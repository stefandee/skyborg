UNIT
    NEWAPPS;
{$R-}
{$Q-}
INTERFACE

USES
    GRAPHICS,STRUCTS,VISIONS,SOUNDDRV,MOUSEDRV,SPACE,TYPES3D,PILOT,CRT;

TYPE
    PApp_Vol = ^App_Vol;
     App_Vol = object(App_View)
           constructor Init(name : string;fname,cfname : string; x,y : integer; act : word);
           procedure DrawView(where : word);virtual;
           destructor Done;virtual;
           end;

    PText = ^Text;
     Text = array[1..3000] of char;

    PApp_Info = ^App_Info;
     App_Info = object(App_View)
             Info  : PText;
             Rows,Cols  : integer;
             constructor Init(name,fname,bgnd,shape : string;x,y,r,c,a : integer;s : point3d);
             procedure DrawView(where : word);virtual;
             destructor Done;virtual;
             private
              Index : integer;
              IPixel : integer;
              MaxRows : integer;
              Back,Is3d,IsText   : boolean;
              obj3d : PNewObj;
              ang1,ang2 : integer;
              scale : Point3d;
             end;

   PApp_GroupInc = ^App_GroupInc;
    App_GroupInc = object(App_Group)
            PushUp,PushDown : boolean;
            constructor Init(groupname : string; x,y,xl,yl : integer);
            procedure DrawView(where : word);virtual;
            function Selected(x,y : integer):boolean;virtual;
            destructor Done;virtual;
            end;

   PApp_Spc = ^App_Spc;
    App_Spc = object(App_View)
             constructor Init(name : string; fname : string; x,y : integer; act : word);
             procedure DrawView(where : word);virtual;
             destructor Done;virtual;
             end;

   PApp_Mission = ^App_Mission;
    App_Mission = object(App_View)
                  sel_flag : boolean;
                  Txt : PText;
                  EnableText,PushPlayLeft,PushPlayRight,PushStop : boolean;
                  ViewLX,ViewLY : integer;
                  MapCount,time,timeforline,sidelen,firstline,lastline,textline,maxlines: integer;
                  linecolor : array[1..25] of byte;
                  lettercolor : array[1..16] of byte;
                  timeforletter,crtletter,microbase : byte;
                  constructor Init(name : string;x,y,xl,yl : integer);
                  procedure DrawView(where : word);virtual;
                  function Selected(x,y : integer) : boolean;virtual;
                  destructor Done;virtual;
                end;


IMPLEMENTATION

constructor App_Vol.Init;
begin
 ViewName:=name;
 LoadSpr(fname,1);
 LoadSpr(cfname,2);
 ViewX:=x;Viewy:=y;
 Action:=act;
end;

procedure App_Vol.DraWView;
begin
  PutSpr(1,ViewX,ViewY,gameput,where);
  PutSpr(2,ViewX+spr[1].xl div 2-spr[2].xl div 2,ViewY+spr[1].yl-volcnt*5-spr[2].yl,gameput,where);
  if Selx>-1 then Outtext(SelX,SelY,ViewName,1,255,where);
end;

destructor App_Vol.DOne;
begin
 DoneSpr(1);DoneSpr(2);
end;

constructor App_Info.Init;
 var f : file;
begin
 rows:=r;cols:=c;action:=a;
 if fname=''
    then istext:=false
    else begin
          new(Info);
          assign(f,missionpath+fname);
          reset(f,1);blockread(f,Info^,filesize(f));
          MaxRows:=filesize(f) div cols+1;close(f);
          istext:=true;
         end;
 index:=1;ipixel:=6;ViewName:=name;ViewX:=x;ViewY:=y;ang1:=0;ang2:=0;scale:=s;
 if bgnd='' then back:=false
            else begin
                  LoadSpr(bgnd,1);
                  back:=true;
                 end;
 if shape='' then is3d:=false
             else begin
                   new(Obj3d);
                   assign(f,shapepath+shape);
                   reset(f,1);
                   blockread(f,Obj3d^,sizeof(Obj3D^));
                   close(f);
                   is3d:=true;
                  end;

end;

procedure App_Info.DrawView;
var i,j : integer;
    aux : string;
    aux1,aux2 : integer;
