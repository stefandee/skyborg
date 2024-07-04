UNIT
    PLAYGAME;

INTERFACE

USES
    SPACE,GRAPHICS,STRUCTS,MOUSEDRV,TYPES3D,CRT,VISIONS,DOS,PILOT;

TYPE
    PApp_PlayGame = ^App_PlayGame;
     App_PlayGame = object(App_Graph)
              Previous_Pal : PalType;
              Status       : byte;
              {
               0 - playing;
               1 - death;
               2 - failed;
               3 - success;
               6 - quit by escape;
              }
              constructor Init;
              procedure Run;virtual;
              destructor Done;virtual;
              private
               Xlc,Xrc,Ytc,Ybc : integer;
              end;

IMPLEMENTATION

constructor App_PlayGame.Init;
VAR
    i         : integer;
    aux       : PIntoSpace;
    aux_point : Point3d;
    aux_com   : CommZone;
    aux_str   : Str20;

begin
 for i:=0 to 255 do GetRGB(i,Previous_Pal[i,1],Previous_Pal[i,2],Previous_Pal[i,3]);
 workpal := Previous_Pal;
 FadeOut(2);

 Vga256;
 InitPath;
 InitVScreen;
 LoadFnt('micro2.fnt',6);

 Randomize;
 Cls(0,SegA000);
 Cls(0,vaddr);
 LoadPal('fight3.pal');SetPal;
 Gfx := new(PApp_Graph,Init);
 Gfx^.workpal:=workpal;
 for i:=1 to 7 do Gfx^.LoadSpr(crt_ship.carry[i].sprite,20+i);
 for i:=1 to 9 do Gfx^.LoadSpr('expld0'+char(48+i)+'.spr',29+i);
 Gfx^.LoadSpr('expld10.spr',39);

 Gfx^.LoadSpr('particle.spr',6);
 Gfx^.LoadSpr('shield.spr',8);
 Gfx^.LoadSpr('lradar.spr',9);
 Gfx^.LoadSpr('rradar.spr',10);

 Status := 0;SpaceRoot:=Nil;
 LoadObjects;
 LoadDmg;
 { now init the SpaceRoot...}
 for i:= 1 to Crt_Mission.MaxMap do
     begin
      aux:=new( PIntoSpace,
                Init( Crt_Mission.Map[i].X,Crt_Mission.Map[i].Name,Crt_Mission.Map[i].FlightInd,
                      Crt_Mission.Map[i].ShapeNo,Crt_Mission.Map[i].DmgNo,Crt_Mission.Map[i].HullRU,
                      Crt_Mission.Map[i].Points));
      aux^.curent:=false;
      Ins2Space(aux);
     end;

 My_Craft:=new(PMyCraft,Init(Crt_Mission.MyCraft,100));
 aux:=My_Craft;
 aux^.curent:=true;
 Ins2Space(aux);
 Crt_Craft:=Aux;

 if TheSun
    then begin
          {insert sun}
          Gfx^.LoadSpr('sun.spr',3);
          with aux_point do begin x:=0;y:=30000;z:=0 end;
          aux:=new(PSun,Init(aux_point,3));
          Ins2Space(aux);
         end;

 if Clouds
    then begin{insert clouds}
          Gfx^.LoadSpr('cloud01.spr',4);
          Gfx^.LoadSpr('cloud02.spr',5);
          for i:=1 to 4 do
              begin
               with aux_point do begin x:=-12000;{random(65535)};y:=2000+random(1000);z:=12000{random(65535)};end;
               aux := new(PScaled,Init(aux_point,'CLOUDS',random(2)+4,5000,500));
               Ins2Space(aux);
              end;
         end;
 if Trees
    then begin
          aux_com[1] := 0;aux_com[3] := 0;
          aux_str := 'Tree';
          for i:=1 to Crt_Mission.TreeCnt do
              begin
               aux:=new( PIntoSpace,Init(aux_com,aux_str,'',
                         Crt_Mission.Trees[i].shapeno,1,20,0));
               aux^.look := Crt_Mission.Trees[i].pos;
               aux^.curent := false;
               Ins2Space(aux);
              end;
         end;
 TheSky := new(PSky,Init);
 TheSky^.look := Crt_Craft^.look;
 dec(TheSky^.look.z,128);
 Crt_Pilot.ClearBrf;
 {inc(TheSky^.look.y,4096);}

 {
 aux:=new(PSky,Init);
 Ins2Space(aux);
 }
