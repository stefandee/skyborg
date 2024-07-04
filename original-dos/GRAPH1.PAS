unit graph1;
{$G+}

interface

uses Dos,Crt;

Type Vrt     = Array [1..64000] of byte;  { The size of the virtual screen }
     VirtPtr = ^Vrt;
     Tspr    = record
             xl,yl:word;
             pspr:pointer
             end;
     pp      = record
             ofs,seg :word
             end;
     bytes   = array[1..7,1..7] of byte;
     mbytes  = array[1..3,1..3] of byte;


     point   = record
             x,y:integer;
             end;
     triangle= record
             a,b,c : point;
             d     : real;
             col   : byte;
             end;
     paltype = array[0..255,1..3] of byte;

Const VGA=$A000;
      crtc_addr=$3d4;
      NormalPut =  0  ;      {MOV}
      CopyPut   =  1  ;      {MOV}
      XORPut    =  3  ;      {XOR}
      OrPut     =  2  ;      {OR }
      AndPut    =  1  ;      {AND}
      NotPut    =  4  ;      {NOT}
      GamePut   =  5  ;      {Special put : designed by Karg - ex Phane}
      Fond      =  0  ;      {like in cartoons stuff, the put above needs
                              a backgnd color}
      SmallFnt  =  1  ;
      MicroFnt  =  2  ;
      Font8x8   =  3  ;
      Font8x14  =  4  ;
      Font8x8B  =  5  ;


Var workpal,pal  : paltype;
    Virscr       : VirtPtr;                      { Our first Virtual screen }
    Vaddr        : word;                        { The segment of our virtual screen}
    Spr          : array [1..255] of tspr;
    Small        : array[' '..'^'] of bytes;
    Micro        : array[' '..'^'] of mbytes;

procedure Vga256;
procedure DoneVga256;
procedure InitVScreen;
procedure DoneVScreen;

procedure Putpixel(x,y:word;color:byte;where:word);
function  Getpixel(x,y:word;where:word):byte;
procedure Line(x1,y1,x2,y2:integer;color:byte;where:word);
procedure Hlin(x,y,x1,y1:longint;color:byte;where:word);
procedure Rectangle(xi,yi,xf,yf:integer;color:byte;where:word);
procedure Bar(xb,yb,xf,yf:integer;color:byte;where:word);

procedure Setpal;
procedure Loadpal(numef:string);
procedure SetRGB(index,r,g,b:byte);
procedure FadeOut(speed:byte);
procedure WaitRetrace;

procedure Flip;
procedure Cls (Color : Byte; Where:Word);

{sprite procedures...}
procedure Loadspr(nume:string;nr:byte);
procedure Putspr(nr:byte;x1,y1:integer;mode:byte;where:word);
procedure ReplaceSpr(fname:string;nr:byte);
procedure GetImage(nr:byte;x,y,xll,yll : word;where : word);
procedure DoneSpr(nr:byte);

procedure Outtext(x,y:word;s:string;fnt:byte;color : byte;where:word);
procedure Outint(x,y:word;v:longint;fnt:byte;color : byte;where:word);
{procedure Fill(p1,p2,p3,p4 : point2d;color:byte);}
procedure Setvisiblestart(offset : word);


implementation

procedure Vga256;
begin
asm
   mov ax,$0013
   int $10
end
end;

Procedure DoneVga256;  { This procedure returns you to text mode.  }
begin
  asm
     mov        ax,0003h
     int        10h
  end;
end;

procedure InitVScreen;
begin
Getmem(virscr,64000);
Vaddr := seg (virscr^);
end;

procedure DoneVScreen;
begin
FreeMem(virscr,64000);
end;

procedure Putpixel;
begin
Mem [Where:X+Y shl 8+Y shl 6]:=color;
end;

function GetPixel;
begin
GetPixel:=Mem[Where:X+Y shl 8+Y shl 6];
end;

procedure Line;
var i, deltax, deltay, numpixels,
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2 : integer;
    screen : word;
    screeninc1, screeninc2 : integer;

