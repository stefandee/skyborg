UNIT
    SPACE;
{$Q-}

INTERFACE

USES
    TYPES3D,VISIONS,STRUCTS,GRAPHICS,MOUSEDRV,CRT,DOS,PILOT;

CONST
     {details}
     TheSun        : boolean = False;
     Clouds        : boolean = False;
     Mountain      : boolean = False;
     Trees         : boolean = False;

TYPE
    Message = record
            Text : Title;
            Time : byte;
            end;

    MessageQueue = record
                 Msgs   : array[1..100] of Message;
                 Crt    : byte;
                 Last   : byte;
                 end;

    KeyPoint = record
             code   : byte;
             {
              0-engine,1-comm/radar,2-lcannon,
              3-rcannon,4-hull,5-bay,6-lrocket,
              7-rrocket,8-gnd,9-hangar
             }
             radius : byte;
             damage : integer;
             pos    : Point3D;
             end;

   PKeyPoints = ^KeyPoints;
    KeyPoints = record
              AKP : array[1..10] of KeyPoint;
              IKP : byte;
              CKP : byte;
              end;

   PIntoSpace = ^IntoSpace;
    IntoSpace = object
              curent               : boolean;
              head,headto,headcrt  : point3d;{ keep track of craft "nose" - angles }
              ovi,ovj,ovk,vi,vj,vk : point3d;
              eyevi,eyevj,eyevk    : point3d;
              oeyevi,oeyevj,oeyevk : point3d;
              look                 : point3d;{ curent position into space - could be rotated}
              sortdistance         : longint;
              Speed,ReachSpeed     : integer;
              HullRU               : integer;
              dummypoint           : point3d;
              whatshape,whatdmg    : byte;
              dummyang,XCount      : integer;
              Dispose_Me           : boolean;
              I_Was_Destroyed      : boolean;
              SubAction,Time       : byte;
              X                    : CommZone;
              Name                 : Str20;
              FlightInd            : StrInd;
              Next,NextDraw        : PIntoSpace;
              Target               : PIntoSpace;
              OKP,KP               : PKeyPoints;
              Points               : longint;
              LastHit              : integer;
              constructor Init(Data : CommZone;var nm : Str20;fi : StrInd;ws,wd : byte;hull : byte;p : longint);
              procedure   Strategy(var status : byte);virtual;
              procedure   Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
              destructor  Done;virtual;
              private
               key : byte;
              end;

   PMyCraft = ^MyCraft;
    MyCraft = object(IntoSpace)
              Board                  : boolean;
              LeftScreen,RightScreen : byte;
              RadarZoom              : byte;
              LastShld               : integer;
              MQ                     : MessageQueue;
              constructor Init(Sp : point3d;ws : byte);
              procedure Strategy(var status : byte);virtual;
              procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
              destructor Done;virtual;
              end;

   PBitMap = ^BitMap;
    BitMap = object(IntoSpace)
           sprite : byte;
           constructor Init(where : point3d;nm : Str20;whatspr : byte);
           procedure Strategy(var status : byte);virtual;
           procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
           destructor Done;virtual;
           end;

   PScaled = ^Scaled;
    Scaled = object(BitMap)
           Visibility , ScaleFactor : integer;
           constructor Init(where : point3d;nm : Str20;whatspr : byte;vis,sf : integer);
           procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
           destructor Done;virtual;
           end;

   PBullet = ^Bullet;
    Bullet = object(Scaled)
           DrainedRU : word;
           Author    : integer;
           constructor Init( where : point3d;dir : point3d;t,s : integer;nm : Str20;whatspr : byte;vis,sf : integer;pw : word;
                             a : integer);
           procedure Strategy(var status : byte);virtual;
           destructor Done;virtual;
           end;

   PSun = ^Sun;
    Sun = object(BitMap)
        savepal    : paltype;
        lastregion : byte;
        constructor Init(where : point3d;whatspr : byte);
        procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
        destructor Done;virtual;
        end;

   PSky = ^Sky;
    Sky = object(IntoSpace)
              ProPoints : array[1..20,1..4] of point2d;
              constructor Init;
              procedure Strategy(var status : byte);virtual;
              procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
              destructor Done;virtual;
           end;

   PAnimation = ^Animation;
    Animation = object(Scaled)
              maxsprite : byte;
              constructor Init(where : point3d;whatspr : byte;maxspr : byte;vis,sf : integer);
              procedure Strategy(var status : byte);virtual;
              procedure Draw(var fromvi,fromvj,fromvk,fromlook : point3d);virtual;
              destructor Done;virtual;
           end;

   procedure Ins2Space(what : PIntoSpace);
   procedure ins2DrawSpace(what : PIntoSpace);
   procedure DoneSpace;
   procedure LoadObjects;
   procedure LoadDmg;
   procedure DisposeObjects;
   procedure DisposeDmg;
   procedure Ins2MsgQueue(var MQ : MessageQueue;text : Title;time : byte);

VAR
   My_Craft      : PMyCraft;
   Crt_Craft     : PIntoSpace;
   TheSky        : PSky;
   SpaceRoot     : PIntoSpace;
   DrawSpaceRoot : PIntoSpace;
   AllObjects    : array[1..100] of PNewObj;
   AllDmg        : array[1..100] of PKeyPoints;

IMPLEMENTATION

procedure Ins2Space;
var aux : PIntoSpace;
begin
 what^.next:=nil;
 if SpaceRoot=nil
    then SpaceRoot:=what
    else begin
          aux:=SpaceRoot;
          while (aux^.next<>NIL) do
                begin
                 aux:=aux^.next;
                end;
          aux^.next:=what;
         end;
end;

procedure Ins2DrawSpace;
var aux,aux1 : PIntoSpace;
begin
 what^.nextdraw:=nil;
 if DrawSpaceRoot=nil
    then DrawSpaceRoot:=what
    else if DrawSpaceRoot^.sortdistance<what^.sortdistance
             then begin
                   what^.nextdraw:=DrawSpaceRoot;
                   DrawSpaceRoot:=what;
                  end
             else begin
                   aux:=DrawSpaceRoot;
                   while (aux^.nextdraw<>NIL) and (what^.sortdistance<aux^.nextdraw^.sortdistance) do
                         begin
                          aux:=aux^.nextdraw;
                         end;
                   aux1:=aux^.nextdraw;
                   aux^.nextdraw:=what;
                   what^.nextdraw:=aux1;
                  end;
end;

procedure DoneSpace;
var aux1,aux2 : PIntoSpace;
begin
 aux1:=SpaceRoot;
 while aux1<>nil do
       begin
        aux2:=aux1^.next;
        dispose(aux1,Done);
        aux1:=aux2;
       end;
