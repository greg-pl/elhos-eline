unit frameKpWeightCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Math;

type
  TKpWeightCfgFrame = class(TFrame)
    WagaAktivBox: TCheckBox;
    PT_Panel: TPanel;
    Label10: TLabel;
    WagaPTKorektaEdit: TLabeledEdit;
    WagaPTAnInpBox: TComboBox;
    WagaPTZeroEdit: TLabeledEdit;
    LT_Panel: TPanel;
    Label12: TLabel;
    WagaLTKorektaEdit: TLabeledEdit;
    WagaLTAnInpBox: TComboBox;
    WagaLTZeroEdit: TLabeledEdit;
    PP_Panel: TPanel;
    Label9: TLabel;
    WagaPPKorektaEdit: TLabeledEdit;
    WagaPPAnInpBox: TComboBox;
    WagaPPZeroEdit: TLabeledEdit;
    LP_Panel: TPanel;
    Label14: TLabel;
    WagaLPKorektaEdit: TLabeledEdit;
    WagaLPAnInpBox: TComboBox;
    WagaLPZeroEdit: TLabeledEdit;
    GroupBox2: TGroupBox;
    WagaP1ValEdit: TLabeledEdit;
    WagaP1KalibrEdit: TLabeledEdit;
    PaintBox1: TPaintBox;
    procedure WagaLTKorektaEditKeyPress(Sender: TObject; var Key: Char);
    procedure WagaLTKorektaEditExit(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxPaint(Sender: TObject);
    procedure GroupBox2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TKpWeightCfgFrame.WagaLTKorektaEditExit(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TKpWeightCfgFrame.WagaLTKorektaEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    PaintBox1.Invalidate;
    Key := #0;
  end;

end;

procedure TKpWeightCfgFrame.GroupBox2Click(Sender: TObject);
begin
  PaintBox1.Invalidate;
end;

procedure TKpWeightCfgFrame.PaintBox1Paint(Sender: TObject);
begin
  with sender as TPaintBox do
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clBlue;
    Canvas.Rectangle(0,0,width,Height);

  end;
end;

procedure TKpWeightCfgFrame.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  w, h: Integer;
  m11, m12, m21, m22: single;
  xr, yr: single;
  s: single;

begin
  w := PaintBox1.Width;
  h := PaintBox1.Height;

  xr := X / w;
  yr := Y / h;

  xr := 0.4 * (xr - 0.5) + 0.5;
  yr := 0.4 * (yr - 0.5) + 0.5;

  m11 := 1.5 - yr;
  m12 := m11;
  m21 := 0.5 + yr;
  m22 := m21;

  m12 := m12 * (0.5 + xr);
  m22 := m22 * (0.5 + xr);

  m11 := m11 * (1.5 - xr);
  m21 := m21 * (1.5 - xr);

  s := (m11 + m12 + m21 + m22) / 4;

  m11 := m11 / s;
  m12 := m12 / s;
  m21 := m21 / s;
  m22 := m22 / s;

  WagaLPKorektaEdit.Text := FormatFloat('0.000', m11);
  WagaPPKorektaEdit.Text := FormatFloat('0.000', m12);
  WagaLTKorektaEdit.Text := FormatFloat('0.000', m21);
  WagaPTKorektaEdit.Text := FormatFloat('0.000', m22);

  PaintBox1.Invalidate;
end;

procedure TKpWeightCfgFrame.PaintBoxPaint(Sender: TObject);
var
  Cn: TCanvas;
  w, h: Integer;
  w2, h2: Integer;
  rr: Integer;
  R: TRect;

  function BuildRect(m: real): TRect;
  begin
    Result.Left := round(w2 - m * rr);
    Result.Top := round(h2 - m * rr);
    Result.Right := round(w2 + m * rr);
    Result.Bottom := round(h2 + m * rr);
  end;

var
  xr, yr: single;
  mLP, mPP, mLT, mPT: single;
  s: single;
  X, Y: Integer;

begin
  mLP := StrToFloat(WagaLPKorektaEdit.Text);
  mPP := StrToFloat(WagaPPKorektaEdit.Text);
  mLT := StrToFloat(WagaLTKorektaEdit.Text);
  mPT := StrToFloat(WagaPTKorektaEdit.Text);

  Cn := PaintBox1.Canvas;
  w := PaintBox1.Width;
  h := PaintBox1.Height;
  w2 := w div 2;
  h2 := h div 2;
  rr := min(w2, h2);

  Cn.Brush.Color := clCream;
  Cn.Pen.Color := clBlack;
  Cn.Brush.Style := bsSolid;
  R := Rect(0, 0, w - 1, h - 1);
  Cn.Rectangle(R);
  Cn.Brush.Style := bsClear;
  Cn.Ellipse(R);
  Cn.Ellipse(BuildRect(0.75));
  Cn.Ellipse(BuildRect(0.50));
  Cn.Ellipse(BuildRect(0.25));
  Cn.MoveTo(w2, 0);
  Cn.LineTo(w2, h - 1);
  Cn.MoveTo(0, h2);
  Cn.LineTo(w - 1, h2);

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

  // wzmocnienie x5
  xr := 5 * (xr - 0.5) + 0.5;
  yr := 5 * (yr - 0.5) + 0.5;

  X := round(w * xr);
  Y := round(h * yr);

  R := Rect(X - 2, Y - 2, X + 2, Y + 2);
  Cn.Brush.Color := clRed;
  Cn.Pen.Color := clBlack;
  Cn.Ellipse(R);
end;

end.
