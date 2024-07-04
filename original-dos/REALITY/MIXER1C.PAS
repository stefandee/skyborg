{$R+}
{$M 60000,0,655360}
program
       mixer;

uses
    sounddrv,crt,dos;

type
    zone = array[1..30000] of byte;

var
   x,y   :  ^zone;
   xl,yl : longint;
   f     : file;
   j,i,maxf  : longint;
   Snd   : PApp_SB;
   oldint08 : procedure;
   Clock_Ticks   : longint;
   Counter       : longint;
   frequency     : longint;
   cnt           : longint;

{$F+}
procedure NewInt08;interrupt;
begin
 asm cli end;
 if cnt<maxf-4
    then begin
          Snd^.SB_WriteDAC((x^[cnt]+y^[cnt]) div 2);
          inc(cnt);
         end;
 Clock_Ticks := Clock_Ticks + counter;
 { Is it time for the BIOS handler to do it's thang? }
 if clock_ticks >= $10000 then
   begin
     { Yep! So adjust the count and call the BIOS handler }
     clock_ticks := clock_ticks - $10000;
     asm sti end;
     asm pushf end;
     OldInt08;
   end
 { If not then just acknowledge the interrupt }
 else begin
       Port[$20] := $20;
       asm sti end;
      end;

end;
{$F-}


begin
 Snd := new(PApp_SB,InternalSet);
 volcnt := 9;
 Snd^.SetVolume;
 new(x);new(y);
 assign(f,'beback.2f');reset(f,1);xl:=filesize(f);blockread(f,x^,xl-1);close(f);
 assign(f,'alienlif.2f');reset(f,1);yl:=filesize(f);blockread(f,y^,yl-1);close(f);
 if xl>yl then maxf := yl
          else maxf := xl;
 cnt:=1;
 { Interrupt 08 settings }
 clrscr;
 clock_ticks := 0;
 frequency := 5512;
 counter := $1234DD div frequency;
 GetIntVec($08,@OldInt08);
 SetIntVec($08,addr(NewInt08));
 { Set the PIT channel 0 frequency }

 Port[$43] := $34;
 Port[$40] := counter mod 256;
 Port[$40] := counter div 256;

 readln;

 { Restore the normal clock frequency }
 asm cli end;

 Port[$43] := $34;
 Port[$40] := 0;
 Port[$40] := 0;

 SetIntVec($08,Addr(OldInt08));
 asm sti end;

end.