end;

procedure LoadObjects;
var i : integer;
    f : file of NewObj;
begin
 for i:=1 to Crt_Mission.MaxShapes do
     begin
      {if AllObjects[i]<>NIL then dispose(AllObjects[i]);}
      new(AllObjects[i]);
      assign(f,shapepath+Crt_Mission.Shapes[i]);
      reset(f);
      read(f,AllObjects[i]^);
      close(f);
     end;
 {if AllObjects[100]<>NIL then dispose(AllObjects[100]);}
 new(AllObjects[100]);
 assign(f,shapepath+Crt_Ship.Shape);
 reset(f);
 read(f,AllObjects[100]^);
 close(f);
 new(AllObjects[90]);
 assign(f,shapepath+'sky.s3d');
 reset(f);
 read(f,AllObjects[90]^);
 close(f);
end;

procedure DisposeObjects;
var i : integer;
begin
 for i:=1 to Crt_Mission.MaxShapes do {if AllObjects[i]<>NIL then }dispose(AllObjects[i]);
 {if AllObjects[100]<>NIL then }dispose(AllObjects[100]);
 dispose(AllObjects[90]);{the sky}
end;

procedure LoadDmg;
var f : file of KeyPoints;
    i : integer;
begin
 for i:=1 to Crt_Mission.MaxDMG do
     begin
      new(AllDmg[i]);
      assign(f,shapepath+Crt_Mission.Dmg[i]);
      reset(f);
      read(f,AllDmg[i]^);
      close(f);
     end;
end;

procedure DisposeDmg;
var i : integer;
begin
 for i:=1 to Crt_Mission.MaxDMG do Dispose(AllDmg[i]);
end;

procedure Ins2MsgQueue;
begin
 if MQ.Last<100 then begin
  inc(MQ.Last);
  MQ.Msgs[MQ.Last].text := text;
  MQ.Msgs[MQ.Last].time := time
 end;
end;

constructor IntoSpace.Init;
var FDmg : file of KeyPoints;
begin
 X                := Data;
 whatshape        := ws;
 whatdmg          := wd;
 points           := p;
 name             := nm;
 look.x           := x[5];
 look.z           := x[6];
 look.y           := x[7];
 speed            := 0;
 subaction        := 0;
 dispose_me       := false;
 I_Was_Destroyed  := false;
 curent           := false;
 headto           := origin;
 HullRU           := hull;
 FlightInd        := FI;
 XCount           := 8;
 dummypoint.x     := X[XCount];
 dummypoint.z     := X[XCount+1];
 dummypoint.y     := X[XCount+2];
 LastHit          := 0;

 with vi do begin x:=16;y:=0;z:=0;end;
 with vj do begin x:=0;y:=16;z:=0;end;
 with vk do begin x:=0;y:=0;z:=16;end;
 ovi:=vi;ovj:=vj;ovk:=vk;

 with eyevi do begin x:=16;y:=0;z:=0;end;
 with eyevj do begin x:=0;y:=16;z:=0;end;
 with eyevk do begin x:=0;y:=0;z:=16;end;
 oeyevi:=eyevi;oeyevj:=eyevj;oeyevk:=eyevk;

 with headcrt do
      begin
       x:=nework^.RealAngleVPV(look,ovi,dummypoint);
       y:=nework^.RealAngleVPV(look,ovj,dummypoint);
       z:=nework^.RealAngleVPV(look,ovk,dummypoint);
      end;

 if whatdmg<>0 then begin new(KP);new(OKP); KP^ := AllDmg[whatdmg]^;OKP^ := KP^;end
end;

procedure IntoSpace.Strategy;
var
   a1,a2,a3,modul : real;
   aux            : PIntoSpace;
   NX             : CommZone;
   nm             : Str20;
   i              : integer;
