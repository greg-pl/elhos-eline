unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.Contnrs,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, Vcl.Menus,
  Vcl.ExtCtrls, Vcl.StdCtrls,
  ConfigUdpUnit,
  DevDefinitionUnit,
  CmmObjDefinition,
  BaseDevCmmUnit,
  Base64Tools,
  NetToolsUnit,
  eLineDef, Vcl.Buttons;

const
  wm_showKalibr = wm_user + 200;

type
  TMainForm = class(TForm)
    ImageList1: TImageList;
    ToolBar: TToolBar;
    HideSendingBtn: TToolButton;
    ToolButton5: TToolButton;
    ToolButton3: TToolButton;
    ToolButton9: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton4: TToolButton;
    ToolButton8: TToolButton;
    ToolButton6: TToolButton;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    RunButton: TToolButton;
    ActionList1: TActionList;
    actFindDev: TAction;
    Memo1: TMemo;
    BottomSplitter: TSplitter;
    MainMenu1: TMainMenu;
    Pliki1: TMenuItem;
    LanguageItem: TMenuItem;
    WritteLngFileItem: TMenuItem;
    N1: TMenuItem;
    ExitItem: TMenuItem;
    CardsItem: TMenuItem;
    Lista1: TMenuItem;
    CardsLiniaItem: TMenuItem;
    ServiceItem: TMenuItem;
    Lista2: TMenuItem;
    ServiceLiniaItem: TMenuItem;
    StatusBar: TStatusBar;
    TV: TTreeView;
    Splitter2: TSplitter;
    BottomPanel: TPanel;
    Panel2: TPanel;
    ClrMemoBtn: TButton;
    TreePopUpMenu: TPopupMenu;
    actConnect: TAction;
    actDisconnect: TAction;
    LeftPanel: TPanel;
    Panel1: TPanel;
    NrKeyEdit: TLabeledEdit;
    TypKeyGroup: TRadioGroup;
    TreeImageList: TImageList;
    actDelete: TAction;
    ToolButton2: TToolButton;
    actCloseAll: TAction;
    actCascade: TAction;
    actCloseAllButOne: TAction;
    actSetHorizontal: TAction;
    actSetVertical: TAction;
    actShowDevPanel: TAction;
    actDelAllDev: TAction;
    ShowFramesBtn: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actFindDevUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actFindDevExecute(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
    procedure ClrMemoBtnClick(Sender: TObject);
    procedure TVDeletion(Sender: TObject; Node: TTreeNode);
    procedure TVDblClick(Sender: TObject);
    procedure TreePopUpMenuPopup(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actConnectUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure TVGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure TVGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actCloseAllButOneUpdate(Sender: TObject);
    procedure actCloseAllUpdate(Sender: TObject);
    procedure actCascadeExecute(Sender: TObject);
    procedure actSetVerticalExecute(Sender: TObject);
    procedure actSetHorizontalExecute(Sender: TObject);
    procedure actCloseAllButOneExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure actShowDevPanelExecute(Sender: TObject);
    procedure actShowDevPanelUpdate(Sender: TObject);
    procedure actDelAllDevUpdate(Sender: TObject);
    procedure actDelAllDevExecute(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure TVKeyPress(Sender: TObject; var Key: Char);
  private type
    TObjArray = array of TObject;

    TStatusFrameList = class(TObjectList)
      function findDev(Dev: TBaseELineDev): integer;
      function findFrame(Dev: TBaseELineDev): TFrame;
    end;

  private
    // UDP
    ConfigUdp: TConfigUdp;
    procedure OnDeviceIpDefProc(Sender: TObject; IP: string; Port: Word; SerNum, ip2, mask, gate, devId: string);
    procedure OnDeviceFoundProc(Sender: TObject; IP, SerNum, DevType, devId: string);
    procedure OnDeviceRebootProc(Sender: TObject; IP, SerNum: string);
    procedure OnListenEndProc(Sender: TObject);
    // procedure wmERASEBKGND(var Msg: TMessage); message WM_ERASEBKGND;
  private
    globCnt: integer;
    StatusFrameList: TStatusFrameList;
    procedure loadFromReg;
    procedure saveToReg;
    procedure OnStatuFrameClose(Sender: TObject);
  protected
    function VV(Key: String): string;

  private
    // TcpSvr
    procedure OnReciveObjNotifyProc(Sender: TObject);
    procedure OnConnectedProc(Sender: TObject);
    procedure OnDeviceRdyProc(Sender: TObject);

  private
    procedure wmShowKalibr(var AMessage: TMessage); message wm_showKalibr;

    // TV
    procedure BuildTreePopUpMenu(Objs: TObjArray);
    procedure AddDeviceChildNodes(Node: TTreeNode; obj: TBaseELineDev);
    procedure DeleteDevice(Dev: TBaseELineDev);
    procedure RefreshNode(Dev: TBaseELineDev);
    procedure AddElineDev(foDevType: TElineDevType.T; IP, SerNum, devId: string);

    function FindELineDevByIP(aIP: string): TBaseELineDev;
    function FindELineDevByDevID(devTyp: TElineDevType.T; aDevID: string): TBaseELineDev;
    function FindNodeByElineDev(Dev: TBaseELineDev): TTreeNode;

  public
    procedure Wr(s: string);
    function ProducerMode: boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  UdpSocketUnit,
  MyUtils,
  frmBaseELineUnit,
  frmCfgHistory,
  frmPing,
  frmDevInfo,
  HostDevUnit,
  KPDevUnit,
  SensDevUnit,

  frmSerialNum,
  frmUpgrade,

  frmKeyLog,
  frmHostCfg,
  frmHostTestHdw,
  frmHostTestPilot,
  frmHostFalowniki,

  frameKpStatusBar,
  frmKPCfg,
  frmKpTest,
  frmBaseKpService,
  frmServBreaks,
  frmServSuspension,
  frmServSlipSide,
  frmServWeight,

  frmSensCfg,
  frmSensorTest,

  eLineTestDef,
  MyRegistryUnit;

type
  TFunCode = ( //
    funINFO = 6, //
    funCFG, //
    funHIST_CFG, //
    funRESET, //
    funPING, //
    funUPGRADE, //
    funEDIT_SN, //

    funHOST_TEST, //
    funHOST_FALOWNIKI, //
    funHOST_PILOT, //
    funHOST_KEY_LOG, //

    funKP_TEST, //
    funKP_SERVICES, //

    funKP_BREAK_L, //
    funKP_BREAK_R, //
    funKP_SUSP_L, //
    funKP_SUSP_R, //
    funKP_SLIP_SIDE, //
    funKP_WEIGHT_L, //
    funKP_WEIGHT_R, //

    funSENSOR_TEST, //

    funMAX);

  TFunObj = class(TObject)
    Fun: TFunCode;
    constructor Create(aFun: TFunCode);
    class function getServiceCode(serv: TKPService.T): TFunCode;
  end;

constructor TFunObj.Create(aFun: TFunCode);
begin
  inherited Create;
  Fun := aFun;
end;

class function TFunObj.getServiceCode(serv: TKPService.T): TFunCode;
begin
  case serv of
    uuBREAK_L:
      Result := funKP_BREAK_L;
    uuBREAK_R:
      Result := funKP_BREAK_R;
    uuSUSP_L:
      Result := funKP_SUSP_L;
    uuSUSP_R:
      Result := funKP_SUSP_R;
    uuSLIP_SIDE:
      Result := funKP_SLIP_SIDE;
    uuWEIGHT_L:
      Result := funKP_WEIGHT_L;
    uuWEIGHT_R:
      Result := funKP_WEIGHT_R;
  else
    raise Exception.Create('TFunObj: no defined');
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  StatusFrameList := TStatusFrameList.Create(false);

  ConfigUdp := TConfigUdp.Create;
  ConfigUdp.OnDeviceIpDef := OnDeviceIpDefProc;
  ConfigUdp.OnDeviceFound := OnDeviceFoundProc;
  ConfigUdp.OnDeviceReboot := OnDeviceRebootProc;
  ConfigUdp.OnListenEnd := OnListenEndProc;

  globCnt := 1100;
  loadFromReg;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  saveToReg;
  ConfigUdp.Free;
  StatusFrameList.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ConfigUdp.Open;
  BottomPanel.Top := StatusBar.Top - BottomPanel.Height;
  BottomSplitter.Top := BottomPanel.Top - BottomSplitter.Height;
end;

procedure TMainForm.Wr(s: string);
begin
  Memo1.lines.add(s);
end;

function TMainForm.VV(Key: String): string;
begin
  Result := Key;
end;

{
  procedure TMainForm.wmERASEBKGND(var Msg: TMessage);
  // var
  // MyDC: hDC;
  begin
  // MyDC := TWMEraseBkGnd(Msg).DC;
  // BitBlt(MyDC, Co * Image1.Picture.Width, Ro * Image1.Picture.Height, Image1.Picture.Width, Image1.Picture.Height,
  // Image1.Picture.Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
  end;
}



// ---------------------------------------------------------------------------
// UdpConfig
// ---------------------------------------------------------------------------

procedure TMainForm.actFindDevExecute(Sender: TObject);
var
  st: TStatus;
  SL: TStrings;
  i: integer;
begin
  SL := TSimpUdp.GetIPs;
  for i := 0 to SL.Count - 1 do
    Wr(SL.Strings[i]);
  SL.Free;
  st := ConfigUdp.BrodcastFind;
  if st <> 0 then
    Application.MessageBox(pchar(Format('B³¹d nadania komunikatu, code=%d', [st])), 'ZnajdŸ', mb_OK or MB_ICONERROR);

  TV.SetFocus;
end;

procedure TMainForm.actFindDevUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ConfigUdp.IsConnected;
end;

procedure TMainForm.actSetHorizontalExecute(Sender: TObject);
begin
  TileMode := tbVertical;
  Tile;
end;

procedure TMainForm.actSetVerticalExecute(Sender: TObject);
begin
  TileMode := tbVertical;
  Tile;
end;

procedure TMainForm.OnDeviceIpDefProc(Sender: TObject; IP: string; Port: Word; SerNum, ip2, mask, gate, devId: string);
begin
  Wr(Format('DeviceIpDef', []));
end;

procedure TMainForm.OnDeviceRebootProc(Sender: TObject; IP, SerNum: string);
begin
  Wr(Format('DeviceReboot', []));
end;

procedure TMainForm.OnListenEndProc(Sender: TObject);
begin
  Wr('ListenEnd');

end;

procedure TMainForm.OnDeviceFoundProc(Sender: TObject; IP, SerNum, DevType, devId: string);
var
  Dev: TBaseELineDev;
  txt: string;
  foDevType: TElineDevType.T;
  s: string;
begin
  foDevType := TElineDevType.getDevType(DevType);

  Dev := FindELineDevByIP(IP);
  if Assigned(Dev) then
  begin
    if Dev.DevState.DevInfo.getDevType <> foDevType then
    begin
      s := Format('Zmieniana typu urz¹dzenia o IP: ', [IP]) + #13;
      s := s + 'Usuwam stare i tworze nowe';

      Application.MessageBox(pchar(s), 'Zmiana', mb_OK);
      DeleteDevice(Dev);
      AddElineDev(foDevType, IP, SerNum, devId);
    end
    else
    begin
      if Dev.DevState.DevInfo.getDevID <> devId then
      begin
        // zmiana DevID urz¹dzenia
        Dev.setDevID(devId);
        RefreshNode(Dev);
        txt := 'DEVID_CHD';
      end
      else
      begin
        txt := 'OK';
      end;
    end;
  end
  else
  begin
    Dev := FindELineDevByDevID(foDevType, devId);
    if Assigned(Dev) then
    begin
      s := Format('%s zmieni³ swoje IP', [Dev.getCpxName]);
      Application.MessageBox(pchar(s), 'Zmiana IP', mb_OK);
      txt := 'CHG_IP';
      Dev.setIp(IP);
      RefreshNode(Dev);
    end
    else
    begin
      txt := 'NEW';
      AddElineDev(foDevType, IP, SerNum, devId);
    end;
  end;
  Wr(Format('DeviceFound: %s NS=%s IP=%s Typ=%s  ID=%s', [txt, SerNum, IP, DevType, devId]));
end;

procedure TMainForm.ClrMemoBtnClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TMainForm.loadFromReg;
var
  Reg: TMyRegistry;
begin
  Reg := TMyRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, false) then
    begin
      if Reg.ValueExists('Top') then
        Top := Reg.ReadInteger('Top');
      if Reg.ValueExists('Left') then
        Left := Reg.ReadInteger('Left');
      if Reg.ValueExists('Height') then
        Height := Reg.ReadInteger('Height');
      if Reg.ValueExists('Width') then
        Width := Reg.ReadInteger('Width');

      if Reg.ValueExists('LeftPanel_W') then
        LeftPanel.Width := Reg.ReadInteger('LeftPanel_W');
      if Reg.ValueExists('BotPanel_H') then
        BottomPanel.Height := Reg.ReadInteger('BotPanel_H');

      if Reg.ValueExists('TypKlucza') then
        TypKeyGroup.ItemIndex := Reg.ReadInteger('TypKlucza');
      if Reg.ValueExists('NrKlucza') then
        NrKeyEdit.text := Reg.ReadString('NrKlucza');
    end;

  finally
    Reg.Free;
  end;

end;

procedure TMainForm.saveToReg;
var
  Reg: TMyRegistry;
begin
  Reg := TMyRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, true) then
    begin
      if WindowState = wsNormal then
      begin
        Reg.WriteInteger('Top', Top);
        Reg.WriteInteger('Left', Left);
        Reg.WriteInteger('Height', Height);
        Reg.WriteInteger('Width', Width);
      end;
      Reg.WriteInteger('LeftPanel_W', LeftPanel.Width);
      Reg.WriteInteger('BotPanel_H', BottomPanel.Height);
      Reg.WriteInteger('TypKlucza', TypKeyGroup.ItemIndex);
      Reg.WriteString('NrKlucza', NrKeyEdit.text);

    end;
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
  Memo1.SelectAll;
  Memo1.CopyToClipboard;
  Memo1.SelLength := 0;
end;

function TMainForm.ProducerMode: boolean;
begin
  Result := (TypKeyGroup.ItemIndex = 1);
end;

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  b1: TBytes;
  b2: TBytes;
  stt: ansiString;
  i, k, j, n: integer;
  USek1: TMicroSekTime;
  USek2: TMicroSekTime;
begin
  USek1 := TMicroSekTime.Create('T1');
  USek2 := TMicroSekTime.Create('T2');
  try
    for k := 8000 to 10000 do
    begin
      setlength(b1, k);
      for j := 0 to k - 1 do
      begin
        b1[j] := Random(256);
      end;

      USek1.Start;
      stt := EncodeBase64(b1);
      USek1.Stop;
      USek2.Start;
      b2 := DecodeBase64(stt);
      USek2.Stop;

      if length(b1) = length(b2) then
      begin
        n := length(b1);
        for i := 0 to n - 1 do
        begin
          if b1[i] <> b2[i] then
          begin
            Wr('B³¹d');
            exit;
          end;
        end;
      end
      else
      begin
        Wr('B³¹d 2');
        exit;

      end;
      Wr(Format('K=%u t1=%u t2=%u', [k, USek1.getDeltaAsUSek, USek2.getDeltaAsUSek]))
    end;
    Wr('Koniec');
  finally
    USek1.Free;
    USek2.Free;
  end;

end;

procedure TMainForm.OnConnectedProc(Sender: TObject);
begin
  TV.Refresh;
end;

procedure TMainForm.OnDeviceRdyProc(Sender: TObject);
  function FindNode(ParentNode: TTreeNode; code: TFunCode): TTreeNode;
  var
    n: TTreeNode;
    obj: TObject;
    fobj: TFunObj;
  begin
    Result := nil;
    n := ParentNode.getFirstChild;
    while Assigned(n) do
    begin
      obj := TObject(n.Data);
      if obj is TFunObj then
      begin
        fobj := (obj as TFunObj);
        if fobj.Fun = code then
        begin
          Result := n;
          break;
        end;
      end;
      n := n.getNextSibling;
    end;
  end;

  function FindChildNode(ParentNode: TTreeNode; serv: TKPService.T): TTreeNode;
  var
    n: TTreeNode;
    obj: TObject;
    FunCode: TFunCode;
  begin
    Result := nil;
    FunCode := TFunObj.getServiceCode(serv);

    n := ParentNode.getFirstChild;
    while Assigned(n) do
    begin
      obj := TObject(n.Data);
      if obj is TFunObj then
      begin
        if (obj as TFunObj).Fun = FunCode then
        begin
          Result := n;
          break;
        end;

      end;
      n := n.getNextSibling;
    end;
  end;

  procedure AddServiceNode(ParentNode: TTreeNode; serv: TKPService.T);
  var
    FunCode: TFunCode;
  begin
    FunCode := TFunObj.getServiceCode(serv);
    TV.Items.AddChildObject(ParentNode, TKPService.getServNameHid(serv), TFunObj.Create(FunCode));
  end;

var
  Dev: TBaseELineDev;
  KpDev: TKpDev;
  Node: TTreeNode;
  SrvNode: TTreeNode;
  chNode: TTreeNode;
  serv: TKPService.T;
begin
  Dev := Sender as TBaseELineDev;
  Node := FindNodeByElineDev(Dev);
  SrvNode := FindNode(Node, funKP_SERVICES);
  if Dev is TKpDev then
  begin
    KpDev := Dev as TKpDev;
    for serv := low(TKPService.T) to high(TKPService.T) do
    begin
      chNode := FindChildNode(SrvNode, serv);
      if KpDev.isService(serv) then
      begin
        if not Assigned(chNode) then
          AddServiceNode(SrvNode, serv);
      end
      else
      begin
        if Assigned(chNode) then
        begin
          TBaseKpServForm.closeDevForms(KpDev, serv);
          chNode.Free;
        end;
      end;
    end;
  end;
  TV.Refresh;
end;

procedure TMainForm.OnReciveObjNotifyProc(Sender: TObject);
var
  i: integer;
  obj: TKobj;
  s1: string;
  EForm: TBaseELineForm;
  Dev: TBaseELineDev;
  frame: TKpStatusFrame;
begin
  Dev := Sender as TBaseELineDev;

  while Dev.popRecKobj(obj) do
  begin
    for i := 0 to MDIChildCount - 1 do
    begin
      if MDIChildren[i] is TBaseELineForm then
      begin
        EForm := (MDIChildren[i] as TBaseELineForm);
        if EForm.isThisDev(Sender) then
          EForm.RecivedObj(obj);
      end;
    end;
    if ShowFramesBtn.Down then
    begin
      Wr(Format('OBJ: Dev=%u code=%d n=%d %s', [ord(obj.srcDev), ord(obj.obCode), length(obj.Data), s1]));
    end;
    // Skasowanie obiektu !!!
    obj.Free;
  end;

  frame := StatusFrameList.findFrame(Dev) as TKpStatusFrame;
  if Assigned(frame) then
    frame.UpDateFrame;

end;

// TREE---------------------------------------------------------------------------

procedure TMainForm.AddDeviceChildNodes(Node: TTreeNode; obj: TBaseELineDev);
begin
  if obj is TBaseELineDev then
  begin
    Node.text := obj.getCpxName;
    TV.Items.AddChildObject(Node, 'Info', TFunObj.Create(funINFO));
    TV.Items.AddChildObject(Node, 'Konfiguracja', TFunObj.Create(funCFG));
    TV.Items.AddChildObject(Node, 'Historia konfiguracji', TFunObj.Create(funHIST_CFG));
    TV.Items.AddChildObject(Node, 'Reset', TFunObj.Create(funRESET));
    TV.Items.AddChildObject(Node, 'Ping', TFunObj.Create(funPING));
    if (obj is THostDev) or (obj is TKpDev) then
      TV.Items.AddChildObject(Node, 'Upgrade', TFunObj.Create(funUPGRADE));

    if ProducerMode then
    begin
      TV.Items.AddChildObject(Node, 'Numer seryjny', TFunObj.Create(funEDIT_SN));
    end;

    if obj is THostDev then
    begin
      TV.Items.AddChildObject(Node, 'Test hardware', TFunObj.Create(funHOST_TEST));
      TV.Items.AddChildObject(Node, 'Falowniki', TFunObj.Create(funHOST_FALOWNIKI));
      TV.Items.AddChildObject(Node, 'Test pilota', TFunObj.Create(funHOST_PILOT));
      TV.Items.AddChildObject(Node, 'Poka¿ dane KeyLog', TFunObj.Create(funHOST_KEY_LOG));

    end
    else if obj is TKpDev then
    begin

      // dodawane po DeviceReady
      TV.Items.AddChildObject(Node, 'Test', TFunObj.Create(funKP_TEST));
      TV.Items.AddChildObject(Node, 'Us³ugi', TFunObj.Create(funKP_SERVICES));
    end
    else if obj is TSensDev then
    begin
      TV.Items.AddChildObject(Node, 'Pomiary', TFunObj.Create(funSENSOR_TEST));
    end;

  end;

end;

procedure TMainForm.DeleteDevice(Dev: TBaseELineDev);
var
  Node: TTreeNode;
begin
  TBaseELineForm.closeDevForms(Dev);
  Node := FindNodeByElineDev(Dev);
  Node.Free;
end;

procedure TMainForm.RefreshNode(Dev: TBaseELineDev);
begin

end;

procedure TMainForm.AddElineDev(foDevType: TElineDevType.T; IP, SerNum, devId: string);
var
  Dev: TBaseELineDev;
  Node: TTreeNode;
begin
  case foDevType of
    elTYP_HOST:
      Dev := THostDev.Create;
    elTYP_KP:
      Dev := TKpDev.Create;
    elTYP_SENS_F, elTYP_SENS_P:
      Dev := TSensDev.Create;
  else
    Dev := TBaseELineDev.Create;
  end;
  Dev.setDevID(devId);
  Dev.setDevSerNum(SerNum);
  Dev.setIp(IP);
  Dev.OnReciveObjNotify := OnReciveObjNotifyProc;
  Dev.OnConnectedNotify := OnConnectedProc;
  Dev.OnDeviceRdyNotify := OnDeviceRdyProc;

  if Assigned(Dev) then
  begin
    Node := TV.Items.AddObject(nil, Dev.getCpxName, Dev);
    AddDeviceChildNodes(Node, Dev);
  end;

end;

procedure TMainForm.BuildTreePopUpMenu(Objs: TObjArray);
var
  i: integer;
  Item: TMenuItem;
begin
  TreePopUpMenu.Items.Clear;
  for i := 0 to length(Objs) - 1 do
  begin
    Item := TMenuItem.Create(TreePopUpMenu);
    if Assigned(Objs[i]) then
    begin
      Item.Action := Objs[i] as TAction;
    end
    else
      Item.Caption := '-';
    TreePopUpMenu.Items.add(Item);
  end;
end;

function TMainForm.TStatusFrameList.findDev(Dev: TBaseELineDev): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TKpStatusFrame).Dev = Dev then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TMainForm.TStatusFrameList.findFrame(Dev: TBaseELineDev): TFrame;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (Items[i] as TKpStatusFrame).Dev = Dev then
    begin
      Result := Items[i] as TKpStatusFrame;
      break;
    end;
  end;
