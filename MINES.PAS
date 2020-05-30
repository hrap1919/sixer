unit MINES;

{$MODE Delphi}

interface

type
    Morbit=class(TObject)
                         away:TObject;
                         next:Morbit;
                         constructor New(aaway:tobject);
                         procedure add(aaway:tobject);
                         class procedure clear(orbit:Morbit);
    end;
    Mcell=class(Tobject)
                        //ingame:boolean; //? it is usually true
                        mine:boolean;  //is mine here?
                        state:boolean;   //  is the cell open?
                        flag:boolean;   // is the cell marked
                        proved:boolean;  // is mine when flag// in fact it is a property
                        num,mines:integer; // num is the number of cells around, mines - the number of mines around
                        around:Morbit; // connects the cell with cells around via the chain of Morbit objects
                        constructor New(ismine,isstate:boolean);
                        procedure addenv(cell:Mcell);  // adding "an edge" to another cell
                        class procedure clear(cell:Mcell);
                        function open:boolean; //recursive open procedure
                        procedure show;  virtual; // in fact, it is an event
                        procedure decreasenum; virtual; // in fact, it is an event
                        procedure klik;  // procedure on clicking of open cells
      end;

implementation

constructor Morbit.New(aaway:tobject);
begin
     inherited Create; self.next:=nil; self.away:=aaway;
end;

procedure Morbit.add(aaway:tobject);
var x,y:Morbit;
begin
     x:=Morbit.New(aaway);
     y:=next;
     next:=x;
     x.next:=y;
end;

class procedure Morbit.clear(orbit:Morbit);
var x,y:Morbit;
begin
     x:=orbit;
     while x<>nil
           do
             begin
                  y:=x.next;
                  x.Destroy;
                  x:=y
             end;
end;

constructor Mcell.New(ismine,isstate:boolean);
begin
     inherited Create;
     self.mine:=ismine;
     self.state:=isstate;
     self.mines:=0;
     self.around:=nil;
     self.flag:=false;
     self.proved:=false;
     self.num:=0;
end;

procedure Mcell.addenv(cell:Mcell);
begin
     if around=nil
        then around:=Morbit.New(cell)
        else around.add(cell);
     num:=num+1;
     if cell.mine
        then mines:=self.mines+1;
end;

class procedure Mcell.clear(cell:Mcell);
begin
     Morbit.clear(cell.around);
     cell.Destroy;
end;

function Mcell.open:boolean;
var
   x:Morbit;
begin
     if  state
         then result:=true
         else
             if  mine
                 then
                     begin
                          state:=true;
                          show;
                          result:=false
                     end
                 else
                     begin
                          state:=true;
                          show;
                          decreasenum;
                          x:=around;
                          while x<>nil
                                do
                                  begin
                                       if mines=0
                                          then  Mcell(x.away).open;
                                       x:=x.next;
                                  end;
                          result:=true;
                     end;

end;

procedure Mcell.show;
begin end;

procedure Mcell.decreasenum;
begin end;


procedure Mcell.klik;
var
   x:Morbit;
   n,m:integer;
begin
     x:=around; n:=0; m:=0;
     while x<>nil do
     begin
          if Mcell(x.away).state=false
             then n:=n+1;;
          if Mcell(x.away).flag then m:=m+1;;
     x:=x.next
     end;
     x:=around;
     if n=mines
        then
            while x<>nil do
                  begin
                       if (Mcell(x.away).state=false) and (Mcell(x.away).flag=false)
                          then
                              begin
                                   Mcell(x.away).flag:=true;
                                   Mcell(x.away).proved:=true;
                                   Mcell(x.away).show;
                              end;
                       x:=x.next;
                  end
        else
            if mines=m
               then
                   while x<>nil do
                         begin
                              if (Mcell(x.away).state=false) and (Mcell(x.away).flag=false)
                                 then
                                     begin
                                          Mcell(x.away).open;
                                     end;
                              x:=x.next;
                         end;
end;

end.
