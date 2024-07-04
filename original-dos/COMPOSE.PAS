program cmpose_pcxs;

uses crt;

var buffer:array[1..25000] of byte;
    lung:array[0..194] of word;
    fs,fd:file;
    fname,manv:string;
    i:word;
begin
clrscr;
writeln('composing animation file...wait');
assign(fd,'intro.anm');
rewrite(fd,1);
for i:=0 to 194 do
    begin
    str(i,manv);
    fname:='pic00000';
    insert(manv,fname,9-length(manv));
    fname[0]:=#8;
    fname:=fname+'.pcx';
    gotoxy(10,10);
    writeln('adding ',fname);
    assign(fs,fname);
    reset(fs,1);
    blockread(fs,buffer,filesize(fs));
    blockwrite(fd,buffer,filesize(fs));
    lung[i]:=filesize(fs);
    close(fs);
    end;
writeln('adding lengths...');
blockwrite(fd,lung,sizeof(lung));
close(fd);
writeln('Done.');
end.
