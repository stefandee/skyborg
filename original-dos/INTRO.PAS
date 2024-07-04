UNIT
    INTRO;

INTERFACE

USES
    GRAPHICS,SOUNDDRV,STRUCTS,DOS,TYPES3D;
TYPE
    PApp_WosIntro = ^App_WosIntro;
    App_WosIntro = object(App_Graph)
              constructor Init;
              procedure Run;virtual;
              destructor Done;
              end;
    PApp_Roll = ^App_Roll;
    App_Roll = object(App_Graph)
             public
              constructor Init;
              procedure Run;virtual;
              destructor Done;
             private
              lung          : array[0..194] of word;
              posit         : longint;
              fintro        : file;
              pcx           : pointer;
              pcxseg,pcxofs : word;
              procedure ChunkRead(pos,len : longint);
             end;

IMPLEMENTATION

constructor App_WosIntro.Init;
begin
 inherited Init;
 FreeBuf;
 Cls(0,Vaddr);Cls(0,SegA000);
 LoadPal('wos.pal');
 SetPal;
 Loadspr('wos.spr',1);
 if Base<>0 then Snd^.LoadSound('intro.vox',1);
end;

procedure App_WosIntro.Run;
 var
    counter : word;
begin
 if Base<>0 then Snd^.PlaySound(1);
 PutSpr(1,0,0,normalput,vaddr);
 Flip;
 counter := 0;
 repeat
  FreeBuf;
  inc(counter);
 until (port[$60]<128) or (counter>25000);
 FadeOut(2);
end;

destructor App_WosIntro.Done;
begin
 DoneSpr(1);
 Snd^.PlayStop;
 if Base<>0 then Snd^.FreeSound(1);
 Cls(0,SegA000);Cls(0,Vaddr);
 FreeBuf;
end;

constructor App_Roll.Init;
var
   i : integer;
begin
 inherited Init;
 FreeBuf;
 Cls(0,Vaddr);Cls(0,SegA000);
 for i:=0 to 255 do GetRGB(i,pal[i,1],pal[i,2],pal[i,3]);
 LoadPal('menupal2.pal');SetPal;
 LoadSpr('skyborg.spr',1);
 LoadSpr('point.spr',2);
 LoadFnt('dotty.fnt',2);
 {load intro data}
 assign(fintro,intropath+'intro.anm');
 reset(fintro,1);
 seek(fintro,filesize(fintro)-sizeof(lung));
 blockread(fintro,lung,sizeof(lung));
 getmem(pcx,32000);
 pcxseg:=seg(pcx^);pcxofs:=ofs(pcx^);posit:=0;

end;

procedure App_Roll.Run;
CONST
     Msg1 : string = '     ....A W.O.S PRODUCTION 1995/1996   GRAPHICS  : STELI     3D SHAPES : TRAIAN     ';
     Msg2 : string = 'PROGRAMMING & DESIGN : KARG     PRESS ANY KEY TO JOIN THE SKYBORG FORCE...';
TYPE
     Scroll = array[1..7,1..50] of byte;
     PScroll = ^Scroll;
VAR
   count,i,j   : integer;
   msgcount    : integer;
   ip,jp,kp    : point3d;
   wip,wjp,wkp : point3d;
   cut         : byte;
   proj        : point2d;
   s           : PScroll;
   x,y,z       : integer;
   x3d,y3d,z3d : integer;
   fpr         : real;
   ang         : integer;
   msg         : string;
   llen        : integer;

BEGIN
 count:=0;msgcount:=1;cut:=fonts[2].y;
 with ip do begin x:=128;y:=0;z:=0;end;
 with jp do begin x:=0;y:=128;z:=0;end;
 with kp do begin x:=0;y:=0;z:=128;end;
 center:=origin;
 Nework^.rotatepoint(ip,0,180,0);
 Nework^.rotatepoint(jp,0,180,0);
 Nework^.rotatepoint(kp,0,180,0);
 new(s);
 for i:=1 to 50 do for j:=1 to 7 do s^[j,i]:=0;
 msg:=msg1+msg2;
 llen:=fonts[2].x*fonts[2].y;

 repeat
  {peisage rolling...}
  ChunkRead(posit,lung[count]);
  posit:=posit+lung[count];
  inc(count);
  if count>194 then begin
                     count:=0;
                     posit:=0;
                    end;
  {3D scroller...}
  wip:=ip;wjp:=jp;wkp:=kp;
  ang:=(ang+5) mod 360;
  center:=origin;
  Nework^.rotatepoint(wip,ang,ang,0);
  Nework^.rotatepoint(wjp,ang,ang,0);
  Nework^.rotatepoint(wkp,ang,ang,0);
  dec(cut);

  if cut<1 then begin
                 inc(msgcount);
                 if msgcount>length(msg) then msgcount:=1;
                 cut:=fonts[2].y;
                end;

  for i:=1 to 7 do
      begin
       for j:=50 downto 2 do
          begin
           s^[i,j]:=s^[i,j-1];
           x:=(j-25)*4;y:=(i-3)*6;z:=0;
           x3d:=(x*wip.x+y*wjp.x) div 128;
           y3d:=(x*wip.y+y*wjp.y) div 128;
           z3d:=(x*wip.z+y*wjp.z) div 128;
           if z0+z3d<>0 then fpr:=z0/(z0+z3d)
                        else fpr:=z0;
           proj.x:=round(x3d*fpr+orgx);proj.y:=round(y3d*fpr+orgy);
           with proj do
           if (x>xleftclip) and (x<xrightclip) and (y>ytopclip) and (y<ybotclip) then
           if s^[i,j]<>0 then putspr(2,x,y,gameput,vaddr);
           end;
       s^[i,1]:=mem[seg(fonts[2].p^):(ofs(fonts[2].p^)+(byte(upcase(msg[msgcount]))-32)*llen+(i-1)*fonts[2].x+7-cut)];
      end;
  PutSpr(1,160-spr[1].xl div 2,10,GamePut,vaddr);
  Flip;
 until port[$60]<128;
 dispose(s);
END;

procedure App_Roll.ChunkRead;
VAR
    lv            : word;
    dummy1,dummy2 : word;
begin

 seek(fintro,128+pos);
 len:=len-128-769;
 blockread(fintro,pcx^,word(len));
 lv:=vaddr;
 dummy1:=pcxseg;
 dummy2:=pcxofs;

 {begin decoding}
 asm
    push si
    push di
    push bp
    push ds
    push es

    mov dx,dummy1
    mov ds,dx
    mov si,dummy2
    mov dx,lv
    mov es,dx
    mov di,0
    mov bh,$3f
    mov ch,0
    mov dh,$c0
    mov dl,$3f

 @decode:
          mov ax,di
          cmp ax,63999
          jae @finish

          lodsw;

          mov bl,al
          and bl,dh
          cmp bl,dh
          jne @notcode

          and al,dl
          mov cl,al
          shr cx,1
          mov al,ah
          rep stosw
          jnc @decode
          stosb
          jmp @decode
 @notcode:
          stosb
          dec si
          jmp @decode
 @finish:
    pop es
    pop ds
    pop bp
    pop di
    pop si

 end;
end;

destructor App_Roll.Done;
var
   i,j : integer;
begin
 FadeOut(2);
 Cls(0,SegA000);Cls(0,Vaddr);
 close(fintro);
 freemem(pcx,32000);
 DoneSpr(1);DoneSpr(2);DoneFnt(2);
 FreeBuf;
 for i:=0 to 255 do for j:=1 to 3 do workpal[i,j]:=pal[i,j];
 SetPal;
end;

BEGIN
END.