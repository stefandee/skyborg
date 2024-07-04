constructor Sky.Init;
begin
end;

procedure Sky.Draw;
var i,a,a1,a2,a3,a4 : integer;
    look1,look2,look3,look4,med : point3d;
begin
 nework^.Inverter(fromvi,fromvj,fromvk);
 for i := 1 to AllObjects[90]^.faceno do
     begin

      look1.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].x;
      look1.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].y;
      look1.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].z;

      look2.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].x;
      look2.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].y;
      look2.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].z;

      look3.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].x;
      look3.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].y;
      look3.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].z;

      look4.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].x;
      look4.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].y;
      look4.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].z;
      {
      med.x := (AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].x+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].x+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].x+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].x) div 4+fromlook.x;
      med.y := (AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].y+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].y+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].y+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].y) div 4+fromlook.y;
      med.z := (AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].z+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].z+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].z+
               AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].z) div 4+fromlook.z;

      a := nework^.RealAngleVPV(fromlook,fromvk,med);
      }
      a1 := nework^.RealAngleVPV(fromlook,fromvk,look1);
      a2 := nework^.RealAngleVPV(fromlook,fromvk,look2);
      a3 := nework^.RealAngleVPV(fromlook,fromvk,look3);
      a4 := nework^.RealAngleVPV(fromlook,fromvk,look4);

      if (a1<120) or (a1>240) or (a2<120) or (a2>240) or (a3<120) or (a3>240)
         or (a4<120) or (a4>240)
         then begin
               {look.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].x;
               look.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].y;
               look.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].z;}
               nework^.ProLookPoint(fromlook,look1);
               ProPoints[i,1] := nework^.ProWork^[1];
               {
               look.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].x;
               look.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].y;
               look.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].z;}
               nework^.ProLookPoint(fromlook,look2);
               ProPoints[i,2] := nework^.ProWork^[1];
               {
               look.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].x;
               look.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].y;
               look.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].z;}
               nework^.ProLookPoint(fromlook,look3);
               ProPoints[i,3] := nework^.ProWork^[1];
               {
               look.x := fromlook.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].x;
               look.y := fromlook.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].y;
               look.z := fromlook.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].z;}
               nework^.ProLookPoint(fromlook,look4);
               ProPoints[i,4] := nework^.ProWork^[1];
               Gfx^.DrawPoly(
                ProPoints[i,1].x,ProPoints[i,1].y,
                ProPoints[i,2].x,ProPoints[i,2].y,
                ProPoints[i,3].x,ProPoints[i,3].y,
                ProPoints[i,4].x,ProPoints[i,4].y,
                Crt_Mission.skytype+i,vaddr)
              end;
     end;
end;

procedure Sky.Strategy;
begin
end;

destructor Sky.Done;
begin
end;
