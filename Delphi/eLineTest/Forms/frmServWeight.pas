unit frmServWeight;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Math, Vcl.ImgList, Vcl.ToolWin, Vcl.StdCtrls,
  Vcl.Grids, Vcl.ComCtrls, Vcl.Buttons, System.Actions, Vcl.ActnList, System.ImageList,

  frmBaseELineUnit,
  frmBaseKpService,

  MyUtils,
  CmmObjDefinition,
  BaseDevCmmUnit,
  eLineDef,
  KpDevUnit,
  Wykres3Unit,
  WykresEngUnit;

type
  TServWeightForm = class(TBaseKpServForm)
    PageControl1: TPageControl;
    TabSlupkiSheet: TTabSheet;
    Conv0Paint: TPaintBox;
    Conv3Paint: TPaintBox;
    Conv2Paint: TPaintBox;
    Conv1Paint: TPaintBox;
    TabSheet2: TTabSheet;
    CirclePaintBox: TPaintBox;
    MeasGrid: TStringGrid;
    TopPanel: TPanel;
    Panel2: TPanel;
    MsgCntEdit: TLabeledEdit;
    MsgPerSekEdit: TLabeledEdit;
    RatioBox: TRadioGroup;
    Splitter1: TSplitter;
    Okr10kgBox: TCheckBox;
    actKalibrZero: TAction;
    actKalibrP1: TAction;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    BigDigPaintBox: TPaintBox;
    Splitter2: TSplitter;
    procedure TabSlupkiSheetResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CirclePaintBoxPaint(Sender: TObject);
    procedure Conv0PaintPaint(Sender: TObject);
    procedure actKalibrZeroUpdate(Sender: TObject);
    procedure actKalibrP1Execute(Sender: TObject);
    procedure actKalibrZeroExecute(Sender: TObject);
    procedure RatioBoxClick(Sender: TObject);
    procedure BigDigPaintBoxPaint(Sender: TObject);
  private const
    MAX_WAGA = 11000; // 11 ton
    CHART_PROB_CNT = 300 * 10; // 300 sekund = 5 min

  private type
    T4Wag = array [0 .. 3] of double;
    TWagaData = array [0 .. 4] of single;

    TChartData = record
      Buffer: array of TWagaData;
      BufPtr: integer;
    end;

  private
    mRecCnt: integer;
    mShowTick: cardinal;
    DataSpeed: TDataSpeedMeas;
    WzglTab: T4Wag;
    MemWag4: T4Wag;
    MemWag4Zaokr: T4Wag;
    WeightAll: double;
    SlupkiTab: array [0 .. 3] of TPaintBox;

    Chart: TElWykres;
    DtPanel: TAnalogPanel;
    DtSeries: array [0 .. 4] of TAnalogSerie;
    ChartData: TChartData;
    mkalibrVal : single;

    procedure SetChartMinMax;
    procedure OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double; var Exist: boolean);

  protected
    procedure doStartStop(run: boolean); override;
    procedure ReciveMeasData(dt: TBytes); override;
    procedure RecivedServiceObj(obCode: integer; dt : TBytes); override;

  public

  end;

implementation

{$R *.dfm}

procedure TServWeightForm.FormCreate(Sender: TObject);
const
  TabColor: array [0 .. 4] of TColor = (clRed, clGreen, clBlue, clMaroon, clBlack);
var
  i: integer;
begin
  inherited;
  mRecCnt := 0;
  DataSpeed := TDataSpeedMeas.create;
  MeasGrid.Rows[0].CommaText := 'lp. Procent waga';
  MeasGrid.Cols[0].CommaText := 'lp. "Lewy Przód" "Prawy Przód" "Lewy Tyl" "Prawy Tyl" Suma';
  SlupkiTab[0] := Conv0Paint;
  SlupkiTab[1] := Conv1Paint;
  SlupkiTab[2] := Conv2Paint;
  SlupkiTab[3] := Conv3Paint;

  Chart := TElWykres.create(self);
  Chart.Parent := self;
  Chart.Align := alClient;
  Chart.OnGetAnValue := OnGetAnValueProc;
  Chart.ProbCnt := CHART_PROB_CNT;
  Chart.DtPerProbka := 0.10;
  Chart.Engine.ShowPoints := true;

  DtPanel := Chart.Engine.AddAnalogPanel;
  DtPanel.Title := 'Ciê¿ar';
  DtPanel.MinR := 0;
  DtPanel.MaxR := 11000;
  for i := 0 to 4 do
  begin
    DtSeries[i] := DtPanel.Series.CreateNew(i);
    DtSeries[i].PenColor := TabColor[i];
  end;
  SetLength(ChartData.Buffer, CHART_PROB_CNT);
  ChartData.BufPtr := 0;
  SetChartMinMax;
  WeightAll := -1;
  mkalibrVal := 1000;
