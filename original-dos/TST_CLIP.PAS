uses graphics;
var x1,x2,y1,y2,aux,temp : integer;
    xinc : longint;
begin
  x1:=-50;y1:=-10;x2:=300;y2:=300;
  if y1=y2 then {y2:=y1+1}exit;
  if y2<y1 then BEGIN
    temp:=y2;
    y2:=y1;
    y1:=temp;
    temp:=x2;
    x2:=x1;
    x1:=temp;
  END;
  xinc:=round(128*((x2-x1)/(y2-y1)));

  if y2>ybotclip
     then begin
           y2:=ybotclip;
           x2:=x1+((y2-y1)*xinc) shr 7;
          end;
  if y2<ytopclip
     then begin
           y2:=ytopclip;
           x2:=x1+((y2-y1)*xinc) shr 7;
          end;

  if y1>ybotclip
     then begin
           aux:=y1;
           y1:=ybotclip;
           x1:=x1+((y1-aux)*xinc) shr 7;
          end;
  if y1<ytopclip
     then begin
           aux:=y1;
           y1:=ytopclip;
           x1:=x1+((y1-aux)*xinc) shr 7;
          end;

end.