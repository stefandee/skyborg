UNIT
    GRAPHICS;
{$R-}
INTERFACE

USES
    STRUCTS,TYPES3D,DOS,CRT;
TYPE
     Vrt     = Array [1..64000] of byte;  { The size of the virtual screen }
     VirtPtr = ^Vrt;
     Tspr    = record
             xl,yl:word;
             pspr:pointer
             end;
     font    = record
               x,y : byte;
               p   : pointer;
               end;
     paltype = array[0..255,1..3] of byte;

CONST
      VGA=$A000;
      Crtc_Addr =  $3d4;
      NormalPut =  0  ;      {MOV}
      CopyPut   =  1  ;      {MOV}
      XORPut    =  3  ;      {XOR}
      OrPut     =  2  ;      {OR }
      AndPut    =  1  ;      {AND}
      NotPut    =  4  ;      {NOT}
      GamePut   =  5  ;      {Special put : designed by Karg }
      TextPut   =  6  ;
      Fond      =  0  ;      {like in cartoons stuff, the put above needs
                              a backgnd color}
      SmallFnt  =  1  ;
      MicroFnt  =  2  ;
      XLeftClip  : word  =  1  ;
      XRightClip : word  =  319;
      YTopClip   : word  =  1  ;
      YBotClip   : word  =  199;
      CirclePoints : word = 15;

VAR
    Virscr       : VirtPtr;                     
    Vaddr        : word;                        { The segment of our virtual screen}
    TextColor    : byte;
    Fonts        : array[1..10] of font;
    Frames       : integer;

TYPE
    PApp_Graph = ^App_Graph;
    App_Graph = object(App_3D)

                workpal,pal  : paltype;
                Spr          : array [1..50] of tspr;

                constructor Init;
                procedure Vga256;
                procedure DoneVga256;
                procedure InitVScreen;
                procedure DoneVScreen;

                procedure Putpixel(x,y:word;color:byte;where:word);
                function  Getpixel(x,y:word;where:word):byte;
                procedure Line(x1,y1,x2,y2:integer;color:byte;where:word);
                procedure Hlin(x,y,x1,y1:integer;color:byte;where:word);
                procedure Rectangle(xi,yi,xf,yf:integer;color:byte;where:word);
                procedure Bar(xi,yi,xf,yf:integer;color:byte;where:word);
                procedure NCircle(x,y,radius : integer;color : byte;where : word);
                function Clip(var P1,P2 : Point2D) : boolean;

                procedure Setpal;
                procedure Loadpal(numef:string);
                procedure SetRGB(index,r,g,b:byte);
                procedure GetRGB(index : byte;var r,g,b : byte);
                procedure FadeOut(speed:byte);
                procedure WaitRetrace;

                procedure Flip;
                procedure Cls (Color : Byte; Where:Word);

                {sprite procedures...}
                procedure Loadspr(nume:string;nr:byte);
                procedure Putspr(nr:byte;x1,y1:integer;mode:byte;where:word);
                procedure ScaleSpr(nr : byte;x,y : integer;dxl,dyl : integer);
                procedure ReplaceSpr(fname:string;nr:byte);
                procedure DoneSpr(nr:byte);

                procedure Outtext(x,y:integer;s:string;fnt:byte;color : byte;where:word);
                procedure LoadFnt(fname : string;fnt : integer);
                procedure DoneFnt(fnt : integer);
                procedure Outint(x,y:integer;v:longint;fnt:byte;color : byte;where:word);
                procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
                procedure Setvisiblestart(offset : word);
                procedure Run;virtual;

                destructor Done;
              end;

VAR
   Gfx : PApp_Graph;

IMPLEMENTATION

{$L scale.obj} 	        { Link in Object file }
{$F+} 				{ force calls to be 'far'}
procedure Scale(X,Y,DW,DY,SW,SH : integer;Bitmap : pointer);external;
{$F-}

constructor App_Graph.Init;
begin
 {save pals,maybe virtual screens,loadsprs used for this application...}
end;

procedure App_Graph.Vga256;assembler;
asm
   mov ax,$0013
   int $10
end;

Procedure App_Graph.DoneVga256;assembler;  { This procedure returns you to text mode.  }
  asm
     mov        ax,0003h
     int        10h
  end;

procedure App_Graph.InitVScreen;
begin
 Getmem(virscr,64000);
 Vaddr := seg (virscr^);
end;

procedure App_Graph.DoneVScreen;
begin
 FreeMem(virscr,64000);
end;

