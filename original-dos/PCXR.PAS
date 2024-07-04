unit pcxr;

interface

uses dos;

var xmin,xmax,ymin,ymax:integer;
    xdep,ydep:integer;
    size,posit:longint;
    scr:array[0..199,0..319] of byte absolute $a000:0;
    Palette256: array[1..256,1..3] of byte;              { place to put 256 color palette }


procedure readpcx(name:string);

implementation

const MAX_WIDTH = 4000;    { arbitrary - maximum width (in bytes) of a PCX image }
      COMPRESS_NUM = $C0;  { this is the upper two bits that indicate a count }
      MAX_BLOCK = 4096;

type
   file_buffer = array [0..127] of byte;
   block_array = array [0..MAX_BLOCK] of byte;
   pal_array = array [1..256, 1..3] of byte;
   line_array = array [0..MAX_WIDTH] of byte;

   pcx_header = record
   Manufacturer: byte;     { Always 10 for PCX file }

   Version: byte;          { 2 - old PCX - no palette (not used anymore),
                           3 - no palette,
			   4 - Microsoft Windows - no palette (only in
                           old files, new Windows version uses 3),
			   5 - with palette }

   Encoding: byte;         { 1 is PCX, it is possible that we may add
                           additional encoding methods in the future }

   Bits_per_pixel: byte;   { Number of bits to represent a pixel
																	(per plane) - 1, 2, 4, or 8 }

   Xmin: integer;          { Image window dimensions (inclusive) }
   Ymin: integer;          { Xmin, Ymin are usually zero (not always) }
   Xmax: integer;
   Ymax: integer;

   Hdpi: integer;          { Resolution of image (dots per inch) }
   Vdpi: integer;          { Set to scanner resolution - 300 is default }

   ColorMap: array [0..15, 1..3] of byte;
   {RGB palette data (16 colors or less)
   256 color palette is appended to end of file }

   Reserved: byte;         { (used to contain video mode)
                             now it is ignored - just set to zero }

   Nplanes: byte;          { Number of planes }

   Bytes_per_line_per_plane: integer;   { Number of bytes to allocate
                                        for a scanline plane.
                                        MUST be an an EVEN number!
                                        Do NOT calculate from Xmax-Xmin! }

   PaletteInfo: integer;   { 1 = black & white or color image,
                           2 = grayscale image - ignored in PB4, PB4+
			   palette must also be set to shades of gray! }

   HscreenSize: integer;   { added for PC Paintbrush IV Plus ver 1.0,  }
   VscreenSize: integer;   { PC Paintbrush IV ver 1.02 (and later)     }
                           {I know it is tempting to use these fields
                           to determine what video mode should be used
			   to display the image - but it is NOT
                           recommended since the fields will probably
                           just contain garbage. It is better to have
			   the user install for the graphics mode he
			   wants to use... }

   Filler: array [74..127] of byte;     { Just set to zeros }
   end;

var
   BlockFile: file;                    { file for reading block data }
   BlockData: block_array;             { 4k data buffer }


   Header: pcx_header;                 { PCX file header }
   
   PCXline: line_array;                { place to put uncompressed data }

   {Ymax: integer;}                      { maximum Y value on screen }
   NextByte: integer;                  { index into file buffer in ReadByte }
   Index: integer;                     { PCXline index - where to put Data }
   Data: byte;                         { PCX compressed data byte }

   PictureMode: integer;               { Graphics mode number }
   Reg: Registers;                     { Register set - used for int 10 calls }
   i: integer;
   buffer: pointer;
{   size: word;}


procedure initg;
begin
asm
mov ax,13h
int 10h
mov ax,0a000h
mov es,ax
end;
end;

procedure xsetcolor(cul:byte;re,gr,blu:byte);
var
igr,iblu,ire:byte;
begin
igr:=gr;
ire:=re;
iblu:=blu;
asm
mov ah,$10
mov al,$10
mov bh,0
mov bl,cul
mov ch,igr
mov cl,iblu
mov dh,ire
int 10h
end;
end;


procedure ShowMCGA (Y: integer);

{ Put a line of MCGA data on the screen }
{ In Turbo Pascal, a '$' means the number is hexadeximal. }

var
   l: integer;

