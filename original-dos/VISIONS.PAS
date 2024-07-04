UNIT
    VISIONS;{from the dark side}

INTERFACE

USES
    GRAPHICS,STRUCTS,MOUSEDRV,CRT,DOS,TYPES3D;

CONST
     cmNoAction = 0;
     cmKbd      = 10;
     cmExit     = 15;

TYPE
    PApp_View = ^App_View;
    App_View = object(App_Graph)
              Action : word;
              WinActive : boolean;
              ViewName   : string;
              ViewX,ViewY : integer;
              SelX,Sely : integer;
              constructor Init(name : string; fname : string; x,y : integer; act : word);
              procedure DrawView(where : word);virtual;
              procedure InsertItem(what : PApp_View);virtual;{never used by this object - only for TGroup}
              function Selected(x,y : integer): boolean;virtual;
              destructor Done;virtual;
             end;

    PItem = ^Item;
    Item = record
         Info : PApp_View;
         Ant ,Next : PItem;
         end;

    PTitle   = ^Title;
     Title   = string[30];
    PString  = ^String;
    PLongInt = ^LongInt;
    PInt     = ^Integer;

    PStrList = ^StrList;
     StrList = record
             Info : PTitle;
             Next : PStrList;
             end;

    PMenu = ^Menu;
    PMenuItem = ^MenuItem;
     MenuItem = record
              Next : PMenuItem;
              Name : Title;
              Command : Word;
              SprIfSel,DirIfSel : integer;
              SubMenu : PMenu;
              end;

     Menu = record
             Items : PMenuItem;
             end;

    CommZone = array[1..128] of integer;


   PApp_Cluster = ^App_Cluster;
    App_Cluster = object(App_View)
                FirstStr : PStrList;
                Value    : byte; { max 8 options }
                constructor Init(name : Title;act : word;v : byte;x,y : integer;First : PStrList);
                procedure DrawView(where : word);virtual;
                function Selected(x,y : integer) : boolean;virtual;
                destructor Done;virtual;
                end;

   PApp_RadioBtn = ^App_RadioBtn;
    App_RadioBtn = object(App_Cluster)
                 function Selected(x,y : integer) : boolean;virtual;
                 end;

   PApp_CheckBtn = ^App_CheckBtn;
    App_CheckBtn = object(App_Cluster)
                 function Selected(x,y : integer) : boolean;virtual;
                 end;

   PClusterList = ^ClusterList;
    ClusterList = record
                Info : PApp_Cluster;
                Next : PClusterList;
                end;

   PApp_Dialog = ^App_Dialog;
    App_Dialog = object(App_View)
               FirstCluster : PClusterList;
               constructor Init(vname : Title;x,y,xl,yl : integer);
               procedure Link(What : PApp_Cluster);
               procedure UnLink;
               function Selected(x,y : integer) : boolean;virtual;
               procedure DrawView(where : word);virtual;
               destructor Done;virtual;
               end;

   PApp_Btn = ^App_Btn;
    App_Btn = object(App_View)
            Press : boolean;
            constructor Init(name : Title;fnamepress,fnamerel : string;x,y : integer;act : word);
            function Selected(x,y : integer) : boolean;virtual;
            procedure DrawView(where : word);virtual;
            destructor Done;virtual;
            end;

   PApp_Btn2 = ^App_Btn2;
    App_Btn2 = object(App_View)
            Press : boolean;
            ViewLX,ViewLY : integer;
            WhatFont : integer;
            constructor Init(name : Title;x,y : integer;wf : integer;act : word);
            function Selected(x,y : integer) : boolean;virtual;
            procedure DrawView(where : word);virtual;
            destructor Done;virtual;
            end;

   PApp_Menu = ^App_Menu;
    App_Menu = object(App_View)
                 FirstMenu,AntMenu,CrtMenu : PMenu;
                 Tree : array[1..40] of PMenu;
                 TreeCount : integer;
                 FirstItem,CrtItem : PMenuItem;
                 end;

   PApp_MenuVert = ^App_MenuVert;
    App_MenuVert = object(App_Menu)
                 constructor Init(MName : string;x,y : integer;AMenu : PMenu);
                 function Selected(x,y : integer) : boolean;virtual;
                 procedure DrawView(where : word);virtual;
                 destructor Done;virtual;
                 end;

  PApp_Back = ^App_Back;
   App_Back = object(App_View)
            constructor Init(backfile : string);
            procedure DrawView(where : word);virtual;
            destructor Done;virtual;
            end;

  PApp_GBack = ^App_GBack;
   App_GBack = object(App_View)
             WhatBack      : integer;
             ViewLx,ViewLy : integer;
             constructor Init(x,y,xl,yl,wb : integer);
             procedure DrawView(where : word);virtual;
             destructor Done;virtual;
             end;

  PApp_StaticText = ^App_StaticText;
   App_StaticText = object(App_View)
              font : byte;
              constructor Init(name : string; x,y : integer;f : byte);
              procedure DrawView(where : word);virtual;
              procedure UpDate;virtual;
              function Selected(x,y : integer): boolean;virtual;
              destructor Done;virtual;
              end;

   PApp_Time = ^App_Time;
    App_Time = object(App_StaticText)
             procedure UpDate;virtual;
             end;

   PApp_Heap = ^App_Heap;
    App_Heap = object(App_StaticText)
             procedure UpDate;virtual;
             end;

   PApp_MemStr = ^App_MemStr;
    App_MemStr = object(App_StaticText)
             PViewName : PString;
             LeftStr,RightStr : string;
             constructor Init(left : string;name : PString;right : string;x,y : integer;f : byte);
             procedure UpDate;virtual;
             end;

   PApp_MemLInt = ^App_MemLInt;
    App_MemLInt = object(App_StaticText)
             PNumber : PLongInt;
             LeftStr,RightStr : string;
             constructor Init(left : string;number : PLongInt;right : string;x,y : integer;f : byte);
             procedure UpDate;virtual;
             end;

   PApp_InputLine = ^App_InputLine;
    App_InputLine = object(App_View)
                  Data : PString;
                  Count : integer;
                  Blink : byte;
                  ViewLX,ViewLY : integer;
                  MaxCount : integer;
                  CursorSpr : real;
                  constructor Init(datastr : string;x,y,xl,yl : integer;act : integer);
                  procedure DrawView(where : word);virtual;
                  function Selected(x,y : integer): boolean;virtual;
                  destructor Done;virtual;
                  end;

   PApp_Window = ^App_Window;
    App_Window = object(App_View)
               ViewLX,ViewLY : integer;{window extensions}
               First,Active : PItem;
               PushLeft,PushRight : boolean;
               constructor Init(WindowName : string;x,y,xl,yl : integer);
               procedure DrawView(where : word);virtual;
               procedure InsertItem(What : PApp_View);virtual;
               function Selected(x,y : integer) : boolean;virtual;
               destructor Done;virtual;
               end;

    PApp_Group = ^App_Group;
    App_Group = object(App_Window)
              constructor Init(groupname : string; x,y,xl,yl : integer);
              procedure DrawView(where : word);virtual;
              function Selected(x,y : integer):boolean;virtual;
              destructor Done;virtual;
              end;

   PApp_Program = ^App_Program;
    App_Program = object(App_View)
             public
              DeskTop : PApp_Window;
              constructor Init;
              procedure Run;virtual;
              procedure HandleAction;virtual;
              procedure HandleComm;virtual;
              destructor Done;virtual;
              procedure GetTextScr;
              procedure RestoreTextScr;
             private
              textscr : array[1..25,1..80] of word;
              C_Line_Start,C_Line_End,C_Row,C_Col : byte;
             end;

   PApp_StrListBox = ^App_StrListBox;
    App_StrListBox = object(App_Window)
                FirstStrList : PStrList;
                CurentItem   : PStrList;
                SelectedItem : PStrList;
                MaxItems     : integer;
                {HScrollBar   : PHScrollBar;}
                constructor Init(Data : PStrList;x,y,xl,yl : integer;SprF : string);
                procedure  DrawView(where : word);virtual;
                function Selected(x,y : integer) : boolean;virtual;
                destructor Done;virtual;
                end;

   PApp_FileListBox = ^App_FileListBox;
    App_FileListBox = object(App_StrListBox)
                    WildCard  : string[3];
                    Directory : string;
                    constructor Init(WDC ,Dir : string;x,y,xl,yl : integer;SprF : string;act : word);
                    procedure Update;
                    procedure Load;
                    end;

   PApp_MemInputLine = ^App_MemInputLine;
    App_MemInputLine = object(App_InputLine)
                      constructor Init(mz : PString;x,y,xl,yl : integer;act : integer);
                      function Selected(x,y : integer) : boolean;virtual;
                      end;

   KeyCodes = array[1..128] of byte;

   function NewStrList(Name : Title;Follow : PStrList) : PStrList;
   procedure TrackStrList(First : PStrList);
   procedure DisposeStrList(First : PstrList);

   function NewMenu(Items : PMenuItem) : PMenu;
   function NewItem(Name : Title;Command : word;Next : PMenuItem) : PMenuItem;
   function NewSubMenu(Name : Title;SubMenu : PMenu;Next : PMenuItem) : PMenuItem;
   procedure DisposeMenu(AMenu : PMenu);

