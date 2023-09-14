unit frmSensorTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, System.Actions, Vcl.ActnList, System.ImageList,
  Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Buttons,

  frmBaseKpService,

  MyUtils,
  CmmObjDefinition,
  BaseDevCmmUnit,
  eLineDef,
  SensDevUnit,
  Wykres3Unit,
  WykresEngUnit, frmBaseELineUnit;

type
  TSensorTestForm = class(TBaseELineForm)
    MeasGrid: TStringGrid;
    MsgCntEdit: TLabeledEdit;
    MsgPerSekEdit: TLabeledEdit;

    TopPanel: TPanel;
    BigDigPaintBox: TPaintBox;
    Panel1: TPanel;
    ActivShape: TShape;
    ProcPaintBox: TPaintBox;
    actKalibrInpP0: TAction;
    actKalibrInpP1: TAction;

    actKalibrVBatP0: TAction;
    actKalibrVBatP1: TAction;
    actKalibrV12P0: TAction;
    actKalibrV12P1: TAction;
    actKalibrI12P0: TAction;
    actKalibrI12P1: TAction;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton6: TToolButton;
    Splitter2: TSplitter;
    actRUN: TAction;
    actShowKalibr: TAction;
    ToolButton2: TToolButton;
    RunBtn: TToolButton;
    ToolButton17: TToolButton;
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    ActionList1: TActionList;
    Sw12VBtn: TSpeedButton;
    SwOutBtn: TSpeedButton;
    MeasTimer: TTimer;
    procedure actKalibrInpP0Update(Sender: TObject);
    procedure actKalibrInpP0Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Sw12VBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxClick(Sender: TObject);
    procedure actKalibrInpP1Execute(Sender: TObject);
    procedure actRUNExecute(Sender: TObject);
    procedure actKalibrVBatP0Execute(Sender: TObject);
    procedure actKalibrVBatP1Execute(Sender: TObject);
    procedure actKalibrV12P0Execute(Sender: TObject);
    procedure actKalibrV12P1Execute(Sender: TObject);
    procedure actKalibrI12P0Execute(Sender: TObject);
    procedure actKalibrI12P1Execute(Sender: TObject);
    procedure actShowKalibrExecute(Sender: TObject);
    procedure SwOutBtnClick(Sender: TObject);
    procedure MeasTimerTimer(Sender: TObject);
  private const
    CHART_PROB_CNT = 120 * 1000; // 120 sekund = 2 min
  private type
    TChartDtItem = record
      inp: single;
      time: cardinal;
    end;

    TChartData = record
      Buffer: array of TChartDtItem;
      BufPtr: integer;
      Chart: TElWykres;
      DtPanel: array [0 .. 1] of TAnalogPanel;
      DtSeries: array [0 .. 1] of TAnalogSerie;
      LastTm: cardinal;
    end;

    TMeas = record
      mShowTick: cardinal;
      mRecCnt: integer;

      tabProc: array [TSensorCh] of single;
      tabFiz: array [TSensorCh] of single;
      LastRecTime: cardinal;
    end;
  private
    ChartData: TChartData;
    DataSpeed: TDataSpeedMeas;
    mMeas: TMeas;

    bigDigMode: integer;
    mkalibrInpP0: single;
    mkalibrInpP1: single;

    mkalibrVBatP0: single;
    mkalibrVBatP1: single;
    mkalibrV12P0: single;
    mkalibrV12P1: single;
    mkalibrI12P0: single;
    mkalibrI12P1: single;

    mKalibrPointNr: integer;
    function SensorDev: TSensDev;
    procedure StartKalibracji(PkName, UnitName: string; PkNr: integer; var KalibVal: single);

    procedure OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double; var Exist: boolean);
    procedure ReciveMeasData(dt: TBytes);

  protected
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure BringUp; override;
    procedure RecivedObj(obj: TKobj); override;
  end;

implementation

{$R *.dfm}

uses
  Main;

