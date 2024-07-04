{$M 56789,0,655360}
{$B+}
{$R-}
{$Q-}

USES
    INTRO,GRAPHICS,SOUNDDRV,STRUCTS,VISIONS,MOUSEDRV,NEWAPPS,
    SPACE,TYPES3D,PLAYGAME,CRT,SETTINGS,PILOT;

TYPE
    PApp_Game = ^App_Game;
    App_Game = object(App_Program)
              fship    : file of Ship;
              fgun     : file of Gun;
              fmis     : file of Mission;
              constructor Init;
              procedure   HandleAction;virtual;
              procedure   HandleComm;virtual;
              destructor  Done;virtual;
             end;
CONST
     ExitGame   = 1;
     cmStart    = 2;
     SetVol     = 3;
     Querry     = 4;
     ShipOne    = 11;
     ShipTwo    = 12;
     cmDetail   = 40;
     cmPltFile  = 50;
     cmFieldMod = 51;
     cmClear    = 52;

constructor App_Game.Init;
CONST
     scale : Point3d = (x:0;y:0;z:0);
VAR
   WosIntro : PApp_WosIntro;
   Roll     : PApp_Roll;
   f        : file;
   App_Win  : PApp_View;
   App_Win1 : PApp_View;
   App_Aux  : PApp_View;
   App_FLB  : PApp_FileListBox;
   Str_Aux  : PStrList;
   Dlg_Aux  : PApp_Dialog;
   Cst_Aux  : PApp_Cluster;
   App_Mss  : PApp_Mission;
   i        : integer;
   key      : byte;
   Game     : PApp_PlayGame;
   gun_aux  : guns;
   auxstr   : string;

BEGIN
 InitPath;
 if not SearchSetup
    then begin
          writeln('Configuration file doesn''t exist. :-(');
          writeln('Better select your HARDWARE before you run the game. ;-)');
          writeln('Please run SETUP first !');
          halt;
         end;
 writeln('Initializing internal variables...');
 ReadSetup;
 {soundcard}
 Base := Setup.Adress;
 case Setup.SoundCard of
  0 : begin
       Snd := new(PApp_Sound,LoadConfig);
       writeln('No soundcard detected. :-(')
      end;
  7 : begin
       Snd:=New(PApp_SB,LoadConfig);
       writeln('SoundBlaster or compatible selected. :-)')
      end;
 end;
 Snd^.InstallTimer;
 {graphics-related init}
 Randomize;
 GetTextScr;
 Vga256;
 InitVScreen;
 NeWork:=New(PNewApp_3D,Init);
 LoadFnt('sysfnt.fnt',1);
 LoadFnt('micro2.fnt',6);
 LoadSpr('pmouse.spr',1);
 Mouse := New(PTMouse,Init);
 {
 WosIntro:=New(PApp_WosIntro,Init);
 WosIntro^.Run;
 Dispose(WosIntro,Done);
 {
 Roll:=New(PApp_Roll,Init);
 Roll^.Run;
 Dispose(Roll,Done);
 }
 {loading data...begin}
 Cls(0,Vaddr);Cls(0,SegA000);
 LoadPal('ldata.pal');SetPal;
 LoadSpr('ldata.spr',2);
 PutSpr(2,0,0,normalput,Vaddr);
 Flip;
 {init desktop}
 DeskTop := new(PApp_Window,Init('',0,0,319,199));
 with DeskTop^ do
      begin
       App_Win := New(PApp_Window,Init('TaskBar',2,178,319,199));
       App_Win^.InsertItem(New(PApp_Btn2,Init('Start',6,183,6,cmStart)));
       App_Win^.InsertItem(New(PApp_Btn2,Init('Credits',34,183,6,querry)));
       App_Win^.InsertItem(New(PApp_Btn2,Init('Exit',70,183,6,cmExit)));
       App_Win^.InsertItem(New(PApp_View,Init('','bar.spr',2,178,cmNoAction)));
       InsertItem(App_Win);
       App_Win := New(PApp_Group,Init('Main',0,0,320,177));
       App_Win1 := New(PApp_Window,Init('Load',0,0,320,177));
       App_Win1^.InsertItem(New(PApp_View,Init('','load.spr',0,0,cmNoAction)));
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Registration-accesing pilot files...',65,20,1)));
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Status',5,60,6)));
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Rank',45,60,6)));
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Name',105,60,6)));
       {
       App_FLB := New(PApp_FileListBox,Init('plt',pilotpath,85,85,50,50,'disk.spr',cmPltFile));
       App_Win1^.InsertItem(New(PApp_MemInputLine,Init(addr(Crt_Pilot.Name),150,85,80,9,cmFieldMod)));
       App_Win1^.InsertItem(New(PApp_MemInputLine,Init(addr(Crt_Pilot.CallSign),150,104,80,9,cmFieldMod)));
       App_Win1^.InsertItem(App_FLB);
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Name:',150,79,1)));
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Callsign:',150,98,1)));
       App_Win1^.InsertItem(New(PApp_StaticText,Init('Files:',85,79,1)));
       App_Win1^.InsertItem(New(PApp_MemStr,Init('',addr(Crt_Pilot.RankStr),'',85,140,1)));
       App_Win1^.InsertItem(New(PApp_MemStr,Init(',',addr(Crt_Pilot.StatusStr),'',170,140,1)));
       App_Win1^.InsertItem(New(PApp_MemStr,Init('Op.',addr(Crt_Mission.BattleStr),'',85,146,1)));
       App_Win1^.InsertItem(New(PApp_MemLInt,Init(',Mission ',addr(Crt_Mission.MissionNR),'',170,146,1)));
       App_Win1^.InsertItem(New(PApp_MemLInt,Init('',addr(Crt_Pilot.Points),' duty points',85,152,1)));
       }
       App_Win1^.InsertItem(New(PApp_Btn2,Init('Clear',145,160,6,cmClear)));
       App_Win1^.InsertItem(New(PApp_GBack,Init(0,0,319,178,1)));
       App_Win^.InsertItem(App_Win1);
       InsertItem(App_Win);
      end;
 {load pilot info}
 Crt_Pilot.LoadFirst;
 Crt_Pilot.LoadMission;
 {set screen for desktop}
 DoneSpr(2);
 FadeOut(2);
 Cls(0,Vaddr);
 Cls(0,SegA000);
 LoadPal('main.pal');SetPal;
END;

procedure App_Game.HandleAction;
var
   Game : PApp_PlayGame;
BEGIN
 case DeskTop^.Action of
  cmStart : begin
             Game:=New(PApp_PlayGame,Init);
             Game^.Run;
             Dispose(Game,Done);
            end;
 end;
END;

procedure App_Game.HandleComm;
BEGIN
END;

destructor App_Game.Done;
BEGIN
 FadeOut(3);
 Snd^.PlayStop;
 Snd^.UnInstallTimer;
 dispose(Snd,Done);
 DoneVScreen;
 DoneVga256;
 Dispose(Mouse,Done);
 DoneSpr(1);
 dispose(NeWork,Done);
 RestoreTextScr;
 writeln('Thank you for playing SKYBORG, (C) W.O.S, 1995-1996.');
END;

VAR
   Game : PApp_Game;

BEGIN
 Game:=new(PApp_Game,Init);
 Game^.Run;
 dispose(Game,Done);
END.