PROGRAM
       SetupProgram;
USES
    Visions,Graphics,MouseDrv,Settings,Sounddrv,Crt,NewApps,Types3d;

TYPE
    App_Setup = object(App_Program)
              constructor Init;
              procedure HandleAction;virtual;
              procedure HandleComm;virtual;
              destructor Done;virtual;
              end;
CONST
     cmIrq5  = 100;
     cmIrq7  = 101;
     cmIrq10 = 102;
     cmA210  = 103;
     cmA220  = 104;
     cmA230  = 105;
     cmA240  = 106;
     cmA250  = 107;
     cmA260  = 108;
     cmA270  = 109;
     cmA280  = 110;
     cmIrq3  = 112;
     cmIrq4  = 113;
     cmNoSnd = 114;
     cmCom1  = 115;
     cmCom2  = 116;
     cmTestSound = 117;

constructor App_Setup.Init;
 var
    app_aux : PApp_View;
begin
 inherited Init;
 DeskTop := new(PApp_Window,Init('',0,0,319,199));

 if SearchSetup then ReadSetup
                else begin
                      CreateSetup;
                      with Setup do
                           begin
                            SoundCard:=0;
                            MouseIntr:=$0C;
                            MousePort:=$2F8;
                           end;
                      WriteSetup;
                     end;
 SetupMouse;

 App_Aux:=new(PApp_MenuVert,Init('TEST',102,70,NewMenu(
   NewSubMenu('SOUNDCARD',NewMenu(
      NewSubMenu('SoundBlaster',NewMenu(
         NewSubMenu('Irq',NewMenu(
            NewItem('Irq 5',cmIrq5,
            NewItem('Irq 7',cmIrq7,
            NewItem('Irq 10',cmIrq10,
            nil)))),
         NewSubMenu('Port Adress',NewMenu(
            NewItem('210',cmA210,
            NewItem('220',cmA220,
            NewItem('230',cmA230,
            NewItem('240',cmA240,
            NewItem('250',cmA250,
            NewItem('260',cmA260,
            NewItem('270',cmA270,
            nil)))))))),
          NewItem('Test Sound',cmTestSound,
         nil)))),
      NewItem('No Sound',cmNoSnd,nil))),
   NewSubMenu('Mouse',NewMenu(
      NewSubMenu('Irq',NewMenu(
         NewItem('Irq 3',cmIrq3,
         NewItem('Irq 4',cmIrq4,
         nil))),
      NewSubMenu('Port',NewMenu(
         NewItem('COM 1',cmCom1,
         NewItem('COM 2',cmCom2,
         nil))),nil))),
   NewItem('Exit',cmExit,nil))))));

 App_Aux^.WinActive:=true;
 DeskTop^.InsertItem(App_Aux);
 DeskTop^.InsertItem(new(PApp_Time,Init('00:00:00',269,193,1)));
 DeskTop^.InsertItem(new(PApp_Heap,Init('        ',2,193,1)));
 DeskTop^.InsertItem(new(PApp_Info,Init('','','skyborg.spr','',10,1,0,0,cmNoAction,origin)));
 DeskTop^.InsertItem(New(PApp_Back,Init('setup.spr')));

end;

procedure App_Setup.HandleAction;
begin
 case DeskTop^.Action of
  cmCom1 : Setup.MousePort := $3F8;
  cmCom2 : Setup.MousePort := $2F8;
  cmIrq3 : Setup.MouseIntr := $0B;
  cmIrq4 : Setup.MouseIntr := $0C;
  cmA210 : begin Setup.SoundCard:=7;Setup.Adress:=$210;end;
  cmA220 : begin Setup.SoundCard:=7;Setup.Adress:=$220;end;
  cmA230 : begin Setup.SoundCard:=7;Setup.Adress:=$230;end;
  cmA240 : begin Setup.SoundCard:=7;Setup.Adress:=$240;end;
  cmA250 : begin Setup.SoundCard:=7;Setup.Adress:=$250;end;
  cmA260 : begin Setup.SoundCard:=7;Setup.Adress:=$260;end;
  cmA270 : begin Setup.SoundCard:=7;Setup.Adress:=$270;end;
  cmA280 : begin Setup.SoundCard:=7;Setup.Adress:=$280;end;
  cmNoSnd: Setup.SoundCard:=0;
  cmIrq5 : begin Setup.SoundCard:=7;Setup.Irq:=$0D;end;
  cmIrq7 : begin Setup.SoundCard:=7;Setup.Irq:=$0F;end;
  cmIrq10: begin Setup.SoundCard:=7;Setup.Irq:=$5A;end;
  cmTestSound : begin
                 Base := Setup.Adress;
                 Snd := new(PApp_SB,LoadConfig);
                 Snd^.LoadSound('test.vox',1);
                 Snd^.PlayDMASound(1);
                 delay(1500);
                 Dispose(Snd,Done);
                end;
 end;
 if DeskTop^.Action in [100..117]
    then begin
          WriteSetup;
          SetupMouse;
         end;
end;

procedure App_Setup.HandleComm;
begin
end;

destructor App_Setup.Done;
begin
 inherited Done;
 writeln('Setup v1.01.');
 writeln('Type ''Skyborg'' at your DOS prompt to start !');
 Dispose(DeskTop,Done);
end;

VAR
   MyApp : App_Setup;

begin
 MyApp.Init;
 MyApp.Run;
 MyApp.Done;
end.

