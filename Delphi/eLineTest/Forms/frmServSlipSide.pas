unit frmServSlipSide;

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
  TServSlipSideForm = class(TBaseKpServForm)
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
    actStartMeas: TAction;
    ToolButton7: TToolButton;
    ResultPanel: TPanel;
    ResultSwingEdit: TLabeledEdit;
    ResultTimeEdit: TLabeledEdit;
    ResultStatusEdit: TLabeledEdit;
    ResultTimer: TTimer;
    lostCntEdit: TLabeledEdit;
    ToolButton6: TToolButton;
    procedure actKalibrP0Update(Sender: TObject);
    procedure actKalibrP0Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProcPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxClick(Sender: TObject);
    procedure actKalibrP1Execute(Sender: TObject);
    procedure actKalibrWagiExecute(Sender: TObject);
    procedure actRUNExecute(Sender: TObject);
    procedure actStartMeasExecute(Sender: TObject);
    procedure ResultTimerTimer(Sender: TObject);
  private const
    CHART_PROB_CNT = 120 * 1000; // 120 sekund = 2 min
  private type
    TSlipSideData = record
      Wychyl: single;
      Aktiv: integer;
    end;

    TChartData = record
      Buffer: array of TSlipSideData;
      BufPtr: integer;
      Chart: TElWykres;
      DtPanel: array [0 .. 1] of TAnalogPanel;
      DtSeries: array [0 .. 1] of TAnalogSerie;
    end;

    TMeas = record
      showTick: cardinal;
      recCnt: integer;
      loastCnt: integer;

      cfgErrMode: boolean;
      bufferNr: integer;
      proc: single;
      wychylVal: single;
      zeroShift: single;
      startShift: single;
      devActiv: boolean;
      typPlyty: byte;
      typPlytyStr: string;
      najazdSensActiv: boolean;
      zjazdSensActiv: boolean;
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
    function getStartMode: byte; override;

  public
  end;

implementation

{$R *.dfm}

uses
  dlgKalibrWagiSelect,
  Main;

procedure TServSlipSideForm.FormCreate(Sender: TObject);
begin
  inherited;
  DataSpeed := TDataSpeedMeas.create;
  mMeas.recCnt := 0;
  mMeas.loastCnt := 0;
  mMeas.wychylVal := 0;
  mMeas.proc := -1;

  MeasGrid.Rows[0].CommaText := 'Nazwa Wartoœæ';
  MeasGrid.Cols[0].CommaText :=
    'Nazwa "Procent" "Wychylenie" "ZeroShift" "Aktywnoœæ" "Typ p³yty" "Cz.najazdu stan" "Cz.zjazdu stan"';

  ChartData.Chart := TElWykres.create(self);
  ChartData.Chart.Parent := self;
  ChartData.Chart.Align := alClient;
  ChartData.Chart.OnGetAnValue := OnGetAnValueProc;
  ChartData.Chart.ProbCnt := CHART_PROB_CNT;
  ChartData.Chart.DtPerProbka := 0.001;
  ChartData.Chart.Engine.ShowPoints := true;

  ChartData.DtPanel[0] := ChartData.Chart.Engine.AddAnalogPanel;
  ChartData.DtPanel[0].Title := 'Wychylenie';
  ChartData.DtPanel[0].MinR := -20;
  ChartData.DtPanel[0].MaxR := 20;
  ChartData.DtSeries[0] := ChartData.DtPanel[0].Series.CreateNew(0);
  ChartData.DtSeries[0].PenColor := clBlue;

  ChartData.DtPanel[1] := ChartData.Chart.Engine.AddAnalogPanel;
  ChartData.DtPanel[1].Title := 'Aktwnoœæ';
  ChartData.DtPanel[1].MinR := -1.2;
  ChartData.DtPanel[1].MaxR := 1.2;
  ChartData.DtSeries[1] := ChartData.DtPanel[1].Series.CreateNew(1);
  ChartData.DtSeries[1].PenColor := clBlue;

  SetLength(ChartData.Buffer, CHART_PROB_CNT);
  ChartData.BufPtr := 0;

  mkalibrValP0 := 0;
  mkalibrValP1 := 40;
  mKalibrPointNr := 0;

end;

procedure TServSlipSideForm.FormDestroy(Sender: TObject);
begin
  inherited;
  DataSpeed.Free;
end;

procedure TServSlipSideForm.OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double;
  var Exist: boolean);
