PROGRAM
       Analizor;

USES
    GRAPH,CRT,DOS;

CONST
     Esant_Max = 20000;

TYPE
      sigla_spr  = array[1..40,1..10] of byte;
      psigla_spr = ^sigla_spr;

VAR
   gd,gm         : integer;
   esantion      : array[1..Esant_Max] of byte;
   left,right    : integer;
   curent        : integer;
   ecolor        : integer;
   key           : char;
   i             : integer;
   HLevel        : byte;
   Period        : byte;
   Frequency     : integer;
   StartMsg      : string[15];
   OldInt08      : procedure;
   CountRead     : byte;
   ValueRead     : byte;
   CrtBitIntr,LastBitIntr : byte;
   SprSigla      : PSigla_Spr;
   CrtFile       : string;
   Ts            : SearchRec;
   WavFile       : File;
   Clock_Ticks   : longint;
   Counter       : longint;

procedure sigla;external;
{$L sigla.obj}

function ENTER(x,y,len:integer;fond,fore:byte;firsttext:string):string;
var s,manv             : string;
    ch                 : char;
    index,moveindex    : integer;
    th,tw              : integer;
begin
s:=firsttext;index:=length(s);moveindex:=1;
setcolor(fore);outtextxy(x,y,s);
tw := textwidth('A');
th := textheight('A');
 repeat
  if keypressed
     then begin
           ch:=readkey;
           case upcase(ch) of
           #8 : begin
                if (length(s)>1) and (index>1)
                then begin
                     delete(s,index,1);
                     dec(index);
                     end;
                end;
           #75 : begin
                 if (length(s)>1) and (index>1)
                 then begin
                      dec(index);
                      end;
                 end;
           #77 : begin
                 if (length(s)<len) and (index<len)
                 then begin
                      inc(index);
                      end;
                 end;
           ' '..'z' : begin
                       if (length(s)<len) and (index<len)
                          then begin
                                manv:=ch;
                                insert(manv,s,index);
                                inc(index);
                               end;
                      end;
          end;
          setfillstyle(1,fond);bar(x,y,x+len*tw,y+th);
          setfillstyle(1,fore+1);bar(x+(index-1)*tw,y,x+index*tw,y+th);
          setcolor(fore);outtextxy(x,y,s);
         end
     else ch:=#0;
 until ch=#13;
 enter:=s;
end;


function GetBit(value : byte;where : byte) : byte;
var aux : byte;
begin
 aux := 1;
 aux := aux shl where;
 if value and aux = 0 then GetBit := 0
    else GetBit := 1;
end;


procedure FreeBuf;assembler;
 asm
  mov ax,$0c02
  int 21h
 end;

function Int2Str(value : longint) : string;
var result : string;
begin
 str(value,result);
 Int2Str := result;
end;


procedure Afis_Esant;

const lastbit : byte = 0;

var i,j,crtbit   : integer;

begin
 setfillstyle(1,black);
 bar(1,1,getmaxx-1,getmaxy div 2-1);
 moveto(1,getmaxy div 4);
 setcolor(ecolor);
 for i:=1 to 80 div Period do
     for j:=0 to 7 do
          begin
           crtbit := GetBit(esantion[i+left],j);
           case crtbit of
           0 : if lastbit=1 then begin LineRel(0,HLevel);LineRel(Period,0);end
                  else LineRel(Period,0);
           1 : if lastbit=0 then begin LineRel(0,-HLevel);LineRel(Period,0);end
                  else LineRel(Period,0);
           end;
           lastbit := crtbit;
          end;
end;

procedure Meniu;
begin
 setfillstyle(1,black);
 bar(0,getmaxy div 2,getmaxx,getmaxy);
 setcolor(15);
 rectangle(0,0,getmaxx,getmaxy);
 line(0,getmaxy div 2,getmaxx,getmaxy div 2);
 outtextxy(10,getmaxy div 2+10,StartMsg);
 outtextxy(10,getmaxy div 2+40,'< (rulare esantion : '+Int2Str(left div 200)+'% ) > ');
 outtextxy(10,getmaxy div 2+55,'+ (inaltime : '+Int2Str(HLevel)+' ) - ');
 outtextxy(10,getmaxy div 2+25,'[ (latime : '+Int2Str(Period)+' ) ] ');
 outtextxy(10,getmaxy div 2+70,'<- (timp de esantionare : '+Int2Str(Frequency)+'Hz('+Int2Str(1000 div Frequency)+'ms)) -> ');
 outtextxy(10,getmaxy div 2+85,'<L>oad waveform ');
 outtextxy(10,getmaxy div 2+100,'S<a>ve waveform ');
 outtextxy(10,getmaxy div 2+115,'Esc - quit ');
 setcolor(10);
 putimage(596,468,SprSigla^,copyput);
end;

