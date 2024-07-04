UNIT
    SETTINGS;

INTERFACE

USES
    DOS;

TYPE
    HardWare = record
          SoundCard : byte;
          Irq : byte;
          Adress : word;
          MouseIntr : word;
          MousePort : word;
          end;
VAR
   Setup : HardWare;
   FSetup : file of HardWare;

procedure WriteSetup;
procedure ReadSetup;
procedure CreateSetup;
function SearchSetup : boolean;

IMPLEMENTATION

procedure WriteSetup;
begin
 assign(FSetup,'skyborg.cfg');
 reset(FSetup);
 write(FSetup,Setup);
 close(FSetup);
end;

procedure ReadSetup;
begin
 assign(FSetup,'skyborg.cfg');
 reset(FSetup);
 read(FSetup,Setup);
 close(FSetup);
end;

procedure CreateSetup;
begin
 assign(FSetup,'skyborg.cfg');
 rewrite(FSetup);
 close(FSetup);
end;

function SearchSetup;
var
   Sr : SearchRec;
begin
 FindFirst('skyborg.cfg',$3F,Sr);
 if doserror<>0 then SearchSetup := false
               else SearchSetup := true;
end;

BEGIN
END.

