UNIT
    TYPES3D;
{$Q-}
{$R-}
INTERFACE

USES
    STRUCTS;

CONST
      MaxFace = 50;
      Orgx    : integer = 160;
      Orgy    : integer = 100;
      Z0      : integer = 128;
TYPE
      Point3D = RECORD
             X,Y,Z : integer;
             END;
      Point2D = RECORD
             X,Y : integer;
             END;
      Plan3D  = RECORD
             P1,P2,P3,P4 : Point3D;
             Color       : byte;
             EyeDist     : longint;
             END;
      Ec_plan = RECORD
              a,b,c,d : real;
              end;
      Plan2D  = RECORD
              P1,P2,P3,P4: Point2D;
              END;
      Rect = RECORD
           P1,P2 : Point2D;
           END;
      PObj    = ^Obj;
      Obj     = RECORD
                 Form : ARRAY[1..MaxFace] of Plan3D;
                 Face : byte;
                 Core : Point3D;{the coordinator of objects movements}
                END;

      PointedPlane = record
                   P1,P2,P3,P4 : byte;
                   Color : byte;
                   EyeDist : longint;
                   end;

      Scheme = ARRAY[1..225] of Point3D;
      PNewObj = ^NewObj;
      NewObj = RECORD
             Points   : Scheme;{core if pointsno+1 point}
             Planes   : ARRAY[1..100] of PointedPlane;
             FaceNo   : byte;
             PointsNo : byte;
             END;

      ProObj    = ARRAY[1..225] OF Plan2D;
      PProObj   = ^ProObj;
      NewProObj = ARRAY[1..225] of Point2D;
      PNewProObj = ^NewProObj;
      LookUpTab = ARRAY[0..359] OF integer;

      PApp_3D = ^App_3D;
      App_3D = object(App)
             ProWork   : PProObj;
             RotWork   : PObj;
             constructor Init;
             procedure RotatePoint (VAR P : Point3D;x,y,z : integer);
             procedure RotateObj   (x,y,z : integer);
             procedure DepthSort   ;
             procedure Project     ;
             procedure LoadShape   (fname : string;VAR O : PObj);
             destructor Done;
             end;

      PNewApp_3D = ^NewApp_3D;
      NewApp_3D = object(App)
             ProWork   : PNewProObj;
             RotWork   : Scheme;
             Invert    : array[1..3,1..3] of longint;
             constructor Init;
             procedure RotatePoint (VAR P : Point3D;x,y,z : integer);
             procedure RotateObj   (Base : PNewObj;x,y,z : integer);
             procedure DepthSort   (Base : PNewObj;var viewpoint,wherepoint : point3d);
             procedure Project     (Base : PNewObj);
             procedure ProLook     (Base : PNewObj;viewpoint,wherepoint : point3d);
             procedure ProLookPoint(viewpoint,wherepoint : point3d);
             procedure Inverter    (vi,vj,vk : point3d);
             function  Sign(what : longint) : integer;
             function  AngleVPV(var c,p1,p2 : point3d) : integer;
             function  AngleVV(var p1,p2 : point3d) : integer;
             function  RealAngleVPV(var c,p1,p2 : point3d) : integer;
             function  RealAngleVV(var p1,p2 : point3d) : integer;
             function  DistancePP(var p1,p2 : point3d) : longint;
             destructor Done;
             end;

CONST
      origin    : point3d=(x:0;y:0;z:0);
      viewplane : ec_plan=(a:0;b:0;c:1;d:0);

VAR
    Sint,Cost : LookUpTab;
    Look      : point3d;
    Center    : point3d;
    Work      : PApp_3D;
    NeWork    : PNewApp_3D;

IMPLEMENTATION

constructor App_3D.Init;
 VAR
    i : integer;
BEGIN
 with center do begin x:=0;y:=0;z:=0; end;
 for i:=0 to 359 do
     begin
      sint[i]:=round(sin(i*pi/180)*16384);
      cost[i]:=round(cos(i*pi/180)*16384);
     end;
 new(ProWork);new(RotWork);
END;

procedure App_3D.RotatePoint;

VAR
   a,b,c : integer;
   PRot  : Point3D;

