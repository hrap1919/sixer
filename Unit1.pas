unit Unit1;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,MINES, ExtCtrls, StdCtrls, Menus;

type
    TPR=record
       Name:string[15];
        case byte of
          0: (width,height:byte;mines:word;);
          1: (time:integer;)
          end;

    Mcell1=class(Mcell)
      aa,bb:integer; // physical coordinates
      light:boolean;   // red light on during mouse movement
       procedure preshow(d:string);
     procedure show; override;
     procedure decreasenum;   override;
     procedure show1(sw:boolean); //show and hide red hints on the field
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

uses Unit2;

const
     // Size parameters of cells
     rr=20;
     rx=18;
     ry=10;
     // Offest parameters for digits
     digitoffsetx=7;
     digitoffsety=16;
     // Size of digits
     fontsize=18;
     // Set touch=1 to inverst left and right mouse clicks
     touch=0;
var

fpr: file of TPR;
rec:Tpr;
momentnumber:integer;  //temp number for mouse
momentflag:boolean ;  //temp flag for mouse

CurrentDirectory: array[0..MAX_PATH] of Char;   //path of exe-file
newprofileresult:integer; // result of selecting profile
curprofilename:string;  // current profile

nn1:integer=17;   //columns
nn2:integer=16;   //rows
oldnn1,oldnn2:integer; //previous columns and rows
destnm:integer;    // number of mines
pressed:Mcell1; // pressed cell
paused:boolean;
ar:array of array of Mcell1;  // array of cells
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
opendialog1.InitialDir:=CurrentDirectory+'\Profiles';
end;

procedure TForm1.FormShow(Sender: TObject);
var Tx:textfile;
begin
     p:=nil;
     if FileExists(currentdirectory+'\Profiles\last')
        then
            begin
                 assignfile(Tx,currentdirectory+'\Profiles\last');
                 reset(Tx);
                           readln(Tx,curprofilename);
                 closefile(Tx);
                 if not FileExists(curprofilename)
                    then curprofilename:=currentdirectory+'\Profiles\Beginner.six';
            end
        else curprofilename:=currentdirectory+'\Profiles\Beginner.six';
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
//

//Creating and destroying p:Timage and the associated array of Mcell

procedure ClearField;
var i,j:integer;
begin
     for i:=0 to oldnn1 do
         for j:=0 to oldnn2 do
             Mcell1.clear(ar[i,j]);
     p.Destroy;
end;

