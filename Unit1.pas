unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,MINES, ExtCtrls, StdCtrls, Menus;

const
     FormDy=50; // addition for correct window height
     FormDx=20; // addition for correct window width
     FieldTop=0; //play field Y-coordinate


     // Set separator='/' for Linux
     {$IFDEF UNIX}
      separator='/';
     {$ELSE}
      separator='\';
     {$ENDIF}


type

    TPR=record
              Name:string[15];
              case byte of
                   0: (width,height:byte;mines:word;);
                   1: (time:integer;)
              end;


    Mcell1=class(Mcell)
      aa,bb:integer; // physical cooryinates
      light:boolean;   // red light on during mouse movement
       procedure preshow(d:char;c:TColor);
     procedure show; override;
     procedure decreasenum;   override;
     procedure show1(sw:boolean); //show and hide red hints on the field
  end;

  { TForm1 }

  TForm1 = class(TForm)
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuZoomIn: TMenuItem;
    MenuDrag: TMenuItem;
    MenuItem4: TMenuItem;
    MenuOpenButton: TMenuItem;
    MenuStat: TMenuItem;
    MenuDragButton: TMenuItem;
    MenuZoomOut: TMenuItem;
    MenuNew: TMenuItem;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    Options: TMenuItem;
    NewProfile1: TMenuItem;
    LoadProfile1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Timer2: TTimer;
    TOP111: TMenuItem;
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormWindowStateChange(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1Mousemove
     (Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuZoomInClick(Sender: TObject);
    procedure MenuZoomOutClick(Sender: TObject);
    procedure MenuOpenButtonClick(Sender: TObject);
    procedure MenuDragButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure win;
    procedure lose;
    procedure NewProfile1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure newprofileok(Sender: TObject);
    procedure loadprofile(Sender: TObject);
    procedure newprofilecancel(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure TOP111Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MenuDragClick(Sender: TObject);
    private
    { Private declarations }
  public
    { Public declarations }
  end;




var
  Form1: TForm1;

implementation

{$R *.lfm}

uses Unit2,Drawing;

var

fpr: file of TPR;

// 1 - normally intsalled, 2 - first start, 0 - config is not available
filexists:integer=1;
//

rec:Tpr;
momentnumber:integer;  //temp number for mouse
momentflag:boolean ;  //temp flag for mouse

CurrentDirectory: array[0..MAX_PATH] of Char;   //path of exe-file
newprofileresult:integer; // result of selecting profile
curprofilename:string='';  // current profile




// Size parameters of cells
rymax:integer=10;
ry:integer=10;
rx:integer=18;
rr:integer=20;
//rr=2*ry;
//rx=9*ry div 5;

//Invert or revert buttons
touch:boolean=false; // open button
touch1:boolean=false; //drug button
//
//Drag mode
drag:boolean=true;

//Scroll temp coordinated
pausedx,pausedy:integer;
scrollx:integer=0;
scrolly:integer=0;
toscrollposx:integer=0;
toscrollposy:integer=0;
toscroll:boolean=false;
prescroll:boolean=false;
afterscroll:boolean=false;
afterzoomscroll:boolean=false;
//

Time:integer=0;
nn1:integer=17;   //columns
nn2:integer=16;   //rows
oldnn1,oldnn2:integer; //previous columns and rows
destnm:integer;    // number of mines
pressed:Mcell1; // pressed cell
paused:boolean;
ar:array of array of Mcell1;  // array of cells
er:Mcell1; //exploded bomb
mm:array of array of boolean; //array of bomb/not bomb
p:Timage=nil;  // the image of the game field
game:integer; //game is active if flag=0
numcl,nummin,numsel,numtruesel:integer;

f:Tform;e1,e2,e3:Tedit;b1,b2:Tbutton;
l1,l2,l3,l4:Tlabel;


//Initial profiling

procedure TForm1.FormCreate(Sender: TObject);
begin
destnm:=(nn1+1)*(nn2+1) div 6;
CurrentDirectory:=ExtractFileDir(Application.ExeName);//GetCurrentDir;
opendialog1.InitialDir:=CurrentDirectory+separator+'Profiles';
end;

procedure TForm1.FormShow(Sender: TObject);
var Tx:textfile; s:string;
begin
     p:=nil;
     if FileExists(currentdirectory+separator+'Profiles'+separator+'.config')
        then
            begin
                 assignfile(Tx,currentdirectory+separator+'Profiles'+separator+'.config');
                 reset(Tx);
                 readln(Tx,curprofilename);
                 readln(Tx,s);
                 rymax:=strtoint(s);
                 ry:=rymax;
                 rr:=2*ry;
                 rx:=9*ry div 5;
                 readln(Tx,s);
                 form1.Left:=strtoint(s);
                 readln(Tx,s);
                 form1.Top:=strtoint(s);
                 readln(Tx,s);
                 form1.Width:=strtoint(s);
                 readln(Tx,s);
                 form1.Height:=strtoint(s);
                 readln(Tx,s);
                 touch:=(strtoint(s)=1);
                 readln(Tx,s);
                 drag:=(strtoint(s)=1);
                 readln(Tx,s);
                 touch1:=(strtoint(s)=1);
                 closefile(Tx);
                 if not FileExists(curprofilename)
                    then filexists:=2;
            end
        else filexists:=2;
        if filexists=2
            then if FileExists(currentdirectory+separator+'Profiles'+separator+'Beginner.six')
                    then curprofilename:=currentdirectory+separator+'Profiles'+separator+'Beginner.six'
                    else filexists:=0;
        if filexists>0
           then
               begin
                assignfile(fpr,curprofilename);
                reset(fpr);
                read(fpr,rec)  ;
                closefile(fpr);
               end
           else
               begin
                  rec.width:=11;
                  rec.height:=11;
                  rec.mines:=20;
                  rec.name:='Temp';
                  TOP111.Enabled:=false;
               end;
        nn1:=rec.width;
        nn2:=rec.height;
        destnm:=rec.mines;
        caption:=rec.Name;
        if touch
           then form1.MenuOpenButton.Caption:='Open the cell by left button'
           else form1.MenuOpenButton.Caption:='Open the cell by right button';
        if drag
           then form1.MenuDrag.Caption:='Disable dragging'
           else form1.MenuDrag.Caption:='Enable dragging';
        form1.MenuDragButton.Enabled:=drag;
        if touch1
           then form1.MenuDragButton.Caption:='Drag the field by right button'
           else form1.MenuDragButton.Caption:='Drag the field by left button';
        form1.Button1Click(form1);
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin

end;


//Redraw the Timage p with cells

procedure Redraw;
var i2,j2:integer;
begin
     if p<>nil
        then p.Destroy;
     rr:=2*ry;
     rx:=9*ry div 5;
     p:=Timage.Create(Form1);
     p.Top:=FieldTop;p.Left:=0;
     p.Height:=(nn2+1)*3*ry+ry;
     p.Width:=(nn1+1)*2*rx+rx;

     p.Parent:=form1;

     p.Visible:=false;

     //p.OnMouseWheel:=form1.OnMouseWheel;
     p.OnMouseDown:=form1.Image1MouseDown;
     p.OnMouseUp:=form1.Image1MouseUp;
     p.OnMousemove:=form1.Image1Mousemove;
     p.Canvas.Brush.Color:=clWhite;
     p.canvas.FillRect(Rect(1,1,p.Width,p.Height));
     p.canvas.brush.Color:=clbtnface;
     for i2:=0 to nn1 do
         for j2:=0 to nn2 do
             begin
                  if j2 mod 2=0
                     then ar[i2,j2].aa:=rx+2*rx*i2
                     else ar[i2,j2].aa:=rx+rx+2*rx*i2;
                  ar[i2,j2].bb:=2*ry+(3*ry)*j2;
                  ar[i2,j2].show1(true);
                  ar[i2,j2].light:=false;
             end;
    end;

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
   hp:integer=0;
   vp:integer=0;
   hr:integer=1;
   vr:integer=1;

begin
  if not paused then
    begin
      if (wheeldelta>0) and (ry<rymax)
            then ry:=ry+1
            else
                if (wheeldelta<0) and (ry>=2) then ry:=ry-1;
      hp:=MousePos.x;
      vp:=MousePos.y;
      if HorzScrollBar.IsScrollBarVisible
        then
            begin
             hp:=hp+HorzScrollBar.Position-(form1.clientwidth div 2);
             hr:=p.Width;
            end;
      if VertScrollBar.IsScrollBarVisible then
          begin
           vp:=vp+VertScrollBar.Position-(form1.clientheight div 2);
           vr:=p.Height;
          end;
      Redraw;
      p.Visible:=true;
      afterzoomscroll:=true;
      toscrollposx:=(hp)*p.Width div hr;
      toscrollposy:=(vp)*p.Height div vr;
      if HorzScrollBar.IsScrollBarVisible then HorzScrollBar.Position:=(hp)*p.Width div hr;
      if VertScrollBar.IsScrollBarVisible then VertScrollBar.Position:=(vp)*p.Height div vr;
      Timer2.Enabled:=true;
    end;
end;

procedure TForm1.MenuZoomInClick(Sender: TObject);
var
   hp:integer=1;
   hr:integer=1;
   vp:integer=1;
   vr:integer=1;
begin
     if ry<=27 then rymax:=ry+1;
     ry:=rymax;
     if HorzScrollBar.IsScrollBarVisible and (p.Width>form1.clientwidth)
         then
             begin
              hp:=HorzScrollBar.Position;
              hr:=p.Width-form1.clientwidth;
             end;
     if VertScrollBar.IsScrollBarVisible and (p.Height>form1.ClientHeight)
         then
             begin
              vp:=VertScrollBar.Position;
              vr:=p.Height-form1.ClientHeight;
             end;
     Redraw;
      p.Visible:=true;
      if HorzScrollBar.IsScrollBarVisible then HorzScrollBar.Position:=hp*(p.Width-form1.clientwidth) div hr;
      if VertScrollBar.IsScrollBarVisible then VertScrollBar.Position:=vp*(p.Height-form1.ClientHeight) div vr;
    end;

procedure TForm1.MenuZoomOutClick(Sender: TObject);
var
   hp:integer=1;
   hr:integer=1;
   vp:integer=1;
   vr:integer=1;
begin
  if ry>=2 then rymax:=ry-1;
  ry:=rymax;
  if HorzScrollBar.IsScrollBarVisible and (p.Width>form1.clientwidth)
         then
             begin
              hp:=HorzScrollBar.Position;
              hr:=p.Width-form1.clientwidth;
             end;
     if VertScrollBar.IsScrollBarVisible and (p.Height>form1.ClientHeight)
         then
             begin
              vp:=VertScrollBar.Position;
              vr:=p.Height-form1.ClientHeight;
             end;
     Redraw;
      p.Visible:=true;
      if HorzScrollBar.IsScrollBarVisible then HorzScrollBar.Position:=hp*(p.Width-form1.clientwidth) div hr;
      if VertScrollBar.IsScrollBarVisible then VertScrollBar.Position:=vp*(p.Height-form1.ClientHeight) div vr;
end;



//

//Creating and destroying array of Mcell

procedure ClearField;
var i,j:integer;
begin
     for i:=0 to oldnn1 do
         for j:=0 to oldnn2 do
             Mcell1.clear(ar[i,j]);
end;

procedure TForm1.Button1Click(Sender: TObject);
var i2,j2,k2,l2:integer;
begin
  game:=0;
  if filexists>0
           then
               begin
                assignfile(fpr,curprofilename);
                reset(fpr);
                read(fpr,rec)  ;
                closefile(fpr);
               end
           else
               begin
                  rec.width:=12;
                  rec.height:=12;
                  rec.mines:=20;
                  rec.name:='Temp';
               end;
   form1.Caption:=rec.Name;
  if p<>nil
        then ClearField;
        rr:=2*ry;
        rx:=9*ry div 5;
     oldnn1:=nn1;oldnn2:=nn2;
     setlength(ar,nn1+1,nn2+1);
     setlength(mm,nn1+1,nn2+1);

          //stupid randomization of bombs
     randomize;
     nummin:=0;
     for i2:=0 to nn1 do
         for j2:=0 to nn2 do
             mm[i2,j2]:=false;
     k2:=destnm;

     while k2>0 do
     begin
          j2:=random(nn2+1);
          i2:=random(nn1+1);
          if not mm[i2,j2] and (i2<nn1)  and (j2<nn2)
             then
                 begin
                      mm[i2,j2]:=true;
                      k2:=k2-1
                 end
     end;
     //

     //creating the cells
     for i2:=0 to nn1 do
         for j2:=0 to nn2 do
             begin
                  if not mm[i2,j2]
                     then ar[i2,j2]:=Mcell1(Mcell1.New(false,false))
                     else
                         begin
                              ar[i2,j2]:=Mcell1(Mcell1.New(true,false));
                              nummin:=nummin+1;
                         end;
             end;

     pressed:=ar[nn1,nn2];
     numcl:=(nn1+1)*(nn2+1)-nummin;
     numsel:=nummin;
     numtruesel:=nummin;

     //Draw the playfield and assign the coordinatates (aa,bb) to each of cells
     Redraw;

     //Connecting the cells
     for i2:=0 to nn1 do
         for j2:=0 to nn2 do
                    begin
                         for k2:=0 to nn1 do
                             for l2:=0 to nn2 do
                                 //we are connecting the cell (i2,j2) with (k2,l2) if they are physically close
                                 if //ar[k2,l2].ingame and
                                 (0<sqr(i2-k2)+sqr(j2-l2)) and
                                 (sqr(ar[i2,j2].aa-ar[k2,l2].aa)+sqr(ar[i2,j2].bb-ar[k2,l2].bb)<18*sqr(rx)+1)
                                    then ar[i2,j2].addenv(ar[k2,l2]);
                                 //
                    end;

     for i2:=0 to nn1
         do ar[i2,nn2].open;
     for j2:=0 to nn2
         do ar[nn1,j2].open;

     //the game form update
     paused:=false;
     Time:=0;
     MenuStat.Caption:='Mines: '+inttostr(nummin)+'  '+'Time: '+inttostr(Time);
     form1.MenuZoomIn.Enabled:=true;
     form1.MenuZoomOut.Enabled:=true;
     timer1.Enabled:=true;
     afterscroll:=true;
     p.Visible:=true;
     afterzoomscroll:=true;
     if HorzScrollbar.IsScrollBarVisible
       then toscrollposx:=HorzScrollBar.Range;
     If  VertScrollbar.IsScrollBarVisible
       then toscrollposy:=VertScrollBar.Range;
     timer2.Enabled:=true;


     //

end;


//extending Mcell functionality
function dig(x:integer):char;
begin
     if x<10
        then result:=inttostr(x)[1]
        else result:=chr(ord('A')+x-10);
end;

function inttocolor(m:integer):TColor;
begin
     case m mod 11 of
          1: result:=clblue;
          2: result:=clgreen;
          3: result:=clred;
          4: result:=clNavy;
          5: result:=clmaroon;
          6: result:=clteal;
          7: result:=clolive;
          8: result:=clpurple;
          9: result:=clLime-$00003000+$00300000;
          10: result:=$007FFF;
          0: result:=clFuchsia
          else result:=clblack
     end;
end;

procedure Mcell1.decreasenum;
var i1,j1:integer;
begin
     numcl:=numcl-1;
     form1.show;
     if numcl=0
        then
            for i1:=0 to nn1 do
            for j1:=0 to nn2 do
                if (ar[i1,j1].mine) and (not ar[i1,j1].flag)
                       then
                        begin
                             ar[i1,j1].flag:=true;
                             ar[i1,j1].show
                        end;;
end;



procedure Mcell1.preshow(d:char; c:Tcolor);
begin
     p.Canvas.Pen.Width:=1;
     p.Canvas.Pen.Color:=clBlack;
     DrawHex(p.Canvas,rx,ry,rr,aa,bb);

     p.Canvas.Pen.Width:=2+ry div 10;
     p.Canvas.Pen.Color:=c;
         case d of
          '*':    DrawStar(p.Canvas,ry,aa-9*ry div 10,bb-10*ry div 10);
          'X':    DrawX(p.Canvas,ry,aa-8*ry div 10,bb-10*ry div 10);
          ' ': ;
          '0': Draw0(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
          'A':  begin
                   Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                   Draw0(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
               end;
          '1': Draw1(p.Canvas,ry,aa-4*ry div 10,bb-8*ry div 10);
          'B':  begin
                   Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                   Draw1(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
               end;
          '2': Draw2(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
          'C':  begin
                    Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                    Draw2(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
                end;
          '3': Draw3(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
          'D': begin
                    Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                    Draw3(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
               end;
          '4': Draw4(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
          'E': begin
                    Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                    Draw4(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
               end;
          '5':  Draw5(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
          'F':  begin
                     Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                     Draw5(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
                end;
           '6': Draw6(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
           'G': begin
                    Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                    Draw6(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
                end;
            '7': Draw7(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
            'H': begin
                    Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                    Draw7(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
                 end;
             '8': Draw8(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
             'I': begin
                    Draw1(p.Canvas,ry,aa-10*ry div 10,bb-8*ry div 10);
                    Draw8(p.Canvas,ry,aa+2*ry div 10,bb-8*ry div 10);
                 end;
             '9': Draw9(p.Canvas,ry,aa-5*ry div 10,bb-8*ry div 10);
          else     ;
     end;
    // p.Canvas.Pen.Color:=clBlack;

end;

procedure Mcell1.show;
begin
     if not state
        then
            begin
                 p.Canvas.Brush.Color:=$00C0D0D0;
                 if flag
                    then
                        begin
                             preshow('X',clBlack);
                             numsel:=numsel-1;
                             form1.MenuStat.caption:='Mines: '+inttostr(numsel)+'  '+'Time: '+inttostr(Time);
                             if mine
                                then numtruesel:=numtruesel-1;
                             if (numtruesel=0) and (numsel=0)
                                then
                                    begin
                                         game:=1;
                                         form1.caption:=form1.caption+': You''ve won';
                                         form1.win;
                                    end;
                        end
                    else
                        begin
                             preshow(' ',clBlack);
                             p.Canvas.Brush.Color:=clwhite;
                             numsel:=numsel+1;
                             form1.MenuStat.caption:='Mines: '+inttostr(numsel)+'  '+'Time: '+inttostr(Time);
                             if mine
                                then numtruesel:=numtruesel+1;
                             if (numtruesel=0) and (numsel=0)
                                then
                                    begin
                                         game:=1;
                                         form1.caption:=form1.caption+': You''ve won';
                                         form1.win;
                                    end;
                        end
            end
        else
            if mine
               then
                   begin
                        er:=self;
                        form1.lose;
                   end
               else
                   begin
                        p.Canvas.Brush.Color:=clwhite;
                        if mines=0
                           then preshow(' ',clBlack)
                           else
                               begin
                                    preshow(dig(mines),inttocolor(mines));
                               end;
                   end;
end;

procedure Mcell1.show1(sw:boolean);
begin
     if (game=2) and (self=er)
       then
         begin
           p.Canvas.Brush.Color:=clred;
           preshow('*',clWhite);
         end
     else if (game=2) and mine and (self<>er)  and flag
       then
           begin
             p.Canvas.Brush.Color:=clwhite;
             preshow('*',clBlack);
           end
      else if (game=2) and mine and (self<>er)  and not flag
        then
           begin
             p.Canvas.Brush.Color:=clwhite;
             preshow('*',clred);
           end
     else
     if not state
        then
            begin
                 if sw
                    then p.Canvas.Brush.Color:=$00C0D0D0
                    else p.Canvas.Brush.Color:=clgray;
                 if flag
                    then
                        begin
                             if not sw
                                then p.Canvas.brush.Color:=clred;
                                preshow('X',clBlack);
                        end
                    else
                        begin
                             if sw
                                then preshow(' ',clBlack)
                                else
                                    if momentflag
                                       then
                                           if momentnumber>=0
                                            then
                                                begin
                                                     preshow(dig(momentnumber),clWhite);
                                                end
                                            else
                                                begin
                                                     preshow(dig(-momentnumber),clRed);
                                                end
                                       else
                                           begin
                                                p.Canvas.brush.Color:=clred;
                                                preshow(' ',clBlack);
                                           end
                        end
            end
        else
            begin
                 if sw
                    then p.Canvas.Brush.Color:=clwhite
                    else p.Canvas.Brush.Color:=$00A0A0FF;
                 if mines=0
                    then preshow(' ',clBlack)
                    else
                        begin
                             preshow(dig(mines),inttocolor(mines));
                        end;
            end;
end;
//

//mouse events
procedure xytoij (x,y:integer; var i,j:integer);
begin
     if (y div ry) mod 3>0
        then j:=(y div ry) div 3
        else
            if
                     (((x div rx) mod 2 =(y div ry) mod 2) and
                     (rx*(y mod ry)<ry*(rx-x mod rx))
                                 or
                     ((x div rx) mod 2 <>(y div ry) mod 2) and
                     (rx*(y mod ry)<ry*(x mod rx)))
            then j:=(y div ry) div 3-1
            else j:=(y div ry) div 3;
     if j mod 2=0
        then i:=x div rx div 2
        else i:=(x div rx+1) div 2-1;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j:integer; xx:Morbit;
begin
   if not prescroll and not toscroll and (HorzScrollBar.IsScrollBarVisible or VertScrollBar.IsScrollBarVisible) and
     drag and (touch1 and (mbleft = button) or not touch1 and (mbright = button))
      then
           begin
                prescroll:=true;
                scrollx:=x;
                scrolly:=y
           end;
   if (game=0)  and not toscroll and not afterscroll
    then
        begin
             xytoij(x,y,i,j);
             if (i>=0) and (i<=nn1) and (j>=0) and (j<=nn2)
                then
                    if //(ar[i,j].ingame) and
                    (ar[i,j].state)
                       then
                           begin
                                pressed:=ar[i,j];
                                xx:=ar[i,j].around;
                                momentnumber:=ar[i,j].mines;
                                while xx<>nil do
                                      begin
                                           if Mcell1(xx.away).flag
                                              then momentnumber:=momentnumber-1;
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
                       else
                           if //(ar[i,j].ingame) and
                           not (ar[i,j].state)
                              then
                                  begin
                                       momentflag:=false;
                                       ar[i,j].show1(false);
                                  end;

        end;
end;


procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,j:integer; xx:Morbit;
begin
 if (game=0) and not toscroll and not afterscroll
  then
   begin
        xytoij(x,y,i,j);
        if (i>=0) and (i<=nn1) and (j>=0) and (j<=nn2)
           then
               //if ar[i,j].ingame then
                  begin
                       xx:=pressed.around;
                       while xx<>nil do
                             begin
                                  Mcell1(xx.away).show1(true);
                                  xx:=xx.next;
                             end;
                       if (ar[i,j].state=true) then ar[i,j].klik;
                       if ((not touch ) and (mbleft = button) or (touch) and (mbright = button))
                                           and  (shift=[])
                                           and (ar[i,j].state=false)
                                           and (ar[i,j].flag=false)
                                  then
                                      if  ar[i,j].open
                                          then ar[i,j].klik;
                       if ((not touch) and (mbright = button) or (touch ) and (mbleft = button))
                                           and (shift=[])
                                           and (ar[i,j].state=false)
                                  then
                                      begin
                                           ar[i,j].flag:=not ar[i,j].flag;
                                           ar[i,j].show;
                                      end;
                  end;
   end;
 toscroll:=false;
 prescroll:=false;
end;

procedure tform1.Image1Mousemove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); //this is for red light hints, it is very unclear through
var i,j:integer; xx:Morbit;

begin
  if (not (ssRight in Shift) and not touch1) or (not (ssLeft in Shift) and touch1)
    then
        begin
             prescroll:=false;
             toscroll:=false;
             afterscroll:=false;
        end;
  if drag and HorzScrollBar.IsScrollBarVisible and toscroll and (((ssRight in Shift) and not touch1) or ((ssLeft in Shift) and touch1))
       then
           begin
                toscrollposx:=scrollx-x;
                if toscrollposx<0
                   then toscrollposx:=0
                   else
                     if toscrollposx>HorzScrollBar.Range
                        then toscrollposx:=HorzScrollBar.Range;
                Timer2.Enabled:=true;
           end;
 if drag and VertScrollBar.IsScrollBarVisible and toscroll and (((ssRight in Shift) and not touch1) or ((ssLeft in Shift) and touch1))
       then
           begin
                toscrollposy:=scrolly-y;
                if toscrollposy<0
                   then toscrollposy:=0
                   else
                     if toscrollposy>VertScrollBar.Range
                        then toscrollposy:=VertScrollBar.Range;
                Timer2.Enabled:=true;
           end;
 if drag and (prescroll or afterscroll) and ((scrollx-x>10) or (x-scrollx>10) or (scrolly-y>10) or (y-scrolly>10))
   and (HorzScrollBar.IsScrollBarVisible or VertScrollBar.IsScrollBarVisible)
   and (((ssRight in Shift) and not touch1) or ((ssLeft in Shift) and touch1))
    then
        begin
             toscroll:=true;
             scrollx:=x+HorzScrollBar.Position;
             scrolly:=y+VertScrollBar.Position;
             prescroll:=false;
             afterscroll:=false;
        end;
 if game=0
   then
       begin
            xytoij(x,y,i,j);
            if (i>=0) and (i<=nn1) and (j>=0) and (j<=nn2) //and (ar[i,j].ingame)
               then
                   if (ar[i,j]<>pressed)
                      then
                          begin
                               if  not pressed.state
                                   then
                                       begin
                                            momentflag:=false;
                                            pressed.show1(true);
                                       end;
                               if (Shift<>[])  and not toscroll and not afterscroll  and
                                 not ar[i,j].state
                                  then
                                      begin
                                           momentflag:=false;
                                           ar[i,j].show1(false);
                                      end;
                               xx:=pressed.around;
                               while xx<>nil do
                                     begin
                                          Mcell1(xx.away).light:=true;
                                          xx:=xx.next;
                                     end;
                               if (Shift<>[]) and   not toscroll and not afterscroll  and
                                 (ar[i,j].state)
                                  then
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
                               if (Shift<>[]) and   not toscroll and not afterscroll  and
                                 (ar[i,j].state)
                                             then
                                                 begin
                                                      xx:=ar[i,j].around;
                                                      momentnumber:=ar[i,j].mines;
                                                      while xx<>nil do
                                                            begin
                                                                 if Mcell1(xx.away).flag
                                                                    then momentnumber:=momentnumber-1;
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
                          end;
       end;
end;
//

//Timer event
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if Time<9999
        then
            begin
             Time:=Time+1;
             MenuStat.caption:='Mines: '+inttostr(numsel)+'  '+'Time: '+inttostr(Time);
            end;
end;
//

//Pause-Play button
procedure TForm1.Button2Click(Sender: TObject);
begin
     if paused
       then
           begin
            p.Visible:=true;
            if HorzScrollBar.IsScrollBarVisible
              then HorzScrollBar.Position:=pausedx;
            if VertScrollBar.IsScrollBarVisible
              then VertScrollBar.Position:=pausedy;
           end
       else
           begin
            if HorzScrollBar.IsScrollBarVisible
              then pausedx:=HorzScrollBar.Position;
            if VertScrollBar.IsScrollBarVisible
              then pausedy:=VertScrollBar.Position;
            p.Visible:=false;
           end;
     MenuZoomIn.Enabled:=paused;
     MenuZoomOut.Enabled:=paused;
     if game=0 then timer1.Enabled:=paused;
     paused:=not paused;
end;



//

//Endings
procedure Tform1.lose;  //er is the cell with the expolded bomb
var i,j:integer;
begin
     timer1.Enabled:=false;
     p.Canvas.Brush.Color:=clred;
     er.preshow('*',clWhite);
     game:=2;
     //form1.MenuZoomIn.Enabled:=false;
     //form1.MenuZoomOut.Enabled:=false;
     form1.caption:=form1.caption+': You''ve lost';
     p.Canvas.Brush.Color:=clwhite;

     for i:=0 to nn1 do
         for j:=0 to nn2 do
             if ar[i,j].mine and (ar[i,j]<>er)
                then
                    if ar[i,j].flag
                       then
                           begin
                                ar[i,j].preshow('*',clBlack);
                           end
                       else
                           begin
                                ar[i,j].preshow('*',clred);
                           end;
end;


procedure Tform1.win;
var  rec1:Tpr;
champ,istemp:boolean;ix,jx,kx:integer;
ar:array [0..10] of TPr;
begin
  timer1.Enabled:=false;
  if filexists>0
    then
        begin
             assignfile(fpr,curprofilename);
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
                if Time<ar[jx].time
                   then
                       begin
                            kx:=jx;
                            champ:=true
                       end;
                jx:=jx+1;
             end;
             if not champ and (ix<11)
               then
                begin
                  kx:=ix;
                  champ:=true;
                end ;
             if champ
                then
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
                         f.Caption:='Success!';
                         l2.Top:=15;
                         l3.Top:=30;
                         l4.Top:=45;
                         istemp:=CompareStr(rec1.Name,'Temp')=0;
                         if istemp
                            then
                                begin
                                     l1.Caption:='Now you can save your profile.';
                                     l2.Caption:='Then you can rename temp.tmp';
                                     l3.Caption:='to a *.six file accordingly.';
                                     l4.Caption:='Please enter the profile name';
                                end
                            else
                                begin
                                     l1.Caption:='You are in TOP 11';
                                     l2.Caption:='Profile: '''+rec1.Name+'''';
                                     l3.Caption:='Position: '+ inttostr(kx+1);
                                     l4.Caption:='Please enter your name';
                                end;
                         e1.Top:=65;
                         b1.Top:=65;
                         e1.Width:=150;
                         b1.Left:=155;
                         f.Top:=form1.Top+80;
                         f.Height:=125;f.Width:=215;
                         f.Left:=form1.Left;
                         b1.OnClick:=newprofileok;
                         f.ShowModal;
                         if istemp
                            then rec1.Name:=e1.Text;
                         if ix<11
                            then ix:=ix+1;
                         for jx:=ix-1 downto kx+1 do
                             ar[jx]:=ar[jx-1];
                         ar[kx].Name:=e1.Text;
                         ar[kx].Time:=Time;
                         rewrite(fpr);
                            write(fpr,rec1);
                            if istemp
                                then else for jx:=0 to ix-1 do
                                   write(fpr,ar[jx]);
                            closefile(fpr);
                         f.Free;
                         if istemp
                            then else top111click(form1);
                    end;
        end;
end;
//

//New Profile form
procedure TForm1.NewProfile1Click(Sender: TObject);
begin
     newprofileresult:=0;
     if timer1.Enabled
        then MenuStat.Click;
     f:=Tform.Create(form1);
     f.Caption:='New Profile';
     f.Icon:=form1.Icon;
     e1:=Tedit.Create(f);
     e2:=Tedit.Create(f);
     e3:=Tedit.Create(f);
     l1:=Tlabel.Create(f);l2:=Tlabel.Create(f);
     l3:=Tlabel.Create(f);
     b1:=Tbutton.Create(form1);
     b2:=Tbutton.Create(form1);
     l1.Caption:='Width:';
     l2.Caption:='Height:';
     l3.Caption:='Number of mines:';
     l1.Height:=19; l2.Height:=19; l3.Height:=19;
     l1.top:=39; l2.top:=59; l3.top:=79;
     l1.Parent:=f; l2.Parent:=f; l3.Parent:=f;
     e1.left:=125; e2.left:=125; e3.left:=125;
     e1.Height:=19; e2.Height:=19; e3.Height:=19;
     e1.top:=39; e2.top:=59; e3.top:=79;
     e1.Width:=30; e2.Width:=30; e3.Width:=30;
     e1.Text:=inttostr(nn1+1);
     e2.Text:=inttostr(nn2+1);
     e3.Text:=inttostr(destnm);
     e1.Parent:=f; e2.Parent:=f; e3.Parent:=f;
     b1.Caption:='Ok';
     b1.Default:=true;
     b2.Caption:='Cancel';
     b2.Cancel:=true;
     b1.Left:=175; b2.left:=175;
     b1.Top:=39; b2.Top:=74;
     b1.Height:=25; b2.Height:=25;
     b1.Width:=70; b2.width:=70;
     b1.OnClick:=newprofileok;
     b2.OnClick:= newprofilecancel;
     b1.Parent:=f; b2.Parent:=f;
     f.AutoSize:=true;
     f.Top:=form1.Top+50;
     f.Left:=form1.Left;
     f.BorderStyle:=bsSingle;
     f.showmodal;
     if newprofileresult=1
      then
       begin
         try
           nn1:=strtoint(e1.text)-1;
           nn2:=strtoint(e2.text)-1;
           destnm:=strtoint(e3.text);
           if nn1<11
              then nn1:=11;
           if nn2<1
              then nn2:=1;
           if destnm>nn1*nn2
              then destnm:=nn1*nn2;
           if destnm<1
              then destnm:=1;
         except
         end;
         rec.width:=nn1;
         rec.height:=nn2;
         rec.mines:=destnm;
         rec.Name:='Temp';
         if filexists>0
            then
                begin
                     curprofilename:=currentdirectory+separator+'Profiles'+separator+'temp.tmp';
                     assignfile(fpr,curprofilename);
                     rewrite(fpr);
                     write(fpr,rec);
                     closefile(fpr);
                end;
          f.Free;
            form1.Button1Click(form1)
       end
      else f.Free;
end;
//

//Load Profile Dialog
procedure TForm1.loadprofile(Sender: TObject);
begin
     if timer1.enabled
        then MenuStat.Click; //Click Pause
     if opendialog1.execute
        then
            if fileexists(opendialog1.FileName)
               then
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
//

//Showing the scores
procedure TForm1.TOP111Click(Sender: TObject);
var ix:byte;
begin
  if filexists>0
    then
      begin
           for ix:=0 to 10 do
               form2.StringGrid1.Cells[0,ix]:='';
           for ix:=0 to 10 do
               form2.StringGrid1.Cells[1,ix]:='';
           assignfile(fpr,curprofilename);
           reset(fpr);
             read(fpr,rec);
             form2.Caption:='TOP 11: '+rec.Name;
             for ix:=0 to 10 do
                 if not eof(fpr)
                    then
                        begin
                             read(fpr,rec);
                             form2.StringGrid1.Cells[0,ix]:=rec.Name;
                             form2.StringGrid1.Cells[1,ix]:=inttostr(rec.time);
                        end;
           closefile(fpr);
           form2.showmodal;
      end;
end;
//

//Closing the game
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var Tx:Textfile;
begin
     if p<>nil
        then ClearField;
     if filexists>0
        then
            begin
             assignfile(Tx,currentdirectory+separator+'Profiles'+separator+'.config');
             rewrite(Tx);
             writeln(Tx,curprofilename);
             writeln(Tx,inttostr(rymax));
             writeln(Tx,inttostr(Form1.Left));
             writeln(Tx,inttostr(Form1.Top));
             writeln(Tx,inttostr(Form1.Width));
             writeln(Tx,inttostr(Form1.Height));
             if touch
               then writeln(Tx,'1')
               else writeln(Tx, '0');
             if drag
               then writeln(Tx,'1')
               else writeln(Tx, '0');
             if touch1
               then writeln(Tx,'1')
               else writeln(Tx, '0');
             closefile(Tx);
            end;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
     Close;
end;
//

//Ok and Cancel functions for modal runtime forms
procedure TForm1.newprofileok(Sender: TObject);
begin
  newprofileresult:=1;
  f.Close;
end;

procedure TForm1.newprofilecancel(Sender: TObject);
begin
  newprofileresult:=0;
  f.Close;
end;
//

//Invert and revert buttons menu
procedure TForm1.MenuOpenButtonClick(Sender: TObject);
begin
   touch:=not touch;
   if touch
      then form1.MenuOpenButton.Caption:='Open the cell by left button'
      else form1.MenuOpenButton.Caption:='Open the cell by right button';
 end;

procedure TForm1.MenuDragButtonClick(Sender: TObject);
begin
   touch1:=not touch1;
   if touch1
      then form1.MenuDragButton.Caption:='Drag the field by right button'
      else form1.MenuDragButton.Caption:='Drag the field by left button';

end;

procedure TForm1.MenuDragClick(Sender: TObject);
begin
   drag:=not drag;
   if drag
      then form1.MenuDrag.Caption:='Disable dragging'
      else form1.MenuDrag.Caption:='Enable dragging';
   form1.MenuDragButton.Enabled:=drag;
end;

//Resize behaviour

procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
    Timer2.Enabled:=false;
    Timer2.Enabled:=true;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
   tempx:integer=0;
   tempy:integer=0;
   dx,dy,tp,lf:integer;
begin
  if (p<>nil)  then
      begin
       if (Form1.WindowState=wsMaximized) then
           begin
             tempx:=form1.width;
             tempy:=form1.height;
             dx:=form1.Width-form1.ClientWidth;
             dy:=form1.Height-form1.ClientHeight;
             lf:=form1.left;
             tp:=form1.top;
             if tempx>dx+p.Width
                then tempx:=dx+p.Width;
             if tempy>dy+p.Height
                then tempy:=dy+p.Height;
             if tempx<470 then tempx:=470;
             Form1.WindowState:=wsNormal;
             form1.width:=tempx;
             form1.height:=tempy;
             form1.top:=tp;
             form1.left:=lf;
             VertScrollbar.Visible:=false;
             VertScrollbar.Visible:=true;
             HorzScrollbar.Visible:=false;
             HorzScrollbar.Visible:=true;
             afterzoomscroll:=true;
             if HorzScrollbar.IsScrollBarVisible
                 then toscrollposx:=HorzScrollBar.Range;
             If  VertScrollbar.IsScrollBarVisible
                 then toscrollposy:=VertScrollBar.Range;
           end;
       end;

  if HorzScrollbar.IsScrollBarVisible
    then
        if toscroll or afterzoomscroll
           then HorzScrollbar.Position:=toscrollposx;
  If  VertScrollbar.IsScrollBarVisible
    then
      if toscroll or afterzoomscroll
        then VertScrollbar.Position:=toscrollposy;
  Timer2.Enabled:=false;
  if toscroll then
      begin
       toscroll:=false;
       afterscroll:=true;
      end;
  if afterzoomscroll then afterzoomscroll:=false;

end;
//


end.
