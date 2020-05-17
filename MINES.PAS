unit mines;

interface
//uses
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs, StdCtrls, Buttons;

type
Morbit=class(TObject)
         away:TObject;
         next:Morbit;
         class function New(aaway:tobject):Morbit;
         procedure add(aaway:tobject);
         class procedure clear(orbit:Morbit);
        end;
Mcell=class(Tobject)
       ingame:boolean;
       mine:boolean;
       state:boolean;
       flag:boolean;
       proved:boolean;
       num,mines:integer;
       around:Morbit;
       class function New(ismine,isstate:boolean):Mcell;
       procedure addenv(cell:Mcell);
       class procedure clear(cell:Mcell);
       function open:boolean;
       procedure show;  virtual;
       procedure decreasenum; virtual;
       procedure klik;
      end;

implementation

class function Morbit.New(aaway:tobject):Morbit;
var x:Morbit;
begin
x:=inherited Create; x.next:=nil; x.away:=aaway; result:=x;
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

class function Mcell.New(ismine,isstate:boolean):Mcell;
var x:Mcell;
begin
x:=inherited Create; 
x.mine:=ismine;
x.state:=isstate;
x.mines:=0;
x.around:=nil;
x.flag:=false;
x.proved:=false;
x.num:=0;
result:=x;
end;

procedure Mcell.addenv(cell:Mcell);
begin
if around=nil then begin around:=Morbit.New(cell) end else
begin around.add(cell) end;
num:=num+1;
if cell.mine then mines:=self.mines+1;
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
if  state then result:=true else
begin
if  mine then begin state:=true;
show; result:=false end
else begin
state:=true;
show;
decreasenum;
x:=around;
while x<>nil do
begin
if mines=0
then
 Mcell(x.away).open;
x:=x.next;
end;
result:=true;
end;
end;
end;
procedure Mcell.show;
begin end;

procedure Mcell.decreasenum;
begin end;


procedure Mcell.klik;
var x:Morbit; n,m:integer;
begin
x:=around; n:=0; m:=0;
while x<>nil do
begin
if Mcell(x.away).state=false then n:=n+1;;
if Mcell(x.away).flag then m:=m+1;;
x:=x.next
end;
x:=around;
if n=mines then
while x<>nil do
begin
if (Mcell(x.away).state=false) and (Mcell(x.away).flag=false) then
begin Mcell(x.away).flag:=true;
Mcell(x.away).proved:=true;
Mcell(x.away).show;
end;
x:=x.next;
end
else if mines=m then
while x<>nil do
begin
if (Mcell(x.away).state=false) and (Mcell(x.away).flag=false)  then
begin
Mcell(x.away).open;
end;
x:=x.next;
end;
end;

end.
