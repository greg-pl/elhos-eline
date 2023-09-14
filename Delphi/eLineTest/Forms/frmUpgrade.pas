unit frmUpgrade;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, registry,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids;

type
  TUpgradeForm = class(TBaseELineForm)
    Memo: TMemo;
    Button1: TButton;
    FileNameEdit: TLabeledEdit;
    CheckClearBtn: TButton;
    SendFileBtn: TButton;
    ClearFlashBtn: TButton;
    VerifyBtn: TButton;
    ExecProgBtn: TButton;
    StatusBar1: TStatusBar;
    VerGrid: TStringGrid;
    AutoUpdateBtn: TButton;
    VerifyUserFlashBtn: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckClearBtnClick(Sender: TObject);
    procedure SendFileBtnClick(Sender: TObject);
    procedure ClearFlashBtnClick(Sender: TObject);
    procedure VerifyBtnClick(Sender: TObject);
    function onMsgReadUserFlash(buf: TBytes): boolean;
    procedure ExecProgBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AutoUpdateBtnClick(Sender: TObject);
    procedure VerGridDblClick(Sender: TObject);
    procedure VerifyUserFlashBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private const
    MAX_BUF_SIZE = 1024;
    USER_FLASH_SIZE = 3 * 128 * 1024;

  private type
    TSendRec = record
      sendBuffer: TBytes;
      sndNr: integer;
      function isDone: boolean;
      function getSekCnt: integer;
      function readFile(FName: string): boolean;
    end;

    TReadRec = record
      buf: TBytes;
      rdNr: integer;
      userFlash : boolean;  // czy odczyt UserFlash czy BaseFlash
      function isDone: boolean;
    end;
  private
    mSendRec: TSendRec;
    mReadRec: TReadRec;
    mAutoMode: boolean;

    procedure sendPart;
    procedure readPart(userFlash : boolean);
    procedure SetStatusText(s: string);
    procedure Wr(s: string);
    procedure FillVerGrid;
    procedure sendClearUserflash;
    procedure sendCheckFlashClear;
    procedure startSendFile;
    procedure startVerifyFile(userFlash : boolean);
    procedure ExecStartProg;

  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}

uses
  Main,
  eLineTestDef;

procedure TUpgradeForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  registry: TRegistry;
  devType: TElineDevType.T;
  key: string;
begin
  inherited;
  registry := TRegistry.Create;
  try
    if registry.OpenKey(REG_KEY, false) then
    begin
      devType := mELineDev.DevState.DevInfo.getDevType;
      key := 'UpdateFile_' + TElineDevType.getTypNameHid(devType);
      registry.WriteString(key, FileNameEdit.Text);
    end;
  finally
    registry.Free;
  end;
end;

procedure TUpgradeForm.FormCreate(Sender: TObject);
begin
  inherited;
  VerGrid.Rows[0].CommaText := 'lp Ver czas';
  VerGrid.Cols[0].CommaText := 'lp Device File';
end;

procedure TUpgradeForm.FormShow(Sender: TObject);
var
  q : boolean;
begin
  inherited;
  q := MainForm.ProducerMode;
  VerifyUserFlashBtn.Visible := q;
  SendFileBtn.Visible := q;
  ExecProgBtn.Visible := q;
  ClearFlashBtn.Visible := q;
  CheckClearBtn.Visible := q;
end;

procedure TUpgradeForm.setELineDev(aDev: TBaseELineDev);
var
  registry: TRegistry;
  devType: TElineDevType.T;
  key: string;
begin
  inherited;
  caption := 'Upgrade:' + mELineDev.getCpxName;
  BringUp;

  registry := TRegistry.Create;
  try
    if registry.OpenKey(REG_KEY, false) then
    begin
      devType := mELineDev.DevState.DevInfo.getDevType;
      key := 'UpdateFile_' + TElineDevType.getTypNameHid(devType);

      if registry.ValueExists(key) then
        FileNameEdit.Text := registry.ReadString(key);
    end;
  finally
    registry.Free;
  end;
  FillVerGrid;
end;

procedure TUpgradeForm.FillVerGrid;
var
  fileVer: TKVerInfo;
begin
  VerGrid.Cells[1, 1] := mELineDev.DevState.DevInfo.firmVer.getAsString;
  VerGrid.Cells[2, 1] := mELineDev.DevState.DevInfo.firmVer.time.getAsString;
  if FileNameEdit.Text <> '' then
  begin
    if mSendRec.readFile(FileNameEdit.Text) then
    begin
      if fileVer.loadFromBytes(mSendRec.sendBuffer) then
      begin
        VerGrid.Cells[1, 2] := fileVer.getAsString;
        VerGrid.Cells[2, 2] := fileVer.time.getAsString;

      end;
    end;

  end;

end;

procedure TUpgradeForm.VerGridDblClick(Sender: TObject);
begin
  inherited;
  FillVerGrid;
