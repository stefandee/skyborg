program
       mixer;

uses
    sounddrv,crt;

type
    zone = array[1..30000] of byte;

var
   x,y   :  ^zone;
   xl,yl : longint;
   f     : file;
   j,i,maxf  : integer;
   Snd   : PApp_SB;
begin
 Snd := new(PApp_SB,InternalSet);
 volcnt := 8;
 Snd^.SetVolume;
 new(x);new(y);
 assign(f,'beback.raw');reset(f,1);xl:=filesize(f);blockread(f,x^,xl);close(f);
 assign(f,'alienlif.raw');reset(f,1);yl:=filesize(f);blockread(f,y^,yl);close(f);
 if xl>yl then maxf := yl
          else maxf := xl;
 for i:=1 to maxf do
     begin
      Snd^.SB_WriteDAC((x^[i]+y^[i]) div 2);
      {Snd^.SB_WriteDAC(y^[i]);}
      for j:=1 to 100 do begin end;
     end;
end.