CONST
     NONE = 255;
VAR
   Comm    : CommZone;
   KeyCode : KeyCodes;

IMPLEMENTATION

constructor App_View.Init;
begin
 ViewName:=name;
 ViewX:=x;ViewY:=y;
 Selx:=-1;Sely:=-1;
 Action:=Act;
 LoadSpr(fname,1);
 WinActive := false;
end;

procedure App_View.DrawView;
begin
 PutSpr(1,ViewX,ViewY,gameput,where);
 if Selx>-1 then Outtext(SelX,SelY,ViewName,1,255,where);
end;

function App_View.Selected;
begin
 Selx:=-1;Sely:=-1;
 Selected:=false;
  if (X<ViewX+spr[1].xl) and (X>Viewx) and
    (Y<ViewY+spr[1].yl) and (Y>Viewy)
    then begin
          if Mouse^.LeftButtonPressed then Selected:=true;
          SelX:=x;
          Sely:=y;
         end;
end;

procedure App_View.InsertItem;
begin
end;

destructor App_View.Done;
begin
 DoneSpr(1);
end;

constructor App_Group.Init;
begin
 ViewName:=groupname;
 ViewX:=x;ViewY:=y;
 ViewLX:=xl;ViewLY:=yl;
 First:=nil;Active:=First;
 LoadSpr('left.spr',1);
 LoadSpr('right.spr',2);
 LoadSpr('sleft.spr',3);
 LoadSpr('sright.spr',4);
end;

