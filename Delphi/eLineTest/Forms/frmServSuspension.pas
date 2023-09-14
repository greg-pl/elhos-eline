unit frmServSuspension;

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
  KpDevUnit,
  Wykres3Unit,
  WykresEngUnit;

type
  TServSuspensionForm = class(TBaseKpServForm)
    TopPanel: TPanel;
    BigDigPaintBox: TPaintBox;
    MeasGrid: TStringGrid;
    Panel2: TPanel;
    MsgCntEdit: TLabeledEdit;
    MsgPerSekEdit: TLabeledEdit;
    Panel1: TPanel;
    Splitter2: TSplitter;
    ActivShape: TShape;
    ProcPaintBox: TPaintBox;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    actKalibrWagi: TAction;
    ToolButton6: TToolButton;
    procedure actKalibrP0Update(Sender: TObject);
    procedure actKalibrP0Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WhiteCableBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxClick(Sender: TObject);
    procedure actKalibrP1Execute(Sender: TObject);
    procedure actKalibrWagiExecute(Sender: TObject);
    procedure actRUNExecute(Sender: TObject);
  private const
    CHART_PROB_CNT = 120 * 1000; // 120 sekund = 2 min
  private type

    TChartData = record
      Buffer: array of single;
      BufPtr: integer;
      Chart: TElWykres;
      DtPanel: TAnalogPanel;
      DtSeries: TAnalogSerie;
    end;

    TMeas = record
      mShowTick: cardinal;
      mRecCnt: integer;
      mCfgErrMode: boolean;
      mWagaVal: single;
      mWychylVal: single;
      mProc: single;
    end;
  private
    ChartData: TChartData;
    DataSpeed: TDataSpeedMeas;
    mMeas: TMeas;

    bigDigMode: integer;
    mkalibrValP0: single;
    mkalibrValP1: single;
    mKalibrPointNr: integer;

    procedure OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double; var Exist: boolean);

  protected
    procedure doStartStop(run: boolean); override;
    procedure ReciveMeasData(dt: TBytes); override;
    procedure ReciveMeasDataErrCfg(dt: TBytes); override;
    procedure RecivedServiceObj(obCode: integer; dt: TBytes); override;
  public
  end;

implementation

{$R *.dfm}

uses
  dlgKalibrWagiSelect,
  Main;

procedure TServSuspensionForm.FormCreate(Sender: TObject);
begin
  inherited;
  DataSpeed := TDataSpeedMeas.create;
  mMeas.mRecCnt := 0;
  mMeas.mWagaVal := -1;
  mMeas.mWychylVal := -1;
  mMeas.mProc := -1;

  MeasGrid.Rows[0].CommaText := 'Nazwa Wartoœæ';
  MeasGrid.Cols[0].CommaText := 'Nazwa "Procent" "Wychylenie" "Waga"  "Aktywnoœæ"';

  ChartData.Chart := TElWykres.create(self);
  ChartData.Chart.Parent := self;
  ChartData.Chart.Align := alClient;
  ChartData.Chart.OnGetAnValue := OnGetAnValueProc;
  ChartData.Chart.ProbCnt := CHART_PROB_CNT;
  ChartData.Chart.DtPerProbka := 0.001;
  ChartData.Chart.Engine.ShowPoints := true;

  ChartData.DtPanel := ChartData.Chart.Engine.AddAnalogPanel;
  ChartData.DtPanel.Title := 'Nacisk';
  ChartData.DtPanel.MinR := -15;
  ChartData.DtPanel.MaxR := 40;
  ChartData.DtSeries := ChartData.DtPanel.Series.CreateNew(0);
  ChartData.DtSeries.PenColor := clBlue;

  SetLength(ChartData.Buffer, CHART_PROB_CNT);
  ChartData.BufPtr := 0;

  mkalibrValP0 := 0;
  mkalibrValP1 := 40;
  mKalibrPointNr := 0;

end;

procedure TServSuspensionForm.FormDestroy(Sender: TObject);
begin
  inherited;
  DataSpeed.Free;
end;

procedure TServSuspensionForm.OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double;
  var Exist: boolean);
begin
  Exist := false;
  if NrProb < cardinal(ChartData.BufPtr) then
  begin
    Exist := true;
    Val := ChartData.Buffer[NrProb];
  end;

end;

procedure TServSuspensionForm.ProcPaintBoxPaint(Sender: TObject);
begin
  inherited;
  PaintTxtBar(ProcPaintBox, clGray, clGReen, ['Si³a H.', FormatFloat('000.0', mMeas.mProc)], mMeas.mProc / 100);
end;

procedure TServSuspensionForm.doStartStop(run: boolean);
begin
  inherited;
end;

procedure TServSuspensionForm.ReciveMeasDataErrCfg(dt: TBytes);
var
  spd: double;
  rec: TKSuspensDataRecErrCfg;
  n1, n2: integer;