BEGIN
 x:=x mod 360;y:=y mod 360;z:=z mod 360;

 b:=cost[y];
 c:=P.x-center.x;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   mov   a,dx
 end;
 b:=sint[y];
 c:=P.z-center.z;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   add   a,dx
 end;
 PRot.x:=a;
 PRot.y:=P.y-center.y;
 b:=-sint[y];
 c:=P.x-center.x;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   mov   a,dx
 end;
 b:=cost[y];
 c:=P.z-center.z;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   add   a,dx
 end;
 PRot.z:=a+center.z;


 if x<>0 then BEGIN
   b:=cost[x];
   c:=PRot.y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=sint[x];
   c:=PRot.z-center.z;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     sub   a,dx
   end;
   b:=sint[x];
   c:=PRot.y-center.y;
   PRot.y:=a-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=cost[x];
   c:=PRot.z-center.z;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     add   a,dx
   end;
   PRot.z:=a+center.z;
 END;




 if z<>0 then BEGIN
   b:=cost[z];
   c:=PRot.x-center.x;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=sint[z];
   c:=PRot.y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     sub   a,dx
   end;
   b:=sint[z];
   c:=PRot.x-center.x;
   PRot.x:=a+center.x;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=cost[z];
   c:=PRot.y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     add   a,dx
   end;
   PRot.y:=a-center.y;
 END;
 P:=PRot;
END;{end procedure rotate point}


PROCEDURE App_3D.RotateObj;
 VAR i : integer;
BEGIN
 for i:=1 to RotWork^.face do
     begin
      RotatePoint(RotWork^.Form[i].P1,x,y,z);
      RotatePoint(RotWork^.Form[i].P2,x,y,z);
      RotatePoint(RotWork^.Form[i].P3,x,y,z);
      RotatePoint(RotWork^.Form[i].P4,x,y,z);
     end;
 RotatePoint(RotWork^.core,x,y,z);
END;{end procedure rotate obj}

PROCEDURE App_3D.DepthSort;
 VAR i,j   : integer;
     temp  : Plan3d;

procedure Kwik (first,last:integer);

var
    i,j   : integer;
    mid   : integer;

begin
 i:=first;
 j:=last;
 mid:=RotWork^.Form[(i+j) div 2].EyeDist;
 repeat
  while RotWork^.Form[i].EyeDist<mid do inc(i);
  while RotWork^.Form[j].EyeDist>mid do dec(j);
  if i<=j
     then begin
          temp:=RotWork^.Form[i];
          RotWork^.Form[i]:=RotWork^.Form[j];
          RotWork^.Form[j]:=temp;
          dec(j);
          inc(i);
          end;
 until i>j;
 if first<j then Kwik(first,j);
 if last>i  then Kwik(i,last);
end;

BEGIN
 with RotWork^ do
 for i:=1 to Face do
     with Form[i] do
     EyeDist:= SQR((P1.X+P2.X+P4.X) div 3-look.x)+ SQR((P1.Y+P2.Y+P4.Y) div 3-look.y)+
              SQR((P1.Z+P2.Z+P4.Z) div 3-look.z);
 Kwik(1,RotWork^.Face);
END;

PROCEDURE App_3D.Project;
 var i   : integer;
     fpr : longint;
BEGIN
   for i:=RotWork^.face downto 1do
       with RotWork^.form[i] do
            begin
             if (p1.z+z0)<>0
                then fpr:=16384 div (z0+p1.z)
                else fpr:=Z0;
             ProWork^[i].p1.x:=round((fpr*p1.x) shr 7+orgx);
             ProWork^[i].p1.y:=round((fpr*p1.y) shr 7+orgy);
             if (p2.z+z0)<>0
                then fpr:=16384 div (z0+p2.z)
                else fpr:=Z0;
             ProWork^[i].p2.x:=round((fpr*p2.x) shr 7+orgx);
             ProWork^[i].p2.y:=round((fpr*p2.y) shr 7+orgy);
             if (p3.z+z0)<>0
                then fpr:=16384 div (z0+p3.z)
                else fpr:=Z0;
             ProWork^[i].p3.x:=round((fpr*p3.x) shr 7+orgx);
             ProWork^[i].p3.y:=round((fpr*p3.y) shr 7+orgy);
             if (p4.z+z0)<>0
                then fpr:=16384 div (z0+p4.z)
                else fpr:=Z0;
             ProWork^[i].p4.x:=round((fpr*p4.x) shr 7+orgx);
             ProWork^[i].p4.y:=round((fpr*p4.y) shr 7+orgy);
            end;
END;

procedure App_3D.LoadShape;
 var f : file of Obj;
begin
 assign(f,shapepath+fname);
 reset(f);
 read(f,O^);
 close(f);
end;

destructor App_3D.Done;
BEGIN
 inherited Done;
 dispose(ProWork);
 dispose(RotWork);
END;

