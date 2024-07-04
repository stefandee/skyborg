PROGRAM
       MAKEDMG;
USES
    TYPES3D,CRT,SPACE;

const
     d = 1000;
var
   F  : File;
   KP : KeyPoints;

BEGIN
 clrscr;
 writeln(sizeof(KP));
 {airport}
 with KP do
      begin
       with AKP[1] do begin code := 9;damage := d;pos.x:=130;pos.y:=70;pos.z:=-25;radius:=50;end;{hangar}
       with AKP[2] do begin code := 8;damage := d;pos.x:=-70;pos.y:=-150;pos.z:=0;radius:=20;end;{track}
       with AKP[3] do begin code := 8;damage := d;pos.x:=-70;pos.y:=-50;pos.z:=0;radius:=20;end;{track}
       with AKP[4] do begin code := 8;damage := d;pos.x:=-70;pos.y:=150;pos.z:=0;radius:=20;end;{track}
       with AKP[5] do begin code := 8;damage := d;pos.x:=70;pos.y:=-150;pos.z:=0;radius:=20;end;{track}
       with AKP[6] do begin code := 8;damage := d;pos.x:=70;pos.y:=-50;pos.z:=0;radius:=20;end;{track}
       with AKP[7] do begin code := 8;damage := d;pos.x:=70;pos.y:=150;pos.z:=0;radius:=20;end;{track}
       with AKP[8] do begin code := 1;damage := d;pos.x:=170;pos.y:=-35;pos.z:=-80;radius:=35;end;{comm}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'airport.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {mig25}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=15;pos.z:=2;radius:=15;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-15;pos.z:=1;radius:=6;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=-3;pos.y:=8;pos.z:=1;radius:=6;end;{lcannon}
       with AKP[4] do begin code := 3;damage := d;pos.x:=3;pos.y:=8;pos.z:=1;radius:=6;end;{rcannon}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=-13;pos.z:=0;radius:=16;end;{hull}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=2;pos.z:=4;radius:=13;end;{bay}
       with AKP[7] do begin code := 6;damage := d;pos.x:=-15;pos.y:=2;pos.z:=1;radius:=16;end;{lrocket}
       with AKP[8] do begin code := 7;damage := d;pos.x:=15;pos.y:=2;pos.z:=1;radius:=16;end;{rrocket}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'mig25.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {f22}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=16;pos.z:=0;radius:=15;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-16;pos.z:=0;radius:=6;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=-7;pos.y:=-3;pos.z:=0;radius:=8;end;{lcannon}
       with AKP[4] do begin code := 3;damage := d;pos.x:=7;pos.y:=-3;pos.z:=0;radius:=8;end;{rcannon}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=-8;pos.z:=-4;radius:=12;end;{hull}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=3;pos.z:=0;radius:=13;end;{bay}
       with AKP[7] do begin code := 6;damage := 140;pos.x:=-12;pos.y:=12;pos.z:=0;radius:=14;end;{lrocket}
       with AKP[8] do begin code := 7;damage := 140;pos.x:=12;pos.y:=12;pos.z:=0;radius:=14;end;{rrocket}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'f22.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {transport}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := 200;pos.x:=0;pos.y:=30;pos.z:=-5;radius:=13;end;{engine}
       with AKP[2] do begin code := 1;damage := 200;pos.x:=0;pos.y:=-40;pos.z:=0;radius:=6;end;{comm/radar}
       with AKP[3] do begin code := 4;damage := 200;pos.x:=0;pos.y:=-30;pos.z:=-10;radius:=9;end;{hull}
       with AKP[4] do begin code := 5;damage := 200;pos.x:=0;pos.y:=-17;pos.z:=0;radius:=10;end;{bay}
       with AKP[5] do begin code := 10;damage := 200;pos.x:=-24;pos.y:=0;pos.z:=0;radius:=9;end;{wing}
       with AKP[6] do begin code := 10;damage := 200;pos.x:=24;pos.y:=0;pos.z:=0;radius:=10;end;{wing}
       IKP := 6;
       CKP := 1;
      end;
 assign(f,'tranport.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {f29retal}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=19;pos.z:=-2;radius:=10;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-19;pos.z:=0;radius:=3;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=-5;pos.y:=-6;pos.z:=0;radius:=9;end;{lcannon}
       with AKP[4] do begin code := 3;damage := d;pos.x:=5;pos.y:=-6;pos.z:=0;radius:=9;end;{rcannon}
       with AKP[5] do begin code := 4;damage := d;pos.x:=13;pos.y:=0;pos.z:=-4;radius:=10;end;{hull}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=4;pos.z:=0;radius:=13;end;{bay}
       with AKP[7] do begin code := 6;damage := 140;pos.x:=-17;pos.y:=10;pos.z:=0;radius:=9;end;{lrocket}
       with AKP[8] do begin code := 7;damage := 140;pos.x:=17;pos.y:=10;pos.z:=0;radius:=9;end;{rrocket}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'f29retal.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {delta}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=26;pos.z:=2;radius:=13;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-13;pos.z:=0;radius:=5;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=-6;pos.y:=6;pos.z:=7;radius:=9;end;{lcannon}
       with AKP[4] do begin code := 3;damage := d;pos.x:=6;pos.y:=6;pos.z:=7;radius:=9;end;{rcannon}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=9;pos.z:=0;radius:=10;end;{hull}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=-4;pos.z:=0;radius:=13;end;{bay}
       with AKP[7] do begin code := 6;damage := 140;pos.x:=-13;pos.y:=13;pos.z:=2;radius:=13;end;{lrocket}
       with AKP[8] do begin code := 7;damage := 140;pos.x:=13;pos.y:=13;pos.z:=2;radius:=13;end;{rrocket}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'delta.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {b115}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=30;pos.z:=-2;radius:=15;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-30;pos.z:=0;radius:=5;end;{comm/radar}
       with AKP[3] do begin code := 5;damage := d;pos.x:=-15;pos.y:=-10;pos.z:=1;radius:=12;end;{lbay}
       with AKP[4] do begin code := 5;damage := d;pos.x:=15;pos.y:=-10;pos.z:=1;radius:=12;end;{rbay}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=-27;pos.z:=-2;radius:=13;end;{hull}
       with AKP[6] do begin code := 6;damage := 140;pos.x:=-35;pos.y:=10;pos.z:=0;radius:=15;end;{lrocket}
       with AKP[7] do begin code := 7;damage := 140;pos.x:=35;pos.y:=10;pos.z:=0;radius:=15;end;{rrocket}
       with AKP[8] do begin code := 10;damage := 140;pos.x:=-25;pos.y:=0;pos.z:=-1;radius:=13;end;{lrocket}
       with AKP[9] do begin code := 10;damage := 140;pos.x:=25;pos.y:=0;pos.z:=-1;radius:=13;end;{rrocket}
       IKP := 9;
       CKP := 1;
      end;
 assign(f,'b115.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {b52}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=40;pos.z:=0;radius:=16;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-30;pos.z:=2;radius:=6;end;{comm/radar}
       with AKP[3] do begin code := 5;damage := d;pos.x:=23;pos.y:=-11;pos.z:=8;radius:=12;end;{lbay}
       with AKP[4] do begin code := 5;damage := d;pos.x:=-23;pos.y:=-11;pos.z:=8;radius:=12;end;{rbay}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=-28;pos.z:=-2;radius:=15;end;{hull}
       with AKP[6] do begin code := 6;damage := 140;pos.x:=-64;pos.y:=8;pos.z:=1;radius:=16;end;{lrocket}
       with AKP[7] do begin code := 7;damage := 140;pos.x:=64;pos.y:=8;pos.z:=1;radius:=16;end;{rrocket}
       with AKP[8] do begin code := 10;damage := 140;pos.x:=-36;pos.y:=0;pos.z:=0;radius:=36;end;{wing}
       with AKP[9] do begin code := 10;damage := 140;pos.x:=36;pos.y:=0;pos.z:=0;radius:=36;end;{wing}
       IKP := 9;
       CKP := 1;
      end;
 assign(f,'b52.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {bt100}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=-10;pos.y:=30;pos.z:=-5;radius:=15;end;{lbengine}
       with AKP[2] do begin code := 0;damage := d;pos.x:=10;pos.y:=30;pos.z:=-5;radius:=15;end;{lbengine}
       with AKP[3] do begin code := 0;damage := d;pos.x:=-19;pos.y:=-2;pos.z:=0;radius:=10;end;{lfengine}
       with AKP[4] do begin code := 0;damage := d;pos.x:=19;pos.y:=-2;pos.z:=0;radius:=10;end;{lfengine}
       with AKP[5] do begin code := 1;damage := d;pos.x:=-5;pos.y:=-30;pos.z:=-5;radius:=7;end;{comm/radar}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=0;pos.z:=0;radius:=17;end;{bay}
       with AKP[7] do begin code := 4;damage := d;pos.x:=0;pos.y:=-28;pos.z:=-5;radius:=15;end;{hull}
       with AKP[8] do begin code := 10;damage := 140;pos.x:=-36;pos.y:=-13;pos.z:=0;radius:=36;end;{wing}
       with AKP[9] do begin code := 10;damage := 140;pos.x:=36;pos.y:=-13;pos.z:=0;radius:=36;end;{wing}
       IKP := 9;
       CKP := 1;
      end;
 assign(f,'bt100.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {hell}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=-20;pos.z:=-3;radius:=15;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=35;pos.z:=0;radius:=3;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=-10;pos.y:=20;pos.z:=2;radius:=9;end;{lcannon}
       with AKP[4] do begin code := 3;damage := d;pos.x:=10;pos.y:=20;pos.z:=2;radius:=9;end;{rcannon}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=18;pos.z:=-6;radius:=12;end;{hull}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=0;pos.z:=0;radius:=16;end;{bay}
       with AKP[7] do begin code := 6;damage := 140;pos.x:=-32;pos.y:=0;pos.z:=6;radius:=9;end;{lrocket}
       with AKP[8] do begin code := 7;damage := 140;pos.x:=32;pos.y:=0;pos.z:=6;radius:=9;end;{rrocket}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'hell.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {storm}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=20;pos.z:=-3;radius:=16;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-25;pos.z:=0;radius:=6;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=-10;pos.y:=-20;pos.z:=0;radius:=9;end;{lcannon}
       with AKP[4] do begin code := 3;damage := d;pos.x:=10;pos.y:=-20;pos.z:=0;radius:=9;end;{rcannon}
       with AKP[5] do begin code := 4;damage := d;pos.x:=0;pos.y:=-20;pos.z:=-2;radius:=12;end;{hull}
       with AKP[6] do begin code := 5;damage := d;pos.x:=0;pos.y:=0;pos.z:=0;radius:=16;end;{bay}
       with AKP[7] do begin code := 6;damage := 140;pos.x:=-18;pos.y:=0;pos.z:=2;radius:=15;end;{lrocket}
       with AKP[8] do begin code := 7;damage := 140;pos.x:=18;pos.y:=0;pos.z:=2;radius:=15;end;{rrocket}
       with AKP[9] do begin code := 10;damage := 140;pos.x:=-40;pos.y:=0;pos.z:=4;radius:=20;end;{lrocket}
       with AKP[10] do begin code := 10;damage := 140;pos.x:=40;pos.y:=0;pos.z:=4;radius:=20;end;{rrocket}
       IKP := 10;
       CKP := 1;
      end;
 assign(f,'storm.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {ft20}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=0;pos.z:=0;radius:=15;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=3;pos.z:=-3;radius:=5;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=0;pos.y:=-18;pos.z:=-7;radius:=9;end;{cannon}
       with AKP[4] do begin code := 5;damage := d;pos.x:=0;pos.y:=9;pos.z:=2;radius:=5;end;{bay}
       with AKP[5] do begin code := 6;damage := 140;pos.x:=-5;pos.y:=0;pos.z:=-4;radius:=13;end;{lrocket}
       with AKP[6] do begin code := 7;damage := 140;pos.x:=5;pos.y:=0;pos.z:=-4;radius:=13;end;{rrocket}
       with AKP[7] do begin code := 12;damage := 140;pos.x:=-7;pos.y:=-8;pos.z:=5;radius:=14;end;{wheel}
       with AKP[8] do begin code := 12;damage := 140;pos.x:=7;pos.y:=0;pos.z:=5;radius:=14;end;{wheel}
       with AKP[9] do begin code := 12;damage := 140;pos.x:=-7;pos.y:=10;pos.z:=5;radius:=14;end;{wheel}
       with AKP[10] do begin code := 12;damage := 140;pos.x:=7;pos.y:=10;pos.z:=5;radius:=14;end;{wheel}
       IKP := 10;
       CKP := 1;
      end;
 assign(f,'ft20.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {u16}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=10;pos.z:=3;radius:=15;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=-7;pos.z:=1;radius:=5;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=0;pos.y:=-25;pos.z:=-8;radius:=9;end;{cannon}
       with AKP[4] do begin code := 5;damage := d;pos.x:=0;pos.y:=3;pos.z:=6;radius:=5;end;{bay}
       with AKP[5] do begin code := 12;damage := 140;pos.x:=-8;pos.y:=-8;pos.z:=3;radius:=14;end;{wheel}
       with AKP[6] do begin code := 12;damage := 140;pos.x:=8;pos.y:=-8;pos.z:=3;radius:=14;end;{wheel}
       with AKP[7] do begin code := 12;damage := 140;pos.x:=-8;pos.y:=8;pos.z:=3;radius:=14;end;{wheel}
       with AKP[8] do begin code := 12;damage := 140;pos.x:=8;pos.y:=8;pos.z:=3;radius:=14;end;{wheel}
       IKP := 8;
       CKP := 1;
      end;
 assign(f,'u16.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {hound}
 with KP do
      begin
       with AKP[1] do begin code := 0;damage := d;pos.x:=0;pos.y:=-10;pos.z:=3;radius:=16;end;{engine}
       with AKP[2] do begin code := 1;damage := d;pos.x:=0;pos.y:=4;pos.z:=-3;radius:=5;end;{comm/radar}
       with AKP[3] do begin code := 2;damage := d;pos.x:=0;pos.y:=15;pos.z:=-3;radius:=9;end;{cannon}
       with AKP[4] do begin code := 5;damage := d;pos.x:=0;pos.y:=0;pos.z:=4;radius:=10;end;{bay}
       with AKP[5] do begin code := 12;damage := 140;pos.x:=-7;pos.y:=7;pos.z:=6;radius:=14;end;{wheel}
       with AKP[6] do begin code := 12;damage := 140;pos.x:=7;pos.y:=7;pos.z:=6;radius:=14;end;{wheel}
       with AKP[7] do begin code := 12;damage := 140;pos.x:=-7;pos.y:=-8;pos.z:=6;radius:=14;end;{wheel}
       with AKP[8] do begin code := 12;damage := 140;pos.x:=7;pos.y:=-8;pos.z:=6;radius:=14;end;{wheel}
       IKP := 10;
       CKP := 1;
      end;
 assign(f,'hound.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
 {tree}
 with KP do
      begin
       with AKP[1] do begin code := 8;damage := d;pos.x:=0;pos.y:=0;pos.z:=0;radius:=16;end;{ground}
       IKP := 1;
       CKP := 1;
      end;
 assign(f,'tree.dmg');rewrite(f,1);blockwrite(f,KP,sizeof(KP));close(F);
END.
