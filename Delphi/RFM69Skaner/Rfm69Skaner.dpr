program Rfm69Skaner;

uses
  Forms,
  Rfm69Main in 'Rfm69Main.pas' {MainForm},
  InterRsd in 'InterRsd.pas',
  SkanerCmmUnit in 'SkanerCmmUnit.pas',
  Rfm69SkanerCfg in 'Rfm69SkanerCfg.pas' {CfgForm},
  CrcUnit in 'CrcUnit.pas',
  eLineDef in 'eLineDef.pas',
  U_USB in 'U_USB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
