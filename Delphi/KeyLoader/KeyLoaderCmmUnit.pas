unit KeyLoaderCmmUnit;

interface

uses
  System.Contnrs,
  Vcl.ExtCtrls, Vcl.Forms,
  classes, Registry, Windows, SysUtils, InterRsd,
  CrcUnit,
  KeyLoaderDef;

const
  stUnknownReply = 30;
  stDevBaseError = 40;
  stDevHalOK = stDevBaseError + 0;
  stDevHalError = stDevBaseError + 1;
  stDevHalBusy = stDevBaseError + 2;
  stDevHalTimeOut = stDevBaseError + 3;

  stDevHalBadCmd = stDevBaseError + 5;
  stDevHalBadRecNr = stDevBaseError + 6;
  stDevHalBadRecMode = stDevBaseError + 7;

type

  TKeyData = record
    Info: TKeyLogInfoRec;
    KeyTab: array [0 .. KEY_CNT_MAX - 1] of TKeyLogData;
    procedure Clear;
    procedure load3Keys(nr: integer; var w);
    function isDataRdy: boolean;
  end;

  TLoaderDev = class;

  TLoaderCom = class(TComDevice)
  private
    mOwner: TLoaderDev;
  protected
    procedure AsynchBinData(Cnt: integer); override;
    procedure doBinData(dtCnt: integer); override;

  public
    constructor Create(Owner: TLoaderDev);

  end;

  // TDataNotify = procedure(Dender: TObject; D: TSkanerObj) of object;
  // TAckSendingNotify = procedure(sender: TObject; msgType: TMesgType) of object;

  TDataNotify = procedure(Dender: TObject; D: TObject) of object;
  TAckSendingNotify = procedure(sender: TObject; msgType: integer) of object;
  TOnPktCntChgNotify = procedure(sender: TObject; pktCnt: integer) of object;

  TLoaderDev = class(TObject)
  private type
    TRplItem = (riTimeOut, riError, riUnknownRpl, riClrMemory, riReadInfo, riReadData, riSetDevInfo, riWriteData,
      riIncCounter, riKeyQuery);
    TRplItems = set of TRplItem;

    TFunResult = record
      RplItems: TRplItems;
      errCode: integer;
      keyActiv : byte; //dla zapytaia 'Q'
      procedure Clear;
    end;

  private
    Com: TLoaderCom;
    mTimeOutTimer: TTimer;
    FunResult: TFunResult;
    mPktCnt: integer;
    globKeyLogQueryIn: TKeyLogQueryIn;
    mInPkt: TKeyLogPacket;

    procedure NewData(buf: TBytes);
    procedure OnTimeOutTimerProc(sender: TObject);
    procedure sendPkt(const pkt: TKeyLogPacket);
    function sendPktWithAck(const pkt: TKeyLogPacket; RplItem: TRplItem): TStatus;
  public
    KeyLogData: TKeyData;
    OnAllDataRecived: TNotifyEvent;
    OnDataNotify: TDataNotify;
    OnAckSendNotify: TAckSendingNotify;
    onPktCntChgNotify: TOnPktCntChgNotify;

    constructor Create;
    destructor destroy; override;
    function Connected: boolean;
    procedure CloseDev;
    function OpenDev(ComNr: integer): TStatus;
    function ComNr: integer;
    function GetErrStr(st: TStatus): string;
    function SetSerailNum(sn: integer): TStatus;
    function sendKeydata(keyNr: integer): TStatus;
    function decrementCount(keyNr: integer): TStatus;
    function checkKeyQctive(keyNr: integer; var activ: byte): TStatus;

    procedure ReadWholeData;
    procedure ReadDevInfo;
    procedure Read3keys(nr: integer);
    function ClearDevData: TStatus;

  end;

procedure LoadRsPorts(Coms: TStrings);
function GetComNr(s: string): integer;

implementation

function GetComNr(s: string): integer;
begin
  Result := StrToInt(copy(s, 4, length(s) - 3));
end;

function MyCompare(List: TStringList; Index1, Index2: integer): integer;
var
  nr1, nr2: integer;