begin
  Exist := false;
  if NrProb < cardinal(ChartData.BufPtr) then
  begin
    Exist := true;
    case DtNr of
      0:
        Val := ChartData.Buffer[NrProb].Wychyl;
      1:
        Val := ChartData.Buffer[NrProb].Aktiv;
    end;

  end;

end;

procedure TServSlipSideForm.ProcPaintBoxPaint(Sender: TObject);
begin
  inherited;
  PaintTxtBar(ProcPaintBox, clGray, clGReen, ['Si³a H.', FormatFloat('000.0', mMeas.proc)], mMeas.proc / 100);
end;

procedure TServSlipSideForm.doStartStop(run: boolean);
begin
  inherited;
end;

procedure TServSlipSideForm.ReciveMeasDataErrCfg(dt: TBytes);
var
  spd: double;
  rec: TKSlipSideDataRecErrCfg;
  n1, n2: integer;
begin
  inc(mMeas.recCnt);
  mMeas.cfgErrMode := true;
  DataSpeed.AddItem;
  MsgCntEdit.Text := IntToStr(mMeas.recCnt);
  if DataSpeed.getSpeed(spd) then
    MsgPerSekEdit.Text := Format('%.2f', [spd])
  else
    MsgPerSekEdit.Text := '';
  n1 := length(dt);
  n2 := sizeof(rec);
  if n1 = n2 then
  begin
    move(dt[0], rec, n1);
    mMeas.proc := rec.proc;
    ProcPaintBox.Invalidate;
    BigDigPaintBox.Invalidate;

    if GetTickCount - mMeas.showTick > 200 then
    begin
      mMeas.showTick := GetTickCount;
      MeasGrid.Cells[1, 1] := Format('%.1f[%%]', [mMeas.proc]);
      MeasGrid.Cells[1, 2] := '???';
      MeasGrid.Cells[1, 3] := '?';
      MeasGrid.Cells[1, 4] := '?';
      MeasGrid.Cells[1, 5] := '?';
      MeasGrid.Cells[1, 6] := '?';
      MeasGrid.Cells[1, 7] := '?';

    end;

  end;
end;

procedure TServSlipSideForm.ReciveMeasData(dt: TBytes);
var
  spd: double;
  rec: TKSlipSideDataRec;
  n1, n2: integer;
  i: integer;
  m: integer;
  s: string;
begin
  inc(mMeas.recCnt);
  mMeas.cfgErrMode := false;
  DataSpeed.AddItem;
  MsgCntEdit.Text := IntToStr(mMeas.recCnt);
  if DataSpeed.getSpeed(spd) then
    MsgPerSekEdit.Text := Format('%.2f', [spd])
  else
    MsgPerSekEdit.Text := '';
  n1 := length(dt);
  n2 := sizeof(rec);
  if n1 = n2 then
  begin
    move(dt[0], rec, n1);
    m := 0;
    if rec.getFlagActiv then
    begin
      if rec.Wychyl > 0 then
        m := 1
      else
        m := -1;
    end;

    if rec.bufferNr <> mMeas.bufferNr + 1 then
      inc(mMeas.loastCnt);
    lostCntEdit.Text := IntToStr(mMeas.loastCnt);
    mMeas.bufferNr := rec.bufferNr;
    mMeas.proc := rec.proc;
    mMeas.wychylVal := rec.Wychyl;
    mMeas.zeroShift := rec.startShift;
    mMeas.devActiv := rec.getFlagActiv;
    mMeas.typPlyty := rec.getTypPlyty;
    mMeas.typPlytyStr := rec.getTypPlytyStr;
    mMeas.najazdSensActiv := rec.getNajazdSensorActiv;
    mMeas.zjazdSensActiv := rec.getZjazdSensorActiv;

    for i := 0 to CHANNEL_DATA_LEN - 1 do
    begin
      if ChartData.BufPtr < CHART_PROB_CNT then
      begin
        ChartData.Buffer[ChartData.BufPtr].Wychyl := (rec.wsp.a * rec.Buffer[i] + rec.wsp.b) - mMeas.zeroShift;
        ChartData.Buffer[ChartData.BufPtr].Aktiv := m;
        inc(ChartData.BufPtr);
      end;
    end;

    if mMeas.devActiv then
      ActivShape.Brush.color := clRed
    else
      ActivShape.Brush.color := clGray;

    ProcPaintBox.Invalidate;
    ChartData.Chart.Invalidate;
    BigDigPaintBox.Invalidate;

    if GetTickCount - mMeas.showTick > 200 then
    begin
      mMeas.showTick := GetTickCount;
      MeasGrid.Cells[1, 1] := Format('%.1f[%%]', [mMeas.proc]);
      MeasGrid.Cells[1, 2] := Format('%.1f[mm]', [mMeas.wychylVal]);
      MeasGrid.Cells[1, 3] := Format('%.1f[mm]', [mMeas.zeroShift]);

      MeasGrid.Cells[1, 4] := Format('%u', [byte(mMeas.devActiv)]);
      MeasGrid.Cells[1, 5] := mMeas.typPlytyStr;

      if (mMeas.typPlyty = 1) or (mMeas.typPlyty = 2) then
        s := Format('%u', [byte(mMeas.najazdSensActiv)])
      else
        s := '-';
      MeasGrid.Cells[1, 6] := s;

      if (mMeas.typPlyty = 2) then
        s := Format('%u', [byte(mMeas.zjazdSensActiv)])
      else
        s := '-';
      MeasGrid.Cells[1, 7] := s;

    end;

  end;
