unit frameKpSuspensCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus,
  Vcl.StdCtrls, VclTee.TeEngine, VclTee.Series, Vcl.ExtCtrls, VclTee.TeeProcs,
  VclTee.Chart, Vcl.Grids;

type
  TKpSuspensCfgFrame = class(TFrame)
    Label4: TLabel;
    Label8: TLabel;
    AmorKalibrInfoText: TLabel;
    AktivBox: TCheckBox;
    AnInpBox: TComboBox;
    DeadBandEdit: TLabeledEdit;
    GroupBox5: TGroupBox;
    L0MeasValEdit: TLabeledEdit;
    L0FizValEdit: TLabeledEdit;
    L1MeasValEdit: TLabeledEdit;
    L1FizValEdit: TLabeledEdit;
    PGrid: TStringGrid;
    Chart: TChart;
    Series1: TLineSeries;
    LiczP1Btn: TButton;
    ReturnTimeEdit: TLabeledEdit;
    procedure PGridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure LiczP1BtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    KalibQuqlity: Integer;
    constructor Create(AOwner: TComponent); override;
    procedure UpdateChart;
  end;

implementation

{$R *.dfm}

uses
  MyUtils,
  eLineDef;

constructor TKpSuspensCfgFrame.Create(AOwner: TComponent);
begin
  inherited;
  PGrid.Rows[0].CommaText := 'lp. Masa[kg] Wart.zmierzona[%]';
  PGrid.Cols[0].CommaText := 'lp. 1 2 3 4 5 6';
end;

procedure TKpSuspensCfgFrame.PGridSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
begin
  UpdateChart;
end;

procedure TKpSuspensCfgFrame.UpdateChart;
  function IncWeight(mx: double): double;
  begin
    if mx<2000 then
      Result := 2000
    else if mx<5000 then
      Result := 5000
    else if mx<10000 then
      Result := 10000
    else
      Result := 1.2 *mx;


  end;

var
  i: Integer;
  m, pr: double;
  mx: double;
  add: boolean;
begin
  Series1.Clear;
  mx := 1000;

  for i := 0 to PGrid.RowCount - 1 do
  begin

    if TryStrtoFloat(PGrid.Cells[1, i + 1], m) and TryStrtoFloat(PGrid.Cells[2, i + 1], pr) then
    begin
      add := true;
      if (m = 0) and (pr = 0) and (i <> 0) then
        add := false;
      if add then
      begin
        Series1.AddXY(m, pr);
        if m > mx then
          mx := IncWeight(m);
      end;
    end;
  end;
  Chart.BottomAxis.Maximum := mx;
end;

procedure TKpSuspensCfgFrame.LiczP1BtnClick(Sender: TObject);

  function LiczL1(Wspol: double): single;
  var
    wartFizL0: double;
    wartFizL1: double;
    wartZmierzL0: double;
  begin

    wartFizL0 := StrToFloat(L0FizValEdit.Text);
    wartFizL1 := StrToFloat(L1FizValEdit.Text);
    wartZmierzL0 := StrToFloat(L0MeasValEdit.Text);

    Result := (wartFizL1 - wartFizL0) * Wspol + wartZmierzL0;
  end;

  function LiczW1(Wspol: double): single;
  var
    wartFizL0: double;
    wartFizL1: double;
    wartZmierzL0: double;
  begin
    wartFizL0 := StrToFloat(PGrid.Cells[1, 1]);
    wartFizL1 := StrToFloat(PGrid.Cells[1, 2]);
    wartZmierzL0 := StrToFloat(PGrid.Cells[2, 1]);
    Result := (wartFizL1 - wartFizL0) * Wspol + wartZmierzL0;
  end;

var
  Wspol_L: double;
  Wspol_W: double;
  i: Integer;
  txt: string;
begin
  Wspol_L := TGlobRegistry.ReadWspol('WspUrzAmorL', 0.20995);
  Wspol_W := TGlobRegistry.ReadWspol('WspUrzAmorW', 0.02084);
  // wyliczenie punktu L1
  L1MeasValEdit.Text := FloatToStr(LiczL1(Wspol_L));

  // wyliczenie punktu W1

  for i := 3 to PGrid.RowCount - 1 do
  begin
    PGrid.Cells[1, i] := '';
    PGrid.Cells[2, i] := '';
  end;
  PGrid.Cells[2, 2] := FloatToStr(LiczW1(Wspol_W));

  KalibQuqlity := CALIBR_BY_FUN;

  txt := 'Obliczenia zosta³y wykonane' + #13;
  txt := txt + Format('Wychylenie: wspó³czynnik: A=%.7f', [Wspol_L]) + #13;
  txt := txt + Format('Waga: wspó³czynnik: A=%.7f', [Wspol_W]);

  Application.MessageBox(pchar(txt), 'Kalibracja ', mb_OK);
end;

end.