begin
  nr1 := GetComNr(List.Strings[Index1]);
  nr2 := GetComNr(List.Strings[Index2]);
  Result := 0;
  if nr1 > nr2 then
    Result := 1;
  if nr1 < nr2 then
    Result := -1;
end;

procedure LoadRsPorts(Coms: TStrings);
var
  Reg: TRegistry;
  SL: TStringList;
  SLC: TStringList;

  s: string;
  i: integer;
begin
  SL := TStringList.Create;
  SLC := TStringList.Create;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM\') then
    begin
      Reg.GetValueNames(SL);
      for i := 0 to SL.Count - 1 do
      begin
        s := Reg.ReadString(SL.Strings[i]);
        SLC.Add(s);
      end;
    end;
    SLC.CustomSort(MyCompare);
    Coms.Clear;
    Coms.AddStrings(SLC);
  finally
    Reg.free;
    SL.free;
    SLC.free;
  end;
end;

// ----------------------------------------------------------------

procedure TKeyData.Clear;
var
  i: integer;
begin
  Info.Clear;
  for i := 0 to KEY_CNT_MAX - 1 do
    KeyTab[i].Clear;
end;

procedure TKeyData.load3Keys(nr: integer; var w);
var
  key3: array [0 .. 2] of TKeyLogData;
begin
  move(w, key3, sizeof(key3));
  if nr < KEY_CNT_MAX then
    KeyTab[nr].load(key3[0]);
  inc(nr);
  if nr < KEY_CNT_MAX then
    KeyTab[nr].load(key3[1]);
  inc(nr);
  if nr < KEY_CNT_MAX then
    KeyTab[nr].load(key3[2]);
end;

function TKeyData.isDataRdy: boolean;
begin
  Result := true;
  if Info.Info.SerNumber = 0 then
    Result := false;
  if Info.Info.SerNumber = $FFFF then
    Result := false;
  if Info.Info.ProductionDate = 0 then
    Result := false;
  if Info.Info.ProductionDate = $FFFF then
    Result := false;
end;

// ----------------------------------------------------------------
constructor TLoaderCom.Create(Owner: TLoaderDev);
begin
  inherited Create(smBINARY);
  mOwner := Owner;
end;

procedure TLoaderCom.AsynchBinData(Cnt: integer);
begin
  if Cnt >= KEYLOG_PACKET_SIZE then
  begin
    inherited;
  end;
end;

procedure TLoaderCom.doBinData(dtCnt: integer);
begin
  mOwner.NewData(GetBytes);
end;

// -----------------------------------------------------------------
constructor TLoaderDev.Create;
begin
  inherited;
  Com := TLoaderCom.Create(self);
  mTimeOutTimer := TTimer.Create(nil);
  mTimeOutTimer.OnTimer := OnTimeOutTimerProc;
  mTimeOutTimer.Enabled := false;

  OnAllDataRecived := nil;

  OnDataNotify := nil;
end;

destructor TLoaderDev.destroy;
begin
  Com.free;
  inherited;
end;

function TLoaderDev.ComNr: integer;
begin
  Result := Com.ComNr;
end;

function TLoaderDev.GetErrStr(st: TStatus): string;
begin
  Result := '';
  case st of
    stDevHalOK:
      Result := 'devOK';
    stDevHalError:
      Result := 'DevHalError';
    stDevHalBusy:
      Result := 'DevHalBusy';
    stDevHalTimeOut:
      Result := 'DevHalTimeOut';
    stUnknownReply:
      Result := 'UnknownReply';
    stDevHalBadCmd:
      Result := 'DevBadCmd';
    stDevHalBadRecNr:
      Result := 'DevBadRecNr';
    stDevHalBadRecMode:
      Result := 'DevHalBadRecMode';
  else
    if (st >= stDevBaseError) and (st < stDevBaseError + 10) then
    begin
      Result := Format('DevErr:%u', [st]);
    end
    else
      Result := Com.GetErrStr(st);
  end;

  if Result = '' then
    Result := Format('Err, code=%u', [st]);