end;

procedure TMainForm.actShowDevPanelUpdate(Sender: TObject);
var
  obj: TObject;
  Dev: TBaseELineDev;
  q: boolean;
begin
  q := false;
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      q := (StatusFrameList.findDev(Dev) < 0);
    end;
  end;
  (Sender as TAction).Enabled := q;
end;

procedure TMainForm.actShowDevPanelExecute(Sender: TObject);
var
  Pan: TPanel;
  frame: TKpStatusFrame;
  obj: TObject;
  Dev: TBaseELineDev;
begin
  Dev := nil;
  if Assigned(TV.Selected) then
  begin
    if Assigned(TV.Selected.Data) then
    begin
      obj := TObject(TV.Selected.Data);
      if obj is TBaseELineDev then
        Dev := (obj as TBaseELineDev);
    end;
  end;
  if Assigned(Dev) then
  begin
    if StatusFrameList.findDev(Dev) < 0 then
    begin

      Pan := TPanel.Create(self);
      Pan.Parent := self;
      Pan.Align := alTop;
      Pan.Top := ToolBar.Top + ToolBar.Height;
      Pan.Caption := '';
      Pan.BevelOuter := bvLowered;
      Pan.Height := 32;

      frame := TKpStatusFrame.Create(self);
      frame.Parent := Pan;
      frame.Align := alClient;
      frame.Name := 'KpFrame' + IntToStr(GetTickCount);
      frame.setDev(Dev);
      frame.onClose := OnStatuFrameClose;
      StatusFrameList.add(frame);
    end;

  end;
