unit frmServBreaks;

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
  TServBreakForm = class(TBaseKpServForm)
    TopPanel: TPanel;
    BigDigPaintBox: TPaintBox;
    MeasGrid: TStringGrid;
    Panel2: TPanel;
    MsgCntEdit: TLabeledEdit;
    MsgPerSekEdit: TLabeledEdit;
    Panel1: TPanel;
    Splitter2: TSplitter;
    ActivShape: TShape;
    HamowPaintBox: TPaintBox;
    WhiteCableBtn: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure actKalibrZeroUpdate(Sender: TObject);
    procedure actKalibrZeroExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WhiteCableBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HamowPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxPaint(Sender: TObject);
    procedure BigDigPaintBoxClick(Sender: TObject);
    procedure actKalibrP1Execute(Sender: TObject);
    procedure actRUNExecute(Sender: TObject);
  private const
    CHART_PROB_CNT = 120 * 1000; // 120 sekund = 2 min
  private type
    TBreakData = record
      Hamow: single;
      Speed: single;
      Najazd: integer;
    end;

    TChartData = record
      Buffer: array of TBreakData;
      BufPtr: integer;
    end;

  private
    Chart: TElWykres;
    DtPanel: array [0 .. 2] of TAnalogPanel;
    DtSeries: array [0 .. 2] of TAnalogSerie;
    ChartData: TChartData;
    DataSpeed: TDataSpeedMeas;
    mRecCnt: integer;
    mShowTick: cardinal;
    mHamowVal: single;
    mHamowProc: single;
    bigDigMode: integer;
    mkalibrVal: single;

    procedure OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double; var Exist: boolean);

  protected
    procedure doStartStop(run: boolean); override;
    procedure ReciveMeasData(dt: TBytes); override;
    procedure RecivedServiceObj(obCode: integer; dt: TBytes); override;
  public
  end;

implementation

{$R *.dfm}

uses
  Main;

procedure TServBreakForm.FormCreate(Sender: TObject);
const
  TabNames: array [0 .. 2] of string = ('Si³a hamowania', 'Prêdkoœæ', 'Najazd');
  TabRangeMax: array [0 .. 2] of double = (10000, 8, 1.2);
  TabRangeMin: array [0 .. 2] of double = (-10000, -0.5, -0.2);
var
  i: integer;
begin
  inherited;
  DataSpeed := TDataSpeedMeas.create;
  mRecCnt := 0;
  mHamowProc := -1;
  mHamowVal := -1;

  MeasGrid.Rows[0].CommaText := 'Nazwa Wartoœæ';
  MeasGrid.Cols[0].CommaText := 'Nazwa "Si³a hamow" "Si³a h.proc." "Prêdkoœæ" "Najazd" "White wire"';

  Chart := TElWykres.create(self);
  Chart.Parent := self;
  Chart.Align := alClient;
  Chart.OnGetAnValue := OnGetAnValueProc;
  Chart.ProbCnt := CHART_PROB_CNT;
  Chart.DtPerProbka := 0.10;
  Chart.Engine.ShowPoints := true;

  for i := 0 to 2 do
  begin
    DtPanel[i] := Chart.Engine.AddAnalogPanel;
    DtPanel[i].Title := TabNames[i];
    DtPanel[i].MinR := TabRangeMin[i];
    DtPanel[i].MaxR := TabRangeMax[i];
    DtSeries[i] := DtPanel[i].Series.CreateNew(i);
    DtSeries[i].PenColor := clBlack;
  end;
  SetLength(ChartData.Buffer, CHART_PROB_CNT);
  ChartData.BufPtr := 0;

  WhiteCableBtn.Caption := 'White cable' + #13 + 'Zakres';
  mkalibrVal := 4000;

end;

procedure TServBreakForm.FormDestroy(Sender: TObject);
begin
  inherited;
  DataSpeed.Free;
end;

procedure TServBreakForm.OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double;
  var Exist: boolean);
begin
  Exist := false;
  if NrProb < cardinal(ChartData.BufPtr) then
  begin
    Exist := true;
    case DtNr of
      0:
        Val := ChartData.Buffer[NrProb].Hamow;
      1:
        Val := ChartData.Buffer[NrProb].Speed;
      2:
        Val := ChartData.Buffer[NrProb].Najazd;
    end;
  end;

