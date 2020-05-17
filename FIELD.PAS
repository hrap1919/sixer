unit field;

interface
//uses
//  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
//  Dialogs, StdCtrls, Buttons;


const n1=50; n2=30; size=15;

type
 Defrgn=class(TObject)
   procedure r1(i,j:integer; var isin:boolean);
   end;
implementation

procedure defrgn.r1(i,j:integer; var isin:boolean);
begin
isin:= ((i>=1) and (i<=20) and (j>=1) and (j<=20)) or
       ((i>=1) and (i<=50) and (j>=10) and (j<=20));
end;


end.