end;

function TLoaderDev.Connected: boolean;
begin
  Result := Com.Connected;
end;

procedure TLoaderDev.CloseDev;
begin
  Com.CloseDev;
end;

function TLoaderDev.OpenDev(ComNr: integer): TStatus;
begin
  Result := Com.OpenDev(ComNr);
  mPktCnt := 0;
  if Assigned(onPktCntChgNotify) then
    onPktCntChgNotify(self, mPktCnt);
end;

procedure TLoaderDev.TFunResult.Clear;
begin
  fillchar(self, sizeof(self), 0);
end;

procedure TLoaderDev.NewData(buf: TBytes);
var
  pkt: TKeyLogPacket;
  nr: integer;
begin
  if length(buf) >= KEYLOG_PACKET_SIZE then
  begin
    pkt.loadfromTab(buf);
    if pkt.checkValid(mInPkt) then
    begin
      inc(mPktCnt);
      if Assigned(onPktCntChgNotify) then
        onPktCntChgNotify(self, mPktCnt);

      mTimeOutTimer.Enabled := false;
      case pkt.Cmd of
        ord('F'):
          begin
            KeyLogData.Info.load(pkt.Data);
            Read3keys(0);
          end;
        ord('R'):
          begin
            KeyLogData.load3Keys(pkt.RecNr, pkt.Data);
            nr := pkt.RecNr + 3;
            if nr < KeyLogData.Info.PacketCnt then
              Read3keys(nr)
            else
            begin
              if Assigned(OnAllDataRecived) then
                OnAllDataRecived(self);
            end;
          end;
        ord('X'): // potwierdzenie skasowania całej pamięci
          begin
            FunResult.errCode := stDevBaseError + pkt.RecNr;
            if FunResult.errCode = stDevHalOK then
              FunResult.RplItems := FunResult.RplItems + [riClrMemory]
            else
              FunResult.RplItems := FunResult.RplItems + [riError];
          end;
        ord('T'):
          begin
            FunResult.errCode := stDevBaseError + pkt.RecNr;
            if FunResult.errCode = stDevHalOK then
              FunResult.RplItems := FunResult.RplItems + [riSetDevInfo]
            else
              FunResult.RplItems := FunResult.RplItems + [riError];
          end;

        ord('W'):
          begin
            FunResult.errCode := stDevBaseError + pkt.RecNr;
            if FunResult.errCode = stDevHalOK then
              FunResult.RplItems := FunResult.RplItems + [riWriteData]
            else
              FunResult.RplItems := FunResult.RplItems + [riError];
          end;
        ord('I'):
          begin
            FunResult.errCode := stDevBaseError + pkt.RecNr;
            if FunResult.errCode = stDevHalOK then
              FunResult.RplItems := FunResult.RplItems + [riIncCounter]
            else
              FunResult.RplItems := FunResult.RplItems + [riError];
          end;
        ord('Q'):
          begin
            FunResult.keyActiv := KeyLogCheckQueryReply(PKeyLogQueryOut(@pkt.Data)^,globKeyLogQueryIn);
            FunResult.RplItems := FunResult.RplItems + [riKeyQuery]
          end;

        ord('E'): // bład
          begin
            FunResult.RplItems := FunResult.RplItems + [riError];
            FunResult.errCode := stDevBaseError + pkt.RecNr;
          end;

      else
        begin
          FunResult.RplItems := FunResult.RplItems + [riUnknownRpl];
        end;

      end;
    end
    else
    begin
      OutputDebugString('Pkt_not_valid');
    end;
  end
  else
  begin
    OutputDebugString('Pkt_to_short');
  end;
end;

procedure TLoaderDev.OnTimeOutTimerProc(sender: TObject);
begin
  mTimeOutTimer.Enabled := false;
  FunResult.RplItems := FunResult.RplItems + [riTimeOut];
end;

procedure TLoaderDev.sendPkt(const pkt: TKeyLogPacket);
begin
  mInPkt := pkt;
  Com.ClrRecData;
  Com.RsWrite(pkt, sizeof(pkt));
  mTimeOutTimer.Interval := 1000;
  mTimeOutTimer.Enabled := true;
  FunResult.Clear;
