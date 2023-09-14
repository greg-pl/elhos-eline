unit frameKalibr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TKalibrFrame = class(TFrame)
    GroupBox5: TGroupBox;
    P0MeasValEdit: TLabeledEdit;
    P0FizValEdit: TLabeledEdit;
    P1MeasValEdit: TLabeledEdit;
    P1FizValEdit: TLabeledEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
