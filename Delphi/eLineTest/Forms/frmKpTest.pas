unit frmKpTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition,
  kpDevUnit,
  frmBaseELineUnit, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TKpTestForm = class(TBaseELineForm)
    TestTimer: TTimer;
    Splitter1: TSplitter;
    Panel1: TPanel;
    MsgCntText: TStaticText;
    DigiPanel: TPanel;
    Bn8Panel: TPanel;
    Dg7Shape: TShape;
    Bin7Paint: TPaintBox;
    Bevel8: TBevel;
    NameDg8Text: TStaticText;
    Bn7Panel: TPanel;
    Dg6Shape: TShape;
    Bin6Paint: TPaintBox;
    Bevel7: TBevel;
    NameDg7Text: TStaticText;
    Bn6Panel: TPanel;
    Dg5Shape: TShape;
    Bin5Paint: TPaintBox;
    Bevel6: TBevel;
    NameDg6Text: TStaticText;
    Bn5Panel: TPanel;
    Dg4Shape: TShape;
    Bin4Paint: TPaintBox;
    Bevel5: TBevel;
    NameDg5Text: TStaticText;
    Bn4Panel: TPanel;
    Dg3Shape: TShape;
    Bin3Paint: TPaintBox;
    Bevel4: TBevel;
    NameDg4Text: TStaticText;
    Bn3Panel: TPanel;
    Dg2Shape: TShape;
    Bin2Paint: TPaintBox;
    Bevel3: TBevel;
    NameDg3Text: TStaticText;
    Bn2Panel: TPanel;
    Dg1Shape: TShape;
    Bin1Paint: TPaintBox;
    Bevel2: TBevel;
    NameDg2Text: TStaticText;
    Bn1Panel: TPanel;
    Dg0Shape: TShape;
    Bin0Paint: TPaintBox;
    Bevel1: TBevel;
    NameDg1Text: TStaticText;
    AnPanel: TPanel;
    Kn1Panel: TPanel;
    Wh1Btn: TSpeedButton;
    An0Paint: TPaintBox;
    StaticText2: TStaticText;
    Kn2Panel: TPanel;
    Wh2Btn: TSpeedButton;
    An1Paint: TPaintBox;
    StaticText30: TStaticText;
    Kn3Panel: TPanel;
    Wh3Btn: TSpeedButton;
    An2Paint: TPaintBox;
    StaticText28: TStaticText;
    Kn4Panel: TPanel;
    Wh4Btn: TSpeedButton;
    An3Paint: TPaintBox;
    StaticText26: TStaticText;
    Kn5Panel: TPanel;
    Wh5Btn: TSpeedButton;
    An4Paint: TPaintBox;
    StaticText24: TStaticText;
    Kn6Panel: TPanel;
    Wh6Btn: TSpeedButton;
    An5Paint: TPaintBox;
    StaticText22: TStaticText;
    Kn7Panel: TPanel;
    Wh7Btn: TSpeedButton;
    An6Paint: TPaintBox;
    StaticText20: TStaticText;
    Kn8Panel: TPanel;
    Wh8Btn: TSpeedButton;
    An7Paint: TPaintBox;
    StaticText18: TStaticText;
    procedure An0PaintPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Wh1BtnClick(Sender: TObject);
    procedure Bin0PaintPaint(Sender: TObject);
    procedure TestTimerTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
  private const
    DIG_CNT = 8;
    AN_CNT = 8;

  private type
    TAnRec = record
      Btn: TSpeedButton;
      Sh: TPaintBox;
      val: single; // wartoœæ aktualna w procentach
    end;

    TAnDt = record
      tab: array [0 .. AN_CNT - 1] of TAnRec;
      function getIdx(Sender: TObject): integer;
      procedure update;

    end;

    TDigRec = record
      BtnSh: TShape;
      LevSh: TPaintBox;
      levelL: single; // wartoœc progu LOW w procentach
      levelH: single; // wartoœc progu HIGH w procentach
      asAnalog: boolean; // wejœcie binarne czytane jak analog
      binVal: boolean;
      val: single; // wartoœæ aktualna w procentach
    end;

    TDigDt = record
      tab: array [0 .. DIG_CNT - 1] of TDigRec;
      function getIdx(Sender: TObject): integer;
      procedure update;
    end;

    TKKpTestDataBinCh = packed record
      val: single;
      levL: single;
      levH: single;
    end;

    TKKpTestData = packed record
      anVal: array [0 .. AN_CNT - 1] of single; // wartoœæ w procentach
      binState: byte;
      binAsAC: byte;
      free: word;
      binCh: array [0 .. DIG_CNT - 1] of TKKpTestDataBinCh;
    end;

  private
    Dig: TDigDt;
    An: TAnDt;
    mRecCnt: integer;

    function kpDev: TKPDev;
    procedure RecivedTestData(buf: TBytes);

  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}



