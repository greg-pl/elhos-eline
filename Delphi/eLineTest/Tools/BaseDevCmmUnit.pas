unit BaseDevCmmUnit;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs, ExtCtrls,
  // WinSock,
  WinSock2,
  CmmObjDefinition,
  DevDefinitionUnit,
  Base64Tools,
  eLineDef,
  NetToolsUnit;

const
  wm_RecivedObj = wm_user + 100;
  wm_Connected = wm_user + 101;
  wm_DeviceReady = wm_user + 102; // wysy³any po odczytaniu DevceInfo

type
  TSimpTcp = class(TObject)
  private type
    TSockCheckMthd = function(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer of object;

  private
    fSd: TSocket;
    FIp: string;
    function SockCheckRead(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
    function SockCheckWrite(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
    function SockCheckExcept(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
  protected
    FLastErr: integer;
    FPort: word;
    FConnected: boolean;
    FNonBlkMode: boolean;
    MaxRecBuf: integer;
    MaxSndBuf: integer;

    procedure FSetIp(aIp: string);
    function LoadLastErr(Res: TStatus): TStatus;
    function FillINetStruct(var Addr: TSockAddr; IP: string; Port: word): TStatus; overload;
    function FillINetStruct(var Addr: TSockAddr; IPd: cardinal; Port: word): TStatus; overload;
    function SockCheck(const aCheckMthd: TSockCheckMthd): boolean; overload;
    function SockCheck(const aCheckMthd: TSockCheckMthd; aTime: integer): boolean; overload;
  public
    RecWaitTime: integer;
    SndWaitTime: integer;
    OnMsgReadCnt: integer;
    SendItemCnt: integer;

    property Sd: TSocket read fSd;
    constructor Create;
    destructor Destroy; override;
    function Open: TStatus;
    function Close: TStatus;

    function CheckRead: boolean; overload;
    function CheckRead(Time: integer): boolean; overload;
    function CheckWrite: boolean; // inline;
    function CheckExcept: boolean; // inline;
    function IsConnected: boolean; // inline;

    property LastErr: integer read FLastErr;
    property Port: word read FPort write FPort;
    property IP: string read FIp write FSetIp;

    function Write(txt: AnsiString): TStatus;
    function Read(Var buf; var Len: integer): TStatus;
    function ReadStr(Var txt: AnsiString): TStatus;
    function ClearInpBuf: TStatus;
  end;

  TBaseELineDev = class(TThread)
  private

  private

    const
    TM_SEND_BUF = 300;
    STX = #2;
    ETX = #3;
    TM_DATA_MAX_IN_BUF = 500; // maksymalny czas w buforze
    TM_DATA_JOIN = 250; // 250[ms] - czas sklejania danych
  private type
    TSendRec = class(TObject)
      mOutStream: TOutTrackStream;
      mOutCriSection: TRTLCriticalSection;
      mAddSendItemTick: cardinal; // czas w³ozenia do bufora ostatniego elementu
      mAddFirstTick: cardinal; // czas w³ozenia do bufora pierwszego elementu
      mSendNowFlag: boolean; // wymuszenie wys³ania bufora
      mSendTick: cardinal; // czas wys³ania bufora
      constructor Create;
      destructor Destroy; override;
      procedure addItem(dst: TTrkDev; code: byte; const dt; dt_size: integer);
      function canAdd(size: integer): boolean;
      function isTimeToSend: boolean;
      procedure clear;
    end;

    TKObjList = class(TObjectList)
    private
      mListCriSection: TRTLCriticalSection;
      function FGetItem(Index: integer): TKobj;
    public
      constructor Create;
      destructor Destroy; override;
      property Items[Index: integer]: TKobj read FGetItem;
      procedure Add(obj: TKobj);
      function Pop(var obj: TKobj): boolean;
    end;

    TPartInf = record
      ptr: pointer;
      Len: integer;
    end;

    TReciveRec = class(TObject)
    strict private
      mBuf: TBytes;
      mHead: integer;
      mTail: integer;
      mBufSize: integer;
    public
      constructor Create(size: integer);
      destructor Destroy; override;
      procedure Clear;
      function incIdx(idx: integer): integer;
      function decIdx(idx: integer): integer;
      function getPart: TPartInf;
      procedure addPart(Len: integer);
      function getStxEtxStr: AnsiString;
    end;

  private const
    HPOS_EVENT = 0;
    HPOS_SOCKET = 1;
    KEEP_ALIVE_TIME = 1000;
    MAX_NO_RECIVE_TIME = 10000;

  private
    mSocket: TSimpTcp;
    mSendRec: TSendRec;
    mReciveRec: TReciveRec;
    mRecKObjList: TKObjList;

    mReciveTick: cardinal;
    mKeepAliveRectick: cardinal;
    mKeepAliveCnt: integer;

    mHandleTab: TWOHandleArray;
    mMyHandle: THandle;
    mStateConnect: boolean;
    mConnected: boolean;
    mDoClose: boolean;
    mIP: string;
    mIpBin: cardinal;
    procedure setConnected(q: boolean);
    procedure _LoopOpen;
    procedure _LoopWork;
    procedure _readSocket;
    procedure WndProc(var AMessage: TMessage);
    procedure wmRecivedObj(var AMessage: TMessage); message wm_RecivedObj;
    procedure wmConnectedObj(var AMessage: TMessage); message wm_Connected;
    procedure wmDeviceReady(var AMessage: TMessage); message wm_DeviceReady;

  protected
    procedure Execute; override;
  protected

    procedure _DoOnUserEvent; virtual;
    procedure _DoOnException; virtual;
    procedure _doLoopTick; virtual;
    procedure _doAfterOpenConnection; virtual;

  public type
    TDevState = record
      flagDevInfo: boolean;
      DevInfo: TKDevInfo;
      DevId: string; // zmienna ³adowana z TKDevInfo lub z kana³u UDP
      SerNum: string; // zmienna ³adowana z TKDevInfo lub z kana³u UDP
      msgCnt: integer;
      procedure clear;
    end;

  public
    OnReciveObjNotify: TNotifyEvent;
    OnConnectedNotify: TNotifyEvent;
    OnDeviceRdyNotify: TNotifyEvent;
    DevState: TDevState;

    constructor Create;
    destructor Destroy; override;
    procedure Connect;
    procedure DisConnect;
    function IsConnected: boolean;

    procedure _sendBuffer;
    procedure addReqest(dst: TTrkDev; code: byte; const dt; dt_size: integer); overload;
    procedure addReqest(dst: TTrkDev; code: byte); overload;
    procedure addReqest(dst: TTrkDev; code: byte; buf: TBytes); overload;

    procedure sendBufferNow;
    procedure setIp(aIp: string);
    procedure setDevID(DevId: string);
    procedure setDevSerNum(SerNum: string);

    function popRecKobj(var obj: TKobj): boolean;
    function getIpBin: cardinal;
    function getIp: string;
    function getCpxName: string;
    function getDevTypeName: string;
  public
    procedure makeReboot;
  end;

implementation

// -------------------------- TSimpSock ----------------------------------

constructor TSimpTcp.Create;
begin
  inherited Create;
  fSd := INVALID_SOCKET;
  FPort := 0;
  FIp := '';
  RecWaitTime := 250;
  SndWaitTime := 250;
  FNonBlkMode := true;
end;

destructor TSimpTcp.Destroy;
begin
  Close;
  inherited;
end;

function TSimpTcp.LoadLastErr(Res: TStatus): TStatus;
begin
  if (Res <> stOk) then
    FLastErr := WSAGetLastError
  else
    FLastErr := stOk;
  Result := FLastErr
end;

function TSimpTcp.Open: TStatus;
var
  n: integer;
  s: u_long;
  size: integer;
  Addr: TSockAddr;
  i: integer;

begin
  Result := stOk;
  if Sd <> INVALID_SOCKET then
  begin
    Result := Close;
  end;

  FConnected := false;

  fSd := WinSock2.Socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if Result <> integer(INVALID_SOCKET) then
  begin
    if FNonBlkMode then
      s := 1 // 1-nonbloking mode;
    else
      s := 0; // 0-bloking mode;
    Result := ioctlsocket(Sd, Longint(FIONBIO), s);
  end;
  if Result = stOk then
  begin
    size := $20000;
    Result := setsockopt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@size), SizeOf(size));
  end;
  if Result = stOk then
  begin
    n := SizeOf(MaxRecBuf);
    Result := GetSockOpt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@MaxRecBuf), n);
  end;
  if Result = stOk then
  begin
    size := $20100;
    Result := setsockopt(Sd, SOL_SOCKET, SO_SNDBUF, PAnsiChar(@size), SizeOf(size));
  end;
  if Result = stOk then
  begin
    n := SizeOf(MaxSndBuf);
    Result := GetSockOpt(Sd, SOL_SOCKET, SO_SNDBUF, PAnsiChar(@MaxSndBuf), n);
  end;

  if FillINetStruct(Addr, FIp, FPort) = stOk then
  begin
    // socket is non-blocking (connection attempt cannot be completed immediately)
    // so there will be error on connect
    { Result := }
    WinSock2.Connect(Sd, Addr, SizeOf(Addr));
    for i := 0 to 5 do
    begin
      FConnected := CheckWrite;
      if FConnected then
        break;
      sleep(100);
    end;
  end
  else
    Result := stError;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Close: TStatus;
