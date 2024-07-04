{$M 32768,0,655360}
program
       mixer;

uses
    sounddrv,crt;

var
   key : byte;
   pv  : TProc;

begin
 clrscr;
 Snd := new(PApp_SB,InternalSet);
 volcnt := 11;
 Snd^.SetVolume;
 Snd^.LoadSound('beback.2f',1);
 Snd^.LoadSound('alienlif.2f',2);
 Snd^.InstallTimer;
 repeat
  key := port[$60];
  case key of
   2 :  Snd^.PlaySound(1);
   3 :  Snd^.PlaySound(2);
  end;
  writeln('loop');
  delay(50);
  if key<128 then writeln(key);
 until key = 1;
 Snd^.UnInstallTimer;
 Snd^.FreeSound(1);
 Snd^.FreeSound(2);
end.