end;

procedure TUpgradeForm.VerifyBtnClick(Sender: TObject);
begin
  inherited;
  startVerifyFile(false);
end;

procedure TUpgradeForm.VerifyUserFlashBtnClick(Sender: TObject);
begin
  inherited;
  startVerifyFile(true);
end;

procedure TUpgradeForm.startVerifyFile(userFlash : boolean);
begin
  if mSendRec.readFile(FileNameEdit.Text) then
  begin
    setlength(mReadRec.buf, USER_FLASH_SIZE);
    mReadRec.rdNr := 0;
    mReadRec.userFlash := userFlash;
    readPart(userFlash);
  end;
end;

procedure TUpgradeForm.Wr(s: string);
begin
  Memo.Lines.Add(s);
end;

procedure TUpgradeForm.Button1Click(Sender: TObject);
var
  dlg: TOpenDialog;
begin
  inherited;
  dlg := TOpenDialog.Create(self);
  try
    if FileNameEdit.Text <> '' then
      dlg.FileName := FileNameEdit.Text;

    dlg.DefaultExt := '.bin';
    dlg.Filter := 'Pliki binarne|*.bin|Wszystkie pliki|*.*';
    if dlg.Execute then
    begin
      FileNameEdit.Text := dlg.FileName;
      FillVerGrid;
    end;

  finally
    dlg.Free;
  end;

end;

procedure TUpgradeForm.CheckClearBtnClick(Sender: TObject);
begin
  inherited;
  sendCheckFlashClear;
end;

procedure TUpgradeForm.readPart(userFlash : boolean);
type
  TRdDt = record
    Adr: cardinal;
    dtLen: cardinal;
  end;
var
  RdDt: TRdDt;
  code : TDevCommonObjCode;
begin
  if userFlash then
    code := msgReadUserFlash
  else
    code := msgReadBaseFlash;

  RdDt.Adr := mReadRec.rdNr * MAX_BUF_SIZE;
  RdDt.dtLen := MAX_BUF_SIZE;
  mELineDev.addReqest(dsdDEV_COMMON, ord(code), RdDt, sizeof(RdDt));
  mELineDev.sendBufferNow;
end;

procedure TUpgradeForm.sendPart;
type
  TSndDt = record
    Adr: cardinal;
    dtLen: cardinal;
    buf: array [0 .. MAX_BUF_SIZE - 1] of byte;
  end;
var
  SndDt: TSndDt;
  n: integer;
begin
  n := length(mSendRec.sendBuffer) - MAX_BUF_SIZE * mSendRec.sndNr;
  if n > MAX_BUF_SIZE then
    n := MAX_BUF_SIZE;
  if n > 0 then
  begin

    fillchar(SndDt.buf, MAX_BUF_SIZE, 0);
    move(mSendRec.sendBuffer[MAX_BUF_SIZE * mSendRec.sndNr], SndDt.buf[0], n);

    n := ((n + 3) div 4) * 4;
    SndDt.dtLen := n;
    SndDt.Adr := MAX_BUF_SIZE * mSendRec.sndNr;

    mELineDev.addReqest(dsdDEV_COMMON, ord(msgWriteUserFlash), SndDt, 8 + n);
    mELineDev.sendBufferNow;
    inc(mSendRec.sndNr);
    SetStatusText(Format('%u/%u', [mSendRec.sndNr, mSendRec.getSekCnt]));
  end;
end;

procedure TUpgradeForm.SetStatusText(s: string);
begin
  StatusBar1.Panels[1].Text := s;
end;

function TUpgradeForm.TSendRec.isDone: boolean;
begin
  Result := (MAX_BUF_SIZE * sndNr >= length(sendBuffer));
end;

function TUpgradeForm.TSendRec.getSekCnt: integer;
begin
  Result := (length(sendBuffer) + (MAX_BUF_SIZE - 1)) div MAX_BUF_SIZE;
end;

function TUpgradeForm.TSendRec.readFile(FName: string): boolean;
var
  strm: TMemoryStream;
  q: boolean;
begin
  inherited;
  strm := TMemoryStream.Create;
  try
    strm.LoadFromFile(FName);
    setlength(sendBuffer, strm.Size);
    strm.Read(sendBuffer[0], strm.Size);
    q := true;
  finally
    strm.Free;
  end;
  Result := q;
end;

function TUpgradeForm.TReadRec.isDone: boolean;
begin
  Result := (rdNr >= USER_FLASH_SIZE / MAX_BUF_SIZE);
end;

procedure TUpgradeForm.SendFileBtnClick(Sender: TObject);
begin
  startSendFile;
end;

procedure TUpgradeForm.startSendFile;
var
  q: boolean;
begin
  inherited;
  q := mSendRec.readFile(FileNameEdit.Text);
  if q then
  begin
    mSendRec.sndNr := 0;
    sendPart;
  end;