end;

procedure TMainForm.OnStatuFrameClose(Sender: TObject);
var
  idx: integer;
begin
  idx := StatusFrameList.IndexOf(Sender);
  if idx >= 0 then
    StatusFrameList.Delete(idx);
end;

procedure TMainForm.TreePopUpMenuPopup(Sender: TObject);
var
  Node: TTreeNode;
  X, Y: integer;
  menu: TObjArray;
  obj: TObject;
begin
  X := TV.ScreenToClient(TreePopUpMenu.PopupPoint).X;
  Y := TV.ScreenToClient(TreePopUpMenu.PopupPoint).Y;
  Node := TV.GetNodeAt(X, Y);
  TV.ClearSelection(false);
  if Node <> nil then
    TV.Selected := Node;

  menu := [actFindDev, nil, actFindDev];
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TFunObj then
    begin
      menu := [];
    end
    else if obj is TBaseELineDev then
    begin
      menu := [actConnect, actDisconnect, nil, actShowDevPanel, nil, actDelete];
      if obj is TKpDev then
      begin

      end;
    end;
  end;
  BuildTreePopUpMenu(menu);
end;

procedure TMainForm.TVDblClick(Sender: TObject);
  procedure rebootDev(aDev: TBaseELineDev);
  begin
    if Application.MessageBox('Czy wykonaæ restart ?', pchar(aDev.getCpxName), MB_YESNO) = idYES then
    begin
      aDev.makeReboot;
    end;
  end;

