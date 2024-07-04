{$M 32768,0,405000}
{$B+}
{$R-}
USES
    INTRO,GRAPHICS,SBLASTER,STRUCTS,VISIONS,MOUSEDRV,NEWAPPS,
    SPACE,CRT,TYPES3D;
TYPE
    PApp_Game = ^App_Game;
    App_Game = object(App_Graph)
             snd : PApp_SB;
             public
              constructor Init;
              procedure Run;virtual;
              destructor Done;
             private
              textscr : array[1..25,1..80] of word;
              C_Line_Start,C_Line_End,C_Row,C_Col : byte;
              procedure GetTextScr;
              procedure RestoreTextScr;
             end;
CONST
     ExitGame  = 1;
     StartGame = 2;
     SetVol    = 3;
     Querry    = 4;
     ShipOne   = 11;
     ShipTwo   = 12;
     None      = 255;

constructor App_Game.Init;
var
   WosIntro : PApp_WosIntro;
   Roll     : PApp_Roll;
   f        : file;
BEGIN
 Snd:=New(PApp_SB,Init);
 Snd^.SB_InternalSet;
 writeln('Initializing internal variables...');
 if base<>0 then writeln('SoundBlaster or compatible found.')
            else writeln('No soundcard detected.');
 GetTextScr;
 InitPath;
 Vga256;
 InitVScreen;
 NeWork:=New(PNewApp_3D,Init);
 LoadFnt('sysfnt.fnt',1);
 {
 WosIntro:=New(PApp_WosIntro,Init);
 WosIntro^.Run;
 Dispose(WosIntro,Done);
 Roll:=New(PApp_Roll,Init);
 Roll^.Run;
 Dispose(Roll,Done);
 }
 LoadPal(palpath+'menupal3.pal');SetPal;
 LoadSpr(imgpath+'cursor.spr',1);
 MouseInit(COM1INTR,COM1PORT);
END;

procedure App_Game.Run;
var
   DeskTop : array[1..21] of PApp_View;
   App_Aux : PApp_View;
   i   : integer;
   key : byte;
   Roll     : PApp_Roll;
   fship : file of Ship;
   fgun  : file of Gun;
   gun_aux : guns;

