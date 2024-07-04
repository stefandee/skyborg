program test_the_game;

uses PlayGame,MouseDrv,Space,TYpes3d,Graphics;

var
   Pg : PApp_PlayGame;
   fm : file of Mission;
   fs : file of Ship;
   fg : file of Gun;
   i  : integer;
begin
 writeln(memavail);
 assign(fm,'c:\app\karg\fight\missions\missions.dat');
 reset(fm);read(fm,Crt_Mission);close(fm);
 assign(fs,'c:\app\karg\fight\missions\ships.dat');
 reset(fs);seek(fs,1);read(fs,Crt_Ship);close(fs);
 assign(fg,'c:\app\karg\fight\missions\weapons.dat');reset(fg);
 for i:=1 to 7 do read(fg,crt_ship.carry[i]);
 close(fg);
 MouseInit(Com1Intr,Com1Port);
 nework:=new(PNewapp_3d,Init);
 Pg:=New(PApp_PlayGame,Init);
 Pg^.Run;
 Dispose(Pg,Done);
 MouseDone;
 Dispose(nework,Done);
 writeln(memavail);
end.
