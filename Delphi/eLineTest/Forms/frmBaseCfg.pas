unit frmBaseCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  System.Actions, Vcl.ActnList, Vcl.Grids, System.UITypes,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CfgBinUtils,
  CmmObjDefinition;

type
  TBaseCfgForm = class(TBaseELineForm)
    BottomPanel: TPanel;
    CheckButton: TButton;
    SaveBtn: TBitBtn;
    OpenBtn: TBitBtn;
    BaseActionList: TActionList;
    SendAct: TAction;
    ReadAct: TAction;
    ReadButton: TButton;
    SendButton: TButton;
    ChangesBtn: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ReadActUpdate(Sender: TObject);
    procedure ReadActExecute(Sender: TObject);
    procedure SendActUpdate(Sender: TObject);
    procedure SendActExecute(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure ChangesBtnClick(Sender: TObject);
    procedure ChangesBtnContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure OpenBtnClick(Sender: TObject);

  protected
    mRSett: TCfgTool;
    function getDefaultExt: string; virtual; abstract;
    function getFileFilter: string; virtual; abstract;


  protected
    procedure DrawColorStringGridCell(grid: TStringGrid; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
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

procedure TBaseCfgForm.FormCreate(Sender: TObject);
begin
  inherited;
  mRSett := TCfgTool.Create;
end;

procedure TBaseCfgForm.FormDestroy(Sender: TObject);
begin
  inherited;
  mRSett.Free;
end;

procedure TBaseCfgForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := 'Konfiguracja:' + mELineDev.getCpxName;
  BringUp;
end;

procedure TBaseCfgForm.ChangesBtnClick(Sender: TObject);
var
  n: Integer;
begin
  inherited;
  n := mRSett.getDifferencesCount(MainFormMsgOut);
  if n = 0 then
    Application.MessageBox('Brak ró¿nic z konfiguracj¹ orginaln¹', 'Konfiguracja', MB_OK)
  else
    Application.MessageBox(pchar(format('Jest %d ró¿nic(a)', [n])), 'Konfiguracja', MB_OK)
end;

procedure TBaseCfgForm.ChangesBtnContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
  mRSett.clearChangesSign;
end;

procedure TBaseCfgForm.BringUp;
begin
  mRSett.clearWControls;
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgGetCfg));
end;

procedure TBaseCfgForm.RecivedObj(obj: TKobj);
var
  st: byte;
begin
  if (obj.srcDev = dsdDEV_COMMON) then
  begin
    if (obj.obCode = ord(msgGetCfg)) then
    begin
      mRSett.loadValBuf(MainFormMsgOut, obj.data);
      //mRSett.loadValBuf(nil, obj.data);
    end;
    if (obj.obCode = ord(msgSetCfg)) then
    begin
      st := obj.data[0];
      if st = stOK then
      begin
        Application.MessageBox('Konfiguracja wys³ana', pchar(mELineDev.getCpxName), MB_OK);
        mRSett.AckChanges;
      end
      else
        Application.MessageBox(pchar(format('B³¹d podczas wysy³ania konfiguracji: %d', [st])),
          pchar(mELineDev.getCpxName), MB_OK or MB_ICONERROR);
    end;

  end;
end;

procedure TBaseCfgForm.ReadActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := mELineDev.IsConnected;
end;

procedure TBaseCfgForm.ReadActExecute(Sender: TObject);
begin
  inherited;
  BringUp;
end;

procedure TBaseCfgForm.SendActUpdate(Sender: TObject);
begin
  inherited;
  (Sender as TAction).Enabled := mELineDev.IsConnected;
end;

procedure TBaseCfgForm.OpenBtnClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  inherited;
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := getDefaultExt;
    Dlg.Filter := getFileFilter;
    if Dlg.Execute then
    begin
      mRSett.LoadFromFile(Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;

end;

procedure TBaseCfgForm.SaveBtnClick(Sender: TObject);
var
  Dlg: TSaveDialog;
begin
  inherited;
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := getDefaultExt;
    Dlg.Filter := getFileFilter;

    if Dlg.Execute then
    begin
      mRSett.SaveToFile(mELineDev.getDevTypeName, Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;

end;

procedure TBaseCfgForm.SendActExecute(Sender: TObject);
var
  buf: TBytes;
begin
  inherited;
  buf := mRSett.getDifferences;
  if buf <> nil then
    mELineDev.addReqest(dsdDEV_COMMON, ord(msgSetCfg), buf)
  else
    Application.MessageBox('Brak zmian', 'Konfiguracja', MB_OK);
end;

procedure TBaseCfgForm.DrawColorStringGridCell(grid: TStringGrid; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  txt: string;
begin
  if Assigned(grid.Objects[ACol, ARow]) then
  begin
    grid.Canvas.Brush.Color := TColorRec.Cyan;
    grid.Canvas.FillRect(Rect);
    grid.Canvas.Font.Color := TColorRec.Blue;
    txt := grid.Cells[ACol, ARow];
    grid.Canvas.TextRect(Rect, txt);
  end;

end;

end.