begin

  if x1<0 then x1:=0;
  if x2<0 then x2:=0;
  if y1<0 then y1:=0;
  if y2<0 then y2:=0;
  if x1>319 then x1:=319;
  if x2>319 then x2:=319;
  if y1>199 then y1:=199;
  if y2>199 then y2:=199;


  { Calculate deltax and deltay for initialisation }
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);

  { Initialize all vars based on which is the independent variable }
  if deltax >= deltay then
    begin

      { x is independent variable }
      numpixels := deltax + 1;
      d := (2 * deltay) - deltax;
      dinc1 := deltay Shl 1;
      dinc2 := (deltay - deltax) shl 1;
      xinc1 := 1;
      xinc2 := 1;
      yinc1 := 0;
      yinc2 := 1;
    end
  else
    begin

      { y is independent variable }
      numpixels := deltay + 1;
      d := (2 * deltax) - deltay;
      dinc1 := deltax Shl 1;
      dinc2 := (deltax - deltay) shl 1;
      xinc1 := 0;
      xinc2 := 1;
      yinc1 := 1;
      yinc2 := 1;
    end;

  { Make sure x and y move in the right directions }
  if x1 > x2 then
    begin
      xinc1 := - xinc1;
      xinc2 := - xinc2;
    end;
  if y1 > y2 then
    begin
      yinc1 := - yinc1;
      yinc2 := - yinc2;
    end;

  { Start drawing at <x1, y1> }
  
  screen := word(Y1) shl 8+word(Y1) shl 6 + x1;
  screeninc1 := Yinc1 shl 8+Yinc1 shl 6 + xinc1;
  screeninc2 := Yinc2 shl 8+Yinc2 shl 6 + xinc2;

  { Draw the pixels }
  asm

    { Use as many registers as are available }
    push where
    pop es
    mov di, screen
    mov dx, d
    mov al, color
    mov cx, numpixels
    mov bx, dinc1

    @bres1:

    { Draw the current pixel and compare the decision variable to 0 }
    mov es:[di], al
    cmp dx, 0
    jnl @bres2

    { D < 0 }
    add dx, bx { bx = dinc1 }
    add di, screeninc1
    jmp @bres3

    @bres2:

    { D >= 0 }
    add dx, dinc2
    add di, screeninc2

    @bres3:

    loop @bres1
  end;

end;

procedure Hlin;
var adr:word;
    xb,len:word;

begin
if x<0 then x:=0;
if x1<0 then x1:=0;
if x1>320 then x1:=320;
if x>320 then x:=320;
if y>199 then exit;
if y1>199 then exit;
if y<0 then exit;
if y1<0 then exit;

if x>x1 then begin
             xb:=x1;
             len:=abs(x-x1);
             end
        else begin
             xb:=x;
             len:=abs(x1-x);
             end;
adr:=word(xb+y shl 8+y shl 6);
asm
mov dx,es
mov ax,where
mov es,ax
mov di,adr
mov cx,len
shr cx,1
mov ah,color
mov al,color
rep stosw
jnc @finish
stosb
@finish:mov es,dx
end;
end;

procedure Rectangle;
begin
Hlin(xi,yi,xf,yi,color,where);
Hlin(xi,yf,xf,yf,color,where);
Line(xi,yi,xi,yf,color,where);
Line(xf,yi,xf,yf,color,where);
end;

procedure Bar(xb,yb,xf,yf:integer;color:byte;where:word);
var i,m:integer;
begin
if xb>xf then begin m:=xb; xb:=xf; xf:=m; end;
if yb>yf then begin m:=yb; yb:=yf; yf:=m; end;
for i:=yb to yf do hlin(xb,i,xf,i,color,where);
end;

procedure LoadPal;

var
    result:word;
    fs:file;
begin

   assign(fs,numef);
   reset(fs,1);
   blockread(fs,workpal,768,result);
   close(fs);
   move(workpal,pal,768);
end;

procedure Setpal;
VAR
   r:registers;
begin
     r.ax:=$1012;
     r.es:=seg(workpal);
     r.dx:=ofs(workpal);
     r.bx:=0;
     r.cx:=256;
     intr($10,r);
     move(workpal,pal,768);
end;

procedure SetRGB;
begin

port[$3c8]:=index;
port[$3c9]:=r;
port[$3c9]:=g;
port[$3c9]:=b;

end;

procedure WaitRetrace;assembler;
label l1,l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;



Procedure Cls;
BEGIN
  asm
  mov ax,where
  mov es,ax
  mov al,color
  mov ah,al
  mov si,0
  mov di,0
  mov cx,32000
  rep stosw
  end;
{Fillchar (Mem [where:0],64000,color);}
END;

Procedure Flip;
BEGIN
  asm
  push es
  push ds
  mov ax,vaddr
  mov ds,ax
  mov si,0
  mov ax,vga
  mov es,ax
  mov di,0
  mov cx,32000
  cld
  rep movsw
  pop ds
  pop es
  end;
{  Move (Virscr^,mem [VGA:0],64000);}
END;

Procedure Ofsto0(var p:pointer);
var
   ss,oo,oo1:word;
begin
ss:=pp(p).seg;
oo:=pp(p).ofs;
oo1:=oo;
oo:=oo mod 16;
ss:=ss+oo1 div 16;
p:=ptr(ss,oo);
end;



Procedure Putimage(x,y:integer;xl,yl:word;p:pointer;md:byte;where:word);
var
   s,o,adr,dist : word;
   xli          : word;