var
  obj: TObject;
  Fun: TFunCode;
  pNode: TTreeNode;
  Dev: TBaseELineDev;
begin
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TFunObj then
    begin
      Fun := (obj as TFunObj).Fun;
      pNode := TV.Selected.Parent;
      obj := TObject(pNode.Data);
      if obj is TFunObj then
      begin
        // wprzypadku serwisów jest jedno zagnie¿dzeie wiêcej
        pNode := pNode.Parent;
        obj := TObject(pNode.Data);
      end;

      if obj is TBaseELineDev then
      begin
        Dev := (obj as TBaseELineDev);
        case Fun of
          funINFO:
            TBaseELineForm.ExecElineForm(self, TDevInfoForm, Dev);
          funCFG:
            begin
              if Dev is THostDev then
                TBaseELineForm.ExecElineForm(self, THostCfgForm, Dev)
              else if Dev is TKpDev then
                TBaseELineForm.ExecElineForm(self, TKPCfgForm, Dev)
              else if Dev is TSensDev then
                TBaseELineForm.ExecElineForm(self, TSensCfgForm, Dev);
            end;
          funHIST_CFG:
            TBaseELineForm.ExecElineForm(self, TCfgHistoryForm, Dev);
          funRESET:
            rebootDev(Dev);
          funPING:
            TBaseELineForm.ExecElineForm(self, TPingForm, Dev);
          funUPGRADE:
            TBaseELineForm.ExecElineForm(self, TUpgradeForm, Dev);
          funEDIT_SN:
            TBaseELineForm.ExecElineForm(self, TSerialNumform, Dev);

          funHOST_KEY_LOG:
            TBaseELineForm.ExecElineForm(self, TKeyLogform, Dev);
          funHOST_TEST:
            TBaseELineForm.ExecElineForm(self, THostTestHdwForm, Dev);
          funHOST_FALOWNIKI:
            TBaseELineForm.ExecElineForm(self, THostFalownikiForm, Dev);
          funHOST_PILOT:
            TBaseELineForm.ExecElineForm(self, THostTestPilotForm, Dev);

          funKP_TEST:
            TBaseELineForm.ExecElineForm(self, TKpTestForm, Dev);
          funKP_BREAK_L:
            TBaseKpServForm.ExecKpServiceForm(self, TServBreakForm, Dev, uuBREAK_L);
          funKP_BREAK_R:
            TBaseKpServForm.ExecKpServiceForm(self, TServBreakForm, Dev, uuBREAK_R);
          funKP_SUSP_L:
            TBaseKpServForm.ExecKpServiceForm(self, TServSuspensionForm, Dev, uuSUSP_L);
          funKP_SUSP_R:
            TBaseKpServForm.ExecKpServiceForm(self, TServSuspensionForm, Dev, uuSUSP_R);
          funKP_SLIP_SIDE:
            TBaseKpServForm.ExecKpServiceForm(self, TServSlipSideForm, Dev, uuSLIP_SIDE);
          funKP_WEIGHT_L:
            TBaseKpServForm.ExecKpServiceForm(self, TServWeightForm, Dev, uuWEIGHT_L);
          funKP_WEIGHT_R:
            TBaseKpServForm.ExecKpServiceForm(self, TServWeightForm, Dev, uuWEIGHT_R);

          funSENSOR_TEST:
            TBaseELineForm.ExecElineForm(self, TSensorTestForm, Dev);
          funMAX:
            ;

        end;

      end;

    end
    else if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      if Dev.IsConnected then
        Dev.DisConnect
      else
        Dev.Connect;
    end;
  end;