procedure App_Graph.Putpixel;
begin
 Mem [Where:X+Y shl 8 +y shl 6]:=color;
end;

function App_Graph.GetPixel;
begin
GetPixel:=Mem[Where:X+Y*320];
end;

procedure App_Graph.Line;
var i, deltax, deltay, numpixels,
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2        : integer;
    screen                 : word;
    screeninc1, screeninc2 : integer;
    p1, p2                 : point2d;
begin

  {clip it}
  p1.x := x1;p1.y := y1;
  p2.x := x2;p2.y := y2;
  if not Clip(p1,p2) then exit;
  x1 := p1.x;y1 := p1.y;
  x2 := p2.x;y2 := p2.y;

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
  screen := word(y1) * 320 + x1;
  screeninc1 := yinc1 * 320 + xinc1;
  screeninc2 := yinc2 * 320 + xinc2;

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

procedure App_Graph.Hlin;
var adr:word;
    xb,len:word;

begin
 if x<xleftclip then x:=xleftclip;
 if x1<xleftclip then x1:=xleftclip;
 if x1>xrightclip then x1:=xrightclip;
 if x>xrightclip then x:=xrightclip;
 if y>ybotclip then exit;
 if y1>ybotclip then exit;
 if y<ytopclip then exit;
 if y1<ytopclip then exit;

 if x>x1 then begin
              xb:=x1;
              len:=abs(x-x1);
              end
         else begin
              xb:=x;
              len:=abs(x1-x);
              end;
 adr:=word(xb+y shl 8 + y shl 6);

 asm
  push es
  mov ax,where
  mov es,ax
  mov di,adr
  mov bl,color
  mov ah,bl
  mov al,bl
  {db $66,$C1,$C0,8{rol eax,8}
  {mov ah,bl
  mov al,bl
  {db $66,$C1,$C0,8{rol eax,8}

  mov cx,len
  mov bx,cx
  and bx,1
  shr cx,1
  {db $F3,$66,$AB{rep stosd}
  rep stosw
  mov cx,bx
  rep stosb
  pop es
 end;
end;

procedure App_Graph.Rectangle;
begin
 if (xi>XRightClip) or (yi>YBotClip) or (yf<YTopClip) or (xf<XLeftClip) then exit;
 if yi>YTopCLip then Line(xi,yi,xf,yi,color,where);
 if yf<YBotClip then Line(xi,yf,xf,yf,color,where);
 if xi>XLeftClip then Line(xi,yi,xi,yf,color,where);
 if xf<XRightClip then Line(xf,yi,xf,yf,color,where);
end;

procedure App_Graph.Bar;
var i : integer;
begin
 for i:=Yi to Yf do Hlin(Xi,i,Xf,i,color,where);
end;

procedure App_Graph.NCircle;
var i,centerang : integer;
    xi,yi,yf,xf : longint;
begin

 centerang := 360 div CirclePoints;
 xi := sint[centerang];xi := xi*radius div 16384;xi:=x-xi;
 yi := cost[centerang];yi := yi*radius div 16384;yi:=y-yi;

 for i:=2 to CirclePoints+1 do
     begin
      xf := sint[(i*centerang) mod 360];
      xf := xf*radius div 16384;
      yf := cost[(i*centerang) mod 360];
      yf := yf*radius div 16384;
      xf:=x-xf;
      yf:=y-yf;
      {
      if (xi>xleftclip) and (xi<xrightclip) and
         (yi<ybotclip) and (yi>ytopclip) and
         (xf>xleftclip) and (xf<xrightclip) and
         (yf<ybotclip) and (yf>ytopclip) then }
      line(xi,yi,xf,yf,color,where);
      xi := xf;
      yi := yf;
     end;
end;

function App_Graph.Clip;
{ input      : P1 , P2 - the points that define the segment to be clipped
               (ussually called by Line/Fill routines)
  output     : the same P1 and P2
  remark     : transcribed from the C routine found in Video docs series,
               which is the implementation of Sutherland-Cohen algorithm
               the C original is (he)artwork
  date       : 30.10.1996, by Karg;original comments                     }
Type
    OutCodeType = record
                code0,code1,code2,code3 : boolean;
                outcodes                : byte;
                end;

Var
   ocu1,ocu2,ocuaux : OutCodeType;
   Inside           : boolean;
   Outside          : boolean;
   temp             : Point2D;

procedure SetOutCodes(var U : OutCodeType ; P : Point2D);
begin
 U.code0 := (P.x<XLeftClip);
 U.code1 := (P.y<YTopClip);
 U.code2 := (P.x>XRightClip);
 U.code3 := (P.y>YBotClip);
 U.outcodes := 0;
 {Feel like coding horror !?}
 U.outcodes := (((((((U.outcodes or byte(U.code3)) shl 1) or byte(U.code2)) shl 1) or byte(U.code1)) shl 1) or byte(U.code0));
end;

begin
 {init 4-bit codes}
 SetOutCodes(ocu1,P1);
 SetOutCodes(ocu2,P2);
 Inside  := (ocu1.outcodes or ocu2.outcodes) = 0;
 OutSide := (ocu1.outcodes and ocu2.outcodes ) <> 0;

 while (not Inside) and (not Outside) do
       begin
        if ocu1.outcodes = 0
           then begin           { swap endpoints if necessary so that P1 to}
                 temp := P1;    { be clipped                               }
                 P1   := P2;
                 P2   := temp;
                 ocuaux := ocu1;
                 ocu1   := ocu2;
                 ocu2   := ocuaux;
                end;
        if ocu1.code0 then begin                 { clip left }
	   P1.y := P1.y+round((P2.y-P1.y)*(XLeftClip-P1.x)/(P2.x-P1.x));
	   P1.x := XLeftClip;
          end
          else if ocu1.code1 then begin            { clip above }
	       P1.x := P1.x+round((P2.x-P1.x)*(YTopClip-P1.y)/(P2.y-P1.y));
	       P1.y := YTopClip;
	      end
	  else if ocu1.code2 then begin	           { clip right }
	       P1.y := P1.x+round((P2.y-P1.y)*(XRightClip-P1.x)/(P2.x-P1.x));
	       P1.x := XRightClip;
              end
	  else if ocu1.code3 then begin		   { clip below }
	       P1.x := P1.x+round((P2.x-P1.x)*(YBotClip-P1.y)/(P2.y-P1.y));
	       P1.y := YBotClip;
	      end;
        SetOutCodes(ocu1,P1); { update for P1 }
        Inside  := (ocu1.outcodes or ocu2.outcodes ) = 0;    { update 4-bit codes}
        OutSide := (ocu1.outcodes and ocu2.outcodes ) <> 0;
       end;
 Clip := Inside;
end;

procedure App_Graph.LoadPal;

var
    fs:file;
begin
 assign(fs,palpath+numef);
 reset(fs,1);
 blockread(fs,workpal,768);
 close(fs);
end;
{
procedure App_Graph.Setpal;
VAR
   r:registers;
begin
     r.ax:=$1012;
     r.es:=seg(workpal);
     r.dx:=ofs(workpal);
     r.bx:=0;
     r.cx:=256;
     intr($10,r);
end;
}

procedure App_Graph.Setpal;
var
   pseg,pofs : word;
begin
 pseg := seg(workpal);
 pofs := ofs(workpal);
asm
   push ds
   mov ax,pseg
   mov ds,ax
   mov si,pofs
end;
WaitRetrace;
asm
   mov dx,3c8h
   mov al,0
   out dx,al
   inc dx
   mov cx,384
   rep outsb
end;
WaitRetrace;
asm
   mov dx,3c8h
   mov al,128
   out dx,al
   inc dx
   mov cx,384
   rep outsb
   pop ds
end;
end;

procedure App_Graph.SetRGB;
begin

port[$3c8]:=index;
port[$3c9]:=r;
port[$3c9]:=g;
port[$3c9]:=b;

end;

Procedure App_Graph.GetRGB;
Var
   RR,GR,BR : Byte;
Begin
   Asm
      mov   dx, 3c7h
      mov   al, [Index]
      out   dx, al
      inc   dx
      inc   dx
      in    al, dx
      mov   [RR],al
      in    al, dx
      mov   [GR],al
      in    al, dx
      mov   [BR],al
   End;
   R := RR;
   G := GR;
   B := BR;
End;

procedure App_Graph.WaitRetrace;assembler;
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



Procedure App_Graph.Cls;
BEGIN
  asm
  mov ax,where
  mov es,ax
  mov al,color
  mov ah,al
  db $66,$C1,$C0,16{rol eax,8}
  mov ah,color
  mov al,ah
  {db $66,$33,$C0{xor eax,eax}
  xor si,si
  xor di,di
  mov cx,16000
  db $F3,$66,$AB{rep stosd - 32 bits ! yeaaah !}
  {rep stosw}
  end;
{Fillchar (Mem [where:0],64000,color);}
END;

Procedure App_Graph.Flip;
var aux : word;
BEGIN
  aux := SegA000;
  asm
  push es
  push ds
  mov ax,vaddr
  mov ds,ax
  xor si,si
  mov ax,AUX
  mov es,ax
  xor di,di
  mov cx,16000
  cld
  db $F3,$66,$A5
  {rep movsw}
  pop ds
  pop es
  end;
{  Move (Virscr^,mem [VGA:0],64000);}
END;

Procedure Putimage(x,y:integer;xl,yl:word;p:pointer;md:byte;where:word);
VAR
   xbg,xe,ybg,ye : word ;
   adrxs,adrys,xlen,grlenx : word ;
   xpxl,ypyl : integer;
   iseg,iofs : word ;
   imgstart : word ;
   xli : word;
   tc : byte;

begin
 xpxl:=x+xl;ypyl:=y+yl;
 tc:=textcolor;
 if (ypyl<ytopclip) or (y>ybotclip) or (xpxl<xleftclip) or (x>xrightclip) then exit;
 if x<xleftclip
    then begin
          xbg:=xleftclip-x+1;
          adrxs:=xleftclip;
         end
    else begin
          xbg:=0;
          adrxs:=x;
         end;
 if xpxl>xrightclip
    then begin
         xe:=xrightclip-adrxs+1;
         end
    else xe:=xl;
 if y<ytopclip
    then begin
          ybg:=ytopclip-y;
          adrys:=ytopclip;
         end
    else begin
          ybg:=0;
          adrys:=y;
         end;
 if ypyl>ybotclip
    then begin
         ye:=ybotclip-adrys+1;
         end
    else ye:=yl;
iseg:=seg(p^);iofs:=ofs(p^);
xlen:=xl-xe+xbg;
grlenx:=320-(xe-xbg);
imgstart:=xl*ybg+xbg;

case md of
gameput :
        asm
         push es
         push ds
         {update es:di-destination and ds:si-source}
         mov ax,iseg
         mov ds,ax
         mov si,iofs
         add si,imgstart
         mov ax,where
         mov es,ax
         {computing x+y*320}
         mov ax,adrxs
         mov bx,adrys
         shl bx,8
         add ax,bx
         shr bx,2
         add ax,bx
         mov di,ax
         mov cx,ybg
         mov dx,xbg
         cld

         @loopy :
                mov bx,cx
                mov cx,xbg{dx}
         @loopx :
                lodsb
                cmp al,0
                jz @zero
                stosb
                jmp @nzero
         @zero :
               inc di
         @nzero :
                inc cx
                cmp cx,xe
                jb @loopx
                add si,xlen
                add di,grlenx
                mov cx,bx
                inc cx
                cmp cx,ye
                jb @loopy
         pop ds
         pop es
        end;
normalput :
          begin
           xli:=xe-xbg;
           asm
            push es
            push ds
            {update es:di-destination and ds:si-source}
            mov ax,iseg
            mov ds,ax
            mov si,iofs
            add si,imgstart
            mov ax,where
            mov es,ax
            {computing x+y*320}
            mov ax,adrxs
            mov bx,adrys
            shl bx,8
            add ax,bx
            shr bx,2
            add ax,bx
            mov di,ax
            mov bx,ybg
            mov dx,xli
            shr dx,1
            cld
            @loopy :
                   mov cx,dx
                   rep movsw
                   jnc @ok
                   movsb
            @ok :
                   add si,xlen
                   add di,grlenx
                   inc bx
                   cmp bx,ye
                   jb @loopy
            pop ds
            pop es
           end;
          end;
textput :
        asm
         push es
         push ds
         {update es:di-destination and ds:si-source}
         mov ax,iseg
         mov ds,ax
         mov si,iofs
         add si,imgstart
         mov ax,where
         mov es,ax
         {computing x+y*320}
         mov ax,adrxs
         mov bx,adrys
         shl bx,8
         add ax,bx
         shr bx,2
         add ax,bx
         mov di,ax
         mov cx,ybg
         mov dx,xbg
         cld

         @loopy :
                mov bx,cx
                mov cx,dx
         @loopx :
                lodsb
                cmp al,0
                jz @zero
                mov al,tc
                stosb
                jmp @nzero
         @zero :
               inc di
         @nzero :
                inc cx
                cmp cx,xe
                jb @loopx
                add si,xlen
                add di,grlenx
                mov cx,bx
                inc cx
                cmp cx,ye
                jb @loopy
         pop ds
         pop es
        end;

end;{case}
end;{proc}


Procedure App_Graph.Loadspr(nume:string;nr:byte{;pos:longint});
var
    xxl,yyl    : word;
    fs         : file;

begin
assign(fs,imgpath+nume);
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

procedure App_Graph.ReplaceSpr;
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


procedure App_Graph.Putspr(nr:byte;x1,y1:integer;mode:byte;where:word);
begin
with spr[nr] do
putimage(x1,y1,xl,yl,pspr,mode,where);
end;

procedure App_Graph.ScaleSpr;
begin
 Scale(x,y,dxl,dyl,spr[nr].xl,spr[nr].yl,spr[nr].pspr);
end;

procedure App_Graph.DoneSpr(nr:byte);
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
xor cx,cx
mov cl,charheight
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

procedure App_Graph.Outtext;
var llen,i,xp:integer;
    p:pointer;

begin
case fnt of
{1 : begin
    xp:=x-7;
    for i:=1 to length(s) do
    begin
    p:=ptr(seg(small^),ofs(small^[s[i]]));
    putimage(xp+7*i,y,7,7,p,copyput,where);
    end;
    end;
2 : begin
    xp:=x-5;
    for i:=1 to length(s) do
    begin
    p:=ptr(seg(micro^),ofs(micro^[upcase(s[i])]));
    putimage(xp+i*6,y,5,5,p,gameput,where);
    end;
    end;
}
1,2
  : begin
     xp:=x-fonts[fnt].x;
     llen:=fonts[fnt].x*fonts[fnt].y;
     for i:=1 to length(s) do
         if (upcase(s[i])>=#32) and (upcase(s[i])<#97) then
            begin
             p:=ptr(seg(fonts[fnt].p^),ofs(fonts[fnt].p^)+(byte(upcase(s[i]))-32)*llen);
             putimage(xp+i*(fonts[fnt].x+1),y,fonts[fnt].x,fonts[fnt].y,p,gameput,where);
            end;
    end;
6,7
  : begin
     xp:=x-fonts[fnt].x;
     llen:=fonts[fnt].x*fonts[fnt].y;
     textcolor:=color;
     for i:=1 to length(s) do
         if (upcase(s[i])>=#32) and (upcase(s[i])<#97) then
            begin
             p:=ptr(seg(fonts[fnt].p^),ofs(fonts[fnt].p^)+(byte(upcase(s[i]))-32)*llen);
             putimage(xp+i*(fonts[fnt].x+1),y,fonts[fnt].x,fonts[fnt].y,p,textput,where);
            end;
    end;

3 : for i:=1 to length(s) do if (x+(i-1)*8<319) and (x+(i-1)*8>=0) then PutRomFont(x+(i-1)*8,y,1,byte(s[i]),8,color,where);
4 : for i:=1 to length(s) do if x+(i-1)*8<319 then PutRomFont(x+(i-1)*8,y,2,byte(s[i]),14,color,where);
5 : for i:=1 to length(s) do if x+(i-1)*8<319 then PutRomFont(x+(i-1)*8,y,3,byte(s[i]),8,color,where);

end;
end;

procedure App_Graph.Outint;
var s:string;
begin
str(v,s);
outtext(x,y,s,fnt,color,where);
end;

procedure App_Graph.LoadFnt;
var f : file;
begin
 assign(f,imgpath+fname);
 reset(f,1);
 with fonts[fnt] do
      begin
       blockread(f,x,1);
       blockread(f,y,1);
       getmem(p,x*y*63);
       blockread(f,p^,x*y*63);
      end;
 close(f);
end;

procedure App_Graph.DoneFnt;
begin
 with fonts[fnt] do
      begin
       freemem(p,x*y*63);
      end;
end;

procedure App_Graph.FadeOut(speed:byte);
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
    Setpal;
    delay(15);
    end;
end;

Procedure App_Graph.DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
  { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
    in color col }
VAR
    miny,maxy : integer;
    loop1     : integer;
    poly      : array[0..199,1..2] of integer;
    sg,os     : word;
    lasty     : integer;

Procedure doside (x1,y1,x2,y2:integer);
  { This scans the side of a polygon and updates the poly variable }
VAR
    temp   : integer;
    x,xinc : longint;
    loop1  : integer;
    a      : longint;
    nx1    : integer;
    aux    : integer;
    p1,p2  : point2d;

BEGIN

  p1.x := x1;p1.y := y1;
  p2.x := x2;p2.y := y2;
  if not Clip(p1,p2) then exit;
  x1 := p1.x;y1 := p1.y;
  x2 := p2.x;y2 := p2.y;

  if y1=y2 then exit;

  if y2<y1 then BEGIN
    temp:=y2;
    y2:=y1;
    y1:=temp;
    temp:=x2;
    x2:=x1;
    x1:=temp;
  END;
  xinc:=round(128*(x2-x1)/(y2-y1));
  {
  if y2>ybotclip
     then begin
           y2:=ybotclip;
           x2:=x1+((y2-y1)*xinc) div 128;
          end;
  if y2<ytopclip
     then begin
           y2:=ytopclip;
           x2:=x1+((y2-y1)*xinc) div 128;
          end;

  if y1>ybotclip
     then begin
           aux:=y1;
           y1:=ybotclip;
           nx1:=x1+((y1-aux)*xinc) div 128;
           x1:=nx1;
          end;
  if y1<ytopclip
     then begin
           aux:=y1;
           y1:=ytopclip;
           nx1:=x1+((y1-aux)*xinc) div 128;
           x1:=nx1;
          end;
  {
  x:=x1*128;
  for loop1:=y1 to y2 do BEGIN
    if (loop1>ytopclip) and (loop1<ybotclip) then BEGIN
      a:=x div 128;
      if (a<poly[loop1,1]) then poly[loop1,1]:=a;
      if (a>poly[loop1,2]) then poly[loop1,2]:=a;
    END;
    x:=x+xinc;
  END;
  }
  for loop1:=y1 to y2 do BEGIN
    if (loop1>ytopclip) and (loop1<ybotclip) then BEGIN
      a:=x1+((loop1-y1)*xinc) div 128;
      if (a<poly[loop1,1]) then poly[loop1,1]:=a;
      if (a>poly[loop1,2]) then poly[loop1,2]:=a;
    END;
    {x:=x+xinc;}
  END;
END;

begin
  if ((x1=MaxInt) and (y1=MaxInt)) or
     ((x2=MaxInt) and (y2=MaxInt)) or
     ((x3=MaxInt) and (y3=MaxInt)) or
     ((x4=MaxInt) and (y4=MaxInt))
     then exit;

  sg:=seg(poly);
  os:=ofs(poly);

  asm
    push ds
    mov ax,sg
    mov ds,ax
    mov   si,os
    mov   cx,200
@Loop1:
    mov   ax,32766
    mov   ds:[si],ax
    inc   si
    inc   si
    mov   ax,-32767
    mov   ds:[si],ax
    inc   si
    inc   si
    loop  @loop1
    pop ds
  end;     { Setting the minx and maxx values to extremes }

  miny:=y1;
  maxy:=y1;
  if y2<miny then miny:=y2;
  if y3<miny then miny:=y3;
  if y4<miny then miny:=y4;
  if y2>maxy then maxy:=y2;
  if y3>maxy then maxy:=y3;
  if y4>maxy then maxy:=y4;
  if miny<ytopclip then miny:=ytopclip;
  if maxy>ybotclip then maxy:=ybotclip;

  Doside (x1,y1,x2,y2);
  Doside (x2,y2,x3,y3);
  Doside (x3,y3,x4,y4);
  Doside (x4,y4,x1,y1);
  Doside (x3,y3,x1,y1);
  Doside (x4,y4,x2,y2);

  for loop1:= miny to maxy do
{      if (poly[loop1,1]>xleftclip) and (poly[loop1,2]>xleftclip) and
         (poly[loop1,1]<xrightclip) and (poly[loop1,2]<xrightclip) then}
      if (poly[loop1,1]<>-32767) and (poly[loop1,2]<>-32767) and
         (poly[loop1,1]<>32766) and (poly[loop1,2]<>32766) and (poly[loop1,2]>poly[loop1,1]) then
         hlin(poly[loop1,1],loop1,poly[loop1,2],loop1,color,where);

end;


procedure App_Graph.SetVisibleStart(offset : word);
begin
        portw[CRTC_ADDR]:= $0C;               {/* set high byte */}
        portw[CRTC_ADDR+1]:=offset shr 8;
        portw[CRTC_ADDR]:= $0D;               {/* set low byte */}
        portw[CRTC_ADDR+1]:=offset and $ff;
end;

procedure App_Graph.Run;
begin
end;

destructor App_Graph.Done;
begin
 {restore pals,virtual screens,donesprs...}
end;

BEGIN
END.

