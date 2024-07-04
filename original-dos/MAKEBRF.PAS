uses crt;
var f,fs : file;
    aux : string;
    i : integer;
    c : char;
begin
 assign(f,'c:\k\fight\missions\help.brf');
 rewrite(f,1);
 assign(fs,'htemp.txt');
 reset(fs,1);
 clrscr;
 aux[1]:=' ';
 for i:=1 to 12*24 do blockwrite(f,aux[1],1);

 repeat
  blockread(fs,aux[1],1);
  if aux[1]='.' then aux[1]:=' ';
  if aux[1]>=' ' then blockwrite(f,aux[1],1);
 until filepos(fs)=filesize(fs);
 {repeat
  readln(aux);
  for i:=1 to length(aux) do
      begin
       if aux[i]<' ' then aux[i]:=' ';
       blockwrite(f,aux[i],1);
      end;
  aux[1]:=' ';
  blockwrite(f,aux[1],1);
  asm mov ax,$0c02
      int $21
      end;
  c:=readkey;
 until (c<>#13);
 }
 aux[1]:=' ';
 for i:=1 to 12*24 do blockwrite(f,aux[1],1);
 close(f);
end.