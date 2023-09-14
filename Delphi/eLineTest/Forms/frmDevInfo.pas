unit frmDevInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit,
  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition;

type
  TDevInfoForm = class(TBaseELineForm)
    VL: TValueListEditor;
    procedure VLDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;

  end;

implementation

{$R *.dfm}

procedure TDevInfoForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  caption := 'DevInfo:' + mELineDev.getCpxName;
  BringUp;
end;

procedure TDevInfoForm.VLDblClick(Sender: TObject);
begin
  inherited;
  BringUp;
end;

procedure TDevInfoForm.BringUp;
begin
  VL.Strings.Clear;
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgDevInfo));
end;

procedure TDevInfoForm.RecivedObj(obj: TKobj);
var
  DevInfo: TKDevInfo;
begin
  if (obj.srcDev = dsdDEV_COMMON) and (obj.obCode = ord(msgDevInfo)) then
  begin
    if length(obj.data) = sizeof(DevInfo) then
    begin
      move(obj.data[0], DevInfo, sizeof(DevInfo));

      VL.Values['IP'] := mELineDev.getIp;
      VL.Values['Type'] := DevInfo.getDevTypAsStr;
      VL.Values['HardwareVer'] := IntToStr(DevInfo.hdwVer);

      VL.Values['Firmware'] := DevInfo.firmVer.getAsFullString;
      VL.Values['SerialNumber'] := DevInfo.getSerialNr;
      VL.Values['DeviceID'] := DevInfo.getDevID;
      if DevInfo.getDevType = elTYP_KP then
      begin
        VL.Values['Tester hamulców'] := DevInfo.getActivBreaksLRStr;
        VL.Values['Tester amorty.'] := DevInfo.getActivSuspensLRStr;
        VL.Values['Zbie¿noœæ'] := DevInfo.getActivSlipSideStr;
        VL.Values['Waga'] := DevInfo.getActivWeightLRStr;
      end
      else if DevInfo.getDevType = elTYP_HOST then
      begin

      end;
    end
    else
    begin
      Application.MessageBox('Niepoprawna struktra: TKDevInfo',pchar(caption),MB_OK or MB_ICONERROR);
    end;
  end;
end;

end.