end;

procedure TServWeightForm.FormDestroy(Sender: TObject);
begin
  inherited;
  DataSpeed.Free;

end;

procedure TServWeightForm.SetChartMinMax;
var
  mm: double;
begin
  mm := MAX_WAGA;
  case RatioBox.ItemIndex of
    0:
      mm := mm;
    1:
      mm := mm / 2;
    2:
      mm := mm / 5;
    3:
      mm := mm / 10;
    4:
      mm := mm / 20;
    5:
      mm := mm / 50;
  end;
  DtPanel.MinR := 0;
  DtPanel.MaxR := mm;
end;

procedure TServWeightForm.OnGetAnValueProc(Sender: TObject; DtNr: integer; NrProb: cardinal; var Val: double;
  var Exist: boolean);
begin
  Exist := false;
  if NrProb < cardinal(ChartData.BufPtr) then
  begin
    Exist := true;
    Val := ChartData.Buffer[NrProb][DtNr];
  end;

end;

procedure TServWeightForm.BigDigPaintBoxPaint(Sender: TObject);
var
  s: string;
begin
  inherited;

  if WeightAll > 0 then
    s := FormatFloat('0.', WeightAll)
  else
    s := '---';

  PaintTxtBox(Sender as TPaintBox, clSilver, clBlue, s);

end;

procedure TServWeightForm.RatioBoxClick(Sender: TObject);
begin
  inherited;
  SetChartMinMax;
end;

procedure TServWeightForm.CirclePaintBoxPaint(Sender: TObject);
var
  Cn: TCanvas;
  W, h: integer;
  w2, h2: integer;
  rr: integer;
  R: TRect;
  rw: double;

  function BuildRect(m: real): TRect;
  begin
    Result.Left := round(w2 - m * rr);
    Result.Top := round(h2 - m * rr);
    Result.Right := round(w2 + m * rr);
    Result.Bottom := round(h2 + m * rr);
  end;

const
  DirW: array [0 .. 3] of real = (-1, 1, -1, 1);
  DirH: array [0 .. 3] of real = (-1, -1, 1, 1);

var
  xr, yr: single;
  mLP, mPP, mLT, mPT: single;
  s: single;
  x, y: integer;
  WgMax: double;
  i: integer;
begin
  inherited;
  Cn := CirclePaintBox.Canvas;
  W := CirclePaintBox.Width;
  h := CirclePaintBox.Height;
  w2 := W div 2;
  h2 := h div 2;
  rr := min(w2, h2);

  Cn.Brush.Color := clCream;
  Cn.Pen.Color := clBlack;
  Cn.Brush.Style := bsSolid;
  R := BuildRect(1);
  Cn.Rectangle(R);
  Cn.Brush.Style := bsClear;
  Cn.Ellipse(R);

  w2 := (R.Right - R.Left) div 2 + R.Left;
  h2 := (R.Bottom - R.Top) div 2 + R.Top;

  Cn.MoveTo(w2, R.Top);
  Cn.LineTo(w2, R.Bottom);
  Cn.MoveTo(R.Left, h2);
  Cn.LineTo(R.Right, h2);

  Cn.Ellipse(BuildRect(0.75));
  Cn.Ellipse(BuildRect(0.50));
  Cn.Ellipse(BuildRect(0.25));

  mLP := MemWag4[0];
  mPP := MemWag4[1];
  mLT := MemWag4[2];
  mPT := MemWag4[3];

  s := mLP + mPP + mLT + mPT;
  if s <> 0 then
  begin
    xr := (mPP + mPT) / s;
    yr := (mLT + mPT) / s;
  end
  else
  begin
    xr := 0.5;
    yr := 0.5;
  end;

  if (xr < 0) then
    xr := 0;
  if (xr > 1) then
    xr := 1;
  if (yr < 0) then
    yr := 0;
  if (yr > 1) then
    yr := 1;

  x := round(2 * rr * xr) - rr; // x=(-rr..rr)
  y := round(2 * rr * yr) - rr; // y=(-rr..rr)
  x := W div 2 + x;
  y := h div 2 + y;

  R := Rect(x - 6, y - 6, x + 6, y + 6);
  Cn.Brush.Color := clRed;
  Cn.Pen.Color := clBlack;
  Cn.Ellipse(R);

  Cn.Brush.Color := clGreen;
  Cn.Pen.Color := clBlack;
  WgMax := MAX_WAGA;
  case RatioBox.ItemIndex of
    0:
      WgMax := WgMax;
    1:
      WgMax := WgMax / 2;
    2:
      WgMax := WgMax / 5;
    3:
      WgMax := WgMax / 10;
    4:
      WgMax := WgMax / 20;
    5:
      WgMax := WgMax / 50;
  end;

  for i := 0 to 3 do
  begin
    rw := MemWag4[i] / WgMax;
    x := w2 + round(rr * rw * DirW[i]);
    y := h2 + round(rr * rw * DirH[i]);
    R := Rect(x - 4, y - 4, x + 4, y + 4);
    Cn.Ellipse(R);
  end;
