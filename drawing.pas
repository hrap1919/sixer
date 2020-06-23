unit Drawing;

{$MODE Delphi}

interface

uses
  Classes, Graphics;

procedure DrawHex(canv:TCanvas;rx,ry,rr,a,b:integer);
procedure DrawStar(canv:TCanvas;rd,a,b:integer);
procedure DrawX(canv:TCanvas;rd,a,b:integer);
procedure Draw1(canv:TCanvas;rd,a,b:integer);
procedure Draw2(canv:TCanvas;rd,a,b:integer);
procedure Draw3(canv:TCanvas;rd,a,b:integer);
procedure Draw4(canv:TCanvas;rd,a,b:integer);
procedure Draw5(canv:TCanvas;rd,a,b:integer);
procedure Draw6(canv:TCanvas;rd,a,b:integer);
procedure Draw7(canv:TCanvas;rd,a,b:integer);
procedure Draw8(canv:TCanvas;rd,a,b:integer);
procedure Draw9(canv:TCanvas;rd,a,b:integer);
procedure Draw0(canv:TCanvas;rd,a,b:integer);



implementation

procedure DrawHex(canv:TCanvas;rx,ry,rr,a,b:integer);
begin
     canv.Polygon([
                   Point(a,b+rr),
                   Point(a+rx,b+ry),
                   Point(a+rx,b-ry),
                   Point(a,b-rr),
                   Point(a-rx,b-ry),
                   Point(a-rx,b+ry)
                   ]);
     canv.Polyline([
                    Point(a,b+rr),
                    Point(a+rx,b+ry),
                    Point(a+rx,b-ry),
                    Point(a,b-rr),
                    Point(a-rx,b-ry),
                    Point(a-rx,b+ry),
                    Point(a,b+rr)
                    ]);
end;

procedure DrawStar(canv:TCanvas;rd,a,b:integer);
begin
    with canv do
         begin
              MoveTo(a+9*rd div 10,b+0*rd div 10);
              LineTo(a+9*rd div 10,b+5*rd div 10);
              LineTo(a+10*rd div 10,b+5*rd div 10);
              LineTo(a+12*rd div 10,b+6*rd div 10);
              LineTo(a+14*rd div 10,b+4*rd div 10);
              MoveTo(a+12*rd div 10,b+6*rd div 10);
              LineTo(a+13*rd div 10,b+8*rd div 10);
              LineTo(a+13*rd div 10,b+9*rd div 10);
              LineTo(a+18*rd div 10,b+9*rd div 10);
              MoveTo(a+13*rd div 10,b+9*rd div 10);
              LineTo(a+13*rd div 10,b+10*rd div 10);
              LineTo(a+12*rd div 10,b+12*rd div 10);
              LineTo(a+14*rd div 10,b+14*rd div 10);
              MoveTo(a+12*rd div 10,b+12*rd div 10);
              LineTo(a+10*rd div 10,b+13*rd div 10);
              LineTo(a+9*rd div 10,b+13*rd div 10);
              LineTo(a+9*rd div 10,b+18*rd div 10);
              MoveTo(a+9*rd div 10,b+13*rd div 10);
              LineTo(a+8*rd div 10,b+13*rd div 10);
              LineTo(a+6*rd div 10,b+12*rd div 10);
              LineTo(a+4*rd div 10,b+14*rd div 10);
              MoveTo(a+6*rd div 10,b+12*rd div 10);
              LineTo(a+5*rd div 10,b+10*rd div 10);
              LineTo(a+5*rd div 10,b+9*rd div 10);
              LineTo(a+0*rd div 10,b+9*rd div 10);
              MoveTo(a+5*rd div 10,b+9*rd div 10);
              LineTo(a+5*rd div 10,b+8*rd div 10);
              LineTo(a+6*rd div 10,b+6*rd div 10);
              LineTo(a+4*rd div 10,b+4*rd div 10);
              MoveTo(a+6*rd div 10,b+6*rd div 10);
              LineTo(a+8*rd div 10,b+5*rd div 10);
              LineTo(a+9*rd div 10,b+5*rd div 10);
         end;
end;
procedure DrawX(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+16*rd div 10,b+0*rd div 10);
              LineTo(a+0*rd div 10,b+20*rd div 10);
              MoveTo(a+0*rd div 10,b+0*rd div 10);
              LineTo(a+16*rd div 10,b+20*rd div 10);
          end;

end;