begin
 if curent
    then begin
          key:=port[$60];
          case key of
           73 : begin
                 Crt_Craft^.curent:=false;
                 if Crt_Craft^.next=Nil then Crt_Craft:=SpaceRoot
                                        else Crt_Craft:=Crt_Craft^.Next;
                 Crt_Craft^.curent:=true;
                end;
            1 : status := 6;
          end;
          Gfx^.FreeBuf;
          center:=origin;
          Mouse^.X;Mouse^.Y;
          eyevi:=oeyevi;eyevj:=oeyevj;eyevk:=oeyevk;
          head.z:=head.z+Mouse^.DeltaX;
          head.y:=head.y+Mouse^.DeltaX;
          head.x:=head.x+Mouse^.DeltaY;
          if head.x<0 then head.x:=360-head.x;
          if head.y<0 then head.y:=360-head.y;
          if head.z<0 then head.z:=360-head.z;
          nework^.rotatepoint(eyevi,head.x,head.y,head.z);
          nework^.rotatepoint(eyevj,head.x,head.y,head.z);
          nework^.rotatepoint(eyevk,head.x,head.y,head.z);
          Mouse^.DeltaX:=0;Mouse^.DeltaY:=0;
         end;

 {do your own strategy...}
 case X[3] of
  1,3
    : begin
       if look.y<250 then inc(look.y,2);
       if speed<19 then inc(speed);
       if (look.x>X[XCount  ]-50) and (look.x<X[XCount  ]+50) and
          (look.y>X[XCount+2]-50) and (look.y<X[XCount+2]+50) and
          (look.z>X[XCount+1]-50) and (look.z<X[XCount+1]+50)
          then begin
                inc(XCount,3);
                dummypoint.x:=X[XCount];dummypoint.z:=X[XCount+1];dummypoint.y:=X[XCount+2];
                sound(2000);
                delay(35);
                nosound;
               end;
       {
       if X[3]=1 then
          if (nework^.DistancePP(My_Craft^.look,look)<1500) and (random(30)=1)
             then begin
                   X[3] := 5;
                   SubAction := 1;
                  end;
       }

       with headto do
        begin
         x:=nework^.RealAngleVPV(look,ovi,dummypoint);
         y:=nework^.RealAngleVPV(look,ovj,dummypoint);
         z:=nework^.RealAngleVPV(look,ovk,dummypoint);
        end;
       headcrt := headto;
      end;
  5 : begin
       if look.y<250 then inc(look.y,2);
       if speed<48 then inc(speed);
       case SubAction of
       1 : begin
            {dummypoint := My_Craft^.look;}
            if nework^.DistancePP(dummypoint,look)<100
               then begin
                     with dummypoint do begin x:=0;y:=5000;z:=0;end;
                     SubAction := 2;{distance}
                     Time := 100;
                    end;
            end;
       2 : begin
            dec(Time);
            if Time<=0 then SubAction := 1;
           end;
       end;
       with headto do
        begin
         x:=nework^.RealAngleVPV(look,ovi,dummypoint);
         y:=nework^.RealAngleVPV(look,ovj,dummypoint);
         z:=nework^.RealAngleVPV(look,ovk,dummypoint);
        end;
       headcrt := headto;
      end;
   10 : begin
         {object is smoke}
         dec(X[4]);
         if X[4]=0 then dispose_me := true;
         with headto do
              begin
               inc(x,3);x := x mod 360;
               inc(y,3);y := y mod 360;
               inc(z,3);z := z mod 360;
              end;
        end;
   11 : begin
         {vrie}
         inc(headto.y,6);headto.y := headto.y mod 360;
        end;
 end;

 if X[1]>384
    then begin
          vi:=ovi;vj:=ovj;vk:=ovk;
          if headto.x<0 then headto.x:=360-headto.x;
          if headto.y<0 then headto.y:=360-headto.y;
          if headto.z<0 then headto.z:=360-headto.z;
          with headto do begin x:=x mod 360;y:=y mod 360;z:=z mod 360;end;
          dummyang:=nework^.RealAngleVPV(dummypoint,vk,look);
          {
          nework^.rotatepoint(vi,headto.x,headto.y,headto.z);
          nework^.rotatepoint(vj,headto.x,headto.y,headto.z);
          nework^.rotatepoint(vk,headto.x,headto.y,headto.z);}

          a1:=(-look.x+dummypoint.x);a2:=(-look.y+dummypoint.y);a3:=(-look.z+dummypoint.z);
          modul := sqrt(abs(a1*a1+a2*a2+a3*a3));
          if modul<>0
             then begin
                   vk.x := round(16*a1/modul);
                   vk.y := round(16*a2/modul);
                   vk.z := round(16*a3/modul);
                  end
             else vk := ovk;

          look.x:=look.x+(speed div 4*vk.x) div 16;
          look.y:=look.y+(speed div 4*vk.y) div 16{-4grav};
          look.z:=look.z+(speed div 4*vk.z) div 16;
         end;

 if whatdmg<>0 then
 for i := 1 to KP^.IKP do
     begin
      if KP^.AKP[i].damage<130
         then begin
               NX[1] := 5;{id code}
               NX[3] := 10;
               NX[4] := 13;
               nm    := 'smoke';

               {insert smoke}
               aux := new(PIntoSpace,Init(NX,nm,'',9+random(2),0,0,0));

               aux^.KP := NIL;
               aux^.OKP := NIL;
               aux^.look.x := KP^.AKP[i].pos.x;
               aux^.look.y := KP^.AKP[i].pos.y;
               aux^.look.z := KP^.AKP[i].pos.z;

               aux^.headto.x := random(360);
               aux^.headto.y := random(360);
               aux^.headto.z := random(360);
               Ins2Space(aux);
              end;

      if KP^.AKP[i].damage = 0 then
         case KP^.AKP[i].code of
          0,4,5 : begin { destruction }
                   I_Was_Destroyed := true;
                   aux             := new(PAnimation,Init(look,30,38,1000,100));
                   {if my_craft shot down this plane, write it to its victims}
                   if LastHit = 768 then Crt_Pilot.Insert2Craft(Name);
                   Ins2Space(aux);
                  end;
          6,7,10 : begin
                 X[3]   := 11;{vrie}
                 speed  := 0;
                end;
         end;

     end;
end;

procedure IntoSpace.Draw;
var a,i : integer;
    s   : string;
begin
 if whatdmg<>0
    then for i:= 1 to KP^.IKP do
            begin
             KP^.AKP[i].pos:=OKP^.AKP[i].pos;
             nework^.RotatePoint(KP^.AKP[i].pos,270+headto.x,headto.y,headto.z);
             inc(KP^.AKP[i].pos.x,look.x);
             inc(KP^.AKP[i].pos.y,look.y);
             inc(KP^.AKP[i].pos.z,look.z);
            end;
 if not curent
    then begin
          nework^.rotwork:=AllObjects[whatshape]^.points;{optimize this !!! no way - It's a PENTIUM}
          nework^.RotateObj(AllObjects[whatshape],270+headto.x,headto.y,headto.z);
          nework^.DepthSort(AllObjects[whatshape],fromlook,look);
          nework^.Inverter(fromvi,fromvj,fromvk);
          nework^.ProLook(AllObjects[whatshape],fromlook,look);
          {sortdistance:=nework^.DistancePP(fromlook,look);}
          a:=nework^.AngleVPV(fromlook,fromvk,look);
          if (a>-50) and (a<50) then
          for i:=1 to AllObjects[whatshape]^.faceno do
              if (AllObjects[whatshape]^.planes[i].eyedist>30) and (AllObjects[whatshape]^.planes[i].eyedist<1500)then
              Gfx^.DrawPoly(
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p1].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p1].y,
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p2].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p2].y,
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p3].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p3].y,
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p4].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p4].y,
              AllObjects[whatshape]^.planes[i].color,vaddr)
              else if AllObjects[whatshape]^.planes[i].eyedist<100
                      then begin
                    Gfx^.Outtext(0,100,'Collission!',6,255,vaddr);
                    Gfx^.Outint(0,110,i,6,255,vaddr);
                   end;
        end
    else begin
          s:='View from '+name;
          Gfx^.outtext(160-((fonts[6].x+1)*length(s)) div 2,ytopclip,s,6,255,vaddr);
         end;
end;

destructor IntoSpace.Done;
begin
 if whatdmg<>0 then begin dispose(KP);dispose(OKP);end;
end;

constructor BitMap.Init;
begin
 X[1]            := 0;{invisible}
 look            := where;
 speed           := 0;
 dispose_me      := false;
 I_Was_Destroyed := false;
 curent          := false;
 name            := nm;
 sprite          := whatspr;
 KP              := NIL;
 OKP             := NIL;
 with vi do begin x:=16;y:=0;z:=0;end;
 with vj do begin x:=0;y:=16;z:=0;end;
 with vk do begin x:=0;y:=0;z:=16;end;
 ovi:=vi;ovj:=vj;ovk:=vk;
 with eyevi do begin x:=16;y:=0;z:=0;end;
 with eyevj do begin x:=0;y:=16;z:=0;end;
 with eyevk do begin x:=0;y:=0;z:=16;end;
 oeyevi:=eyevi;oeyevj:=eyevj;oeyevk:=eyevk;
 with headto do begin x:=0;y:=0;z:=0;end;
end;

