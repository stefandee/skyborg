uses Visions,Graphics;

var
   g : PApp_Graph;
   m : PApp_MenuVert;
begin
 g:=new(PApp_Graph,Init);
 with g^ do
      begin
       Vga256;
       InitVScreen;
       InitPath;
       LoadPal('menupal4');SetPal;
       LoadFNt('micro2.fnt',6);
      end;

end.