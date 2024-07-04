type codearray = array[1..128] of byte;
var
   a : codearray;
   f : file of codearray;
   i : integer;
begin
 for i:=1 to 128 do a[i]:=128;
 i := 0;
 inc(i);a[i]:=1;
 inc(i);a[i]:=byte('1');
 inc(i);a[i]:=byte('2');
 inc(i);a[i]:=byte('3');
 inc(i);a[i]:=byte('4');
 inc(i);a[i]:=byte('5');
 inc(i);a[i]:=byte('6');
 inc(i);a[i]:=byte('7');
 inc(i);a[i]:=byte('8');
 inc(i);a[i]:=byte('9');
 inc(i);a[i]:=byte('0');
 inc(i);a[i]:=byte('-');
 inc(i);a[i]:=14;
 i:=15;
 inc(i);a[i]:=byte('Q');
 inc(i);a[i]:=byte('W');
 inc(i);a[i]:=byte('E');
 inc(i);a[i]:=byte('R');
 inc(i);a[i]:=byte('T');
 inc(i);a[i]:=byte('Y');
 inc(i);a[i]:=byte('U');
 inc(i);a[i]:=byte('I');
 inc(i);a[i]:=byte('O');
 inc(i);a[i]:=byte('P');
 i:=29;
 inc(i);a[i]:=byte('A');
 inc(i);a[i]:=byte('S');
 inc(i);a[i]:=byte('D');
 inc(i);a[i]:=byte('F');
 inc(i);a[i]:=byte('G');
 inc(i);a[i]:=byte('H');
 inc(i);a[i]:=byte('J');
 inc(i);a[i]:=byte('K');
 inc(i);a[i]:=byte('L');
 i:=43;
 inc(i);a[i]:=byte('Z');
 inc(i);a[i]:=byte('X');
 inc(i);a[i]:=byte('C');
 inc(i);a[i]:=byte('V');
 inc(i);a[i]:=byte('B');
 inc(i);a[i]:=byte('N');
 inc(i);a[i]:=byte('M');
 i:=56;
 inc(i);a[i]:=byte(' ');

 ASSIGN(f,'keycodes.dat');rewrite(f);
 write(f,a);close(f);
end.