procedure Draw1(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
             // MoveTo(a+0*rd div 10,b+2*rd div 10);
             // LineTo(a+4*rd div 10,b+2*rd div 10);

              MoveTo(a+0*rd div 10,b+2*rd div 10);
              //LineTo(a+0*rd div 10,b+2*rd div 10);
              LineTo(a+4*rd div 10,b+0*rd div 10);

              //LineTo(a+4*rd div 10,b+0*rd div 10);
              LineTo(a+4*rd div 10,b+15*rd div 10);
              LineTo(a+0*rd div 10,b+15*rd div 10);
              LineTo(a+8*rd div 10,b+15*rd div 10);
          end;

end;
procedure Draw2(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+0*rd div 10,b+3*rd div 10);
              LineTo(a+1*rd div 10,b+1*rd div 10);   //1 -2
              LineTo(a+3*rd div 10,b+0*rd div 10);   //2 -1
              LineTo(a+5*rd div 10,b+0*rd div 10);   //2 0
              LineTo(a+7*rd div 10,b+1*rd div 10);   //2 1
              LineTo(a+8*rd div 10,b+3*rd div 10);   //1 2
              LineTo(a+8*rd div 10,b+5*rd div 10);   //0 2
              LineTo(a+7*rd div 10,b+7*rd div 10);   //-1 2
              LineTo(a+0*rd div 10,b+15*rd div 10);
              LineTo(a+8*rd div 10,b+15*rd div 10);
          end;
end;
procedure Draw3(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+0*rd div 10,b+3*rd div 10);
              LineTo(a+1*rd div 10,b+1*rd div 10);   //1 -2
              LineTo(a+3*rd div 10,b+0*rd div 10);   //2 -1
              LineTo(a+5*rd div 10,b+0*rd div 10);   //2 0
              LineTo(a+7*rd div 10,b+1*rd div 10);   //2 1
              LineTo(a+8*rd div 10,b+3*rd div 10);   //1 2
              LineTo(a+8*rd div 10,b+5*rd div 10);   //0 2

              LineTo(a+7*rd div 10,b+6*rd div 10);   //-1 1
              LineTo(a+3*rd div 10,b+7*rd div 10);   //-4 1
              LineTo(a+5*rd div 10,b+7*rd div 10);   //2 0
              LineTo(a+7*rd div 10,b+8*rd div 10);   //2 1
              LineTo(a+8*rd div 10,b+9*rd div 10);   //1 1

              LineTo(a+8*rd div 10,b+12*rd div 10);  //0 3
              LineTo(a+7*rd div 10,b+14*rd div 10);  //-1 2
              LineTo(a+5*rd div 10,b+15*rd div 10);  //-2 1
              LineTo(a+3*rd div 10,b+15*rd div 10);  //-2 0
              LineTo(a+1*rd div 10,b+14*rd div 10);  //-2 -1
              LineTo(a+0*rd div 10,b+12*rd div 10);  //-1 -2
          end;
end;
procedure Draw4(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+7*rd div 10,b+15*rd div 10);
              LineTo(a+7*rd div 10,b+0*rd div 10);
              LineTo(a+0*rd div 10,b+11*rd div 10);
              LineTo(a+10*rd div 10,b+11*rd div 10);
          end;
end;
procedure Draw5(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+8*rd div 10,b+0*rd div 10);
              LineTo(a+0*rd div 10,b+0*rd div 10);
              LineTo(a+0*rd div 10,b+5*rd div 10);
              LineTo(a+4*rd div 10,b+5*rd div 10);
              LineTo(a+6*rd div 10,b+6*rd div 10);
              LineTo(a+7*rd div 10,b+7*rd div 10);
              LineTo(a+8*rd div 10,b+9*rd div 10);
              LineTo(a+8*rd div 10,b+11*rd div 10);
              LineTo(a+7*rd div 10,b+13*rd div 10);
              LineTo(a+6*rd div 10,b+14*rd div 10);
              LineTo(a+4*rd div 10,b+15*rd div 10);
              LineTo(a+3*rd div 10,b+15*rd div 10);
              LineTo(a+1*rd div 10,b+14*rd div 10);
              LineTo(a+0*rd div 10,b+13*rd div 10);
          end;
end;

procedure Draw6(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+6*rd div 10,b+0*rd div 10);
              LineTo(a+5*rd div 10,b+0*rd div 10);
              LineTo(a+3*rd div 10,b+1*rd div 10);
              LineTo(a+2*rd div 10,b+2*rd div 10);
              LineTo(a+1*rd div 10,b+4*rd div 10);
              LineTo(a+0*rd div 10,b+7*rd div 10);
              LineTo(a+0*rd div 10,b+11*rd div 10);
              LineTo(a+1*rd div 10,b+13*rd div 10);
              LineTo(a+2*rd div 10,b+14*rd div 10);
              LineTo(a+4*rd div 10,b+15*rd div 10);
              LineTo(a+5*rd div 10,b+15*rd div 10);
              LineTo(a+7*rd div 10,b+14*rd div 10);
              LineTo(a+8*rd div 10,b+12*rd div 10);
              LineTo(a+8*rd div 10,b+10*rd div 10);
              LineTo(a+7*rd div 10,b+8*rd div 10);
              LineTo(a+5*rd div 10,b+7*rd div 10);
              LineTo(a+4*rd div 10,b+7*rd div 10);   //-1 0
              LineTo(a+1*rd div 10,b+9*rd div 10);   //-3 2
              LineTo(a+0*rd div 10,b+12*rd div 10);
          end;
end;
procedure Draw7(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+0*rd div 10,b+2*rd div 10);
              LineTo(a+0*rd div 10,b+0*rd div 10);
              LineTo(a+8*rd div 10,b+0*rd div 10);
              LineTo(a+4*rd div 10,b+15*rd div 10);
          end;
end;

procedure Draw8(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
               MoveTo(a+1*rd div 10,b+6*rd div 10);
               LineTo(a+0*rd div 10,b+4*rd div 10);    //-1 2
               LineTo(a+0*rd div 10,b+3*rd div 10);    //0 -1
               LineTo(a+1*rd div 10,b+1*rd div 10);   //1 -2
               LineTo(a+3*rd div 10,b+0*rd div 10);   //2 -1
               LineTo(a+5*rd div 10,b+0*rd div 10);   //2 0
               LineTo(a+7*rd div 10,b+1*rd div 10);   //2 1
               LineTo(a+8*rd div 10,b+3*rd div 10);   //1 2
               LineTo(a+8*rd div 10,b+4*rd div 10);   //0 1
               LineTo(a+7*rd div 10,b+6*rd div 10);    //-1 2

               LineTo(a+1*rd div 10,b+9*rd div 10);    //-6 -3

               LineTo(a+0*rd div 10,b+11*rd div 10);   // -1 2
               LineTo(a+0*rd div 10,b+12*rd div 10);    // 0 1
               LineTo(a+1*rd div 10,b+14*rd div 10);     //1 2
               LineTo(a+3*rd div 10,b+15*rd div 10);     // 2 1
               LineTo(a+5*rd div 10,b+15*rd div 10);    // 2 0
               LineTo(a+7*rd div 10,b+14*rd div 10);     // 2 -1
               LineTo(a+8*rd div 10,b+12*rd div 10);     // 1 -2
               LineTo(a+8*rd div 10,b+11*rd div 10);    // 0 -1
               LineTo(a+7*rd div 10,b+9*rd div 10);    //  -1 -2

               LineTo(a+1*rd div 10,b+6*rd div 10); //  -6 -3

          end;
end;


procedure Draw9(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
              MoveTo(a+2*rd div 10,b+15*rd div 10);
              LineTo(a+3*rd div 10,b+15*rd div 10);
              LineTo(a+5*rd div 10,b+14*rd div 10);
              LineTo(a+6*rd div 10,b+13*rd div 10);
              LineTo(a+7*rd div 10,b+11*rd div 10);
              LineTo(a+8*rd div 10,b+8*rd div 10);
              LineTo(a+8*rd div 10,b+3*rd div 10);
              LineTo(a+7*rd div 10,b+1*rd div 10);
              LineTo(a+5*rd div 10,b+0*rd div 10);
              LineTo(a+3*rd div 10,b+0*rd div 10);
              LineTo(a+1*rd div 10,b+1*rd div 10);
              LineTo(a+0*rd div 10,b+3*rd div 10);
              LineTo(a+0*rd div 10,b+5*rd div 10);
              LineTo(a+1*rd div 10,b+7*rd div 10);
              LineTo(a+3*rd div 10,b+8*rd div 10);
              LineTo(a+4*rd div 10,b+8*rd div 10);
              LineTo(a+7*rd div 10,b+6*rd div 10);
              LineTo(a+8*rd div 10,b+3*rd div 10);
          end;
end;

procedure Draw0(canv:TCanvas;rd,a,b:integer);
begin
     with canv do
          begin
               MoveTo(a+3*rd div 10,b+0*rd div 10);
               LineTo(a+5*rd div 10,b+0*rd div 10);
               LineTo(a+7*rd div 10,b+1*rd div 10);
               LineTo(a+8*rd div 10,b+3*rd div 10);
               LineTo(a+8*rd div 10,b+12*rd div 10);
               LineTo(a+7*rd div 10,b+14*rd div 10);
               LineTo(a+5*rd div 10,b+15*rd div 10);
               LineTo(a+3*rd div 10,b+15*rd div 10);
               LineTo(a+1*rd div 10,b+14*rd div 10);
               LineTo(a+0*rd div 10,b+12*rd div 10);
               LineTo(a+0*rd div 10,b+3*rd div 10);
               LineTo(a+1*rd div 10,b+1*rd div 10);
               LineTo(a+3*rd div 10,b+0*rd div 10);
          end;
end;

end.
