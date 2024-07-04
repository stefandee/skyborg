UNIT
    PILOT;

INTERFACE

USES
    VISIONS,STRUCTS,DOS,TYPES3D,CRT;

CONST
     MaxWeapon     = 7;
     MaxGadgets    = 6;

TYPE
    Gun  = record
            Name               : Title;
            Sprite,MSprite,Brf : string[12];
            MaxAmmo            : word;
            CurrentAmmo        : word;
            Weight             : word;
            AmmoWeight         : word;
            DrainedRU          : word;
            Get                : boolean;
            end;

    guns = array[1..maxweapon] of gun;

    Ship    = record
              name,shape,brf,sprite,msprite,dmg : string[12];
              gadgets : array[0..1,1..maxgadgets] of point2d;
              maxcarry : word;
              carry : guns;
              speed : word;
              accel : word;
              decel : word;
              HullRU: byte;{hull resistence unit}
              whatweapon : shortint;
              multiple : boolean;
              currentweight : integer;
              end;


   MissionGoal = record
               GoalType  : byte;
               GoalImpt  : byte;{1-primary,2-secondary,3-bonus}
               GoalSubj  : Str20;
               GoalComm  : array[1..10] of Title;
               GoalCommL : byte;
               Done      : boolean;
               end;


   Objective = record
             BrieFile     : string[12];
             DmgNo        : integer;
             Name         : Str20;
             HullRU       : byte;
             FlightInd    : StrInd;
             ShapeNo      : byte;
             X            : CommZone;
             zfact        : integer;
             micro        : byte;
             show         : boolean;
             Points       : longint;
             angst,angvar : point3d;{for mission briefing}
             end;

   Peisage = record
           pos      : Point3D;
           shapeno  : integer;
           end;

   Mission = record
           BattleStr         : string[25];
           BattleNr          : longint;
           MissionNr         : longint;
           Name              : string[25];
           Shapes            : array[1..50] of string[12];
           Dmg               : array[1..50] of string[12];
           Micro             : array[1..11] of string[12];
           Map               : array[1..50] of objective;
           MiniBrief         : array[1..10] of string[12];
           Trees             : array[1..40] of Peisage;
           Goals             : array[1..15] of MissionGoal;
           TreeCnt           : integer;
           MaxMap,MaxShapes,
           MaxMicro,MaxDmg ,
           MaxGoals          : integer;
           MyCraft           : point3d;
           SkyType           : byte;{color}
           GndType           : byte;
           MedalAward        : byte;{255-none,other-a positon in an array}
           Promotion         : byte;{255-none,other-new rank}
           FailPos,WinPos    : longint;
           {
             General structures - if it's too difficult
             only one could be used and setting failpos
             to the curent mission.
           }
           end;

    {this variable must be cleared before a mission}
    TDebrief = record
             text   : array[1..15] of Str40;
             points : longint;
             kills  : longint;{he he !}
             ykill  : longint;
             end;

    TGunStatistic = record
                  Name     : Str20;
                  Fired    : longint;
                  Hit      : longint;
                  Procent  : longint;
                  ToScreen : Str40;
                  end;

    TCraftStatistic = record
                    Name     : Str20;
                    Shot     : longint;{almost impossible!}
                    ToScreen : Str40;
                    end;

    TPilot      = object
                Name           : Title;
                Picture        : string[12];
                FileName       : Title;
                CallSign       : Title;
                RankStr        : Title;
                StatusStr      : Title;
                Points         : longint;
                Battles        : array[1..10,1..8] of longint;
                CrtDiskPos     : longint;
                Rank           : byte;
                Status         : byte;
                Debrief        : TDebrief;
                GunStatistic   : array[1..10] of TGunStatistic;
                CraftStatistic : array[1..40] of TCraftStatistic;
                constructor Init;
                procedure   Load;
                procedure   LoadFirst;
                procedure   LoadMission;
                procedure   Save;
                procedure   Clear;
                procedure   CalcPoints;
                procedure   Rank2Str(r : byte);
                procedure   Status2Str(s : byte);
                procedure   Insert2Brf(t : Str40;l : byte);
                procedure   Insert2Craft(n : Title);
                procedure   Insert2GunFired(n : Str20);
                procedure   Insert2GunHit(n : Str20);
                procedure   ClearBrf;
                destructor  Done;
                end;

VAR
   Crt_Pilot     : TPilot;
   Crt_Ship      : Ship;
   Crt_Mission   : Mission;

IMPLEMENTATION

constructor TPilot.Init;
begin
end;

procedure TPilot.Load;
var
   f : file;
begin
 assign(f,pilotpath+FileName);
 reset(f,1);
 blockread(f,Name,sizeof(Name));
 blockread(f,Picture,sizeof(Picture));
 blockread(f,FileName,sizeof(Filename));
 blockread(f,CallSign,sizeof(CallSign));
 blockread(f,Points,sizeof(Points));
 blockread(f,Battles,sizeof(Battles));
 blockread(f,RankStr,sizeof(RankStr));
 blockread(f,Rank,sizeof(Rank));
 blockread(f,StatusStr,sizeof(StatusStr));
 blockread(f,Status,sizeof(Status));
 blockread(f,Debrief,sizeof(Debrief));
 blockread(f,GunStatistic,sizeof(GunStatistic));
 blockread(f,CraftStatistic,sizeof(CraftStatistic));
 close(f);
end;

procedure TPilot.LoadFirst;
var
   ts : SearchRec;
   f  : file;
