uses space,structs,pilot;
var P : Tpilot;
    j : integer;
    S : App;
begin
 randomize;
 writeln(sizeof(TPilot));
 s.initpath;
 for j:=1 to 7 do
     begin
      P.FileName := 'Pilot'+char(j+48)+'.plt';
      P.Name := 'KARG'+char(j+48);
      P.Clear;
      P.RankStr := 'COLONEL';
      P.CrtDiskPos := 0;
      P.Save;
     end;
end.