procedure App_Group.DrawView;
begin
 Active^.Info^.DrawView(where);
 if pushleft
    then begin
          Putspr(3,ViewX+ViewLx-spr[1].xl-spr[2].xl-1,ViewY+Viewly-spr[1].yl,gameput,where);
          pushleft:=false;
         end
    else Putspr(1,ViewX+ViewLx-spr[1].xl-spr[2].xl-1,ViewY+Viewly-spr[1].yl,gameput,where);
 if pushright
    then begin
          Putspr(4,ViewX+ViewLX-spr[2].xl,Viewy+Viewly-spr[1].yl,gameput,where);
          pushright:=false;
         end
    else Putspr(2,ViewX+ViewLX-spr[2].xl,Viewy+Viewly-spr[1].yl,gameput,where);
end;

function App_Group.Selected;
begin
 if (x>ViewX+ViewLx-spr[1].xl-spr[2].xl-1) and (x<ViewLx-spr[1].xl) and
    (y>ViewY+ViewLY-spr[1].yl) and (y<ViewY+ViewLY) and
    Mouse^.LeftButtonPressed
    then begin
          Active:=Active^.Next;
          pushleft:=true;
         end;
 if (x<ViewX+ViewLX) and (x>ViewX+ViewLX-spr[1].xl) and
    (y>ViewY+ViewLY-spr[1].yl) and (y<ViewY+ViewLY) and
    Mouse^.LeftButtonPressed
    then begin
          Active:=Active^.Ant;
          pushright:=true;
         end;

 Selected:=false;
 if Active^.Info^.Selected(x,y) and Mouse^.LeftButtonPressed
    then begin
          Action:=Active^.Info^.Action;
          Selected:=true;
         end;
end;


destructor App_Group.Done;
 var
    aux,aux1 : PItem;
begin
 DoneSpr(1);DoneSpr(2);
 DoneSpr(3);DoneSpr(4);
 if First<>nil
    then begin
          aux:=First^.Next;
          while aux<>First do
                begin
                 aux1:=aux^.next;
                 dispose(aux^.Info,Done);
                 dispose(aux);
                 aux:=aux1;
                end;
          dispose(First^.Info,Done);
          dispose(First);
         end;
end;

function NewStrList;
 var aux : PStrList;
begin
 new(aux);
 with aux^ do
      begin
       new(info);
       Info^:=name;
       Next:=Follow;
      end;
 NewStrList:=aux;
end;

procedure TrackStrList;
 var aux  : PStrList;
begin
 aux:=First;
 while aux<>Nil do
       begin
        writeln(aux^.Info^);
        aux:=aux^.Next;
       end;
end;

procedure DisposeStrList;
 var aux1,aux2 : PStrList;
begin
 aux1:=First;
 while aux1<>nil do
       begin
        aux2:=aux1^.next;
        dispose(aux1^.Info);
        dispose(aux1);
        aux1:=aux2;
       end;
end;

constructor App_Cluster.Init;
begin
 ViewName := Name;
 FirstStr := First;
 Action := Act;
 Value := V;
 ViewX := X;
 ViewY := Y;
 LoadSpr('tile.spr',1);
 LoadSpr('checkit.spr',2);
 { use font 1 }
end;

function App_Cluster.Selected;
begin
 { to be defined by radiobutton and checkbox }
end;

procedure App_Cluster.DrawView;
 var count : byte;
     aux   : PStrList;
begin
 count:=0;
 aux:=FirstStr;
 outtext(ViewX,ViewY-fonts[1].y-3,ViewName,1,255,where);
 while aux<>Nil do
       begin
        putspr(1,ViewX,ViewY+(spr[1].yl+2)*count,gameput,where);
        if (value and (1 shl count)=1 shl count) then putspr(2,ViewX,ViewY+(spr[1].yl+2)*count,gameput,where);
        outtext(ViewX+spr[1].xl+3,ViewY+(spr[1].yl+2)*count+spr[1].yl div 2-fonts[1].y div 2,aux^.Info^,1,255,where);
        inc(count);
        aux:=aux^.Next;
       end;
end;

destructor App_Cluster.Done;
begin
 DisposeStrList(FirstStr);
 Donespr(1);
 Donespr(2);
end;

function App_RadioBtn.Selected;
 var count : byte;
     aux   : PStrList;
begin
 count:=0;
 aux:=FirstStr;
 Selected := false;
 while aux<>Nil do
       begin
        if (x>ViewX) and (ViewX+spr[1].xl>x) and (y>ViewY+(spr[1].yl+2)*count) and (y<ViewY+(spr[1].yl+2)*(count+1))
           and Mouse^.LeftButtonPressed
           then begin
                 value := 1 shl count;
                 Selected:=true;
                 break;
                end;
        inc(count);
        aux:=aux^.Next;
       end;
end;

function App_CheckBtn.Selected;
 var count : byte;
     aux   : PStrList;
     c1,c2 : byte;
begin
 count:=0;
 aux:=FirstStr;
 Selected := false;
 while aux<>Nil do
       begin
        if (x>ViewX) and (ViewX+spr[1].xl>x) and (y>ViewY+(spr[1].yl+2)*count) and (y<ViewY+(spr[1].yl+2)*(count+1))
           and Mouse^.LeftButtonPressed
           then begin
                 c1:=1 shl count;
                 if (value and c1=0) then value:=value or c1
                                     else value:=value and (not c1);
                 comm[1] := Action;
                 comm[2] := value;
                 Selected:=true;
                 break;
                end;
        inc(count);
        aux:=aux^.Next;
       end;

