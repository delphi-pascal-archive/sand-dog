unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }

    procedure DoSand;

  end;

var
  Form1: TForm1;
  w,h: integer;
  bitmap: TBitmap;

implementation

{$R *.dfm}
type
  PQuadArray = ^TQuadArray;
  TQuadArray = array [Byte] of longint;

procedure TForm1.DoSand;
var
 x,y:integer;
 a,b,c,d,e:integer;
 bg:integer;
 p:PQuadArray;
begin
 bg:=$FFFFFF;
 p:=bitmap.scanline[h-1];
 // on balaye de bas en haut l'image,
 // sinon, des grains de sable pourai tomber d'un coup du haut en bas...
 for y:=0 to h-2 do
  begin
   for x:=1 to w-2 do
    begin
        // attention, le bitmap est la tête en bas
        // donc y+1 est au dessus de y
        a:=p[x  +w*(y+1)];
        b:=p[x  +w* y];
        c:=p[x-1+w* y];
        d:=p[x-1+w*(y+1)];

        e:=0;
        // e = configuration des 4 points a,b,c,d
        // d a  =>  8 1
        // c b  =>  4 2
        if (a<>bg) and (a<>0) then e:=e+1;
        if (b<>bg) and (b<>0) then e:=e+2;
        if (c<>bg) and (c<>0) then e:=e+4;
        if (d<>bg) and (d<>0) then e:=e+8;
        if (b=0)  then e:=e+200;
        if (c=0)  then e:=e+400;
        case e of
          //==================
          // a tombe vers b
          1,5,401,409:
           begin b:=a; a:=BG; end;
          //==================
          // a tombe en b ou (d tombe en c et c est poussé en b)
          13:
           if random(2)=0 then
            begin b:=a; a:=Bg; end
           else
            begin b:=c; c:=d; d:=BG; end;
          //==================
          // d tombe vers c
          8,10,208,209:
           begin c:=d; d:=BG; end;
          //==================
          // d tombe en c ou (a tombe en b et b est poussé en c)
          11:
           if random(2)=0 then
            begin c:=d; d:=Bg; end
           else
             begin c:=b; b:=a; a:=BG; end;
          //==================
          // a et d tombent en c et b
          9:
           begin b:=a; a:=Bg; c:=d; d:=BG; end;
          //==================
          // a tombe en c ou (a tombe en b et b est poussé en c )
          3:
           if random(2)=0 then
            begin c:=a; a:=Bg; end
           else
            begin c:=b; b:=a; a:=BG; end;
          //==================
          // d tombe en b ou (d tombe en c et c est poussé en b)
          12:
           if random(2)=0 then
            begin b:=d; d:=Bg; end
           else
            begin b:=c; c:=d; d:=BG; end;
        end;
        // d a
        // c b
        p[x  +w*(y+1)]:=a;
        p[x-1+w*(y+1)]:=d;
        p[x  +w*y]:=b;
        p[x-1+w*y]:=c;
    end;
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 bitmap:=tbitmap.Create;
 w:=image1.Width;
 h:=image1.Height;
 bitmap.Assign(image1.picture.Bitmap);
 bitmap.PixelFormat:=pf32bit;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 DoSand;
 image1.canvas.Draw(0,0,bitmap);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
 // inverse l'image, tête en bas
 bitmap.Canvas.CopyRect(rect(0,h,w,0),bitmap.Canvas,rect(0,0,w,h));
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 bitmap.Free;
end;

end.
