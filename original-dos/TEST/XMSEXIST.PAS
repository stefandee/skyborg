program xms_tester;
{$M 16384,0,200}
uses dos;
const hmaexist:array[0..1] of string=('not exist','exist');
var r:registers;
    xmsexist:boolean;
    ad1,ad2:word;
    xmscontrol:^longint;
    hma,version,revision:word;
    largest,total:word;
    effect,freeumb,canumb:word;
begin
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
        mov     ax,4310h
        int     2Fh
        mov     word ptr [XMSControl],bx
        mov     word ptr [XMSControl+2],es
        mov ax,0
        call [xmscontrol]
        mov version,ax
        mov revision,bx
        mov hma,dx
        end;
        writeln('commercial version ',{hi(version) div 16,}hi(version) mod 16,'.',lo(version) div 16,lo(version) mod 16,
        ',internal revision number ',{hi(revision) div 16,}hi(revision) mod 16,'.',lo(revision) div 16,lo(revision) mod 16,
        ',Hma ',hmaexist[hma],'.');
        asm
        mov ah,8
        call [xmscontrol]
        mov largest,ax
        mov total,dx
        end;
        writeln('total ammount of XMS memory is : ',total,'Kb',#13#10,
                'largest  XMS  memory block is : ',largest,'Kb');
        asm
        mov ah,$10
        mov dx,$ffff
        call [xmscontrol]
        mov freeumb,dx
        mov canumb,ax
        mov effect,bx
        end;
        writeln('largest UMB is ',freeumb,' ',canumb,' ',effect)
        end;
end.