end;

constructor App_Dialog.Init;
begin
 ViewName := VName;
 ViewX := X;
 ViewY := Y;
 FirstCluster:=nil;
end;

procedure App_Dialog.Link;
var aux1,aux2 : PClusterList;
begin
 if FirstCluster=Nil
    then begin
          New(FirstCluster);
          FirstCluster^.Next:=Nil;
          FirstCluster^.Info:=What;
         end
    else begin
          aux1:=FirstCluster;
          while aux1^.Next<>Nil do aux1:=aux1^.Next;
          new(aux2);
          aux2^.Info:=What;
          aux2^.Next:=nil;
          aux1^.Next:=aux2;
         end;
end;

function App_Dialog.Selected;
 var aux : PClusterList;
begin
 aux := FirstCluster;
 Selected := false;
 while aux<>nil do
       begin
        aux^.Info^.Selected(x,y);
        aux:=aux^.next;
       end;
end;

procedure App_Dialog.DrawView;
 var aux : PClusterList;
begin
 aux := FirstCluster;
 while aux<>nil do
       begin
        aux^.Info^.DrawView(where);
        aux:=aux^.next;
       end;
end;

procedure App_Dialog.Unlink;
 var aux1,aux2 : PClusterList;
begin
 aux1:=FirstCluster;
 while aux1<>nil do
       begin
        aux2:=aux1^.next;
        dispose(aux1^.Info,Done);
        dispose(aux1);
        aux1:=aux2;
       end;
 FirstCluster:=nil;
end;

destructor App_Dialog.Done;
begin
 UnLink;
end;

constructor App_MenuVert.Init;
var i : integer;
begin
 ViewName := MName;
 FirstMenu := AMenu;
 CrtItem := FirstMenu^.Items;
 FirstItem := CrtItem;
 TreeCount:=1;
 Tree[TreeCount]:=FirstMenu;
 CrtItem^.SprIfSel:=1;
 CrtItem^.DirIfSel:=1;

 LoadSpr('menudef.spr',1);
 for i:=2 to 30 do LoadSpr('menu'+Int2Str(i-2)+'.spr',i);
 ViewX := x;
 ViewY := y;
end;

function App_MenuVert.Selected;
 var
    aux : PMenuItem;
    i   : integer;
    key : byte;
begin

 Selected := false;
 FreeBuf;
 key := port[$60];

 aux:=FirstItem;
 i := 0;
 while aux <> nil do
       begin
        if (ViewX<x) and (ViewX+spr[1].xl>x) and
           (ViewY+i*(spr[1].yl+2)<y) and (ViewY+i*(spr[1].yl+2)+spr[1].yl>y)
           then begin
                 CrtItem:=aux;
                 if Mouse^.LeftButtonPressed then key := 28;
                 break;
                end;
        aux:=aux^.next;
        inc(i);
       end;

 case key of
 80 : begin
       Crtitem:=CrtItem^.Next;
       if CrtItem=nil then CrtItem:=FirstItem;
       CrtItem^.SprIfSel:=0;CrtItem^.DirIfSel:=1;
       delay(50);
      end;
 72 : begin
       aux := FirstItem;
       if FirstItem=CrtItem
          then while true do
                     begin
                      if aux^.next=nil
                         then begin
                               CrtItem:=aux;{last item in the list}
                               break;
                              end;
                      aux:=aux^.next;
                     end
          else while true do
                     begin
                      if aux^.Next=CrtItem
                         then begin
                               CrtItem:=aux;
                               break;
                              end;
                      aux:=aux^.Next;
                     end;
       CrtItem^.SprIfSel:=0;CrtItem^.DirIfSel:=1;
       delay(50);
      end;
 28 : if CrtItem^.Command<>0
         then begin
               Action:=CrtItem^.Command;
               if TreeCount>1 then dec(TreeCount);
               FirstItem := Tree[TreeCount]^.Items;
               CrtItem := FirstItem;
               CrtItem^.SprIfSel:=0;CrtItem^.DirIfSel:=1;
               delay(200);
               Selected := True;
              end
         else begin
               inc(TreeCount);
               Tree[TreeCount] := CrtItem^.SubMenu;
               FirstItem := Tree[TreeCount]^.Items;
               CrtItem := FirstItem;
               CrtItem^.SprIfSel:=0;CrtItem^.DirIfSel:=1;
               delay(200);
              end;
  1 : begin
       if TreeCount>1 then dec(TreeCount);
       FirstItem := Tree[TreeCount]^.Items;
       CrtItem := FirstItem;
       CrtItem^.SprIfSel:=0;CrtItem^.DirIfSel:=1;
       delay(50);
      end;
 end;
end;

procedure App_MenuVert.DrawView;
 var
    aux : PMenuItem;
    i   : integer;
begin
 aux := FirstItem;
 i := 0;
 while aux <> nil do
       begin
        if aux=CrtItem
           then begin
                 CrtItem^.SprIfSel:=CrtItem^.SprIfSel+CrtItem^.DirIfSel;
                 if CrtItem^.SprIfSel>30 then CrtItem^.SprIfSel:=2;
                 PutSpr(CrtItem^.SprIfSel,ViewX,ViewY+i*(spr[1].yl+2),gameput,where);
                end
           else PutSpr(1,ViewX,ViewY+i*(spr[1].yl+2),gameput,where);
        Outtext(ViewX+spr[1].xl div 2-(length(aux^.name)*(fonts[1].x+1)) div 2,ViewY+i*(spr[1].yl+2)+4,aux^.name,1,255,where);
        aux:=aux^.next;
        inc(i);
       end;
