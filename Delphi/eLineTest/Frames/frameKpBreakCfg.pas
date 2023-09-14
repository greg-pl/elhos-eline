unit frameKpBreakCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Registry;

type
  TKpBreaksCfgFrame = class(TFrame)
    LiczP1ManuBtn: TButton;
    LiczP1Btn: TButton;
    SpeedBitBox: TComboBox;
    PressBitBox: TComboBox;
    AnInpNrBox: TComboBox;
    AktivBox: TCheckBox;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    ParametryRolki_GroupBox: TGroupBox;
    DiameterEdit: TLabeledEdit;
    ImpCnt: TLabeledEdit;
    Kalibr_GroupBox: TGroupBox;
    RollKalibrInfoText: TLabel;
    Z0CloseEdit: TLabeledEdit;
    P1ValEdit: TLabeledEdit;
    P1KalibrEdit: TLabeledEdit;
    Z0OpenEdit: TLabeledEdit;
    procedure LiczP1BtnClick(Sender: TObject);
  private

  public
    KalibQuqlity: integer;
  end;

implementation

{$R *.dfm}

uses
  MyUtils,
  eLineTestDef,
  eLineDef,
  dlgTypLiniiSelect;




procedure TKpBreaksCfgFrame.LiczP1BtnClick(Sender: TObject);

  function LiczP1(Wspol: double): single;
  var
    wspR: double;
    wartFiz: double;
  begin
    wartFiz := StrToFloat(P1ValEdit.Text);

    wspR := Wspol / 100;

    if wartFiz >= 0 then
      Result := 100 * wartFiz * wspR + StrToFloat(Z0OpenEdit.Text)
    else
      Result := 100 * wartFiz * wspR + StrToFloat(Z0CloseEdit.Text)
  end;

var
  Wspol: double;
  s1: string;
  dlg: TTypLiniselectDlg;
  doIt: boolean;
  txt: string;

begin
  Wspol := 1;
  if Sender = LiczP1Btn then
  begin
    dlg := TTypLiniselectDlg.Create(self);
    try
      doIt := (dlg.ShowModal = mrOK);
      if doIt then
      begin
        if dlg.typLini = 0 then
          Wspol := TGlobRegistry.ReadWspol('WspUrzRollCi_1', 0.01179)
        else
          Wspol := TGlobRegistry.ReadWspol('WspUrzRollOs_1', 0.00172);
      end;
    finally
      dlg.Free;
    end;
  end
  else
  begin
    Wspol := TGlobRegistry.ReadWspol('WspUrzRoll_Manu', 0.00172);

    s1 := FloatToStr(Wspol);
    doIt := InputQuery('Kalibracja', 'Podaj wspó³czynnik A', s1);
    if doIt then
    begin
      Wspol := StrToFloat(s1);
      TGlobRegistry.WriteWspol('WspUrzRoll_Manu', Wspol);
    end;
  end;

  if doIt then
  begin
    KalibQuqlity := CALIBR_BY_FUN;
    P1KalibrEdit.Text := FloatToStr(LiczP1(Wspol));
    txt := 'Kalibracja punktu P1 zosta³a wykonana' + #13 + format('U¿yty wspo³czynnik A=%.8f', [Wspol]);
    Application.MessageBox(pchar(txt), 'Kalibracja P1', mb_OK);

  end
end;

end.
