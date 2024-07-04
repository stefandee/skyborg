program tree_generator;
uses
    graphics,types3d,crt,dos;

const n = 1;
var
   o : obj;
   angx,angy,angz : integer;
   x,y,z : integer;
   sgnx,sgny,sgnz : integer;
   i,j : integer;
   fpr : real;
   f : file of obj;
   gr : Papp_graph;
   pd: longint;
   zfact : integer;
   h,m,so,sn,so100,sn100 : word;
   test : integer;
   zerocount,v : longint;
   p,p1 : plan3d;

begin
 gr:=New(Papp_graph,Init);
 work:=new(papp_3d,init);
 gr^.vga256;
 gr^.initvscreen;
 gr^.initpath;
 gr^.loadpal('menupal4.pal');
 gr^.setpal;

{
 assign(f,'c:\app\karg\fight\shapes\mig25.shp');
 reset(f);
 read(f,o);
 close(f);
}

  with p do
       begin
        p1.x:= 3;p1.y:= 0;p1.z:=0;
        p2.x:= 0;p2.y:= 3;p2.z:=0;
        p3.x:= -3;p3.y:= 0;p3.z:=0;
        p4.x:= 0;p4.y:= -3;p4.z:=0;
        color := 0;
       end;

  {add comment here...}
  with o.form[1] do
     begin
     p1.x:=1;p1.y:=-10;p1.z:=2;
     p2.x:=1;p2.y:=-10;p2.z:=-2;
     p3.x:=1;p3.y:=+10;p3.z:=2;
     p4.x:=1;p4.y:=+10;p4.z:=-2;
     color:=131;
    end;
  with o.form[2] do
     begin
     p1.x:=-1;p1.y:=-10;p1.z:=2;
     p2.x:=-1;p2.y:=-10;p2.z:=-2;
     p3.x:=-1;p3.y:=+10;p3.z:=2;
     p4.x:=-1;p4.y:=+10;p4.z:=-2;
     color:=131;
    end;
  with o.form[3] do
     begin
     p1.x:=1;p1.y:=10;p1.z:=2;
     p2.x:=-1;p2.y:=10;p2.z:=2;
     p3.x:=-1;p3.y:=-10;p3.z:=2;
     p4.x:=1;p4.y:=-10;p4.z:=2;
     color:=131;
    end;
  with o.form[4] do
     begin
     p1.x:=1;p1.y:=10;p1.z:=-2;
     p2.x:=-1;p2.y:=10;p2.z:=-2;
     p3.x:=-1;p3.y:=-10;p3.z:=-2;
     p4.x:=1;p4.y:=-10;p4.z:=-2;
     color:=131;
    end;
  randomize;
  for i:=5 to 14 do
      begin
       p1:=p;
       p.color := random(5)+141;
       angx := random(35)+5;angy := random(35)+5;angz := random(35)+5;
       x := -random(14)-3;
       y := -random(25)-8;
       z := -random(10)+5;
       with p do
            begin
             inc(p1.x,x);inc(p2.x,x);inc(p3.x,x);inc(p4.x,x);
             inc(p1.y,y);inc(p2.y,y);inc(p3.y,y);inc(p4.y,y);
             inc(p1.z,z);inc(p2.z,z);inc(p3.z,z);inc(p4.z,z);
            end;
       work^.RotatePoint(p.p1,angx,angy,angz);
       work^.RotatePoint(p.p2,angx,angy,angz);
       work^.RotatePoint(p.p3,angx,angy,angz);
       work^.RotatePoint(p.p4,angx,angy,angz);
       o.form[i]:=p;
       p:=p1;
      end;
  for i:=15 to 20 do
      begin
      p1:=p;
       p.color := random(5)+141;
       angx := random(35)+5;angy := random(35)+5;angz := random(35)+5;
       x := 3+random(14);
       y := -random(25)-8;
       z := -random(10)+5;
       with p do
            begin
             inc(p1.x,x);inc(p2.x,x);inc(p3.x,x);inc(p4.x,x);
             inc(p1.y,y);inc(p2.y,y);inc(p3.y,y);inc(p4.y,y);
             inc(p1.z,z);inc(p2.z,z);inc(p3.z,z);inc(p4.z,z);
            end;
       work^.RotatePoint(p.p1,angx,angy,angz);
       work^.RotatePoint(p.p2,angx,angy,angz);
       work^.RotatePoint(p.p3,angx,angy,angz);
       work^.RotatePoint(p.p4,angx,angy,angz);
       o.form[i]:=p;
       p:=p1;
      end;
  o.face:=20;o.core:=origin;


  assign(f,'c:\app\karg\fight\shapes\tree04.shp');
  rewrite(f);
  write(f,o);
  close(f);

  angx:=0;angy:=10;
  with look do begin x:=0;y:=0;z:=30;end;
  center:=origin;
  zfact:=+10;
  for i:=1 to o.face do
      begin
       inc(o.form[i].p1.z,zfact);
       inc(o.form[i].p2.z,zfact);
       inc(o.form[i].p3.z,zfact);
       inc(o.form[i].p4.z,zfact);
      end;
  inc(o.core.z,zfact);
  center:=o.core;
  repeat
   gr^.cls(0,vaddr);
   gettime(h,m,so,so100);
   angx:=(angx+10) mod 360;
   if angy<30 then angy:=(angy+1) mod 360
              else angy:=(angy-1) mod 360;
   move(o,work^.RotWork^,sizeof(o));
   work^.RotateObj(0,0,0);
   work^.DepthSort;
   work^.project;
   for i:=1 to work^.RotWork^.face do
       gr^.DrawPoly(
       work^.ProWork^[i].p1.x,work^.ProWork^[i].p1.y,
       work^.ProWork^[i].p2.x,work^.ProWork^[i].p2.y,
       work^.ProWork^[i].p3.x,work^.ProWork^[i].p3.y,
       work^.ProWork^[i].p4.x,work^.ProWork^[i].p4.y,
       work^.RotWork^.form[i].color,vaddr);
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
  until port[$60]=1;
end.