end;

destructor App_MenuVert.Done;
 var
    i : integer;
begin
 for i:=2 to 30 do DoneSpr(i);
 DoneSpr(1);
 DisposeMenu(FirstMenu);
end;

constructor App_Btn.Init;
begin
 LoadSpr(fnamepress,1);
 LoadSpr(fnamerel,2);
 ViewName := name;
 Action   := act;
 ViewX    := x;
 ViewY    := y;
end;

function App_Btn.Selected;
begin
 Selected := false;
 if (x>ViewX) and (x<ViewX+spr[1].xl) and
    (y>ViewY) and (y<ViewY+spr[1].yl) and Mouse^.LeftButtonPressed
    then begin
          Selected := true;
          Press := true;
         end;
end;

procedure App_Btn.DrawView;
begin
 if Press
    then begin
          Press := false;
          PutSpr(2,ViewX,ViewY,gameput,where);
         end
    else PutSpr(1,ViewX,ViewY,gameput,where);
end;

destructor App_Btn.Done;
begin
 DoneSpr(1);
 DoneSpr(2);
end;

constructor App_Btn2.Init;
begin
 ViewName := name;
 Action   := act;
 ViewX    := x;
 ViewY    := y;
 WhatFont := wf;
 ViewLX   := length(name)*(fonts[WhatFont].x+1)+4;
 ViewLY   := (fonts[WhatFont].y+1)+4;
end;

function App_Btn2.Selected;
begin
 Selected := false;
 if (x>ViewX) and (x<ViewX+ViewLX) and
    (y>ViewY) and (y<ViewY+ViewLY) and Mouse^.LeftButtonPressed
    then begin
          Selected := true;
          Press := true;
         end;
end;

procedure App_Btn2.DrawView;
begin
 if not Press
    then begin
          {}
          Line(ViewX,ViewY,ViewX+ViewLX,ViewY,80,where);
          Line(ViewX,ViewY,ViewX,ViewY+ViewLY,80,where);
          Line(ViewX+ViewLX,ViewY,ViewX+ViewLX,ViewY+ViewLY,94,where);
          Line(ViewX+1,ViewY+ViewLY,ViewX+ViewLX,ViewY+ViewLY,94,where);
          {}
          Bar(ViewX+1,ViewY+1,ViewX+ViewLX,ViewY+ViewLY-1,92,where);
          {}
          Outtext(ViewX+2,ViewY+ViewLy div 2-(fonts[WhatFont].y+1) div 2+1,ViewName,WhatFont,15,where);
         end
    else begin
          {}
          Press := false;
          Line(ViewX,ViewY,ViewX+ViewLX,ViewY,80,where);
          Line(ViewX,ViewY,ViewX,ViewY+ViewLY,80,where);
          Line(ViewX+ViewLX,ViewY,ViewX+ViewLX,ViewY+ViewLY,94,where);
          Line(ViewX+1,ViewY+ViewLY,ViewX+ViewLX,ViewY+ViewLY,94,where);
          {}
          Line(ViewX+1,ViewY+1,ViewX+ViewLX-1,ViewY+1,80,where);
          Line(ViewX+1,ViewY+1,ViewX+1,ViewY+ViewLY-1,80,where);
          Line(ViewX+ViewLX-1,ViewY+1,ViewX+ViewLX-1,ViewY+ViewLY-1,94,where);
          Line(ViewX+2,ViewY+ViewLY-1,ViewX+ViewLX-1,ViewY+ViewLY-1,94,where);
          {}
          Bar(ViewX+2,ViewY+2,ViewX+ViewLX-1,ViewY+ViewLY-2,92,where);
          {}
          Outtext(ViewX+3,ViewY+ViewLy div 2-(fonts[WhatFont].y+1) div 2+1,ViewName,WhatFont,17,where);
         end;
end;

destructor App_Btn2.Done;
begin
end;

constructor App_Back.Init;
begin
 Loadspr(backfile,1);
end;

procedure App_Back.DrawView;
begin
 putspr(1,0,0,normalput,where);
end;

destructor App_Back.Done;
begin
 DoneSpr(1);
end;

constructor App_GBack.Init;
begin
 ViewX    := x;
 ViewY    := y;
 ViewLx   := xl;
 ViewLy   := yl;
 WhatBack := wb;
end;

procedure App_GBack.DrawView;
var
   i,difx,dify : integer;
begin
 case WhatBack of
  1 : begin
       dify := ViewLy div 2;
       for i := 0 to dify-1 do
           begin
            Line(ViewX,i*2+ViewY,ViewX+ViewLx,i*2+ViewY,82,where);
            Line(ViewX,i*2+ViewY+1,ViewX+ViewLx,i*2+ViewY+1,75,where);
           end;
      end;
 end;
end;

destructor App_GBack.Done;
begin
end;

function NewMenu;
 var Aux : PMenu;
begin
 new(Aux);
 Aux^.Items := Items;
 NewMenu := Aux;
end;

function NewSubMenu;
 var Aux : PMenuItem;
begin
 new(Aux);
 Aux^.Name := Name;
 Aux^.Command := 0;
 Aux^.SubMenu := SubMenu;
 Aux^.DirIfSel:=1;Aux^.SprIfSel:=0;
 Aux^.Next := Next;
 NewSubMenu := Aux;
end;

function NewItem;
 var Aux : PMenuItem;