procedure BitMap.Strategy;
begin
 if curent
    then begin
           Crt_Craft^.curent:=false;
           if Crt_Craft^.next=Nil then Crt_Craft:=SpaceRoot
                                  else Crt_Craft:=Crt_Craft^.Next;
           Crt_Craft^.curent:=true;
          end;
end;

procedure BitMap.Draw;
begin
 nework^.Inverter(fromvi,fromvj,fromvk);
 nework^.ProLookPoint(fromlook,look);
 sortdistance := nework^.DistancePP(look,fromlook);
 Gfx^.PutSpr(sprite,nework^.ProWork^[1].x,nework^.ProWork^[1].y,gameput,vaddr);
end;

destructor BitMap.Done;
begin
end;

constructor Scaled.Init;
begin
 Name            := nm;
 Look            := where;
 Sprite          := whatspr;
 Visibility      := vis;
 ScaleFactor     := sf;
 Curent          := false;
 Dispose_me      := false;
 X[1]            := 0;
 KP              := NIL;
 OKP             := NIL;
 I_Was_Destroyed := false
end;

procedure Scaled.Draw;
var
   a,NewXL,NewYl : integer;
begin
 sortdistance:=nework^.DistancePP(fromlook,look);
 a:=nework^.AngleVPV(fromlook,fromvk,look);

 if (sortdistance<Visibility) and ((a>270) or (a<90))
    then begin
          if sortdistance=0 then inc(sortdistance);
          NewXL := (Gfx^.Spr[sprite].xl*ScaleFactor) div sortdistance;
          NewYL := (Gfx^.Spr[sprite].yl*ScaleFactor) div sortdistance;
          nework^.Inverter(fromvi,fromvj,fromvk);
          nework^.ProLookPoint(fromlook,look);
          Gfx^.ScaleSpr(sprite,nework^.ProWork^[1].x-NewXL div 2,nework^.ProWork^[1].y-NewYL div 2,NewXL,NewYL);
         end;
end;

destructor Scaled.Done;
begin
end;

constructor Bullet.Init;
begin
 Time            := t;
 Visibility      := vis;
 ScaleFactor     := sf;
 vk              := dir;
 speed           := s;
 look            := where;
 Name            := nm;
 sprite          := whatspr;
 dispose_me      := false;
 curent          := false;
 DrainedRU       := pw;
 HullRU          := 0;
 X[1]            := 8;
 KP              := NIL;
 OKP             := NIL;
 I_Was_Destroyed := false;
 Author          := a;
end;

procedure Bullet.Strategy;
var aux : PIntoSpace;
    i   : integer;
begin
 if curent
    then begin
           Crt_Craft^.curent:=false;
           if Crt_Craft^.next=Nil then Crt_Craft:=SpaceRoot
                                  else Crt_Craft:=Crt_Craft^.Next;
           Crt_Craft^.curent:=true;
          end;
  dec(Time);
  if Time<=0 then dispose_me := true;
  look.x:=look.x-(speed div 4*vk.x) div 16;
  look.y:=look.y-(speed div 4*vk.y) div 16;
  look.z:=look.z-(speed div 4*vk.z) div 16;

  aux := SpaceRoot;
  while (aux<>nil) do
        begin
         if (aux^.KP <> NIL)
            then begin
                  for i:=1 to aux^.KP^.IKP do
                      with aux^.KP^.AKP[i] do
                           if (look.x<pos.x+radius) and (look.x>pos.x-radius) and
                              (look.y<pos.y+radius) and (look.y>pos.y-radius) and
                              (look.z<pos.z+radius) and (look.z>pos.z-radius)
                              then begin
                                    dec(damage,DrainedRU*aux^.HullRU);
                                    if damage <= 0 then damage := 0;
                                    if Author = 768 then Crt_Pilot.Insert2GunHit(Name);
                                    aux^.LastHit := Author;
                                    dispose_me := true;
                                    break;
                                   end;
                 end;
         {daca atinge o tinta , ii scade energia si se elimina}
         aux := aux^.next;
        end;
end;

destructor Bullet.Done;
begin
end;

constructor Sun.Init;
 var
    i : integer;
begin
 inherited Init(where,'',whatspr);
 for i:=0 to 255 do Gfx^.GetRGB(i,savepal[i,1],savepal[i,2],savepal[i,3]);
 lastregion      := 0;
 name            := 'SUN';
 dispose_me      := false;
 KP              := NIL;
 OKP             := NIL;
 X[1]            := 4;
 whatdmg         := 0;
 I_Was_Destroyed := false;
end;

procedure Sun.Draw;
 var
    i,a : integer;
begin

 inherited Draw(fromvi,fromvj,fromvk,fromlook);
 a:=nework^.RealAngleVPV(fromlook,fromvk,look);
 sortdistance := nework^.DistancePP(look,fromlook);
 dummyang := a;
 if (a in [0..20]) or ((a>340) and (a<359)) and (lastregion<>1)
    then begin
          lastregion:=1;
          Gfx^.workpal := savepal;
          for i:=0 to 255 do
              begin
               if Gfx^.workpal[i,1]<23 then inc(Gfx^.workpal[i,1],40)
                                  else Gfx^.workpal[i,1]:=63;
               if Gfx^.workpal[i,2]<23 then inc(Gfx^.workpal[i,2],40)
                                  else Gfx^.workpal[i,2]:=63;
               if Gfx^.workpal[i,3]<23 then inc(Gfx^.workpal[i,3],40)
                                  else Gfx^.workpal[i,3]:=63;
              end;
          Gfx^.SetPal;
          exit;
         end;
 if (a in [20..40]) or ((a>320) and (a<339)) and (lastregion<>2)
    then begin
          lastregion:=2;
          Gfx^.workpal := savepal;
          for i:=0 to 255 do
              begin
               if Gfx^.workpal[i,1]<43 then inc(Gfx^.workpal[i,1],20)
                                  else Gfx^.workpal[i,1]:=63;
               if Gfx^.workpal[i,2]<43 then inc(Gfx^.workpal[i,2],20)
                                  else Gfx^.workpal[i,2]:=63;
               if Gfx^.workpal[i,3]<43 then inc(Gfx^.workpal[i,3],20)
                                  else Gfx^.workpal[i,3]:=63;
              end;
          Gfx^.SetPal;
          exit;
         end;
 if lastregion<>0
    then begin
          lastregion := 0;
          Gfx^.workpal := savepal;
          Gfx^.SetPal;
         end;
end;

destructor Sun.Done;
begin
end;

