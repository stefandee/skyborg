uses
    graphics,types3d,crt,dos;

const n = 1;
var
   o : obj;
   angx,angy : integer;
   i,j : integer;
   fpr : real;
   f : file of obj;
   gr : Papp_graph;
   pd: longint;
   zfact : integer;
   h,m,so,sn,so100,sn100 : word;
   test : integer;
   zerocount,v : longint;

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

  {add comment here...}
  with o.form[1] do
     begin
     p1.x:=12;p1.y:=0;p1.z:=12;
     p2.x:=12;p2.y:=-8;p2.z:=12;
     p3.x:=-12;p3.y:=0;p3.z:=12;
     p4.x:=-12;p4.y:=-8;p4.z:=12;
     color:=144;
    end;

  with o.form[2] do
     begin
     p1.x:=12;p1.y:=0;p1.z:=12;
     p2.x:=12;p2.y:=-8;p2.z:=12;
     p3.x:=12;p3.y:=-8;p3.z:=8;
     p4.x:=12;p4.y:=0;p4.z:=8;
     color:=142;
    end;

  with o.form[3] do
     begin
     p1.x:=12;p1.y:=0;p1.z:=8;
     p2.x:=12;p2.y:=-8;p2.z:=8;
     p3.x:=8;p3.y:=-8;p3.z:=8;
     p4.x:=8;p4.y:=0;p4.z:=8;
     color:=142;
    end;

  with o.form[4] do
     begin
     p1.x:=8;p1.y:=0;p1.z:=12;
     p2.x:=8;p2.y:=0;p2.z:=8;
     p3.x:=8;p3.y:=-8;p3.z:=8;
     p4.x:=8;p4.y:=-8;p4.z:=12;
     color:=142;
     end;

  with o.form[5] do
     begin
     p1.x:=-12;p1.y:=0;p1.z:=12;
     p2.x:=-12;p2.y:=0;p2.z:=8;
     p3.x:=-12;p3.y:=-8;p3.z:=8;
     p4.x:=-12;p4.y:=-8;p4.z:=12;
     color:=142;
    end;

  with o.form[6] do
     begin
     p1.x:=-8;p1.y:=0;p1.z:=8;
     p2.x:=-12;p2.y:=0;p2.z:=8;
     p3.x:=-12;p3.y:=-8;p3.z:=8;
     p4.x:=-8;p4.y:=-8;p4.z:=8;
     color:=142;
    end;

  with o.form[7] do
     begin
     p1.x:=-8;p1.y:=0;p1.z:=12;
     p2.x:=-8;p2.y:=0;p2.z:=8;
     p3.x:=-8;p3.y:=-8;p3.z:=8;
     p4.x:=-8;p4.y:=-8;p4.z:=12;
     color:=142;
    end;

  with o.form[8] do
     begin
     p1.x:=4;p1.y:=4;p1.z:=12;
     p2.x:=-4;p2.y:=4;p2.z:=12;
     p3.x:=-4;p3.y:=0;p3.z:=12;
     p4.x:=4;p4.y:=0;p4.z:=12;
     color:=147;
    end;

  with o.form[9] do
     begin
     p1.x:=8;p1.y:=0;p1.z:=6;
     p2.x:=8;p2.y:=4;p2.z:=6;
     p3.x:=4;p3.y:=4;p3.z:=12;
     p4.x:=4;p4.y:=0;p4.z:=12;
     color:=146;
    end;

  with o.form[10] do
     begin
     p1.x:=-8;p1.y:=0;p1.z:=6;
     p2.x:=-8;p2.y:=4;p2.z:=6;
     p3.x:=-4;p3.y:=4;p3.z:=12;
     p4.x:=-4;p4.y:=0;p4.z:=12;
     color:=146;
    end;

  with o.form[11] do
     begin
     p1.x:=4;p1.y:=4;p1.z:=12;
     p2.x:=-4;p2.y:=4;p2.z:=12;
     p3.x:=-4;p3.y:=14;p3.z:=6;
     p4.x:=4;p4.y:=14;p4.z:=6;
     color:=147;{?}
    end;

  with o.form[12] do
     begin
     p1.x:=8;p1.y:=4;p1.z:=6;
     p2.x:=4;p2.y:=4;p2.z:=12;
     p3.x:=4;p3.y:=14;p3.z:=6;
     p4.x:=4;p4.y:=14;p4.z:=6;
     color:=146;
    end;

  with o.form[13] do
     begin
     p1.x:=-4;p1.y:=4;p1.z:=12;
     p2.x:=-8;p2.y:=4;p2.z:=6;
     p3.x:=-4;p3.y:=14;p3.z:=6;
     p4.x:=-4;p4.y:=14;p4.z:=6;
     color:=146;
    end;

  with o.form[14] do
     begin
     p1.x:=4;p1.y:=14;p1.z:=6;
     p2.x:=-4;p2.y:=14;p2.z:=6;
     p3.x:=-4;p3.y:=14;p3.z:=2;
     p4.x:=4;p4.y:=14;p4.z:=2;
     color:=142;
    end;

  with o.form[15] do
     begin
     p1.x:=8;p1.y:=4;p1.z:=6;
     p2.x:=8;p2.y:=4;p2.z:=2;
     p3.x:=4;p3.y:=14;p3.z:=2;
     p4.x:=4;p4.y:=14;p4.z:=6;
     color:=142;
    end;

  with o.form[16] do
     begin
     p1.x:=-8;p1.y:=4;p1.z:=6;
     p2.x:=-8;p2.y:=4;p2.z:=2;
     p3.x:=-4;p3.y:=14;p3.z:=2;
     p4.x:=-4;p4.y:=14;p4.z:=6;
     color:=142;
    end;

  with o.form[17] do
     begin
     p1.x:=8;p1.y:=4;p1.z:=6;
     p2.x:=8;p2.y:=0;p2.z:=6;
     p3.x:=8;p3.y:=4;p3.z:=2;
     p4.x:=8;p4.y:=0;p4.z:=2;
     color:=143;
    end;

  with o.form[18] do
     begin
     p1.x:=-8;p1.y:=4;p1.z:=6;
     p2.x:=-8;p2.y:=4;p2.z:=2;
     p3.x:=-8;p3.y:=0;p3.z:=6;
     p4.x:=-8;p4.y:=0;p4.z:=2;
     color:=143;
    end;

  with o.form[19] do
     begin
     p1.x:=4;p1.y:=14;p1.z:=2;
     p2.x:=-4;p2.y:=14;p2.z:=2;
     p3.x:=4;p3.y:=4;p3.z:=0;
     p4.x:=-4;p4.y:=4;p4.z:=0;
     color:=143;
    end;

  with o.form[20] do
     begin
     p1.x:=8;p1.y:=4;p1.z:=2;
     p2.x:=4;p2.y:=4;p2.z:=0;
     p3.x:=4;p3.y:=14;p3.z:=2;
     p4.x:=4;p4.y:=14;p4.z:=2;
     color:=143;
    end;

  with o.form[21] do
     begin
     p1.x:=-8;p1.y:=4;p1.z:=2;
     p2.x:=-4;p2.y:=4;p2.z:=0;
     p3.x:=-4;p3.y:=14;p3.z:=2;
     p4.x:=-4;p4.y:=14;p4.z:=2;
     color:=143;
    end;

  with o.form[22] do
     begin
     p1.x:=8;p1.y:=4;p1.z:=2;
     p2.x:=8;p2.y:=0;p2.z:=2;
     p3.x:=4;p3.y:=4;p3.z:=0;
     p4.x:=4;p4.y:=0;p4.z:=0;
     color:=144;
    end;

  with o.form[23] do
     begin
     p1.x:=-8;p1.y:=4;p1.z:=2;
     p2.x:=-8;p2.y:=0;p2.z:=2;
     p3.x:=-4;p3.y:=4;p3.z:=0;
     p4.x:=-4;p4.y:=0;p4.z:=0;
     color:=144;
    end;

  with o.form[24] do
     begin
     p1.x:=4;p1.y:=4;p1.z:=0;
     p2.x:=-4;p2.y:=4;p2.z:=0;
     p3.x:=4;p3.y:=0;p3.z:=0;
     p4.x:=-4;p4.y:=0;p4.z:=0;
     color:=145;
    end;

  with o.form[25] do
     begin
     p1.x:=8;p1.y:=0;p1.z:=6;
     p2.x:=4;p2.y:=0;p2.z:=12;
     p3.x:=-4;p3.y:=0;p3.z:=12;
     p4.x:=-8;p4.y:=0;p4.z:=8;
     color:=145;
    end;

  with o.form[26] do
     begin
     p1.x:=4;p1.y:=0;p1.z:=6;
     p2.x:=-4;p2.y:=0;p2.z:=6;
     p3.x:=-4;p3.y:=0;p3.z:=2;
     p4.x:=4;p4.y:=0;p4.z:=2;
     color:=145;
    end;

  with o.form[27] do
     begin
     p1.x:=8;p1.y:=0;p1.z:=2;
     p2.x:=-8;p2.y:=0;p2.z:=2;
     p3.x:=-4;p3.y:=0;p3.z:=0;
     p4.x:=4;p4.y:=0;p4.z:=0;
     color:=145;
    end;

  with o.form[28] do
     begin
     p1.x:=2;p1.y:=0;p1.z:=6;
     p2.x:=-2;p2.y:=0;p2.z:=6;
     p3.x:=-2;p3.y:=-4;p3.z:=6;
     p4.x:=2;p4.y:=-4;p4.z:=6;
     color:=146;
    end;

  with o.form[29] do
     begin
     p1.x:=2;p1.y:=0;p1.z:=6;
     p2.x:=2;p2.y:=-4;p2.z:=6;
     p3.x:=2;p3.y:=-4;p3.z:=2;
     p4.x:=2;p4.y:=0;p4.z:=2;
     color:=146;
    end;

  with o.form[30] do
     begin
     p1.x:=-2;p1.y:=0;p1.z:=6;
     p2.x:=-2;p2.y:=-4;p2.z:=6;
     p3.x:=-2;p3.y:=-4;p3.z:=2;
     p4.x:=-2;p4.y:=0;p4.z:=2;
     color:=146;
    end;

  with o.form[31] do
     begin
     p1.x:=2;p1.y:=0;p1.z:=2;
     p2.x:=2;p2.y:=-4;p2.z:=2;
     p3.x:=-2;p3.y:=-4;p3.z:=2;
     p4.x:=-2;p4.y:=0;p4.z:=2;
     color:=146;
    end;

  with o.form[32] do
     begin
     p1.x:=2;p1.y:=22;p1.z:=0;
     p2.x:=2;p2.y:=0;p2.z:=0;
     p3.x:=2;p3.y:=0;p3.z:=-1;
     p4.x:=2;p4.y:=22;p4.z:=-1;
     color:=141;
    end;

  with o.form[33] do
     begin
     p1.x:=-2;p1.y:=22;p1.z:=0;
     p2.x:=-2;p2.y:=0;p2.z:=0;
     p3.x:=-2;p3.y:=0;p3.z:=-1;
     p4.x:=-2;p4.y:=22;p4.z:=-1;
     color:=141;
    end;

  with o.form[34] do
     begin
     p1.x:=5;p1.y:=-2;p1.z:=4;
     p2.x:=5;p2.y:=-4;p2.z:=4;
     p3.x:=5;p3.y:=-4;p3.z:=-8;
     p4.x:=5;p4.y:=-2;p4.z:=-8;
     color:=144;
    end;

  with o.form[35] do
     begin
     p1.x:=-5;p1.y:=-2;p1.z:=4;
     p2.x:=-5;p2.y:=-4;p2.z:=4;
     p3.x:=-5;p3.y:=-4;p3.z:=-8;
     p4.x:=-5;p4.y:=-2;p4.z:=-8;
     color:=144;
    end;

  with o.form[36] do
     begin
     p1.x:=4;p1.y:=-2;p1.z:=4;
     p2.x:=4;p2.y:=-4;p2.z:=4;
     p3.x:=4;p3.y:=-4;p3.z:=-8;
     p4.x:=4;p4.y:=-2;p4.z:=-8;
     color:=144;
    end;

  with o.form[37] do
     begin
     p1.x:=-4;p1.y:=-2;p1.z:=4;
     p2.x:=-4;p2.y:=-4;p2.z:=4;
     p3.x:=-4;p3.y:=-4;p3.z:=-8;
     p4.x:=-4;p4.y:=-2;p4.z:=-8;
     color:=144;
    end;

  with o.form[38] do
     begin
     p1.x:=6;p1.y:=-2;p1.z:=-6;
     p2.x:=6;p2.y:=-5;p2.z:=-8;
     p3.x:=6;p3.y:=4;p3.z:=-18;
     p4.x:=6;p4.y:=4;p4.z:=-18;
     color:=144;
    end;

  with o.form[39] do
     begin
     p1.x:=-6;p1.y:=-2;p1.z:=-6;
     p2.x:=-6;p2.y:=-5;p2.z:=-8;
     p3.x:=-6;p3.y:=4;p3.z:=-18;
     p4.x:=-6;p4.y:=4;p4.z:=-18;
     color:=144;
    end;

  with o.form[40] do
     begin
     p1.x:=3;p1.y:=-2;p1.z:=-6;
     p2.x:=3;p2.y:=-5;p2.z:=-8;
     p3.x:=3;p3.y:=4;p3.z:=-18;
     p4.x:=3;p4.y:=4;p4.z:=-18;
     color:=144;
    end;

  with o.form[41] do
     begin
     p1.x:=-3;p1.y:=-2;p1.z:=-6;
     p2.x:=-3;p2.y:=-5;p2.z:=-8;
     p3.x:=-3;p3.y:=4;p3.z:=-18;
     p4.x:=-3;p4.y:=4;p4.z:=-18;
     color:=144;
    end;

  with o.form[42] do
     begin
     p1.x:=7;p1.y:=6;p1.z:=-18;
     p2.x:=3;p2.y:=6;p2.z:=-18;
     p3.x:=3;p3.y:=2;p3.z:=-18;
     p4.x:=7;p4.y:=2;p4.z:=-18;
     color:=146;
    end;

  with o.form[43] do
     begin
     p1.x:=-7;p1.y:=6;p1.z:=-18;
     p2.x:=-3;p2.y:=6;p2.z:=-18;
     p3.x:=-3;p3.y:=2;p3.z:=-18;
     p4.x:=-7;p4.y:=2;p4.z:=-18;
     color:=146;
    end;

  with o.form[44] do
     begin
     p1.x:=6;p1.y:=6;p1.z:=-18;
     p2.x:=4;p2.y:=6;p2.z:=-18;
     p3.x:=4;p3.y:=12;p3.z:=-22;
     p4.x:=6;p4.y:=12;p4.z:=-22;
     color:=146;
    end;

  with o.form[45] do
     begin
     p1.x:=-6;p1.y:=6;p1.z:=-18;
     p2.x:=-4;p2.y:=6;p2.z:=-18;
     p3.x:=-4;p3.y:=12;p3.z:=-22;
     p4.x:=-6;p4.y:=12;p4.z:=-22;
     color:=146;
    end;

  with o.form[46] do
     begin
     p1.x:=7;p1.y:=5;p1.z:=-18;
     p2.x:=7;p2.y:=3;p2.z:=-18;
     p3.x:=10;p3.y:=3;p3.z:=-22;
     p4.x:=10;p4.y:=5;p4.z:=-22;
     color:=146;
    end;

  with o.form[47] do
     begin
     p1.x:=-7;p1.y:=5;p1.z:=-18;
     p2.x:=-7;p2.y:=3;p2.z:=-18;
     p3.x:=-10;p3.y:=3;p3.z:=-22;
     p4.x:=-10;p4.y:=5;p4.z:=-22;
     color:=146;
    end;

  with o.form[48] do
     begin
     p1.x:=6;p1.y:=2;p1.z:=-18;
     p2.x:=4;p2.y:=2;p2.z:=-18;
     p3.x:=4;p3.y:=-2;p3.z:=-22;
     p4.x:=6;p4.y:=-2;p4.z:=-22;
     color:=146;
    end;

  with o.form[49] do
     begin
     p1.x:=-6;p1.y:=2;p1.z:=-18;
     p2.x:=-4;p2.y:=2;p2.z:=-18;
     p3.x:=-4;p3.y:=-2;p3.z:=-22;
     p4.x:=-6;p4.y:=-2;p4.z:=-22;
     color:=146;
    end;

  o.face:=49;o.core:=origin;

  for i:=1 to o.face do
      begin
       o.form[i].p1.z := -o.form[i].p1.z;
       o.form[i].p2.z := -o.form[i].p2.z;
       o.form[i].p3.z := -o.form[i].p3.z;
       o.form[i].p4.z := -o.form[i].p4.z;
      end;

  assign(f,'c:\app\karg\fight\shapes\asr.shp');
  rewrite(f);
  write(f,o);
  close(f);

  angx:=0;angy:=10;
  with look do begin x:=0;y:=0;z:=30;end;
  center:=origin;
  zfact:=5;
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
   work^.RotateObj(angx,0,angx);
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

