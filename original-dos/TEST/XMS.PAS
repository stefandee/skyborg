program xms1587;

uses graphics;

type gdt = record
         first : array[1..16] of byte;
         slen : word;
         sadr : array[1..3] of byte;
         sacc : byte;
         middle : word;
         dlen : word;
         dadr : array[1..3] of byte;
         dacc : byte;
         last : array[1..18] of byte;
         end;

var g : gdt;
    i : integer;
    gdtseg,gdtofs : word;
    error : byte;
    aux : longint;

function power(n,p : integer) : integer;
var aux : integer;
begin
if p=0 then power:=1
       else begin
            aux:=1;
            for i:=1 to p do aux:=aux*n;
            power:=aux;
            end;
end;

function Rb(b : byte;nr : byte) : byte;
begin
if (b and nr)=0 then rb:=0
                else rb:=1;
end;

function invert(b:byte):byte;
begin
invert:= rb(b,128)+rb(b,64)*2+rb(b,32)*4+rb(b,16)*8+rb(b,8)*16+rb(b,4)*32+
         rb(b,2)*64+rb(b,1)*128;
end;

begin
vga256;
loadpal('dog.pal');setpal;
loadspr('dog.spr',1);
putspr(1,0,0,normalput,vga);
with spr[2] do
     begin
     xl:=160;yl:=100;
     getmem(pspr,16000);
     end;


{Begin transfer...}
with g do
     begin
          for i:=1 to 16 do first[i]:=0;
          middle:=0;
          for i:=1 to 18 do last[i]:=0;
          slen:=15999;
          sacc:=$93;
          aux:=8*longint(seg(spr[1].pspr^))+longint(ofs(spr[1].pspr^));
          sadr[1]:=invert(aux mod 256);sadr[2]:=invert((aux shr 8) mod 256);sadr[3]:=invert((aux shr 16) mod 256);
          dlen:=15999;
          dacc:=$93;
          dadr[1]:=0;dadr[2]:=0;dadr[3]:=4;
     end;

gdtseg:=seg(g);gdtofs:=ofs(g);
asm
   mov ah,87h
   mov es,gdtseg
   mov si,gdtofs
   mov cx,8000
   int 15h
   jnc @ok
   mov error,ah
@ok :
end;


case error of
0 : outtext(0,0,'Transfer Ok.',3,255,vga);
1 : outtext(0,0,'Parity error.',3,255,vga);
2 : outtext(0,0,'Interrupt error.',3,255,vga);
3 : outtext(0,0,'Adress line 20 gating failed.',3,255,vga);
end;
readln;

{Return transfer}
with g do
     begin
          for i:=1 to 16 do first[i]:=0;
          middle:=0;
          for i:=1 to 18 do last[i]:=0;
          dlen:=15999;
          dacc:=$93;
          aux:=8*longint(seg(spr[2].pspr^))+longint(ofs(spr[2].pspr^));
          dadr[1]:=invert(aux mod 256);dadr[2]:=invert((aux shr 8) mod 256);dadr[3]:=invert((aux shr 16) mod 256);
          slen:=15999;
          sacc:=$93;
          sadr[1]:=0;sadr[2]:=0;sadr[3]:=4;
     end;

gdtseg:=seg(g);gdtofs:=ofs(g);
asm
   mov ah,87h
   mov es,gdtseg
   mov si,gdtofs
   mov cx,8000
   int 15h
   jnc @ok
   mov error,ah
@ok :
end;

case error of
0 : outtext(0,0,'Transfer Ok. 2',3,255,vga);
1 : outtext(0,0,'Parity error. 2',3,255,vga);
2 : outtext(0,0,'Interrupt error. 2',3,255,vga);
3 : outtext(0,0,'Adress line 20 gating failed. 2',3,255,vga);
end;

putspr(2,80,50,normalput,vga);

readln;

end.