uses graphics,types3d;
begin
gfx := new(PApp_Graph,Init);
nework := new(PNewApp_3D,Init);
gfx^.initpath;
gfx^.vga256;
gfx^.loadpal('fight3.pal');
gfx^.setpal;

gfx^.NCircle(160,100,50,255,vga);
end.