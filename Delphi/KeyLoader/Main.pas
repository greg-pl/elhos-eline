unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, System.Actions, Vcl.ActnList, System.ImageList,
  Vcl.ImgList, Registry,
  KeyLoaderCmmUnit, KeyLoaderDef,
  InterRsd, Vcl.Menus;

type
  TMainForm = class(TForm)
    ImageList2: TImageList;
    ActionList1: TActionList;
    actOpen: TAction;
    actClear: TAction;
    actGetAll: TAction;
    actEdit: TAction;
    ToolBar1: TToolBar;
    ToolButton5: TToolButton;
    btnClear: TToolButton;
    ToolButton16: TToolButton;
    btnOpen: TToolButton;
    btnSetName: TToolButton;
    btnEditKeyItem: TToolButton;
    ToolButton24: TToolButton;
    btnGet: TToolButton;
    LV: TListView;
    Memo: TMemo;
    Splitter1: TSplitter;
    ComListMenu: TPopupMenu;
    StatusBar: TStatusBar;
    actSerialNum: TAction;
    actClrDevData: TAction;
    ToolButton1: TToolButton;
    actDecrement: TAction;
    ToolButton2: TToolButton;
    actCheckQuery: TAction;
    ToolButton3: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ComListMenuPopup(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actOpenUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actSerialNumUpdate(Sender: TObject);
    procedure actSerialNumExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actGetAllExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actClrDevDataExecute(Sender: TObject);
    procedure LVDblClick(Sender: TObject);
    procedure actDecrementExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actCheckQueryExecute(Sender: TObject);
  private
    LoaderDrv: TLoaderDev;
    memComNr: Integer;
    serviceMode: boolean; // SERVICE_KEY;

    procedure OnComClickProc(Sender: TObject);
    procedure OnPktCntChgNotifyproc(Sender: TObject; pktCnt: Integer);
    procedure SaveToRegistry;
    procedure ReadFromRegistry;
    procedure ReloadLV;
    procedure OnAllDataRecivedProc(Sender: TObject);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  KeyLogItemUnit;

const
  REG_KEY = '\SOFTWARE\E-LINE\KEY_LOADER';
  SERVICE_KEY = 33567;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LoaderDrv := TLoaderDev.Create;
  LoaderDrv.OnAllDataRecived := OnAllDataRecivedProc;
  LoaderDrv.onPktCntChgNotify := OnPktCntChgNotifyproc;

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  LoaderDrv.Free;

end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ReadFromRegistry;
end;

procedure TMainForm.LVDblClick(Sender: TObject);
begin
  actEditExecute(nil);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveToRegistry;
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
      Reg.WriteInteger('Memo_Width', Memo.Width);
    end;
  finally
    Reg.Free;
  end;
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
begin
  memComNr := -1;
  serviceMode := false;
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

      if Reg.ValueExists('serviceMode') then
        serviceMode := Reg.ReadInteger('serviceMode') = SERVICE_KEY;

      if Reg.ValueExists('ColWidths') then
        setLVWidths(LV, Reg.ReadString('ColWidths'));

      if Reg.ValueExists('Memo_Width') then
        Memo.Width := Reg.ReadInteger('Memo_Width');

    end;
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.actClearExecute(Sender: TObject);
begin
  LoaderDrv.KeyLogData.Clear;
  Memo.Clear;
  ReloadLV;
end;

procedure TMainForm.actClrDevDataExecute(Sender: TObject);
var
  st: TStatus;
  s: string;
begin
  if Application.MessageBox('Czy chcesz skasowaæ ca³¹ zawartoœæ klucza ?', 'Kasowanie danych', MB_YESNO) = idYES then
  begin
    st := LoaderDrv.ClearDevData;
    if st = stOK then
    begin
      actClearExecute(nil);
      Application.MessageBox('Dane skasowane.', 'Kasowanie danych', MB_OK);
    end
    else
    begin
      s := Format('B³¹d kasowania danych: %s', [LoaderDrv.GetErrStr(st)]);
      Application.MessageBox(pchar(s), 'Kasowanie danych', MB_OK or MB_ICONSTOP);

    end;
  end;
end;

procedure TMainForm.actDecrementExecute(Sender: TObject);
var
  n: Integer;
  st: TStatus;
  s: string;
begin
  if Assigned(LV.Selected) then
  begin
    n := LV.Items.IndexOf(LV.Selected);
    st := LoaderDrv.decrementCount(n);
    if st = stOK then
    begin
      Application.MessageBox('Ok.', 'Decrement counter', MB_OK);
      LoaderDrv.ReadWholeData;
    end
    else
    begin
      s := Format('B³¹d dekrementacji: %s', [LoaderDrv.GetErrStr(st)]);
      Application.MessageBox(pchar(s), 'Dekrement counter', MB_OK or MB_ICONSTOP);
    end;
  end;
end;

procedure TMainForm.actCheckQueryExecute(Sender: TObject);
var
  n: Integer;
  st: TStatus;
  activ: byte;
  s: string;
begin
  if Assigned(LV.Selected) then
  begin
    n := LV.Items.IndexOf(LV.Selected);
    st := LoaderDrv.checkKeyQctive(n, activ);
    if st = stOK then
    begin
      case activ of
        keyBAD_RPL:
          s := 'B³¹d odpowiedzi';
        keyNO_ACTIV:
          s := 'Klucz nieaktywny';
        keyACTIV:
          s := 'Klucz aktywny';
      else
        s := 'Niepoprawny wynik';
      end;
      Application.MessageBox(pchar(s), 'SprawdŸ klucz', MB_OK);
      if activ = keyACTIV then
        LoaderDrv.ReadWholeData;
    end
    else
    begin
      s := Format('B³¹d pobrania wartoœci klucza: %s', [LoaderDrv.GetErrStr(st)]);
      Application.MessageBox(pchar(s), 'SprawdŸ klucz', MB_OK or MB_ICONSTOP);
    end;

  end;

end;

procedure TMainForm.actEditExecute(Sender: TObject);
var
  n: Integer;
  dlg: TKeyLogItemForm;
  st: TStatus;
  s: string;

begin
  if Assigned(LV.Selected) then
  begin
    n := LV.Items.IndexOf(LV.Selected);
    dlg := TKeyLogItemForm.Create(self);
    try
      dlg.SetKeyLogItem(n, LoaderDrv.KeyLogData.KeyTab[n]);
      if dlg.ShowModal = mrOK then
      begin
        LoaderDrv.KeyLogData.KeyTab[n] := dlg.GetKeyLogItem;
        st := LoaderDrv.sendKeydata(n);
        if st = stOK then
        begin
          ReloadLV;
        end
        else
        begin
          s := Format('B³¹d zapisu klucza: %s', [LoaderDrv.GetErrStr(st)]);
          Application.MessageBox(pchar(s), 'Edycja danych', MB_OK or MB_ICONSTOP);
        end;
      end;
    finally
      dlg.Free;
    end;
  end;
end;

procedure TMainForm.actEditUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := LoaderDrv.Connected and Assigned(LV.Selected);
end;

procedure TMainForm.actGetAllExecute(Sender: TObject);
begin
  LoaderDrv.ReadWholeData;
end;

procedure TMainForm.actOpenExecute(Sender: TObject);
var
  st: TStatus;
begin
  if LoaderDrv.Connected then
  begin
    LoaderDrv.CloseDev;
  end
  else
  begin
    if memComNr >= 0 then
    begin
      st := LoaderDrv.OpenDev(memComNr);
      if st = stOK then
      begin
        StatusBar.Panels[1].Text := ' Port: COM' + IntToStr(LoaderDrv.ComNr);
        LV.Items.Clear;
        LoaderDrv.KeyLogData.Clear;
      end
      else
        StatusBar.Panels[1].Text := ' Port: ' + LoaderDrv.GetErrStr(st);
    end
    else
      StatusBar.Panels[1].Text := ' Port: ???';
  end;
  StatusBar.Refresh;
end;

procedure TMainForm.actOpenUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked := LoaderDrv.Connected;
end;

procedure TMainForm.actSerialNumExecute(Sender: TObject);
var
  s: string;
  res: TStatus;
begin
  inherited;
  s := IntToStr(LoaderDrv.KeyLogData.Info.Info.SerNumber);
  if InputQuery('Numer seryjny', 'Podaj numer seryjny KeyLog-a', s) then
  begin
    res := LoaderDrv.SetSerailNum(StrToInt(s));
    if res <> stOK then
      Application.MessageBox(pchar(LoaderDrv.GetErrStr(res)), 'B³¹d');
  end;
end;

procedure TMainForm.actSerialNumUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := LoaderDrv.Connected;
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

procedure TMainForm.OnPktCntChgNotifyproc(Sender: TObject; pktCnt: Integer);
begin
  StatusBar.Panels[2].Text := 'Pkt=' + IntToStr(pktCnt);
end;

procedure TMainForm.OnAllDataRecivedProc(Sender: TObject);
  procedure WR(s: string);
  begin
    Memo.Lines.Add(s);
  end;

var
  Info: TKeyLogInfoRec;
begin
  ReloadLV;
  Memo.Lines.BeginUpdate;
  try
    Memo.Lines.Clear;
    Info := LoaderDrv.KeyLogData.Info;
    WR(Format('Firmware       :%u.%.3u', [Info.Ver, Info.Rev]));
    WR(Format('Iloœc pakietów :%u', [Info.PacketCnt]));
    if LoaderDrv.KeyLogData.isDataRdy then
    begin
      WR(Format('Wersja danych  :%u', [Info.Info.Version]));
      WR(Format('Numer seryjny  :%u', [Info.Info.SerNumber]));
      WR(Format('Data produkcji :%s', [DateToStr(UnpackDate(Info.Info.ProductionDate))]));
    end;
  finally
    Memo.Lines.EndUpdate;
  end;

end;

procedure TMainForm.ReloadLV;
var
  n: Integer;
  i: Integer;
  li: TListItem;
  tm: TDateTime;
  Item: TKeyLogData;
begin
  LV.Items.Clear;
  if LoaderDrv.KeyLogData.isDataRdy then
  begin
    n := LoaderDrv.KeyLogData.Info.PacketCnt;
    if n < KEY_CNT_MAX then
    begin
      LV.Items.BeginUpdate;
      try
        LV.Items.Clear;
        for i := 0 to n - 1 do
        begin
          Item := LoaderDrv.KeyLogData.KeyTab[i];
          li := LV.Items.Add;
          li.Caption := IntToStr(i + 1);
          li.SubItems.Add(getKeyName(i));
          li.SubItems.Add(getKeyMod(Item.Mode));
          if Item.Mode = kmdDEMO then
          begin
            tm := UnpackDate(Item.ValidDate);
            li.SubItems.Add(DateToStr(tm));
            li.SubItems.Add(IntToStr(Item.ValidCnt));
          end;
        end;
      finally
        LV.Items.EndUpdate;
      end;
    end
    else
      Application.MessageBox(pchar('Too big packetCnt'), 'Error');
  end;
end;

end.
