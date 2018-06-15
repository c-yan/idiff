unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ShellApi;

type
  TMainForm = class(TForm)
    FileName1Edit: TEdit;
    FileName2Edit: TEdit;
    ExecButton: TButton;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure ExecButtonClick(Sender: TObject);
  private
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    { Public êÈåæ }
  end;

  TRGBColor = record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
  PRGBColor = ^TRGbColor;
  TRGBColorArray = Array[0..1600000] of TRGBColor;
  PRGBColorArray = ^TRGBColorArray;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
end;

procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
var
  FileName: TFileName;
begin
  if DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0) = 2 then
  begin
    SetLength(FileName, MAX_PATH + 1);
    DragQueryFile(Msg.Drop, 0, PChar(FileName), MAX_PATH);
    SetLength(FileName, StrLen(PChar(FileName)));
    FileName1Edit.Text := FileName;

    SetLength(FileName, MAX_PATH + 1);
    DragQueryFile(Msg.Drop, 1, PChar(FileName), MAX_PATH);
    SetLength(FileName, StrLen(PChar(FileName)));
    FileName2Edit.Text := FileName;
  end;

  DragFinish(Msg.Drop);
end;

procedure TMainForm.ExecButtonClick(Sender: TObject);
var
  Bmp1, Bmp2: TBitmap;
  X, Y, Z: Integer;
  Diff: Extended;
  P1, P2: PRGBColorArray;
begin
  Bmp1 := TBitmap.Create;
  Bmp2 := TBitmap.Create;

  Bmp1.LoadFromFile(FileName1Edit.Text);
  Bmp2.LoadFromFile(FileName2Edit.Text);

  Bmp1.PixelFormat := pf24bit;
  Bmp2.PixelFormat := pf24bit;

  if (Bmp1.Width <> Bmp2.Width) or (Bmp1.Height <> Bmp2.Height) then
  begin
    StatusBar.SimpleText := 'Size mismatch';
    Exit;
  end;

  Diff := 0;
  for Y := 0 to Bmp1.Height - 1 do
  begin
    P1 := Bmp1.ScanLine[Y];
    P2 := Bmp2.ScanLine[Y];
    for X := 0 to Bmp1.Width - 1 do
    begin
      Z := 0;
      Inc(Z, (P1[X].R - P2[X].R) * (P1[X].R - P2[X].R));
      Inc(Z, (P1[X].G - P2[X].G) * (P1[X].G - P2[X].G));
      Inc(Z, (P1[X].B - P2[X].B) * (P1[X].B - P2[X].B));
      Diff := Diff + Sqrt(Z);
    end;
  end;
  StatusBar.SimpleText := 'Result: ' + FloatToStr(Diff / (Bmp1.Width * Bmp1.Height));

  Bmp1.Free;
  Bmp2.Free;
end;

end.
