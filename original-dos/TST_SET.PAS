uses
    Visions,Graphics,MouseDrv,Settings;

var
   g       : PApp_Graph;
   DeskTop : array[1..10] of PApp_View;
   i,key   : byte;
   aux : string;

const
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
     cmExit  = 111;
     cmIrq3  = 112;
     cmIrq4  = 113;
     cmNoSnd = 114;
     cmCom1  = 115;
     cmCom2  = 116;
     cmTestSound = 117;
     cmTestStr = 118;

begin

 g:=new(PApp_Graph,Init);
 with g^ do
      begin
       Vga256;
       InitVScreen;
       InitPath;
       LoadPal('menupal4.pal');SetPal;
       LoadFnt('sysfnt.fnt',1);
       LoadSpr('cursor.spr',1);
      end;

 if SearchSetup then ReadSetup
                else begin
                      CreateSetup;
                      with Setup do
                           begin
                            SoundCard:=0;
                            MouseIntr:=$0C;
                            MousePort:=$2F8;
                           end;
                     end;
 SetupMouse;

 DeskTop[1]:=New(PApp_Back,Init('setup.spr'));
 DeskTop[2] := new(PApp_MenuVert,Init('TEST',102,70,NewMenu(
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
            NewItem('280',cmA280,
            nil))))))))),
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

 DeskTop[2]^.WinActive:=true;
 DeskTop[3] := new(PApp_Time,Init('00:00:00',269,193));
 DeskTop[4] := new(PApp_Mem,Init('        ',2,193));
 DeskTop[5] := new(PApp_Btn,Init('','skyborg.spr',10,1,cmNoAction));

 {
 DeskTop[6] := new(PApp_Window,Init('Window Test',10,10,100,100));
 DeskTop[6]^.InsertItem(new(PApp_InputLine,Init('NEWTEXT',15,15,105,8,cmTestStr)));
 DeskTop[6]^.InsertItem(new(PApp_InputLine,Init('ANOTHER',15,25,105,8,cmTestStr)));
 DeskTop[6]^.InsertItem(new(PApp_Btn,Init('Exit','exit.spr',15,35,cmExit)));
 DeskTop[6]^.WinActive := true;
 }

 repeat
  g^.Cls(0,vaddr);
  key := port[$60];
  if key<128 then begin comm[1]:=cmKbd;comm[2]:=key;end;
  g^.FreeBuf;
  for i:=1 to 5 do
      with DeskTop[i]^ do
           begin
            DrawView(vaddr);
            if Selected(MouseX,MouseY) and WinActive
               then begin
                     case DeskTop[i]^.Action of
                      cmExit : begin
                                g^.DoneFnt(1);
                                g^.DoneSpr(1);
                                g^.FadeOut(3);
                                g^.DoneVScreen;
                                g^.DoneVga256;
                                writeln('Setup v1.01.');
                                writeln('Type ''Skyborg'' at your DOS prompt to start !');
                                g^.FreeBuf;
                                Dispose(g,Done);
                                for i:=1 to 5 do DeskTop[i]^.Done;
                                MouseDone;
                                halt;
                               end;
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
                      cmIrq5 : begin Setup.SoundCard:=7;Setup.Irq:=5;end;
                      cmIrq7 : begin Setup.SoundCard:=7;Setup.Irq:=7;end;
                      cmIrq10: begin Setup.SoundCard:=7;Setup.Irq:=10;end;
                     end;
                     WriteSetup;
                     SetupMouse;
                    end;
           end;
 {
  if Comm[1]=cmTestStr
     then begin
           aux:='';
           Comm[1]:=cmNoAction;
           for i:=2 to 15 do aux:=aux+char(comm[i]);
           comm[1]:=cmNoAction;
          end;
 }
  g^.PutSpr(1,MouseX,MouseY,gameput,vaddr);
  g^.Flip;
 until false;

end.