begin
l := Header.XMax - Header.Xmin;            { compute number of bytes to display }
if l > 320 then
   l := 320;                               { don't overrun screen width }

Move (PCXline [0], scr [Y{+ydep},0{xdep}], l);

end;   { ShowMCGA }

procedure Read256palette;

{ Read in a 256 color palette at end of PCX file }
var
   i: integer;
   b: byte;

begin

seek (BlockFile, filesize(blockfile)-769);
BlockRead (BlockFile, b, 1);           { read indicator byte }

if b <> 12 then exit;
BlockRead (blockfile,Palette256,768);
for i:=1 to 256 do xsetcolor(i-1,Palette256[i,1] div 4,Palette256[i,2] div 4,Palette256[i,3] div 4);
{Reg.ah := $10;
Reg.al := $12;
Reg.bx := 0;
Reg.cx := 255;
Reg.dx := ofs (Palette256);
Reg.es := seg (Palette256);
intr ($10, Reg);}
seek (BlockFile,posit+128);                 { go back to start of PCX data }

end;


procedure ReadByte;

{ read a single byte of data - use BlockRead because it is FAST! }

var
   NumBlocksRead: integer;

begin
if NextByte = MAX_BLOCK then
	 begin
	 BlockRead (BlockFile, BlockData, MAX_BLOCK, NumBlocksRead);
   NextByte := 0;
   end;

data := BlockData [NextByte];
inc (NextByte);                         { NextByte++; }
end;  { ReadByte }


procedure ReadHeader;

{ Load a picture header from a PC Paintbrush PCX file }

label WrongFormat;

begin
{$I-}
BlockRead (BlockFile, Header, 128);         { read 128 byte PCX header }

if (Header.Nplanes = 1) then
   begin
   Ymax := 199;
   if (Header.Bits_per_pixel = 8) then
      begin
      PictureMode := 6;{symbolic!}
      if Header.Version = 5 then
         Read256palette;
      end
   end;
Index := 0;
NextByte := MAX_BLOCK;          { indicates no data read in yet... }

end;  { ReadHeader }

procedure Read_PCX_Line;

{ Read a line from a PC Paintbrush PCX file }

var
   count: integer;
   bytes_per_line: integer;

begin
{$I-}
bytes_per_line := Header.Bytes_per_line_per_plane * Header.Nplanes;

                          { bring in any data that wrapped from previous line }
                          { usually none  -  this is just to be safe          }
if Index <> 0 then
   FillChar (PCXline [0], Index, data);    { fills a contiguous block of data }

while (Index < bytes_per_line) do          { read 1 line of data (all planes) }
   begin
   ReadByte;

   if (data and $C0) = compress_num then
      begin
      count := data and $3F;
      ReadByte;
      FillChar (PCXline [Index], count, data);  { fills a contiguous block }
      inc (Index, count);                       { Index += count; }
      end
   else
      begin
      PCXline [Index] := data;
      inc (Index);                              { Index++; }
      end;
      end;


Index := Index - bytes_per_line;

{$I+}
end;  { Read_PCX_Line }

procedure ReadPCX;

{ Read PC Paintbrush PCX file and put it on the screen }

var
   k, kmax: integer;

begin
{$I-}
assign (BlockFile, name);
reset (BlockFile, 1);
seek(blockfile,posit);                  { use 1 byte blocks }
ReadHeader;                            { read the PCX header }

{ >>>>> No checking is done to see if the user has the correct hardware <<<<<
  >>>>> to load the image. Your program sure verify the video mode is   <<<<<
  >>>>> supported. Otherwise, the computer may lock-up.                 <<<<< }
if Header.Version = 5 then


{ >>>>> Note: You should compute the height of the image as follows. <<<<<
	>>>>> Do NOT just read until End-Of-File!                          <<<<< }

kmax := Header.Ymin + Ymax;
if Header.Ymax < kmax then        { don't show more than the screen can display }
	 kmax := Header.ymax;

if (PictureMode = 6) then
   begin
   xmax:=Header.xmax;
   xmin:=Header.xmin;
   ymax:=kmax;
   ymin:=Header.ymin;
   xdep:=(320-(Header.xmax-Header.xmin)) div 2;
   ydep:=(200-(Header.ymax-Header.ymin)) div 2;
   for k := Header.Ymin to kmax do
      begin
      Read_PCX_Line;
      ShowMCGA (k);
      end;
   end;
close (BlockFile);
{$I+}
end;  { Read_PCX }
end.  {implementation}