end;

procedure TServWeightForm.Conv0PaintPaint(Sender: TObject);
const
  TabChName: array [0 .. 3] of string = ('LP', 'PP', 'LT', 'PT');
var
  i: integer;
begin
  inherited;
  for i := 0 to 3 do
  begin
    if SlupkiTab[i] = Sender then
    begin
      PaintTxtBar(SlupkiTab[i], clGray, clYellow, [TabChName[i], FormatFloat('0000', MemWag4Zaokr[i])], WzglTab[i]);
      break;
    end;
  end;
end;

procedure TServWeightForm.doStartStop(run: boolean);
begin
  DataSpeed.Reset;
  mRecCnt := 0;
  ChartData.BufPtr := 0;
  mShowTick := GetTickCount;

end;

procedure TServWeightForm.ReciveMeasData(dt: TBytes);
var
  spd: double;
  rec: TKWeightData;
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

    for i := 0 to 3 do
    begin
      MemWag4[i] := rec.chnVal[i];
      MemWag4Zaokr[i] := rec.chnVal[i];
      WzglTab[i] := rec.chnProc[i] / 100;
      if Okr10kgBox.Checked then
      begin
        MemWag4Zaokr[i] := 10 * round(MemWag4Zaokr[i] / 10);
      end;
    end;
    WeightAll := rec.weight;
    if Okr10kgBox.Checked then
      WeightAll := 10 * round(WeightAll / 10);

    if GetTickCount - mShowTick > 200 then
    begin
      mShowTick := GetTickCount;
      for i := 0 to 3 do
      begin
        MeasGrid.Cells[1, 1 + i] := Format('%.1f[%%]', [rec.chnProc[i]]);
        MeasGrid.Cells[2, 1 + i] := Format('%.1f[kg]', [MemWag4Zaokr[i]]);
      end;
      MeasGrid.Cells[2, 5] := Format('%.1f[kg]', [WeightAll]);
    end;

    if ChartData.BufPtr < CHART_PROB_CNT then
    begin
      for i := 0 to 3 do
      begin
        ChartData.Buffer[ChartData.BufPtr][i] := rec.chnVal[i];
      end;
      ChartData.Buffer[ChartData.BufPtr][4] := rec.weight;
      inc(ChartData.BufPtr);
    end;

    for i := 0 to 3 do
      SlupkiTab[i].Invalidate;
    CirclePaintBox.Invalidate;
    BigDigPaintBox.Invalidate;
    Chart.Invalidate;
  end;

end;

procedure TServWeightForm.RecivedServiceObj(obCode: integer; dt : TBytes);
begin

end;

procedure TServWeightForm.actKalibrP1Execute(Sender: TObject);
begin
  inherited;
  StartKalibracji('P1', 'kg', 1, mkalibrVal);
end;

procedure TServWeightForm.actKalibrZeroExecute(Sender: TObject);
begin
  inherited;
  if Application.MessageBox('Czy uruchomic kalibracjê zera ?', pchar(caption), mb_yesNo) = idYes then
  begin
    KpDev.sendRunKalibr(Service, 0, 0);
  end;
end;

procedure TServWeightForm.actKalibrZeroUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := KpDev.IsConnected;
end;

procedure TServWeightForm.TabSlupkiSheetResize(Sender: TObject);
var
  dx: integer;
  dw: real;
begin
  inherited;
  dx := TabSlupkiSheet.Width - 5 * 5;
  dw := dx div 4;
  Conv0Paint.Width := round(dw);
  Conv1Paint.Width := round(dw);
  Conv2Paint.Width := round(dw);
  Conv3Paint.Width := round(dw);
  Conv0Paint.Left := 5;
  Conv1Paint.Left := 2 * 5 + round(dw);
  Conv2Paint.Left := 3 * 5 + round(2 * dw);
  Conv3Paint.Left := 4 * 5 + round(3 * dw);
end;

end.