end;

procedure TUpgradeForm.ClearFlashBtnClick(Sender: TObject);
begin
  inherited;
  sendClearUserflash;
end;

procedure TUpgradeForm.ExecProgBtnClick(Sender: TObject);
begin
  inherited;
  ExecStartProg;

end;

procedure TUpgradeForm.ExecStartProg;
var
  M: cardinal;
begin
  Wr('Uruchomienie podmiany firmware');
  mSendRec.readFile(FileNameEdit.Text);
  M := length(mSendRec.sendBuffer);
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgExecUpdate), M, sizeof(M));
  mELineDev.sendBufferNow;
end;

function TUpgradeForm.onMsgReadUserFlash(buf: TBytes): boolean;

type
  TRdAnsw = packed record
    status: byte;
    Free: TByte3;
    Adr: cardinal;
    dtLen: cardinal;
  end;

var
  ans: TRdAnsw;
  er: TKStatus.T;
  q: boolean;
  i, n: integer;
begin
  Result := false;
  q := false;
  if length(buf) >= sizeof(ans) then
  begin
    move(buf[0], ans, sizeof(ans));
    er := TKStatus.getCode(ans.status);
    if er = stOK then
    begin
      if length(buf) >= sizeof(ans) + integer(ans.dtLen) then
      begin
        if ans.Adr + ans.dtLen <= USER_FLASH_SIZE then
        begin
          move(buf[sizeof(ans)], mReadRec.buf[ans.Adr], ans.dtLen);
          q := true;
        end;

      end;

    end
    else
      SetStatusText(TKStatus.getTxt(er));

  end
  else
    SetStatusText('Done. Bad answer');
  if q then
  begin
    inc(mReadRec.rdNr);
    if mReadRec.isDone = false then
    begin
      readPart(mReadRec.userFlash);
      SetStatusText(Format('%u/%u', [mReadRec.rdNr, 3 * 128]));
    end
    else
    begin
      Wr('Odczytane');
      SetStatusText('Done.');

      n := length(mSendRec.sendBuffer);
      for i := 0 to n - 1 do
      begin
        if mSendRec.sendBuffer[i] <> mReadRec.buf[i] then
        begin
          q := false;
          break;
        end;
      end;
      if q then
      begin
        Wr('Porównanie - OK');
        Result := true;
      end
      else
        Wr('Porównanie - Inne')
    end;

  end;
end;

procedure TUpgradeForm.RecivedObj(obj: TKobj);

var
  er: TKStatus.T;
begin
  if (obj.srcDev = dsdDEV_COMMON) then
  begin
    case obj.obCode of
      ord(msgDevInfo):
        FillVerGrid;
      ord(msgClrUserFlash):
        // rozkaz kasowania USER flash
        begin
          er := TKStatus.getCode(obj.data[0]);
          if er = stOK then
          begin
            Wr('Kasowanie poprawne');
            if mAutoMode then
              sendCheckFlashClear;
          end
          else
            Wr('B³ad kasowania :' + TKStatus.getTxt(er));

        end;

      ord(msgCheckFlashClear):
        begin
          er := TKStatus.getCode(obj.data[0]);
          if er = stOK then
          begin
            Wr('Flash is Clear');
            if mAutoMode then
              startSendFile;
          end
          else
            Wr('FlashClear:' + TKStatus.getTxt(er));
        end;

      ord(msgWriteUserFlash): // zapis USER FLASH
        begin
          er := TKStatus.getCode(obj.data[0]);
          if er = stOK then
          begin
            if not mSendRec.isDone then
              sendPart
            else
            begin
              SetStatusText('Done');
              Wr('File sended');
              if mAutoMode then
                startVerifyFile(true);
            end;
          end
          else
          begin
            SetStatusText('B³¹d : ' + TKStatus.getTxt(er));
            Wr('B³¹d : ' + TKStatus.getTxt(er));
          end;
        end;

      ord(msgReadBaseFlash): // odczyt zawartoœci g³ownego flasha
        ;
      ord(msgReadUserFlash): // odczyt zawartoœci USER Flash
        begin
          if onMsgReadUserFlash(obj.data) then
          begin
            if mAutoMode then
              ExecStartProg;
          end;

        end;

      ord(msgExecUpdate): // skopiowanie nowej wersji w aktualnej
        ;
    end;

  end;
end;

procedure TUpgradeForm.sendCheckFlashClear;
begin
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgCheckFlashClear));
end;

procedure TUpgradeForm.sendClearUserflash;
begin
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgClrUserFlash));
end;

procedure TUpgradeForm.AutoUpdateBtnClick(Sender: TObject);
begin
  inherited;
  mAutoMode := true;
  sendClearUserflash;
end;

procedure TUpgradeForm.BringUp;
begin

end;

end.