end;

procedure TServBreakForm.HamowPaintBoxPaint(Sender: TObject);
begin
  inherited;
  PaintTxtBar(HamowPaintBox, clGray, clGReen, ['Si³a H.', FormatFloat('000.0', mHamowVal)], mHamowProc / 100);
end;

procedure TServBreakForm.doStartStop(run: boolean);
begin
  inherited;
end;

procedure TServBreakForm.ReciveMeasData(dt: TBytes);
var
  spd: double;
  rec: TKBreakData;
  n1, n2: integer;
  i: integer;
begin
  inc(mRecCnt);
  DataSpeed.AddItem;
  MsgCntEdit.Text := IntToStr(mRecCnt);
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
        ChartData.Buffer[ChartData.BufPtr].Hamow := rec.wsp.a * rec.Buffer[i] + rec.wsp.b;
        ChartData.Buffer[ChartData.BufPtr].Speed := rec.Speed;
        ChartData.Buffer[ChartData.BufPtr].Najazd := rec.getFlagInt(breakFlag_pressRol);
        inc(ChartData.BufPtr);
      end;
    end;

    if rec.getFlagBit(breakFlag_pressRol) then
      ActivShape.Brush.color := clRed
    else
      ActivShape.Brush.color := clGray;

    mHamowProc := rec.silHamowProc;
    mHamowVal := rec.silHamow;
    HamowPaintBox.Invalidate;
    Chart.Invalidate;
    BigDigPaintBox.Invalidate;

    if GetTickCount - mShowTick > 200 then
    begin
      mShowTick := GetTickCount;
      MeasGrid.Cells[1, 1] := Format('%.1f[N]', [rec.silHamow]);
      MeasGrid.Cells[1, 2] := Format('%.1f[%%]', [rec.silHamowProc]);
      MeasGrid.Cells[1, 3] := Format('%.1f[m/s]', [rec.Speed]);
      MeasGrid.Cells[1, 4] := Format('%u', [rec.getFlagInt(breakFlag_pressRol)]);
      MeasGrid.Cells[1, 5] := Format('%u', [rec.getFlagInt(breakFlag_pls)]);
    end;

  end;
end;

procedure TServBreakForm.WhiteCableBtnClick(Sender: TObject);
begin
  inherited;
  KpDev.sendBreakWhiteWire(service, (Sender as TSpeedButton).Down);
end;

procedure TServBreakForm.RecivedServiceObj(obCode: integer; dt: TBytes);
begin

end;

procedure TServBreakForm.actKalibrP1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('P1', 'N', 1, mkalibrVal);
end;

procedure TServBreakForm.actKalibrZeroExecute(Sender: TObject);
begin
  inherited;
  if Application.MessageBox('Czy uruchomiæ kalibracjê zera ?', pchar(Caption), mb_yesNo) = idYes then
  begin
    KpDev.sendRunKalibr(service, 0, 0);
  end;

end;

procedure TServBreakForm.actKalibrZeroUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := KpDev.IsConnected;
end;

procedure TServBreakForm.actRUNExecute(Sender: TObject);
begin
  inherited;
  if actRun.Checked then
  begin
    mRecCnt := 0;
    ChartData.BufPtr := 0;
    DataSpeed.Reset;
  end;
end;

procedure TServBreakForm.BigDigPaintBoxClick(Sender: TObject);
begin
  inherited;
  inc(bigDigMode);
  if (bigDigMode < 0) or (bigDigMode >= 4) then
    bigDigMode := 0;
  BigDigPaintBox.Invalidate;
end;

procedure TServBreakForm.BigDigPaintBoxPaint(Sender: TObject);
var
  s: Strings;
begin
  inherited;

  if mHamowProc > 0 then
  begin
    case bigDigMode of
      0:
        s := [Format('%.1f[N]', [mHamowVal])];
      1:
        s := [Format('%.1f[%%]', [mHamowProc])];
      2:
        s := [Format('%.1f[N] - %.1f[%%]', [mHamowVal, mHamowProc])];
      3:
        s := [Format('%.1f[N]', [mHamowVal]), Format('%.1f[%%]', [mHamowProc])];

    end;
  end
  else
    s := ['---'];

  PaintTxtBox(Sender as TPaintBox, clSilver, clBlue, s);
end;

end.