begin
s:=seg(p^);
o:=ofs(p^);
if x>=0 then begin
            adr:=word(y shl 8+y shl 6+x);
            dist:=xl;
            end
       else begin
            adr:=y shl 8+y shl 6;
            o:=o+abs(x);
            dist:=xl+x;
            end;

xli:=xl;
if x+xl>=320 then dist:=320-x;
case md of
gameput :
   asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,where
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o;
   mov di,adr
   mov cx,yl
   cld
   @another:
   push di;
   push cx;
   mov cx,dist;
   mov bx,0;
   @again:
   mov al,ds:[si+bx];
   cmp al,fond;
   je @pas;
   mov es:[di+bx],al;
   @pas:inc bx;
   loop @again;
   pop cx;
   pop di;
   add di,320;
   add si,xli;
   loop @another;
   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax

   end;

normalput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es

   mov ax,where
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld

@5:
   push di
   push cx
   mov cx,dist
   shr cx,1
   rep movsw
   jnc @done
   movsb
@done:pop cx
   pop di
   add di,320
   loop @5

   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax
end;
copyput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,where
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld
@7:
   push di
   push cx
   mov cx,xl
@6:
   lodsb
   cmp al,0
   je @8
   mov es:[di],al
@8:
   inc di
   loop @6
   pop cx
   pop di

   add di,320
   loop @7
   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax


end;


end;{case}
end;{proc}



Procedure Loadspr(nume:string;nr:byte{;pos:longint});
var
    xxl,yyl    : word;
    fs         : file;

begin
assign(fs,nume);
reset(fs,1);
with spr[nr] do
     begin
         blockread(fs,xxl,2);
         blockread(fs,yyl,2);
         getmem(pspr,xxl*yyl);
         blockread(fs,pspr^,xxl*yyl);
         xl:=xxl;
         yl:=yyl;
     end;
close(fs);
end;

procedure ReplaceSpr;
var
    xxl,yyl    : word;
    fs         : file;

begin
assign(fs,fname);
reset(fs,1);
with spr[nr] do
     begin
         blockread(fs,xxl,2);
         blockread(fs,yyl,2);
         blockread(fs,pspr^,xxl*yyl);
         xl:=xxl;
         yl:=yyl;
     end;
close(fs);
end;{usually for full screen sprites}

procedure GetImage(nr:byte;x,y,xll,yll:word;where : word);
label l1;
var
   s,o:word;
   adr:word;

begin
with spr[nr] do
     begin
     xl:=xll;
     yl:=yll;
     getmem(pspr,xl*yl);
     s:=seg(pspr^);
     o:=ofs(pspr^);
     end;

adr:=x+y shl 8 +y shl 6;

asm

   push ds
   push es
   mov ax,s
   mov es,ax
   mov ax,where
   mov ds,ax
   mov si,adr
   mov di,o
   mov cx,yll
l1:
   push si
   push cx
   mov cx,xll
   rep movsb
   pop cx
   pop si

   add si,320
   loop l1
   pop es
   pop ds
end;

end;{proc}


Procedure Putspr(nr:byte;x1,y1:integer;mode:byte;where:word);
begin
with spr[nr] do
putimage(x1,y1,xl,yl,pspr,mode,where);
end;

procedure DoneSpr(nr:byte);
begin
with spr[nr] do
freemem(pspr,xl*yl);
end;

procedure PutRomFont( x,y : word;whatfont : byte;
                      whatchar : byte;charheight : byte;color : byte;
                      where : word);
var s,o       : word;
    r         : registers;
    adr       : word;
begin
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
end;
r.al:=$30;
r.bh:=whatfont;
r.ah:=$11;
intr($10,r);
s:=r.es;o:=r.bp;
o:=o+charheight*whatchar;{A}
adr:=y shl 8+y shl 6+x;
asm
mov ax,s
mov es,ax
mov di,o
mov cx,word(charheight)
mov ax,where
mov ds,ax
mov bl,color
mov si,adr
@1 :
   push cx
   mov cx,8
   mov al,es:[di]
   inc di
@3 :
   xor ah,ah
   shl ax,1
   and ah,1
   jz @2
   mov ds:[si],bl
@2 :
   inc si
   loop @3
   sub si,8
   add si,320
   pop cx
   loop @1

   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax

end;

end;

procedure Outtext;
var i,xp:integer;
    p:pointer;

begin
case fnt of
1 : begin
    xp:=x-7;	
    for i:=1 to length(s) do
    begin
    p:=ptr(seg(small),ofs(small[s[i]]));
    putimage(xp+7*i,y,7,7,p,copyput,where);
    end;
    end;
2 : begin
    xp:=x-3;
    for i:=1 to length(s) do
    begin
    p:=ptr(seg(micro),ofs(micro[s[i]]));
    putimage(xp+i shl 2,y,3,3,p,gameput,where);
    end;
    end;