constructor NewApp_3D.Init;
 VAR
    i : integer;
BEGIN
 with center do begin x:=0;y:=0;z:=0; end;
 for i:=0 to 359 do
     begin
      sint[i]:=round(sin(i*pi/180)*16384);
      cost[i]:=round(cos(i*pi/180)*16384);
     end;
 new(ProWork);
END;

procedure NewApp_3D.RotatePoint;

VAR
   a,b,c : integer;
   PRot  : Point3D;

BEGIN
 x:=x mod 360;y:=y mod 360;z:=z mod 360;

 b:=cost[y];
 c:=P.x-center.x;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   mov   a,dx
 end;
 b:=sint[y];
 c:=P.z-center.z;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   add   a,dx
 end;
 PRot.x:=a;
 PRot.y:=P.y-center.y;
 b:=-sint[y];
 c:=P.x-center.x;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   mov   a,dx
 end;
 b:=cost[y];
 c:=P.z-center.z;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   add   a,dx
 end;
 PRot.z:=a+center.z;


 if x<>0 then BEGIN
   b:=cost[x];
   c:=PRot.y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=sint[x];
   c:=PRot.z-center.z;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     sub   a,dx
   end;
   b:=sint[x];
   c:=PRot.y-center.y;
   PRot.y:=a-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=cost[x];
   c:=PRot.z-center.z;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     add   a,dx
   end;
   PRot.z:=a+center.z;
 END;




 if z<>0 then BEGIN
   b:=cost[z];
   c:=PRot.x-center.x;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=sint[z];
   c:=PRot.y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     sub   a,dx
   end;
   b:=sint[z];
   c:=PRot.x-center.x;
   PRot.x:=a+center.x;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=cost[z];
   c:=PRot.y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     add   a,dx
   end;
   PRot.y:=a-center.y;
 END;
 P:=PRot;
END;{end procedure rotate point}


PROCEDURE NewApp_3D.RotateObj;
 VAR i : integer;
BEGIN
 for i:=1 to Base^.PointsNo+1 do RotatePoint(RotWork[i],x,y,z);
END;{end procedure rotate obj}

PROCEDURE NewApp_3D.DepthSort;
 VAR i,j   : integer;
     temp  : PointedPlane;
     a1,a2,a3 : longint;

procedure Kwik (first,last:integer);
var
    i,j   : integer;
    mid   : integer;
begin
 i:=first;
 j:=last;
 mid:=Base^.Planes[(i+j) div 2].EyeDist;
 repeat
  while (Base^.Planes[i].EyeDist<mid) and (i<last) do inc(i);
  while (Base^.Planes[j].EyeDist>mid) and (j>first) do dec(j);
  if i<=j
     then begin
           temp:=Base^.Planes[i];
           Base^.Planes[i]:=Base^.Planes[j];
           Base^.Planes[j]:=temp;
           dec(j);
           inc(i);
          end;
 until i>j;
 if first<j then Kwik(first,j);
 if last>i  then Kwik(i,last);
end;

BEGIN
 for i:=1 to Base^.FaceNo do
     with Base^.Planes[i] do
          begin
           a1:=(RotWork[P1].X+RotWork[P2].X+RotWork[P3].X) div 3+wherepoint.x-viewpoint.x;
           a2:=(RotWork[P1].Y+RotWork[P2].Y+RotWork[P3].Y) div 3+wherepoint.y-viewpoint.y;
           a3:=(RotWork[P1].Z+RotWork[P2].Z+RotWork[P3].Z) div 3+wherepoint.z-viewpoint.z;
           EyeDist:=round(sqrt(abs(a1*a1+a2*a2+a3*a3)));
          end;
 Kwik(1,Base^.FaceNo);
END;

PROCEDURE NewApp_3D.Project;
 var i   : integer;
     fpr : longint;
BEGIN
   for i:=Base^.PointsNo downto 1 do
            begin
             if (Rotwork[i].z+look.z)<>0
                then fpr:=16384 div (look.z+Rotwork[i].z)
                else fpr:=look.z;
             ProWork^[i].x:=(fpr*Rotwork[i].x) shr 7+orgx;
             ProWork^[i].y:=(fpr*Rotwork[i].y) shr 7+orgy;
            end;
END;


