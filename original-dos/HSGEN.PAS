program
       hsgen;

uses
    types3d,crt;

var
   i,j    : integer;
   rad    : integer;
   o      : newobj;
   f      : file of newobj;
   ang    : integer;
   count  : integer;
   xi,yi,xf,yf : longint;
begin
 nework := new(PNewApp_3d,Init);
 ang := 360 div 10;count := 0;rad := 2048;
 xi := sint[ang];xi := xi*rad div 16384;xi:=-xi;
 yi := cost[ang];yi := yi*rad div 16384;yi:=-yi;

 {make points}
 for i:=1 to 4 do
     begin
      for j:=2 to 10 do
          begin
           inc(count);
           xf := sint[j*ang];xf := xf*rad div 16384;xf:=-xf;
           yf := cost[j*ang];yf := yf*rad div 16384;yf:=-yf;
           o.points[count].x := xi;
           o.points[count].z := yi;
           o.points[count].y := (i-1)*96;
           xi := xf;
           yi := yf;
          end;
      rad := rad-500;
     end;
 o.points[count+1].x := 0;
 o.points[count+1].z := 0;
 o.points[count+1].y := 256;
 o.pointsno := count+1;
 {planes}
 count := 0;
 for i:=1 to 4 do
     begin
      for j:=1 to 10 do
          begin
           inc(count);
           o.planes[count].p1 := count;
           o.planes[count].p2 := count+1;
           o.planes[count].p3 := count+10;
           o.planes[count].p4 := count+11;
           o.planes[count].color := 84+2*i;
          end;
      o.planes[count].p2 := 1;
      o.planes[count].p4 := 10*i+1;
     end;
 o.faceno := count;
 for i:=1 to 10 do begin o.planes[count-11+i].p3 := o.pointsno;o.planes[count-11+i].p4 := o.pointsno;end;

 assign(f,'c:\app\karg\fight\shapes\sky.s3d');
 rewrite(f);
 write(f,o);
 close(f);
end.


