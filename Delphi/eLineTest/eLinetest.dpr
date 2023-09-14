program eLinetest;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  ConfigUdpUnit in 'Tools\ConfigUdpUnit.pas',
  DevDefinitionUnit in 'Tools\DevDefinitionUnit.pas',
  BaseDevCmmUnit in 'Tools\BaseDevCmmUnit.pas',
  CmmObjDefinition in 'Definition\CmmObjDefinition.pas',
  MyUtils in 'Tools\MyUtils.pas',
  Base64Tools in 'Tools\Base64Tools.pas',
  eLineDef in 'Definition\eLineDef.pas',
  NetToolsUnit in 'Tools\NetToolsUnit.pas',
  UdpSocketUnit in 'Tools\UdpSocketUnit.pas',
  frmBaseMdiUnit in 'Forms\frmBaseMdiUnit.pas' {BaseMdiForm},
  frmBaseELineUnit in 'Forms\frmBaseELineUnit.pas' {BaseELineForm},
  frmDevInfo in 'Forms\frmDevInfo.pas' {DevInfoForm},
  frmCfgHistory in 'Forms\frmCfgHistory.pas' {CfgHistoryForm},
  frmPing in 'Forms\frmPing.pas' {PingForm},
  HostDevUnit in 'Tools\HostDevUnit.pas',
  KpDevUnit in 'Tools\KpDevUnit.pas',
  MyRegistryUnit in 'Tools\MyRegistryUnit.pas',
  frmKeyLog in 'Forms\frmKeyLog.pas' {KeyLogform},
  frmSerialNum in 'Forms\frmSerialNum.pas' {SerialNumForm},
  frmBaseCfg in 'Forms\frmBaseCfg.pas' {BaseCfgForm},
  CfgBinUtils in 'Tools\CfgBinUtils.pas',
  frmHostTestHdw in 'Forms\frmHostTestHdw.pas' {HostTestHdwForm},
  frmHostTestPilot in 'Forms\frmHostTestPilot.pas' {HostTestPilotForm},
  frmHostFalowniki in 'Forms\frmHostFalowniki.pas' {HostFalownikiForm},
  frmKPCfg in 'Forms\frmKPCfg.pas' {KPCfgForm},
  frmHostCfg in 'Forms\frmHostCfg.pas' {HostCfgForm},
  eLineTestDef in 'Definition\eLineTestDef.pas',
  dlgTypLiniiSelect in 'Dialogs\dlgTypLiniiSelect.pas' {TypLiniselectDlg},
  frmBaseKpService in 'Forms\frmBaseKpService.pas' {BaseKpServForm},
  frmServBreaks in 'Forms\frmServBreaks.pas' {ServBreakForm},
  frmServSuspension in 'Forms\frmServSuspension.pas' {ServSuspensionForm},
  frmServSlipSide in 'Forms\frmServSlipSide.pas' {ServSlipSideForm},
  frmServWeight in 'Forms\frmServWeight.pas' {ServWeightForm},
  frmKpTest in 'Forms\frmKpTest.pas' {KpTestForm},
  Wykres3Unit in 'Wykres3\Wykres3Unit.pas',
  WykresEngUnit in 'Wykres3\WykresEngUnit.pas',
  frameHostFalownik in 'Frames\frameHostFalownik.pas' {HostFalownikFrame: TFrame},
  frameKpBreakCfg in 'Frames\frameKpBreakCfg.pas' {KpBreaksCfgFrame: TFrame},
  frameKpSlipsideCfg in 'Frames\frameKpSlipsideCfg.pas' {KpSlipsideCfgFrame: TFrame},
  frameKpStatusBar in 'Frames\frameKpStatusBar.pas' {KpStatusFrame: TFrame},
  frameKpSuspensCfg in 'Frames\frameKpSuspensCfg.pas' {KpSuspensCfgFrame: TFrame},
  frameKpWeightCfg in 'Frames\frameKpWeightCfg.pas' {KpWeightCfgFrame: TFrame},
  dlgKalibrWagiSelect in 'Dialogs\dlgKalibrWagiSelect.pas' {KalibrWagiSelectDlg},
  dlgAnBinUsage in 'Dialogs\dlgAnBinUsage.pas' {AnBinUsageDlg},
  frmUpgrade in 'Forms\frmUpgrade.pas' {UpgradeForm},
  frmSensCfg in 'Forms\frmSensCfg.pas' {SensCfgForm},
  SensDevUnit in 'Tools\SensDevUnit.pas',
  frameKalibr in 'Frames\frameKalibr.pas' {KalibrFrame: TFrame},
  frmSensorTest in 'Forms\frmSensorTest.pas' {SensorTestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
