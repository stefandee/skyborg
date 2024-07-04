program
       Transformer;

uses
    types3d,dos;
{from old s3d to new s3d}

var
   fs ,fd : file;
   O      : NewObj;
   ts     : SearchRec;
begin
 FindFirst('c:\app\karg\fight\shapes\*.s3d',$3f,ts);
 while doserror=0 do
       begin
        assign(fs,'c:\app\karg\fight\shapes\'+ts.name);
        reset(fs,1);
        blockread(fs,o.Points,6*100);
        blockread(fs,o.Planes,50*9);
        blockread(fs,o.FaceNo,1);
        blockread(fs,o.PointsNo,1);
        close(fs);

        assign(fd,'c:\app\karg\fight\shapes\'+ts.name);
        reset(fd,1);
        blockwrite(fd,o,sizeof(o));
        close(fd);
        FindNext(ts);
       end;
end.