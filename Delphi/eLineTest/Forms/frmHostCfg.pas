unit frmHostCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Actions, Vcl.ActnList,

  frmBaseCfg,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CfgBinUtils,
  CmmObjDefinition;

type
  THostCfgForm = class(TBaseCfgForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TypLiniiGroup: TRadioGroup;
    PilotChannelEdit: TLabeledEdit;
    FalownikTypeEdit: TLabeledEdit;
    FreqExitSupportText: TLabeledEdit;
    Freq1Text: TLabeledEdit;
    Freq2Text: TLabeledEdit;
    TabSheet3: TTabSheet;
    NetIpEdit: TLabeledEdit;
    NetMaskaEdit: TLabeledEdit;
    NetBramaEdit: TLabeledEdit;
    TabSheet2: TTabSheet;
    AwariaKeyBox: TCheckBox;
    AwariaRolkiBox: TCheckBox;
    AwariaRolkiTimeEdit: TLabeledEdit;
    AwariaPCBox: TCheckBox;
    AwariaPCTimeEdit: TLabeledEdit;
    TurnOffFalByModbusBox: TCheckBox;
    TurnOffFalByModbusTime: TLabeledEdit;
    PilotTxPowerEdit: TLabeledEdit;
    OwnNameEdit: TLabeledEdit;
    BeepWhenPilotBox: TRadioGroup;
    procedure FormCreate(Sender: TObject);
  private type
    THostCfgCode = ( //
{$INCLUDE .\..\..\PROG\Common\Tags\Host.itm }
      msgHostLast);
    TCodes = array of THostCfgCode;

  private
    function KnvTab(codes: TCodes): TBytes;

  protected
    function getDefaultExt: string; override;
    function getFileFilter: string; override;

  end;

implementation

{$R *.dfm}

uses
  MyUtils,
  NetToolsUnit;

procedure THostCfgForm.FormCreate(Sender: TObject);
begin
  inherited;

  mRSett.AddItem(ckString, KnvTab([cfgA_DEVID]), OwnNameEdit);
  mRSett.AddItem(ckByte, KnvTab([cfgA_HostBase, cfgH_liniaType]), TypLiniiGroup);
  mRSett.AddItem(ckByte, KnvTab([cfgA_HostBase, cfgH_falownikType]), FalownikTypeEdit);
  mRSett.AddItem(ckInt, KnvTab([cfgA_HostBase, cfgH_radioChannel]), PilotChannelEdit);
  mRSett.AddItem(ckInt, KnvTab([cfgA_HostBase, cfgH_radioTxPower]), PilotTxPowerEdit);
  mRSett.AddItem(ckFloat, KnvTab([cfgA_HostBase, cfgH_falowFreqLow]), Freq1Text);
  mRSett.AddItem(ckFloat, KnvTab([cfgA_HostBase, cfgH_falowFreqHigh]), Freq2Text);
  mRSett.AddItem(ckFloat, KnvTab([cfgA_HostBase, cfgH_falowFreqSupport]), FreqExitSupportText);
  mRSett.AddItem(ckByte, KnvTab([cfgA_HostBase, cfgH_pilotBeep]), BeepWhenPilotBox);

  mRSett.AddItem(ckIP, KnvTab([cfgA_TCP, cfgB_tIp]), NetIpEdit);
  mRSett.AddItem(ckIP, KnvTab([cfgA_TCP, cfgB_tMask]), NetMaskaEdit);
  mRSett.AddItem(ckIP, KnvTab([cfgA_TCP, cfgB_tGw]), NetBramaEdit);

  mRSett.AddItem(ckBool, KnvTab([cfgA_Emerg, cfgH_emerPilotOFF]), AwariaKeyBox);
  mRSett.AddItem(ckBool, KnvTab([cfgA_Emerg, cfgH_emerRolerOffAfterBeamUp]), AwariaRolkiBox);
  mRSett.AddItem(ckFloat, KnvTab([cfgA_Emerg, cfgH_delayRolerOffAfterBeamUp]), AwariaRolkiTimeEdit);

  mRSett.AddItem(ckBool, KnvTab([cfgA_Emerg, cfgH_emerRolerOffAfterPCLost]), AwariaPCBox);
  mRSett.AddItem(ckFloat, KnvTab([cfgA_Emerg, cfgH_delayRolerOffAfterPCLost]), AwariaPCTimeEdit);

  mRSett.AddItem(ckBool, KnvTab([cfgA_Emerg, cfgH_emerInverterOFFAfterConnLost]), TurnOffFalByModbusBox);
  mRSett.AddItem(ckFloat, KnvTab([cfgA_Emerg, cfgH_delayInverterOFFAfterConnLost]), TurnOffFalByModbusTime);

end;

function THostCfgForm.KnvTab(codes: TCodes): TBytes;
var
  n, i: integer;
begin
  n := length(codes);
  setlength(Result, n);
  for i := 0 to n - 1 do
    Result[i] := ord(codes[i]);
end;

function THostCfgForm.getDefaultExt: string;
begin
  Result := '.hcfg';
end;

function THostCfgForm.getFileFilter: string;
begin
  Result := 'Konfiguracja hosta eLine|*.hcfg|Wszystkie pliki|*.*';
end;


end.
