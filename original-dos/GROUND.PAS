   GroundArray = array[1..128,1..128] of byte;
   PGround = ^Ground;
    Ground = object(IntoSpace)
           GA : ^GroundArray;
           constructor Init(fname : Str20);{ussualy,will be the 50th sprite of Gfx}
           procedure Strategy(var status : byte);virtual;
           procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
           destructor Done;virtual;
           end;


constructor Ground.Init;
var f     : file;
    i,j   : integer;
    count : integer;
begin
 X[1]       := 20;
 look       := origin;
 whatdmg    := 0;
 name       := 'GROUND';
 dispose_me := false;
 new(GA);
 assign(f,imgpath+fname);reset(f,1);seek(f,2);blockread(f,GA^,16384);close(f);;
 AllObjects[90]^.FaceNo   := 81;
 AllObjects[90]^.PointsNo := 100;
 for i:=1 to 9 do
     for j:=1 to 9 do
         begin
          inc(count);
          AllObjects[90]^.Planes[count].p1 := j;
          AllObjects[90]^.Planes[count].p2 := j+1;
          AllObjects[90]^.Planes[count].p3 := j*15+1;
          AllObjects[90]^.Planes[count].p4 := j*15+1;
         end;
end;

procedure Ground.Strategy;
begin
end;

procedure Ground.Draw;
var
   x256,y256,x512,y512     : integer;
   i,j,ang                 : integer;
   pointscount,planescount : integer;

begin
 if fromlook.x<0 then x256 := (fromlook.x+MaxInt) div 256
    else x256 := fromlook.x div 256;
 if fromlook.z<0 then y256 := (fromlook.z+MaxInt) div 256
    else y256 := fromlook.z div 256;
 pointscount := 0;
 planescount := 0;
 for i := 1 to 10 do
     for j := 1 to 10 do
         begin
          look.x := fromlook.x+(5-i)*256;
          look.z := fromlook.z+(5-j)*256;
          look.y := GA^[x256+5-i,y256+5-j];
          ang := nework^.AngleVPV(fromlook,fromvk,look);
          if (ang<60) or (ang>300)
             then begin
                   inc(pointscount);
                   nework^.rotwork[pointscount] := look;
                   AllObjects[90]^.points[pointscount] := look;
                   if (i<10) and (j<10)
                      then begin
                            inc(planescount);
                            AllObjects[90]^.Planes[planescount].p1 := (i-1)*10+j;
                            AllObjects[90]^.Planes[planescount].p2 := (i-1)*10+j+1;
                            AllObjects[90]^.Planes[planescount].p3 := i*10+j;
                            AllObjects[90]^.Planes[planescount].p4 := i*10+j+1;
                            AllObjects[90]^.Planes[planescount].color := GA^[x256+5-i,y256+5-j];
                           end;
                  end;
         end;

 nework^.DepthSort(AllObjects[90],fromlook,fromlook);
 nework^.Inverter(fromvi,fromvj,fromvk);
 nework^.ProLook(AllObjects[90],fromlook,fromlook);

 for i:=1 to AllObjects[90]^.faceno do
     begin
      Gfx^.DrawPoly(
      nework^.ProWork^[AllObjects[90]^.planes[i].p1].x,nework^.ProWork^[AllObjects[90]^.planes[i].p1].y,
      nework^.ProWork^[AllObjects[90]^.planes[i].p2].x,nework^.ProWork^[AllObjects[90]^.planes[i].p2].y,
      nework^.ProWork^[AllObjects[90]^.planes[i].p3].x,nework^.ProWork^[AllObjects[90]^.planes[i].p3].y,
      nework^.ProWork^[AllObjects[90]^.planes[i].p4].x,nework^.ProWork^[AllObjects[90]^.planes[i].p4].y,
      AllObjects[90]^.planes[i].color,vaddr);
     end;

end;

destructor Ground.Done;
begin
 dispose(GA);
end;