procedure TSensorTestForm.FormCreate(Sender: TObject);
begin
  inherited;
  DataSpeed := TDataSpeedMeas.create;
  mMeas.mRecCnt := 0;
  mMeas.tabProc[schINP] := -1;

  MeasGrid.Rows[0].CommaText := 'Nazwa Procent Wartoœæ';
  MeasGrid.Cols[0].CommaText := 'Nazwa "Input" "VBat" "V12"  "I12"';

  ChartData.Chart := TElWykres.create(self);
  ChartData.Chart.Parent := self;
  ChartData.Chart.Align := alClient;
  ChartData.Chart.OnGetAnValue := OnGetAnValueProc;
  ChartData.Chart.ProbCnt := CHART_PROB_CNT;
  ChartData.Chart.DtPerProbka := 0.02; // 20[ms]
  ChartData.Chart.Engine.ShowPoints := true;

  ChartData.DtPanel[0] := ChartData.Chart.Engine.AddAnalogPanel;
  ChartData.DtPanel[0].Title := 'Si³a';
  ChartData.DtPanel[0].MinR := -15;
  ChartData.DtPanel[0].MaxR := 200;
  ChartData.DtSeries[0] := ChartData.DtPanel[0].Series.CreateNew(0);
  ChartData.DtSeries[0].PenColor := clBlue;

  ChartData.DtPanel[1] := ChartData.Chart.Engine.AddAnalogPanel;
  ChartData.DtPanel[1].Title := 'Czas';
  ChartData.DtPanel[1].MinR := 0;
  ChartData.DtPanel[1].MaxR := 1000;
  ChartData.DtSeries[1] := ChartData.DtPanel[1].Series.CreateNew(1);
  ChartData.DtSeries[1].PenColor := clBlue;

  SetLength(ChartData.Buffer, CHART_PROB_CNT);
  ChartData.BufPtr := 0;

  mkalibrInpP0 := 0;
  mkalibrInpP1 := 40;
  mkalibrVBatP0 := 0;
  mkalibrVBatP1 := 4;
  mkalibrV12P0 := 0;
  mkalibrV12P1 := 12;
  mkalibrI12P0 := 0;
  mkalibrI12P1 := 0.5;

  mKalibrPointNr := 0;

end;

procedure TSensorTestForm.FormDestroy(Sender: TObject);
begin
  inherited;
  DataSpeed.Free;
end;

procedure TSensorTestForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := 'Sensor Pomiar :' + SensorDev.getCpxName;
end;

procedure TSensorTestForm.BringUp;
begin
  inherited;
end;

procedure TSensorTestForm.RecivedObj(obj: TKobj);
begin
  inherited;
  if obj.srcDev = dsdDEV_COMMON then
  begin

  end
  else if obj.srcDev = dsdSENSOR then
  begin
    case obj.obCode of
      ord(msgSensorMeasData):
        ReciveMeasData(obj.data);

    end;

  end;
end;

procedure TSensorTestForm.OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double;
  var Exist: boolean);
begin
  Exist := false;
  if NrProb < cardinal(ChartData.BufPtr) then
  begin
    Exist := true;
    case DtNr of
      0:
        Val := ChartData.Buffer[NrProb].inp;
      1:
        Val := ChartData.Buffer[NrProb].time;
    else
      Exist := false;
    end;

  end;

end;

procedure TSensorTestForm.ProcPaintBoxPaint(Sender: TObject);
var
  v: single;
begin
  inherited;
  v := mMeas.tabProc[schINP];
  PaintTxtBar(ProcPaintBox, clGray, clGReen, ['Inp.', FormatFloat('000.0', v)], v / 100);
end;

procedure TSensorTestForm.ReciveMeasData(dt: TBytes);
var
  spd: double;
  rec: TSensorMeasData;
  n1, n2: integer;
  i: integer;
  ch: TSensorCh;

begin
  inc(mMeas.mRecCnt);
  DataSpeed.AddItem;
  MsgCntEdit.Text := IntToStr(mMeas.mRecCnt);
  if DataSpeed.getSpeed(spd) then
    MsgPerSekEdit.Text := Format('%.2f', [spd])
  else
    MsgPerSekEdit.Text := '';
  n1 := length(dt);
  n2 := sizeof(rec);
  if n1 = n2 then
  begin
    move(dt[0], rec, n1);
    for i := 0 to SENS_MEAS_EXP_CNT - 1 do
    begin
      if ChartData.BufPtr < CHART_PROB_CNT then
      begin
        ChartData.Buffer[ChartData.BufPtr].inp := rec.inp[i];
        ChartData.Buffer[ChartData.BufPtr].time := rec.time - mMeas.LastRecTime;
        inc(ChartData.BufPtr);
      end;
    end;
    for ch := Low(TSensorCh) to High(TSensorCh) do
    begin
      mMeas.tabProc[ch] := rec.tabProc[ord(ch)];
      mMeas.tabFiz[ch] := rec.tabFiz[ord(ch)];
    end;
    mMeas.LastRecTime := rec.time;

    ProcPaintBox.Invalidate;
    ChartData.Chart.Invalidate;
    BigDigPaintBox.Invalidate;

    if GetTickCount - mMeas.mShowTick > 200 then
    begin
      mMeas.mShowTick := GetTickCount;
      MeasGrid.Cells[1, 1] := Format('%.1f[%%]', [mMeas.tabProc[schINP]]);
      MeasGrid.Cells[1, 2] := Format('%.1f[%%]', [mMeas.tabProc[schVBAT]]);
      MeasGrid.Cells[1, 3] := Format('%.1f[%%]', [mMeas.tabProc[schV12]]);
      MeasGrid.Cells[1, 4] := Format('%.1f[%%]', [mMeas.tabProc[schI12]]);

      MeasGrid.Cells[2, 1] := Format('%.1f[N]', [mMeas.tabFiz[schINP]]);
      MeasGrid.Cells[2, 2] := Format('%.3f[V]', [mMeas.tabFiz[schINP]]);
      MeasGrid.Cells[2, 3] := Format('%.3f[V]', [mMeas.tabFiz[schV12]]);
      MeasGrid.Cells[2, 4] := Format('%.3f[A]', [mMeas.tabFiz[schI12]]);
    end;

  end;
