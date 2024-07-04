UNIT
    STRUCTS;

INTERFACE

USES
    Dos,Crt;

TYPE
    Path = string[64];
    PApp = ^App;
    App = object
        constructor Init;
        procedure Run;virtual;
        procedure InitPath;
        procedure FreeBuf;
        destructor Done;
        end;

function Int2Str(v : longint) : string;

VAR
   pilotpath,imgpath,intropath,soundpath,palpath,shapepath,missionpath : path;


IMPLEMENTATION

constructor App.Init;
begin
end;

procedure App.Run;
begin
end;

procedure App.InitPath;
var
     dir : dirstr;
     fn  : namestr;
     ext : extstr;
begin
 fsplit(fexpand('skyborg.exe'),dir,fn,ext);
 soundpath:=dir+'SOUND'+'\';
 imgpath  :=dir+'IMG'+'\';
 intropath:=dir+'INTRO'+'\';
 palpath  :=dir+'PAL'+'\';
 shapepath:=dir+'SHAPES'+'\';
 missionpath:=dir+'MISSIONS'+'\';
 pilotpath := dir+'PILOTS'+'\';
end;

procedure App.FreeBuf;
begin
 asm
  mov ax,$0c02
  int 21h
 end;
end;

destructor App.Done;
begin
end;

function Int2Str;
 var
    aux : string;
begin
 aux := '';
 str(v,aux);
 Int2Str:=aux;
end;

BEGIN
END.