procedure TForm1.Button1Click(Sender: TObject);
var i2,j2,k2,l2:integer;
begin
     if p<>nil
        then ClearField;
     oldnn1:=nn1;oldnn2:=nn2;
     setlength(ar,nn1+1,nn2+1);
     setlength(mm,nn1+1,nn2+1);
     game:=0;

     assignfile(fpr,{currentdirectory+'\Profiles\'+}curprofilename);
     reset(fpr);
                button2.Caption:='Pause';
                read(fpr,rec);
                form1.Caption:=rec.Name;
     closefile(fpr);

     //creating Timage control
     p:=Timage.Create(Form1);
     p.Top:=30;p.Left:=1;
     p.Height:=(nn2+1)*3*ry+ry;
     p.Width:=(nn1+1)*2*rx+rx;
     p.Canvas.Brush.Color:=clWhite;
     p.canvas.FillRect(Rect(1,1,p.Width,p.Height));
     if sender=form1 then
     begin
          form1.Left:=(screen.DesktopWidth div 2)-(p.Width div 2);
          form1.Top:=(screen.DesktopHeight div 2) -(p.Height div 2);
     end;
     p.canvas.brush.Color:=clbtnface;
     p.Canvas.Font.Style:=[fsbold];
     p.Canvas.Font.Size:=fontsize;
     p.canvas.brush.Color:=clwhite;
     p.Parent:=form1;
     p.OnMouseDown:=form1.Image1MouseDown;
     p.OnMouseUp:=form1.Image1MouseUp;
     p.OnMousemove:=form1.Image1Mousemove;
     label1.Caption:='0';
     //

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

     //connecting the cells
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
                  if j2 mod 2=0
                     then ar[i2,j2].aa:=rx+2*rx*i2
                     else ar[i2,j2].aa:=rx+rx+2*rx*i2;
                  ar[i2,j2].bb:=2*ry+(3*ry)*j2;
                  //ar[i2,j2].ingame:=true;
                  ar[i2,j2].show1(true);
                  ar[i2,j2].light:=false;
             end;
     pressed:=ar[nn1,nn2];
     numcl:=(nn1+1)*(nn2+1)-nummin;
     numsel:=nummin;
     numtruesel:=nummin;
     p.Canvas.Brush.Color:=clblack;
     label3.Caption:=inttostr(nummin);
     paused:=false;
     p.Canvas.Brush.Color:=clwhite;
     for i2:=0 to nn1 do
         for j2:=0 to nn2 do
             //if ar[i2,j2].ingame
              //  then
                    begin
                         for k2:=0 to nn1 do
                             for l2:=0 to nn2 do
                                 //we are connecting the cell (i2,j2) with (k2,l2) if they are physically close
                                 if //ar[k2,l2].ingame and
                                 (0<sqr(i2-k2)+sqr(j2-l2)) and
                                 (sqr(ar[i2,j2].aa-ar[k2,l2].aa)+sqr(ar[i2,j2].bb-ar[k2,l2].bb)<sqr(4*rx)+1)
                                    then ar[i2,j2].addenv(ar[k2,l2]);
                                 //
                    end;
     timer1.Enabled:=true;
     for i2:=0 to nn1
         do ar[i2,nn2].open;
     for j2:=0 to nn2
         do ar[nn1,j2].open;
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
     case m mod 10 of
          0: result:=$007FFF;
          1: result:=clblue;
          2: result:=clgreen;
          3: result:=clred;
          4: result:=clNavy;
          5: result:=clFuchsia;
          6: result:=clteal;
          7: result:=clolive;
          8: result:=clpurple;
          9: result:=clLime-$00003000+$00300000;
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

procedure Mcell1.show;
begin
     if not state
        then
            begin
                 p.Canvas.Brush.Color:=$00C0D0D0;
                 p.Canvas.Font.Color:=clblack;
                 if flag
                    then
                        begin
                             preshow('X');
                             numsel:=numsel-1;
                             form1.label3.caption:=inttostr(numsel);
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
                             preshow(' ');
                             p.Canvas.Brush.Color:=clwhite;
                             numsel:=numsel+1;
                             form1.label3.caption:=inttostr(numsel);
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
                        form1.lose(self);
                   end
               else
                   begin
                        p.Canvas.Brush.Color:=clwhite;
                        if mines=0
                           then preshow(' ')
                           else
                               begin
                                    p.Canvas.Font.Color:=inttocolor(mines);
                                    preshow(dig(mines));
                               end;
                   end;
end;

procedure Mcell1.show1(sw:boolean);
begin
     if not state
        then
            begin
                 if sw
                    then p.Canvas.Brush.Color:=$00C0D0D0
                    else p.Canvas.Brush.Color:=clgray;
                 p.Canvas.Font.Color:=clblack;
                 if flag
                    then
                        begin
                             if not sw
                                then p.Canvas.brush.Color:=clred;
                                preshow('X');
                        end
                    else
                        begin
                             if sw
                                then preshow(' ')
                                else
                                    if momentflag
                                       then
                                           if momentnumber>=0
                                            then
                                                begin
                                                     p.Canvas.Font.Color:=clwhite;
                                                     preshow(dig(momentnumber));
                                                end
                                            else
                                                begin
                                                     p.Canvas.Font.Color:=clred;
                                                     preshow(inttostr(-momentnumber));
                                                end
                                       else
                                           begin
                                                p.Canvas.brush.Color:=clred;
                                                preshow(' ');
                                           end
                        end
            end
        else
            begin
                 if sw
                    then p.Canvas.Brush.Color:=clwhite
                    else p.Canvas.Brush.Color:=$00A0A0FF;
                 if mines=0
                    then preshow(' ')
                    else
                        begin
                             p.Canvas.Font.Color:=inttocolor(mines);
                             preshow(dig(mines));
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
 if game=0
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
if game=0 then
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
                       if ((touch = 0) and (mbleft = button) or (touch = 1) and (mbright = button))
                                           and  (shift=[])
                                           and (ar[i,j].state=false)
                                           and (ar[i,j].flag=false)
                                  then
                                      if  ar[i,j].open
                                          then ar[i,j].klik;
                       if ((touch = 0) and (mbright = button) or (touch = 1) and (mbleft = button))
                                           and (shift=[])
                                           and (ar[i,j].state=false)
                                  then
                                      begin
                                           ar[i,j].flag:=not ar[i,j].flag;
                                           ar[i,j].show;
                                      end;
                  end;
   end;
end;

procedure tform1.Image1Mousemove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); //this is for red light hints, it is very unclear through
var i,j:integer; xx:Morbit;

begin
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
                               if (Shift<>[]) and not ar[i,j].state
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
                               if (Shift<>[]) and (ar[i,j].state)
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
                               if(Shift<>[]) and (ar[i,j].state)
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
     if strtoint(label1.caption)<9999
        then label1.Caption:=inttostr(strtoint(label1.caption)+1);
end;
//

//Pause-Play button
procedure TForm1.Button2Click(Sender: TObject);
begin
     paused:=not paused;
     p.Visible:=not paused;
     if game=0
        then timer1.Enabled:=not paused;
     if paused
        then button2.Caption:='Play'
        else button2.Caption:='Pause'
end;
//

//Endings
procedure Tform1.lose(er:Mcell1);  //er is the cell with the expolded bomb
var i,j:integer;
begin
     timer1.Enabled:=false;
     p.Canvas.Brush.Color:=clred;
     p.Canvas.Font.Color:=clblack;
     er.preshow('*');
     game:=2;
     form1.caption:=form1.caption+': You''ve lost';
     p.Canvas.Brush.Color:=clwhite;
     for i:=0 to nn1 do
         for j:=0 to nn2 do
             if ar[i,j].mine and (ar[i,j]<>er)
                then
                    if ar[i,j].flag
                       then
                           begin
                                p.Canvas.Font.Color:=clblack;
                                ar[i,j].preshow('*');
                           end
                       else
                           begin
                                p.Canvas.Font.Color:=clred;
                                ar[i,j].preshow('*');
                           end;
end;


procedure Tform1.win;
var  rec1:Tpr;
champ:boolean;ix,jx,kx:integer;
ar:array [0..10] of TPr;
begin
     timer1.Enabled:=false;
     assignfile(fpr,{currentdirectory+'\Profiles\'+}curprofilename);
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
                if strtoint(label1.Caption)<ar[jx].time
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
             if ix<11
                then ix:=ix+1;
             for jx:=ix-1 downto kx+1 do
                 ar[jx]:=ar[jx-1];
             ar[kx].Name:=e1.Text;
             ar[kx].Time:=strtoint(label1.Caption);
             rewrite(fpr);
                          write(fpr,rec1);
                          for jx:=0 to ix-1 do
                             write(fpr,ar[jx]);
             closefile(fpr);
             f.Free;
             top111click(form1);
        end;
end;
//

//New Profile form
procedure TForm1.NewProfile1Click(Sender: TObject);
begin
     newprofileresult:=0;
     if timer1.Enabled
        then button2.Click;
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
     e1.left:=100; e2.left:=100; e3.left:=100;
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
     b1.Left:=131; b2.left:=131;
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
        curprofilename:=currentdirectory+'\Profiles\temp.tmp';
        assignfile(fpr,curprofilename);
        rewrite(fpr);
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
         write(fpr,rec);
        closefile(fpr);
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
        then button2.Click; //Click Pause
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
     for ix:=0 to 10 do
         form2.StringGrid1.Cells[0,ix]:='';
     for ix:=0 to 10 do
         form2.StringGrid1.Cells[1,ix]:='';
     if not paused
        then button2.Click; //Click Pause
     assignfile(fpr,{currentdirectory+'\Profiles\'+}curprofilename);
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
//

//Closing the game
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var Tx:Textfile;
begin
     if p<>nil
        then ClearField;
     assignfile(Tx,currentdirectory+'\Profiles\last');
     rewrite(Tx);
                 writeln(Tx,curprofilename);
     closefile(Tx);
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


end.