end;

function TServSlipSideForm.getStartMode: byte;
begin
  Result := 1;
end;

procedure TServSlipSideForm.RecivedServiceObj(obCode: integer; dt: TBytes);
var
  s: string;
  errCode: byte;
  recEnd: TKSlipSideMeasEnd;
  col: TColor;
begin
  case obCode of
    ord(msgSlipSideSetZeroShift):
      begin
        errCode := dt[0];
        if dt[0] <> byte(ord(sslOK)) then
        begin
          if errCode = byte(ord(sslMaxStartShiftExceeded)) then
            s := 'Przekroczony margines zerowania'
          else
            s := Format('Zerowanie, b³¹d kod=%d', [errCode]);
        end;
      end;
    ord(msgSlipSideResult):
      begin
        if length(dt) = sizeof(recEnd) then
        begin
          move(dt[0], recEnd, sizeof(recEnd));
          ResultSwingEdit.Text := Format('%.2f[mm]', [recEnd.Wychyl]);
          ResultTimeEdit.Text := Format('%.2f[s]', [recEnd.measTime]);
          ResultStatusEdit.Text := recEnd.getStatusTxt;
          if recEnd.status = ord(sslOK) then
          begin
            if recEnd.Wychyl > 0 then
              col := clGReen
            else
              col := clBlue;
          end
          else
            col := clRed;

          ResultPanel.color := col;

          ResultTimer.Enabled := true;

        end;

      end;
  end;
end;

procedure TServSlipSideForm.ResultTimerTimer(Sender: TObject);
begin
  inherited;
  ResultPanel.color := clBtnFace;
end;

procedure TServSlipSideForm.actKalibrWagiExecute(Sender: TObject);
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

procedure TServSlipSideForm.actRUNExecute(Sender: TObject);
begin
  inherited;
  if actRun.Checked then
  begin
    mMeas.recCnt := 0;
    ChartData.BufPtr := 0;
    DataSpeed.Reset;
  end;

end;

procedure TServSlipSideForm.actStartMeasExecute(Sender: TObject);
begin
  inherited;
  KpDev.sendSlipSideZeroShift;
end;

procedure TServSlipSideForm.actKalibrP1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('L1', 'mm', 1, mkalibrValP1);
end;

procedure TServSlipSideForm.actKalibrP0Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('L0', 'mm', 0, mkalibrValP0);
end;

procedure TServSlipSideForm.actKalibrP0Update(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := KpDev.IsConnected;
end;

procedure TServSlipSideForm.BigDigPaintBoxClick(Sender: TObject);
begin
  inherited;
  inc(bigDigMode);
  if (bigDigMode < 0) or (bigDigMode >= 3) then
    bigDigMode := 0;
  BigDigPaintBox.Invalidate;
end;

procedure TServSlipSideForm.BigDigPaintBoxPaint(Sender: TObject);
var
  s: Strings;
  s1, s2: String;

begin
  inherited;

  if mMeas.proc > 0 then
  begin
    if not mMeas.cfgErrMode then
    begin
      s1 := Format('%.1f[%%]', [mMeas.proc]);
      s2 := Format('%.1f[mm]', [mMeas.wychylVal]);

      case bigDigMode of
        0:
          s := [s1];
        1:
          s := [s2];
        2:
          s := [s1, s2];

      end;
    end
    else
    begin
      s := [Format('%.1f[%%]', [mMeas.proc])];
    end;
  end
  else
    s := ['---'];

  PaintTxtBox(Sender as TPaintBox, clSilver, clBlue, s);
end;

end.
