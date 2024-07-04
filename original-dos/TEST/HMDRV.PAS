UNIT
    HMDRV;

INTERFACE

TYPE
    {general purpose object - father for XMS and EMS}
    HM = object
         Exist  :  boolean;
         constructor Init;
         function    Alloc    (length : word) : word;
         procedure   Move     (Src,Dst : pointer;SrcH,DstH : word);
         procedure   Lock     (handle : word);
         procedure   UnLock   (handle : word);
         procedure   Dispose  (handle : word);
         function    MemAvail : word;
         function    MaxAvail : word;
         destructor  Done;
        end;

IMPLEMENTATION

TYPE

BEGIN
END.