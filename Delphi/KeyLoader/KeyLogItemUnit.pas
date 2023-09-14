unit KeyLogItemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, KeyLoaderDef;

type

  TKeyLogItemForm = class(TForm)
    ModeBox: TRadioGroup;
    ValidCntEdit: TLabeledEdit;
    ValidDateEdit: TDateTimePicker;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure ModeBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetKeyLogItem(KeyNr: integer; item: TKeyLogData);
    function GetKeyLogItem: TKeyLogData;
  end;

implementation

{$R *.dfm}

procedure TKeyLogItemForm.ModeBoxClick(Sender: TObject);
var
  en: boolean;
begin
  en := (ModeBox.ItemIndex = 2);
  ValidDateEdit.Enabled := en;
  ValidCntEdit.Enabled := en;
end;

procedure TKeyLogItemForm.SetKeyLogItem(KeyNr: integer; item: TKeyLogData);
begin
  Caption := Format('Klucz numer %u', [KeyNr]);
  if item.Mode > 2 then
    item.Mode := 0;
  ModeBox.ItemIndex := item.Mode;
  if item.ValidCnt = $FFFF then
    item.ValidCnt := 0;
  ValidCntEdit.Text := IntToStr(item.ValidCnt);

  if (item.ValidDate <> 0) and (item.ValidDate <> $FFFF) then
    ValidDateEdit.Date := UnpackDate(item.ValidDate)
  else
    ValidDateEdit.Date := now;
  ModeBoxClick(nil);
end;

function TKeyLogItemForm.GetKeyLogItem: TKeyLogData;
begin
  Result.Mode := ModeBox.ItemIndex;
  Result.ValidCnt := StrToInt(ValidCntEdit.Text);
  Result.ValidDate := PackDate(ValidDateEdit.Date);
end;

end.