3 : for i:=1 to length(s) do PutRomFont(x+(i-1)*8,y,1,byte(s[i]),8,color,where);
4 : for i:=1 to length(s) do PutRomFont(x+(i-1)*8,y,2,byte(s[i]),14,color,where);
5 : for i:=1 to length(s) do PutRomFont(x+(i-1)*8,y,3,byte(s[i]),8,color,where);

end;
end;

procedure Outint;
var s:string;
begin
str(v,s);
outtext(x,y,s,fnt,color,where);
end;

procedure FadeOut(speed:byte);
var i,j:integer;
begin
for i:=1 to 64 div speed do
    begin
    for j:=0 to 255 do
        begin
        if workpal[j,1]>=speed then dec(workpal[j,1],speed);
        if workpal[j,2]>=speed then dec(workpal[j,2],speed);
        if workpal[j,3]>=speed then dec(workpal[j,3],speed);
        end;
    WaitRetrace;
    Setpal;
    delay(30);
    end;
end;

{
procedure Fill;

var c1,c2,c3,c4,c5,c6 : real;
    r1,r2,r3,r4,r5,r6 : real;
    b1,b2,b3,b4       : real;
    i                 : longint;
    ex56              : real;

begin
if p1.y=p2.y then c1:=(p2.x-p1.x)*10000
             else c1:=(p2.x-p1.x)/(p2.y-p1.y);
r1:=-p1.y*c1+p1.x;

if p1.y=p3.y then c2:=(p3.x-p1.x)*10000
             else c2:=(p3.x-p1.x)/(p3.y-p1.y);
r2:=-p1.y*c2+p1.x;

if p2.y=p4.y then c4:=(p4.x-p2.x)*10000
             else c4:=(p4.x-p2.x)/(p4.y-p2.y);
r4:=-p2.y*c4+p2.x;

if p3.y=p4.y then c3:=(p4.x-p3.x)*10000
             else c3:=(p4.x-p3.x)/(p4.y-p3.y);
r3:=-p3.y*c3+p3.x;

if p2.y=p3.y then c5:=(p3.x-p2.x)*10000
             else c5:=(p3.x-p2.x)/(p3.y-p2.y);
r5:=-p2.y*c5+p2.x;

if p1.y=p4.y then c6:=(p4.x-p1.x)*10000
             else c6:=(p4.x-p1.x)/(p4.y-p1.y);
r6:=-p1.y*c6+p1.x;

if c6<>c5 then ex56:=(r5-r6)/(c6-c5)
          else ex56:=(r5-r6)*10000;

if (ex56>=p2.y) and (ex56<=p3.y+1)
   then begin
        b1:=c1*p1.y+r1;b2:=c2*p1.y+r2;
        for i:=p1.y to p2.y do
            begin
            hlin(round(b1),i,round(b2),i,color,vaddr);
            b1:=b1+c1;b2:=b2+c2;
            end;
        b1:=c2*p2.y+r2;b2:=c5*p2.y+r5;b3:=c4*p2.y+r4;
        for i:=p2.y to p3.y do
        begin
        hlin(round(b1),i,round(b2),i,color,vaddr);
        hlin(round(b3),i,round(b2),i,color,vaddr);
        b1:=b1+c2;b2:=b2+c5;b3:=b3+c4;
        end;
        b1:=p3.y*c3+r3;b2:=p3.y*c4+r4;
        for i:=p3.y to p4.y do
            begin
            hlin(round(b1),i,round(b2),i,color,vaddr);
            b1:=b1+c3;b2:=b2+c4;
            end;
        end
   else begin
        b1:=p1.y*c1+r1;b2:=p1.y*c6+r6;
        for i:=p1.y to p2.y do
            begin
            hlin(round(b1),i,round(b2),i,color,vaddr);
            b1:=b1+c1;b2:=b2+c6;
            end;
        b1:=p2.y*c5+r5;b2:=c6*p2.y+r6;
        for i:=p2.y to p3.y do
            begin
            hlin(round(c5*i+r5),i,round(c6*i+r6),i,color,vaddr);
            b1:=b1+c5;b2:=b2+c6;
            end;
        b1:=p3.y*c3+r3;b2:=p3.y*c6+r6;
        for i:=p3.y to p4.y do
            begin
            hlin(round(b1),i,round(b2),i,color,vaddr);
            b1:=b1+c3;b2:=b2+c6;
            end;
        end;
end;
}

procedure setVisibleStart(offset : word);
begin
        portw[CRTC_ADDR]:= $0C;               {/* set high byte */}
        portw[CRTC_ADDR+1]:=offset shr 8;
        portw[CRTC_ADDR]:= $0D;               {/* set low byte */}
        portw[CRTC_ADDR+1]:=offset and $ff;
end;


begin
end.