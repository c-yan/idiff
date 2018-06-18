unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
  Winapi.ShellApi, Vcl.Clipbrd, Vcl.Imaging.GIFImg, Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage;

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
    { Public 宣言 }
  end;

  TByteTriple = packed array[0..2] of Byte;
  TByteTripleArray = array[0..0] of TByteTriple;
  PByteTripleArray = ^TByteTripleArray;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  if ParamCount = 2 then
  begin
    FileName1Edit.Text := ParamStr(1);
    FileName2Edit.Text := ParamStr(2);
    ExecButtonClick(nil);
  end;
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
  function LoadImage(FileName: string): TBitmap;
  var
    WICImage: TWICImage;
  begin
    WICImage := TWICImage.Create;
    try
      try
        WICImage.LoadFromFile(FileName);
      except
        Result := nil;
        Exit;
      end;
      Result := TBitmap.Create;
      Result.Assign(WICImage);
    finally
      FreeAndNil(WICImage);
    end;
  end;
var
  Bmp1, Bmp2: TBitmap;
  I, X, Y, Z, M, N: Integer;
  P1, P2: PByteTripleArray;
begin
  Bmp1 := LoadImage(FileName1Edit.Text);
  Bmp2 := LoadImage(FileName2Edit.Text);
  try
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

    StatusBar.SimpleText := Format('Average: %.4f / Max: %d', [Z / (Bmp1.Width * Bmp1.Height) / 3, M]);
  finally
    FreeAndNil(Bmp2);
    FreeAndNil(Bmp1);
  end;
end;

procedure TMainForm.CopyButtonClick(Sender: TObject);
begin
  Clipboard.AsText := StatusBar.SimpleText;
end;

end.