begin
 new(Aux);
 Aux^.Name := Name;
 Aux^.Command := Command;
 Aux^.DirIfSel:=1;Aux^.SprIfSel:=0;
 Aux^.SubMenu := nil;
 Aux^.Next := Next;
 NewItem := Aux;
end;

procedure DisposeMenu;
 var
    Aux,Aux1 : PMenuItem;
begin
 Aux:=AMenu^.Items;
 while Aux<>nil do
       begin
        if Aux^.Command=0 then begin
                                aux1:=aux^.next;
                                DisposeMenu(Aux^.SubMenu);
                                dispose(aux);
                                aux:=aux1;
                               end
                          else begin
                                aux1:=aux^.next;
                                dispose(aux);
                                aux:=aux1;
                               end;
       end;
 dispose(AMenu);
end;

constructor App_StaticText.Init;
begin
 ViewName := name;
 Action := cmNoAction;
 ViewX := x;
 ViewY := y;
 Font  := f;
end;

function App_StaticText.Selected;
begin
 Selected := false;
end;

procedure App_StaticText.UpDate;
begin
end;

procedure App_StaticText.DrawView;
begin
 UpDate;
 if ViewName<>'' then outtext(ViewX,ViewY,ViewName,Font,255,where);
end;

destructor App_StaticText.Done;
begin
end;

procedure App_Time.UpDate;
 var
    h,m,s,s100 : word;
    aux        : string;
begin
 ViewName := '';
 gettime(h,m,s,s100);
 str(h,aux);
 if length(aux)=1 then aux:='0'+aux;
 ViewName := ViewName +aux+':';
 str(m,aux);
 if length(aux)=1 then aux:='0'+aux;
 ViewName := ViewName +aux+':';
 str(s,aux);
 if length(aux)=1 then aux:='0'+aux;
 ViewName := ViewName +aux;
end;

procedure App_Heap.UpDate;
begin
 str(memavail,ViewName);
end;

constructor App_MemStr.Init;
begin
 PViewName := name;
 Action    := cmNoAction;
 ViewX     := x;
 ViewY     := y;
 LeftStr   := left;
 RightStr  := right;
 Font      := f;
end;

procedure App_MemStr.UpDate;
begin
 if PViewName^<>'' then ViewName := LeftStr+PViewName^+RightStr
    else ViewName:='';
end;

constructor App_MemLInt.Init;
begin
 PNumber := number;
 Action := cmNoAction;
 ViewX := x;
 ViewY := y;
 LeftStr := left;
 RightStr := right;
 Font := f;
end;

procedure App_MemLInt.UpDate;
begin
 ViewName := LeftStr+Int2Str(PNumber^)+RightStr;
end;

constructor App_InputLine.Init;
 var
    i : integer;
begin
 new(Data);
 Data^:='                 ';
 Data^:= datastr+'        ';
 Count := length(datastr);
 Blink := 1;
 ViewX := x;
 ViewY := y;
 ViewLX := xl;
 ViewLY := yl;
 MaxCount := ViewLX div (fonts[1].x+1)-1;
 Action := act;
 WinActive := false;
 for i:=1 to 8 do LoadSpr('time0'+char(i+48)+'.spr',i);
 CursorSpr := 1;
end;

function App_InputLine.Selected;
var
   key : char;
   i   : integer;
begin
 Selected := false;
 if (x>ViewX) and (x<ViewX+ViewLX) and
    (y>ViewY) and (y<ViewY+ViewLY) and Mouse^.LeftButtonPressed
    then case WinActive of
          true : begin
                  WinActive := false;
                  Selected := true;
                  Comm[1]:=Action;
                  Comm[2]:=Count;
                  for i:=1 to MaxCount do Comm[i+2] := byte(Data^[i]);
                  delay(55);
                 end;
         false : begin
                  WinActive := true;
                  Selected := true;
                  Count := length(Data^);
                  delay(55);
                 end;
         end;

 if (WinActive) and (comm[1]=cmKbd)
    then begin
          comm[1] := cmNoAction;
          delay(55);
          case comm[2] of
          28 : begin
                 WinActive := false;
                 {Selected := true;}
                 Comm[2] := Count;
                 for i:=1 to MaxCount do Comm[i+2] := byte(Data^[i]);
                 Comm[1]:=Action;
                 delay(100);
                end;
          1 : WinActive := false;
          14  : begin
                 Data^[Count]:=' ';
                 dec(Count);
                 if Count<0 then Count:=0;
                end;
          else begin
                inc(Count);
                if KeyCode[comm[2]]>=128 then KeyCode[comm[2]]:=byte('.');
                if Count>MaxCount then Count:=MaxCount
                            else Data^[Count]:=char(KeyCode[comm[2]]);
               end;
          end;
         end;
end;

procedure App_InputLine.DrawView;
begin
 {Data^[0]:=char(Count);}
 outtext(ViewX+2,ViewY+2,Data^,1,255,where);
 if WinActive then Rectangle(ViewX,ViewY,ViewX+ViewLX,ViewY+ViewLY,124,where)
              else Rectangle(ViewX,ViewY,ViewX+ViewLX,ViewY+ViewLY,255,where);
 if WinActive
    then begin
         {outtext(ViewX+2+(fonts[1].x+1)*Count,ViewY+2,'<',1,255,where);}
          putspr(round(CursorSpr),ViewX+2+(fonts[1].x+1)*Count,ViewY+ViewLY div 2-spr[1].yl div 2,gameput,where);
          CursorSpr:=CursorSpr+0.15;
          if CursorSpr>8 then CursorSpr:=1;
         end;
