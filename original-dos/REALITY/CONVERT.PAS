uses
    crt;
var
   fs : file;
   fd : file;
   b1,b2 : array[1..32000] of byte;
   block,maxblock : integer;
   len,i,j  : longint;
begin
 assign(fs,'floyd.voc');reset(fs,1);
 assign(fd,'floyd.rly');rewrite(fd,1);
 maxblock := filesize(fs) div 32000;block := 0;
 repeat
  len := filesize(fs)-filepos(fs);
  if len>32000 then begin blockread(fs,b1,32000);len := 32000;end
     else blockread(fs,b1,len);
  gotoxy(10,10);writeln('              ');
  gotoxy(10,10);writeln('DONE : ',round((block/maxblock)*100),'%');
  inc(block);
  for j:=1 to len div 2 do
      begin
       b2[j] := b1[2*j];
      end;
  blockwrite(fd,b2,len div 2);
 until filesize(fs)=filepos(fs);
 close(fs);
 close(fd);
end.


