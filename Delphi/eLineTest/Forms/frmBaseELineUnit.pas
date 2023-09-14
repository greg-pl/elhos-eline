unit frmBaseELineUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  frmBaseMdiUnit,
  CmmObjDefinition,
  BaseDevCmmUnit,
  NetToolsUnit;

type
  TBaseELineForm = class(TBaseMdiForm)
  private
    { Private declarations }
  protected type
    Strings = array of string;
  protected
    mELineDev: TBaseELineDev;
    class procedure PaintTxtBar(Box: TPaintBox; Cl1, Cl2: TColor; val: string; ulamek: real); overload;
    class procedure PaintTxtBar(Box: TPaintBox; Cl1, Cl2: TColor; SL: TStrings; ulamek: real); overload;
    class procedure PaintTxtBar(Box: TPaintBox; Cl1, Cl2: TColor; Strs: Strings; ulamek: real); overload;
    class procedure PaintTxtBox(Box: TPaintBox; Cl1, Cl2: TColor; Strs: Strings); overload;
    class procedure PaintTxtBox(Box: TPaintBox; Cl1, Cl2: TColor; Str: String); overload;
    class procedure PaintTxtBox(Box: TPaintBox; Cl1, Cl2: TColor; SL: TStrings); overload;

  public
    function isThisDev(TestDev: TObject): boolean;
    procedure setELineDev(aDev: TBaseELineDev); virtual;
    procedure BringUp; virtual;
    procedure RecivedObj(obj: TKobj); virtual;
  private type
    TBaseELineFormClass = class of TBaseELineForm;
    TBaseELineForms = array of TBaseELineForm;
  public
    class function findElineForm(aClass: TBaseELineFormClass; IP: string): TBaseELineForm;
    class function ExecElineForm(ParenForm: TForm; aClass: TBaseELineFormClass; aDev: TBaseELineDev): TBaseELineForm;
    class function findDevForms(aDev: TBaseELineDev): TBaseELineForms;
    class procedure closeDevForms(aDev: TBaseELineDev);
  end;

implementation

{$R *.dfm}

procedure TBaseELineForm.setELineDev(aDev: TBaseELineDev);
begin
  mELineDev := aDev;
end;

function TBaseELineForm.isThisDev(TestDev: TObject): boolean;
begin
  result := (mELineDev = TestDev);
end;

procedure TBaseELineForm.BringUp;
begin

end;

procedure TBaseELineForm.RecivedObj(obj: TKobj);
begin

end;

class function TBaseELineForm.findElineForm(aClass: TBaseELineFormClass; IP: string): TBaseELineForm;
var
  i: integer;
  Form: TForm;
  IP_bin: cardinal;
begin
  result := nil;
  StrToIP(IP, IP_bin);
  for i := 0 to Application.MainForm.MDIChildCount - 1 do
  begin
    Form := Application.MainForm.MDIChildren[i];
    if Form is aClass then
    begin
      if (Form as TBaseELineForm).mELineDev.getIpBin = IP_bin then
      begin
        result := Form as TBaseELineForm;
        break;
      end;
    end;
  end;
end;

class function TBaseELineForm.ExecElineForm(ParenForm: TForm; aClass: TBaseELineFormClass; aDev: TBaseELineDev)
  : TBaseELineForm;
var
  Form: TBaseELineForm;
begin
  Form := findElineForm(aClass, aDev.getIp);
  if Assigned(Form) then
  begin
    Form.BringToFront;
    Form.BringUp;
  end
  else
  begin
    Form := aClass.Create(ParenForm);
    Form.setELineDev(aDev);
    Form.Show;
  end;
  result := Form;
end;

class function TBaseELineForm.findDevForms(aDev: TBaseELineDev): TBaseELineForms;
var
  i: integer;
  Form: TForm;
  n: integer;
begin
  result := [];
  for i := 0 to Application.MainForm.MDIChildCount - 1 do
  begin
    Form := Application.MainForm.MDIChildren[i];
    if Form is TBaseELineForm then
    begin
      if (Form as TBaseELineForm).mELineDev = aDev then
      begin
        n := length(result);
        setlength(result, n + 1);
        result[n] := Form as TBaseELineForm;
      end;
    end;
  end;
end;

class procedure TBaseELineForm.closeDevForms(aDev: TBaseELineDev);
var
  Forms: TBaseELineForms;
  i: integer;
begin
  Forms := findDevForms(aDev);
  for i := 0 to length(Forms) - 1 do
    Forms[i].Close;
end;

class procedure TBaseELineForm.PaintTxtBar(Box: TPaintBox; Cl1, Cl2: TColor; val: string; ulamek: real);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(val);
    PaintTxtBar(Box, Cl1, Cl2, SL, ulamek);
  finally
    SL.Free;
  end;
end;

