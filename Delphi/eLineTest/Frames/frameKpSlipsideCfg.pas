unit frameKpSlipsideCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TKpSlipsideCfgFrame = class(TFrame)
    DeActivTimeEdit: TLabeledEdit;
    MaxMeasEdit: TLabeledEdit;
    ZjazdInvertBox: TCheckBox;
    NajazdInvertBox: TCheckBox;
    ZjazdInpNrBox: TComboBox;
    DeadBandEdit: TLabeledEdit;
    GroupBox3: TGroupBox;
    P1ValEdit: TLabeledEdit;
    P1KalibrEdit: TLabeledEdit;
    P0KalibrEdit: TLabeledEdit;
    P0ValEdit: TLabeledEdit;
    NajazdInpNrBox: TComboBox;
    AnInpBox: TComboBox;
    AktivBox: TCheckBox;
    Label7: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    MinMeasEdit: TLabeledEdit;
    MaxFlipEdit: TLabeledEdit;
    MaxStartShiftEdit: TLabeledEdit;
    TypPlytyBox: TComboBox;
    Label1: TLabel;
    MaxFlipTimeEdit: TLabeledEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