begin
  Result := stOk;
  if cardinal(Sd) <> cardinal(INVALID_SOCKET) then
  begin
    shutdown(Sd, SD_Send);
    Result := CloseSocket(Sd);
    fSd := INVALID_SOCKET;
    Result := LoadLastErr(Result);
  end;
  FConnected := false;
end;

function TSimpTcp.CheckRead(Time: integer): boolean;
begin
  Result := SockCheck(SockCheckRead, Time);
end;

function TSimpTcp.CheckRead: boolean;
begin
  Result := SockCheck(SockCheckRead)
end;

function TSimpTcp.CheckWrite: boolean;
begin
  Result := SockCheck(SockCheckWrite)
end;

function TSimpTcp.FillINetStruct(var Addr: TSockAddr; IP: string; Port: word): TStatus;
var
  IPd: cardinal;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sa_family := PF_INET;
  sockaddr_in(Addr).sin_port := HToNs(Port);
  Result := StrToInetAdr(IP, IPd);
  sockaddr_in(Addr).sin_addr.S_addr := IPd;
end;

function TSimpTcp.FillINetStruct(var Addr: TSockAddr; IPd: cardinal; Port: word): TStatus;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sa_family := PF_INET;
  sockaddr_in(Addr).sin_port := HToNs(Port);
  sockaddr_in(Addr).sin_addr.S_addr := integer(IPd);
  Result := stOk;