procedure NewApp_3D.Inverter;
BEGIN
 Invert[1,1]:=vj.y*vk.z-vj.z*vk.y;
 Invert[1,2]:=vi.z*vk.y-vi.y*vk.z;
 Invert[1,3]:=vi.y*vj.z-vi.z*vj.y;
 Invert[2,1]:=vj.z*vk.x-vj.x*vk.z;
 Invert[2,2]:=vi.x*vk.z-vi.z*vk.x;
 Invert[2,3]:=vj.x*vi.z-vi.x*vj.z;
 Invert[3,1]:=vj.x*vk.y-vk.x*vj.y;
 Invert[3,2]:=vk.x*vi.y-vi.x*vk.y;
 Invert[3,3]:=vi.x*vj.y-vi.y*vj.x;
{
 Invert[1][1]:=Direct[2][2]*Direct[3][3]-Direct[2][3]*Direct[3][2];
 Invert[1][2]:=Direct[1][3]*Direct[3][2]-Direct[1][2]*Direct[3][3];
 Invert[1][3]:=Direct[1][2]*Direct[2][3]-Direct[1][3]*Direct[2][2];
 Invert[2][1]:=Direct[2][3]*Direct[3][1]-Direct[2][1]*Direct[3][3];
 Invert[2][2]:=Direct[1][1]*Direct[3][3]-Direct[1][3]*Direct[3][1];
 Invert[2][3]:=Direct[2][1]*Direct[1][3]-Direct[1][1]*Direct[2][3];
 Invert[3][1]:=Direct[2][1]*Direct[3][2]-Direct[3][1]*Direct[2][2];
 Invert[3][2]:=Direct[3][1]*Direct[1][2]-Direct[1][1]*Direct[3][2];
 Invert[3][3]:=Direct[1][1]*Direct[2][2]-Direct[1][2]*Direct[2][1];
}
END;

procedure NewApp_3D.ProLook;
var XPro,YPro,ZPro : longint;
    fpr : real;
    i : integer;
    difx,dify,difz,cdifx,cdify,cdifz,num : longint;
BEGIN
 difx:=(viewpoint.x-wherepoint.x);
 dify:=(viewpoint.y-wherepoint.y);
 difz:=(viewpoint.z-wherepoint.z);

 for i:=1 to Base^.PointsNo do
            begin
{
             XPro:= difx+
                    RotWork[i].x*Invert[1,1]+
                    RotWork[i].y*Invert[2,1]+
                    RotWork[i].z*Invert[3,1];
             YPro:= dify+
                    RotWork[i].x*Invert[1,2]+
                    RotWork[i].y*Invert[2,2]+
                    RotWork[i].z*Invert[3,2];
             ZPro:= difz+
                    RotWork[i].x*Invert[1,3]+
                    RotWork[i].y*Invert[2,3]+
                    RotWork[i].z*Invert[3,3];
}
             cdifx:=RotWork[i].x+difx;
             cdify:=RotWork[i].y+dify;
             cdifz:=RotWork[i].z+difz;

             XPro:=
                    cdifx*Invert[1,1]+
                    cdify*Invert[2,1]+
                    cdifz*Invert[3,1];
             YPro:=
                    cdifx*Invert[1,2]+
                    cdify*Invert[2,2]+
                    cdifz*Invert[3,2];
             ZPro:=
                    cdifx*Invert[1,3]+
                    cdify*Invert[2,3]+
                    cdifz*Invert[3,3];

             if ZPro>0
                then begin
                      ProWork^[i].x:=((XPro shl 7) div ZPro)+orgx;
                      ProWork^[i].y:=((YPro shl 7) div ZPro)+orgy;
                     end
                else begin
                      ProWork^[i].x:=MaxInt;
                      ProWork^[i].y:=MaxInt;
                     end;

            end;
END;

procedure NewApp_3D.ProLookPoint;
var XPro,YPro,ZPro : longint;
    fpr : real;
    i : integer;
    difx,dify,difz,cdifx,cdify,cdifz,num : longint;
BEGIN
 cdifx:=(viewpoint.x-wherepoint.x);
 cdify:=(viewpoint.y-wherepoint.y);
 cdifz:=(viewpoint.z-wherepoint.z);

 XPro:=
        cdifx*Invert[1,1]+
        cdify*Invert[2,1]+
        cdifz*Invert[3,1];
 YPro:=
        cdifx*Invert[1,2]+
        cdify*Invert[2,2]+
        cdifz*Invert[3,2];
 ZPro:=
        cdifx*Invert[1,3]+
        cdify*Invert[2,3]+
        cdifz*Invert[3,3];

 if ZPro>0
    then begin
          ProWork^[1].x:=((XPro shl 7) div ZPro)+orgx;
          ProWork^[1].y:=((YPro shl 7) div ZPro)+orgy;
         end
    else begin
          ProWork^[1].x:=MaxInt;
          ProWork^[1].y:=MaxInt;
         end;
