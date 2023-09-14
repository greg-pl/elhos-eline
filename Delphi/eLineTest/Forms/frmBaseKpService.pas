unit frmBaseKpService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, System.Actions, Vcl.ActnList, System.ImageList,
  Vcl.ImgList, Vcl.ToolWin, Vcl.ExtCtrls,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  CmmObjDefinition,
  eLineDef,
  KpDevUnit;

type
  TBaseKpServForm = class(TBaseELineForm)
    ToolBar1: TToolBar;
    ImageList1: TImageList;
    ActionList1: TActionList;
    actRUN: TAction;
    RunToolButton: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    RunTimer: TTimer;
    procedure actRUNUpdate(Sender: TObject);
    procedure actRUNExecute(Sender: TObject);
    procedure RunTimerTimer(Sender: TObject);
    procedure actShowKalibrExecute(Sender: TObject);
  private
    mService: TKPService.T;
  private type
    TBaseKpServFormClass = class of TBaseKpServForm;
  public // TBaseELineForm
    procedure setELineDev(aDev: TBaseELineDev); override;

  private
    procedure OnKalibrDone(buf: TBytes);
  protected
    procedure doStartStop(run: boolean); virtual;
    function getStartMode: byte; virtual;
  public
    property Service: TKPService.T read mService;
    function KpDev: TKpDev;
    procedure setService(serv: TKPService.T);
    procedure StartKalibracji(PkName, UnitName: string; PkNr: integer; var KalibVal: single);
    procedure RecivedObj(obj: TKobj); override;
  protected
    procedure ReciveMeasData(dt: TBytes); virtual;
    procedure ReciveMeasDataErrCfg(dt: TBytes); virtual;
    procedure RecivedServiceObj(obCode: integer; dt: TBytes); virtual;
  public
    class function findForm(Dev: TBaseELineDev; serv: TKPService.T): TBaseKpServForm;
    class function ExecKpServiceForm(ParenForm: TForm; aClass: TBaseKpServFormClass; aDev: TBaseELineDev;
      serv: TKPService.T): TBaseELineForm;
    class procedure closeDevForms(aDev: TKpDev; serv: TKPService.T);

  end;

implementation

{$R *.dfm}

uses
  Main;

function TBaseKpServForm.KpDev: TKpDev;
begin
  Result := mELineDev as TKpDev;
end;

procedure TBaseKpServForm.setService(serv: TKPService.T);
begin
  inherited;
  mService := serv;
end;

procedure TBaseKpServForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := TKPService.getServNameHid(Service) + ' : ' + KpDev.getCpxName;
end;

class function TBaseKpServForm.findForm(Dev: TBaseELineDev; serv: TKPService.T): TBaseKpServForm;
var
  i: integer;
  Form: TForm;
begin
  Result := nil;
  for i := 0 to Application.MainForm.MDIChildCount - 1 do
  begin
    Form := Application.MainForm.MDIChildren[i];
    if Form is TBaseKpServForm then
    begin
      if ((Form as TBaseKpServForm).KpDev = Dev) and ((Form as TBaseKpServForm).Service = serv) then
      begin
        Result := Form as TBaseKpServForm;
        break;
      end;
    end;
  end;
end;

class function TBaseKpServForm.ExecKpServiceForm(ParenForm: TForm; aClass: TBaseKpServFormClass; aDev: TBaseELineDev;
  serv: TKPService.T): TBaseELineForm;
var
  Form: TBaseKpServForm;
begin
  Form := findForm(aDev, serv);
  if Assigned(Form) then
  begin
    Form.BringToFront;
    Form.BringUp;
  end
  else
  begin
    Form := aClass.Create(ParenForm);
    Form.setService(serv);
    Form.setELineDev(aDev);
    Form.Show;
  end;
  Result := Form;
end;

procedure TBaseKpServForm.RunTimerTimer(Sender: TObject);
begin
  inherited;
  KpDev.sendRunMeasure(mService, true, 0);
end;

procedure TBaseKpServForm.doStartStop(run: boolean);
begin

end;

function TBaseKpServForm.getStartMode: byte;
begin
  Result := 0;
end;

procedure TBaseKpServForm.actRUNExecute(Sender: TObject);
var
  mode: byte;
begin
  inherited;
  actRUN.Checked := not actRUN.Checked;
  RunToolButton.Down := actRUN.Checked;
  RunTimer.Enabled := actRUN.Checked;
  mode := 0;
  if actRUN.Checked then
    mode := getStartMode;
  KpDev.sendRunMeasure(mService, actRUN.Checked, mode);
  doStartStop(actRUN.Checked);
end;

procedure TBaseKpServForm.actRUNUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := KpDev.IsConnected;
end;

procedure TBaseKpServForm.actShowKalibrExecute(Sender: TObject);
begin
  inherited;
  PostMessage(Application.MainForm.Handle, wm_showKalibr, integer(KpDev), ord(Service));
end;

class procedure TBaseKpServForm.closeDevForms(aDev: TKpDev; serv: TKPService.T);
var
  Form: TBaseKpServForm;
begin
  Form := findForm(aDev, serv);
  if Assigned(Form) then
    Form.Close;
end;

// ----------------------------------------

procedure TBaseKpServForm.OnKalibrDone(buf: TBytes);
var
  kalibPtNr: byte;
  st: TKStatus.T;
  s: string;
begin
  kalibPtNr := buf[0];
  st := TKStatus.getCode(buf[1]);
  s := format('Wykonano kalibracjê dla punktu KP=%u', [kalibPtNr]) + #13;
  s := s + 'Wynik: ' + TKStatus.getTxt(st);

  Application.MessageBox(pchar(s), pchar(Caption), Mb_OK)
end;

procedure TBaseKpServForm.ReciveMeasData(dt: TBytes);
begin

end;

procedure TBaseKpServForm.ReciveMeasDataErrCfg(dt: TBytes);
begin

end;

procedure TBaseKpServForm.RecivedServiceObj(obCode: integer; dt: TBytes);
begin

end;

procedure TBaseKpServForm.RecivedObj(obj: TKobj);
  procedure ReciveCfgError(errCode: byte);
  begin
    Application.MessageBox('Niepoprawna konfiguracja', pchar(Caption), Mb_OK or MB_ICONERROR);
  end;

begin
  if obj.srcDev = KpDev.getTrkDev(mService) then
  begin
    case obj.obCode of
      ord(msgMakeKalibr):
        OnKalibrDone(obj.data);
      ord(msgMeasData):
        ReciveMeasData(obj.data);
      ord(msgMeasDataNoCfg):
        ReciveMeasDataErrCfg(obj.data);
      ord(msgCfgError):
        ReciveCfgError(obj.data[0]);
    else
      RecivedServiceObj(obj.obCode, obj.data);
    end;
  end;
end;

procedure TBaseKpServForm.StartKalibracji(PkName, UnitName: string; PkNr: integer; var KalibVal: single);
var
  Prompt: string;
  Devname: string;
  s: string;
begin
  Devname := TKPService.getServNameHid(Service) + ' : ' + KpDev.getCpxName;
  Prompt := format('Kalibracja punktu %s. Podaj wartoœæ [%s]', [PkName, UnitName]);
  s := format('%.3f', [KalibVal]);
  if InputQuery(Devname, Prompt, s) then
  begin
    KalibVal := StrToFloat(s);
    KpDev.sendRunKalibr(Service, PkNr, KalibVal);

  end;
end;

end.
