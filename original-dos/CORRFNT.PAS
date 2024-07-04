program correction;{font}
var f : file;
    p : pointer;
    aux : byte;
    size : longint;
begin
 assign(f,'d:\backoops\fight.u\micro2.fnt');
 reset(f,1);
 getmem(p,filesize(f));
 blockread(f,p^,filesize(f));
 size:=filesize(f);
 close(f);
 assign(f,'c:\app\karg\fight\img\micro2.fnt');
 rewrite(f,1);
 aux:=3;
 blockwrite(f,aux,1);
 aux:=5;
 blockwrite(f,aux,1);
 blockwrite(f,p^,size);
 close(f);
end.

