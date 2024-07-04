program weapon_create;

uses space;

var add : gun;
    fweapon : file of gun;

begin

assign(fweapon,'c:\app\karg\fight\missions\weapons.dat');
rewrite(fweapon);
seek(fweapon,filesize(fweapon));

with add do
     begin
     name:='PLASMA LAUNCHER';
     msprite:='GUN03.SPR';
     sprite:='GUN11.spr';
     brf:='plasma.brf';
     maxammo:=50;
     currentammo:=0;
     weight:=1000;
     ammoweight:=3;
     DrainedRU:=6;
     get:=false;
     end;
write(fweapon,add);

with add do
     begin
     name:='PARTICLE GUN';
     sprite:='GUN12.SPR';
     msprite:='GUN01.SPR';
     brf:='part.brf';
     maxammo:=100;
     currentammo:=110;
     weight:=100;
     ammoweight:=1;
     DrainedRU:=10;
     get:=true;
     end;
write(fweapon,add);


with add do
     begin
     name:='LASER CANNON';
     sprite:='GUN13.SPR';
     msprite:='GUN02.SPR';
     brf:='laser.brf';
     maxammo:=0;
     currentammo:=0;
     weight:=2000;
     ammoweight:=0;
     DrainedRU:=4;
     get:=true;
     end;
write(fweapon,add);

with add do
     begin
     name:='SONIC DISRUPTOR';
     sprite:='GUN14.SPR';
     msprite:='GUN06.SPR';
     brf:='sonic.brf';
     maxammo:=5;
     currentammo:=0;
     weight:=200;
     ammoweight:=10;
     DrainedRU:=12;
     get:=false;
     end;
write(fweapon,add);

with add do
     begin
     name:='PROTON THROWER';
     sprite:='GUN15.SPR';
     msprite:='GUN07.SPR';
     brf:='proton.brf';
     maxammo:=25;
     currentammo:=0;
     weight:=1500;
     ammoweight:=10;
     DrainedRU:=8;
     get:=false;
     end;
write(fweapon,add);

with add do
     begin
     name:='ANTIMATTER ROCKETS';
     sprite:='GUN16.SPR';
     msprite:='GUN04.SPR';
     brf:='anti.brf';
     maxammo:=5;
     currentammo:=0;
     weight:=300;
     ammoweight:=500;
     DrainedRU:=15;
     get:=false;
     end;
write(fweapon,add);

with add do
     begin
     name:='ATOMIC HEADS';
     sprite:='GUN17.SPR';
     msprite:='GUN05.SPR';
     brf:='atomic.brf';
     maxammo:=2;
     currentammo:=0;
     weight:=300;
     ammoweight:=5000;
     DrainedRU:=100;
     get:=false;
     end;
write(fweapon,add);

close(fweapon);
end.