function TKpTestForm.TAnDt.getIdx(Sender: TObject): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to AN_CNT - 1 do
  begin
    if (tab[i].Btn = Sender) or (tab[i].Sh = Sender) then
    begin
      Result := i;
      break;
    end;
  end;
  if Result < 0 then
    raise exception.Create('TAnDt.getIdx: Error');
end;

procedure TKpTestForm.TAnDt.update;
var
  i: integer;
begin
  for i := 0 to AN_CNT - 1 do
  begin
    tab[i].Sh.Invalidate;
  end;
end;

function TKpTestForm.TDigDt.getIdx(Sender: TObject): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to DIG_CNT - 1 do
  begin
    if (tab[i].BtnSh = Sender) or (tab[i].LevSh = Sender) then
    begin
      Result := i;
      break;
    end;
  end;
  if Result < 0 then
    raise exception.Create('TDigDt.getIdx: Error');
end;

procedure TKpTestForm.TDigDt.update;
var
  i: integer;
  col: TColor;
begin
  for i := 0 to DIG_CNT - 1 do
  begin
    tab[i].LevSh.Invalidate;
    if tab[i].binVal then
      col := clRed
    else
      col := clGreen;
    tab[i].BtnSh.Brush.Color := col;
  end;
end;

procedure TKpTestForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  TestTimer.Enabled := false;
  kpDev.sendNeedTestData(false);
end;

procedure TKpTestForm.FormCreate(Sender: TObject);
begin
  inherited;
  An.tab[0].Btn := Wh1Btn;
  An.tab[1].Btn := Wh2Btn;
  An.tab[2].Btn := Wh3Btn;
  An.tab[3].Btn := Wh4Btn;
  An.tab[4].Btn := Wh5Btn;
  An.tab[5].Btn := Wh6Btn;
  An.tab[6].Btn := Wh7Btn;
  An.tab[7].Btn := Wh8Btn;

  An.tab[0].Sh := An0Paint;
  An.tab[1].Sh := An1Paint;
  An.tab[2].Sh := An2Paint;
  An.tab[3].Sh := An3Paint;
  An.tab[4].Sh := An4Paint;
  An.tab[5].Sh := An5Paint;
  An.tab[6].Sh := An6Paint;
  An.tab[7].Sh := An7Paint;

  Dig.tab[0].BtnSh := Dg0Shape;
  Dig.tab[1].BtnSh := Dg1Shape;
  Dig.tab[2].BtnSh := Dg2Shape;
  Dig.tab[3].BtnSh := Dg3Shape;
  Dig.tab[4].BtnSh := Dg4Shape;
  Dig.tab[5].BtnSh := Dg5Shape;
  Dig.tab[6].BtnSh := Dg6Shape;
  Dig.tab[7].BtnSh := Dg7Shape;

  Dig.tab[0].LevSh := Bin0Paint;
  Dig.tab[1].LevSh := Bin1Paint;
  Dig.tab[2].LevSh := Bin2Paint;
  Dig.tab[3].LevSh := Bin3Paint;
  Dig.tab[4].LevSh := Bin4Paint;
  Dig.tab[5].LevSh := Bin5Paint;
  Dig.tab[6].LevSh := Bin6Paint;
  Dig.tab[7].LevSh := Bin7Paint;
  mRecCnt := 0;
end;

procedure TKpTestForm.FormResize(Sender: TObject);
var
  w : integer;
begin
  w := (Width-16) div 8;

  Kn1Panel.Width :=w;
  Kn2Panel.Width :=w;
  Kn3Panel.Width :=w;
  Kn4Panel.Width :=w;
  Kn5Panel.Width :=w;
  Kn6Panel.Width :=w;
  Kn7Panel.Width :=w;
  Kn8Panel.Width :=w;

  Bn1Panel.Width :=w;
  Bn2Panel.Width :=w;
  Bn3Panel.Width :=w;
  Bn4Panel.Width :=w;
  Bn5Panel.Width :=w;
  Bn6Panel.Width :=w;
  Bn7Panel.Width :=w;
  Bn8Panel.Width :=w;

end;


