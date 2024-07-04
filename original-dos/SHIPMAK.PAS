program ship_maker;

uses space;

var s : ship;
    txt : string;
    i : integer;
    fship : file of ship;

begin

assign(fship,'c:\app\karg\fight\missions\ships.dat');
rewrite(fship);

with s do
     begin
     brf:='wall.brf';
     shape:='storm.s3d';
     sprite:='bord.spr';
     msprite:='pbord.spr';
     name:='StormWall';

     gadgets[0,1].x:=3;gadgets[0,1].y:=175;{data}
     gadgets[0,2].x:=260;gadgets[0,2].y:=140;{right screen}
     gadgets[0,3].x:=10;gadgets[0,3].y:=5;{left screen}
     gadgets[0,4].x:=10;gadgets[0,4].y:=150;{shld}
     gadgets[0,5].x:=3;gadgets[0,5].y:=3;{lradar}
     gadgets[0,6].x:=260;gadgets[0,6].y:=3;{rradar}

     gadgets[1,1].x:=10;gadgets[1,1].y:=10;{data}
     gadgets[1,2].x:=73;gadgets[1,2].y:=144;{right screen}
     gadgets[1,3].x:=200;gadgets[1,3].y:=144;{left screen}
     gadgets[1,4].x:=145;gadgets[1,4].y:=154;{shld}
     gadgets[1,5].x:=3;gadgets[1,5].y:=3;{lradar}
     gadgets[1,6].x:=260;gadgets[1,6].y:=3;{rradar}

     maxcarry:=7000;
     speed:=550;
     accel:=2;
     decel:=1;
     whatweapon:=1;
     multiple:=false;
     currentweight:=0;
     HullRU := 10;
     end;
write(fship,s);

with s do
     begin

     brf:='hell.brf';
     shape:='hell.s3d';
     sprite:='bordf.spr';
     msprite:='pbordf.spr';
     name:='HellRaiser';

     gadgets[0,1].x:=3;gadgets[0,1].y:=175;{data}
     gadgets[0,2].x:=260;gadgets[0,2].y:=140;{screen right}
     gadgets[0,3].x:=10;gadgets[0,3].y:=5;{screen left}
     gadgets[0,4].x:=10;gadgets[0,4].y:=150;{shld}
     gadgets[0,5].x:=3;gadgets[0,5].y:=3;{shld}
     gadgets[0,6].x:=260;gadgets[0,6].y:=3;{shld}

     gadgets[1,1].x:=143;gadgets[1,1].y:=176;{data - center screen}
     gadgets[1,2].x:=220;gadgets[1,2].y:=135;{screen right}
     gadgets[1,3].x:=58;gadgets[1,3].y:=135;{screen left}
     gadgets[1,4].x:=286;gadgets[1,4].y:=164;{shld}
     gadgets[1,5].x:=3;gadgets[1,5].y:=3;{shld}
     gadgets[1,6].x:=260;gadgets[1,6].y:=3;{shld}

     maxcarry:=3000;
     currentweight:=0;
     speed:=690;
     accel:=6;
     decel:=6;
     whatweapon:=1;
     multiple:=true;
     HullRU := 15;
     end;
write(fship,s);
close(fship);
end.