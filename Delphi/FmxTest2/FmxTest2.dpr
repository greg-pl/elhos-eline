program FmxTest2;

uses
  FMX.Forms,
  Main in 'Main.pas' {Form4};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
