program
       sky_generator;

uses
    types3d,crt;

var
    o     : pnewobj;
    f     : file of newobj;
    i     : integer;
    xi,yi : longint;
    xf,yf : longint;
    count : integer;
    centerang,radius : integer;
    x,y   : integer;

begin
 new(o);
 nework := new(PNewApp_3d,init);
 clrscr;
 count := 0;
 radius := 4096;
 centerang := 360 div 20;x := 0;y := 0;
 xi := sint[centerang];xi := xi*radius div 16384;xi:=x-xi;
 yi := cost[centerang];yi := yi*radius div 16384;yi:=y-yi;

 for i:=2 to 20 do
     begin
      inc(count);
      xf := sint[(i*centerang) mod 360];
      xf := xf*radius div 16384;
      yf := cost[(i*centerang) mod 360];
      yf := yf*radius div 16384;
      xf:=x-xf;
      yf:=y-yf;
      o^.points[count].x := xi;
      o^.points[count].z := 0;
      o^.points[count].y := yi;
      writeln(count,' . ',xi,' ',yi);
      o^.planes[count].p1 := count;
      o^.planes[count].p2 := count+1;
      o^.planes[count].color := 84+count;
      xi := xf;
      yi := yf;
     end;
 readln;
 o^.planes[count].p2 := 1;
 inc(count);
 o^.points[count].x := 0;
 o^.points[count].z := 0;
 o^.points[count].y := 0;
 o^.pointsno := count;
 o^.faceno   := count-1;

 for i:=1 to count do begin o^.planes[i].p3 := count;o^.planes[i].p4 := count;end;
 for i:=1 to o^.faceno do begin writeln(i,'.',o^.planes[i].p1,' ',o^.planes[i].p2,' ',o^.planes[i].p3,' ',o^.planes[i].p4);end;

 assign(f,'c:\app\karg\fight\shapes\sky.s3d');
 rewrite(f);
 write(f,o^);
 close(f);

end.
