unit frameKpStatusBar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  frmBaseKpService,

  MyUtils,
  CmmObjDefinition,
  BaseDevCmmUnit,
  eLineDef,
  KpDevUnit, Vcl.ExtCtrls;

type
  TKpStatusFrame = class(TFrame)
    CloseBtn: TButton;
    MsgCntEdit: TLabeledEdit;
    procedure CloseBtnClick(Sender: TObject);
  private
    mDev: TBaseELineDev;
  public
    onClose : TNotifyEvent;
    procedure setDev(Dev: TBaseELineDev);
    property Dev: TBaseELineDev read mDev;
    procedure UpDateFrame;
  end;

implementation

{$R *.dfm}

procedure TKpStatusFrame.CloseBtnClick(Sender: TObject);
begin
  if Assigned(onClose) then
    onClose(self);
  Parent.Free;
end;

procedure TKpStatusFrame.setDev(Dev: TBaseELineDev);
begin
  mDev := Dev;
end;

procedure TKpStatusFrame.UpDateFrame;
begin
 MsgCntEdit.Text := IntToStr(mDev.DevState.msgCnt);

end;


end.
