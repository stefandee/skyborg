UNIT
    SOUNDDRV;
{$F+}

INTERFACE

USES
    STRUCTS,CRT,DOS,SETTINGS;
CONST
      MaxDigitalSounds  = 64;
      Freqv    :   word = 5512;
      MaxTrax           = 8;{no need for more}
      Voltable : array[1..11] of byte=(0,17,51,85,136,153,187,204,221,238,254);
VAR
   Base           : word;
   Irq            : word;
   VolCnt         : integer;

TYPE

    dummy  = array[1..64010] of byte;
    pdummy = ^dummy;
    TProc  = procedure;

    PDigitalSound = ^DigitalSound;
    DigitalSound = record
                  len    : longint;
                  info   : pointer;
                  next   : PDigitalSound;
                  end;

    TTrack = record
          index  : integer;{in the Sounds array}
          pos    : word;
          mode   : byte;
          curent : PDigitalSound;
          end;

    PApp_Sound = ^App_Sound;
    App_Sound = object(App)
              Sounds       : array[1..MaxDigitalSounds] of PDigitalSound;
              OldIrq       : procedure;
              OldInt08     : procedure;
              Counter      : longint;
              Clock_Ticks  : longint;
             public
              DSP_RESET        : word;
              DSP_READ_DATA    : word;
              DSP_WRITE_DATA   : word;
              DSP_WRITE_STATUS : word;
              DSP_DATA_AVAIL   : word;

              constructor InternalSet;
              constructor LoadConfig;
              procedure LoadSound(fname : string;nr : byte);virtual;
              procedure FreeSound(nr : byte);virtual;
              procedure PlaySound(nr : byte);virtual;
              procedure PlayStop;virtual;
              procedure InstallTimer;virtual;
              procedure UnInstallTimer;virtual;
              procedure PlayDMASound(nr : byte);virtual;
              procedure SetVolume;virtual;
              destructor Done;virtual;
              end;

    PApp_SB = ^App_SB;
    App_SB = object(App_Sound)
             public

              constructor InternalSet;
              constructor LoadConfig;
              procedure   LoadSound(fname : string;nr : byte);virtual;
              procedure   FreeSound(nr : byte);virtual;
              procedure   PlayDMASound(nr : byte);virtual;
              procedure   SetVolume;virtual;
              procedure   InstallTimer;virtual;
              procedure   UnInstallTimer;virtual;
              procedure   PlaySound(nr : byte);virtual;
              destructor  Done;virtual;

             private
              function    SB_GetMixerReg(index : byte) : byte;
              function    SB_ResetDSP(xbase : word) : boolean;
              function    SB_ReadDAC : byte;
              function    SB_SpeakerOn: byte;
              function    SB_SpeakerOff: byte;
              function    SB_ReadDSP : byte;
              procedure   SB_SetMixerReg(index, value : byte);
              procedure   SB_WriteDAC(level : byte);
              procedure   SB_DMAStop;
              procedure   SB_DMAContinue;
              procedure   SB_WriteDSP(value : byte);
             end;

VAR
   Snd    : PApp_Sound;
   Tracks       : array[1..MaxTrax] of TTrack;

IMPLEMENTATION

VAR
    Play_Index   : integer;

procedure App_Sound.LoadSound;
BEGIN
END;

procedure App_Sound.FreeSound;
BEGIN
END;

procedure App_Sound.PlayDMASound;
BEGIN
END;

constructor App_Sound.InternalSet;
BEGIN
END;

constructor App_Sound.LoadConfig;
BEGIN
 PlayStop;
 Base := Setup.Adress;
 Play_Index := 0;
END;

procedure App_Sound.InstallTimer;
BEGIN
END;

procedure App_Sound.UnInstallTimer;
BEGIN
END;

procedure App_Sound.PlaySound;
BEGIN
END;

procedure App_Sound.PlayStop;
 var
    i : integer;
BEGIN
 for i:=1 to MaxTrax do with Tracks[i] do begin pos := 0;mode := 0;end;
END;

procedure App_Sound.SetVolume;
BEGIN
END;

destructor App_Sound.Done;
BEGIN
END;

{ base = 220h, 230 or 240h }
procedure App_SB.SB_SetMixerReg(index, value : byte);
BEGIN
 Port[base + 4] := index;
 Port[base + 5] := value;
END;

function App_SB.SB_GetMixerReg(index : byte) : byte;
BEGIN
  Port[base + 4] := index;
  SB_GetMixerReg := Port[base + 5];
END;


function App_SB.SB_ResetDSP(xbase : word) : boolean;

VAR
    basenr : byte;
    count  : integer;

