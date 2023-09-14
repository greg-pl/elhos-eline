unit dlgKalibrWagiSelect;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Registry;

type

  TKalibrWagiSelectDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ValueEdit: TLabeledEdit;
    PointNrBox: TComboBox;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure PointNrBoxChange(Sender: TObject);
  private
    TabWeight: array of single;
    function FGetNrPunktu: integer;
    procedure FSetNrPunktu(Nr: integer);
    function FGetValFiz: single;
  public
    property valFiz: single read FGetValFiz;
    property nrPunktu: integer read FGetNrPunktu write FSetNrPunktu;
    procedure setCaption(cap: string);

  end;

implementation

{$R *.dfm}

uses
  eLineTestDef;

procedure TKalibrWagiSelectDlg.FormCreate(Sender: TObject);
begin
  TabWeight := [0, 100, 200, 500, 1000, 2000];
end;

procedure TKalibrWagiSelectDlg.setCaption(cap: string);
begin
  Caption := cap;
end;

procedure TKalibrWagiSelectDlg.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Registry: TRegistry;
  s: string;
  SL: TStringList;
  i: integer;
begin
  Action := caFree;
  SL := TStringList.Create;
  try
    for i := 0 to 5 do
    begin
      SL.Add(FloatToStr(TabWeight[i]));
    end;
    s := SL.CommaText;
  finally
    SL.Free;
  end;

  Registry := TRegistry.Create;
  try
    if Registry.OpenKey(REG_KEY, true) then
    begin
      Registry.WriteString('WeightTab', s);
    end;
  finally
    Registry.Free;
  end;
end;

procedure TKalibrWagiSelectDlg.FormShow(Sender: TObject);
var
  Registry: TRegistry;
  s: string;
  SL: TStringList;
begin
  Registry := TRegistry.Create;
  try
    if Registry.OpenKey(REG_KEY, false) then
    begin
      if Registry.ValueExists('WeightTab') then
      begin
        s := Registry.ReadString('WeightTab');
        SL := TStringList.Create;
        try
          SL.CommaText := s;
        finally
          SL.Free;
        end;
      end;
    end;
  finally
    Registry.Free;
  end;

end;

procedure TKalibrWagiSelectDlg.FSetNrPunktu(Nr: integer);
begin
  PointNrBox.ItemIndex := Nr;
end;

procedure TKalibrWagiSelectDlg.OKBtnClick(Sender: TObject);
begin
  TabWeight[FGetNrPunktu] := FGetValFiz;
end;

procedure TKalibrWagiSelectDlg.PointNrBoxChange(Sender: TObject);
begin
  ValueEdit.Text := FormatFloat('00.0',TabWeight[FGetNrPunktu]);
end;

function TKalibrWagiSelectDlg.FGetNrPunktu: integer;
begin
  result := PointNrBox.ItemIndex;
end;

function TKalibrWagiSelectDlg.FGetValFiz: single;
begin
  result := StrToFloat(ValueEdit.Text);

end;

end.
