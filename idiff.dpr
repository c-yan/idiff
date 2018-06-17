program idiff;

uses
  Vcl.Forms,
  main in 'main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Image Difference Calculator';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