end;

procedure TSimpTcp.FSetIp(aIp: string);
begin
  FIp := aIp;
end;

function TSimpTcp.SockCheck(const aCheckMthd: TSockCheckMthd): boolean;
begin
  Result := SockCheck(aCheckMthd, RecWaitTime);
end;

function TSimpTcp.SockCheck(const aCheckMthd: TSockCheckMthd; aTime: integer): boolean;
const
  SOCKET_COUNT = 1;
var
  FdSet: TFdSet;
  TimeVal: TTimeVal;
begin
  Result := false;
  Assert(FD_SETSIZE >= SOCKET_COUNT);
  FdSet.fd_array[0] := fSd;
  FdSet.fd_count := SOCKET_COUNT;
  TimeVal.tv_sec := aTime div 1000;
  TimeVal.tv_usec := (aTime * 1000) mod 1000000;
  case aCheckMthd(TimeVal, FdSet) of
    0: // timeout
      FLastErr := WSAETIMEDOUT;
    SOCKET_ERROR:
      LoadLastErr(SOCKET_ERROR);
    1 .. FD_SETSIZE:
      Result := FdSet.fd_count = SOCKET_COUNT
  else
    Assert(false, 'TSimpSock.SockCheck()')
  end
end;

function TSimpTcp.SockCheckExcept(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := select(0, nil, nil, @aFdSet, @aTimeVal)
end;

function TSimpTcp.SockCheckRead(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := select(0, @aFdSet, nil, nil, @aTimeVal)
end;

function TSimpTcp.SockCheckWrite(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := select(0, nil, @aFdSet, nil, @aTimeVal)
end;

function TSimpTcp.CheckExcept: boolean;
begin
  Result := SockCheck(SockCheckExcept)
end;

function TSimpTcp.IsConnected: boolean;
begin
  Result := FConnected;
end;

function TSimpTcp.Write(txt: AnsiString): TStatus;
begin
  inc(SendItemCnt);
  Result := send(Sd, txt[1], length(txt), 0);
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Read(Var buf; var Len: integer): TStatus;
var
  l: integer;
begin
  l := recv(Sd, buf, Len, 0);
  if l <> SOCKET_ERROR then
  begin
    Len := l;
    Result := stOk;
  end
  else
    Result := WSAGetLastError;
end;

function TSimpTcp.ReadStr(Var txt: AnsiString): TStatus;
var
  l: u_long;
  Li: integer;
begin
  txt := '';
  Result := ioctlsocket(Sd, FIONREAD, l);
  if (Result = stOk) and (l > 0) then
  begin
    Li := l;
    SetLength(txt, Li);
    Result := Read(txt[1], Li);
  end;
end;

function TSimpTcp.ClearInpBuf: TStatus;
var
  buf: TBytes;
  l: u_long;
  Li: integer;
begin
  repeat
    Result := ioctlsocket(Sd, FIONREAD, l);
    if (Result = stOk) and (l > 0) then
    begin
      Li := l;
      SetLength(buf, Li);
      Result := Read(buf[0], Li);
    end;
  until (Result <> stOk) or (l = 0);
  Result := LoadLastErr(Result);
end;

// -----------------------------------------------------------------------------
// TBaseELineDev.TSendRec
// -----------------------------------------------------------------------------
constructor TBaseELineDev.TSendRec.Create;
begin
  inherited;
  InitializeCriticalSection(mOutCriSection);
  mOutStream := TOutTrackStream.Create;
  clear;
end;

destructor TBaseELineDev.TSendRec.Destroy;
begin
  inherited;
  mOutStream.Free;
  DeleteCriticalSection(mOutCriSection);
end;

procedure TBaseELineDev.TSendRec.clear;
begin
  mOutStream.clear;
  mSendNowFlag := false;
  mAddSendItemTick := 0;
  mAddFirstTick := 0;
end;

procedure TBaseELineDev.TSendRec.addItem(dst: TTrkDev; code: byte; const dt; dt_size: integer);
begin
  EnterCriticalSection(mOutCriSection);
  try
    mAddSendItemTick := GetTickCount;
    if mOutStream.getDtLen = 0 then
      mAddFirstTick := mAddSendItemTick;
    mOutStream.addItem(dst, code, dt, dt_size);
  finally
    LeaveCriticalSection(mOutCriSection);
  end;
end;

function TBaseELineDev.TSendRec.canAdd(size: integer): boolean;
begin
  Result := (mOutStream.getDtLen + size + 4 < TRACK_BUF_SIZE);
end;

function TBaseELineDev.TSendRec.isTimeToSend: boolean;
var
  tt: cardinal;
begin
  Result := false;
  if mOutStream.getDtLen > 0 then
  begin
    tt := GetTickCount;
    Result := mSendNowFlag;
    Result := Result or (tt - mAddSendItemTick > TM_DATA_JOIN);
    Result := Result or (tt - mAddFirstTick > TM_DATA_MAX_IN_BUF);
  end;
end;

// -- TKObjList -----------------------------------------------

constructor TBaseELineDev.TKObjList.Create;
begin
  inherited Create(false);
  InitializeCriticalSection(mListCriSection);

end;

destructor TBaseELineDev.TKObjList.Destroy;
begin
  DeleteCriticalSection(mListCriSection);
  inherited;
end;

function TBaseELineDev.TKObjList.FGetItem(Index: integer): TKobj;
begin
  Result := inherited GetItem(Index) as TKobj;
end;

procedure TBaseELineDev.TKObjList.Add(obj: TKobj);
begin
  EnterCriticalSection(mListCriSection);
  try
    inherited Add(obj);
  finally
    LeaveCriticalSection(mListCriSection);
  end;
end;

function TBaseELineDev.TKObjList.Pop(var obj: TKobj): boolean;
begin
  Result := false;
  EnterCriticalSection(mListCriSection);
  try
    if Count > 0 then
    begin
      obj := Items[0];
      Remove(obj);
      Result := true;
    end;
  finally
    LeaveCriticalSection(mListCriSection);
  end;
end;

// -- TReciveRec -----------------------------------------------
constructor TBaseELineDev.TReciveRec.Create(size: integer);
begin
  inherited Create;
  SetLength(mBuf, size);
  mBufSize := size;
  Clear;
end;

destructor TBaseELineDev.TReciveRec.Destroy;
begin
  inherited;
  SetLength(mBuf, 0);
end;

procedure TBaseELineDev.TReciveRec.Clear;
begin
  mHead := 0;
  mTail := 0;
end;


function TBaseELineDev.TReciveRec.getPart: TPartInf;
begin
  Result.ptr := @(mBuf[mHead]);
  if mHead >= mTail then
  begin
    Result.Len := mBufSize - mHead;
    if mTail = 0 then
      dec(Result.Len);
  end
  else
  begin

    Result.Len := mTail - mHead - 1;
  end;
end;

procedure TBaseELineDev.TReciveRec.addPart(Len: integer);
begin
  mHead := mHead + Len;
  if mHead > mBufSize then
    raise Exception.Create('GK: TBaseELineDev.TReciveRec.addPart Error');
  if mHead = mBufSize then
    mHead := 0;
end;

function TBaseELineDev.TReciveRec.incIdx(idx: integer): integer;
begin
  inc(idx);
  if idx = mBufSize then
    idx := 0;
  Result := idx;
end;

function TBaseELineDev.TReciveRec.decIdx(idx: integer): integer;
begin
  if idx = 0 then
    idx := mBufSize;
  dec(idx);
  Result := idx;
end;

function TBaseELineDev.TReciveRec.getStxEtxStr: AnsiString;
  function CutString(b_idx, e_idx: integer): AnsiString;
  var
    n: integer;
    i: integer;
    idx: integer;
  begin
    n := e_idx - b_idx;
    if n < 0 then
      n := n + mBufSize;
    SetLength(Result, n);

    idx := b_idx;
    for i := 1 to n do
    begin
      Result[i] := AnsiChar(mBuf[idx]);
      idx := incIdx(idx);
    end;
  end;

var
  idx: integer;
  bg_idx: integer;
  n: integer;
begin
  Result := '';
  idx := mTail;
  bg_idx := -1;
  n := 0;
  while idx <> mHead do
  begin
    if mBuf[idx] = ord(STX) then
      bg_idx := incIdx(idx);
    if mBuf[idx] = ord(ETX) then
    begin
      mTail := incIdx(idx);
      if bg_idx >= 0 then
      begin
        Result := CutString(bg_idx, idx);
        break;
      end
      else
      begin
        OutputDebugString(pchar(Format('TBaseELineDev.TReciveRec.getStxEtxStr: usuniêcie %u bytes', [n])));
        n := 0;
      end;
    end;
    idx := incIdx(idx);
    inc(n);
    if n > 2 * TRACK_BUF_SIZE then
    begin
      OutputDebugString('TBaseELineDev.TReciveRec.getStxEtxStr: RESET bufora wejœciowego');
      mHead := 0;
      mTail := 0;
      break;
    end;
  end;

end;

// -- TDevState -----------------------------------------------
procedure TBaseELineDev.TDevState.clear;
begin
  msgCnt := 0;
  flagDevInfo := false;
end;

// -- TBaseELineDev -----------------------------------------------
constructor TBaseELineDev.Create;
begin
  inherited;
  OnReciveObjNotify := nil;
  OnConnectedNotify := nil;
  OnDeviceRdyNotify := nil;

  mConnected := false;
  mDoClose := false;

  mSocket := TSimpTcp.Create;
  mRecKObjList := TKObjList.Create;

  mHandleTab[HPOS_EVENT] := CreateEvent(nil, false, true, nil);
  mHandleTab[HPOS_SOCKET] := WSACreateEvent;
  mSendRec := TSendRec.Create;
  mReciveRec := TReciveRec.Create(16 * TRACK_BUF_SIZE);
  mMyHandle := Classes.AllocateHWnd(WndProc);

end;

destructor TBaseELineDev.Destroy;
begin
  Terminate;
  SetEvent(mHandleTab[HPOS_EVENT]);
  WaitFor;
  Classes.DeallocateHWnd(mMyHandle);
  CloseHandle(mHandleTab[HPOS_EVENT]);
  WSACloseEvent(mHandleTab[HPOS_SOCKET]);
  mSendRec.Free;
  mReciveRec.Free;
  FreeAndNil(mRecKObjList);
  mSocket.Free;
  inherited;
end;

procedure TBaseELineDev.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

procedure TBaseELineDev._DoOnUserEvent;
begin

end;

procedure TBaseELineDev._DoOnException;
begin

end;

procedure TBaseELineDev._doLoopTick;
begin

end;

procedure TBaseELineDev._doAfterOpenConnection;
var
  tm: TKDATE;
begin
  tm.setNow;
  // ustawienie czasu
  addReqest(dsdDEV_COMMON, ord(msgSetTime), tm, SizeOf(tm));
  // pobranie informacji o urz¹dzeniu
  addReqest(dsdDEV_COMMON, ord(msgDevInfo));
end;

procedure TBaseELineDev._readSocket;

// odbiór danych z Socketa i wstawienie do bufora ko³owego
  procedure LoadfromSocket;
  var
    PartInf: TPartInf;
    Len: integer;
    reclen: integer;
  begin
    while true do
    begin
      PartInf := mReciveRec.getPart;
      Len := PartInf.Len;
      reclen := 0;
      if mSocket.Read(PartInf.ptr^, Len) = stOk then
      begin
        reclen := Len;
        mReciveRec.addPart(Len);
        mReciveTick := GetTickCount;
      end;
      if reclen = 0 then
        break;
    end;
  end;

// odbiór danych z bufora ko³owego  i wstawienie do listy komend
  function SendToList: integer;
  var
    str: AnsiString;
    buf: TBytes;
    inpStream: TInTrackStream;
    obj: TKobj;
  begin
    Result := 0;
    inpStream := TInTrackStream.Create;
    try
      while true do
      begin
        str := mReciveRec.getStxEtxStr;
        if str = '' then
          break;
        buf := DecodeBase64(str);
        inpStream.setBuffer(buf);
        while inpStream.PopObj(obj) do
        begin
          if (obj.srcDev = dsdDEV_COMMON) and (obj.obCode = ord(msgKeepAlive)) then
          begin
            mKeepAliveRectick := GetTickCount;
            inc(mKeepAliveCnt);
          end
          else
            mRecKObjList.Add(obj);
          inc(Result);
        end;
      end;
    finally
      inpStream.Free;
    end;
  end;

var
  n: integer;
begin
  LoadfromSocket;
  n := SendToList;
  if n > 0 then
    PostMessage(mMyHandle, wm_RecivedObj, n, 0);

end;

procedure TBaseELineDev.setConnected(q: boolean);
begin
  mConnected := q;
  PostMessage(mMyHandle, wm_Connected, 0, 0);
end;

procedure TBaseELineDev._LoopWork;
var
  waitRes: DWORD;
  mNetEvent: TWSANetworkEvents;
begin
  mReciveTick := GetTickCount;
  while mConnected and not(Terminated) do
  begin
    waitRes := WaitForMultipleObjects(2, @mHandleTab, false, 50);
    if waitRes = STATUS_TIMEOUT then
    begin
      try
        _doLoopTick;
      except
        _DoOnException;
      end;
    end;

    if waitRes = STATUS_WAIT_0 + HPOS_SOCKET then
    begin
      // Socket Events
      if WSAENUMNetworkEvents(mSocket.Sd, mHandleTab[HPOS_SOCKET], mNetEvent) <> SOCKET_ERROR then
      begin
        if (mNetEvent.lNetworkEvents and FD_READ) <> 0 then
        begin
          _readSocket;
        end;
        if (mNetEvent.lNetworkEvents and FD_CLOSE) <> 0 then
        begin
          mSocket.Close;
          setConnected(false);
        end;
        if (mNetEvent.lNetworkEvents and FD_WRITE) <> 0 then
        begin
          _sendBuffer;
        end;
        if (mNetEvent.lNetworkEvents and FD_CONNECT) <> 0 then
        begin
          if not mSocket.CheckWrite then
          begin
            mDoClose := true;
            OutputDebugString('Close connection 2');
          end;
        end;
      end;
    end;

    if (waitRes = STATUS_TIMEOUT) or (waitRes = STATUS_WAIT_0 + HPOS_EVENT) then
    begin
      try
        if not(mStateConnect) then
        begin
          mSocket.Close;
          setConnected(false);
        end;

        if mSendRec.isTimeToSend then
        begin
          _sendBuffer;
        end;
        _DoOnUserEvent;
      except
        _DoOnException;
      end;
    end;

    if GetTickCount - mReciveTick > MAX_NO_RECIVE_TIME then
    begin
      mDoClose := true;
      OutputDebugString('Close connection 1');
    end;

    if GetTickCount - mSendRec.mSendTick > KEEP_ALIVE_TIME then
    begin
      addReqest(dsdDEV_COMMON, ord(msgKeepAlive));
      _sendBuffer;
    end;

    if mDoClose then
    begin
      mDoClose := false;
      mSocket.Close;
      setConnected(false);
    end;

  end;
  // FSimpTcp.Close;
  FreeOnTerminate := true;
end;

procedure TBaseELineDev._LoopOpen;
var
  waitRes: DWORD;
begin
  while (not Terminated) and (not mConnected) do
  begin
    waitRes := WaitForSingleObject(mHandleTab[HPOS_EVENT], 500);
    // OutputDebugString('LoopOpen');
    if waitRes = STATUS_TIMEOUT then
    begin

    end;
    if mStateConnect then
    begin
      mSocket.Port := TRACK_IP_PORT;
      mSocket.IP := mIP;
      mSocket.Open;
      if mSocket.IsConnected then
      begin
        DevState.clear;
        mReciveRec.Clear;
        setConnected(true);
        WSAEventSelect(mSocket.Sd, mHandleTab[HPOS_SOCKET], FD_READ or FD_CLOSE or FD_WRITE or FD_CONNECT);
        _doAfterOpenConnection;
      end;
    end;
  end;
end;

procedure TBaseELineDev.Execute;
begin
  mConnected := false;
  while not Terminated do
  begin
    _LoopOpen;
    if not Terminated then
      _LoopWork;
  end;
  FreeOnTerminate := false;
end;

// funkcja wywo³ywana z tasku g³ownego i z tasku w¹tku
procedure TBaseELineDev._sendBuffer;
var
  str1: AnsiString;
  str2: AnsiString;
  n: integer;
begin

  EnterCriticalSection(mSendRec.mOutCriSection);
  try
    str1 := EncodeBase64(mSendRec.mOutStream.getBuf);
    if str1 <> '' then
    begin
      n := length(str1);
      SetLength(str2, n + 2);
      str2[1] := STX;
      move(str1[1], str2[2], n);
      str2[n + 2] := ETX;
      mSocket.Write(str2);
      mSendRec.clear;
      mSendRec.mSendTick := GetTickCount;
    end;
  finally
    LeaveCriticalSection(mSendRec.mOutCriSection);
  end;
end;

procedure TBaseELineDev.addReqest(dst: TTrkDev; code: byte; const dt; dt_size: integer);
begin
  if not mSendRec.canAdd(dt_size) then
    _sendBuffer;
  mSendRec.addItem(dst, code, dt, dt_size);

  SetEvent(mHandleTab[HPOS_EVENT]);
end;

procedure TBaseELineDev.addReqest(dst: TTrkDev; code: byte);
var
  b: byte;
begin
  addReqest(dst, code, b, 0);
end;

procedure TBaseELineDev.addReqest(dst: TTrkDev; code: byte; buf: TBytes);
begin
  addReqest(dst, code, buf[0], length(buf));
end;

procedure TBaseELineDev.sendBufferNow;
begin
  mSendRec.mSendNowFlag := true;
  SetEvent(mHandleTab[HPOS_EVENT]);
end;

procedure TBaseELineDev.setIp(aIp: string);
var
  tmpBinIp: cardinal;
begin
  StrToIP(aIp, tmpBinIp);
  if tmpBinIp <> mIpBin then
  begin
    mIP := aIp;
    mIpBin := tmpBinIp;
    if mConnected then
    begin
      mDoClose := true;
      SetEvent(mHandleTab[HPOS_EVENT]);
      OutputDebugString('Close connection 3');

    end;
  end;
end;

procedure TBaseELineDev.setDevID(DevId: string);
begin
  DevState.DevId := DevId;
end;

procedure TBaseELineDev.setDevSerNum(SerNum: string);
begin
  DevState.SerNum := SerNum;
end;

procedure TBaseELineDev.Connect;
begin
  mStateConnect := true;
  SetEvent(mHandleTab[HPOS_EVENT]);
end;

procedure TBaseELineDev.DisConnect;
begin
  mStateConnect := false;
  SetEvent(mHandleTab[HPOS_EVENT]);
end;

function TBaseELineDev.IsConnected: boolean;
begin
  Result := mConnected;
end;

function TBaseELineDev.popRecKobj(var obj: TKobj): boolean;
begin
  if not Assigned(mRecKObjList) then
    raise Exception.Create('TBaseELineDev.popRecKobj: mRecKObjList=nil');
  Result := mRecKObjList.Pop(obj);
  if Result then
  begin
    inc(DevState.msgCnt);
    if obj.srcDev = dsdDEV_COMMON then
    begin
      case obj.obCode of
        ord(msgDevInfo):
          begin
            try
              DevState.DevInfo.Load(obj.data);
              DevState.DevId := DevState.DevInfo.getDevID;
              DevState.SerNum := DevState.DevInfo.getSerialNr;
              PostMessage(mMyHandle, wm_DeviceReady, 0, 0);
              DevState.flagDevInfo := true;
            except

            end;

          end;
      end;
    end;
  end;
end;

procedure TBaseELineDev.wmRecivedObj(var AMessage: TMessage);
begin
  if Assigned(OnReciveObjNotify) then
    OnReciveObjNotify(self);
end;

procedure TBaseELineDev.wmConnectedObj(var AMessage: TMessage);
begin
  if Assigned(OnConnectedNotify) then
    OnConnectedNotify(self);
end;

procedure TBaseELineDev.wmDeviceReady(var AMessage: TMessage);
begin
  if Assigned(OnDeviceRdyNotify) then
    OnDeviceRdyNotify(self);
end;

function TBaseELineDev.getIpBin: cardinal;
begin
  Result := mIpBin;
end;

function TBaseELineDev.getIp: string;
begin
  Result := mIP;
end;

function TBaseELineDev.getCpxName: string;
begin
  Result := DevState.DevId;
end;

function TBaseELineDev.getDevTypeName: string;
begin
  Result := DevState.DevInfo.getDevTypAsStr;
end;

// -----------------------------
procedure TBaseELineDev.makeReboot;
begin
  addReqest(dsdDEV_COMMON, ord(msgExecReset));
end;

end.