BEGIN

  basenr := xbase-$200;

  { Calculate the port addresses }
  DSP_RESET := basenr + $206;
  DSP_READ_DATA := basenr + $20A;
  DSP_WRITE_DATA := basenr + $20C;
  DSP_WRITE_STATUS := basenr + $20C;
  DSP_DATA_AVAIL := basenr + $20E;

  { Reset the DSP, and give some nice long delays just to be safe }
  Port[DSP_RESET] := 1;
  Delay(20);
  Port[DSP_RESET] := 0;
  Delay(20);
  Count:=1000;
  repeat
   dec(Count);
  until ((Port[DSP_READ_DATA] = $AA) and (Port[DSP_DATA_AVAIL] And $80 = $80)) or (Count<=0);
  if Count<=0 then SB_ResetDsp:=false
              else SB_ResetDsp:=true;
END;

procedure App_SB.SB_WriteDSP(value : byte);
BEGIN
  while Port[DSP_WRITE_STATUS] And $80 <> 0 do;
  Port[DSP_WRITE_DATA] := value;
END;

function App_SB.SB_ReadDSP : byte;
BEGIN
  while Port[DSP_DATA_AVAIL] and $80 = 0 do;
  SB_ReadDSP := Port[DSP_READ_DATA];
END;

procedure App_SB.SB_WriteDAC(level : byte);
BEGIN
  SB_WriteDSP($10);
  SB_WriteDSP(level);
END;

function App_SB.SB_ReadDAC : byte;
BEGIN
  SB_WriteDSP($20);
  SB_ReadDAC := SB_ReadDSP;
END;

function App_SB.SB_SpeakerOn: byte;
BEGIN
  SB_WriteDSP($D1);
END;

function App_SB.SB_SpeakerOff: byte;
BEGIN
  SB_WriteDSP($D3);
END;

procedure App_SB.SB_DMAContinue;
BEGIN
  SB_WriteDSP($D4);
END;

procedure App_SB.SB_DMAStop;
BEGIN
  SB_WriteDSP($D0);
END;

procedure App_SB.LoadSound;
 VAR
    f     : file;
    aux   : PDigitalSound;
    first : PDigitalSound;
    aux1  : PDigitalSound;
BEGIN
 assign(f,soundpath+fname);
 reset(f,1);
 first := nil;
 while filesize(f)-filepos(f)>64000 do
       begin
        new(aux);
        getmem(aux^.info,64000);
        aux^.len := 64000;
        blockread(f,aux^.info^,64000);
        aux^.next := NIL;
        if first = NIL then first := aux
           else begin
                 aux1 := first;
                 while aux1^.next<>NIL do aux1:=aux1^.next;
                 aux1^.next := aux;
                end;
       end;
 new(aux);
 getmem(aux^.info,filesize(f)-filepos(f));
 aux^.len := filesize(f)-filepos(f);
 blockread(f,aux^.info^,filesize(f)-filepos(f));
 aux^.next := NIL;
 if first = NIL then first := aux
    else begin
          aux1 := first;
          while aux1^.next<>NIL do aux1:=aux1^.next;
          aux1^.next := aux;
         end;
 Sounds[nr] := first;
 close(f);
END;

procedure App_SB.PlayDMASound(nr:byte);
VAR
    time_constant : word;
    page, offset : word;
BEGIN
 if Play_Index=0
    then with sounds[nr]^ do
          begin
           { Set up the DMA chip }
           {Port[$21] := Port[$21] AND Not(1 SHL (13 - 8));}
           offset := Seg(info^) Shl 4 + Ofs(info^);
           page := (Seg(info^) + Ofs(info^) shr 4) shr 12;
           Port[$0A] := 5;
           Port[$0C] := 0;
           Port[$0B] := $49;
           Port[$02] := Lo(offset);
           Port[$02] := Hi(offset);
           Port[$83] := page;
           Port[$03] := Lo(len-1);
           Port[$03] := Hi(len-1);
           Port[$0A] := 1;
           { Set the playback frequency }
           time_constant := 256 - 1000000 div freqv;
           SB_WriteDSP($40);
           SB_WriteDSP(time_constant);
           { Set the playback type (8-bit) }
           SB_WriteDSP($14);
           SB_WriteDSP(Lo(len-1));
           SB_WriteDSP(Hi(len-1));
         end;
END;

{$F+}
procedure NewInt08;interrupt;
 var
    activecount,i     : integer;
    mixedbyte         : longint;
