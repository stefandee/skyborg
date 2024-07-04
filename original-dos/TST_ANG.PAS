uses Types3d,crt;
var c,p1,p2 : point3d;
begin
 nework:=new(PnewApp_3d,Init);
 c:=origin;
 clrscr;
 with p1 do begin x:=60;y:=0;z:=0;end;
 with p2 do begin x:=-60;y:=-60;z:=0;end;
 writeln(nework^.RealAngleVPV(c,p1,p2));
 readln;
end.
