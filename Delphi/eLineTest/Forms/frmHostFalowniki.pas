unit frmHostFalowniki;

interface

uses
  System.UITypes, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Vcl.ComCtrls,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition,
  HostDevUnit,
  frameHostFalownik;

type
  THostFalownikiForm = class(TBaseELineForm)
    Fal1Frame: THostFalownikFrame;
    Fal2Frame: THostFalownikFrame;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    procedure TabSheet1Resize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure OnClickFalProc(Sender: THostFalownikFrame; Fun: integer);
    function hostDev: THostDev;
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}

procedure THostFalownikiForm.FormCreate(Sender: TObject);
begin
  inherited;
  Fal1Frame.NameLab.Caption := 'Lewy';
  Fal2Frame.NameLab.Caption := 'Prawy';
  Fal1Frame.OnClickFal := OnClickFalProc;
  Fal2Frame.OnClickFal := OnClickFalProc;
end;

function THostFalownikiForm.hostDev: THostDev;
begin
  result := mELineDev as THostDev;
end;

procedure THostFalownikiForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := 'HosTest :' + mELineDev.getCpxName;
  BringUp;
end;

procedure THostFalownikiForm.TabSheet1Resize(Sender: TObject);
var
  w: integer;
begin
  inherited;
  w := (Sender as TTabSheet).Width;
  Fal1Frame.Width := w div 2;
end;

procedure THostFalownikiForm.BringUp;
begin
  inherited;

end;

procedure THostFalownikiForm.OnClickFalProc(Sender: THostFalownikFrame; Fun: integer);
begin
  if Sender = Fal1Frame then
    hostDev.SendFalownikReq(falNR1, TFalownikCmd(Fun));
  if Sender = Fal2Frame then
    hostDev.SendFalownikReq(falNR2, TFalownikCmd(Fun));
end;

procedure THostFalownikiForm.RecivedObj(obj: TKobj);
var
  frame: THostFalownikFrame;
  FRply: TKFalownikCmd;
begin
  if (obj.srcDev = dsdHOST) then
  begin
    case obj.obCode of
      ord(msgHostSterFalownik):
        begin
          move(obj.data[0], FRply, sizeof(FRply));
          

          case FRply.falNr of
            ord(falNR1):
              frame := Fal1Frame;
            ord(falNR2):
              frame := Fal2Frame;
          else
            frame := nil
          end;
          if Assigned(frame) then
          begin
            frame.AckCommand(frply.falCmd, frply.status)
          end;
        end;
    end;
  end;
end;

end.
