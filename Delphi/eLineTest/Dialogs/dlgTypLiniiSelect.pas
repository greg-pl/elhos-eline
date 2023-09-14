unit dlgTypLiniiSelect;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Registry;

type
  TTypLiniselectDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    TypLiniiGroup: TRadioGroup;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OKBtnClick(Sender: TObject);
  private
    function FGetTypLinii: integer;
    procedure FSetTypLinii(tt: integer);
  public
    property typLini: integer read FGetTypLinii write FSetTypLinii;
  end;

implementation

{$R *.dfm}

uses
  eLineTestDef;

function TTypLiniselectDlg.FGetTypLinii: integer;
begin
  result := TypLiniiGroup.ItemIndex;
end;

procedure TTypLiniselectDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TTypLiniselectDlg.FormShow(Sender: TObject);
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    if Registry.OpenKey(REG_KEY, false) then
    begin
      if Registry.ValueExists('TypLiniiSelect') then
        FSetTypLinii(Registry.ReadInteger('TypLiniiSelect'));
    end;
  finally
    Registry.Free;
  end;

end;

procedure TTypLiniselectDlg.FSetTypLinii(tt: integer);
begin
  TypLiniiGroup.ItemIndex := tt;
end;

procedure TTypLiniselectDlg.OKBtnClick(Sender: TObject);
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    if Registry.OpenKey(REG_KEY, true) then
    begin
      Registry.WriteInteger('TypLiniiSelect', FGetTypLinii);
    end;
  finally
    Registry.Free;
  end;
end;



end.
