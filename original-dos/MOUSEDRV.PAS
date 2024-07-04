UNIT
    MOUSEDRV;

INTERFACE

USES
    Dos,Types3D;

TYPE
    TShape = RECORD
           HotX, HotY: Byte;
	   Data: array[1..64] of byte;
           END;

    PTMouse = ^TMouse;
    TMouse = OBJECT
                P: Point2D;
                Shape: TShape;
                DeltaX,DeltaY : integer;
                constructor Init;
                function X: Word;
                function Y: Word;
                function LeftButtonPressed: Boolean;
                function RightButtonPressed: Boolean;
                function CenterButtonPressed: Boolean;
                function LeftButtonStroked: Boolean;
                function RightButtonStroked: Boolean;
                function CenterButtonStroked: Boolean;
                function ButtonReleased(Button: Word): Boolean;
                procedure Show;
                procedure Hide;
                procedure LoadShape(NumeFisier: String);
                procedure SetShape;
                procedure SetRange(Re: Rect);
                procedure SetPos(Point: Point2D);
                destructor Done;
                procedure CopyCoord;
                private
                 OldX,OldY : integer;
             END;

VAR
   Mouse : PTMouse;

IMPLEMENTATION

var R: Registers;

constructor TMouse.Init;
var
   pn : Point2D;
begin
    R.AX := 0;
    Intr($33, R);
    if R.AX = 0 then begin
     WriteLn('Error : THIS GAME REQUIRES A MOUSE !');
     Halt(1);
    end;
    with pn do begin x:=160;y:=100;end;
    SetPos(pn);
end;

function TMouse.X: Word;
begin
    R.AX := 3;
    Intr($33, R);
    X := R.CX;
    DeltaX := R.CX-OldX;
    OldX := R.CX;
end;

function TMouse.Y: Word;
begin
    R.AX := 3;
    Intr($33, R);
    Y := R.DX;
    DeltaY := R.DX-OldY;
    OldY := R.DX;
end;

function TMouse.LeftButtonPressed: Boolean;
begin
    R.AX := 3;
    Intr($33, R);
    LeftButtonPressed := (R.BX and 1) = 1;
end;

function TMouse.RightButtonPressed: Boolean;
begin
    R.AX := 3;
    Intr($33, R);
    RightButtonPressed := (R.BX div 2) mod 2 = 1;
end;

function TMouse.CenterButtonPressed: Boolean;
begin
    R.AX := 3;
    Intr($33, R);
    CenterButtonPressed := (R.BX div 4) mod 2 = 1;
end;

function TMouse.ButtonReleased(Button: Word): Boolean;
begin
    R.AX := $6;
    R.BX := Button;
    Intr($33, R);
    ButtonReleased := R.BX <> 0;
end;

function TMouse.LeftButtonStroked: Boolean;
var Bool: Boolean;
begin
    Bool := ButtonReleased(0);
    if LeftButtonPressed then begin
     repeat until ButtonReleased(0);
     LeftButtonStroked := True;
    end
    else LeftButtonStroked := False;
end;

function TMouse.RightButtonStroked: Boolean;
var Bool: Boolean;
begin
    Bool := ButtonReleased(1);
    if LeftButtonPressed then begin
     repeat until ButtonReleased(1);
     RightButtonStroked := True;
    end
    else RightButtonStroked := False;
end;

function TMouse.CenterButtonStroked: Boolean;
var Bool: Boolean;
begin
    Bool := ButtonReleased(2);
    if LeftButtonPressed then begin
     repeat until ButtonReleased(2);
     CenterButtonStroked := True;
    end
    else CenterButtonStroked := False;
end;

procedure TMouse.Show;
begin
    R.AX := $0001;
    Intr($33, R);
end;

procedure TMouse.Hide;
begin
    R.AX := $0002;
    Intr($33, R);
end;

procedure TMouse.LoadShape(NumeFisier: string);
var f: file;
begin
    Assign(f, NumeFisier);
    Reset(f, 1);
    BlockRead(f, Shape, 66);
    Close(f);
end;

procedure TMouse.SetShape;
begin
    with Shape do
    	begin
          R.BX := HotX;
          R.CX := HotY;
          R.ES := Seg(Data);
          R.DX := Ofs(Data);
          R.AX := 9;
          Intr($33, R);
      end
end;

procedure TMouse.SetRange(Re: Rect);
begin
	R.AX := 7;
 	R.CX := Re.P1.X;
	R.DX := Re.P2.X;
    Intr($33, R);
	R.AX := 8;
 	R.CX := Re.P1.Y;
	R.DX := Re.P2.Y;
    Intr($33, R);
end;

procedure TMouse.SetPos(Point: Point2D);
begin
    R.AX := 4;
    R.CX := Point.X;
    R.DX := Point.Y;
    Intr($33, R);
end;

procedure TMouse.CopyCoord;
begin
    P.X := X;
    P.Y := Y;
end;

destructor TMouse.Done;
begin
    Hide;
end;

BEGIN
END.