end;

procedure TMainForm.wmShowKalibr(var AMessage: TMessage);
var
  Dev: TBaseELineDev;
  service: TKPService.T;
  KPCfgForm: TKPCfgForm;
begin

  Dev := TBaseELineDev(AMessage.WParam);

  if Dev is THostDev then
  begin
    TBaseELineForm.ExecElineForm(self, THostCfgForm, Dev);
  end
  else if Dev is TKpDev then
  begin
    service := TKPService.T(AMessage.LParam);
    KPCfgForm := TBaseELineForm.ExecElineForm(self, TKPCfgForm, Dev) as TKPCfgForm;
    KPCfgForm.showService(service);
  end
  else if Dev is TSensDev then
  begin
    TBaseELineForm.ExecElineForm(self, TSensCfgForm, Dev);
  end

end;

procedure TMainForm.TVDeletion(Sender: TObject; Node: TTreeNode);
var
  obj: TObject;
begin
  if Assigned(Node.Data) then
  begin
    obj := TObject(Node.Data);
    if obj is TBaseELineDev then
      TBaseELineForm.closeDevForms(obj as TBaseELineDev);
    obj.Free;
  end;
end;

procedure TMainForm.TVGetImageIndex(Sender: TObject; Node: TTreeNode);
var
  idx: integer;
  obj: TObject;