begin
 FindFirst(pilotpath+'*.plt',$3F,ts);
 if doserror=0
    then begin
          FileName := ts.name;
          Load;
          {artificii !}
          FileName := ts.name;
         end
    else begin
          Clear;
          FileName := 'Pilot1.plt';
          Save;
         end;
end;

procedure TPilot.Save;
var
   f : file;
begin
 assign(f,pilotpath+FileName);
 rewrite(f,1);
 blockwrite(f,Name,sizeof(Name));
 blockwrite(f,Picture,sizeof(Picture));
 blockwrite(f,FileName,sizeof(filename));
 blockwrite(f,CallSign,sizeof(CallSign));
 blockwrite(f,Points,sizeof(Points));
 blockwrite(f,Battles,sizeof(Battles));
 blockwrite(f,RankStr,sizeof(RankStr));
 blockwrite(f,Rank,sizeof(Rank));
 blockwrite(f,StatusStr,sizeof(StatusStr));
 blockwrite(f,Status,sizeof(Status));
 blockwrite(f,Debrief,sizeof(Debrief));
 blockwrite(f,GunStatistic,sizeof(GunStatistic));
 blockwrite(f,CraftStatistic,sizeof(CraftStatistic));
 close(f);
end;

procedure TPilot.CalcPoints;
var
   i,j : integer;
   sum : longint;
begin
 Points := 0;
 for i:=1 to Crt_Mission.BattleNr do
     for j:=1 to Crt_Mission.MissionNr do
         inc(Points,Battles[i,j]);
end;

procedure TPilot.Rank2Str;
begin
 Rank := R;
 case Rank of
 0 : RankStr := '2nd Liutenant';
 1 : RankStr := '1st Liutenant';
 2 : RankStr := 'Captain';
 3 : RankStr := 'Colonel';
 4 : RankStr := 'Commander';
 end;
end;

procedure TPilot.Status2Str;
begin
 Status := s;
 case Status of
 0 : StatusStr := 'KIA';
 1 : StatusStr := 'Active';
 2 : StatusStr := 'Retired';{at the end of the game}
 3 : StatusStr := 'Captured';
 end;
end;

procedure TPilot.Insert2Brf;
 var
    i   : integer;
    pos : integer;
    len : integer;
begin
 pos := sizeof(Str40) div 2-length(t) div 2;
 if pos<1 then begin pos := 1;len := sizeof(Str40)-1; end
    else len := length(t);
 Debrief.Text[l,0]:=char(sizeof(Str40));
 Insert(t,Debrief.Text[l],pos);
 {for i:=1 to len do Debrief.Text[l,pos+i-1] := t[i];}
end;

procedure TPilot.ClearBrf;
 var
    i : integer;
    t : Str40;
begin
 Debrief.Kills := 0;
 Debrief.YKill := 0;
 Debrief.Points := 0;
 for i:=1 to sizeof(t) do t[i]:=' ';
 for i:=1 to 8 do Insert2Brf(t,i);
end;

procedure TPilot.Clear;
 var
    i,j : integer;
begin
 RankStr    := '2nd Liutenant';
 Rank       := 0;
 Status     := 0;
 StatusStr  := 'Active';
 Points     := 0;
 CrtDiskPos := 0;
 for i:=1 to Crt_Mission.BattleNr do for j:=1 to Crt_Mission.MissionNr do Battles[i,j]:=0;
 ClearBrf;
 Insert2Brf('No mission played yet !',1);
 Insert2Brf('Score : 0',3);
 Insert2Brf('Kills(you) : '+Int2Str(Debrief.Kills)+'('+Int2Str(Debrief.YKill)+')',4);
 for i:=1 to 10 do
     with GunStatistic[i] do
          begin
           ToScreen:='';
           Fired:=0;
           Hit:=0;
           Procent:=0;
           Name := '';
          end;
end;

procedure TPilot.LoadMission;
var
   fmis  : file of Mission;
begin
 assign(fmis,missionpath+'missions.dat');
 reset(fmis);
 seek(fmis,CrtDiskPos);
 read(fmis,Crt_Mission);
 close(fmis);
end;

procedure TPilot.Insert2Craft;
 var
    i : integer;
begin
 for i:=1 to 40 do
     with CraftStatistic[i] do
          if (Name=N) or (Name='') then
             begin
              inc(Shot);
              Name := N;
              ToScreen := N+' : '+Int2Str(Shot);
              exit;
             end;
end;

procedure TPilot.Insert2GunFired;
 var
    i : integer;
begin
 for i:=1 to 10 do
     with GunStatistic[i] do
          if (Name=N) or (Name='')
             then begin
                   inc(Fired);
                   Procent := (Hit*100) div Fired;
                   ToScreen :=N+'(Hit) : '+Int2Str(Fired)+'('+Int2Str(Hit)+')'+' '+Int2Str(Procent)+'%';
                   if Name = '' then Name := N;
                   exit;
                  end;
end;

procedure TPilot.Insert2GunHit;
 var
    i : integer;
begin
 for i:=1 to 10 do
     with GunStatistic[i] do
          if Name=N
             then begin
                   inc(Hit);
                   Procent := (Hit*100) div Fired;
                   ToScreen :=N+'(Hit) : '+Int2Str(Fired)+'('+Int2Str(Hit)+')'+' '+Int2Str(Procent)+'%';
                   exit;
                  end;
end;

destructor TPilot.Done;
begin
end;

BEGIN
END.