constructor Animation.Init;
begin
 sprite          := whatspr-1;
 maxsprite       := maxspr;
 look            := where;
 X[1]            := 7;
 Visibility      := vis;
 ScaleFactor     := sf;
 Curent          := false;
 dispose_me      := false;
 KP              := NIL;
 OKP             := NIL;
 I_Was_Destroyed := false;
end;

procedure Animation.Strategy;
begin
 inc(sprite);
 if sprite>=maxsprite then dispose_me := true;
end;

procedure Animation.Draw;
var
   a,NewXL,NewYl : integer;
begin
 sortdistance:=nework^.DistancePP(fromlook,look);
 a:=nework^.AngleVPV(fromlook,fromvk,look);

 if (sortdistance<Visibility) and ((a>270) or (a<90))
    then begin
          if sortdistance=0 then inc(sortdistance);
          NewXL := (Gfx^.Spr[sprite].xl*ScaleFactor) div sortdistance;
          NewYL := (Gfx^.Spr[sprite].yl*ScaleFactor) div sortdistance;
          nework^.Inverter(fromvi,fromvj,fromvk);
          nework^.ProLookPoint(fromlook,look);
          Gfx^.ScaleSpr(sprite,nework^.ProWork^[1].x-NewXL div 2,nework^.ProWork^[1].y-NewYL div 2,NewXL,NewYL);
         end;
end;

destructor Animation.Done;
begin
end;

constructor MyCraft.Init;
 var
    i : integer;
begin
 X[1]:=768;
 KP := NIL;
 OKP := NIL;
 whatshape:=100;look:=sp;
 Speed:=6;ReachSpeed:=6;
 board:=false;name:='MYCRAFT';
 RadarZoom   := 1;
 LeftScreen  := 2;
 RightScreen := 3;
 with MQ do begin Crt := 1;Last := 0;end;
 with head do begin x:=0;y:=0;z:=0; end;
 with vi do begin x:=16;y:=0;z:=0;end;
 with vj do begin x:=0;y:=16;z:=0;end;
 with vk do begin x:=0;y:=0;z:=16;end;
 ovi:=vi;ovj:=vj;ovk:=vk;
 with eyevi do begin x:=16;y:=0;z:=0;end;
 with eyevj do begin x:=0;y:=16;z:=0;end;
 with eyevk do begin x:=0;y:=0;z:=16;end;
 oeyevi:=eyevi;oeyevj:=eyevj;oeyevk:=eyevk;
 dispose_me      := false;
 I_Was_Destroyed := false;
 {find a gun}
 for i:=1 to MaxWeapon do if crt_ship.carry[i].get then begin crt_ship.whatweapon:=i;break;end;
 Gfx^.LoadSpr(Crt_Ship.sprite,1);
 Gfx^.LoadSpr('rtarget0.spr',2);
 {energy settings}
 HullRU := Crt_Ship.HullRU;
 Target := NIL;
end;

procedure MyCraft.Strategy;
 var
    i   : integer;
    aux : PIntoSpace;
    cdifx,cdify,cdifz,XPro,YPro,ZPro : longint;