END;


function NewApp_3D.Sign;
BEGIN
 if what<0 then Sign:=-1
           else if what>0 then Sign:=1
                          else Sign:=0;
END;

function NewApp_3D.AngleVPV;
var s11,s21,s31,s12,s22,s32 : longint;
    a,m1pm2                 : longint;
    i                       : integer;
BEGIN
 s12:=(c.x-p2.x) div 16;s22:=(c.y-p2.y) div 16;s32:=(c.z-p2.z) div 16;
 m1pm2:=round(sqrt(abs((p1.x*p1.x+p1.y*p1.y+p1.z*p1.z)*(s12*s12+s22*s22+s32*s32))));
 AngleVPV:=0;
 if m1pm2=0 then exit;
 a:=round(16384*((p1.x*s12+p1.y*s22+p1.z*s32)/m1pm2));
 for i:=0 to 359 do
     if (cost[i]<a+150) and (cost[i]>a-150)
        then begin
              AngleVPV:=i;
              exit;
             end;
END;

function NewApp_3D.AngleVV;
var s11,s21,s31,s12,s22,s32 : longint;
    a,m1pm2                 : longint;
    i                       : integer;
BEGIN
 s11:=(p2.x*p2.x+p2.y*p2.y+p2.z*p2.z);
 s21:=(p1.x*p1.x+p1.y*p1.y+p1.z*p1.z);
 s31:=round(sqrt(s11*s21));
 s12:=(p1.x*p2.x+p1.y*p2.y+p1.z*p2.z);
 a:=round(s12*16384/s31);

 for i:=0 to 359 do
     if (cost[i]<a+300) and (cost[i]>a-300)
        then begin
              AngleVV:=i;
              exit;
             end;
END;

function  NewApp_3D.DistancePP;
var s1,s2,s3 : longint;
BEGIN
 s1:=(p1.x-p2.x);s2:=(p1.y-p2.y);s3:=(p1.z-p2.z);
 DistancePP:=round(sqrt(abs(s1*s1+s2*s2+s3*s3)));
END;

function NewApp_3D.RealAngleVPV;
var s11,s21,s31,s12,s22,s32 : longint;
    a,m1pm2                 : longint;
    i,na                    : integer;
    auxpv,auxpv2            : Point3D;
    First,bv1,bv2,bv3       : boolean;
BEGIN

 RealAngleVPV := 0;
 s12:=(c.x-p2.x) div 16;s22:=(c.y-p2.y) div 16;s32:=(c.z-p2.z) div 16;
 m1pm2:=round(sqrt(abs((p1.x*p1.x+p1.y*p1.y+p1.z*p1.z)*(s12*s12+s22*s22+s32*s32))));

 auxpv.x:=abs(s22*p1.z-s32*p1.y) div 16;
 auxpv.y:=abs(-s12*p1.z+s32*p1.x) div 16;
 auxpv.z:=abs(s12*p1.y-s22*p1.x) div 16;

 auxpv2.x:=abs(-p1.y*auxpv.z+p1.z*auxpv.y) div 16;
 auxpv2.y:=abs(p1.x*auxpv.z-p1.z*auxpv.x) div 16;
 auxpv2.z:=abs(-p1.x*auxpv.y+p1.y*auxpv.x) div 16;

 if (Sign(auxpv2.x)=Sign(s12)) or (Sign(s12)=0) or (Sign(auxpv2.x)=0)
    then bv1:=true
    else bv1:=false;
 if (Sign(auxpv2.y)=Sign(s22)) or (Sign(s22)=0) or (Sign(auxpv2.y)=0)
    then bv2:=true
    else bv2:=false;
 if (Sign(auxpv2.z)=Sign(s32)) or (Sign(s32)=0) or (Sign(auxpv2.z)=0)
    then bv3:=true
    else bv3:=false;

 if bv1 and bv2 and bv3
    then First:=False
    else First:=True;

 if m1pm2<>0 then a:=round(16384*((p1.x*s12+p1.y*s22+p1.z*s32)/m1pm2))
             else exit;
 for i:=0 to 359 do
     if (cost[i]<a+150) and (cost[i]>a-150)
        then if First
                then begin
                      RealAngleVPV:=i;
                      break;
                     end
                else First:=not First;
END;

function NewApp_3D.RealAngleVV;
BEGIN
END;

destructor NewApp_3D.Done;
BEGIN
 inherited Done;
 dispose(ProWork);
END;

BEGIN
END.