program Transformation;
uses
    types3d,crt;
var
    fs : file of obj;
    fd : file of newobj;
    i,j : integer;
    n : newobj;
    o : obj;
    found : boolean;

begin
 clrscr;
 assign(fs,'c:\app\karg\fight\shapes\asr.shp');
 reset(fs);
 read(fs,o);
 close(fs);
 assign(fd,'c:\app\karg\fight\shapes\asr.s3d');
 rewrite(fd);
 n.pointsno:=0;

 write('Creating points...');
 for i:=1 to o.face do
     begin
      {for p1}
      found:=false;
      for j:=1 to n.pointsno do
          if (o.form[i].p1.x=n.points[j].x) and (o.form[i].p1.y=n.points[j].y) and
             (o.form[i].p1.z=n.points[j].z)
             then begin
                   found:=true;
                   break;
                  end;
      if not found
         then begin
               inc(n.pointsno);
               n.points[n.pointsno]:=o.form[i].p1;
              end;
      {for p2}
      found:=false;
      for j:=1 to n.pointsno do
          if (o.form[i].p2.x=n.points[j].x) and (o.form[i].p2.y=n.points[j].y) and
             (o.form[i].p2.z=n.points[j].z)
             then begin
                   found:=true;
                   break;
                  end;
      if not found
         then begin
               inc(n.pointsno);
               n.points[n.pointsno]:=o.form[i].p2;
              end;
      {for p3}
      found:=false;
      for j:=1 to n.pointsno do
          if (o.form[i].p3.x=n.points[j].x) and (o.form[i].p3.y=n.points[j].y) and
             (o.form[i].p3.z=n.points[j].z)
             then begin
                   found:=true;
                   break;
                  end;
      if not found
         then begin
               inc(n.pointsno);
               n.points[n.pointsno]:=o.form[i].p3;
              end;
      {for p4}
      found:=false;
      for j:=1 to n.pointsno do
          if (o.form[i].p4.x=n.points[j].x) and (o.form[i].p4.y=n.points[j].y) and
             (o.form[i].p4.z=n.points[j].z)
             then begin
                   found:=true;
                   break;
                  end;
      if not found
         then begin
               inc(n.pointsno);
               n.points[n.pointsno]:=o.form[i].p4;
              end;
    end;{creating points ok}
 writeln('ok.');
 writeln('Found ',n.pointsno,' points.');
 n.points[n.pointsno+1]:=o.core;
 write('Creating planes & remapping points...');

 n.faceno:=1;
 for i:=1 to o.face do
     begin
      for j:=1 to n.pointsno do
          if (o.form[i].p1.x=n.points[j].x) and (o.form[i].p1.y=n.points[j].y) and
             (o.form[i].p1.z=n.points[j].z)
             then begin
                   n.planes[n.faceno].p1:=j;
                   break;
                  end;
      for j:=1 to n.pointsno do
          if (o.form[i].p2.x=n.points[j].x) and (o.form[i].p2.y=n.points[j].y) and
             (o.form[i].p2.z=n.points[j].z)
             then begin
                   n.planes[n.faceno].p2:=j;
                   break;
                  end;
      for j:=1 to n.pointsno do
          if (o.form[i].p3.x=n.points[j].x) and (o.form[i].p3.y=n.points[j].y) and
             (o.form[i].p3.z=n.points[j].z)
             then begin
                   n.planes[n.faceno].p3:=j;
                   break;
                  end;
      for j:=1 to n.pointsno do
          if (o.form[i].p4.x=n.points[j].x) and (o.form[i].p4.y=n.points[j].y) and
             (o.form[i].p4.z=n.points[j].z)
             then begin
                   n.planes[n.faceno].p4:=j;
                   break;
                  end;
      n.planes[n.faceno].color:=o.form[i].color;
      n.planes[n.faceno].eyedist:=0;
      inc(n.faceno);
     end;
 dec(n.faceno);
 writeln('Point Remapping ok.');
 write('Performing checkings...');
 if n.faceno=o.face
    then begin
          writeln('Check ok.');
         end
    else writeln('Check failed.',n.faceno,' ',o.face);
 writeln('Writing results to file...');
 write(fd,n);
 close(fd);
 writeln('Transformation ok.');
end.