BEGIN
 asm cli end;
 activecount := 0;
 mixedbyte   := 0;
 for i:=1 to MaxTrax do
      if Tracks[i].mode<>0 then
         begin
          inc(activecount);
          inc(Tracks[i].pos);
          inc(mixedbyte,pdummy(Tracks[i].curent^.info)^[Tracks[i].pos] div MaxTrax);
          if Tracks[i].pos>Tracks[i].curent^.len-1
             then begin
                   if Tracks[i].curent^.next = NIL then Tracks[i].mode := 0
                      else begin
                            Tracks[i].curent := Tracks[i].curent^.next;
                            Tracks[i].pos    := 0;
                           end;
                  end;
         end;

 if activecount<>0
    then begin
          while Port[Snd^.DSP_WRITE_STATUS] And $80 <> 0 do;
          Port[Snd^.DSP_WRITE_DATA] := $10;
          {if mixedbyte>255 then mixedbyte := 255;}
          {:= mixedbyte div activecount;}
          while Port[Snd^.DSP_WRITE_STATUS] And $80 <> 0 do;
          Port[Snd^.DSP_WRITE_DATA] := BYTE(mixedbyte);
         end;

 Snd^.Clock_Ticks := Snd^.Clock_Ticks + Snd^.counter;
 { Is it time for the BIOS handler to do it's thang? }
 asm sti end;
 if Snd^.clock_ticks >= $10000 then
   begin
     { Yep! So adjust the count and call the BIOS handler }
     Snd^.clock_ticks := Snd^.clock_ticks - $10000;
     asm pushf end;
     Snd^.OldInt08;
   end
 { If not then just acknowledge the interrupt }
 else begin
       Port[$20] := $20;
      end;
END;
{$F-}

procedure App_SB.InstallTimer;
BEGIN
 PlayStop;
 GetIntVec($08,@OldInt08);
 writeln('getintvec');
 SetIntVec($08,addr(NewInt08));
 writeln('setintvec');
 counter := $1234DD div freqv;
 { Set the PIT channel 0 frequency }
 Port[$43] := $34;
 Port[$40] := counter mod 256;
 Port[$40] := counter div 256;
 writeln('pit settings');
END;

procedure App_SB.UnInstallTimer;
BEGIN
 asm cli end;
 PlayStop;
 asm sti end;
 Port[$43] := $34;
 Port[$40] := 0;
 Port[$40] := 0;
 SetIntVec($08,Addr(OldInt08));
END;

procedure App_SB.PlaySound;
 var
    j : integer;
BEGIN
 for j:=1 to MaxTrax do
     if Tracks[j].mode = 0
        then begin
              Tracks[j].curent := Sounds[nr];
              Tracks[j].pos    := 0;
              Tracks[j].index  := nr;
              Tracks[j].mode   := 3;
              break;
             end;
END;

constructor App_SB.LoadConfig;
BEGIN
 PlayStop;
 Base := Setup.Adress;
 case Setup.Irq of
  $0D : begin SB_SetMixerReg($80,2); {plus install the irq hooker}end;
  $0F : begin SB_SetMixerReg($80,4); {plus install the irq hooker}end;
  $5A : begin SB_SetMixerReg($80,8); {plus install the irq hooker}end;
 end;
 Play_Index := 0;
 SB_ResetDsp(base);
 volcnt:=11;
 SB_Speakeron;
 SB_Setmixerreg(0,0);
 SB_Setmixerreg($04,voltable[volcnt]);
 SB_Setmixerreg($22,voltable[volcnt]);
 SB_SetMixerReg($41,128);
 SB_SetMixerReg($42,128);
END;

procedure App_SB.FreeSound;
 var
    auxn,aux : PDigitalSound;
BEGIN
 aux := Sounds[nr];
 while aux<>NIL do
       begin
        freemem(aux^.info,aux^.len);
        auxn:=aux^.next;
        dispose(aux);
        aux:=auxn;
       end;
END;

constructor App_SB.InternalSet;
VAR
   i   : integer;
   aux : string;
BEGIN
 Play_Index := 0;
 PlayStop;
 base := 0;
 aux  := getenv('BLASTER');
 if aux<>''
    then begin
          base := $200+$10*(byte(aux[3])-48);
          SB_ResetDsp(base);
          volcnt:=10;
          SB_Speakeron;
          SB_Setmixerreg(0,0);
          SB_Setmixerreg($04,voltable[volcnt]);
          SB_Setmixerreg($22,voltable[volcnt]);
          SB_SetMixerReg($41,128);
          SB_SetMixerReg($42,128);
         end
    else
         for i:=1 to 9 do
              if SB_ResetDSP($200+$10*i)
                 then begin
                       volcnt:=7;base:=$200+$10*i;
                       SB_Speakeron;
                       SB_Setmixerreg(0,0);
                       SB_Setmixerreg($04,voltable[volcnt]);
                       SB_Setmixerreg($22,voltable[volcnt]);
                       SB_SetMixerReg($41,128);
                       SB_SetMixerReg($42,128);
                       break;
                      end;
END;

procedure App_SB.SetVolume;
BEGIN
 SB_Setmixerreg($04,voltable[volcnt]);
 SB_Setmixerreg($22,voltable[volcnt]);
END;

destructor App_SB.Done;
BEGIN
 SB_SpeakerOff;
END;

BEGIN
END.