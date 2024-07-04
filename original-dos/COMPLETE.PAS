UNIT
    COMPLETE;

INTERFACE

USES
    GRAPHICS,SBLASTER;
TYPE
    App_Dummy2 = object(App_Graph)
               constructor Init;
               destructor Done;
               end;
    PApp_Complete = ^App_Complete;
    App_Complete = object(App_Graph)
                 constructor Init;
                 destructor Done;
                 end;

IMPLEMENTATION

constructor App_Dummy2.Init;
begin
 inherited Init;
end;

destructor App_Dummy2.Done;
begin
 inherited Done;
end;
constructor App_Complete.Init;
begin
 inherited Init;
end;

destructor App_Complete.Done;
begin
 inherited Done;
end;
BEGIN
END.
