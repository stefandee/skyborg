program xmsalloc;

uses Dos;

type TranBlock = record
               length:longint;
               sourcehan:word;
               sourceseg:word;
               sourceofs:word;
               desthan:word;
               destseg:word;
               destofs:word;
               end;

var xmsexist:boolean;
    xmscontrol:^longint;
    a,b:^string;
    r:registers;
    handle:word;
    tran:tranblock;
    status:word;
    error:byte;

begin
getmem(a,255);
getmem(b,255);
a^:='a string to pass into the XMS';
b^:='             b               ';
writeln(a^);
writeln(b^);
r.ax:=$4300;
intr($2f,r);
xmsexist:=false;
if r.al=$80 then begin
                 writeln('an XMS mem driver exists !');
                 xmsexist:=true;
                 end
          else writeln('no mem driver found !');
if xmsexist
   then begin
        asm
        {find XMS function adress}
        mov     ax,4310h
        int     2Fh
        mov     word ptr [XMSControl],bx
        mov     word ptr [XMSControl+2],es
        {allocate some Xms mem}
        mov ah,9h
        mov dx,1h
        call [XMSControl]
        mov handle,dx
        mov status,ax
        mov error,bl
        end;
        if status=0 then begin
                          writeln('error code in allocation ',error);
                          halt;
                          end
                     else writeln('allocating succesful.handle is ',handle);

        {move info of a pointer to xms allocated above}
        {fill the tran record}
        tran.length:=sizeof(a^);
        tran.sourcehan:=0;{dos block}
        tran.sourceseg:=ofs(a^);
        tran.sourceofs:=seg(a^);
        tran.desthan:=handle;
        tran.destseg:=0;
        tran.destofs:=0;
        asm
        mov ax,seg(tran)
        mov ds,ax
        mov si,offset(tran)
        mov ah,11
        call [XMSControl]
        mov status,ax
        mov error,bl
        end;
        if status=0 then begin
                         writeln('error code in move to Xms ',error);
                         halt;
                         end
                     else writeln('transfer succesful ');
        {move the information of the Xms allocated above into Dos heap area}
        tran.length:=sizeof(b^);
        tran.sourcehan:=handle;
        tran.sourceseg:=0;
        tran.sourceofs:=0;
        tran.desthan:=0;
        tran.destseg:=ofs(b^);
        tran.destofs:=seg(b^);
        asm
        mov ax,seg(tran)
        mov ds,ax
        mov si,offset(tran)
        mov ah,11
        call [XMSControl]
        mov status,ax
        mov error,bl
        end;
        if status=0 then begin
                         writeln('error code in move to dos ',error);
                         halt;
                         end
                     else begin
                          writeln('transfer into Dos heap succesful');
                          writeln('string transfered to Xms is :',a^);
                          writeln('string transfered back to heap is :',b^);
                          end;

        end;
readln;
end.