end;

destructor App_InputLine.Done;
 var
    i : integer;
begin
 dispose(Data);
 for i:=1 to 8 do DoneSpr(i);
end;

constructor App_Window.Init;
begin
 ViewName := WindowName;
 ViewX := x;
 ViewY := y;
 ViewLX := xl;
 ViewLY := yl;
 First := nil;
 Action := cmNoAction;
end;

procedure App_Window.DrawView;
 var
    aux : PItem;
begin
 if First<>nil
    then begin
          aux:=First^.Next;
          while aux<>First do
                begin
                 aux^.Info^.DrawView(where);
                 aux:=aux^.next;
                end;
          First^.Info^.DrawView(where);
         end;
end;

function App_Window.Selected;
var
   aux : PItem;
begin
 {must trap}
 Selected := false;
 if First<>nil
    then begin
          aux:=First^.Next;
          while aux<>First do
                begin
                 if aux^.Info^.Selected(x,y)
                    then begin
                          Action := Aux^.Info^.Action;
                          Selected := true;
                          {break;}{il selecteaza pe primul bagat in lista}
                         end;
                 aux:=aux^.next;
                end;
          if First^.Info^.Selected(x,y)
             then begin
                   Action := First^.Info^.Action;
                   Selected := true;
                  end;
         end;
end;

procedure App_Window.InsertItem;
var
   aux,deinsert : pitem;
begin
 if First=nil
    then begin
          new(First);
          First^.Info:=What;
          First^.Next:=First;
          First^.Ant:=First;
          Active:=First;
         end
    else begin
          new(deinsert);
          deinsert^.info:=what;
          aux:=first^.next;
          first^.next:=deinsert;deinsert^.next:=aux;
          deinsert^.ant:=first;aux^.ant:=deinsert;
         end;
end;

destructor App_Window.Done;
 var
    aux,aux1 : PItem;
begin
 if First<>nil
    then begin
          aux:=First^.Next;
          while aux<>First do
                begin
                 aux1:=aux^.next;
                 dispose(aux^.Info,Done);
                 dispose(aux);
                 aux:=aux1;
                end;
          dispose(First^.Info,Done);
          dispose(First);
         end;
end;

constructor App_Program.Init;
BEGIN
 GetTextScr;
 InitPath;
 Vga256;
 InitVScreen;
 NeWork:=New(PNewApp_3D,Init);
 LoadFnt('sysfnt.fnt',1);
 LoadFnt('micro2.fnt',6);
 LoadPal('menupal4.pal');SetPal;
 LoadSpr('cursor.spr',1);
 Mouse := new(PTMouse,Init);
END;

procedure App_Program.Run;
 var
    key : byte;
begin
 repeat
  Cls(0,vaddr);
  key := port[$60];
  if key<128 then begin comm[1]:=cmKbd;comm[2]:=key;end;
  FreeBuf;
  if DeskTop^.Selected(Mouse^.X,Mouse^.Y) {and DeskTop^.WinActive}
     then HandleAction;
  HandleComm;
  DeskTop^.DrawView(vaddr);
  PutSpr(1,Mouse^.X,Mouse^.Y,gameput,vaddr);
  Flip;
 until DeskTop^.Action = cmExit;
end;

procedure App_Program.HandleAction;
begin
 case DeskTop^.Action of
  cmNoAction : begin end;
 end;
end;

procedure App_Program.HandleComm;
begin
 case comm[1] of
  cmNoAction : begin end;
 end;
end;

procedure App_Program.GetTextScr;
 var cr,cc,clst,clen : byte;
begin
 Move(ptr(SegB800,0)^,textscr,25*80*2);
 asm
  xor bh,bh
  mov ah,3
  int 10h
  mov CR,dh
  mov CC,dl
  mov CLSt,ch
  mov CLEn,cl
 end;
 C_Row:=cr;C_Col:=cc;C_Line_Start:=clst;C_Line_End:=clen;
end;

procedure App_Program.RestoreTextScr;
 var cr,cc,clst,clen : byte;
begin
 Move(textscr,ptr(SegB800,0)^,25*80*2);
 cr:=C_Row;cc:=C_Col;clst:=C_Line_Start;clen:=C_Line_End;
 asm
  mov ch,CLSt
  mov cl,CLEn
  mov ah,1
  xor bh,bh
  int 10h
  xor bh,bh
  mov dh,CR
  mov dl,CC
  mov ah,2
  int 10h
 end;
end;

destructor App_Program.Done;
BEGIN
 FadeOut(3);
 DoneVScreen;
 DoneVga256;
 dispose(Mouse,Done);
 DoneSpr(1);
 dispose(NeWork,Done);
 RestoreTextScr;
END;

constructor App_StrListBox.Init;
var
   ListCount : integer;
   aux       : PStrList;
begin
 Action := cmNoAction;
 FirstStrList := Data;
 CurentItem   := Data;
 SelectedItem := Data;
 MaxItems     := 0;
 aux          := FirstStrList;
 while aux<>Nil do begin inc(MaxItems);aux:=aux^.next;end;
 {HScrollBar := nil;}
 ViewX := x;ViewY := y;
 ViewLX := xl;ViewLY := yl;
end;

procedure App_StrListBox.DrawView;
var
   oldxlc,oldxrc,oldytc,oldybc : integer;
   YCount                      : integer;
   aux                         : PStrList;
   color                       : byte;
