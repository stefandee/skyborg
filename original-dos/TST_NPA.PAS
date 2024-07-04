program New_Construction;

uses
    Types3d,graphics,dos,crt;
const
     test : integer=0;
var
   f : file of newobj;
   gr : Papp_graph;
   o : pnewobj;
   obj : newobj;
   angx,angy : integer;
   zfact : integer;
   i,j : integer;
   h,m,so,sn,so100,sn100 : word;
   zerocount : longint;
   v,pd : longint;

begin
 gr:=New(Papp_graph,Init);
 nework:=new(pnewapp_3d,init);
 gr^.vga256;
 gr^.initvscreen;
 gr^.loadpal('c:\app\karg\fight\pal\menupal4.pal');
 gr^.setpal;
 new(o);
 assign(f,'c:\app\karg\fight\shapes\f22.s3d');
 reset(f);
 read(f,o^);
 close(f);

 {with o.points[1] do begin x:=-5;y:=30;z:=0;end;
 with o.points[2] do begin x:=5;y:=30;z:=0;end;
 with o.points[3] do begin x:=-8;y:=25;z:=0;end;
 with o.points[4] do begin x:=-8;y:=25;z:=-10;end;
 with o.points[5] do begin x:=8;y:=25;z:=0;end;
 with o.points[6] do begin x:=8;y:=25;z:=-10;end;}

 {do the projection}
  angx:=0;angy:=10;
  with look do begin x:=0;y:=0;z:=30;end;
  center:=origin;
  zfact:=0;
  for i:=1 to o^.pointsno do
       inc(o^.points[i].z,zfact);
  inc(o^.points[o^.pointsno+1].z,zfact);
  center:=o^.points[o^.pointsno+1];
  pd:=1;

  repeat
   gr^.cls(0,vaddr);
   gettime(h,m,so,so100);
   angx:=(angx+10) mod 360;
   angy:=(angy+1) mod 360;
   move(o^.points,nework^.rotwork,sizeof(o^.points)-(o^.pointsno+1) shl 1);
   nework^.RotateObj(o,angx,70,120);
   nework^.DepthSort(o);
   nework^.project(o);
   for i:=1 to 40 do pd:=pd*i;
   for i:=1 to o^.faceno do
       gr^.DrawPoly(
       nework^.ProWork^[o^.planes[i].p1].x,nework^.ProWork^[o^.planes[i].p1].y,
       nework^.ProWork^[o^.planes[i].p2].x,nework^.ProWork^[o^.planes[i].p2].y,
       nework^.ProWork^[o^.planes[i].p3].x,nework^.ProWork^[o^.planes[i].p3].y,
       nework^.ProWork^[o^.planes[i].p4].x,nework^.ProWork^[o^.planes[i].p4].y,
       o^.planes[i].color,vaddr);
   gettime(h,m,sn,sn100);
   gr^.outint(10,10,(sn-so)*100+sn100-so100,3,255,vaddr);
   inc(test);
   if (sn-so)*100+sn100-so100=0 then inc(zerocount);
   gr^.outint(10,20,v,3,255,vaddr);
   if test=100
      then begin
            test:=0;
            v:=zerocount;
            zerocount:=0;
           end;
   gr^.flip;
   delay(10);
  until port[$60]=1;

end.

