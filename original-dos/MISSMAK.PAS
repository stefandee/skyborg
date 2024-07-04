PROGRAM Mission_Maker;
USES
    SPACE,CRT,pilot;
VAR
   F : file of Mission;
   i : integer;
BEGIN
 assign(f,'e:\work\fight\missions\missions.dat');
 rewrite(f);
 clrscr;
 write(sizeof(intospace),' ',round(250000/sizeof(intospace)));
 {first mission}
 with Crt_Mission do
      begin
       BattleStr := 'Threat!';
       BattleNr  := 1;
       MissionNr := 1;
       name:='Falling Down';skytype := 84;gndtype := 241;
       shapes[1]:='tranport.s3d';shapes[2]:='mig25.s3d';shapes[3]:='f22.s3d';
       shapes[4]:='airport.s3d';shapes[5]:='tree01.s3d';shapes[6]:='tree02.s3d';
       shapes[7]:='tree03.s3d';shapes[8]:='tree04.s3d';
       shapes[9]:='smoke02.s3d';
       shapes[10]:='smoke01.s3d';
       shapes[11]:='smoke03.s3d';
       shapes[12]:='asr.s3d';
       dmg[1]:='tree.dmg';dmg[2]:='tranport.dmg';dmg[3]:='mig25.dmg';
       dmg[4]:='f22.dmg';dmg[5]:='airport.dmg';
       TreeCnt := 5;
       with Trees[1] do begin with pos do begin x:=-12020;z:=12500;y:=10;end; shapeno := 5;end;
       for i:=2 to 5 do
           with Trees[i] do begin with pos do begin x:=random(65535);z:=random(65535);y:=10;end; shapeno := 5+random(4);end;
       micro[1]:='m1air.spr';micro[2]:='m1ant.spr';micro[3]:='m1rdr.spr';
       micro[4]:='m1trn.spr';micro[5]:='m1fgt.spr';micro[6]:='m1tanx.spr';
       micro[7]:='m1my.spr';
       for i:=1 to 10 do MiniBrief[i] := '            ';
       MiniBrief[1] := '***BRIEF*** ';
       MiniBrief[2] := 'Destroy the ';
       MiniBrief[3] := 'Transport   ';
       MiniBrief[4] := 'Flight      ';

       MaxMicro:=7;MaxMap:=6;MaxShapes:=12;MaxDmg:=5;MaxGoals := 1;
       failpos:=0;winpos:=0;
       Promotion := 255;
       MedalAward := 255;

       with Goals[1] do begin GoalType := 1;GoalSubj := 'TRN-AA1';
                              GoalComm[1] := 'Transport was shut down...';
                              GoalComm[2] := 'You did your job, it is ';
                              GoalComm[3] := 'marines turn now . You may';
                              GoalComm[4] := 'proceed with the secondary';
                              GoalComm[5] := 'objective or you may come home';
                              GoalComm[6] := 'and prepare the next mission.';
                              GoalCommL := 6;
                              GoalImpt := 1;Done := false;end;
       with MyCraft do begin x:=-12000;z:=12500;y:=150;end;
       with Map[1] do
            begin
             briefile:='txt001.brf';
             name:='transport flight';
             dmgno := 2;
             FlightInd := 'TRN-AA1';
             hullru := 3;
             micro:=4;
             shapeno:=1;
             show:=true;
             x[1]:=512;{transport}
             x[2]:=1;{is target}
             x[3]:=3;{follow the waypoints}
             x[4]:=2;
             x[5]:=-12000;x[6]:=12000;x[7]:=10;
             x[8]:=0;x[9]:=0;x[10]:=5000;
             x[11]:=24000;x[12]:=-24000;x[13]:=300;
             Points:=1500;
             with angst do begin x:=0;y:=0;z:=0;end;
             with angvar do begin x:=5;y:=5;z:=5;end;
             zfact:=50;
            end;
       with Map[2] do
            begin
             briefile:='';
             name:='mig25';
             dmgno := 3;
             FlightInd := 'FGT-AB1';
             micro:=5;
             shapeno:=2;
             hullru := 5;
             show:=false;
             x[1]:=514;{fighter}
             x[2]:=0;{isn't target}
             x[3]:=1;{follow the waypoints then hunt}
             x[4]:=2;
             x[5]:=-12000;x[6]:=12100;x[7]:=10;
             x[8]:=0;x[9]:=0;x[10]:=5050;
             x[11]:=24000;x[12]:=-23900;x[13]:=300;
             with angst do begin x:=0;y:=0;z:=0;end;
             with angvar do begin x:=5;y:=5;z:=5;end;
             Points := 100;
             zfact:=0;
            end;
        with Map[3] do
            begin
             briefile:='';
             name:='f22';
             dmgno := 4;
             FlightInd := 'FGT-AB2';
             hullru := 5;
             micro:=5;
             shapeno:=3;
             show:=false;
             x[1]:=514;{fighter}
             x[2]:=0;{is target}
             x[3]:=1;{follow the waypoints then hunt}
             x[4]:=2;
             x[5]:=-12070;x[6]:=12000;x[7]:=10;
             x[8]:=0;x[9]:=0;x[10]:=4950;
             x[11]:=23930;x[12]:=-24000;x[13]:=300;
             with angst do begin x:=0;y:=0;z:=0;end;
             with angvar do begin x:=5;y:=5;z:=5;end;
             Points := 100;
             zfact:=0;
            end;
        with Map[4] do
            begin
             briefile:='';
             name:='f22';
             dmgno := 4;
             hullru := 5;
             FlightInd := 'FGT-AB3';
             micro:=5;
             shapeno:=3;
             show:=false;
             x[1]:=514;{fighter}
             x[2]:=0;{is target}
             x[3]:=1;{follow the waypoints then hunt}
             x[4]:=2;
             x[5]:=-11930;x[6]:=12000;x[7]:=10;
             x[8]:=0;x[9]:=50;x[10]:=5000;
             x[11]:=24070;x[12]:=-24000;x[13]:=300;
             with angst do begin x:=0;y:=0;z:=0;end;
             with angvar do begin x:=5;y:=5;z:=5;end;
             Points := 100;
             zfact:=0;
            end;
        with Map[5] do
            begin
             briefile:='txt002.brf';
             name:='Airport';
             hullru := 1;
             dmgno := 5;
             FlightInd := 'APT-001';
             micro:=1;
             shapeno:=4;
             show:=true;
             zfact:=+850;
             x[1]:=256;
             x[2]:=0;
             x[3]:=0;
             x[5]:=-12020;x[6]:=12000;x[7]:=0;
             Points := 10;
             with angst do begin x:=0;y:=70;z:=120;end;
             with angvar do begin x:=10;y:=0;z:=0;end;
            end;
        with Map[6] do
            begin
             briefile:='txt003.brf';
             name:='Airport';
             dmgno := 5;
             hullru := 1;
             FlightInd := 'APT-002';
             shapeno:=4;
             micro:=1;
             zfact:=850;
             show:=true;
             x[1]:=256;{airport}
             x[2]:=0;{is target}
             x[3]:=0;{follow the waypoints then hunt}
             x[5]:=24000;x[6]:=-24000;x[7]:=0;
             with angst do begin x:=0;y:=70;z:=120;end;
             with angvar do begin x:=10;y:=0;z:=0;end;
             Points := 10;
            end;
      end;
 write(f,Crt_Mission);
 close(f);
END.
