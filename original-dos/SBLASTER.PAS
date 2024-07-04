UNIT
    SOUNDDRV;

INTERFACE

USES
    STRUCTS,CRT,DOS,SETTINGS;
CONST
      MaxDigitalSounds=16;
      Freqv  :   word = 11025;
      Voltable : array[1..11] of byte=(0,17,51,85,136,153,187,204,221,238,254);
VAR
   Base           : word;
   VolCnt         : integer;

TYPE
    DigitalSound = record
                  len  : word;
                  psnd : pointer;
                  end;

    PApp_Sound = ^App_Sound;
    App_Sound = object(App)
              Sounds : array[1..MaxDigitalSounds] of DigitalSound;
             public
              constructor InternalSet;
              constructor LoadConfig;
              procedure LoadSound(fname : string;nr : byte);virtual;
              procedure FreeSound(nr : byte);virtual;
              procedure PlaySound(nr : byte);virtual;
              procedure SetVolume;virtual;
              end;

    PApp_SB = ^App_SB;
    App_SB = object(App_Sound)
             public
              DSP_RESET        : word;
              DSP_READ_DATA    : word;
              DSP_WRITE_DATA   : word;
              DSP_WRITE_STATUS : word;
              DSP_DATA_AVAIL   : word;

              constructor InternalSet;
              constructor LoadConfig(Fname : string);
              procedure LoadSound(fname : string;nr : byte);virtual;
              procedure FreeSound(nr : byte);virtual;
              procedure PlaySound(nr : byte);virtual;
              procedure SetVolume;virtual;

             private
              procedure SB_SetMixerReg(index, value : byte);
              function SB_GetMixerReg(index : byte) : byte;
              function SB_ResetDSP(xbase : word) : boolean;
              procedure SB_WriteDAC(level : byte);
              function SB_ReadDAC : byte;
              function SB_SpeakerOn: byte;
              function SB_SpeakerOff: byte;
              procedure SB_DMAStop;
              procedure SB_DMAContinue;
              procedure SB_WriteDSP(value : byte);
              function SB_ReadDSP : byte;

             end;

VAR
   Snd : PApp_Sound;

IMPLEMENTATION

VAR
    SOMETHING_PLAY   : boolean;


procedure App_Sound.LoadSound;
begin
end;

procedure App_Sound.FreeSound;
begin
end;

procedure App_Sound.PlaySound;
begin
end;

constructor App_Sound.InternalSet;
begin
end;

constructor App_Sound.LoadConfig;
begin
end;

procedure App_Sound.SetVolume;
begin
end;

{$F+}
procedure IRQ_Handler;interrupt;
 var InByte : byte;
begin
 asm
  pusha
  push bp
  push es
  push ds
 end;
 Inline($FA);  { "cli" }
 InByte := Port[$22e];        { Acknowledge interrupt (from 2xEh). }
 Something_Play := FALSE;          { Set a flag to indicate DMA done.   }
 Port[$20] := $20;                { Reset interrupt controller.        }
 Inline($FB);  { "sti" }
 asm
  pop ds
  pop es
  pop bp
  popa
 end;
end;
{$F-}

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
    f:file;
BEGIN
 assign(f,fname);
 reset(f,1);
 with sounds[nr] do
      begin
       len:=filesize(f);
       getmem(psnd,len);
       blockread(f,psnd^,len);
      end;
 close(f);
END;

procedure App_SB.PlaySound(nr:byte);
VAR
    time_constant : word;
    page, offset : word;
BEGIN
 if not SOMETHING_PLAY
    then with sounds[nr] do
          begin
           {SOMETHING_PLAY := TRUE;}
           len := len - 1;
           { Set up the DMA chip }
           {Port[$21] := Port[$21] AND Not(1 SHL (13 - 8));}
           offset := Seg(psnd^) Shl 4 + Ofs(psnd^);
           page := (Seg(psnd^) + Ofs(psnd^) shr 4) shr 12;
           Port[$0A] := 5;
           Port[$0C] := 0;
           Port[$0B] := $49;
           Port[$02] := Lo(offset);
           Port[$02] := Hi(offset);
           Port[$83] := page;
           Port[$03] := Lo(len);
           Port[$03] := Hi(len);
           Port[$0A] := 1;
           { Set the playback frequency }
           time_constant := 256 - 1000000 div freqv;
           SB_WriteDSP($40);
           SB_WriteDSP(time_constant);
           { Set the playback type (8-bit) }
           SB_WriteDSP($14);
           SB_WriteDSP(Lo(len));
           SB_WriteDSP(Hi(len));
         end;
END;

constructor App_SB.LoadConfig;
begin
 Base := Setup.Adress;
 SOMETHING_PLAY := FALSE;
 SB_ResetDsp(base);
 volcnt:=7;
 SB_Speakeron;
 SB_Setmixerreg(0,0);
 SB_Setmixerreg($04,voltable[volcnt]);
 SB_Setmixerreg($22,voltable[volcnt]);
end;

procedure App_SB.FreeSound;
BEGIN
 with sounds[nr] do
      begin
       freemem(psnd,len);
       len:=0;
      end;
END;

constructor App_SB.InternalSet;
VAR
   i   : integer;
   aux : string;
BEGIN
 SOMETHING_PLAY := FALSE;
 base := 0;
 aux  := getenv('BLASTER');
 if aux<>''
    then begin
          base := $200+$10*(byte(aux[3])-48);
          SB_ResetDsp(base);
          volcnt:=7;
          SB_Speakeron;
          SB_Setmixerreg(0,0);
          SB_Setmixerreg($04,voltable[volcnt]);
          SB_Setmixerreg($22,voltable[volcnt]);
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
                       break;
                      end;
END;

procedure App_SB.SetVolume;
begin
 SB_Setmixerreg($04,voltable[volcnt]);
 SB_Setmixerreg($22,voltable[volcnt]);
end;

BEGIN
END.