begin
 {parse thru text and scroll}
 if back then PutSpr(1,ViewX,ViewY,gameput,where);
 if is3d
    then begin
          {aux1:=orgx;aux2:=orgy;
          orgx:=ViewX+cols*(fonts[1].x+1) div 2;
          orgy:=ViewY+rows*(fonts[1].y+1) div 2;}
          ang1:=(ang1+6) mod 360;
          ang2:=(ang2+1) mod 360;
          NeWork^.RotWork:=Obj3d^.Points;
          {move(Obj3d^.Points,NeWork^.RotWork,sizeof(RotWork)-Obj3D^.PointsNo shl 1); {take care !}
          center:=origin;
          NeWork^.RotateObj(Obj3D,ang1,ang1,ang2);
          NeWork^.DepthSort(Obj3D,look,origin);
          NeWork^.Project(Obj3D);
          for i:=1 to Obj3D^.faceno do
          DrawPoly(
          nework^.ProWork^[obj3d^.planes[i].p1].x,nework^.ProWork^[obj3d^.planes[i].p1].y,
          nework^.ProWork^[obj3d^.planes[i].p2].x,nework^.ProWork^[obj3d^.planes[i].p2].y,
          nework^.ProWork^[obj3d^.planes[i].p3].x,nework^.ProWork^[obj3d^.planes[i].p3].y,
          nework^.ProWork^[obj3d^.planes[i].p4].x,nework^.ProWork^[obj3d^.planes[i].p4].y,
          obj3d^.planes[i].color,vaddr);
          {orgx:=aux1;orgy:=aux2;}
         end;
 if istext
    then begin
          dec(IPixel);
          if IPixel<=0
             then begin
                   ipixel:=6;
                   inc(index);
                   if index>=maxrows-rows then index:=1;
                  end;

          aux1:=ytopclip;aux2:=ybotclip;
          ytopclip:=ViewY+fonts[1].y;
          ybotclip:=ViewY+rows*6;
          for i:=index to index+rows do
              begin
               aux[0]:=char(cols);
               for j:=1 to cols do aux[j]:=Info^[(i-1)*cols+j];
               if back
                  then outtext(ViewX+spr[1].xl div 2-(cols*(fonts[1].x+1)) div 2,ViewY+(i-index)*6+ipixel,aux,1,255,where)
                  else outtext(ViewX,ViewY+(i-index)*6+ipixel,aux,1,255,where)
              end;
          ytopclip:=aux1;ybotclip:=aux2;
         end;

 if Selx>-1 then Outtext(SelX,SelY,ViewName,1,255,where);
end;

destructor App_Info.Done;
begin
 if istext then dispose(Info);
 if back then DoneSpr(1);
 if is3d then dispose(Obj3D);
end;

constructor App_GroupInc.Init;
begin
 LoadSpr('uparrow.spr',5);
 LoadSpr('suparrow.spr',6);
 LoadSpr('dnarrow.spr',7);
 LoadSpr('sdnarrow.spr',8);
 inherited Init(groupname,x,y,xl,yl);
 PushUp:=false;PushDown:=false;
end;

procedure App_GroupInc.DrawView;
begin
 inherited DrawView(where);
 if pushup
    then begin
          Putspr(6,ViewX-spr[8].xl,ViewY,gameput,where);
          pushup:=false;
         end
    else Putspr(5,ViewX-spr[8].xl,ViewY,gameput,where);
 if pushdown
    then begin
          Putspr(8,ViewX-spr[8].xl,ViewY+Viewly-spr[8].yl-spr[1].yl,gameput,where);
          pushdown:=false;
         end
    else Putspr(7,ViewX-spr[8].xl,ViewY+Viewly-spr[8].yl-spr[1].yl,gameput,where);
end;

function App_GroupInc.Selected;
begin
 inherited Selected(x,y);
 if (x>ViewX-spr[8].xl) and (x<ViewX) and
    (y>ViewY) and (y<ViewY+spr[8].yl) and
    Mouse^.LeftButtonPressed
    then begin
          pushup:=true;
          Comm[1]:=Active^.Info^.Action;
          Comm[2]:=1;{inc}
         end;
 if (x>ViewX-spr[8].xl) and (x<ViewX) and
    (y>ViewY+ViewLY-spr[8].yl-spr[1].yl) and (y<ViewY+ViewLY-spr[1].yl) and
    Mouse^.LeftButtonPressed
    then begin
          pushdown:=true;
          Comm[1]:=Active^.Info^.Action;
          Comm[2]:=2;{dec}
         end;
end;

destructor App_GroupInc.Done;
begin
 inherited Done;
 DoneSpr(5);DoneSpr(6);
 DoneSpr(7);DoneSpr(8);
end;

constructor App_Spc.Init;
begin
 Action:=act;
 LoadSpr(fname,1);
 ViewName:=name;
end;

procedure App_Spc.DrawView;
var aux : string;
    x,y,i : integer;
begin
 if Mouse^.RightButtonPressed
    then begin
          putspr(1,Mouse^.X-spr[1].xl div 2,Mouse^.Y-spr[1].yl div 2,gameput,where);
          y:=Mouse^.Y-spr[1].yl div 2+1;
          aux:='Space available';outtext(Mouse^.X-((fonts[1].x+1) div 2)*length(aux),Y,aux,1,255,where);
          aux:='on '+Crt_Ship.name;outtext(Mouse^.X-((fonts[1].x+1) div 2)*length(aux),Y+fonts[1].y+1,aux,1,255,where);
          outint(Mouse^.X-16,Y+2*(fonts[1].y+1),Crt_Ship.maxcarry-Crt_Ship.currentweight,1,255,where);
          aux:='Weapons ammo : ';outtext(Mouse^.X-((fonts[1].x+1) div 2)*length(aux),Y+4*(fonts[1].y+1),aux,1,255,where);
          for i:=1 to maxweapon do
              begin
               str(crt_ship.carry[i].currentammo,aux);
               aux:=crt_ship.carry[i].name+'....'+aux;
               outtext(Mouse^.X-((fonts[1].x+1) div 2)*length(aux),Y+(i-1)*(fonts[1].y+1)+6*(fonts[1].y+1),aux,1,255,where);
              end;
         end;
end;

destructor App_Spc.Done;
begin
 DoneSpr(1);
end;

constructor App_Mission.Init;
var i : integer;
begin
 LoadSpr('leftp.spr',1);
 LoadSpr('rightp.spr',2);
 LoadSpr('dnleftp.spr',8);
 LoadSpr('dnrightp.spr',9);
 LoadSpr('stopp.spr',3);
 LoadSpr('dnstopp.spr',4);
 LoadSpr('textp.spr',5);
 LoadSpr('dntextp.spr',6);
 LoadSpr('changep.spr',7);

 microbase:=9;
 with Crt_Mission do for i:=1 to MaxMicro do LoadSpr(micro[i],i+microbase);
 time:=-1;sel_flag:=false;
 ViewX:=x;ViewY:=y;
 ViewLX:=xl;ViewLY:=yl;
 ViewName:=name;
 MapCount:=0;New(Txt);
 PushPlayLeft:=False;PushPlayRight:=false;PushStop:=false;EnableText:=true;
 sidelen:=5;
 if base<>0 then Snd^.LoadSound('brr.raw',2);
end;

procedure App_Mission.DrawView;
Var
   i,j,C1x,c1y,auxx,auxy : integer;
   f  : file;
   aux : string;
begin
 {Bar(Viewx,ViewY,Viewx+ViewLX,Viewy+Viewly,0,where);}
 { grid X }
 for i:=1 to 11 do line((i-1)*16+ViewX,ViewY,(i-1)*16+ViewX,ViewY+ViewLY,119,where);
 { grid Y }
 for i:=1 to 11 do line(ViewX,ViewY+(i-1)*10,ViewX+ViewLX,ViewY+(i-1)*10,119,where);

 with Crt_Mission do
      begin
       if (time<0) or (PushPlayLeft) or (PushPlayRight)
          then begin
                repeat
                if PushPlayLeft
                   then begin
                         inc(MapCount);
                         if MapCount>MaxMap then MapCount:=1
                        end
                   else begin
                         dec(MapCount);
                         if MapCount<1 then MapCount:=MaxMap
                        end
                until Map[MapCount].Show;
                time:=100;
                textline:=1;
                for i:=1 to 25 do linecolor[i]:=0;timeforline:=2;
                for i:=1 to 15 do lettercolor[i]:=0;timeforletter:=1;
                sidelen:=15;crtletter:=1;
                FillChar(Txt^,sizeof(Txt^),32);
                Assign(f,missionpath+Map[MapCount].BrieFile);Reset(f,1);blockread(f,Txt^,filesize(f));
                maxlines:=FileSize(f) div 20+1;Close(f);
                firstline:=1;lastline:=6;
                if base<>0 then Snd^.PlaySound(2);
               end;
       if not PushStop then dec(time);
       {brief show}
       if EnableText
          then begin
                bar( ViewX+ViewLX-20*(fonts[6].x+1)-2,ViewY+ViewLY-(fonts[6].y+1)*(lastline-firstline+1),
                     ViewX+ViewLX-2,ViewY+ViewLY,123,where);
                dec(timeforline);
                if timeforline<=0
                   then begin
                         if textline<lastline-firstline then inc(textline);
                         timeforline:=2;
                        end;
                for i:=firstline to firstline+textline do
                    begin
                     if linecolor[i-firstline+1]<50 then inc(linecolor[i-firstline+1],5);
                     aux[0]:=char(20);
                     for j:=1 to 20 do aux[j]:=Txt^[j+(i-1)*20];
                     outtext(ViewX+ViewLX-20*(fonts[6].x+1)-2,ViewY+ViewLY+(i-6-firstline)*6,aux,6,
                     linecolor[i-firstline+1]+200,where);
                    end;
               end;
       {objective name show}
       c1x:=Map[MapCount].X[5] div 409+ViewX+ViewLX div 2;
       c1y:=Map[MapCount].X[6] div 655+ViewY+ViewLY div 2;
       dec(timeforletter);
       if timeforletter<=0
          then begin
                if crtletter<length(Map[MapCount].name) then inc(crtletter);
                timeforletter:=1;
               end;
       for i:=1 to crtletter do
           begin
            if lettercolor[i]<50 then inc(lettercolor[i],5);
            aux[1]:=Map[MapCount].name[i];
            outtext(c1x-(length(Map[MapCount].name)-i)*(fonts[6].x+1),c1y-12,aux[1],6,
            lettercolor[i]+200,where);
           end;
       {map show}
       for i:=1 to MaxMap do
           if i<>MapCount
              then begin
                    auxx:=Map[i].X[5] div 409+ViewX+ViewLX div 2;
                    auxy:=Map[i].X[6] div 655+ViewY+ViewLY div 2;
                    putspr(Map[i].Micro+microbase,auxx-spr[microbase+1].xl div 2,auxy-spr[microbase+1].yl div 2,gameput,where);
                   end;
       if sidelen>6 then dec(sidelen);
       bar(c1x-sidelen,c1y-sidelen,c1x+sidelen,c1y+sidelen,119,where);
       rectangle(c1x-sidelen,c1y-sidelen,c1x+sidelen,c1y+sidelen,115,where);
       putspr(Map[Mapcount].Micro+microbase,c1x-spr[microbase+1].xl div 2,c1y-spr[microbase+1].yl div 2,gameput,where);
       {mission name}
       rectangle(ViewX+1,ViewY+1,ViewX+length(name)*(fonts[6].x+1)+3,ViewY+fonts[6].y+4,115,where);
       outtext(ViewX+2,ViewY+3,name,6,255,where);
       {my craft}
       c1x:=MyCraft.X div 409+ViewX+ViewLX div 2;
       c1y:=MyCraft.Y div 655+ViewY+ViewLY div 2;
       putspr(microbase+7,c1x,c1y,gameput,where);
       outtext(c1x-fonts[6].x,c1y-spr[microbase+7].yl div 2,'YOU',6,255,where);
      end;
 c1x:=ViewX+ViewLX div 2;c1y:=ViewY+ViewLY;
 if PushPlayLeft then putspr(8,c1x-45-spr[1].xl div 2,c1y+7-spr[1].yl div 2,gameput,where)
                 else putspr(1,c1x-45-spr[1].xl div 2,c1y+7-spr[1].yl div 2,gameput,where);
 case PushStop of
  true : putspr(4,c1x-spr[4].xl div 2,c1y+7-spr[4].yl div 2,gameput,where);
  false : putspr(3,c1x-spr[3].xl div 2,c1y+7-spr[3].yl div 2,gameput,where);
 end;
 case EnableText of
  true : putspr(5,c1x+22-spr[5].xl div 2,c1y+7-spr[5].yl div 2,gameput,where);
  false : putspr(6,c1x+22-spr[6].xl div 2,c1y+7-spr[6].yl div 2,gameput,where);
 end;
 if PushPlayRight then putspr(9,c1x+45-spr[2].xl div 2,c1y+7-spr[2].yl div 2,gameput,where)
                  else putspr(2,c1x+45-spr[2].xl div 2,c1y+7-spr[2].yl div 2,gameput,where);
 putspr(7,c1x-22-spr[7].xl div 2,c1y+7-spr[7].yl div 2,gameput,where);
 PushPlayRight:=false;PushPlayLeft:=false;

 if Selx>-1 then Outtext(SelX,SelY,ViewName,1,255,where);
end;

function App_Mission.Selected;
var i : integer;
begin
 Selx:=-1;Sely:=-1;
 Selected:=false;
 if (X<ViewX+ViewLX) and (X>Viewx) and
    (Y<ViewY+ViewLY) and (Y>Viewy)
    then begin
          Selected:=true;
          SelX:=x;
          Sely:=y;
         end;
 if (X>ViewX+ViewLX div 2+45-spr[2].xl div 2) and (X<ViewX+ViewLX div 2+45+spr[2].xl div 2)
    and (Y>ViewY+ViewLY+7-spr[2].yl div 2) and (Y<ViewY+ViewLY+7+spr[2].yl div 2) and Mouse^.LeftButtonPressed
    then PushPlayRight:=true;
 if (X>ViewX+ViewLX div 2-45-spr[1].xl div 2) and (X<ViewX+ViewLX div 2-45+spr[1].xl div 2)
    and (Y>ViewY+ViewLY+7-spr[1].yl div 2) and (Y<ViewY+ViewLY+7+spr[1].yl div 2) and Mouse^.LeftButtonPressed
    then PushPlayLeft:=true;
 if (X>ViewX+ViewLX div 2-spr[3].xl div 2) and (X<ViewX+ViewLX div 2+spr[3].xl div 2)
    and (Y>ViewY+ViewLY+7-spr[3].yl div 2) and (Y<ViewY+ViewLY+7+spr[3].yl div 2) and Mouse^.LeftButtonPressed
    then PushStop:=not PushStop;
 if (X>ViewX+ViewLX div 2+22-spr[5].xl div 2) and (X<ViewX+ViewLX div 2+22+spr[5].xl div 2)
    and (Y>ViewY+ViewLY+7-spr[5].yl div 2) and (Y<ViewY+ViewLY+7+spr[5].yl div 2) and Mouse^.LeftButtonPressed
    then EnableText:=not EnableText;
 if (X>ViewX+ViewLX div 2-22-spr[6].xl div 2) and (X<ViewX+ViewLX div 2-22+spr[6].xl div 2)
    and (Y>ViewY+ViewLY+7-spr[5].yl div 2) and (Y<ViewY+ViewLY+7+spr[5].yl div 2) and Mouse^.LeftButtonPressed
    then begin
          firstline:=lastline+1;
          if firstline>maxlines
             then begin
                   firstline:=1;
                   lastline:=6;
                  end
             else lastline:=firstline+5;
          textline:=1;
          for i:=1 to 25 do linecolor[i]:=0;timeforline:=3;
         end;
end;

destructor App_Mission.Done;
var i : integer;
begin
 DoneSpr(1);DoneSpr(2);DoneSpr(3);DoneSpr(4);
 Dispose(Txt);if base<>0 then Snd^.FreeSound(2);
 with Crt_Mission do for i:=1 to MaxMicro do DoneSpr(i+4);
end;

BEGIN
END.