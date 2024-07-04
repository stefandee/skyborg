UNIT
    MOUSEDRV;

INTERFACE


USES
    DOS,SETTINGS;
CONST
     COM1PORT = $3F8;
     COM1INTR = $0C;
     COM2PORT = $2F8;
     COM2INTR = $0B;
VAR
   MouseX,MouseY    : integer;
   LeftBtn,RightBtn : boolean;
   DeltaX,DeltaY : integer;

procedure MouseInit(WhatIntr,WhatPort : word);
procedure MouseDone;
procedure SetupMouse;

IMPLEMENTATION

VAR
   bytenum : word;
   combytes : array[0..2] of byte;
   OldMouseHandler : procedure;
   MousePort,MouseIntr : word;
   IsMouseActive : boolean;

{$F+}
procedure MyMouseHandler;Interrupt;
var
   inbyte : byte;
begin
  { Get the port byte }
  inbyte := Port[MousePort];

  { Make sure we are properly "synched" }
  if (inbyte and 64) = 64 then bytenum := 0;

  { Store the byte and adjust bytenum }
  combytes[bytenum] := inbyte;
  inc(bytenum);

  { Have we received all 3 bytes? }
  if bytenum = 3 then
    begin
      { Yes, so process them }
      deltax := (combytes[0] and 3) shl 6 + combytes[1] and 63;
      deltay := (combytes[0] and 12) shl 4 + combytes[2] and 63;
      if deltax >= 128 then deltax := deltax - 256;
      if deltay >= 128 then deltay := deltay - 256;
      Mousex := Mousex + deltax;
      Mousey := Mousey + deltay;
      if Mousex<0 then Mousex:=0;
      if Mousex>319 then Mousex:=319;
      if Mousey<0 then Mousey:=0;
      if Mousey>199 then Mousey:=199;
      LeftBtn := (combytes[0] And 32) <> 0;
      RightBtn := (combytes[0] And 16) <> 0;

      { And start on first byte again }
      bytenum := 0;
    end;

  { Acknowledge the interrupt }
  Port[$20] := $20;
end;
{$F-}

procedure MouseInit;
var aux : byte;
begin
  bytenum  := 0;
  LeftBtn  := false;
  RightBtn := false;
  IsMouseActive := true;
  GetIntVec(WhatIntr, @OldMouseHandler);
  SetIntVec(WhatIntr, Addr(MyMouseHandler));
  MousePort := WhatPort;
  MouseIntr := WhatIntr;
  {asm cli end;
  aux:=port[$21] and $EF;
  port[$21]:=aux;
  asm sti end;}
end;


procedure MOuseDone;
begin
  SetIntVec(MouseIntr, @OldMouseHandler);
  IsMouseActive := false;
end;

procedure SetupMouse;
 var tmp : HardWare;
begin
 ReadSetup;
 if IsMouseActive then MouseDone
                  else IsMouseActive := True;
 MouseInit(Setup.MouseIntr,Setup.MousePort);
end;

BEGIN
END.