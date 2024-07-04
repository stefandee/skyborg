unit Images;

interface

uses Crt,Graph1;

var corection : shortint;

procedure Fliread(fname:string;pos:longint);
procedure Pcxread(fname:string;pos:longint;len:longint);

implementation

procedure Fliread;

type Header = record
       size:longint;
       id,frames,width,height,depth,flags,speed:word;
       next,frit:longint;
       expand:array[1..102] of byte;
       end;
     Frame = record
           size:longint;
           id,chunks:word;
           expand:array[1..8] of byte;
           end;
     Chunk = record
           size:longint;
           typ:word;
           end;

     TPage=array[1..65535] of byte;
     PPage=^TPage;

var fis     : file;
    h       : Header;
    f       : Frame;
    c       : Chunk;
    p       : PPage;
    i,j     : integer;
    clen,v  : longint;

procedure FLI_COLOR;

var indexd    : word;
    indexc    : byte;
    i         : word;
    nrpackets : word;
    packets   : word;
    skip      : byte;
    change    : byte;

begin

indexc:=0;
nrpackets:=p^[1]+256*p^[2];
indexd:=3;
for packets:=1 to nrpackets do
    begin
    skip:=p^[indexd];inc(indexd);
    change:=p^[indexd];inc(indexd);
    inc(indexc,skip);
    if change=0 then change:=255;
    for i:=indexc to indexc+change do
        begin
        port[$3c8]:=i;
        port[$3c9]:=p^[indexd];inc(indexd);
        port[$3c9]:=p^[indexd];inc(indexd);
        port[$3c9]:=p^[indexd];inc(indexd);
        end;
    inc(indexc,change);
    end;
delay(2*h.speed);

end;

procedure FLI_LC;

var packets          : byte;
    size             : shortint;
    data,skip        : byte;
    i                : word;
    line             : word;
    packets_per_line : byte;
    ini,fin,is,id    : word;

begin

ini:=p^[1]+256*p^[2];
id:=5;
fin:=p^[3]+256*p^[4];
for line:=ini to ini+fin-1 do
    begin
    is:=line*320;
    packets_per_line:=p^[id];inc(id);
    if packets_per_line<>0 then
    for packets:=1 to packets_per_line do
        begin
        skip:=p^[id];inc(id);
        inc(is,skip);
        size:=p^[id];inc(id);
        if size>0
           then begin
                for i:=1 to size do
                    begin
                    mem[vga:is]:=p^[id];
                    inc(is);
                    inc(id);
                    end;
                end
           else begin
                data:=p^[id];inc(id);
                for i:=1 to -size do
                    begin
                    mem[vga:is]:=data;
                    inc(is);
                    end;
                end;
         end;
end;
delay(2*h.speed);
end;

procedure FLI_BLACK;
begin
end;

procedure FLI_BRUN;
var i,id,is          : word;
    line,data        : byte;
    packets          : byte;
    packets_per_line : byte;
    size             : shortint;
begin

id:=1;is:=0;

for line:=0 to 199 do
    begin
    packets_per_line:=p^[id];inc(id);
    
    for packets:=1 to packets_per_line do
        begin
        size:=p^[id];inc(id);
        if size<0
           then begin
                for i:=id to id-size do
                    begin
                    mem[vga:is]:=p^[i];
                    inc(is);
                    end;
               dec(is);
               inc(id,-size);
               end
          else begin
               data:=p^[id];inc(id);
               for i:=is to is+size do mem[vga:i]:=data;
               inc(is,size);
               end;
         end;
    end;
delay(2*h.speed);
end;


procedure FLI_COPY;
begin
end;

label nochunks;

begin

new(p);
assign(fis,fname);
reset(fis,1);
blockread(fis,h,sizeof(header));

for i:=1 to h.frames do
    begin
    blockread(fis,f,sizeof(Frame));
    clen:=0;
    if f.chunks=0
       then begin
            goto nochunks;
            end
       else for j:=1 to f.chunks do
            begin
            blockread(fis,c,sizeof(Chunk));
            blockread(fis,p^,word(c.size-sizeof(Chunk)));
            inc(clen,c.size);
            case c.typ of
            11 : FLI_COLOR;
            12 : FLI_LC;
            13 : FLI_BLACK;
            15 : FLI_BRUN;
            16 : FLI_COPY;
            end;
            end;
nochunks:if clen<f.size-16 then begin
                        blockread(fis,p,f.size-16-clen);
                        end
                        else begin
                             v:=filepos(fis);
                             dec(v,clen+16-f.size);
                             seek(fis,v);
                             end;

    end;
seek(fis,128);
dispose(p);
close(fis);
end;



procedure Pcxread;

var pcx : pointer;
    i,j : integer;
    f   : file;
    pcxseg,pcxofs:word;

begin

assign(f,fname);
reset(f,1);
seek(f,len-768+pos);
blockread(f,workpal,768);

for i:=0 to 255 do for j:=1 to 3 do workpal[i,j]:=workpal[i,j] shr 2+corection;
waitretrace;
setpal;

seek(f,128+pos);
len:=len-128-769;
getmem(pcx,len);
blockread(f,pcx^,word(len));
close(f);
pcxseg:=seg(pcx^);
pcxofs:=ofs(pcx^);

{begin decoding}
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

mov dx,pcxseg
mov ds,dx
mov si,pcxofs
mov dx,$a000
mov es,dx
mov di,0
mov bh,$3f
mov ch,0
mov dh,$c0
mov dl,$3f

@decode:
         mov ax,di
         cmp ax,63999
         jae @finish

         lodsw;

         mov bl,al
         and bl,dh
         cmp bl,dh
         jne @notcode

         and al,dl
         mov cl,al
         shr cx,1
         mov al,ah
         rep stosw
         jnc @decode
         stosb
         jmp @decode
@notcode:
         stosb
         dec si
         jmp @decode
@finish:
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
freemem(pcx,len);
end;

begin
end.