procedure TKpTestForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := 'KPTest :' + mELineDev.getCpxName;
  TestTimer.Enabled := true;
  kpDev.sendNeedTestData(true);
  BringUp;
end;

procedure TKpTestForm.TestTimerTimer(Sender: TObject);
begin
  inherited;
  kpDev.sendNeedTestData(true);
end;

procedure TKpTestForm.RecivedTestData(buf: TBytes);
var
  dt: TKKpTestData;
  n1, n2: integer;
  i: integer;
  mask: byte;
begin
  n1 := length(buf);
  n2 := sizeof(dt);
  if n1 = n2 then
  begin
    move(buf[0], dt, n1);
    for i := 0 to AN_CNT - 1 do
    begin
      An.tab[i].val := dt.anVal[i];
    end;
    for i := 0 to DIG_CNT - 1 do
    begin
      Dig.tab[i].val := dt.binCh[i].val;
      Dig.tab[i].levelL := dt.binCh[i].levL;
      Dig.tab[i].levelH := dt.binCh[i].levH;
      mask := (1 shl i);
      Dig.tab[i].asAnalog := ((dt.binAsAC and mask) <> 0);
      Dig.tab[i].binVal := ((dt.binState and mask) <> 0);
    end;
    An.update;
    Dig.update;
  end;

end;

procedure TKpTestForm.RecivedObj(obj: TKobj);
  procedure UpdateStatePLS(b: byte);
  var
    i: integer;
    q: boolean;
    mask: byte;
  begin
    for i := 0 to AN_CNT - 1 do
    begin
      mask := 1 shl i;
      q := ((b and mask) <> 0);
      An.tab[i].Btn.Down := q;
    end;
  end;

begin
  if (obj.srcDev = dsdKP) then
  begin
    case obj.obCode of
      ord(msgKPTestData):
        begin
          inc(mRecCnt);
          MsgCntText.Caption := ' ' + InttoStr(mRecCnt);
          RecivedTestData(obj.data);

        end;
      ord(msgKPGetPLS):
        begin
          UpdateStatePLS(obj.data[0]);

        end;
    end;
  end;
end;

procedure TKpTestForm.BringUp;
begin
  kpDev.sendGetPLSState();
end;

procedure TKpTestForm.An0PaintPaint(Sender: TObject);
var
  idx: integer;
  s: string;
begin
  inherited;
  idx := An.getIdx(Sender);
  s := FormatFloat('00.0', An.tab[idx].val);
  PaintTxtBar(Sender as TPaintBox, clGray, clGreen, s, An.tab[idx].val/100);
end;

procedure TKpTestForm.Bin0PaintPaint(Sender: TObject);

  procedure PaintLevels(Bx: TPaintBox; aLow, aHigh: single; asAc: boolean);
  var
    Cn: TCanvas;
    y: integer;
  begin
    Cn := Bx.Canvas;
    if asAc then
    begin
      Cn.Pen.Width := 2;
      Cn.Pen.Style := psSolid;
    end
    else
    begin
      Cn.Pen.Width := 1;
      Cn.Pen.Style := psDot;
    end;

    Cn.Pen.Color := clBlue; //Aqua;
    y := round(Bx.Height * (1 - aLow / 100));
    Cn.MoveTo(0, y);
    Cn.LineTo(Bx.Width - 1, y);

    Cn.Pen.Color := clRed;
    y := round(Bx.Height * (1 - aHigh / 100));
    Cn.MoveTo(0, y);
    Cn.LineTo(Bx.Width - 1, y);

    Cn.Pen.Width := 1;
    Cn.Pen.Color := clBlack;
    Cn.Pen.Style := psSolid;
  end;

var
  nr: integer;
  s: string;
begin
  nr := Dig.getIdx(Sender);
  s := FormatFloat('00.0', Dig.tab[nr].val);

  PaintTxtBar(Sender as TPaintBox, clGray, clGreen, s, Dig.tab[nr].val/100.0);

  PaintLevels(Sender as TPaintBox, Dig.tab[nr].levelL, Dig.tab[nr].levelH, Dig.tab[nr].asAnalog);
end;

function TKpTestForm.kpDev: TKPDev;
begin
  Result := mELineDev as TKPDev;
end;

procedure TKpTestForm.Wh1BtnClick(Sender: TObject);
var
  nr: integer;
begin
  nr := An.getIdx(Sender);
  kpDev.sendWhiteWireTestMode(nr, (Sender as TSpeedButton).Down);

end;

end.