begin
  try
    idx := -1;
    if Assigned(Node) then
      if Assigned(Node.Data) then
      begin
        obj := TObject(Node.Data);
        if obj is TBaseELineDev then
        begin
          if (obj as TBaseELineDev).IsConnected then
            idx := 1
          else
            idx := 0;
        end
        else
        begin
          idx := ord((obj as TFunObj).Fun);
        end;
      end;
  except
    idx := -1;
  end;

  Node.ImageIndex := idx;
end;

procedure TMainForm.TVGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TMainForm.TVKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    TVDblClick(Sender);

end;

function TMainForm.FindELineDevByIP(aIP: string): TBaseELineDev;
var
  n: TTreeNode;
  AN: TBaseELineDev;
  aIPBin: cardinal;
begin
  Result := nil;
  n := TV.Items.GetFirstNode;
  if StrToIP(aIP, aIPBin) then
  begin
    while Assigned(n) do
    begin
      if n.Data <> Nil Then
      begin
        if TObject(n.Data) is TBaseELineDev then
        begin
          AN := TObject(n.Data) as TBaseELineDev;
          if AN.getIpBin = aIPBin then
          begin
            Result := AN;
            break;
          end;
        end;
      end;
      n := n.GetNext;
    end;
  end;
end;

function TMainForm.FindELineDevByDevID(devTyp: TElineDevType.T; aDevID: string): TBaseELineDev;
var
  n: TTreeNode;
  Dev: TBaseELineDev;