end;

procedure App_PlayGame.Run;
const FirstTimeP : boolean = True;
type obj = record
         name   : string[20];
         speed  : integer;
         alt    : integer;
         dummy1 : point3d;
         dummy2 : point3d;
         end;
var aux,eraser   : PIntoSpace;
    cnt,i,j      : integer;
    radar        : array[1..20] of obj;
    craft_color  : byte;
    PrimaryAc    : boolean;{for mission surveillance}
    SecondaryAc  : boolean;
    BonusAc      : boolean;
    TotalPrimary : byte;
    TotalSecondary : byte;
    TotalBonus   : byte;
    AccPrimary   : byte;
    AccSecondary : byte;
    AccBonus     : byte;
    FMission     : file of Mission;
begin
 repeat
  cls(0{Crt_Mission.GndType},vaddr);
  PrimaryAc := True;SecondaryAc := True;BonusAc := True;
  {check if objectives are accomplished}
  for i := 1 to Crt_Mission.MaxGoals do
      case Crt_Mission.Goals[i].GoalImpt of
       1 : if not Crt_Mission.Goals[i].Done then PrimaryAc   := False;
       2 : if not Crt_Mission.Goals[i].Done then SecondaryAc := False;
       3 : if not Crt_Mission.Goals[i].Done then BonusAc     := False;
      end;

  {mission succesful = primary objectives accomplished - check down here}
  if FirstTimeP then
     if PrimaryAc then begin
        Ins2MsgQueue(My_Craft^.MQ,'All objectives acomplished',14);
        Ins2MsgQueue(My_Craft^.MQ,'Now return to base !',14);
        FirstTimeP := False;
        inc(Crt_Pilot.Debrief.Points,1000);
       end;

  {do the strategy}
  aux := SpaceRoot;
  eraser := aux;
  DrawSpaceRoot:=nil;
  cnt:=1;
  while aux<>nil do
        begin
         {do the strategy}
         if not aux^.curent then aux^.Strategy(status);
         {mission surveillance}
         for i := 1 to Crt_Mission.MaxGoals do
             begin
              case Crt_Mission.Goals[i].GoalType of
               {objective must be destroyed}
               1 : if not Crt_Mission.Goals[i].Done then
                      if (Crt_Mission.Goals[i].GoalSubj=aux^.FlightInd) then
                         if aux^.I_Was_Destroyed then
                         begin
                          Crt_Mission.Goals[i].Done := true;
                          for j:=1 to Crt_Mission.Goals[i].GoalCommL do
                              begin
                               Ins2MsgQueue(My_Craft^.MQ,Crt_Mission.Goals[i].GoalComm[j],20);
                              end;
                          inc(Crt_Pilot.Debrief.Points,aux^.points);
                         end;
              {objective must be inspected}
              2 : if not Crt_Mission.Goals[i].Done then
                     if (Crt_Mission.Goals[i].GoalSubj=aux^.FlightInd) then
                        if nework^.DistancePP(aux^.look,My_Craft^.look)<50 then
                           begin
                            Crt_Mission.Goals[i].Done := true;
                            for j:=1 to Crt_Mission.Goals[i].GoalCommL do
                                begin
                                 Ins2MsgQueue(My_Craft^.MQ,Crt_Mission.Goals[i].GoalComm[j],20);
                                end;
                           end;
              {objective must have survived - Done is true}
              3 : if Crt_Mission.Goals[i].Done then
                     if (Crt_Mission.Goals[i].GoalSubj=aux^.FlightInd) then
                         if aux^.I_Was_Destroyed then
                         begin
                          Crt_Mission.Goals[i].Done := false;
                          for j:=1 to Crt_Mission.Goals[i].GoalCommL do
                              begin
                               Ins2MsgQueue(My_Craft^.MQ,Crt_Mission.Goals[i].GoalComm[j],20);
                              end;
                         end;
             end;
            end;
         if (aux^.Dispose_me) or (aux^.I_Was_Destroyed)
            then if aux=SpaceRoot
                    then begin
                          SpaceRoot:=SpaceRoot^.next;
                          dispose(aux,Done);
                          aux := SpaceRoot;
                          eraser := aux;
                         end
                    else begin
                          eraser^.next := aux^.next;
                          dispose(aux,Done);
                          aux := eraser^.next;
                         end
            else begin
                  aux^.sortdistance:=nework^.DistancePP(Crt_Craft^.look,aux^.look);
                  Ins2DrawSpace(aux);
                  eraser := aux;
                  aux    := aux^.next;
                  {
                  if aux^.X[1]<>0
                     then begin
                           radar[cnt].name:=aux^.name;
                           radar[cnt].speed:=aux^.shield;
                           radar[cnt].alt:=aux^.sortdistance;
                           radar[cnt].dummy2:=aux^.look;
                           inc(cnt);
                          end;}
                 end;
        end;

  { do the drawings... }
  {TheSky^.Draw(Crt_Craft^.eyevi,Crt_Craft^.eyevj,Crt_Craft^.eyevk,Crt_Craft^.look);}
  aux := DrawSpaceRoot;
  while aux<>nil do
        begin
         if not aux^.curent
            then aux^.Draw(Crt_Craft^.eyevi,Crt_Craft^.eyevj,Crt_Craft^.eyevk,Crt_Craft^.look);
         aux:=aux^.nextdraw;
        end;

  Crt_Craft^.Strategy(status);
  {sound(1000);delay(30);nosound;readln;}
  Crt_Craft^.Draw(Crt_Craft^.eyevi,Crt_Craft^.eyevj,Crt_Craft^.eyevk,Crt_Craft^.look);
{
  for i:=1 to cnt-1 do
      begin
       outtext(xleftclip,90+i*10,radar[i].name,6,255,vaddr);
       outint(xleftclip+100,90+i*10,radar[i].speed,6,255,vaddr);
       outint(xleftclip+130,90+i*10,radar[i].alt,6,255,vaddr);
       {outint(xleftclip+160,90+i*10,radar[i].dummy1.x,6,255,vaddr);
       outint(xleftclip+175,90+i*10,radar[i].dummy2.x,6,115,vaddr);
       outint(xleftclip+190,90+i*10,radar[i].dummy1.y,6,255,vaddr);
       outint(xleftclip+205,90+i*10,radar[i].dummy2.y,6,115,vaddr);
       outint(xleftclip+220,90+i*10,radar[i].dummy1.z,6,255,vaddr);
       outint(xleftclip+235,90+i*10,radar[i].dummy2.z,6,115,vaddr);
      end;}
  outint(150,10,memavail,6,124,vaddr);
  flip;
 until status <> 0;

 {count all goals}
 TotalPrimary := 0;TotalSecondary := 0;TotalBonus := 0;
 AccPrimary   := 0;AccSecondary := 0; AccBonus := 0;
 for i := 1 to Crt_Mission.MaxGoals do
      case Crt_Mission.Goals[i].GoalImpt of
       1 : begin
            inc(TotalPrimary);
            if Crt_Mission.Goals[i].Done then inc(AccPrimary)
           end;
       2 : begin
            inc(TotalSecondary);
            if Crt_Mission.Goals[i].Done then inc(AccSecondary)
           end;
       3 : begin
            inc(TotalBonus);
            if Crt_Mission.Goals[i].Done then inc(AccBonus)
           end;
      end;
 if TotalPrimary<>0
    then Crt_Pilot.Insert2Brf( 'Primary objectives : '+Int2Str(AccPrimary)+' of '+
                               Int2Str(TotalPrimary)+' ('+Int2Str(AccPrimary*100 div TotalPrimary)+'%)',5);
 if TotalSecondary<>0
    then Crt_Pilot.Insert2Brf( 'Secondary objectives : '+Int2Str(AccSecondary)+' of '+
                               Int2Str(TotalSecondary)+' ('+Int2Str(AccSecondary*100 div TotalSecondary)+'%)',6);
 if TotalBonus<>0
    then Crt_Pilot.Insert2Brf( 'Bonus objectives : '+Int2Str(AccBonus)+' of '+
                               Int2Str(TotalBonus)+' ('+Int2Str(AccBonus*100 div TotalBonus)+'%)',7);
 {if mission accomplished}
 if PrimaryAC
    then begin
          Crt_Pilot.Battles[Crt_Mission.BattleNr,Crt_Mission.MissionNr] := Crt_Pilot.Debrief.points;
          Crt_Pilot.Insert2Brf('Score : '+Int2Str(Crt_Pilot.Debrief.Points),3);
          Crt_Pilot.Insert2Brf('Kills(you) : '+Int2Str(Crt_Pilot.Debrief.Kills)+'('+Int2Str(Crt_Pilot.Debrief.YKill)+')',4);
          Crt_Pilot.Insert2Brf('The mission was a Success',1);
          if Crt_Mission.MedalAward<>255 then Crt_Pilot.Insert2Brf('Medal awarded',12);
          if Crt_Mission.Promotion<>255
             then begin
                   Crt_Pilot.Rank2Str(Crt_Mission.Promotion);
                   Crt_Pilot.Insert2Brf('Promotion to '+Crt_Pilot.RankStr,11);
                  end;
          assign(FMission,missionpath+'missions.dat');
          reset(FMission);
          {no failpos/winpos style-see 1942paw doc from MPS}
          seek(FMission,Crt_Mission.winpos);
          read(FMission,Crt_Mission);
          close(FMission);
          {add here the pilot log information}
          Crt_Pilot.CalcPoints;
          Crt_Pilot.CrtDiskPos := Crt_Mission.WinPos;
          Crt_Pilot.LoadMission;
         end
    else begin
          Crt_Pilot.Insert2Brf('Score : 0',3);
          Crt_Pilot.Insert2Brf('Kills(you) : '+Int2Str(Crt_Pilot.Debrief.Kills)+'('+Int2Str(Crt_Pilot.Debrief.YKill)+')',4);
          Crt_Pilot.Insert2Brf('The mission was a FAILURE',1);
         end;
 Crt_Pilot.Save;
end;

destructor App_PlayGame.Done;
var i : integer;
begin
 Cls(0,SegA000);Cls(0,vaddr);
 for i:=0 to 255 do SetRGB(i,Previous_Pal[i,1],Previous_Pal[i,2],Previous_Pal[i,3]);
 Dispose(TheSky,Done);
 DisposeObjects;
 DisposeDmg;
 DoneSpace;
 {DoneFnt(6);DoneVga256;DoneVScreen;}
 if TheSun then Gfx^.DoneSpr(3);
 if Clouds
    then begin
          Gfx^.DoneSpr(4);
          Gfx^.DoneSpr(5);
         end;
 for i:=1 to 7 do Gfx^.DoneSpr(20+i);
 Gfx^.DoneSpr(6);
 Gfx^.DoneSpr(8);
 Gfx^.DoneSpr(9);
 Gfx^.DoneSpr(10);
 Dispose(Gfx,Done);
end;

BEGIN
END.