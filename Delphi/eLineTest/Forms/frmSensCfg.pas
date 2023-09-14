unit frmSensCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions,
  Vcl.ActnList, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,

  frmBaseCfg,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CfgBinUtils,
  CmmObjDefinition, frameKalibr;

type
  TSensCfgForm = class(TBaseCfgForm)
    OwnNameEdit: TLabeledEdit;
    SensorTypeBox: TComboBox;
    Label1: TLabel;
    KalibrInpFrame: TKalibrFrame;
    KalibrV12Frame: TKalibrFrame;
    KalibrVBatFrame: TKalibrFrame;
    KalibrI12Frame: TKalibrFrame;
    procedure FormCreate(Sender: TObject);
  private type
    TSensCfgCode = ( //
{$INCLUDE .\..\..\ESP32\eLineRmt\main\SensorDev.itm }
      msgHostLast);
    TCodes = array of TSensCfgCode;

  private
    function KnvTab(codes: TCodes): TBytes;

  protected
    function getDefaultExt: string; override;
    function getFileFilter: string; override;

  end;

implementation

{$R *.dfm}

uses
  Main;

procedure TSensCfgForm.FormCreate(Sender: TObject);
// MeasValEdit - wartoœæ zmierzona wyra¿ona w procentach
// FizValEdit - wartoœæ wprowadzona w wartoœciach fizycznych
  procedure addKalibrPoint(codes: TCodes; FizValEdit, MeasValEdit: TLabeledEdit);
  var
    n: Integer;
  begin
    n := length(codes);
    setlength(codes, n + 1);
    codes[n] := cfgX_xValFiz;
    mRSett.AddItem(ckFloat, KnvTab(codes), FizValEdit);
    codes[n] := cfgX_xValMeas;
    mRSett.AddItem(ckFloat, KnvTab(codes), MeasValEdit);
  end;

// PxMeasValEdit - wartoœæ zmierzona wyra¿ona w procentach
// PxFizValEdit - wartoœæ wprowadzona w wartoœciach fizycznych
  procedure KalibrDtDbl(codes: TCodes; frame: TKalibrFrame);
  var
    n: Integer;
  begin
    n := length(codes);
    setlength(codes, n + 1);
    codes[n] := cfgX_yP0;
    addKalibrPoint(codes, frame.P0FizValEdit, frame.P0MeasValEdit);
    codes[n] := cfgX_yP1;
    addKalibrPoint(codes, frame.P1FizValEdit, frame.P1MeasValEdit);
  end;

begin
  inherited;
  mRSett.AddItem(ckString, KnvTab([cfgA_DEVID]), OwnNameEdit);

  mRSett.AddItem(ckByte, KnvTab([cfgA_DEVTYPE]), SensorTypeBox);
  SensorTypeBox.Enabled := Mainform.ProducerMode;

  KalibrDtDbl([cfgA_pKalibrInp], KalibrInpFrame);
  KalibrDtDbl([cfgA_pKalibrVBat], KalibrVBatFrame);
  KalibrDtDbl([cfgA_pKalibrV12], KalibrV12Frame);
  KalibrDtDbl([cfgA_pKalibrI12], KalibrI12Frame);



end;

function TSensCfgForm.KnvTab(codes: TCodes): TBytes;
var
  n, i: Integer;
begin
  n := length(codes);
  setlength(Result, n);
  for i := 0 to n - 1 do
    Result[i] := ord(codes[i]);
end;

function TSensCfgForm.getDefaultExt: string;
begin
  Result := '.scfg';
end;

function TSensCfgForm.getFileFilter: string;
begin
  Result := 'Konfiguracja sensora eLine|*.scfg|Wszystkie pliki|*.*';
end;

end.