end;

procedure TSensorTestForm.Sw12VBtnClick(Sender: TObject);
begin
  inherited;
  SensorDev.sendOnOff12V((Sender as TSpeedButton).Down);
end;

procedure TSensorTestForm.SwOutBtnClick(Sender: TObject);
begin
  inherited;
  SensorDev.sendOnOffOut((Sender as TSpeedButton).Down);
end;

procedure TSensorTestForm.MeasTimerTimer(Sender: TObject);
begin
  inherited;
  SensorDev.sendRunMeasure(true, 0);
end;

procedure TSensorTestForm.actRUNExecute(Sender: TObject);
begin
  inherited;
  actRUN.Checked := RunBtn.Down;
  if actRUN.Checked then
  begin
    mMeas.mRecCnt := 0;
    ChartData.BufPtr := 0;
    DataSpeed.Reset;
  end;
  SensorDev.sendRunMeasure(actRUN.Checked, 0);
  MeasTimer.Enabled := actRUN.Checked;
end;

procedure TSensorTestForm.actShowKalibrExecute(Sender: TObject);
begin
  inherited;
  PostMessage(Application.MainForm.Handle, wm_showKalibr, integer(SensorDev), 0);

end;

function TSensorTestForm.SensorDev: TSensDev;
begin
  Result := mELineDev as TSensDev;
end;

procedure TSensorTestForm.StartKalibracji(PkName, UnitName: string; PkNr: integer; var KalibVal: single);
var
  Prompt: string;
  Devname: string;
  s: string;
begin
  Devname := Caption;
  Prompt := Format('Kalibracja punktu %s. Podaj wartoœæ [%s]', [PkName, UnitName]);
  s := Format('%.3f', [KalibVal]);
  if InputQuery(Devname, Prompt, s) then
  begin
    KalibVal := StrToFloat(s);
    SensorDev.sendRunKalibr(PkNr, KalibVal);
  end;
end;

procedure TSensorTestForm.actKalibrInpP0Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('Inp-P0', 'mm', 0, mkalibrInpP0);
end;

procedure TSensorTestForm.actKalibrInpP1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('Inp-P1', 'mm', 1, mkalibrInpP1);
end;

procedure TSensorTestForm.actKalibrVBatP0Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('VBat-P0', 'V', 2, mkalibrVBatP0);

end;

procedure TSensorTestForm.actKalibrVBatP1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('VBat-P1', 'V', 3, mkalibrVBatP1);
end;

procedure TSensorTestForm.actKalibrV12P0Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('V12-P0', 'V', 4, mkalibrV12P0);

end;

procedure TSensorTestForm.actKalibrV12P1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('V12-P1', 'V', 5, mkalibrV12P1);

end;

procedure TSensorTestForm.actKalibrI12P0Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('I12-P0', 'A', 6, mkalibrI12P0);

end;

procedure TSensorTestForm.actKalibrI12P1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('I12-P1', 'A', 7, mkalibrI12P1);
end;

procedure TSensorTestForm.actKalibrInpP0Update(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := SensorDev.IsConnected;
end;

procedure TSensorTestForm.BigDigPaintBoxClick(Sender: TObject);
begin
  inherited;
  inc(bigDigMode);
  if (bigDigMode < 0) or (bigDigMode >= 4) then
    bigDigMode := 0;
  BigDigPaintBox.Invalidate;
end;

procedure TSensorTestForm.BigDigPaintBoxPaint(Sender: TObject);
var
  s: Strings;

begin
  inherited;

  if mMeas.tabProc[schINP] > 0 then
  begin

    case bigDigMode of
      0:
        s := [Format('%.1f[%%]', [mMeas.tabProc[schINP]])];
      1:
        s := [Format('%.1f[kg]', [mMeas.tabFiz[schINP]])];
      2:
        s := [Format('%.1f[%%]', [mMeas.tabProc[schINP]]), Format('%.1f[N]', [mMeas.tabFiz[schINP]])];

    end;
  end
  else
    s := ['---'];

  PaintTxtBox(Sender as TPaintBox, clSilver, clBlue, s);
end;

end.