procedure NewInt08;interrupt;
var value : byte;
begin
 asm cli end;
 if curent<Esant_Max
    then begin
          value  := port[$3F8];
          CrtBitIntr := GetBit(value,4);

          case CrtBitIntr of
          0 : if lastbitIntr=1 then begin LineRel(0,HLevel);LineRel(Period,0);end
                 else LineRel(Period,0);
          1 : if LastbitIntr=0 then begin LineRel(0,-HLevel);LineRel(Period,0);end
                 else LineRel(Period,0);
          end;
          LastBitIntr := CrtBitIntr;

          Esantion[curent] := Esantion[curent] shl 1;
          inc(Esantion[curent],CrtBitIntr);

          inc(CountRead);
          if CountRead = 8
             then begin
                   CountRead := 1;
                   inc(curent);
                   if curent-left>80 div Period
                      then begin
                            left := curent;
                            Meniu;
                            LastBitIntr := 0;
                            setfillstyle(1,black);
                            bar(1,1,getmaxx-1,getmaxy div 2-1);
                            setcolor(ecolor);
                            moveto(1,getmaxy div 4);
                           end;
                  end;
         end;
  asm sti end;
  Clock_Ticks := Clock_Ticks + counter;
  { Is it time for the BIOS handler to do it's thang? }
  if clock_ticks >= $10000 then
    begin
      { Yep! So adjust the count and call the BIOS handler }
      clock_ticks := clock_ticks - $10000;
      asm pushf end;
      OldInt08;
    end
  { If not then just acknowledge the interrupt }
  else
    Port[$20] := $20;

end;
BEGIN
 gd := detect;
 initgraph(gd,gm,'c:\bin\bp\bgi');
 writeln(GraphErrorMsg(GraphResult));
 left        := 1;
 right       := 639;
 ecolor      := 15;
 HLevel      := 10;
 Period      := 10;
 Frequency   := 18;
 StartMsg    := '<S>tart';
 CrtFile     := 'nothing.wav';
 FillChar(esantion,Esant_Max,0);
 new(SprSigla);
 SprSigla    := addr(Sigla);
 Meniu;
 Afis_Esant;

 repeat
  if keypressed then begin
                      key := readkey;
                      FreeBuf;
                     end
                else key := #0;
  case UPCASE(key) of
  ',' : begin
         dec(left);
         if left<1 then begin left :=1;sound(300);delay(50);nosound;end;
         Meniu;
         Afis_Esant;
        end;
  '.' : begin
         inc(left);
         if (left+getmaxx div 10)>Esant_Max then left :=Esant_Max-getmaxx div 10;
         Meniu;
         Afis_Esant;
        end;
  'S' : begin
         StartMsg :='<S>top';
         Meniu;
         curent := left;
         LastBitIntr := 0;
         moveto(0,0);
         setfillstyle(1,black);
         bar(1,1,getmaxx-1,getmaxy div 2-1);
         moveto(1,getmaxy div 4);
         setcolor(ecolor);

         { Interrupt 08 settings }
         clock_ticks := 0;
         counter := $1234DD div frequency;
         GetIntVec($08,@OldInt08);
         SetIntVec($08,Addr(NewInt08));
         { Set the PIT channel 0 frequency }
         Port[$43] := $34;
         Port[$40] := counter mod 256;
         Port[$40] := counter div 256;

         repeat
         until UPCASE(readkey)='S';

         { Restore the normal clock frequency }
         Port[$43] := $34;
         Port[$40] := 0;
         Port[$40] := 0;
         StartMsg := '<S>tart';
         SetIntVec($08,Addr(OldInt08));

         Meniu;
        end;
  '-' : begin
         dec(HLevel);
         if HLevel<4 then HLevel := 4;
         Afis_Esant;
         Meniu;
        end;
  '=' : begin
         inc(HLevel);
         if HLevel>50 then HLevel := 50;
         Meniu;
         Afis_Esant;
        end;
  '[' : begin
         dec(Period);
         if Period<1 then Period := 1;
         Meniu;
         Afis_Esant;
        end;
  ']' : begin
         inc(Period);
         if Period>50 then Period := 50;
         Meniu;
         Afis_Esant;
        end;
  #77 : begin
         inc(Frequency);
         if Frequency>300 then Frequency := 300;
         Meniu;
        end;
  #75 : begin
         dec(Frequency);
         if Frequency<18 then Frequency := 18;
         Meniu;
        end;
   'L': begin
         CrtFile:=Enter(10+130,getmaxy div 2+85,12,7,15,CrtFile);
         FindFirst(CrtFile,$3f,ts);
         if doserror<>0
            then begin
                  outtextxy(getmaxx div 2-150,8*getmaxy div 9,'Error while loading file '+CrtFile);
                  repeat until readkey<>'';
                 end
            else begin
                  assign(WavFile,CrtFile);
                  reset(WavFile,1);
                  if filesize(WavFile)>sizeof(esantion) then blockread(WavFile,esantion,sizeof(esantion))
                     else blockread(WavFile,esantion,filesize(WavFile));
                  close(WavFile);
                 end;
         Meniu;
         Afis_Esant;
        end;
  'A' : begin
         CrtFile:=Enter(10+130,getmaxy div 2+100,12,7,15,CrtFile);
         FindFirst(CrtFile,$3f,ts);
         if doserror<>0
            then begin
                  assign(WavFile,CrtFile);
                  rewrite(WavFile,1);
                  blockwrite(WavFile,esantion,sizeof(esantion));
                  close(WavFile);
                  outtextxy(getmaxx div 2-150,8*getmaxy div 9,'Saving OK.');
                  repeat until readkey<>'';
                 end
            else begin
                  outtextxy(getmaxx div 2-150,8*getmaxy div 9,'File already exist.Overwrite(y/n) ?');
                  if UPCASE(readkey)='Y'
                     then begin
                           assign(WavFile,CrtFile);
                           rewrite(WavFile,1);
                           blockwrite(WavFile,esantion,sizeof(esantion));
                           close(WavFile);
                           outtextxy(getmaxx div 2-150,8*getmaxy div 9+10,'Saving OK.');
                           repeat until readkey<>'';
                          end
                     else begin
                           outtextxy(getmaxx div 2-150,8*getmaxy div 9+10,'Saving skipped.');
                           repeat until readkey<>'';
                          end;
                 end;
        Meniu;
        Afis_Esant;
        end;
  end;
 until key=#27;

 FreeBuf;
 closegraph;
END.