end;

function TLoaderDev.sendPktWithAck(const pkt: TKeyLogPacket; RplItem: TRplItem): TStatus;
var
  RplAll: TRplItems;
begin
  sendPkt(pkt);
  RplAll := [RplItem] + [riTimeOut, riError];
  Result := stOk;
  while true do
  begin
    Application.ProcessMessages;
    sleep(5);
    if FunResult.RplItems * RplAll <> [] then
    begin
      if RplItem in FunResult.RplItems then
      begin
        Result := stOk;
        break;
      end;
      if riTimeOut in FunResult.RplItems then
      begin
        Result := stTimeOut;
        break;
      end;
      if riError in FunResult.RplItems then
      begin
        Result := FunResult.errCode;
        break;
      end;
    end;
    if FunResult.RplItems - RplAll <> [] then
    begin
      Result := stUnknownReply;
      break;
    end;
  end;

end;

procedure TLoaderDev.ReadWholeData;
begin
  KeyLogData.Clear;
  ReadDevInfo;
end;

procedure TLoaderDev.ReadDevInfo;
var
  rec: TKeyLogPacket;
begin
  rec.Clear;
  rec.Cmd := ord('F');
  rec.ValidRec;
  sendPkt(rec);
end;

procedure TLoaderDev.Read3keys(nr: integer);
var
  rec: TKeyLogPacket;
begin
  rec.Clear;
  rec.Cmd := ord('R');
  rec.RecNr := nr;
  rec.ValidRec;
  sendPkt(rec);
end;

function TLoaderDev.ClearDevData: TStatus;
var
  rec: TKeyLogPacket;
begin
  rec.Clear;
  rec.Cmd := ord('X');
  rec.RecNr := $77;
  rec.ValidRec;
  Result := sendPktWithAck(rec, riClrMemory);
end;

function TLoaderDev.SetSerailNum(sn: integer): TStatus;
var
  pkt: TKeyLogPacket;
  Info: PKeyLogInfoRec;
begin
  pkt.Clear;
  pkt.Cmd := ord('T');
  Info := PKeyLogInfoRec(@pkt.Data);
  Info.Info.SerNumber := sn;
  Info.Info.ProductionDate := PackDate(Now);
  Info.Info.Version := DATA_VERSION;
  pkt.ValidRec;
  Result := sendPktWithAck(pkt, riSetDevInfo);
end;

function TLoaderDev.sendKeydata(keyNr: integer): TStatus;
var
  pkt: TKeyLogPacket;
  dPtr: PKeyLogData;
  i: integer;
begin
  pkt.Clear;
  pkt.Cmd := ord('W');
  pkt.RecNr := keyNr;
  dPtr := PKeyLogData(@pkt.Data);

  dPtr^ := KeyLogData.KeyTab[keyNr];

  pkt.ValidRec;
  Result := sendPktWithAck(pkt, riWriteData);
end;

function TLoaderDev.decrementCount(keyNr: integer): TStatus;
var
  pkt: TKeyLogPacket;
  dPtr: PKeyLogIncRec;
  i: integer;
begin
  pkt.Clear;
  pkt.Cmd := ord('I');
  pkt.RecNr := keyNr;
  dPtr := PKeyLogIncRec(@pkt.Data);
  dPtr.RecNr := keyNr;
  dPtr.IncDec := 0; // decrement
  pkt.ValidRec;
  Result := sendPktWithAck(pkt, riIncCounter);
end;

function TLoaderDev.checkKeyQctive(keyNr: integer; var activ: byte): TStatus;
var
  pkt: TKeyLogPacket;
begin
  KeyLogQueryBuild(globKeyLogQueryIn, keyNr);

  pkt.Clear;
  pkt.Cmd := ord('Q');
  pkt.loadData(globKeyLogQueryIn);
  pkt.ValidRec;
  Result := sendPktWithAck(pkt, riKeyQuery);
  activ := FunResult.keyActiv;
end;

end.