begin
  Result := nil;
  n := TV.Items.GetFirstNode;
  while Assigned(n) do
  begin
    if n.Data <> Nil Then
    begin
      if TObject(n.Data) is TBaseELineDev then
      begin
        Dev := TObject(n.Data) as TBaseELineDev;
        if (Dev.DevState.DevInfo.getDevType = devTyp) and (Dev.DevState.DevInfo.getDevID = aDevID) then
        begin
          Result := Dev;
          break;
        end;
      end;
    end;
    n := n.GetNext;
  end;
end;

function TMainForm.FindNodeByElineDev(Dev: TBaseELineDev): TTreeNode;
var
  n: TTreeNode;
begin
  Result := nil;
  n := TV.Items.GetFirstNode;
  while Assigned(n) do
  begin
    if n.Data <> Nil Then
    begin
      if n.Data = Dev then
      begin
        Result := n;
        break;
      end;
    end;
    n := n.GetNext;
  end;
end;

procedure TMainForm.actConnectUpdate(Sender: TObject);
var
  obj: TObject;
  Dev: TBaseELineDev;
  q: boolean;
begin
  q := false;
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      q := not Dev.IsConnected;
    end;
  end;
  (Sender as TAction).Enabled := q;
end;

procedure TMainForm.actCascadeExecute(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.actCloseAllButOneExecute(Sender: TObject);
var
  i: integer;
begin
  for i := MDIChildCount - 1 downto 1 do
  begin
    MDIChildren[i].Close;
  end;
end;

procedure TMainForm.actCloseAllButOneUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (MDIChildCount > 1);
end;

procedure TMainForm.actCloseAllExecute(Sender: TObject);
var
  i: integer;
begin
  for i := MDIChildCount - 1 downto 0 do
  begin
    MDIChildren[i].Close;
  end;
end;

procedure TMainForm.actCloseAllUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (MDIChildCount > 0);
end;

procedure TMainForm.actConnectExecute(Sender: TObject);
var
  obj: TObject;
  Dev: TBaseELineDev;
begin
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      Dev.Connect;
    end;
  end;
end;

procedure TMainForm.actDisconnectUpdate(Sender: TObject);
var
  obj: TObject;
  Dev: TBaseELineDev;
  q: boolean;
begin
  q := false;
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      q := Dev.IsConnected;
    end;
  end;
  (Sender as TAction).Enabled := q;
end;

procedure TMainForm.actDisconnectExecute(Sender: TObject);
var
  obj: TObject;
  Dev: TBaseELineDev;
begin
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      Dev.DisConnect;
    end;
  end;
end;

procedure TMainForm.actDeleteUpdate(Sender: TObject);
var
  obj: TObject;
  q: boolean;
begin
  q := false;
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    q := (obj is TBaseELineDev);
  end;
  (Sender as TAction).Enabled := q;
end;

procedure TMainForm.actDelAllDevExecute(Sender: TObject);
begin
  if Application.MessageBox('Czy chcesz usun¹æ wszystkie urz¹dzenia ?', 'Usuwanie', MB_YESNO) = idYES then
  begin
    while TV.Items.Count > 0 do
    begin
      TV.Items[0].Free;
    end;
  end;
end;

procedure TMainForm.actDelAllDevUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := TV.Items.Count > 0;
end;

procedure TMainForm.actDeleteExecute(Sender: TObject);
var
  obj: TObject;
  Dev: TBaseELineDev;
begin
  if Assigned(TV.Selected) and Assigned(TV.Selected.Data) then
  begin
    obj := TObject(TV.Selected.Data);
    if obj is TBaseELineDev then
    begin
      Dev := obj as TBaseELineDev;
      DeleteDevice(Dev);
    end;
  end;
end;

end.
