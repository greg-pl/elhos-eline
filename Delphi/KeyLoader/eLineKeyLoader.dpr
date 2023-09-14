program eLineKeyLoader;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  InterRsd in 'InterRsd.pas',
  KeyLoaderCmmUnit in 'KeyLoaderCmmUnit.pas',
  CrcUnit in 'CrcUnit.pas',
  KeyLogItemUnit in 'KeyLogItemUnit.pas' {KeyLogItemForm},
  KeyLoaderDef in 'KeyLoaderDef.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