begin
 if curent
    then begin
          key:=port[$60];
          case key of
           80 : begin
                 center:=origin;
                 inc(head.x,3);
                 head.x:=head.x mod 360;
                 vi:=ovi;vj:=ovj;vk:=ovk;
                 nework^.rotatepoint(vi,head.x,head.y,head.z);
                 nework^.rotatepoint(vk,head.x,head.y,head.z);
                 nework^.rotatepoint(vj,head.x,head.y,head.z);
                end;
           72 : begin
                 center:=origin;
                 vi:=ovi;vj:=ovj;vk:=ovk;
                 dec(head.x,3);
                 if head.x<0 then head.x:=360-head.x;
                 nework^.rotatepoint(vi,head.x,head.y,head.z);
                 nework^.rotatepoint(vk,head.x,head.y,head.z);
                 nework^.rotatepoint(vj,head.x,head.y,head.z);
                end;
           75 : begin
                 center:=origin;
                 inc(head.z,3);
                 {inc(head.y,3);}
                 {head.y:=head.y mod 360;}
                 head.z:=head.z mod 360;
                 vi:=ovi;vj:=ovj;vk:=ovk;
                 nework^.rotatepoint(vi,head.x,head.y,head.z);
                 nework^.rotatepoint(vj,head.x,head.y,head.z);
                 nework^.rotatepoint(vk,head.x,head.y,head.z);
                end;
           77 : begin
                 center:=origin;
                 vi:=ovi;vj:=ovj;vk:=ovk;
                 {dec(head.y,3);
                 if head.y<0 then head.y:=360-head.y;}
                 dec(head.z,3);
                 if head.z<0 then head.z:=360-head.z;
                 nework^.rotatepoint(vi,head.x,head.y,head.z);
                 nework^.rotatepoint(vj,head.x,head.y,head.z);
                 nework^.rotatepoint(vk,head.x,head.y,head.z);
                end;
           {modify speed}
           78,13 : if ReachSpeed<Crt_Ship.Speed div 2 then inc(ReachSpeed);
           74,12 : if ReachSpeed>-10 then dec(ReachSpeed);
           73 : begin
                 Crt_Craft^.Curent:=false;
                 if Crt_Craft^.next=Nil then Crt_Craft:=SpaceRoot
                                        else Crt_Craft:=Crt_Craft^.Next;
                 Crt_Craft^.Curent:=true;
                end;{change view }
           48 : board := not board;{board on/off}
           1  : status := 6;{exit}
           30 : head:=origin;{kwik and dirty method to authomatic pilot}
           17 : begin
                 {change weapon}
                 i:=crt_ship.whatweapon;
                 repeat
                  inc(i);
                  if i>MaxWeapon then i:=1;
                  if crt_ship.carry[i].get then break;
                 until i=crt_ship.whatweapon;
                 crt_ship.whatweapon:=i;
                end;
            {1/3,2/3,full speed}
            53 : ReachSpeed := 0;
            26 : ReachSpeed := (crt_ship.speed) div 3;
            27 : ReachSpeed := 2*(crt_ship.speed) div 3;
            14 : ReachSpeed := crt_ship.speed;
            {enemy ship keypoints}
            51 : if Target<>NIL
                    then begin
                          inc(Target^.KP^.CKP);
                          if Target^.KP^.CKP>Target^.KP^.IKP then Target^.KP^.CKP:=1;
                         end;
            {matching speed with target}
            28 : if Target<>NIL
                    then begin
                          ReachSpeed := Target^.speed;
                          Ins2MsgQueue(MQ,'Maching speed with target',30);
                         end
                    else begin
                          Ins2MsgQueue(MQ,'No target to match speed with',30);
                         end;
            {zoom in/out radar}
            45 : begin
                  if RadarZoom<5 then inc(RadarZoom);
                  Ins2MsgQueue(MQ,'Radar Zoom set on ' + Int2Str(RadarZoom),20);
                 end;
            44 : begin
                  if RadarZoom>1 then dec(RadarZoom);
                  Ins2MsgQueue(MQ,'Radar Zoom set on ' + Int2Str(RadarZoom),20);
                 end;
            {data of on-board screens}
            2  : begin
                  inc(LeftScreen);
                  if LeftScreen>5 then LeftScreen := 1;
                 end;
            3  : begin
                  inc(RightScreen);
                  if RightScreen>5 then RightScreen := 1;
                 end;
           {exchange on-board screen}
           15  : begin
                  i := LeftScreen;
                  LeftScreen := RightScreen;
                  RightScreen := i;
                 end;
           end;
           Gfx^.FreeBuf;
           {from mouse...}
           if Mouse^.LeftButtonPressed
              then if crt_ship.carry[crt_ship.whatweapon].currentammo>0
                   then case crt_ship.whatweapon of
                         2 : begin
                              aux := new(PBullet,Init( look,vk,20,50+speed,crt_ship.carry[crt_ship.whatweapon].Name,6,1500,50,
                                                       crt_ship.carry[crt_ship.whatweapon].DrainedRU,768));
                              Crt_Pilot.Insert2GunFired(crt_ship.carry[crt_ship.whatweapon].Name);
                              Ins2Space(aux);
                              dec(crt_ship.carry[crt_ship.whatweapon].currentammo);
                             end;
                         end;
           {select a target}
           if Target<>NIL then if (Target^.dispose_me) or (Target^.I_Was_Destroyed) then Target := NIL;
           if Mouse^.RightButtonPressed
              then begin
                    aux := SpaceRoot;
                    while aux<>nil do
                          begin
                           nework^.ProLookPoint(look,aux^.look);
                           if (nework^.ProWork^[1].x in [150..170]) and
                              (nework^.ProWork^[1].y in [90..110]) and (aux^.X[1]>255)
                              then begin Target := aux;break;end;
                           aux:=aux^.next;
                          end;
                   end;

           center:=origin;
           Mouse^.X;Mouse^.Y;
           vi:=ovi;vj:=ovj;vk:=ovk;
           head.z:=head.z+Mouse^.DeltaX;
           head.y:=head.y+Mouse^.DeltaX;
           head.x:=head.x+(Mouse^.DeltaY*3) div 2;
           if head.x<0 then head.x:=360-head.x;
           if head.y<0 then head.y:=360-head.y;
           if head.z<0 then head.z:=360-head.z;
           nework^.rotatepoint(vi,head.x,head.y,head.z);
           nework^.rotatepoint(vj,head.x,head.y,head.z);
           nework^.rotatepoint(vk,head.x,head.y,head.z);
           eyevi:=vi;eyevj:=vj;eyevk:=vk;
           Mouse^.DeltaX:=0;Mouse^.DeltaY:=0;
          end;

  if look.y<10 then begin
     Ins2MsgQueue(MQ,'Imminent Crash',10);
     end;
  if (look.y>10) and (look.y<100) then begin
     Ins2MsgQueue(MQ,'Stall warning',10);
     end;

  if ReachSpeed>Speed then inc(Speed,2)
                      else if ReachSpeed<Speed then dec(Speed,2);
  look.x:=look.x-(speed div 4*vk.x) div 16;
  look.y:=look.y-(speed div 4*vk.y) div 16{-4{grav};
  look.z:=look.z-(speed div 4*vk.z) div 16;
END;

procedure MyCraft.Draw;
var xlc,xrc,ytc,ybc : word;
    a               : longint;
    i               : integer;
    aux             : PIntoSpace;
    color,xaux,yaux,
    cdifx,cdify,cdifz,
    XPro,YPro,ZPro  : longint;
    LRadarMidX,LRadarMidY,
    RRadarMidX,RRadarMidY : integer;
    str             : string;
BEGIN {my_craft - DRAW procedure}
 if curent
    then begin
          if Target <> NIL
             then begin
                   nework^.ProLookPoint(look,Target^.look);
                   {Gfx^.Rectangle( nework^.ProWork^[1].x-10,nework^.ProWork^[1].y-10,
                                   nework^.ProWork^[1].x+10,nework^.ProWork^[1].y+10,255,vaddr);}
                   Gfx^.NCircle(nework^.ProWork^[1].x,nework^.ProWork^[1].y,15,255,vaddr);
                   Gfx^.Outtext(
                    nework^.ProWork^[1].x-30,nework^.ProWork^[1].y-17,'spd:'+Int2Str(Target^.speed),6,255,vaddr);
                   Gfx^.Outtext(
                    nework^.ProWork^[1].x+10,nework^.ProWork^[1].y-17,'dst:'+Int2Str(Target^.sortdistance),6,255,vaddr);
                   Gfx^.Outtext(
                    nework^.ProWork^[1].x+10,nework^.ProWork^[1].y+11,'alt:'+Int2Str(Target^.look.y),6,255,vaddr);
                   Gfx^.Outtext(
                    nework^.ProWork^[1].x-5*(fonts[6].x+1),nework^.ProWork^[1].y-14-2*fonts[6].y,'TARGET='+Target^.FlightInd,
                    6,255,vaddr);
                   Gfx^.Outtext(
                    nework^.ProWork^[1].x-30,nework^.ProWork^[1].y+11,'dmg:'+Int2Str(Target^.KP^.AKP[Target^.KP^.CKP].damage
                    div 10)+'%',6,255,vaddr);
                   if Target^.KP<>NIL then begin
                      nework^.ProLookPoint(look,Target^.KP^.AKP[Target^.KP^.CKP].pos);
                      Gfx^.Rectangle( nework^.ProWork^[1].x-2,nework^.ProWork^[1].y-2,
                                      nework^.ProWork^[1].x+2,nework^.ProWork^[1].y+2,176,vaddr);
                      case Target^.KP^.AKP[Target^.KP^.CKP].code of
                       0 : str := 'ENGINE';
                       1 : str := 'RADAR';
                       2 : str := 'CANNON';
                       3 : str := 'CANNON';
                       4 : str := 'HULL';
                       5 : str := 'BAY';
                       6 : str := 'ROCKET';
                       7 : str := 'ROCKET';
                       8 : str := 'GND';
                       9 : str := 'HANGAR';
                      10,11 : str := 'WING';
                      12 : str := 'WHEEL';
                         else str := 'UNK';
                      end;
                   Gfx^.Outtext( nework^.ProWork^[1].x-((fonts[6].x+1)*length(str)) div 2,nework^.ProWork^[1].y-3-fonts[6].y,
                                 str,6,176,vaddr);
                  end;
                  end;
          if board
             then begin
                   Xlc:=xleftclip;Xrc:=xrightclip;Ytc:=ytopclip;Ybc:=ybotclip;
                   xleftclip:=0;xrightclip:=319;ytopclip:=0;ybotclip:=199;
                   Gfx^.PutSpr(1,0,0,gameput,vaddr);
                   xleftclip:=xlc;xrightclip:=xrc;ytopclip:=ytc;ybotclip:=ybc;
                  end;
          {put}
          Gfx^.PutSpr(2,orgx-Gfx^.spr[2].xl div 2,orgy-Gfx^.spr[2].yl div 2,gameput,vaddr);
          {draw the target selection - if any that rectangle}
          if board
             then begin
                   case LeftScreen of
                   3 : {put the current weapon}
                       Gfx^.PutSpr( Crt_Ship.whatweapon+20,
                                    Crt_Ship.Gadgets[byte(board),3].x,
                                    Crt_Ship.Gadgets[byte(board),3].y,
                                    gameput,vaddr);
                   5 : for i:=1 to 10 do Gfx^.outtext( Crt_Ship.Gadgets[byte(board),3].x,
                                                       Crt_Ship.Gadgets[byte(board),3].y+i*(fonts[6].y+1),
                                                       Crt_Mission.MiniBrief[i],6,255,vaddr);
                   2 : begin
                        aux:=SpaceRoot;
                        while aux<>nil do
                              begin
                               if aux^.x[1]>255
                                  then begin
                                        if (aux^.x[1]>767) then color:=115{friends}
                                           else if aux^.x[1]>511 then color:=192{enemies}
                                                else if aux^.x[1]>384 then color:=124{missiles}
                                                     else color := 109;{buildings}
                                        with My_Craft^ do
                                         Gfx^.putpixel(
                                         Crt_Ship.Gadgets[byte(board),3].x+round(RadarZoom*10*((-aux^.look.z)/65535)+23),
                                         Crt_Ship.Gadgets[byte(board),3].y+round(RadarZoom*10*((-aux^.look.x)/65535)+28),
                                         color,vaddr);
                                       end;
                               aux:=aux^.next;
                              end;
                       end;
                   end;
                   case RightScreen of
                   3 : {put the current weapon}
                       Gfx^.PutSpr( Crt_Ship.whatweapon+20,
                                    Crt_Ship.Gadgets[byte(board),2].x,
                                    Crt_Ship.Gadgets[byte(board),2].y,
                                    gameput,vaddr);
                   5 : for i:=1 to 10 do Gfx^.outtext( Crt_Ship.Gadgets[byte(board),2].x,
                                                       Crt_Ship.Gadgets[byte(board),2].y+i*(fonts[6].y+1),
                                                       Crt_Mission.MiniBrief[i],6,255,vaddr);
                   2 : begin
                        aux:=SpaceRoot;
                        while aux<>nil do
                              begin
                               if aux^.x[1]>255
                                  then begin
                                        if (aux^.x[1]>767) then color:=115{friends}
                                           else if aux^.x[1]>511 then color:=192{enemies}
                                                else if aux^.x[1]>384 then color:=124{missiles}
                                                     else color := 109;{buildings}
                                        with My_Craft^ do
                                         Gfx^.putpixel(
                                         Crt_Ship.Gadgets[byte(board),2].x+round(RadarZoom*10*((-aux^.look.z)/65535)+23),
                                         Crt_Ship.Gadgets[byte(board),2].y+round(RadarZoom*10*((-aux^.look.x)/65535)+28),
                                         color,vaddr);
                                       end;
                               aux:=aux^.next;
                              end;
                       end;
                   end;
                  end;

          {put depth radars-left & right}
          Gfx^.putspr( 9,Crt_Ship.gadgets[byte(board),5].x,Crt_Ship.gadgets[byte(board),5].y,gameput,vaddr);
          Gfx^.putspr(10,Crt_Ship.gadgets[byte(board),6].x,Crt_Ship.gadgets[byte(board),6].y,gameput,vaddr);
          nework^.Inverter(vi,vj,vk);
          aux := SpaceRoot;
          LRadarMidX := Crt_Ship.gadgets[0,5].x+Gfx^.Spr[10].xl div 2;
          LRadarMidY := Crt_Ship.gadgets[0,5].y+Gfx^.Spr[10].yl div 2;
          RRadarMidX := Crt_Ship.gadgets[0,6].x+Gfx^.Spr[10].xl div 2;
          RRadarMidY := Crt_Ship.gadgets[0,6].y+Gfx^.Spr[10].yl div 2;
          while aux<>nil do
                begin
                 cdifx:=(look.x-aux^.look.x);
                 cdify:=(look.y-aux^.look.y);
                 cdifz:=(look.z-aux^.look.z);

                 XPro:=
                        cdifx*nework^.Invert[1,1]+
                        cdify*nework^.Invert[2,1]+
                        cdifz*nework^.Invert[3,1];
                 YPro:=
                        cdifx*nework^.Invert[1,2]+
                        cdify*nework^.Invert[2,2]+
                        cdifz*nework^.Invert[3,2];
                 ZPro:=
                        cdifx*nework^.Invert[1,3]+
                        cdify*nework^.Invert[2,3]+
                        cdifz*nework^.Invert[3,3];

                 if ZPro<>0
                    then begin
                          xaux :=((XPro shl 7) div ZPro);
                          yaux := ((YPro shl 7) div ZPro);
                         end
                    else begin
                          xaux := MaxInt;
                          yaux := MaxInt;
                         end;

                 if abs(xaux)>300 then xaux := nework^.sign(xaux)*15
                                  else xaux := (xaux*15) div 300;
                 if abs(yaux)>300 then yaux := nework^.sign(yaux)*15
                                  else yaux := (yaux*15) div 300;

                 if aux^.X[1]>255
                    then begin
                          if (aux^.x[1]>767) then color:=115{friends}
                             else if aux^.x[1]>511 then color:=192{enemies}
                                  else if aux^.x[1]>384 then color:=124{missiles}
                                       else color := 109;{buildings}
                          if ZPro>0 then Gfx^.putpixel(LRadarMidX +xaux,LRadarMidY+yaux,color,vaddr)
                                    else Gfx^.putpixel(RRadarMidX +xaux,RRadarMidY+yaux,color,vaddr);
                          if aux=Target
                             then if ZPro>0
                                  then begin
                                        Gfx^.Outtext( LRadarMidX+xaux-3,LRadarMidY+yaux-2,'[',6,187,vaddr);
                                        Gfx^.Outtext( LRadarMidX+xaux-1,LRadarMidY+yaux-2,']',6,187,vaddr);
                                       end
                                  else begin
                                        Gfx^.Outtext( RRadarMidX+xaux-3,RRadarMidY+yaux-2,'[',6,187,vaddr);
                                        Gfx^.Outtext( RRadarMidX+xaux-1,RRadarMidY+yaux-2,']',6,187,vaddr);
                                       end;

                         end;
                 aux := aux^.next;
                end;

          with MQ do
          if Last<>0 then
             if Msgs[Crt].Time>0
                then begin
                      Gfx^.outtext(160-length(Msgs[Crt].Text)*(fonts[6].x+1) div 2,ytopclip,Msgs[Crt].Text,6,184,vaddr);
                      dec(Msgs[Crt].Time);
                     end
                else begin
                      Msgs[Crt].Text:='';
                      inc(Crt);
                      if (Crt>Last) or (Crt>15) then begin Crt := 1;Last := 0;end;
                     end;

          Gfx^.outtext( Crt_Ship.Gadgets[byte(board),1].x,Crt_Ship.Gadgets[byte(board),1].y,
                        'spd :'+Int2Str(speed)+'m/s',6,152,vaddr);
          Gfx^.outtext( Crt_Ship.Gadgets[byte(board),1].x,Crt_Ship.Gadgets[byte(board),1].y+fonts[6].y+1,
                        'ammo  :'+Int2Str(Crt_Ship.carry[Crt_Ship.whatweapon].currentammo),6,115,vaddr);
          Gfx^.outtext( Crt_Ship.Gadgets[byte(board),1].x,Crt_Ship.Gadgets[byte(board),1].y+2*(fonts[6].y+1),
                        'alt :'+Int2Str(look.y),6,192,vaddr);
          Gfx^.outtext( Crt_Ship.Gadgets[byte(board),1].x,Crt_Ship.Gadgets[byte(board),1].y+3*(fonts[6].y+1),
                        'VSI :'+Int2Str((-speed*vk.y) div 16)+'.'+Int2Str(abs((-speed*vk.y) mod 16))+'m/s',6,182,vaddr);
         end
    else begin
          nework^.rotwork:=AllObjects[whatshape]^.points;
          nework^.RotateObj(AllObjects[whatshape],270+head.x,head.y,head.z);
          nework^.DepthSort(AllObjects[whatshape],fromlook,look);
          nework^.Inverter(fromvi,fromvj,fromvk);
          nework^.ProLook(AllObjects[whatshape],fromlook,look);
          sortdistance:=nework^.DistancePP(fromlook,look);
          a:=nework^.AngleVPV(fromlook,fromvk,look);

          if (a>-50) and (a<50) then
          for i:=1 to AllObjects[whatshape]^.faceno do
              if (AllObjects[whatshape]^.planes[i].eyedist>30) and (AllObjects[whatshape]^.planes[i].eyedist<2500)then
              Gfx^.DrawPoly(
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p1].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p1].y,
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p2].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p2].y,
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p3].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p3].y,
              nework^.ProWork^[AllObjects[whatshape]^.planes[i].p4].x,nework^.ProWork^[AllObjects[whatshape]^.planes[i].p4].y,
              AllObjects[whatshape]^.planes[i].color,vaddr)
              else begin
                    Gfx^.Outtext(0,100,'Collission!',6,255,vaddr);
                    Gfx^.Outint(0,110,i,6,255,vaddr);
                   end;
         end;
