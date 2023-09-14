unit frmSerialNum;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.StdCtrls, Vcl.ExtCtrls,
  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition;

type
  TSerialNumForm = class(TBaseELineForm)
    NumerSerEdit: TLabeledEdit;
    SendBtn: TButton;
    procedure SendBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}

uses
  MyUtils,
  NetToolsUnit;

procedure TSerialNumForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := 'Serial numer:' + mELineDev.getCpxName;
  BringUp;
end;

procedure TSerialNumForm.BringUp;
begin
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgGetSerialNum));

end;

procedure TSerialNumForm.RecivedObj(obj: TKobj);
var
  st: byte;
begin
  if (obj.srcDev = dsdDEV_COMMON) then
  begin
    if (obj.obCode = ord(msgGetSerialNum)) then
    begin
      NumerSerEdit.Text := TBytesTool.ToStr(obj.data);
    end
    else if (obj.obCode = ord(msgSetSerialNum)) then
    begin
      st := obj.data[0];
      if st = stOK then
        Application.MessageBox('Numer Ustawiony', pchar(mELineDev.getCpxName), MB_OK)
      else
        Application.MessageBox(pchar(format('B³¹d podczas ustawiania numeru: %d', [st])), pchar(mELineDev.getCpxName),
          MB_OK or MB_ICONERROR);
    end;
  end;

end;

procedure TSerialNumForm.SendBtnClick(Sender: TObject);
var
  buf: TBytes;
begin
  inherited;
  buf := TBytesTool.FromString(NumerSerEdit.Text);
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgSetSerialNum), buf);
end;

end.
