program speed;
uses
    dos,crt;
var
   h,m,s1,s2,s1100,s2100 : word;
   i                     : longint;
   v                     : real;
   ind                   : integer;
   value                 : longint;
begin
 clrscr;
 ind := 0;value := 0;
 repeat
 v := 10000000;
 gettime(h,m,s1,s1100);
 for i:=1 to round(v) do asm nop end;
 gettime(h,m,s2,s2100);
 gotoxy(10,10);write('          ');
 value := value + round((v*7)*100/(1000000*(s2*100+s2100-s1*100-s1100)));
 delay(10);
 inc(ind);
 gotoxy(10,10);writeln('      ');
 gotoxy(10,10);writeln('Complete : ',100*ind div 20,'%');
 until ind>20;
 gotoxy(10,10);writeln('CPU clock is : ',value div ind ,'Mhz');
 readln;
end.
