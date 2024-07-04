 Crt_Pilot.LoadFirst;
 Crt_Pilot.LoadMission;
 {
 assign(fmis,missionpath+'missions.dat');reset(fmis);read(fmis,Crt_Mission);close(fmis);
 }
 Snd^.LoadSound('record1.wav',1);
 {load first ship info's}
 assign(fship,missionpath+'ships.dat');reset(fship);read(fship,crt_ship);
 {init desktop ... this should be make with pointers like TV collection...}
 DeskTop[2]:=New(PApp_View,Init('Exit','exit.spr',0,0,exitgame));
 DeskTop[3]:=New(PApp_View,Init('Start','start.spr',160,0,startgame));
 DeskTop[4]:=New(PApp_Vol,Init('Volume','volume.spr','volcur.spr',80,0,setvol));
 DeskTop[5]:=New(PApp_View,Init('Credits','querry.spr',240,0,querry));
 App_Win := New(PApp_Window,Init('TaskBar',0,180,319,199));
 App_Win^.InsertItem(New(PApp_Btn2,Init('Start',3,185,6,startgame)));
 App_Win^.InsertItem(New(PApp_Btn2,Init('Credits',31,185,6,querry)));
 App_Win^.InsertItem(New(PApp_Btn2,Init('Exit',67,185,6,exitgame)));
 App_Win^.InsertItem(New(PApp_View,Init('','bar.spr',0,180,cmNoAction)));
 DeskTop[8]:=App_Win;
 DeskTop[6]:=New(PApp_Group,Init('MAIN',50,95,220,100));

 DeskTop[10]:=New(PApp_Group,Init('Choose Ship',80,90,160,100));
 assign(fship,missionpath+'ships.dat');reset(fship);
 for i:=1 to 2 do
     begin
      read(fship,crt_ship);
      with Crt_Ship do App_Aux:=New(PApp_Info,Init(name,brf,msprite,shape,80,75,10,21,10+i,scale));
      DeskTop[10]^.InsertItem(App_Aux);
     end;

 DeskTop[21]:=New(PApp_GroupInc,Init('Choose Guns',90,100,140,90));
 assign(fgun,missionpath+'weapons.dat');reset(fgun);
 for i:=1 to 7 do
     begin
      read(fgun,gun_aux[i]);
      crt_ship.carry[i]:=gun_aux[i];
      with Gun_Aux[i] do App_Aux:=New(PApp_Info,Init(name,brf,msprite,'',130,110,8,20,15+i,scale));
      DeskTop[21]^.InsertItem(App_Aux);
     end;
 close(fgun);

 DeskTop[17]:=New(PApp_Info,Init('Help','help.brf','helpkeys.spr','',120,90,10,24,none,scale));
 DeskTop[11]:=New(PApp_Info,Init('WarBrief','warbrief.brf','globe.spr','',120,80,14,20,none,scale));
 {create pilot group}
 DeskTop[12]:=New(PApp_Group,Init('Pilot',80,90,160,100));
 {make the window for briefing = background + missionbrief}
 App_Win := New(PApp_Window,Init('Brief',80,75,160,100));
 App_Aux:=New(PApp_Mission,Init('Mission Brief',80,75,160,100));
 App_Win^.InsertItem(App_Aux);
 {App_Win^.InsertItem(New(PApp_Info,Init('','','satell.spr','',80,75,0,0,0,origin)));}
 DeskTop[12]^.InsertItem(App_Win);
 {make the window for load = background + filelist + fileinputline }
 App_Win := New(PApp_Window,Init('Load',80,75,160,100));
 App_FLB := New(PApp_FileListBox,Init('plt',pilotpath,85,85,50,50,'disk.spr',cmPltFile));
 App_Win^.InsertItem(New(PApp_MemInputLine,Init(addr(Crt_Pilot.Name),150,85,80,9,cmFieldMod)));
 App_Win^.InsertItem(New(PApp_MemInputLine,Init(addr(Crt_Pilot.CallSign),150,104,80,9,cmFieldMod)));
 App_Win^.InsertItem(App_FLB);
 App_Win^.InsertItem(New(PApp_StaticText,Init('Name:',150,79,1)));
 App_Win^.InsertItem(New(PApp_StaticText,Init('Callsign:',150,98,1)));
 App_Win^.InsertItem(New(PApp_StaticText,Init('Files:',85,79,1)));
 App_Win^.InsertItem(New(PApp_MemStr,Init('',addr(Crt_Pilot.RankStr),'',85,140,1)));
 App_Win^.InsertItem(New(PApp_MemStr,Init(',',addr(Crt_Pilot.StatusStr),'',170,140,1)));
 App_Win^.InsertItem(New(PApp_MemStr,Init('Op.',addr(Crt_Mission.BattleStr),'',85,146,1)));
 App_Win^.InsertItem(New(PApp_MemLInt,Init(',Mission ',addr(Crt_Mission.MissionNR),'',170,146,1)));
 App_Win^.InsertItem(New(PApp_MemLInt,Init('',addr(Crt_Pilot.Points),' duty points',85,152,1)));
 App_Win^.InsertItem(New(PApp_Btn,Init('Clear','clear01.spr','clear02.spr',145,160,cmClear)));
 DeskTop[12]^.InsertItem(App_Win);
 {insert debriefing window}
 App_Win := New(PApp_Window,Init('Debrief',80,75,160,100));
 for i:=1 to 8 do App_Win^.InsertItem(New(PApp_MemStr,Init('',addr(Crt_Pilot.Debrief.Text[i]),'',80,77+i*7-7,6)));
 {App_Win^.InsertItem(New(PApp_MemLInt,Init('Mission Score : ',addr(Crt_Pilot.Debrief.Score),'',100,93)));
 App_Win^.InsertItem(New(PApp_MemLInt,Init('Kills(You) : ',addr(Crt_Pilot.Debrief.Kills),'',100,101)));
 App_Win^.InsertItem(New(PApp_MemLInt,Init('(',addr(Crt_Pilot.Debrief.YKill),')',195,101)));
 }
 App_Win^.InsertItem(New(PApp_Info,Init('','','home.spr','',80,75,0,0,0,origin)));
 DeskTop[12]^.InsertItem(App_Win);
 {insert fired window}
 App_Win := New(PApp_Window,Init('Fire',80,75,160,100));
 App_Win^.InsertItem(New(PApp_StaticText,Init('Gun statistics',130,77,6)));
 for i:=1 to 10 do App_Win^.InsertItem(New(PApp_MemStr,Init('',addr(Crt_Pilot.GunStatistic[i].ToScreen),'',80,85+i*7,6)));
 App_Win^.InsertItem(New(PApp_Info,Init('','','crash.spr','',80,75,0,0,0,origin)));
 DeskTop[12]^.InsertItem(App_Win);

 {insert craft destroyed window}
 App_Win := New(PApp_Window,Init('Crash',80,75,160,100));
 App_Win^.InsertItem(New(PApp_StaticText,Init('Craft destroyed',130,77,6)));
 for i:=1 to 20 do App_Win^.InsertItem(New(PApp_MemStr,Init('',addr(Crt_Pilot.CraftStatistic[i].ToScreen),'',80,85+i*7,6)));
 for i:=21to 40do App_Win^.InsertItem(New(PApp_MemStr,Init('',addr(Crt_Pilot.CraftStatistic[i].ToScreen),'',160,85+i*7,6)));
 App_Win^.InsertItem(New(PApp_Info,Init('','','crash.spr','',80,75,0,0,0,origin)));
 DeskTop[12]^.InsertItem(App_Win);

 Dlg_Aux:=New(PApp_Dialog,Init('',80,90,160,100));
 Str_Aux:= NewStrList('Trees',
           NewStrList('Mountains',
           NewStrList('Clouds',
           NewStrList('Sun',nil))));
 Cst_Aux:=New(PApp_CheckBtn,Init('Detail Level:',cmDetail,2,80,90,Str_Aux));
 Dlg_Aux^.Link(Cst_Aux);
 Str_Aux:= NewStrList('Low Detail while rotation',
           NewStrList('Low Detail in distance',nil));
 Cst_Aux:=New(PApp_CheckBtn,Init('Speedings:',None,0,80,155,Str_Aux));
 Dlg_Aux^.Link(Cst_Aux);
 Desktop[13]:=Dlg_Aux;

 {DeskTop[7]:=New(PApp_Heap,Init('',2,193,1));}
 DeskTop[7]:=New(PApp_Spc,Init('Equip','Loading.Spr',10,10,none));
 DeskTop[1]:=New(PApp_Back,Init('backgnd'+char(random(7)+49)+'.spr'));

 DeskTop[6]^.InsertItem(DeskTop[12]);DeskTop[6]^.InsertItem(DeskTop[13]);
 DeskTop[6]^.InsertItem(DeskTop[11]);DeskTop[6]^.InsertItem(DeskTop[17]);
 DeskTop[6]^.InsertItem(DeskTop[10]);DeskTop[6]^.InsertItem(DeskTop[21]);
 Snd^.PlaySound(1);

 with look do begin x:=0;y:=0;z:=130;end;
 {loading data...end}
 {no need for sprite 2 anymore}
 DoneSpr(2);
 FadeOut(2);
 Cls(0,Vaddr);
 Cls(0,SegA000);
 LoadPal('menupal5.pal');SetPal;

 repeat
  Cls(0,vaddr);
  key := port[$60];
  if key<128 then begin comm[1]:=cmKbd;comm[2]:=key;end;
  FreeBuf;
  for i:=1 to 8 do
      with DeskTop[i]^ do
      begin
       DrawView(vaddr);
       if (Mouse^.LeftButtonPressed) and (Selected(Mouse^.X,Mouse^.Y))
       then case Action of
               ExitGame : key := 1;
               SetVol   : begin
                           volcnt := (-SelY+ViewY+spr[1].yl) div 5;
                           if volcnt<1 then volcnt:=1;
                           if volcnt>11 then volcnt:=11;
                           if base<>0 then Snd^.SetVolume;
                          end;
               Querry   : begin
                           {Dispose(DeskTop[8],Done);
                           Dispose(DeskTop[1],Done);}
                           Roll:=New(PApp_Roll,Init);
                           Roll^.Run;
                           Dispose(Roll,Done);
                           {DeskTop[1]:=New(PApp_Back,Init('backgnd'+char(random(7)+49)+'.spr'));
                           DeskTop[8]:=New(PApp_Spc,Init('Equip','Loading.Spr',10,10,none));}
                          end;
               StartGame: begin
                           {Dispose(DeskTop[1],Done);
                           Dispose(DeskTop[2],Done);
                           Dispose(DeskTop[3],Done);
                           Dispose(DeskTop[4],Done);
                           Dispose(DeskTop[5],Done);
                           Dispose(DeskTop[7],Done);
                           Dispose(DeskTop[8],Done);}
                           Game:=New(PApp_PlayGame,Init);
                           Game^.Run;
                           Dispose(Game,Done);
                           {DeskTop[1]:=New(PApp_Back,Init('backgnd'+char(random(7)+49)+'.spr'));
                           DeskTop[2]:=New(PApp_View,Init('Exit','exit.spr',0,0,exitgame));
                           DeskTop[3]:=New(PApp_View,Init('Start','start.spr',160,0,startgame));
                           DeskTop[4]:=New(PApp_Vol,Init('Volume','volume.spr','volcur.spr',80,0,setvol));
                           DeskTop[5]:=New(PApp_View,Init('Credits','querry.spr',240,0,querry));
                           DeskTop[7]:=New(PApp_Heap,Init('',2,193,1));
                           DeskTop[8]:=New(PApp_Spc,Init('Equip','Loading.Spr',10,10,none));}
                          end;
               ShipOne : begin
                          seek(fship,0);
                          read(fship,Crt_Ship);
                          crt_ship.carry:=gun_aux;
                          {!play selection sound!}
                         end;
               ShipTwo : begin
                          seek(fship,1);
                          read(fship,Crt_Ship);
                          crt_ship.carry:=gun_aux;
                          {!play selection sound!}
                         end;
               cmClear : begin
                          Crt_Pilot.Clear;
                          Crt_Pilot.LoadMission;
                          Crt_Pilot.Save;
                         end;
               end;
      end;
  if (comm[1]>=16) and (comm[1]<=22)
     then begin
           case comm[2] of
           2 : if crt_ship.carry[comm[1]-15].currentammo>0
               then begin
                     dec(crt_ship.carry[comm[1]-15].currentammo);
                     if crt_ship.carry[comm[1]-15].currentammo=0
                        then begin
                              dec(crt_ship.currentweight,crt_ship.carry[comm[1]-15].weight);
                              crt_ship.carry[comm[1]-15].get:=false;
                             end;
                     dec(crt_ship.currentweight,crt_ship.carry[comm[1]-15].ammoweight);
                    end;
           1 : if crt_ship.carry[comm[1]-15].currentammo<crt_ship.carry[comm[1]-15].maxammo
              then begin
                    if crt_ship.carry[comm[1]-15].currentammo=0
                       then if crt_ship.maxcarry>crt_ship.currentweight+crt_ship.carry[comm[1]-15].weight+
                               +crt_ship.carry[comm[1]-15].ammoweight
                            then begin
                                  inc(crt_ship.currentweight,crt_ship.carry[comm[1]-15].weight);
                                  crt_ship.carry[comm[1]-15].get:=true;
                                 end;
                    if crt_ship.maxcarry>crt_ship.currentweight+crt_ship.carry[comm[1]-15].ammoweight
                       then begin
                             inc(crt_ship.carry[comm[1]-15].currentammo);
                             inc(crt_ship.currentweight,crt_ship.carry[comm[1]-15].ammoweight);
                            end;
                   end;
           end;
           comm[1]:=0;
          end;

  if comm[1]=cmDetail
     then begin
           Trees := false;Mountain := False;
           Clouds := false; TheSun := false;
           if comm[2] and 1 = 1 then Trees := true;
           if comm[2] and 2 = 2 then Mountain := true;
           if comm[2] and 4 = 4 then Clouds := true;
           if comm[2] and 8 = 8 then TheSun := true;
           comm[1]:=0;
          end;

  if comm[1]=cmFieldMod
     then begin
           Crt_Pilot.Save;
           comm[1]:=cmNoAction;
          end;

  if comm[1]=cmPltFile
     then begin
           auxstr[0]:=char(comm[2]);
           for i:=1 to comm[2] do auxstr[i]:=char(comm[i+2]);
           Crt_Pilot.FileName := auxstr;
           Crt_Pilot.Load;
           comm[1] := cmNoAction;
          end;

  PutSpr(1,Mouse^.X,Mouse^.Y,gameput,vaddr);
  Flip;
