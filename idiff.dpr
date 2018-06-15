program idiff;

uses
  Forms,
  main in 'main.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Image Difference Calculator';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
