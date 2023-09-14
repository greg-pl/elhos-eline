unit Rfm69Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  Vcl.ComCtrls, Vcl.ToolWin, SkanerCmmUnit, InterRsd, Registry, Vcl.Menus,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, System.UITypes, Vcl.Samples.Spin,
  Vcl.Grids, MMSystem,
  U_USB,
  eLineDef;

const
  SZ_KEY_CNT = 8;
  ELINE_KEY_CNT = 10;

type
  TMainForm = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ActionList1: TActionList;
    ImageList2: TImageList;
    actOpen: TAction;
    StatusBar: TStatusBar;
    ComListMenu: TPopupMenu;
    Memo1: TMemo;
    Splitter1: TSplitter;
    actClear: TAction;
    actRun: TAction;
    LV: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    ClrMemoBtn: TButton;
    ToolButton5: TToolButton;
    actSave: TAction;
    actLoad: TAction;
    ToolButton7: TToolButton;
    colHead1Btn: TToolButton;
    colHead2Btn: TToolButton;
    colHead3Btn: TToolButton;
    colHead4Btn: TToolButton;
    ToolButton8: TToolButton;
    colMostBtn: TToolButton;
    CmdBox: TComboBox;
    Panel3: TPanel;
    RssiMostEdit: TLabeledEdit;
    RssiHead1Edit: TLabeledEdit;
    RssiHead2Edit: TLabeledEdit;
    RssiHead3Edit: TLabeledEdit;
    RssiHead4Edit: TLabeledEdit;
    MainPageControl: TPageControl;
    GeoSheet: TTabSheet;
    UniSheet: TTabSheet;
    ToolBar2: TToolBar;
    UniLV: TListView;
    ToolBar3: TToolBar;
    actSendCfg: TAction;
    actCfg: TAction;
    ToolButton23: TToolButton;
    HideSendingBtn: TToolButton;
    actHideSending: TAction;
    UniSendPanel: TPanel;
    Label2: TLabel;
    UniSplitter: TSplitter;
    GeoSplitter: TSplitter;
    GeoSendPanel: TPanel;
    Label3: TLabel;
    ToolButton24: TToolButton;
    RunButton: TToolButton;
    ToolButton3: TToolButton;
    ToolButton9: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    UniSenderEdit: TSpinEdit;
    ToolButton2: TToolButton;
    UniStringGrid: TStringGrid;
    Panel4: TPanel;
    actLedPulse: TAction;
    ToolButton4: TToolButton;
    UniSendSlotNrBox: TComboBox;
    Label1: TLabel;
    ToolButton6: TToolButton;
    SzarpakSheet: TTabSheet;
    SzBtnLampShape: TShape;
    SzBtnOnOffShape: TShape;
    SzBtnDownShape: TShape;
    SzBtnUPShape: TShape;
    SzBtnLeftShape: TShape;
    SzBtnRightShape: TShape;
    SzBtnOpc1Shape: TShape;
    SzBtnOpc2Shape: TShape;
    Shape9: TShape;
    Panel5: TPanel;
    SarpakDtGrid: TStringGrid;
    SzLampShape: TShape;
    Label4: TLabel;
    SzSendMsgNoBeepBtn: TButton;
    SzSendMsgBeepBtn: TButton;
    actSzPilotMsgNoBeep: TAction;
    actSzPilotMsgBeep: TAction;
    actSzPilotMsgBeep2: TAction;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    actSzLampOn: TAction;
    actSzLampOff: TAction;
    Label5: TLabel;
    Label6: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    actSzSterowMsgNoBeep: TAction;
    actSzSterowMsgBeep: TAction;
    actSzSterowMsg2Beep: TAction;
    Button7: TButton;
    actSzPilotSetCh: TAction;
    SzSetUpChannelBox: TComboBox;
    sLine: TTabSheet;
    Panel6: TPanel;
    Shape1: TShape;
    elineBtn8Shape: TShape;
    elineBtn3Shape: TShape;
    elineBtn6Shape: TShape;
    elineBtn2Shape: TShape;
    elineBtn1Shape: TShape;
    elineBtn5Shape: TShape;
    elineBtn7Shape: TShape;
    elineBtn4Shape: TShape;
    ELineDataGrid: TStringGrid;
    Label7: TLabel;
    Label8: TLabel;
    elineBtn10Shape: TShape;
    elineBtn9Shape: TShape;
    elineLampShape: TShape;
    elineBtn8Txt: TLabel;
    elineBtn10Txt: TLabel;
    elineBtn9Txt: TLabel;
    elineBtn7Txt: TLabel;
    elineBtn6Txt: TLabel;
    elineBtn4Txt: TLabel;
    elineBtn5Txt: TLabel;
    elineBtn1Txt: TLabel;
    elineBtn2Txt: TLabel;
    elineBtn3Txt: TLabel;
    eLineColorRetTimer: TTimer;
    ELineMsgMemo: TMemo;
    Button8: TButton;
    actELineGetPilotInfo: TAction;
    Button9: TButton;
    actELinePilotClrCounters: TAction;
    Button10: TButton;
    actELineSetChannelNr: TAction;
    actELinePilotGoSleep: TAction;
    Button11: TButton;
    eLineReturnWorkChannelTimer: TTimer;
    actELinePilotGoSleepSetup: TAction;
    Button12: TButton;
    procedure actOpenExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComListMenuPopup(Sender: TObject);
    procedure actOpenUpdate(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure LVCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure ClrMemoBtnClick(Sender: TObject);
    procedure ThreadInfoBtnClick(Sender: TObject);
    procedure colHead1BtnClick(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure actLoadUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CmdBoxChange(Sender: TObject);
    procedure actSendCfgUpdate(Sender: TObject);
    procedure actCfgExecute(Sender: TObject);
    procedure actHideSendingExecute(Sender: TObject);
    procedure GeoSheetShow(Sender: TObject);
    procedure UniSheetShow(Sender: TObject);
    procedure MainPageControlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure actCfgUpdate(Sender: TObject);
    procedure UniLVCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure UniSenderEditChange(Sender: TObject);
    procedure UniStringGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure actLedPulseUpdate(Sender: TObject);
    procedure actLedPulseExecute(Sender: TObject);
    procedure actSendCfgExecute(Sender: TObject);
    procedure actSzPilotMsgBeepUpdate(Sender: TObject);
    procedure actSzPilotMsgBeepExecute(Sender: TObject);
    procedure actSzPilotMsgNoBeepExecute(Sender: TObject);
    procedure actSzPilotMsgBeep2Execute(Sender: TObject);
    procedure actSzLampOnExecute(Sender: TObject);
    procedure actSzLampOffExecute(Sender: TObject);
    procedure actSzSterowMsgNoBeepExecute(Sender: TObject);
    procedure actSzSterowMsgBeepExecute(Sender: TObject);
    procedure actSzSterowMsg2BeepExecute(Sender: TObject);
    procedure actSzPilotSetChExecute(Sender: TObject);
    procedure eLineColorRetTimerTimer(Sender: TObject);
    procedure actELineGetPilotInfoUpdate(Sender: TObject);
    procedure actELineGetPilotInfoExecute(Sender: TObject);
    procedure actELinePilotClrCountersExecute(Sender: TObject);
    procedure actELineSetChannelNrExecute(Sender: TObject);
    procedure actELinePilotGoSleepExecute(Sender: TObject);
    procedure eLineReturnWorkChannelTimerTimer(Sender: TObject);
    procedure actELinePilotGoSleepSetupExecute(Sender: TObject);
  private
    memComNr: Integer;
    mShowRSSI: cardinal;
    prevRmkTime: double;
  private type // Szarpak
    TSzarpakRec = record
      Shapes: array [0 .. SZ_KEY_CNT - 1] of TShape;
      FrameOkCnt: Integer;
      FrameErrCnt: Integer;
      FrameLostCnt: Integer;
      MemFrameNr: Integer;
    end;
  private
    szRec: TSzarpakRec;
  private
  private type // eLINE
    TShapeEx = record
      Sh: TShape;
      Lab: TLabel;
      memColor: TColor;
    end;

    TRfm69SkanerCfgEx = record
      RfmCfg: TRfm69SkanerCfg;
      ELineChNr: byte;
    end;

    TELineRec = record
      Shapes: array [0 .. ELINE_KEY_CNT - 1] of TShapeEx;
      FrameOkCnt: Integer;
      FrameErrCnt: Integer;
      sndKeyCnt: word;
      cmdNr: word;
      ZoreChannelForced: Boolean;
    end;
  private
    elineRec: TELineRec;

    procedure sLinePilotShapeOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure SaveToRegistry;
    procedure ReadFromRegistry;
    procedure OnComClickProc(Sender: TObject);
    procedure OnDataNotifyProc(Sender: TObject; Dt: TSkanerObj);
    procedure OnAckSendingNotifyProc(Sender: TObject; msgType: TMesgType);

    procedure Wr(s: string);
    procedure ClearRssiBox;
    procedure FillGeoLV;
    procedure AddToLV(Dt: TSkanerObj);
    procedure FillUniLV;
    procedure AddToUniLV(Dt: TSkanerObj);
    procedure OnExceptionProc(Sender: TObject; E: Exception);
    procedure ShowSzarpakData(Dt: TSkanerObj);
    procedure ShowELineData(Dt: TSkanerObj);
    procedure SendSzarpakMsg(msg: TSzPilotMsg);
    procedure sendCmdToElinePilot(cmd: ELineCmd);
    function getRfm69Cfg: TRfm69SkanerCfgEx;
    procedure ELineSetWorkChannel;
    procedure OnUsbRemooveProc(Sender: TObject);
    procedure OnUSBArrivalProc(Sender: TObject);

  private
    CompUSB: TComponentUSB;
  public
    Skaner: TSkanerDev;
  end;

var
  MainForm: TMainForm;

const
  REG_KEY = '\SOFTWARE\GEKA\RFM69_SKANER';

implementation

{$R *.dfm}

uses
  Rfm69SkanerCfg;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Skaner := TSkanerDev.Create;
  Skaner.OnDataNotify := OnDataNotifyProc;
  Skaner.OnAckSendNotify := OnAckSendingNotifyProc;

  CompUSB := TComponentUSB.Create(self);
  CompUSB.OnUSBRemove := OnUsbRemooveProc;
  CompUSB.OnUSBArrival := OnUSBArrivalProc;

  ReadFromRegistry;
  Application.OnException := OnExceptionProc;

  // Sarpak
  szRec.Shapes[0] := SzBtnDownShape;
  szRec.Shapes[1] := SzBtnUPShape;
  szRec.Shapes[2] := SzBtnLeftShape;
  szRec.Shapes[3] := SzBtnRightShape;
  szRec.Shapes[4] := SzBtnLampShape;
  szRec.Shapes[5] := SzBtnOnOffShape;
  szRec.Shapes[6] := SzBtnOpc1Shape;
  szRec.Shapes[7] := SzBtnOpc2Shape;

  SarpakDtGrid.Cols[0].CommaText := 'lp 1 2 3 4 5 6 7 8 9 10 11';
  SarpakDtGrid.Cols[1].CommaText :=
    'Nazwa Status "Iloœæ ramek OK" "Iloœæ ramek Err" "Il.zgubionych ramek" "RSSI (dBm)" "Nr ramki" ' +
    '"Typ ramki" "Napiêcie Bat." "Wers.Prog" OptByte1 OptByte2';
  SarpakDtGrid.Cols[2].CommaText := 'Wartoœæ';

  // eLINE
  elineRec.Shapes[0].Sh := elineBtn1Shape;
  elineRec.Shapes[1].Sh := elineBtn2Shape;
  elineRec.Shapes[2].Sh := elineBtn3Shape;
  elineRec.Shapes[3].Sh := elineBtn4Shape;
  elineRec.Shapes[4].Sh := elineBtn5Shape;
  elineRec.Shapes[5].Sh := elineBtn6Shape;
  elineRec.Shapes[6].Sh := elineBtn7Shape;
  elineRec.Shapes[7].Sh := elineBtn8Shape;
  elineRec.Shapes[8].Sh := elineBtn9Shape;
  elineRec.Shapes[9].Sh := elineBtn10Shape;

  elineRec.Shapes[0].Lab := elineBtn1Txt;
  elineRec.Shapes[1].Lab := elineBtn2Txt;
  elineRec.Shapes[2].Lab := elineBtn3Txt;
  elineRec.Shapes[3].Lab := elineBtn4Txt;
  elineRec.Shapes[4].Lab := elineBtn5Txt;
  elineRec.Shapes[5].Lab := elineBtn6Txt;
  elineRec.Shapes[6].Lab := elineBtn7Txt;
  elineRec.Shapes[7].Lab := elineBtn8Txt;
  elineRec.Shapes[8].Lab := elineBtn9Txt;
  elineRec.Shapes[9].Lab := elineBtn10Txt;

  for i := 0 to ELINE_KEY_CNT - 1 do
  begin
    elineRec.Shapes[i].memColor := elineRec.Shapes[i].Sh.Brush.Color;
    elineRec.Shapes[i].Sh.OnMouseDown := sLinePilotShapeOnMouseDown;
    elineRec.Shapes[i].Lab.OnMouseDown := sLinePilotShapeOnMouseDown;
  end;

  ELineDataGrid.Cols[0].CommaText := 'lp 1 2 3 4 5 6 7 8 9 10 11';
  ELineDataGrid.Cols[1].CommaText :=
    'Nazwa "Typ/Status" "Iloœæ ramek OK" "Iloœæ ramek Err" "Il.zgubionych ramek" "RSSI (dBm)" "Nr ramki" ' +
    '"Typ ramki" "Napiêcie Bat." "Wers.Prog" OptByte1 OptByte2';
  ELineDataGrid.Cols[2].CommaText := 'Wartoœæ';

end;

procedure TMainForm.OnExceptionProc(Sender: TObject; E: Exception);
begin
  OutputDebugString(pchar(E.ToString));;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveToRegistry;
  Skaner.Free;
  CompUSB.Free;

end;

procedure TMainForm.FormShow(Sender: TObject);
var
  i: TGeomCmd;
  j: Integer;
begin
  CmdBox.Items.Clear;
  CmdBox.Items.Add('---');
  for i := succ(low(TGeomCmd)) to pred(high(TGeomCmd)) do
  begin
    CmdBox.Items.Add(GetGeomCmdName(ord(i)));
  end;
  CmdBox.ItemIndex := 0;
  UniStringGrid.Rows[0].CommaText := 'lp. Nazwa "Do wys³ania (Hex)"';
  for j := 1 to UniStringGrid.RowCount - 1 do
    UniStringGrid.Cells[0, j] := 'Send : ' + IntToStr(j);
end;

procedure TMainForm.OnUSBArrivalProc(Sender: TObject);
begin
  Wr('OnUSBArrivalProc');
  if not(Skaner.Connected) then
    Skaner.OpenDev(memComNr);
end;

procedure TMainForm.OnUsbRemooveProc(Sender: TObject);
var
  commPort : string;
begin
  Wr('OnUSBRemoveProc');
  if Skaner.Connected then
  begin
    if Skaner.WriteLedMessage<>stOK then
      Skaner.CloseDev;
  end;
end;

procedure TMainForm.Wr(s: string);
begin
  Memo1.Lines.Add(s);
end;

procedure TMainForm.SaveToRegistry;
  function getLVWidths(LV: TListView): string;
  var
    i: Integer;
    SL: TStringList;
  begin
    SL := TStringList.Create;
    try
      for i := 0 to LV.Columns.Count - 1 do
      begin
        SL.Add(IntToStr(LV.Columns.Items[i].Width));
      end;
      Result := SL.CommaText;
    finally
      SL.Free;
    end;
  end;

var
  Reg: TRegistry;
  X, Y: Integer;
  key: string;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, true) then
    begin
      Reg.WriteInteger('Top', Top);
      Reg.WriteInteger('Left', Left);
      Reg.WriteInteger('Width', Width);
      Reg.WriteInteger('Height', Height);

      Reg.WriteInteger('memComNr', memComNr);
      Reg.WriteString('ColWidths', getLVWidths(LV));
      Reg.WriteString('UniColWidths', getLVWidths(UniLV));
      Reg.WriteInteger('UniSendSlotNrBox', UniSendSlotNrBox.ItemIndex);
      for X := 1 to 2 do
        for Y := 1 to UniStringGrid.RowCount - 1 do
        begin
          key := Format('UniStr_%u_%u', [X, Y]);
          Reg.WriteString(key, UniStringGrid.Cells[X, Y]);
        end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.UniSenderEditChange(Sender: TObject);
begin
  UniLV.Invalidate;
end;

procedure TMainForm.GeoSheetShow(Sender: TObject);
begin
  Skaner.SkanerDtList.SkanerMode := skmGEO;
  FillGeoLV;
end;

procedure TMainForm.ThreadInfoBtnClick(Sender: TObject);
begin
  Wr(Skaner.GetComThreadStr);
end;

procedure TMainForm.UniLVCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  FillColor: TColor;
  PenColor: TColor;
  Dt: TSkanerObj;
  Dt2: TSkanerObj;
  sendNr: Integer;
  idx: Integer;
begin
  Dt := TSkanerObj(Item.Data);

  FillColor := TColorRec.White;
  PenColor := TColorRec.Black;
  sendNr := Dt.SkRec.SkData.Sender;

  if sendNr = UniSenderEdit.Value then
    FillColor := TColor($A0FFFF);

  if cdsSelected in State then
  begin
    FillColor := FillColor xor $FFFFFF;
    PenColor := PenColor xor $FFFFFF;
  end;

  idx := UniLV.Items.IndexOf(Item);
  if idx > 0 then
  begin
    Dt2 := TSkanerObj(UniLV.Items[idx - 1].Data);
    if Dt.SkRec.SkData.frameNr - Dt2.SkRec.SkData.frameNr <> 1 then
      FillColor := TColorRec.Red;
  end;

  Sender.Canvas.Brush.Color := FillColor;
  Sender.Canvas.Font.Color := PenColor;
  DefaultDraw := true;

end;

procedure TMainForm.UniSheetShow(Sender: TObject);
begin
  Skaner.SkanerDtList.SkanerMode := skmUNI;
  FillUniLV;
end;

procedure TMainForm.UniStringGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  function KonwertStringToBytes(s: string; var buf: TBytes): Boolean;
  var
    i, n, n1: Integer;
    m: Integer;

  begin
    n := length(s);
    n1 := (n + 1) div 2;
    setlength(buf, n1);
    Result := true;
    for i := 0 to n1 - 1 do
    begin
      Result := Result and TryStrToInt('$' + copy(s, 1 + 2 * i, 2), m);
      if Result = false then
        break;
      buf[i] := m;
    end;
  end;

var
  aCol, aRow: Integer;
  s1: string;
  buf: TBytes;
begin
  if Skaner.Connected then
  begin
    UniStringGrid.MouseToCell(X, Y, aCol, aRow);
    if aCol = 0 then
    begin
      s1 := UniStringGrid.Cells[2, aRow];
      if s1 <> '' then
      begin
        if KonwertStringToBytes(s1, buf) then
        begin
          Skaner.WriteDataMessage(UniSendSlotNrBox.ItemIndex, buf);
          Wr(Format('Wys³ano [%s], %u bytes', [UniStringGrid.Cells[1, aRow], length(buf)]));
        end
        else
          Wr(Format('B³¹d formatu danych [%s]', [UniStringGrid.Cells[1, aRow]]));
      end
      else
        Wr('Nic do wys³ania');
    end
  end
  else
    Wr('Skaner not connected');
end;

procedure TMainForm.actSaveExecute(Sender: TObject);
var
  Dlg: TSavedialog;
begin
  Dlg := TSavedialog.Create(self);
  try
    Dlg.Filter := 'Skaner data|*.skn|All files|*.*';
    Dlg.DefaultExt := '.skn';
    if Dlg.Execute then
      Skaner.SkanerDtList.SaveToFile(Dlg.FileName);
  finally
    Dlg.Free;
  end;

end;

procedure TMainForm.actSaveUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (Skaner.SkanerDtList.Count > 0) and (actRun.Checked = false);
end;

procedure TMainForm.actSendCfgExecute(Sender: TObject);
var
  Dlg: TCfgForm;
begin
  Dlg := TCfgForm.Create(self);
  Dlg.ConfigAndClose := true;
  Dlg.Show;
end;

procedure TMainForm.actSendCfgUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Skaner.Connected and not(actRun.Checked);
end;

procedure TMainForm.SendSzarpakMsg(msg: TSzPilotMsg);
var
  buf: TBytes;
begin
  setlength(buf, 6);
  buf[0] := ord(msg);
  buf[1] := not(buf[0]);
  Skaner.WriteDataMessage(DEVICE_SKANER, buf)
end;

procedure TMainForm.actSzPilotMsgNoBeepExecute(Sender: TObject);
begin
  SendSzarpakMsg(skPlCmdNoBeep);
end;

procedure TMainForm.actSzPilotSetChExecute(Sender: TObject);
var
  buf: TBytes;
begin
  setlength(buf, 6);
  buf[0] := ord(skPlCmdSetUpChannel);
  buf[1] := not(buf[0]);
  buf[2] := SzSetUpChannelBox.ItemIndex;
  buf[3] := not(buf[2]);
  Skaner.WriteDataMessage(DEVICE_SKANER, buf)
end;

procedure TMainForm.actSzSterowMsg2BeepExecute(Sender: TObject);
begin
  SendSzarpakMsg(skStCmdBeep2);
end;

procedure TMainForm.actSzSterowMsgBeepExecute(Sender: TObject);
begin
  SendSzarpakMsg(skStCmdBeep);
end;

procedure TMainForm.actSzSterowMsgNoBeepExecute(Sender: TObject);
begin
  SendSzarpakMsg(skStCmdNoBeep);
end;

procedure TMainForm.actSzPilotMsgBeepExecute(Sender: TObject);
begin
  SendSzarpakMsg(skPlCmdBeep);
end;

procedure TMainForm.actSzLampOffExecute(Sender: TObject);
begin
  SendSzarpakMsg(skPlCmdLampOff);
end;

procedure TMainForm.actSzLampOnExecute(Sender: TObject);
begin
  SendSzarpakMsg(skPlCmdLampOn);
end;

procedure TMainForm.actSzPilotMsgBeep2Execute(Sender: TObject);
begin
  SendSzarpakMsg(skPlCmdBeep2);
end;

procedure TMainForm.actSzPilotMsgBeepUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Skaner.Connected;
end;

procedure TMainForm.ClearRssiBox;
begin
  RssiMostEdit.Text := '';
  RssiHead1Edit.Text := '';
  RssiHead2Edit.Text := '';
  RssiHead3Edit.Text := '';
  RssiHead4Edit.Text := '';
end;

procedure TMainForm.actLedPulseExecute(Sender: TObject);
begin
  Skaner.WriteLedMessage;
end;

procedure TMainForm.actLedPulseUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Skaner.Connected;
end;

procedure TMainForm.actLoadExecute(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.Filter := 'Skaner data|*.skn|All files|*.*';
    Dlg.DefaultExt := '.skn';
    if Dlg.Execute then
    begin
      ClearRssiBox;
      Skaner.SkanerDtList.LoadFromFile(Dlg.FileName);
      FillGeoLV;
    end;
  finally
    Dlg.Free;
  end;

end;

procedure TMainForm.actLoadUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (actRun.Checked = false);
end;

procedure TMainForm.ReadFromRegistry;
  procedure setLVWidths(aLV: TListView; s: string);
  var
    i: Integer;
    n: Integer;
    SL: TStringList;
  begin
    SL := TStringList.Create;
    try
      SL.CommaText := s;
      n := SL.Count;
      if aLV.Columns.Count < n then
        n := aLV.Columns.Count;
      for i := 0 to n - 1 do
      begin
        aLV.Columns.Items[i].Width := StrToInt(SL.Strings[i]);
      end;
    finally
      SL.Free;
    end;
  end;

var
  Reg: TRegistry;
  s, s1: string;
  SL: TStringList;
  i, X: Integer;
  xi, yi: Integer;
begin
  memComNr := -1;
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, false) then
    begin
      if Reg.ValueExists('Top') then
        Top := Reg.ReadInteger('Top');
      if Reg.ValueExists('Left') then
        Left := Reg.ReadInteger('Left');
      if Reg.ValueExists('Width') then
        Width := Reg.ReadInteger('Width');
      if Reg.ValueExists('Height') then
        Height := Reg.ReadInteger('Height');

      if Reg.ValueExists('memComNr') then
        memComNr := Reg.ReadInteger('memComNr');

      if Reg.ValueExists('ColWidths') then
        setLVWidths(LV, Reg.ReadString('ColWidths'));

      if Reg.ValueExists('UniColWidths') then
        setLVWidths(UniLV, Reg.ReadString('UniColWidths'));

      if Reg.ValueExists('UniSendSlotNrBox') then
        UniSendSlotNrBox.ItemIndex := Reg.ReadInteger('UniSendSlotNrBox');

      SL := TStringList.Create;
      try
        Reg.GetValueNames(SL);
        for i := 0 to SL.Count - 1 do
        begin
          s := SL.Strings[i];
          if copy(s, 1, 7) = 'UniStr_' then
          begin
            s := copy(s, 8, length(s) - 7);
            X := pos('_', s);
            if X > 0 then
            begin
              try
                s1 := copy(s, 1, X - 1);
                xi := StrToInt(s1);
                s1 := copy(s, X + 1, length(s) - X);
                yi := StrToInt(s1);
                UniStringGrid.Cells[xi, yi] := Reg.ReadString(SL.Strings[i]);
              except

              end;
            end;
          end;
        end;
      finally
        SL.Free;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.actOpenUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked := Skaner.Connected;
end;

procedure TMainForm.actRunExecute(Sender: TObject);
begin
  (Sender as TAction).Checked := not(Sender as TAction).Checked;
  if (Sender as TAction).Checked then
  begin
    Skaner.SkanerDtList.Start;
    LV.Items.Clear;
    UniLV.Items.Clear;
    szRec.FrameOkCnt := 0;
    szRec.FrameErrCnt := 0;
    szRec.FrameLostCnt := 0;
    szRec.MemFrameNr := -1;
  end;

end;

procedure TMainForm.actRunUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Skaner.Connected;
end;

procedure TMainForm.ClrMemoBtnClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TMainForm.CmdBoxChange(Sender: TObject);
begin
  LV.Invalidate;
end;

procedure TMainForm.colHead1BtnClick(Sender: TObject);
begin
  LV.Invalidate;
end;

procedure TMainForm.ComListMenuPopup(Sender: TObject);
var
  Mn: TPopupMenu;
  Item: TMenuItem;
  Coms: TStringList;
  i: Integer;
begin
  Mn := Sender as TPopupMenu;
  Coms := TStringList.Create;
  try
    LoadRsPorts(Coms);
    Mn.Items.Clear;
    for i := 0 to Coms.Count - 1 do
    begin
      Item := TMenuItem.Create(self);
      Item.Caption := Coms.Strings[i];
      Item.tag := GetComNr(Coms.Strings[i]);
      Item.OnClick := OnComClickProc;
      Mn.Items.Add(Item);
    end;
  finally
    Coms.Free;
  end;
end;

procedure TMainForm.OnComClickProc(Sender: TObject);
var
  Item: TMenuItem;
begin
  Item := Sender as TMenuItem;
  memComNr := Item.tag;
  actOpenExecute(nil);
end;

procedure TMainForm.actCfgExecute(Sender: TObject);
var
  Dlg: TCfgForm;
begin
  Dlg := TCfgForm.Create(self);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.actCfgUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Skaner.Connected;
end;

procedure TMainForm.actClearExecute(Sender: TObject);
begin
  UniLV.Clear;
  LV.Clear;
  Memo1.Clear;
  Skaner.SkanerDtList.Start;
end;

procedure TMainForm.actHideSendingExecute(Sender: TObject);
var
  q: Boolean;
begin
  q := HideSendingBtn.Down;
  GeoSplitter.Visible := q;
  GeoSendPanel.Visible := q;
  UniSplitter.Visible := q;
  UniSendPanel.Visible := q;

  UniSplitter.Top := UniSendPanel.Top - UniSplitter.Height;
  GeoSplitter.Top := GeoSendPanel.Top - GeoSplitter.Height;
end;

procedure TMainForm.actOpenExecute(Sender: TObject);
var
  st: TStatus;
begin
  if Skaner.Connected then
  begin
    Skaner.CloseDev;
    actRun.Checked := false;
  end
  else
  begin
    if memComNr >= 0 then
    begin
      st := Skaner.OpenDev(memComNr);
      if st = stOk then
      begin
        StatusBar.Panels[1].Text := ' Port: COM' + IntToStr(Skaner.ComNr);
        LV.Items.Clear;
        Skaner.SkanerDtList.Clear;
      end
      else
        StatusBar.Panels[1].Text := ' Port: ' + Skaner.GetErrStr(st);
    end
    else
      StatusBar.Panels[1].Text := ' Port: ???';
  end;
  StatusBar.Refresh;
end;

procedure TMainForm.LVCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  SkObj: TSkanerObj;
  hNr: Integer;
  Color: TColor;
  PenColor: TColor;
  tm: double;
  GeRec: TGeometriaRec;
begin
  SkObj := TSkanerObj(Item.Data);
  GeRec := SkObj.SkRec.RadioDt.Ge;

  Color := TColorRec.White;
  PenColor := TColorRec.Black;
  hNr := SkObj.SkRec.RadioDt.Ge.getHeadNr;
  if ((hNr = 15) and colMostBtn.Down) or //
    ((hNr = 0) and colHead1Btn.Down) or //
    ((hNr = 1) and colHead2Btn.Down) or //
    ((hNr = 2) and colHead3Btn.Down) or //
    ((hNr = 3) and colHead4Btn.Down) then
    Color := TColorRec.Lightyellow;

  if ord(GeRec.getGeoCmd) = CmdBox.ItemIndex then
  begin
    Color := TColorRec.Blue;
    PenColor := TColorRec.White;

    if { item.Focused } (cdsHot in State) or (cdsFocused in State) then
      PenColor := TColorRec.Black;

  end;
  case GeRec.getGeoCmd of
    cmrTIME_SYNCH:
      begin
        Color := TColorRec.Yellow;
        if not SkObj.timeInRegion(MEAS_PERIOD_ALL, 2) then
          Color := TColorRec.Red;
      end;
    cmrGET_DT:
      begin

        if not inRegion(SkObj.GeoInfo.DataRelTime, 80, 2) then
        begin
          Color := TColorRec.LightGreen;

          if not inRegion(SkObj.GeoInfo.DataRelTime, 160, 2) then
          begin
            Color := TColorRec.Green;
            PenColor := TColorRec.White;
            if cdsFocused in State then
              PenColor := TColorRec.Black;
          end;
        end;

        tm := SkObj.getSlotTime;
        if (tm < 0) or (tm > SLOT_WIDTH) then
          Color := TColorRec.Red;
      end;
    cmrPING:
      begin
        if (SkObj.SkRec.SkData.Sender = 0) and (SkObj.GeoInfo.DataRelTime > 85) then
          PenColor := TColorRec.Red;

      end;
  end;
  Sender.Canvas.Brush.Color := Color;
  Sender.Canvas.Font.Color := PenColor;

  DefaultDraw := true;
end;

procedure TMainForm.MainPageControlChanging(Sender: TObject; var AllowChange: Boolean);
begin
  AllowChange := not(actRun.Checked);
end;

procedure TMainForm.FillGeoLV;
var
  i: Integer;
begin
  LV.Items.Clear;
  for i := 0 to Skaner.SkanerDtList.Count - 1 do
  begin
    AddToLV(Skaner.SkanerDtList.Items[i]);
  end;
end;

procedure TMainForm.AddToLV(Dt: TSkanerObj);
var
  Li: TListItem;
begin
  Li := LV.Items.Add;
  Li.Data := Dt;
  Li.Caption := IntToStr(Dt.idx);
  Li.SubItems.Add(IntToStr(Dt.SkRec.SkData.Sender));
  Li.SubItems.Add(Dt.SkRec.RadioDt.Ge.getSrcNr);
  Li.SubItems.Add(getdBmStr(Dt.SkRec.SkData.RSSI));

  Li.SubItems.Add(GetGeomCmdName(Dt.SkRec.RadioDt.Ge.cmd));
  Li.SubItems.Add(WzTimeStr(Dt.SkRec.GetTime));
  Li.SubItems.Add(WzTimeStr(Dt.GeoInfo.RelTime));
  Li.SubItems.Add(WzTimeStr(Dt.getSlotTime));
  Li.SubItems.Add(WzTimeStr(Dt.GeoInfo.DataRelTime));
end;

procedure TMainForm.FillUniLV;
var
  i: Integer;
begin
  LV.Items.Clear;
  for i := 0 to Skaner.SkanerDtList.Count - 1 do
  begin
    AddToUniLV(Skaner.SkanerDtList.Items[i]);
  end;
end;

procedure TMainForm.AddToUniLV(Dt: TSkanerObj);
var
  Li: TListItem;
  tm: double;
begin
  Li := UniLV.Items.Add;
  Li.Data := Dt;
  Li.Caption := IntToStr(Dt.idx);
  Li.SubItems.Add(IntToStr(Dt.SkRec.SkData.frameNr));
  Li.SubItems.Add(IntToStr(Dt.SkRec.SkData.Sender));
  Li.SubItems.Add(getdBmStr(Dt.SkRec.SkData.RSSI));
  tm := Dt.SkRec.GetTime;
  Li.SubItems.Add(WzTimeStr(tm));
  if tm > prevRmkTime then
    Li.SubItems.Add(WzTimeStr(tm - prevRmkTime))
  else
    Li.SubItems.Add('-');
  Li.SubItems.Add(Dt.SkRec.DataAsString);
  prevRmkTime := tm;
  UniLV.Scroll(0, 500);
end;

procedure TMainForm.OnAckSendingNotifyProc(Sender: TObject; msgType: TMesgType);
var
  s: string;
begin
  s := '???';
  case msgType of
    nuRADIO_CFG:
      s := 'CFG';
    nuRADIO_DATA:
      s := 'DATA';
    nuRED_PULSE:
      s := 'LED';
  end;
  Wr('MostAck: ' + s);
end;

procedure TMainForm.ShowSzarpakData(Dt: TSkanerObj);
  procedure SetShapeColor(Sh: TShape; q: Boolean);
  begin
    if q then
      Sh.Brush.Color := clLime
    else
      Sh.Brush.Color := clGray;
  end;
  procedure SetShapeColor2(Sh: TShape; q: Boolean);
  begin
    if q then
      Sh.Brush.Color := clYellow
    else
      Sh.Brush.Color := clGray;
  end;

var
  Sz: TSzarpakData;
  i: Integer;
  statusTxt: string;
begin
  Sz := Dt.SkRec.RadioDt.Sz;
  for i := 0 to 7 do
    SetShapeColor(szRec.Shapes[i], (Sz.keys and (1 shl i)) <> 0);
  if Sz.CheckFrame then
    inc(szRec.FrameOkCnt)
  else
    inc(szRec.FrameErrCnt);

  if szRec.MemFrameNr >= 0 then
  begin
    inc(szRec.MemFrameNr);
    if szRec.MemFrameNr = 256 then
      szRec.MemFrameNr := 0;
    if szRec.MemFrameNr <> Sz.frameCnt then
      inc(szRec.FrameLostCnt);
    szRec.MemFrameNr := Sz.frameCnt;
  end;

  if Sz.CheckFrameCrc then
  begin
    if Sz.CheckKeyBits then
      statusTxt := 'Ok'
    else
      statusTxt := 'Keys bit Error';
  end
  else
    statusTxt := 'Crc Error';

  SarpakDtGrid.Cells[2, 1] := statusTxt;
  SarpakDtGrid.Cells[2, 2] := IntToStr(szRec.FrameOkCnt);
  SarpakDtGrid.Cells[2, 3] := IntToStr(szRec.FrameErrCnt);
  SarpakDtGrid.Cells[2, 4] := IntToStr(szRec.FrameLostCnt);
  SarpakDtGrid.Cells[2, 5] := getdBmStr(Dt.SkRec.SkData.RSSI);
  SarpakDtGrid.Cells[2, 6] := IntToStr(Sz.frameCnt);
  SarpakDtGrid.Cells[2, 7] := IntToStr(Sz.frameType);
  SarpakDtGrid.Cells[2, 8] := FormatFloat('0.000', Sz.batVolt / 1000.0);
  SarpakDtGrid.Cells[2, 9] := Format('%u.%.3u', [Sz.Ver, Sz.Rev]);
  SarpakDtGrid.Cells[2, 10] := '0x' + IntToHex(Sz.OptByte1, 2);
  SarpakDtGrid.Cells[2, 11] := '0x' + IntToHex(Sz.OptByte2, 2);

  SetShapeColor2(SzLampShape, Sz.lamp <> 0);
end;

procedure TMainForm.OnDataNotifyProc(Sender: TObject; Dt: TSkanerObj);
begin
  if actRun.Checked then
  begin
    case MainPageControl.ActivePageIndex of
      0: // Univeral
        begin
          AddToUniLV(Dt);
        end;
      1: // Geometria
        begin
          AddToLV(Dt);
          if GetTickCount - mShowRSSI > 500 then
          begin
            mShowRSSI := GetTickCount;
            RssiMostEdit.Text := getdBmStr(Skaner.SkanerDtList.FiltrRssi[4].Srednia);
            RssiHead1Edit.Text := getdBmStr(Skaner.SkanerDtList.FiltrRssi[0].Srednia);
            RssiHead2Edit.Text := getdBmStr(Skaner.SkanerDtList.FiltrRssi[1].Srednia);
            RssiHead3Edit.Text := getdBmStr(Skaner.SkanerDtList.FiltrRssi[2].Srednia);
            RssiHead4Edit.Text := getdBmStr(Skaner.SkanerDtList.FiltrRssi[3].Srednia);

          end;
        end;
      2: // Szarpak
        ShowSzarpakData(Dt);
      3: // eLine
        ShowELineData(Dt);
    end;
  end;
end;

procedure TMainForm.eLineColorRetTimerTimer(Sender: TObject);
var
  i: Integer;
begin
  eLineColorRetTimer.Enabled := false;
  for i := 0 to ELINE_KEY_CNT - 1 do
  begin
    elineRec.Shapes[i].Sh.Brush.Color := elineRec.Shapes[i].memColor;
  end;
  sndPlaySound(nil, SND_ASYNC);

end;

procedure TMainForm.ShowELineData(Dt: TSkanerObj);
  procedure ShowElineShapePilot(code: word);
  var
    i: Integer;
  begin
    for i := 0 to ELINE_KEY_CNT - 1 do
    begin
      if (code and (1 shl i)) <> 0 then
      begin
        elineRec.Shapes[i].Sh.Brush.Color := clYellow;
      end;
    end;
    eLineColorRetTimer.Enabled := true;

  end;

  function CheckXor(const p; cnt: Integer): Boolean;
  var
    n, i: Integer;
    XorW: cardinal;
    dtP: PCardinal;
  begin
    Result := false;
    if (cnt mod 4) = 0 then
    begin
      n := cnt div 4;
      XorW := 0;
      dtP := PCardinal(@p);
      for i := 0 to n - 1 do
      begin
        XorW := XorW xor dtP^;
        inc(dtP);
      end;
      Result := (XorW = 0);
    end
  end;

  function GetInfoRecAsTxt(var w): string;
  var
    pInf: PELinePilot_InfoStruct;
    tm: TDateTime;
    tmStr: string;
  begin
    pInf := PELinePilot_InfoStruct(@w);
    try
      tm := FileDateToDateTime(pInf.PackTime);
      tmStr := DateTimeToStr(tm);
    except
      tmStr := '????.??.??';
    end;
    Result := Format('Ver=%u.%.3u StartCnt=%u GlobSendCnt=%u od %s', [pInf.firmVer, pInf.firmRev, pInf.startCnt,
      pInf.keyGlobSendCnt, tmStr]);
  end;

  function getKeysStr(k: word): string;
  begin
    Result := '';
    if (k and $0001) <> 0 then
      Result := Result + 'EngL ';
    if (k and $0002) <> 0 then
      Result := Result + 'EngR ';
    if (k and $0004) <> 0 then
      Result := Result + 'EngLR ';
    if (k and $0008) <> 0 then
      Result := Result + 'UP ';
    if (k and $0010) <> 0 then
      Result := Result + 'DN ';
    if (k and $0020) <> 0 then
      Result := Result + 'LF ';
    if (k and $0040) <> 0 then
      Result := Result + 'RT ';
    if (k and $0080) <> 0 then
      Result := Result + 'OK ';
    if (k and $0100) <> 0 then
      Result := Result + 'MN ';
    if (k and $0200) <> 0 then
      Result := Result + 'ESC ';
  end;

  function GetKeyRecAsTxt(var w): string;
  var
    sDt: PELinePilot_DataStruct;
    s: string;
  begin
    sDt := PELinePilot_DataStruct(@w);
    s := getKeysStr(sDt.key_code);
    Result := Format('KEYS:Cnt=%u Rep=%u cd=0x%.4X (%s)', [sDt.keySendCnt, sDt.repCnt, sDt.key_code, s]);
  end;

  function GetChipIDAsTxt(var w): string;
  var
    pID: PPilot_ChipIDStruct;
  begin
    pID := PPilot_ChipIDStruct(@w);
    Result := Format('ChipID=%.8X.%.8X.%.8X', [pID.ChipID[0], pID.ChipID[1], pID.ChipID[2]]);
  end;

  function GetAckRecDAsTxt(var w): string;
  var
    p: PELinePilot_AckStruct;
  begin
    p := PELinePilot_AckStruct(@w);
    Result := Format('Ack: cmd=%u  cmdNr=%u err=%u', [p.ackCmd, p.ackCmdNr, p.ackError]);
  end;

const
  // FName = 'c:\Windows\Media\Windows Balloon.wav';
  FName = 'KbdKeyTap.wav';
var
  pdt: PELinePilot_Begin;
  sDt: PELinePilot_DataStruct;
  statusTxt: string;
  statusTxtL: string;
begin
  pdt := PELinePilot_Begin(@Dt.SkRec.RadioDt.RecBuf);
  if pdt.Sign = ELinePilot_SIGN then
  begin
    if CheckXor(Dt.SkRec.RadioDt.RecBuf, Dt.SkRec.SkData.dtLen) then
    begin
      inc(elineRec.FrameOkCnt);
      statusTxtL := '';
      statusTxt := '';
      case pdt.cmd of
        ord(plcmdDATA):
          begin
            statusTxt := 'Dane';
            sDt := PELinePilot_DataStruct(@Dt.SkRec.RadioDt.RecBuf);
            if sDt.key_code = (sDt.n_key_code xor $FFFF) then
            begin
              ShowElineShapePilot(sDt.key_code);
              sndPlaySound(pchar(FName), SND_ASYNC);
              statusTxtL := Format('', [sDt.key_code]);
              statusTxtL := GetKeyRecAsTxt(Dt.SkRec.RadioDt.RecBuf);

            end
            else
              statusTxt := 'Dane Error';

            // {P-->} ramka danych z pilota
          end;
        ord(plcmdINFO):
          begin
            // {P-->} ramka informacyjna z pilota
            statusTxt := 'Info z pilota';
            statusTxtL := GetInfoRecAsTxt(Dt.SkRec.RadioDt.RecBuf);
          end;
        ord(plcmdCHIP_SN):
          begin
            statusTxt := 'ChipID';
            statusTxtL := GetChipIDAsTxt(Dt.SkRec.RadioDt.RecBuf);
          end;
        ord(plcmdACK):
          begin
            if elineRec.ZoreChannelForced then
              ELineSetWorkChannel;
            statusTxt := 'Cmd Ack';
            statusTxtL := GetAckRecDAsTxt(Dt.SkRec.RadioDt.RecBuf);

            // {P-->} potwierdzenie komend
          end;
        ord(plcmdSETUP):
          begin
            // {-->P} ramka konfiguracyjna do pilota
            statusTxt := 'Ustaw kana³';
          end;
        ord(plcmdCLR_CNT):
          begin
            // {-->P} rozkaz kasowania liczników
            statusTxt := 'Zeruj liczniki';
          end;
        ord(plcmdGET_INFO):
          begin
            // {-->P} wyœlij info rekord
            statusTxt := 'Wyœlij info';
          end;
        ord(plcmdEXIT_SETUP):
          begin
            // {P-->} informacja o wyjœciu z trybu setup
            statusTxt := 'Exit MainLoop';
          end;
        ord(plcmdGO_SLEEP):
          begin
            // {P-->} informacja o wyjœciu z trybu setup
            statusTxt := 'GoSleep';
          end;
      else
        begin
          statusTxt := Format('Unknow command, cmd=%u', [pdt.cmd]);
        end;

      end;
    end
    else
      statusTxt := 'SumaXor Error';
  end
  else
  begin
    inc(elineRec.FrameErrCnt);
    statusTxt := 'FrameSign Error';
  end;
  ELineDataGrid.Cells[2, 1] := statusTxt;
  ELineDataGrid.Cells[2, 2] := IntToStr(elineRec.FrameOkCnt);
  ELineDataGrid.Cells[2, 3] := IntToStr(elineRec.FrameErrCnt);

  ELineDataGrid.Cells[2, 5] := getdBmStr(Dt.SkRec.SkData.RSSI);
  if statusTxtL = '' then
    statusTxtL := statusTxt;

  ELineMsgMemo.Lines.Add(statusTxtL);
end;

procedure TMainForm.sLinePilotShapeOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i: Integer;
  pkt: TELinePilot_DataStruct;
begin
  for i := 0 to ELINE_KEY_CNT - 1 do
  begin
    if (elineRec.Shapes[i].Sh = Sender) or (elineRec.Shapes[i].Lab = Sender) then
    begin
      pkt.Sign := ELinePilot_SIGN;
      pkt.cmd := ord(plcmdDATA);
      pkt.key_code := 1 shl i;
      pkt.n_key_code := pkt.key_code xor $FFFF;
      pkt.repCnt := 1;
      pkt.keySendCnt := elineRec.sndKeyCnt;
      eLineBuildXor(pkt, sizeof(pkt));

      Skaner.WriteDataMessage(2, pkt, sizeof(pkt));
      elineRec.Shapes[i].Sh.Brush.Color := clWhite;
      eLineColorRetTimer.Enabled := true;
      inc(elineRec.sndKeyCnt);

    end;
  end;

end;

procedure TMainForm.actELineGetPilotInfoUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Skaner.Connected;
end;

procedure TMainForm.sendCmdToElinePilot(cmd: ELineCmd);
var
  pkt: TELinePilot_CmdStruct;
begin
  pkt.Sign := ELinePilot_SIGN;
  pkt.cmd := ord(cmd);
  pkt.cmdNr := elineRec.cmdNr;
  pkt.PackTime := DateTimeToFileDate(Now);
  inc(elineRec.cmdNr);
  eLineBuildXor(pkt, sizeof(pkt));

  Skaner.WriteDataMessage(2, pkt, sizeof(pkt));
end;

procedure TMainForm.actELineGetPilotInfoExecute(Sender: TObject);
begin
  sendCmdToElinePilot(plcmdGET_INFO);
end;

procedure TMainForm.actELinePilotClrCountersExecute(Sender: TObject);
begin
  if Application.MessageBox('Czy chcesz skasowac liczniki w pilocie ?', 'Kasowanie', mb_yesNo) = idYes then
  begin
    sendCmdToElinePilot(plcmdCLR_CNT);
  end;
end;

procedure TMainForm.actELinePilotGoSleepExecute(Sender: TObject);
begin
  sendCmdToElinePilot(plcmdGO_SLEEP);
end;

function TMainForm.getRfm69Cfg: TRfm69SkanerCfgEx;
var
  Dlg: TCfgForm;

begin
  Dlg := TCfgForm.Create(self);
  try
    Result.RfmCfg := Dlg.getRfm69Cfg;
    Result.ELineChNr := Dlg.getELineChannelNr;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.eLineReturnWorkChannelTimerTimer(Sender: TObject);
begin
  eLineReturnWorkChannelTimer.Enabled := false;
  ELineSetWorkChannel;
end;

procedure TMainForm.ELineSetWorkChannel;
var
  skCfg: TRfm69SkanerCfgEx;
begin
  elineRec.ZoreChannelForced := false;
  skCfg := getRfm69Cfg;
  Skaner.WriteCfgMessage(skCfg.RfmCfg);
  Wr(Format('ELine: Set Work Channel. freq=%u', [skCfg.RfmCfg.ChannelFreq]));
end;

procedure TMainForm.actELineSetChannelNrExecute(Sender: TObject);
var
  pkt: TELinePilot_SetupStruct;
  skCfg: TRfm69SkanerCfgEx;
begin
  skCfg := getRfm69Cfg;

  // ustawienie czêstotliwoœci kana³u ZERO
  skCfg.RfmCfg.ChannelFreq := ELINE_FREQ_BASE;
  Skaner.WriteCfgMessage(skCfg.RfmCfg);
  Wr(Format('ELine: Set Setup Channel. freq=%u', [skCfg.RfmCfg.ChannelFreq]));
  sleep(500);

  // wys³anie ramki
  pkt.Sign := ELinePilot_SIGN;
  pkt.cmd := ord(plcmdSETUP);
  pkt.channelNr := skCfg.ELineChNr;
  pkt.n_channelNr := pkt.channelNr xor $FF;
  pkt.txPower := 31;
  pkt.cmdNr := elineRec.cmdNr;
  inc(elineRec.cmdNr);
  eLineBuildXor(pkt, sizeof(pkt));

  Skaner.WriteDataMessage(2, pkt, sizeof(pkt));

  elineRec.ZoreChannelForced := true;
  eLineReturnWorkChannelTimer.Enabled := true;

end;

procedure TMainForm.actELinePilotGoSleepSetupExecute(Sender: TObject);
var
  pkt: TELinePilot_CmdStruct;
  skCfg: TRfm69SkanerCfgEx;
begin
  skCfg := getRfm69Cfg;

  // ustawienie czêstotliwoœci kana³u ZERO
  skCfg.RfmCfg.ChannelFreq := ELINE_FREQ_BASE;
  Skaner.WriteCfgMessage(skCfg.RfmCfg);
  Wr(Format('ELine: Set Setup Channel. freq=%u', [skCfg.RfmCfg.ChannelFreq]));
  sleep(500);

  // wys³anie ramki
  pkt.Sign := ELinePilot_SIGN;
  pkt.cmd := ord(plcmdGO_SLEEP);
  pkt.cmdNr := elineRec.cmdNr;
  pkt.PackTime := DateTimeToFileDate(Now);
  inc(elineRec.cmdNr);
  eLineBuildXor(pkt, sizeof(pkt));

  Skaner.WriteDataMessage(2, pkt, sizeof(pkt));

  elineRec.ZoreChannelForced := true;
  eLineReturnWorkChannelTimer.Enabled := true;

end;

end.
