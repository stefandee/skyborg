program point_of_view;
{$M 45678,0,655360}

uses Types3d,graphics,structs,mousedrv,space,crt;

const grx = 30;
      gry = 170;

var
 gr   : PApp_Graph;
 key  : byte;
 o    : pnewobj;
 f    : file of newobj;
 fm   : file of Mission;
 fs   : file of Ship;
 angx,angy,i,j : integer;
 ovi,ovj,ovk,vi,vj,vk,org : point3d;
 hangx,hangy,hangz : integer;
 speed : integer;
 a : integer;

begin

 clrscr;
 gr:=new(PApp_Graph,Init);
 gr^.InitPath;
 nework:=new(PNewApp_3D,init);

 {
 assign(fm,'c:\app\karg\fight\missions\missions.dat');
 reset(fm);read(fm,Crt_Mission);close(fm);
 assign(fs,'c:\app\karg\fight\missions\ships.dat');
 reset(fs);read(fs,Crt_Ship);close(fs);
 LoadObjects;
 }

 MouseInit(Com1Intr,Com1Port);
 gr^.vga256;
 gr^.initpath;
 gr^.initvscreen;
 gr^.loadpal('fight3.pal');
 gr^.setpal;
 gr^.loadfnt('micro2.fnt',6);

 new(o);
 assign(f,'c:\app\karg\fight\shapes\asr.s3d');
 reset(f);
 read(f,o^);
 close(f);

 xleftclip:=15;xrightclip:=305;ytopclip:=15;ybotclip:=185;

 with look do begin x:=0;y:=120;z:=400;end;
 center:=origin;
 with org do begin x:=0;y:=0;z:=0; end;

 with vi do begin x:=16;y:=0;z:=0;end;
 with vj do begin x:=0;y:=16;z:=0;end;
 with vk do begin x:=0;y:=0;z:=16;end;
 with ovi do begin x:=16;y:=0;z:=0;end;
 with ovj do begin x:=0;y:=16;z:=0;end;
 with ovk do begin x:=0;y:=0;z:=16;end;

  repeat
   key:=port[$60];
   case key of
   16 : inc(look.z,4);
   44 : dec(look.z,4);
   72 : begin
         center:=origin;
         inc(hangx,3);
         hangx:=hangx mod 360;
         vi:=ovi;vj:=ovj;vk:=ovk;
         nework^.rotatepoint(vi,hangx,hangy,hangz);
         nework^.rotatepoint(vk,hangx,hangy,hangz);
         nework^.rotatepoint(vj,hangx,hangy,hangz);
        end;
   80 : begin
         center:=origin;
         vi:=ovi;vj:=ovj;vk:=ovk;
         dec(hangx,3);
         if hangx<0 then hangx:=360-hangx;
         nework^.rotatepoint(vi,hangx,hangy,hangz);
         nework^.rotatepoint(vk,hangx,hangy,hangz);
         nework^.rotatepoint(vj,hangx,hangy,hangz);
        end;
   75 : begin
         center:=origin;
         inc(hangz,3);
         inc(hangy,3);
         hangy:=hangy mod 360;
         hangz:=hangz mod 360;
         vi:=ovi;vj:=ovj;vk:=ovk;
         nework^.rotatepoint(vi,hangx,hangy,hangz);
         nework^.rotatepoint(vj,hangx,hangy,hangz);
         nework^.rotatepoint(vk,hangx,hangy,hangz);
        end;
   77 : begin
         center:=origin;
         vi:=ovi;vj:=ovj;vk:=ovk;
         dec(hangy,3);
         if hangy<0 then hangy:=360-hangy;
         dec(hangz,3);
         if hangz<0 then hangz:=360-hangz;
         nework^.rotatepoint(vi,hangx,hangy,hangz);
         nework^.rotatepoint(vj,hangx,hangy,hangz);
         nework^.rotatepoint(vk,hangx,hangy,hangz);
        end;
   78,13 : if speed<10 then inc(speed);
   74,12 : if speed>-10 then dec(speed);
   end;
   gr^.freebuf;
   gr^.cls(0,vaddr);

   {from mouse...}
   center:=origin;
   vi:=ovi;vj:=ovj;vk:=ovk;
   hangz:=hangz+deltax;
   hangy:=hangy+deltax;
   hangx:=hangx+deltay;
   if hangx<0 then hangx:=360-hangx;
   if hangy<0 then hangy:=360-hangy;
   if hangz<0 then hangz:=360-hangz;
   nework^.rotatepoint(vi,hangx,hangy,hangz);
   nework^.rotatepoint(vj,hangx,hangy,hangz);
   nework^.rotatepoint(vk,hangx,hangy,hangz);
   deltax:=0;deltay:=0;

   look.x:=look.x-(speed*vk.x) div 16;
   look.y:=look.y-(speed*vk.y) div 16;
   look.z:=look.z-(speed*vk.z) div 16;

   angx:=(angx+5) mod 360;

   move(o^.points,nework^.rotwork,sizeof(o^.points){-(o^.pointsno+1) shl 1});
   nework^.RotateObj(o,angx,angy,angx);
   nework^.DepthSort(o,look,org);

   nework^.Inverter(vi,vj,vk);
   nework^.ProLook(o,look,org);

   a:=nework^.AngleVPV(look,vk,org);

   if (a>-55) and (a<55) then
   for i:=1 to o^.faceno do
       if o^.planes[i].eyedist>30 then
       gr^.DrawPoly(
       nework^.ProWork^[o^.planes[i].p1].x,nework^.ProWork^[o^.planes[i].p1].y,
       nework^.ProWork^[o^.planes[i].p2].x,nework^.ProWork^[o^.planes[i].p2].y,
       nework^.ProWork^[o^.planes[i].p3].x,nework^.ProWork^[o^.planes[i].p3].y,
       nework^.ProWork^[o^.planes[i].p4].x,nework^.ProWork^[o^.planes[i].p4].y,
       o^.planes[i].color,vaddr)
       else begin
             gr^.outtext(0,100,'Collission!',3,255,vaddr);
             gr^.outint(0,110,i,3,255,vaddr);
            end;


   gr^.outint(0,10,look.z,3,255,vaddr);
   gr^.outint(0,20,look.x,3,255,vaddr);
   gr^.outint(0,30,look.y,3,255,vaddr);
   gr^.outint(40,10,org.z,3,255,vaddr);
   gr^.outint(40,20,org.x,3,255,vaddr);
   gr^.outint(40,30,org.y,3,255,vaddr);

   gr^.line(grx,gry,grx+vk.x,gry+vk.y,189,vaddr);
   gr^.line(grx,gry,grx+vi.x,gry+vi.y,113,vaddr);
   gr^.line(grx,gry,grx+vj.x,gry+vj.y,125,vaddr);
   gr^.outtext(grx+vk.x,gry+vk.y,'Z',6,255,vaddr);
   gr^.outtext(grx+vi.x,gry+vi.y,'X',6,255,vaddr);
   gr^.outtext(grx+vj.x,gry+vj.y,'Y',6,255,vaddr);

   gr^.line(grx+50,gry,grx+vk.z+50,gry+vk.y,189,vaddr);
   gr^.line(grx+50,gry,grx+vi.z+50,gry+vi.y,113,vaddr);
   gr^.line(grx+50,gry,grx+vj.z+50,gry+vj.y,125,vaddr);
   gr^.outtext(grx+vk.z+50,gry+vk.y,'Z',6,255,vaddr);
   gr^.outtext(grx+vi.z+50,gry+vi.y,'X',6,255,vaddr);
   gr^.outtext(grx+vj.z+50,gry+vj.y,'Y',6,255,vaddr);

   gr^.line(grx+100,gry,grx+vk.z+100,gry+vk.x,189,vaddr);
   gr^.line(grx+100,gry,grx+vi.z+100,gry+vi.x,113,vaddr);
   gr^.line(grx+100,gry,grx+vj.z+100,gry+vj.x,125,vaddr);
   gr^.outtext(grx+vk.z+100,gry+vk.x,'Z',6,255,vaddr);
   gr^.outtext(grx+vi.z+100,gry+vi.x,'X',6,255,vaddr);
   gr^.outtext(grx+vj.z+100,gry+vj.x,'Y',6,255,vaddr);

   gr^.outint(80,10,deltax,3,255,vaddr);
   gr^.outint(80,20,deltay,3,255,vaddr);
   gr^.outint(120,10,speed,3,255,vaddr);
   gr^.rectangle(xleftclip,ytopclip,xrightclip,ybotclip,255,vaddr);
   gr^.flip;
  until key=1;
  MouseDone;
end.