begin
 ScaleSpr(1,ViewX,ViewY,ViewLX,ViewLY+1);
 {rectangle(ViewX,ViewY,ViewX+ViewLX,ViewY+ViewLY+1,255,where);}
 oldxlc := XLeftClip;oldxrc := XRightClip;
 oldytc := YTopClip ;oldybc := YBotClip;
 XLeftClip := ViewX;XRightClip := ViewX+ViewLX;
 YTopClip := ViewY;YBotClip := ViewY+ViewLY;

 aux := CurentItem;YCount := 0;
 while (YCount*(fonts[6].y+1)<ViewLY) and (aux<>nil) do
       begin
        color := 124;
        if aux=SelectedItem
           then bar(ViewX+1,ViewY+1+YCount*(fonts[6].y+1),ViewX+ViewLX+1,ViewY+1+(YCount+1)*(fonts[6].y+1),189,where)
           else color := 255;
        outtext(ViewX+1,ViewY+YCount*(fonts[1].y+1)+2,aux^.Info^,6,color,where);
        inc(YCount);
        aux:=aux^.next;
       end;
 XLeftClip:=oldxlc ;XRightClip:=oldxrc;
 YTopClip:=oldytc ;YBotClip:=oldybc;
end;

function App_StrListBox.Selected;
var
   YCount,i                    : integer;
   aux                         : PStrList;
begin
 Selected := false;
 aux    := CurentItem;
 YCount := 0;
 while (aux<>nil) and (YCount*(fonts[6].y+1)<ViewLY) do
       begin
        if (y>ViewY+YCount*(fonts[6].y+1)) and (y<ViewY+(YCount+1)*(fonts[6].y+1)) and
           (x>ViewX) and (x<ViewX+ViewLX) and Mouse^.LeftButtonPressed
           then begin
                 SelectedItem := aux;
                 comm[1] := Action;
                 comm[2] := length(SelectedItem^.Info^);
                 for i:=1 to comm[2] do comm[i+2] := integer(SelectedItem^.Info^[i]);
                 {sound(1000);delay(100);nosound;readln;}
                 Selected := true;
                 break;
                end;
        inc(YCount);
        aux := aux^.next;
       end;
end;

destructor App_StrListBox.Done;
begin
 DisposeStrList(FirstStrList);
 DoneSpr(1);
end;

constructor App_FileListBox.Init;
begin
 ViewName := 'This one!';
 Action := act;
 ViewX := x;ViewY := y;
 ViewLX := xl;ViewLY := yl;
 WildCard  := WDC;
 Directory := Dir;
 Load;
 CurentItem   := FirstStrList;
 SelectedItem := FirstStrList;
 LoadSpr(SprF,1);
end;

procedure App_FileListBox.Load;
var
   ts   : SearchRec;
   aux  : PStrList;
begin
 FindFirst(Directory+'*.'+WildCard,$3F,ts);
 FirstStrList := nil;
 repeat
  FirstStrList := NewStrList(ts.name,FirstStrList);
  FindNext(ts);
 until doserror<>0;
 MaxItems     := 0;
 aux          := FirstStrList;
 while aux<>Nil do begin inc(MaxItems);aux:=aux^.next;end;
end;

procedure App_FileListBox.UpDate;
begin
 if FirstStrList<>nil then DisposeStrList(FirstStrList);
 Load;
end;

constructor App_MemInputLine.Init;
var
   i : integer;
begin
 Blink := 1;
 ViewX := x;
 ViewY := y;
 ViewLX := xl;
 ViewLY := yl;
 Action := act;
 WinActive := false;
 for i:=1 to 8 do LoadSpr('time0'+char(i+48)+'.spr',i);
 CursorSpr := 1;
 new(Data);
 Data := mz;
 Count := length(Data^);
 MaxCount := ViewLX div (fonts[1].x+1)-1;
end;

function App_MemInputLine.Selected;
var
   key : char;
   i   : integer;
begin
 Selected := false;
 if (x>ViewX) and (x<ViewX+ViewLX) and
    (y>ViewY) and (y<ViewY+ViewLY) and Mouse^.LeftButtonPressed
    then case WinActive of
          true : begin
                  WinActive := false;
                  Selected := true;
                  comm[1]:=Action;
                  delay(55);
                 end;
         false : begin
                  WinActive := true;
                  Selected := true;
                  Count := length(Data^);
                  delay(55);
                 end;
         end;

 if (WinActive) and (comm[1]=cmKbd)
    then begin
          comm[1] := cmNoAction;
          delay(55);
          case comm[2] of
          28 : begin
                 WinActive := false;
                 {Selected := true;}
                 Comm[1]:=Action;
                 delay(100);
                end;
          1 : WinActive := false;
          14  : begin
                 Data^[Count]:=' ';
                 dec(Count);
                 if Count<0 then Count:=0;
                 Data^[0] := char(Count);
                end;
          else begin
                inc(Count);
                Data^[0] := char(Count);
                if KeyCode[comm[2]]>=128 then KeyCode[comm[2]]:=byte('.');
                if Count>MaxCount then Count:=MaxCount
                            else Data^[Count]:=char(KeyCode[comm[2]]);
               end;
          end;
         end
end;

VAR
   FKeys : file of keycodes;

BEGIN
 assign(FKeys,'keycodes.dat');
 reset(FKeys);
 read(FKeys,Keycode);
 close(FKeys);
END.