end;

destructor MyCraft.Done;
begin
 Gfx^.DoneSpr(1);
 Gfx^.DoneSpr(2);
end;

constructor Sky.Init;
begin
 X[1] := 0;
end;

procedure Sky.Draw;
var look1,look2,look3,look4 : point3d;
    a1,a2,a3,a4,i : integer;
begin

 nework^.rotwork:=AllObjects[90]^.points;
 nework^.RotateObj(AllObjects[90],360-Crt_Craft^.head.x,0,0{360-Crt_Craft^.head.z});

 nework^.Inverter(fromvi,fromvj,fromvk);
 nework^.ProLook(AllObjects[90],fromlook,look);
 {sortdistance:=nework^.DistancePP(fromlook,look);}

 for i:=1 to AllObjects[90]^.faceno do
     begin
      look1.x := look.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].x;
      look1.y := look.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].y;
      look1.z := look.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p1].z;

      look2.x := look.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].x;
      look2.y := look.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].y;
      look2.z := look.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p2].z;

      look3.x := look.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].x;
      look3.y := look.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].y;
      look3.z := look.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p3].z;

      look4.x := look.x+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].x;
      look4.y := look.y+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].y;
      look4.z := look.z+AllObjects[90]^.points[AllObjects[90]^.planes[i].p4].z;

      a1 := nework^.RealAngleVPV(fromlook,fromvk,look1);
      a2 := nework^.RealAngleVPV(fromlook,fromvk,look2);
      a3 := nework^.RealAngleVPV(fromlook,fromvk,look3);
      a4 := nework^.RealAngleVPV(fromlook,fromvk,look4);

      if (a1<120) or (a1>240) or (a2<120) or (a2>240) or (a3<120) or (a3>240)
         or (a4<120) or (a4>240) then
           Gfx^.DrawPoly(
            nework^.ProWork^[AllObjects[90]^.planes[i].p1].x,nework^.ProWork^[AllObjects[90]^.planes[i].p1].y,
            nework^.ProWork^[AllObjects[90]^.planes[i].p2].x,nework^.ProWork^[AllObjects[90]^.planes[i].p2].y,
            nework^.ProWork^[AllObjects[90]^.planes[i].p3].x,nework^.ProWork^[AllObjects[90]^.planes[i].p3].y,
            nework^.ProWork^[AllObjects[90]^.planes[i].p4].x,nework^.ProWork^[AllObjects[90]^.planes[i].p4].y,
            AllObjects[90]^.planes[i].color,vaddr);
      end;
end;

procedure Sky.Strategy;
begin
  look.x:=look.x-(Crt_Craft^.speed div 4*Crt_Craft^.vk.x) div 16;
  look.y:=look.y-(Crt_Craft^.speed div 4*Crt_Craft^.vk.y) div 16{-4{grav};
  look.z:=look.z-(Crt_Craft^.speed div 4*Crt_Craft^.vk.z) div 16;
end;

destructor Sky.Done;
begin
end;

BEGIN
END.