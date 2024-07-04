unit fire;
{$R-}

interface

procedure DoFire;

implementation

uses graphics;

const oy = 50;
      maxtxt = 6;
      txt : array[1..maxtxt] of string=('FIRE','EFFECT','YEAH !','BURN','THE','GROUND');
      rol = 1;

var xfire : array[1..oy+2,1..80] of byte;
    k,i,j,i4,j4,i2  : integer;
    sum  : integer;
    cnt,l,y  : integer;
    f    : file;
    inf  : byte;
    txtcrt : integer;
    dx : integer;
    time : integer;


procedure Initxfire(js,je,is,ie,base : integer);
 var i,j : integer;
begin
 for i:=is to ie do for j:=js to je do xfire[i,j]:=random(254-base)+base+1;
end;

procedure DoFire;

begin

cls(0,vaddr);cls(0,vga);
loadpal('compile.dat',137249);setpal;

randomize;

initxfire(10,19,oy-6,oy+2,0);
initxfire(16,45,oy-15,oy+2,0);
initxfire(43,50,oy-12,oy+2,0);
initxfire(49,70,oy-6,oy+2,0);

cnt:=0;txtcrt:=1;y:=oy-21;dx:=80;time:=0;
hlin:=nhlin;

repeat
  for i:=1 to oy do
      begin
        i4:=(i-1) shl rol;
        i2:=oy shl rol+oy shl (rol-1)-(i-1) shl (rol-1);
        for j:=1 to 80 do
            begin
              sum:=0;
              if xfire[i,j]<>0
                 then begin
                        inc(sum,xfire[i-1,j]);
                        inc(sum,xfire[i,j-1]);
                        inc(sum,xfire[i,j+1]);
                        inc(sum,xfire[i+1,j]);
                        {inc(sum,xfire[i+1,j+1]);inc(sum,xfire[i-1,j+1]);
                        inc(sum,xfire[i+1,j-1]);inc(sum,xfire[i-1,j-1]);}
                        inc(sum,xfire[i,j]);
                        xfire[i,j]:=sum div 5;
                        inc(xfire[i,j],random(5));
                        if xfire[i,j]<3 then xfire[i,j]:=240;
                      end;
              j4:=(j-1) shl rol;
              if (i4<oy shl rol)
                 then begin
                        bar(dx+j4,i4,dx+j4+rol*2,i4+rol*2,xfire[i,j],vaddr);
                        bar(dx+j4,i2,dx+j4+rol*2,i2+rol,xfire[i,j],vaddr);
                      end;
              end;
      end;

dec(y);
if y<=1 then begin
               inc(txtcrt);
               if txtcrt>maxtxt then txtcrt:=1;
               y:=oy-21;
             end;

l:=length(txt[txtcrt]);

for k:=1 to l do
    for i:=1 to 17 do
        for j:=1 to 17 do
            begin
              inf:=small[txt[txtcrt,k]][i,j];
              if inf<>0 then xfire[y+i,round(40-l*7+14*k-14+j)]:=inf;
            end;

if cnt>20
   then begin
        initxfire(1,80,oy+1,oy+2,245);
        cnt:=0;
        end;

inc(cnt);inc(time);
flip;
until (port[$60]=1) or (time>200);
fadeout(3);

end;

Begin
End.
