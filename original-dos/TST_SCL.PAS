uses
    graphics;

{$L scale.obj} 	        { Link in Object file }
{$F+} 				{ force calls to be 'far'}
procedure Scale(X,Y,DW,DY,SW,SH : integer;Bitmap : pointer);external;
{$F-}

var
   g : PApp_Graph;

begin
 g := new(PApp_Graph,Init);
 g^.Vga256;
 g^.InitVScreen;
 g^.InitPath;
 g^.LoadPal('fight3.pal');
 g^.SetPal;
 g^.LoadSpr('expl15.spr',1);
 g^.cls(0,vaddr);
 g^.Scalespr(1,10,10,200,200);
 g^.flip;
 readln;
end.