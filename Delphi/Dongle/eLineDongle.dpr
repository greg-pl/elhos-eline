program eLineDongle;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  WinUsbDll in 'WinUsbDll.pas',
  WinUsbDev in 'WinUsbDev.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