begin

 {load first ship info's}
 assign(fship,missionpath+'ships.dat');reset(fship);read(fship,crt_ship);
 {init desktop ... this should be make with pointers like TV collection...}
 DeskTop[2]:=New(PApp_Btn,Init('Exit','exit.spr',0,0,exitgame));
 DeskTop[3]:=New(PApp_Btn,Init('Start','start.spr',160,0,startgame));
 DeskTop[4]:=New(PApp_Vol,Init('Volume','volume.spr','volcur.spr',80,0,setvol));
 DeskTop[5]:=New(PApp_Btn,Init('Credits','querry.spr',240,0,querry));
 DeskTop[6]:=New(PApp_Group,Init('MAIN',50,95,220,100));

 DeskTop[10]:=New(PApp_Group,Init('Choose Ship',80,90,160,100));
 assign(fship,missionpath+'ships.dat');reset(fship);
 for i:=1 to 2 do
     begin
      read(fship,crt_ship);
      with Crt_Ship do App_Aux:=New(PApp_Info,Init(name,brf,msprite,shape,80,75,10,21,10+i));
      DeskTop[10]^.InsertItem(App_Aux);
     end;

 DeskTop[21]:=New(PApp_GroupInc,Init('Choose Guns',90,100,140,90));
 assign(fgun,missionpath+'weapons.dat');reset(fgun);
 for i:=1 to 7 do
     begin
      read(fgun,gun_aux[i]);
      crt_ship.carry[i]:=gun_aux[i];
      with Gun_Aux[i] do App_Aux:=New(PApp_Info,Init(name,brf,msprite,'',130,110,8,20,15+i));
      DeskTop[21]^.InsertItem(App_Aux);
     end;
 close(fgun);

 DeskTop[17]:=New(PApp_Info,Init('Help','help.brf','helpkeys.spr','',120,90,10,20,none));
 DeskTop[18]:=New(PApp_Info,Init('WarBrief','warbrief.brf','globe.spr','',120,80,14,20,none));
 DeskTop[7]:=New(PApp_Spc,Init('Equip','Loading.Spr',10,10,none));
 DeskTop[1]:=New(PApp_Back,Init('backgnd.spr'));

 DeskTop[6]^.InsertItem(DeskTop[18]);DeskTop[6]^.InsertItem(DeskTop[17]);
 DeskTop[6]^.InsertItem(DeskTop[10]);DeskTop[6]^.InsertItem(DeskTop[21]);
 with look do begin x:=0;y:=0;z:=30;end;

 repeat
  Cls(0,vaddr);
  key := port[$60];
  FreeBuf;
  for i:=1 to 7 do
      with DeskTop[i]^ do
      begin
       DrawView(vaddr);
       if (LeftBtn) and (Selected(MouseX,MouseY))
       then case Action of
               ExitGame : key := 1;
               SetVol   : begin
                           volcnt := (-SelY+ViewY+spr[1].yl) div 5;
                           if volcnt<1 then volcnt:=1;
                           if volcnt>11 then volcnt:=11;
                           if base<>0 then Snd^.SB_SetVolume;
                          end;
               Querry   : begin
                           Roll:=New(PApp_Roll,Init);
                           Roll^.Run;
                           Dispose(Roll,Done);
                          end;
               StartGame: begin
                          end;
               ShipOne : begin
                          seek(fship,0);
                          read(fship,Crt_Ship);
                          crt_ship.carry:=gun_aux;
                          {!play selection sound!}
                         end;
               ShipTwo : begin
                          seek(fship,1);
                          read(fship,Crt_Ship);
                          crt_ship.carry:=gun_aux;
                          {!play selection sound!}
                         end;
               end;
      end;
  if (comm[1]>=16) and (comm[1]<=22)
     then begin
           case comm[2] of
           2 : if crt_ship.carry[comm[1]-15].currentammo>0
               then begin
                     dec(crt_ship.carry[comm[1]-15].currentammo);
                     if crt_ship.carry[comm[1]-15].currentammo=0
                        then begin
                              dec(crt_ship.currentweight,crt_ship.carry[comm[1]-15].weight);
                              crt_ship.carry[comm[1]-15].get:=false;
                             end;
                     dec(crt_ship.currentweight,crt_ship.carry[comm[1]-15].ammoweight);
                    end;
           1 : if crt_ship.carry[comm[1]-15].currentammo<crt_ship.carry[comm[1]-15].maxammo
              then begin
                    if crt_ship.carry[comm[1]-15].currentammo=0
                       then begin
                             inc(crt_ship.currentweight,crt_ship.carry[comm[1]-15].weight);
                             crt_ship.carry[comm[1]-15].get:=true;
                            end;
                    inc(crt_ship.carry[comm[1]-15].currentammo);
                    inc(crt_ship.currentweight,crt_ship.carry[comm[1]-15].ammoweight);
                   end;
           end;
           comm[1]:=0;
          end;

  PutSpr(1,MouseX,MouseY,gameput,vaddr);
  outint(0,0,memavail,3,255,vaddr);
  Flip;
 until key=1;
 FadeOut(1);
 close(fship);
end;

procedure App_Game.GetTextScr;
 var cr,cc,clst,clen : byte;
begin
 Move(ptr($b800,0)^,textscr,25*80*2);
 asm
  xor bh,bh
  mov ah,3
  int 10h
  mov CR,dh
  mov CC,dl
  mov CLSt,ch
  mov CLEn,cl
 end;
 C_Row:=cr;C_Col:=cc;C_Line_Start:=clst;C_Line_End:=clen;
end;

procedure App_Game.RestoreTextScr;
 var cr,cc,clst,clen : byte;
begin
 Move(textscr,ptr($b800,0)^,25*80*2);
 cr:=C_Row;cc:=C_Col;clst:=C_Line_Start;clen:=C_Line_End;
 asm
  mov ch,CLSt
  mov cl,CLEn
  mov ah,1
  xor bh,bh
  int 10h
  xor bh,bh
  mov dh,CR
  mov dl,CC
  mov ah,2
  int 10h
 end;
end;

destructor App_Game.Done;
begin
 DoneVScreen;
 DoneVga256;
 MouseDone;
 DoneSpr(1);
 dispose(NeWork,Done);
 RestoreTextScr;
 writeln('Thank you for playing SKYBORG, (C) W.O.S, 1995-1996.');
end;

VAR
   Game : PApp_Game;

BEGIN
 Game:=new(PApp_Game,Init);
 Game^.Run;
 dispose(Game,Done);
END.