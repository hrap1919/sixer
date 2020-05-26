unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,MINES, ExtCtrls, StdCtrls, Menus;

type
    TPR=record
       Name:string[15];
        case byte of
          0: (width,height:byte;mines:word;);
          1: (time:integer;)
          end;

    Mcell1=class(Mcell)
      aa,bb:integer;
      light:boolean;
   //   rect:Trect;
     procedure preshow(d:string);
     procedure show; override;
     procedure decreasenum;   override;
     procedure show1(sw:boolean);
  end;

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button2: TButton;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    NewProfile1: TMenuItem;
    safeprofile1: TMenuItem;
    LoadProfile1: TMenuItem;
    OpenDialog1: TOpenDialog;
    TOP111: TMenuItem;
    Label4: TLabel;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
     procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
     procedure Image1Mousemove
     (Sender: TObject; Shift: TShiftState; X,
      Y: Integer);


    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure win;
    procedure lose(er:Mcell1);
    procedure NewProfile1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure newprofileok(Sender: TObject);
    procedure loadprofile(Sender: TObject);
    procedure newprofilecancel(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure TOP111Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    private
    { Private declarations }
  public
    { Public declarations }
  end;




var
  Form1: TForm1;

implementation

{$R *.lfm}

//type

uses Unit2;

const
//n1=30; n2=30; //size=15;
//nn1=17; nn2=16;
//const n1=6; n2=15; size=15;
//destnm=(nn1+1)*(nn2+1) div 6;
//destnm=n1*n2;
//destnm=1;
       rr=20;
      rx=18;
      ry=10;
      digitoffsetx=8;
      digitoffsety=14;
      fontsize=18;
      touch=0;
var

fpr: file of TPR;
rec:Tpr;
momentnumber:integer;
momentflag:boolean ;

CurrentDirectory: array[0..MAX_PATH] of Char;
newprofileresult:integer;
curprofilename:string;

nn1:integer=17;
nn2:integer=16;
//const n1=6; n2=15; size=15;
oldnn1,oldnn2:integer;
destnm:integer;
pressed:Mcell1;
paused:boolean;
ar:array of array of Mcell1;
mm:array of array of boolean;
//r:Trect;
p:Timage;
game:integer;
numcl,nummin,numsel,numtruesel:integer;

f{,f1}:Tform;{e0,}e1,e2,e3:Tedit;b1,b2:Tbutton;
{l0,}l1,l2,l3,l4:Tlabel;

{ttt:Int64;}

procedure tform1.Image1Mousemove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
var i,j:integer; xx:Morbit;

begin
if game=0 then
begin
{j:=y div size; if j>n2 then j:=n2;
i:=x div size; if i>n1 then i:=n1;}
if (y div ry) mod 3>0
then j:=(y div ry) div 3
else
if (((x div rx) mod 2 =(y div ry) mod 2)
and (rx*(y mod ry)<ry*(rx-x mod rx))
or
((x div rx) mod 2 <>(y div ry) mod 2)
and (rx*(y mod ry)<ry*(x mod rx)))
then j:=(y div ry) div 3-1
else j:=(y div ry) div 3;
if j mod 2=0 then i:=x div rx div 2
else
i:=(x div rx+1) div 2-1;






   if (i>=0) and (i<=nn1) and (j>=0) and (j<=nn2) and
   (ar[i,j].ingame)
   then
   if (ar[i,j]<>pressed) then
begin
   if  not pressed.state then
      begin
         momentflag:=false;
         pressed.show1(true);
      end;
   if (Shift<>[]) and not ar[i,j].state then
      begin
         momentflag:=false;
         ar[i,j].show1(false);
         //Messagebox(0,'','',MB_OK);
      end;
    xx:=pressed.around;
   while xx<>nil do
   begin
   Mcell1(xx.away).light:=true;
   xx:=xx.next;
   end;

if (Shift<>[]) and (ar[i,j].state) then
begin
   xx:=ar[i,j].around;
   while xx<>nil do
   begin
   Mcell1(xx.away).light:=false;
   xx:=xx.next;
   end;
end;

xx:=pressed.around;
   while xx<>nil do
   begin
   if (Mcell1(xx.away)<>ar[i,j]) or ar[i,j].state
   then Mcell1(xx.away).show1(Mcell1(xx.away).light);
   xx:=xx.next;
   end;


if(Shift<>[]) and (ar[i,j].state) then
begin
   xx:=ar[i,j].around; momentnumber:=ar[i,j].mines;
   while xx<>nil do
   begin
   if Mcell1(xx.away).flag then momentnumber:=momentnumber-1;
   xx:=xx.next;
   end;
    momentflag:=true;
   xx:=ar[i,j].around;
   while xx<>nil do
   begin
      Mcell1(xx.away).show1(Mcell1(xx.away).light);
   xx:=xx.next;
   end;

end;
   pressed:=ar[i,j];


end else else
begin
end;

end;
end;






procedure Mcell1.decreasenum;
var i1,j1:integer;
begin
numcl:=numcl-1;
form1.show;
if numcl=0 then
for i1:=0 to nn1 do for j1:=0 to nn2 do
if (ar[i1,j1].mine) and (not ar[i1,j1].flag)
then begin ar[i1,j1].flag:=true; ar[i1,j1].show end;;
end;

procedure Mcell1.preshow(d:string);
begin
p.canvas.Polygon([Point(aa,bb+rr),Point(aa+rx,bb+ry),Point(aa+rx,bb-ry),
Point(aa,bb-rr),Point(aa-rx,bb-ry),
Point(aa-rx,bb+ry)]);
p.canvas.TextOut(aa-digitoffsetx,bb-digitoffsety,d);
p.canvas.Polyline([Point(aa,bb+rr),Point(aa+rx,bb+ry),Point(aa+rx,bb-ry),
Point(aa,bb-rr),Point(aa-rx,bb-ry),
Point(aa-rx,bb+ry),Point(aa,bb+rr)]);
end;

function dig(x:integer):char;
begin
if x<10 then result:=inttostr(x)[1]
else result:=chr(ord('A')+x-10);
end;


procedure Mcell1.show;
begin
if not state then
begin
p.Canvas.Brush.Color:=$00C0D0D0;
p.Canvas.Font.Color:=clblack;
if flag then
begin
//p.canvas.TextRect(rect,rect.Left+3,rect.top,'?');
preshow('X');
numsel:=numsel-1;
form1.label3.caption:=inttostr(numsel);
if mine then numtruesel:=numtruesel-1;
if (numtruesel=0) and (numsel=0) then begin game:=1; form1.caption:=
form1.caption+': You''ve won'; form1.win; end;
end
else
begin //p.canvas.TextRect(rect,rect.Left+3,rect.top,' ');
preshow(' ');
p.Canvas.Brush.Color:=clwhite;
numsel:=numsel+1;
form1.label3.caption:=inttostr(numsel);
if mine then numtruesel:=numtruesel+1;
if (numtruesel=0) and (numsel=0) then begin game:=1; form1.caption:=
form1.caption+': You''ve won'; form1.win; end;
end
end
else
if mine then
begin
form1.lose(self);
end else
begin p.Canvas.Brush.Color:=clwhite;
if mines=0 then
//p.canvas.TextRect(rect,rect.Left+3,rect.top,' ')
preshow(' ')
else
begin
case mines mod 10 of
0: p.Canvas.Font.Color:=$007FFF;
1: p.Canvas.Font.Color:=clblue;
2: p.Canvas.Font.Color:=clgreen;
3: p.Canvas.Font.Color:=clred;
4: p.Canvas.Font.Color:=clNavy;
5: p.Canvas.Font.Color:=clFuchsia;
6: p.Canvas.Font.Color:=clteal;
7: p.Canvas.Font.Color:=clolive;
8: p.Canvas.Font.Color:=clpurple;
9: p.Canvas.Font.Color:=clLime-$00003000+$00300000;
else p.Canvas.Font.Color:=clblack end;
//p.canvas.TextRect(rect,rect.Left+3,rect.top,''+inttostr(mines));
preshow(dig(mines));
end;
end;
end;





procedure Mcell1.show1(sw:boolean);
begin
if not state then
begin
if sw then p.Canvas.Brush.Color:=$00C0D0D0 else p.Canvas.Brush.Color:=clgray;
p.Canvas.Font.Color:=clblack;
if flag then
begin
//p.canvas.TextRect(rect,rect.Left+3,rect.top,'?');
if not sw then p.Canvas.brush.Color:=clred;
preshow('X');
end
else
begin //p.canvas.TextRect(rect,rect.Left+3,rect.top,' ');
if sw then preshow(' ') else
if not momentflag then
begin
p.Canvas.brush.Color:=clred;
preshow(' ');
end else
if momentflag and  (momentnumber>=0) then
begin
p.Canvas.Font.Color:=clwhite;
preshow(inttostr(momentnumber));
end else
if momentflag then
begin
p.Canvas.Font.Color:=clred;
preshow(inttostr(-momentnumber));
end;


//p.Canvas.Brush.Color:=clwhite;
end
end
else
begin
if sw then p.Canvas.Brush.Color:=clwhite else p.Canvas.Brush.Color:=$00A0A0FF;
if mines=0 then
//p.canvas.TextRect(rect,rect.Left+3,rect.top,' ')
preshow(' ')
else
begin
case mines mod 10 of
0: p.Canvas.Font.Color:=$007FFF;
1: p.Canvas.Font.Color:=clblue;
2: p.Canvas.Font.Color:=clgreen;
3: p.Canvas.Font.Color:=clred;
4: p.Canvas.Font.Color:=clNavy;
5: p.Canvas.Font.Color:=clFuchsia;
6: p.Canvas.Font.Color:=clteal;
7: p.Canvas.Font.Color:=clolive;
8: p.Canvas.Font.Color:=clpurple;
9: p.Canvas.Font.Color:=clLime-$00003000+$00300000;
else p.Canvas.Font.Color:=clblack end;
//p.canvas.TextRect(rect,rect.Left+3,rect.top,''+inttostr(mines));
preshow(dig(mines));
end;
end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j,s:integer; xx:Morbit;
begin
if game=0 then
begin
//setcapture(form1.Handle);
{j:=y div size; if j>n2 then j:=n2;
i:=x div size; if i>n1 then i:=n1;}
if (y div ry) mod 3>0
then j:=(y div ry) div 3
else
if (((x div rx) mod 2 =(y div ry) mod 2)
and (rx*(y mod ry)<ry*(rx-x mod rx))
or
((x div rx) mod 2 <>(y div ry) mod 2)
and (rx*(y mod ry)<ry*(x mod rx)))
then j:=(y div ry) div 3-1
else j:=(y div ry) div 3;
if j mod 2=0 then i:=x div rx div 2
else
i:=(x div rx+1) div 2-1;

if (i>=0) and (i<=nn1) and (j>=0) and (j<=nn2) then
 if (ar[i,j].ingame) and (ar[i,j].state) then
    begin
   pressed:=ar[i,j];
   xx:=ar[i,j].around; momentnumber:=ar[i,j].mines;
   while xx<>nil do
   begin
   if Mcell1(xx.away).flag then momentnumber:=momentnumber-1;
   momentflag:=true;
   xx:=xx.next;
   end;
    xx:=ar[i,j].around;
   while xx<>nil do
   begin
   Mcell1(xx.away).show1(false);
   xx:=xx.next;
   end;
end
else if (ar[i,j].ingame) and not (ar[i,j].state) then
begin momentflag:=false; ar[i,j].show1(false); end;

end;
end;


procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j:integer; xx:Morbit;
begin
if game=0 then
begin
{j:=y div size; if j>n2 then j:=n2;
i:=x div size; if i>n1 then i:=n1;}
if (y div ry) mod 3>0
then j:=(y div ry) div 3
else
if (((x div rx) mod 2 =(y div ry) mod 2)
and (rx*(y mod ry)<ry*(rx-x mod rx))
or
((x div rx) mod 2 <>(y div ry) mod 2)
and (rx*(y mod ry)<ry*(x mod rx)))
then j:=(y div ry) div 3-1
else j:=(y div ry) div 3;
if j mod 2=0 then i:=x div rx div 2
else
i:=(x div rx+1) div 2-1;

if (i>=0) and (i<=nn1) and (j>=0) and (j<=nn2) then
 if ar[i,j].ingame then
  begin
   xx:=pressed.around;
   while xx<>nil do
   begin
   Mcell1(xx.away).show1(true);
   xx:=xx.next;
   end;
   if (ar[i,j].state=true) then ar[i,j].klik;
   if ((touch = 0) and (mbleft = button) or (touch = 1) and (mbright = button)) and  (shift=[]) and (ar[i,j].state=false)
   and (ar[i,j].flag=false)
   then if  ar[i,j].open then ar[i,j].klik;
    if ((touch = 0) and (mbright = button) or (touch = 1) and (mbleft = button)) and (shift=[])and (ar[i,j].state=false)
    then
    begin ar[i,j].flag:=not ar[i,j].flag; ar[i,j].show;
    end;
end;
end;
end;

procedure TForm1.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
resize:=true;
end;

procedure ClearField;
var i,j:integer;
begin
for i:=0 to oldnn1 do for j:=0 to oldnn2 do Mcell1.clear(ar[i,j]);
p.Destroy;
//Messagedlg(' ',mterror,[mbok],0);
end;

procedure TForm1.Button1Click(Sender: TObject);
var i2,j2,k2,l2:integer;
begin
if p<>nil then
begin
ClearField;
end;
oldnn1:=nn1;oldnn2:=nn2;
setlength(ar,nn1+1,nn2+1);
setlength(mm,nn1+1,nn2+1);
game:=0;
//label2.Caption:='P';
assignfile(fpr,{currentdirectory+'/Profiles/'+}curprofilename);
reset(fpr);
read(fpr,rec);
form1.Caption:=rec.Name;
button2.Caption:='Pause';

closefile(fpr);

p:=Timage.Create(Form1);
p.Top:=30;p.Left:=1;
//p.Canvas.Brush.Color:=clWhite;
//p.Canvas.moveto((n1+1)*2*rx+rx,0);
//p.Canvas.lineto((n1+1)*2*rx+rx,244);
//p.Canvas.moveto(0,(n2+1)*3*ry+ry);
//p.Canvas.lineto(410,(n2+1)*3*ry+ry);

p.Height:=(nn2+1)*3*ry+ry;
p.Width:=(nn1+1)*2*rx+rx;
p.Canvas.Brush.Color:=clWhite;
p.canvas.FillRect(Rect(1,1,p.Width,p.Height));
Form1.Width:=p.Left+p.Width;
Form1.Height:=28+p.Top+p.Height;

if sender=form1 then
begin
form1.Left:=(screen.DesktopWidth div 2)-(p.Width div 2);
form1.Top:=(screen.DesktopHeight div 2) -(p.Height div 2);
end;
p.canvas.brush.Color:=clbtnface;
p.Canvas.Font.Style:=[fsbold];
p.Canvas.Font.Size:=fontsize;
//p.canvas.FillRect(Rect(1,1,(n1+1)*size+1,(n2+1)*size+1));
p.canvas.brush.Color:=clwhite;
p.Parent:=form1;
p.OnMouseDown:=form1.Image1MouseDown;
p.OnMouseUp:=form1.Image1MouseUp;
p.OnMousemove:=form1.Image1Mousemove;
//form1.Repaint;
//form1.height:=400;
label1.Caption:='0';
{for j2:=0 to n2+1 do begin
MoveTo(1,j2*size);
lineto(p.Width,j2*size);
end;
for i2:=0 to n1+1 do begin
MoveTo(i2*size,1);
lineTo(i2*size,p.Height);
end;}

randomize;
nummin:=0;

for i2:=0 to nn1 do for j2:=0 to nn2 do
mm[i2,j2]:=false;
k2:=destnm;

while k2>0 do
begin
j2:=random(nn2+1);
i2:=random(nn1+1);
if not mm[i2,j2] and (i2<nn1)  and
(j2<nn2)
then begin mm[i2,j2]:=true; k2:=k2-1 end
end;

for i2:=0 to nn1 do for j2:=0 to nn2 do
begin
if not mm[i2,j2] then ar[i2,j2]:=Mcell1(Mcell1.New(false,false)) else
begin
ar[i2,j2]:=Mcell1(Mcell1.New(true,false));
nummin:=nummin+1;
end;
{r.left:=i2*size+1;
r.Right:=(i2+1)*size-1;
r.Top:=j2*size+1;
r.bottom:=(j2+1)*size-1;
ar[i2,j2].rect:=r;}
if j2 mod 2=0 then ar[i2,j2].aa:=rx+2*rx*i2 else ar[i2,j2].aa:=rx+rx+2*rx*i2;
ar[i2,j2].bb:=2*ry+(3*ry)*j2;
ar[i2,j2].ingame:=true;
ar[i2,j2].show1(true);
ar[i2,j2].light:=false;
timer1.Enabled:=true;
end;

pressed:=ar[nn1,nn2];

numcl:=(nn1+1)*(nn2+1)-nummin;
numsel:=nummin;
numtruesel:=nummin;
p.Canvas.Brush.Color:=clblack;
//label1.Caption:=inttostr(nummin);
label3.Caption:=inttostr(nummin);
paused:=false;

p.Canvas.Brush.Color:=clwhite;

for i2:=0 to nn1 do for j2:=0 to nn2 do
if ar[i2,j2].ingame then
begin
for k2:=0 to nn1 do for l2:=0 to nn2 do
if ar[k2,l2].ingame and (0<sqr(i2-k2)+sqr(j2-l2)) and
(sqr(ar[i2,j2].aa-ar[k2,l2].aa)+sqr(ar[i2,j2].bb-ar[k2,l2].bb)<sqr(4*rx)+1)
then
ar[i2,j2].addenv(ar[k2,l2]);
end;
pressed:=ar[0,0];
{for j2:=0 to n2 div 3 do
begin
ar[0,j2].open;
end;}

{for j2:=n2 div 3+1 to n2 do
begin
ar[n1,j2].open;
end;}

for i2:=0 to nn1 do begin ar[i2,nn2].open; {ar[i2,n2].open;} end;
for j2:=0 to nn2 do begin ar[nn1,j2].open; {ar[n1,j2].open;} end;
end;

procedure TForm1.FormShow(Sender: TObject);
var Tx:textfile;
begin
p:=nil;
  if FileExists(currentdirectory+'/Profiles/last') then
   begin
    assignfile(Tx,currentdirectory+'/Profiles/last');
    reset(Tx); readln(Tx,curprofilename);
    closefile(Tx);
    if not FileExists(curprofilename) then
     curprofilename:=currentdirectory+'/Profiles/Beginner.six';
   end else
  curprofilename:=currentdirectory+'/Profiles/Beginner.six';
  assignfile(fpr,curprofilename);
  reset(fpr);
  read(fpr,rec)  ;
  closefile(fpr);
  nn1:=rec.width;
  nn2:=rec.height;
  destnm:=rec.mines;
  caption:=rec.Name;
  form1.Button1Click(form1);
end;



procedure TForm1.Timer1Timer(Sender: TObject);
begin
if strtoint(label1.caption)<9999 then
label1.Caption:=inttostr(strtoint(label1.caption)+1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
//if not paused then
paused:=not paused;
p.Visible:=not paused;
if game=0 then timer1.Enabled:=not paused;
if paused then button2.Caption:='Play' else
button2.Caption:='Pause'
end;

procedure Tform1.lose(er:Mcell1);
var i,j:integer;
begin
timer1.Enabled:=false;
p.Canvas.Brush.Color:=clred; p.Canvas.Font.Color:=clblack;
//p.canvas.TextRect(rect,rect.Left+3,rect.top,'*');
er.preshow('*');
game:=2;
form1.caption:=form1.caption+': You''ve lost';
p.Canvas.Brush.Color:=clwhite;
for i:=0 to nn1 do for j:=0 to nn2 do if ar[i,j].mine and
(ar[i,j]<>er) then
if ar[i,j].flag  then
begin
p.Canvas.Font.Color:=clblack; ar[i,j].preshow('*');
end
else
begin
p.Canvas.Font.Color:=clred; ar[i,j].preshow('*');
end;
end;


procedure Tform1.win;
var  rec1:Tpr;
champ:boolean;ix,jx,kx:integer;
ar:array [0..10] of TPr;
begin
timer1.Enabled:=false;
assignfile(fpr,{currentdirectory+'/Profiles/'+}curprofilename);
reset(fpr);
read(fpr,rec1);
ix:=0;
while not eof(fpr) and (ix<=10) do
begin
read(fpr,rec);
ar[ix]:=rec;
ix:=ix+1;
end;
closefile(fpr);
champ:=false;
 jx:=0;
while (jx<ix) and not champ do
begin
if strtoint(label1.Caption)<ar[jx].time then
 begin
  kx:=jx;
  champ:=true
 end;
jx:=jx+1;
end;
if not champ and (ix<11) then begin
 kx:=ix; champ:=true;
 end ;

if champ then
begin
f:=Tform.Create(form1);
f.Icon:=form1.Icon;
f.BorderStyle:=bsSingle;
f.AutoSize:=true;
e1:=Tedit.Create(f);
b1:=Tbutton.Create(f);
l1:=Tlabel.Create(f);
l2:=Tlabel.Create(f);
l3:=Tlabel.Create(f);
l4:=Tlabel.Create(f);
b1.Caption:='Ok';
b1.Default:=true;
b1.Cancel:=true;
l1.Parent:=f;
l2.Parent:=f;
l3.Parent:=f;
l4.Parent:=f;
e1.Parent:=f;
b1.Parent:=f;
f.Caption:='GONGRATULATION!';
l1.Caption:='You are in TOP 11';
l2.Top:=15;
l2.Caption:='Profile: '''+rec1.Name+'''';
l3.Top:=30;
l3.Caption:='Position: '+ inttostr(kx+1);
l4.Top:=45;
l4.Caption:='Please enter your name';
e1.Top:=65;
b1.Top:=65;
e1.Width:=120;
b1.Left:=125;
f.Top:=form1.Top+80;
f.Height:=125;f.Width:=215;
f.Left:=form1.Left;
b1.OnClick:=newprofileok;
f.ShowModal;
if ix<11 then ix:=ix+1;
for jx:=ix-1 downto kx+1 do
ar[jx]:=ar[jx-1];
ar[kx].Name:=e1.Text;
ar[kx].Time:=strtoint(label1.Caption);
rewrite(fpr);
write(fpr,rec1);
for jx:=0 to ix-1 do write(fpr,ar[jx]);
closefile(fpr);
f.Free;
top111click(form1);
end;
end;

procedure TForm1.NewProfile1Click(Sender: TObject);
//var
//bb:boolean;
begin
newprofileresult:=0;
if timer1.Enabled then button2.Click;
f:=Tform.Create(form1);
f.Caption:='New Profile';
f.Icon:=form1.Icon;
//e0:=Tedit.Create(f);
e1:=Tedit.Create(f);e2:=Tedit.Create(f);e3:=Tedit.Create(f);
//l0:=Tlabel.Create(f);
l1:=Tlabel.Create(f);l2:=Tlabel.Create(f);l3:=Tlabel.Create(f);
b1:=Tbutton.Create(form1);b2:=Tbutton.Create(form1);

//l0.Caption:='Name of profile:';
l1.Caption:='Width:';l2.Caption:='Height:';l3.Caption:='Number of mines:';
//l0.left:=150;l1.left:=150;l2.left:=150;l3.left:=150;
//l0.Height:=19;
l1.Height:=19;l2.Height:=19;l3.Height:=19;
//l0.top:=20;
l1.top:=39;l2.top:=59;l3.top:=79;
//l0.Parent:=f;
l1.Parent:=f;l2.Parent:=f;l3.Parent:=f;

//e0.left:=100;
e1.left:=100;e2.left:=100;e3.left:=100;
//e0.Height:=19;
e1.Height:=19;e2.Height:=19;e3.Height:=19;
//e0.top:=19;
e1.top:=39;e2.top:=59;e3.top:=79;
//e0.Width:=100;
e1.Width:=30;e2.Width:=30;e3.Width:=30;
//e0.Text:='Profile1';
e1.Text:=inttostr(nn1+1);e2.Text:=inttostr(nn2+1);e3.Text:=
inttostr(destnm);
//inttostr((nn1+1)*(nn2+1) div 7);
//e0.Parent:=f;
e1.Parent:=f;e2.Parent:=f;e3.Parent:=f;

b1.Caption:='Ok';
b1.Default:=true;
b2.Caption:='Cancel';
b2.Cancel:=true;
b1.Left:=131;b2.left:=131;
b1.Top:=39;b2.Top:=74;
b1.Height:=25;b2.Height:=25;
b1.Width:=70; b2.width:=70;
b1.OnClick:=newprofileok;b2.OnClick:= newprofilecancel;
b1.Parent:=f; b2.Parent:=f;

f.AutoSize:=true;
f.Top:=form1.Top+50;
f.Left:=form1.Left;
f.showmodal;

if newprofileresult=1 then
begin
  curprofilename:=currentdirectory+'/Profiles/temp.tmp';
  assignfile(fpr,curprofilename);
  rewrite(fpr);
  try
  nn1:=strtoint(e1.text)-1;
  nn2:=strtoint(e2.text)-1;
  destnm:=strtoint(e3.text);
  //if nn1>40 then nn1:=40;
  if nn1<11 then nn1:=11;
  //if nn2>30 then nn2:=30;
  if nn2<1 then nn2:=1;
  if destnm>nn1*nn2 then destnm:=nn1*nn2;
  if destnm<1 then destnm:=1;
  except
  end;

rec.width:=nn1;
rec.height:=nn2;
rec.mines:=destnm;
rec.Name:='Temp';
write(fpr,rec);
closefile(fpr);
  f.Free;
    form1.Button1Click(form1)
end
else begin
    f.Free;
 end;

end;


procedure TForm1.newprofileok(Sender: TObject);
begin
  newprofileresult:=1;
  f.Close;
end;

procedure TForm1.newprofilecancel(Sender: TObject);
begin
  newprofileresult:=0;  f.Close;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
destnm:=(nn1+1)*(nn2+1) div 6;
//GetCurrentDirectory(SizeOf(CurrentDirectory), CurrentDirectory);
CurrentDirectory:=ExtractFileDir(Application.ExeName);//GetCurrentDir;
opendialog1.InitialDir:=CurrentDirectory+'/Profiles';
end;




procedure TForm1.N2Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.loadprofile(Sender: TObject);
begin
if timer1.enabled then button2.Click;
  if opendialog1.execute then
  if fileexists(opendialog1.FileName) then
  begin
  assignfile(fpr,opendialog1.FileName);
  reset(fpr);
  read(fpr,rec) ;
  nn1:=rec.width;
  nn2:=rec.height;
  destnm:=rec.mines;
  caption:=rec.Name;
  closefile(fpr);
  curprofilename:=opendialog1.FileName;
  form1.Button1Click(form1);
  end;
end;





procedure TForm1.TOP111Click(Sender: TObject);
var ix:byte;
begin
for ix:=0 to 10 do   form2.StringGrid1.Cells[0,ix]:='';
for ix:=0 to 10 do   form2.StringGrid1.Cells[1,ix]:='';
if not paused then button2.Click;
assignfile(fpr,{currentdirectory+'/Profiles/'+}curprofilename);
reset(fpr);
read(fpr,rec);
form2.Caption:='TOP 11: '+rec.Name;
for ix:=0 to 10 do
if not eof(fpr) then
 begin
  read(fpr,rec);
  form2.StringGrid1.Cells[0,ix]:=rec.Name;
  form2.StringGrid1.Cells[1,ix]:=inttostr(rec.time);
 end;
closefile(fpr);
form2.showmodal;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var Tx:Textfile;
begin
 assignfile(Tx,currentdirectory+'/Profiles/last');
 rewrite(Tx); writeln(Tx,curprofilename);
 closefile(Tx);
end;

end.