class procedure TBaseELineForm.PaintTxtBar(Box: TPaintBox; Cl1, Cl2: TColor; Strs: Strings; ulamek: real);
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    for i := 0 to length(Strs) - 1 do
    begin
      SL.Add(Strs[i]);
    end;
    PaintTxtBar(Box, Cl1, Cl2, SL, ulamek);
  finally
    SL.Free;
  end;
end;

class procedure TBaseELineForm.PaintTxtBar(Box: TPaintBox; Cl1, Cl2: TColor; SL: TStrings; ulamek: real);
var
  Cn: TCanvas;
  R: TRect;
  R1: TRect;
  tx, ty: integer;
  y1: integer;
  xb: integer;
  siz: integer;
  i, mx, idx: integer;
  y0: integer;
begin
  Cn := Box.Canvas;
  R := Rect(0, 0, Box.Width, Box.Height);
  y1 := round((1 - ulamek) * Box.Height);

  Cn.Brush.Style := bsSolid;

  R1 := R;
  R1.Bottom := y1;
  Cn.Brush.Color := Cl1;
  Cn.FillRect(R1);

  R1 := R;
  R1.Top := y1;
  Cn.Brush.Color := Cl2;
  Cn.FillRect(R1);

  if SL.Count > 0 then
  begin
    mx := length(SL.Strings[0]);
    idx := 0;
    for i := 1 to SL.Count - 1 do
    begin
      if length(SL.Strings[i]) > mx then
      begin
        mx := length(SL.Strings[i]);
        idx := i;
      end;
    end;

    Cn.Font.Name := 'Courier New';
    Cn.Font.Style := [fsbold];
    siz := 6;
    repeat
      Cn.Font.Size := siz;
      inc(siz);
      ty := Cn.TextHeight(SL.Strings[idx]);
      tx := Cn.TextWidth(SL.Strings[idx]);
    until tx > 0.7 * Box.Width;
    xb := (Box.Width - tx) div 2;

    y0 := R.Bottom - 4 - (SL.Count * ty + 4);

    Cn.Brush.Style := bsClear;
    R1 := Rect(R.Left + 4, y0, R.Right - 4, R.Bottom - 4);
    Cn.Pen.Color := clBlack;
    Cn.Rectangle(R1);

    for i := 0 to SL.Count - 1 do
    begin
      Cn.TextRect(R1, xb, y0 + 2 + i * ty, SL.Strings[i]);
    end;

    Cn.Rectangle(R);
  end;
end;

class procedure TBaseELineForm.PaintTxtBox(Box: TPaintBox; Cl1, Cl2: TColor; Str: String);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(Str);
    PaintTxtBox(Box, Cl1, Cl2, SL);
  finally
    SL.Free;
  end;
end;

class procedure TBaseELineForm.PaintTxtBox(Box: TPaintBox; Cl1, Cl2: TColor; Strs: Strings);
var
  SL: TStringList;
  i: integer;
begin
  SL := TStringList.Create;
  try
    for i := 0 to length(Strs) - 1 do
    begin
      SL.Add(Strs[i]);
    end;
    PaintTxtBox(Box, Cl1, Cl2, SL);
  finally
    SL.Free;
  end;
end;

class procedure TBaseELineForm.PaintTxtBox(Box: TPaintBox; Cl1, Cl2: TColor; SL: TStrings);
var
  Cn: TCanvas;
  R: TRect;
  R1: TRect;
  tx, ty: integer;
  xb: integer;
  siz: integer;
  i, mx, idx: integer;
  y0: integer;
  NN: integer;
begin
  Cn := Box.Canvas;
  R := Rect(0, 0, Box.Width, Box.Height);

  Cn.Brush.Style := bsSolid;
  Cn.Brush.Color := Cl1;
  Cn.FillRect(R);

  Cn.Brush.Style := bsClear;
  R1 := R;
  R1.Inflate(4, 4);
  Cn.Rectangle(R1);

  NN := SL.Count;
  if NN > 0 then
  begin
    mx := length(SL.Strings[0]);
    idx := 0;
    for i := 1 to NN - 1 do
    begin
      if length(SL.Strings[i]) > mx then
      begin
        mx := length(SL.Strings[i]);
        idx := i;
      end;
    end;

    Cn.Font.Name := 'Courier New';
    Cn.Font.Style := [fsbold];
    siz := 6;
    repeat
      Cn.Font.Size := siz;
      inc(siz);
      ty := Cn.TextHeight(SL.Strings[idx]);
      tx := Cn.TextWidth(SL.Strings[idx]);
    until (tx > 0.7 * Box.Width) or (ty * NN > 0.9 * Box.Height);
    y0 := (R.Height - NN * ty) div 2;

    Cn.Font.Color := Cl2;

    for i := 0 to NN - 1 do
    begin
      tx := Cn.TextWidth(SL.Strings[i]);
      xb := (Box.Width - tx) div 2;
      Cn.TextRect(R1, xb, y0 , SL.Strings[i]);
      y0 := y0 + ty;
    end;

    Cn.Rectangle(R);
  end;
end;

end.
