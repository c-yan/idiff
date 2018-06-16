unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ShellApi, Clipbrd;

type
  TMainForm = class(TForm)
    FileName1Edit: TEdit;
    FileName2Edit: TEdit;
    ExecButton: TButton;
    StatusBar: TStatusBar;
    CopyButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ExecButtonClick(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
  private
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    { Public êÈåæ }
  end;

  TByteTriple = packed array[0..2] of Byte;
  TByteTripleArray = array[0..400000] of TByteTriple;
  PByteTripleArray = ^TByteTripleArray;

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
  FileName: string;
begin
  if DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0) = 2 then
  begin
    SetLength(FileName, MAX_PATH);
    DragQueryFile(Msg.Drop, 0, PChar(FileName), MAX_PATH);
    SetLength(FileName, StrLen(PChar(FileName)));
    FileName1Edit.Text := FileName;

    SetLength(FileName, MAX_PATH);
    DragQueryFile(Msg.Drop, 1, PChar(FileName), MAX_PATH);
    SetLength(FileName, StrLen(PChar(FileName)));
    FileName2Edit.Text := FileName;
  end;

  DragFinish(Msg.Drop);
end;

procedure TMainForm.ExecButtonClick(Sender: TObject);
var
  Bmp1, Bmp2: TBitmap;
  I, X, Y, Z, M, N: Integer;
  P1, P2: PByteTripleArray;
begin
  Bmp1 := TBitmap.Create;
  Bmp2 := TBitmap.Create;

  Bmp1.LoadFromFile(FileName1Edit.Text);
  Bmp2.LoadFromFile(FileName2Edit.Text);

  if (Bmp1.Width <> Bmp2.Width) or (Bmp1.Height <> Bmp2.Height) then
  begin
    StatusBar.SimpleText := 'Size mismatch';
    Exit;
  end;

  Bmp1.PixelFormat := pf24bit;
  Bmp2.PixelFormat := pf24bit;

  Z := 0;
  M := 0;
  for Y := 0 to Bmp1.Height - 1 do
  begin
    P1 := Bmp1.ScanLine[Y];
    P2 := Bmp2.ScanLine[Y];
    for X := 0 to Bmp1.Width - 1 do
    begin
      for I := 0 to 2 do
      begin
        N := Abs(P1[X][I] - P2[X][I]);
        Inc(Z, N);
        if (N > M) then M := N;
      end;
    end;
  end;
  StatusBar.SimpleText := Format('ïΩãœ: %.4f / ç≈ëÂ: %d', [Z / (Bmp1.Width * Bmp1.Height) / 3, M]);

  Bmp1.Free;
  Bmp2.Free;
end;

procedure TMainForm.CopyButtonClick(Sender: TObject);
begin
  Clipboard.AsText := StatusBar.SimpleText;
end;

end.