begin
  inc(mMeas.mRecCnt);
  mMeas.mCfgErrMode := true;
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
    mMeas.mProc := rec.anProc;
    ProcPaintBox.Invalidate;
    BigDigPaintBox.Invalidate;

    if GetTickCount - mMeas.mShowTick > 200 then
    begin
      mMeas.mShowTick := GetTickCount;
      MeasGrid.Cells[1, 1] := Format('%.1f[%%]', [rec.anProc]);
      MeasGrid.Cells[1, 2] := '???';
      MeasGrid.Cells[1, 3] := '???';
      MeasGrid.Cells[1, 4] := '???';

    end;

  end;
end;

procedure TServSuspensionForm.ReciveMeasData(dt: TBytes);
var
  spd: double;
  rec: TKSuspensDataRec;
  n1, n2: integer;
  i: integer;
begin
  inc(mMeas.mRecCnt);
  mMeas.mCfgErrMode := false;
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
    for i := 0 to CHANNEL_DATA_LEN - 1 do
    begin
      if ChartData.BufPtr < CHART_PROB_CNT then
      begin
        ChartData.Buffer[ChartData.BufPtr] := rec.wsp.a * rec.Buffer[i] + rec.wsp.b;
        inc(ChartData.BufPtr);
      end;
    end;

    if rec.getFlagActiv then
      ActivShape.Brush.color := clRed
    else
      ActivShape.Brush.color := clGray;

    mMeas.mWychylVal := rec.wychyl;
    mMeas.mWagaVal := rec.waga;
    mMeas.mProc := rec.proc;
    ProcPaintBox.Invalidate;
    ChartData.Chart.Invalidate;
    BigDigPaintBox.Invalidate;

    if GetTickCount - mMeas.mShowTick > 200 then
    begin
      mMeas.mShowTick := GetTickCount;
      MeasGrid.Cells[1, 1] := Format('%.1f[%%]', [rec.proc]);
      MeasGrid.Cells[1, 2] := Format('%.1f[mm]', [rec.wychyl]);
      MeasGrid.Cells[1, 3] := Format('%.1f[kg]', [rec.waga]);
      MeasGrid.Cells[1, 4] := Format('%u', [byte(rec.getFlagActiv)]);
    end;

  end;
end;

procedure TServSuspensionForm.WhiteCableBtnClick(Sender: TObject);
begin
  inherited;
  KpDev.sendBreakWhiteWire(service, (Sender as TSpeedButton).Down);
end;

procedure TServSuspensionForm.RecivedServiceObj(obCode: integer; dt: TBytes);
begin

end;

procedure TServSuspensionForm.actKalibrWagiExecute(Sender: TObject);
var
  dlg: TKalibrWagiSelectDlg;
begin
  inherited;
  dlg := TKalibrWagiSelectDlg.create(self);
  try
    dlg.nrPunktu := mKalibrPointNr;
    dlg.setCaption(caption);
    if dlg.ShowModal = mrOk then
    begin
      mKalibrPointNr := dlg.nrPunktu;
      KpDev.sendRunKalibr(service, 10 + mKalibrPointNr, dlg.valFiz);
    end;
  finally
    dlg.Free;
  end;

end;

procedure TServSuspensionForm.actRUNExecute(Sender: TObject);
begin
  inherited;
  if actRun.Checked then
  begin
    mMeas.mRecCnt := 0;
    ChartData.BufPtr := 0;
    DataSpeed.Reset;
  end;

end;

procedure TServSuspensionForm.actKalibrP1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('L1', 'mm', 1, mkalibrValP1);
end;

procedure TServSuspensionForm.actKalibrP0Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('L0', 'mm', 0, mkalibrValP0);
end;

procedure TServSuspensionForm.actKalibrP0Update(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := KpDev.IsConnected;
end;

procedure TServSuspensionForm.BigDigPaintBoxClick(Sender: TObject);
begin
  inherited;
  inc(bigDigMode);
  if (bigDigMode < 0) or (bigDigMode >= 4) then
    bigDigMode := 0;
  BigDigPaintBox.Invalidate;
end;

procedure TServSuspensionForm.BigDigPaintBoxPaint(Sender: TObject);
var
  s: Strings;
begin
  inherited;

  if mMeas.mProc > 0 then
  begin
    if not mMeas.mCfgErrMode then
    begin

      case bigDigMode of
        0:
          s := [Format('%.1f[%%]', [mMeas.mProc])];
        1:
          s := [Format('%.1f[kg]', [mMeas.mWagaVal])];
        2:
          s := [Format('%.1f[mm]', [mMeas.mWychylVal])];
        3:
          s := [Format('%.1f[%%]', [mMeas.mProc]), Format('%.1f[kg]', [mMeas.mWagaVal]),
            Format('%.1f[mm]', [mMeas.mWychylVal])];
      end;
    end
    else
    begin
      s := [Format('%.1f[%%]', [mMeas.mProc])];
    end;
  end
  else
    s := ['---'];

  PaintTxtBox(Sender as TPaintBox, clSilver, clBlue, s);
end;

end.
