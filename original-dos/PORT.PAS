uses crt,dos;
var regs:registers;
    v,vold:byte;
begin
v:=port[$60];
vold:=v;
repeat
v:=port[$60];
if v<>vold
   then begin
        gotoxy(10,10);
        writeln('   ');
        gotoxy(10,10);
        writeln(v);
        vold:=v;
        end;

regs.ah:=$0c;
regs.al:=$02;
intr($21,regs);

until 1=0;
end.