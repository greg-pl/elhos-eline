unit SimpSock;

interface

uses
  Classes, Windows, WinSock, Messages, Types, SysUtils, Contnrs;

const
  wm_SocketEvent = wm_user + 100;
  wm_CloseClient = wm_user + 101;

type
  TStatus = integer;

const
  stOk = 0;
  stTimeOut = 1;
  stNotOpen = 12;
  stUserBreak = 15;
  stFrmTooLarge = 16;
  stError = -1;

type
  TRdEvent = procedure(Sender: TObject; RecIp: string; RecPort: word; RecBuf: string) of object;
  TMsgFlow = procedure(Sender: TObject; R: real) of object;

  TSockCheckMthd = function(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer of object;

  TWSAEvent = (wsaREAD, wsaWRITE, wsaOOB, wsaACCEPT, wsaCONNECT, wsaCLOSE);
  TWSAEvents = set of TWSAEvent;

  TSimpSock = class(TObject)
  private
    fSd: TSocket;
    FMsgFlow: TMsgFlow;
    FAsync: boolean;
    FIp: string;
    FBinIp: cardinal;
    procedure WndProc(var AMessage: TMessage);
    procedure SetMsgFlow(R: real);
    function SockCheckRead(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
    function SockCheckWrite(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
    function SockCheckExcept(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer; // inline;
  protected
    FOwnHandle: THandle;
    FLastErr: integer;
    FPort: word;
    mBreakFlag: boolean;
    FWsaEvents: TWSAEvents;
    FConnected: boolean;

    procedure FSetIp(aIp: string);
    procedure FSetBinIp(aBinIp: cardinal);
    function LoadLastErr(Res: TStatus): TStatus;
    procedure wmSocketEvent(var AMessage: TMessage); message wm_SocketEvent;

    procedure DoOnMsgRead; virtual;
    procedure DoOnMsgWrite; virtual;
    procedure DoOnMsgOOB; virtual;
    procedure DoOnAccept; virtual;
    procedure DoOnConnect; virtual;
    procedure DoOnClose; virtual;
    procedure DoOnException; virtual;
    function FillINetStruct(var Addr: sockaddr_in; IP: string; Port: word): TStatus; overload;
    function FillINetStruct(var Addr: sockaddr_in; IPd: cardinal; Port: word): TStatus; overload;
    property Sd: TSocket read fSd write fSd;
    function SetWsaEvents: integer;
    procedure FSetAsync(AAsync: boolean);
    function FGetAsync: boolean;
  public
    ExceptCnt: integer;
    RecWaitTime: integer;
    SndWaitTime: integer;
    constructor Create;
    destructor Destroy; override;
    function Open: TStatus; virtual;
    function Close: TStatus; virtual;
    procedure SetBreakFlag;
    function GetHandle: THandle;
    procedure Freehandle;
    function SockCheck(const aCheckMthd: TSockCheckMthd): boolean; overload;
    function SockCheck(const aCheckMthd: TSockCheckMthd; aTime: integer): boolean; overload;
    function CheckRead: boolean; overload;
    function CheckRead(Time: integer): boolean; overload;
    function CheckWrite: boolean; // inline;
    function CheckExcept: boolean; // inline;
    function IsConnected: boolean; // inline;

    property LastErr: integer read FLastErr;
    property Port: word read FPort write FPort;
    property IP: string read FIp write FSetIp;
    property BinIp: cardinal read FBinIp write FSetBinIp;
    function DSwap(X: cardinal): cardinal;
    property MsgFlow: TMsgFlow read FMsgFlow write FMsgFlow;
    property Socket: TSocket read fSd;
    property Async: boolean read FGetAsync write FSetAsync;
  end;

  TSimpUdp = class(TSimpSock)
  protected
    RecBuf: string;
    RecIp: string;
    RecPort: word;
    FOnMsgRead: TRdEvent;
    procedure DoOnMsgRead; override;
  public
    VPort: word;
    constructor Create;
    function Open: TStatus; override;
    function Close: TStatus; override;
    function ReadFromSocket(var RecBuf: string; var RecIp: string; var RecPort: word): TStatus;
    function SendBuf(DestIp: string; DestPort: word; var buf; Len: integer): TStatus; overload;
    function SendBuf(DestIp: cardinal; DestPort: word; var buf; Len: integer): TStatus; overload;
    function SendStr(DestIp: string; DestPort: word; ToSnd: string): TStatus; overload;
    function SendStr(IPd: cardinal; DestPort: word; ToSnd: string): TStatus; overload;
    function BrodcastStr(DestPort: word; ToSnd: string): TStatus;
    function ClearRecBuf: TStatus;
    function EnableBrodcast(Enable: boolean): TStatus;
    property OnMsgRead: TRdEvent read FOnMsgRead write FOnMsgRead;
  end;

  TTcpRdEvent = procedure(Sender: TObject; RecBuf: string) of object;

  TSimpTcp = class(TSimpSock)
  private
    MaxRecBuf: integer;
    MaxSndBuf: integer;
    FRestReadStrLN: string;
  protected
    FNonBlkMode: boolean;
    procedure DoOnConnect; override;
    procedure DoOnClose; override;
    procedure DoOnMsgRead; override;
    procedure DoOnMsgWrite; override;
  public
    OnConnect: TNotifyEvent;
    OnClose: TNotifyEvent;
    OnMsgRead: TNotifyEvent;
    OnMsgWrite: TNotifyEvent;
    constructor Create;
    function Open: TStatus; override;
    function Close: TStatus; override;
    function Connect: TStatus; virtual;
    function ReOpen: TStatus;
    function Write(Var buf; Len: integer): TStatus;
    function WriteStr(txt: string): TStatus;
    function WriteStream(Stream: TMemoryStream): TStatus;
    function Read(Var buf; var Len: integer): TStatus;
    function ReadStr(Var txt: string): TStatus;

    // ReadStream: MaxBytes: zabezpieczenie przed allokacj¹ zbyt wielkich bloków pamiêci
    // MaxTimeMsec : Maksymalny okres oczekiwania na kompletacjê danych
    function ReadStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
    function ReadBinaryStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
    function ReciveToBufTime(StartT: cardinal; var buf; Count: integer): TStatus;
    function ClearInpBuf: TStatus;
  end;

  TLockString = class(TObject)
  private
    FMyStr: string;
    flNew: boolean;
    CriSection: TRTLCriticalSection;
    function FGetString: string;
    procedure FSetString(s: string);
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    property s: string read FGetString write FSetString;
    function IsNew: boolean;
  end;

  // TCPServer

  TSimpServerTCP = class;

  TClientTaskList = class;

  TClientTask = class(TThread)
  private
    FSimpTcp: TSimpTcp;
    FOwnerList: TClientTaskList;
    procedure OnSocketClose(Sender: TObject);
  protected
    procedure Execute; override;
    procedure ReciveMsg(s: string); virtual;
    procedure SocketClose; virtual;
    procedure Start(aSd: TSocket; RecIp: string; RecPort: word); virtual;
    procedure Closed; virtual;
  public
    ClientIP: string;
    ClientIPBin: cardinal;
    ClientPort: word;
    constructor Create(aOwnerList: TClientTaskList); virtual;
    destructor Destroy; override;
    procedure Stop;
    procedure Send(txt: string);
  end;

  TClientTaskList = class(TObjectList)
  private
    FCriSection: TRTLCriticalSection;
    function FGetItem(Index: integer): TClientTask;
    procedure Lock;
    procedure Unlock;
  public
    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TClientTask read FGetItem;
    procedure WaitForAll;
    procedure Add(task: TClientTask);
    procedure Remoove(task: TClientTask);
    procedure CloseClients;
  end;

  TClientTaskClass = class of TClientTask;

  TSerwerLisenTask = class(TThread)
  protected
    ClientTaskClass: TClientTaskClass;
    FListenSocket: TSocket;
    FOwner: TSimpServerTCP;
    FLastErr: integer;
    FDoListen: boolean;
    procedure Execute; override;
  public
    constructor Create(aOwner: TSimpServerTCP);
    destructor Destroy; override;
    procedure StartListen(Sd: TSocket; aClientTaskClass: TClientTaskClass);
    procedure StopListen;
  end;

  TSimpServerTCP = class(TSimpTcp)
  private
    FClientTaskList: TClientTaskList;
    FListenTask: TSerwerLisenTask;
  public
    constructor Create;
    destructor Destroy; override;
    function StartListen(aClientTaskClass: TClientTaskClass): integer;
    procedure StopListen;
    function GetClientsCnt: integer;
  end;

  // TCPAsynchServer

  TAsynchClientList = class;
  TAsynchServerTCP = class;

  TAsynchClient = class(TSimpTcp)
  private
    FOwner: TAsynchServerTCP;
  protected
    procedure DoCloseMe;
    procedure DoOnClose; override;
    procedure Start(aSd: TSocket; RecIp: string; RecPort: word); virtual;
  public
    constructor Create(aOwner: TAsynchServerTCP); virtual;
    destructor Destroy; override;
  end;

  TAsynchClientClass = class of TAsynchClient;

  TAsynchClientList = class(TObjectList)
  private
    function FGetItem(Index: integer): TAsynchClient;
  public
    property Items[Index: integer]: TAsynchClient read FGetItem;
    procedure Add(task: TAsynchClient);
  end;

  TAsynchServerTCP = class(TSimpTcp)
  private
    FClientList: TAsynchClientList;
    FClientClass: TAsynchClientClass;
    function FGetItem(Index: integer): TAsynchClient;
    procedure wmCloseClient(var AMessage: TMessage); message wm_CloseClient;
  protected
    procedure DoOnAccept; override;
  public
    property Items[Index: integer]: TAsynchClient read FGetItem;
    constructor Create(aAsynchClientClass: TAsynchClientClass);
    destructor Destroy; override;
    function StartListen: integer;
    procedure StopListen;
    function Count: integer;
  end;

function StrToInetAdr(IP: string; var IPd: cardinal): TStatus;
function DSwap(X: cardinal): cardinal;
function IpToStr(IP: cardinal): string;
procedure GetLocalAdresses(SL: TStrings);
function GetLocalAdress: string;
function GetHostName: string;
function StrToIP(s: string; var IP: cardinal): boolean;

var
  SocketsVersion: integer;
  SocketRevision: integer;
  SocketsOk: boolean;

implementation

function StrToIP(s: string; var IP: cardinal): boolean;
var
  a: integer;
  b: array [0 .. 3] of cardinal;
  err: boolean;
  X, k, i, l: integer;
  s1: string;
begin
  IP := 0;
  l := length(s);
  i := 1;
  err := false;
  for k := 0 to 3 do
  begin
    X := i;
    while (i <= l) and (s[i] <> '.') do
      inc(i);
    s1 := copy(s, X, i - X);
    inc(i);
    if s1 <> '' then
    begin
      try
        a := StrToInt(s1);
        if (a > 255) or (a < 0) then
          err := false
        else
          b[k] := a;
      except
        err := true;
      end;
    end
    else
    begin
      err := true;
      break;
    end;
  end;
  if not(err) then
  begin
    IP := (b[3] shl 24) or (b[2] shl 16) or (b[1] shl 8) or b[0];
  end;
  Result := not(err);
end;

function DSwap(X: cardinal): cardinal;
begin
  Result := Swap(X shr 16) or (Swap(X and $FFFF) shl 16);
end;

function IpToStr(IP: cardinal): string;
var
  b1, b2, b3, b4: byte;
begin
  IP := DSwap(IP);
  b1 := (IP shr 24) and $FF;
  b2 := (IP shr 16) and $FF;
  b3 := (IP shr 8) and $FF;
  b4 := IP and $FF;
  Result := Format('%u.%u.%u.%u', [b1, b2, b3, b4]);
end;

function GetHostName: string;
var
  s1 : AnsiString;
begin
  SetLength(s1, 250);
  WinSock.GetHostName(PAnsiChar(s1), length(s1));
  Result := String(PAnsiChar(s1));
end;

procedure GetLocalAdresses(SL: TStrings);
type
  TaPInAddr = Array [0 .. 250] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  i: integer;
  AHost: PHostEnt;
  PAdrPtr: PaPInAddr;
  hostName : AnsiString;
begin
  SL.Clear;

  SetLength(hostName, 250);
  WinSock.GetHostName(PAnsiChar(hostName), length(hostName));


  AHost := GetHostByName(PAnsiChar(hostName));
  if AHost <> nil then
  begin
    PAdrPtr := PaPInAddr(AHost^.h_addr_list);
    i := 0;
    while PAdrPtr^[i] <> nil do
    begin
      SL.Add(IpToStr(cardinal(PAdrPtr^[i].S_addr)));
      inc(i);
    end;
  end;
end;

function GetLocalAdress: string;
var
  SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    GetLocalAdresses(SL);
    if SL.Count > 0 then
      Result := SL.Strings[0];
  finally
    SL.Free;
  end;
end;

function StrToInetAdr(IP: string; var IPd: cardinal): TStatus;
begin
  if IP <> '' then
  begin
    if not(StrToIP(IP, IPd)) then
    begin
      WinSock.WSASetLastError(WSAEFAULT);
      Result := WSAEFAULT;
    end
    else
      Result := stOk;
  end
  else
  begin
    IPd := 0;
    Result := stOk;
  end;
end;


// -------------------------- TSimpSock ----------------------------------

constructor TSimpSock.Create;
begin
  inherited Create;
  Sd := INVALID_SOCKET;
  FOwnHandle := INVALID_HANDLE_VALUE;
  FPort := 0;
  FIp := '';
  ExceptCnt := 0;
  RecWaitTime := 200; // 200 milisekund
  SndWaitTime := 200; // 200 milisekund
  FWsaEvents := [wsaREAD, wsaCONNECT, wsaCLOSE];
end;

function TSimpSock.LoadLastErr(Res: TStatus): TStatus;
begin
  if (Res <> stOk) then
    FLastErr := WSAGetLastError
  else
    FLastErr := stOk;
  Result := FLastErr
end;

function TSimpSock.Open: TStatus;
begin
  Result := stOk;
  if Sd <> INVALID_SOCKET then
  begin
    Result := Close;
  end;
end;

function TSimpSock.Close: TStatus;
begin
  Result := stOk;
  if Sd <> INVALID_SOCKET then
  begin
    Result := WinSock.shutdown(Sd, SD_Send);
    if Result = stOk then
      Result := WinSock.CloseSocket(Sd);
    if Result = stOk then
      Sd := INVALID_SOCKET;
    Result := LoadLastErr(Result);
  end;
  FConnected := false;
end;

destructor TSimpSock.Destroy;
begin
  Close;
  Freehandle;
  inherited;
end;

procedure TSimpSock.SetBreakFlag;
begin
  mBreakFlag := true;
end;

function TSimpSock.GetHandle: THandle;
begin
  if FOwnHandle = INVALID_HANDLE_VALUE then
  begin
    FOwnHandle := Classes.AllocateHWnd(WndProc);
  end;
  Result := FOwnHandle;
end;

procedure TSimpSock.Freehandle;
begin
  if FOwnHandle <> INVALID_HANDLE_VALUE then
  begin
    Classes.DeallocateHWnd(FOwnHandle);
  end;
end;

procedure TSimpSock.SetMsgFlow(R: real);
begin
  if Assigned(FMsgFlow) then
    FMsgFlow(self, R);
end;

procedure TSimpSock.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

procedure TSimpSock.wmSocketEvent(var AMessage: TMessage);
var
  Ev: word;
begin
  try
    Ev := LoWord(AMessage.LParam);
    if (Ev and FD_READ) <> 0 then
      DoOnMsgRead;
    if (Ev and FD_WRITE) <> 0 then
      DoOnMsgWrite;
    if (Ev and FD_OOB) <> 0 then
      DoOnMsgOOB;
    if (Ev and FD_ACCEPT) <> 0 then
      DoOnAccept;
    if (Ev and FD_CONNECT) <> 0 then
      DoOnConnect;
    if (Ev and FD_CLOSE) <> 0 then
      DoOnClose;
  except
    DoOnException;
  end;
end;

procedure TSimpSock.DoOnMsgRead;
begin
end;

procedure TSimpSock.DoOnMsgWrite;
begin
end;

procedure TSimpSock.DoOnMsgOOB;
begin
end;

procedure TSimpSock.DoOnAccept;
begin
end;

procedure TSimpSock.DoOnConnect;
begin
end;

procedure TSimpSock.DoOnClose;
begin
  FConnected := false;
end;

procedure TSimpSock.DoOnException;
begin

end;

function TSimpSock.CheckRead(Time: integer): boolean;
begin
  Result := SockCheck(SockCheckRead, Time);
end;

function TSimpSock.CheckRead: boolean;
begin
  Result := SockCheck(SockCheckRead)
end;

function TSimpSock.CheckWrite: boolean;
begin
  Result := SockCheck(SockCheckWrite)
end;

function TSimpSock.FillINetStruct(var Addr: sockaddr_in; IP: string; Port: word): TStatus;
var
  IPd: cardinal;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := PF_INET;
  Addr.sin_port := WinSock.HToNs(Port);
  Result := StrToInetAdr(IP, IPd);
  Addr.sin_addr.S_addr := integer(IPd);
end;

function TSimpSock.FillINetStruct(var Addr: sockaddr_in; IPd: cardinal; Port: word): TStatus;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family := PF_INET;
  Addr.sin_port := WinSock.HToNs(Port);
  Addr.sin_addr.S_addr := integer(IPd);
  Result := stOk;
end;

function TSimpSock.SetWsaEvents: integer;
var
  w: cardinal;
begin
  w := 0;
  if wsaREAD in FWsaEvents then
    w := w or FD_READ;
  if wsaWRITE in FWsaEvents then
    w := w or FD_WRITE;
  if wsaOOB in FWsaEvents then
    w := w or FD_OOB;
  if wsaACCEPT in FWsaEvents then
    w := w or FD_ACCEPT;
  if wsaCONNECT in FWsaEvents then
    w := w or FD_CONNECT;
  if wsaCLOSE in FWsaEvents then
    w := w or FD_CLOSE;
  GetHandle;
  Result := WSAAsyncSelect(Sd, FOwnHandle, wm_SocketEvent, w);
  if Result <> 0 then
    Result := WSAGetLastError;
end;

procedure TSimpSock.FSetIp(aIp: string);
begin
  FIp := aIp;
  StrToIP(aIp, FBinIp);
end;

procedure TSimpSock.FSetBinIp(aBinIp: cardinal);
begin
  FBinIp := aBinIp;
  FIp := IpToStr(FBinIp);
end;

procedure TSimpSock.FSetAsync(AAsync: boolean);
var
  p: TStatus;
begin
  p := stOk;
  if AAsync then
  begin
    if not(FAsync) then
    begin
      GetHandle;
      p := SetWsaEvents;
    end;
  end
  else
  begin
    if FAsync then
    begin
      p := WSAAsyncSelect(Sd, FOwnHandle, 0, 0);
    end;
  end;
  FAsync := AAsync;
  LoadLastErr(p);
end;

function TSimpSock.FGetAsync: boolean;
begin
  Result := FAsync; // (FownHandle<>INVALID_HANDLE_VALUE);
end;

function TSimpSock.DSwap(X: cardinal): cardinal;
begin
  Result := Swap(X shr 16) or (Swap(X and $FFFF) shl 16);
end;

function TSimpSock.SockCheck(const aCheckMthd: TSockCheckMthd): boolean;
begin
  Result := SockCheck(aCheckMthd, RecWaitTime);
end;

function TSimpSock.SockCheck(const aCheckMthd: TSockCheckMthd; aTime: integer): boolean;
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

function TSimpSock.SockCheckExcept(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := WinSock.select(0, nil, nil, @aFdSet, @aTimeVal)
end;

function TSimpSock.SockCheckRead(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := WinSock.select(0, @aFdSet, nil, nil, @aTimeVal)
end;

function TSimpSock.SockCheckWrite(const aTimeVal: TTimeVal; const aFdSet: TFdSet): integer;
begin
  Result := WinSock.select(0, nil, @aFdSet, nil, @aTimeVal)
end;

function TSimpSock.CheckExcept: boolean;
begin
  Result := SockCheck(SockCheckExcept)
end;

function TSimpSock.IsConnected: boolean;
begin
  Result := FConnected;
end;

// -------------------------- TSimpUdp ----------------------------------

constructor TSimpUdp.Create;
begin
  inherited Create;
  RecWaitTime := 200; // 200 milisekund
  SndWaitTime := 200; // 200 milisekund
  FAsync := false;
end;

function TSimpUdp.Open: TStatus;
var
  N: integer;
  LAddr: sockaddr_in;
  Addr: sockaddr_in;
begin
  Result := inherited Open;
  if Result = stOk then
  begin
    Sd := WinSock.Socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if Sd = INVALID_SOCKET then
      Result := WSAGetLastError;
  end;
  EnableBrodcast(true);
  if Result = stOk then
    Result := FillINetStruct(Addr, FIp, FPort);
  if Result = stOk then
  begin
    Result := WinSock.bind(Sd, Addr, SizeOf(Addr));
  end;
  if Result = stOk then
  begin
    N := SizeOf(LAddr);
    Result := GetSockName(Sd, LAddr, N);
  end;

  if Result = stOk then
  begin
    VPort := Ntohs(LAddr.sin_port);
    FSetAsync(true);
  end;
  Result := LoadLastErr(Result);
end;

function TSimpUdp.Close: TStatus;
begin
  FSetAsync(false);
  Result := inherited Close;
end;

function TSimpUdp.EnableBrodcast(Enable: boolean): TStatus;
var
  State: integer;
begin
  if Enable then
    State := 1
  else
    State := 0;
  Result := setsockopt(Sd, SOL_SOCKET, SO_BROADCAST, @State, SizeOf(State));
  Result := LoadLastErr(Result);
end;

function TSimpUdp.SendBuf(DestIp: string; DestPort: word; var buf; Len: integer): TStatus;
var
  Addr: sockaddr_in;
begin
  Result := FillINetStruct(Addr, DestIp, DestPort);
  if Result = stOk then
    Result := WinSock.sendto(Sd, buf, Len, 0, Addr, SizeOf(Addr));
  Result := LoadLastErr(Result);
end;

function TSimpUdp.SendBuf(DestIp: cardinal; DestPort: word; var buf; Len: integer): TStatus;
var
  Addr: sockaddr_in;
begin
  Result := FillINetStruct(Addr, DestIp, DestPort);
  if Result = stOk then
    Result := WinSock.sendto(Sd, buf, Len, 0, Addr, SizeOf(Addr));
  Result := LoadLastErr(Result);
end;

function TSimpUdp.SendStr(DestIp: string; DestPort: word; ToSnd: string): TStatus;
var
  s1: AnsiString;
begin
  if ToSnd <> '' then
  begin
    s1 := AnsiString(ToSnd);
    Result := SendBuf(DestIp, DestPort, s1[1], length(s1))
  end
  else
    Result := stOk;
end;

function TSimpUdp.SendStr(IPd: cardinal; DestPort: word; ToSnd: string): TStatus;
begin
  if ToSnd <> '' then
    Result := SendBuf(IPd, DestPort, ToSnd[1], length(ToSnd))
  else
    Result := stOk;
end;

function TSimpUdp.BrodcastStr(DestPort: word; ToSnd: string): TStatus;
begin
  Result := SendStr('255.255.255.255', DestPort, ToSnd);
end;

function TSimpUdp.ClearRecBuf: TStatus;
var
  AddrSize: integer;
  RecAdr: sockaddr_in;
  Len: u_long;
  st: integer;
  RecBuf: string;
begin
  repeat
    st := WinSock.ioctlsocket(Sd, FIONREAD, Len);
    if st <> SOCKET_ERROR then
    begin
      if Len <> 0 then
      begin
        SetLength(RecBuf, Len + 1);
        AddrSize := SizeOf(RecAdr);
        st := WinSock.recvfrom(Sd, RecBuf[1], length(RecBuf), 0, RecAdr, AddrSize);
      end;
    end;
  until (st = SOCKET_ERROR) or (Len = 0);
  Result := st;
end;

function TSimpUdp.ReadFromSocket(var RecBuf: string; var RecIp: string; var RecPort: word): TStatus;
var
  AddrSize: integer;
  RecAdr: sockaddr_in;
  Len: u_long;
  l: integer;
begin
  l := 0;
  Result := WinSock.ioctlsocket(Sd, FIONREAD, Len);
  if Result = stOk then
  begin
    if Len <> 0 then
    begin
      SetLength(RecBuf, Len + 1);
      AddrSize := SizeOf(RecAdr);
      l := WinSock.recvfrom(Sd, RecBuf[1], length(RecBuf), 0, RecAdr, AddrSize);
      if l = SOCKET_ERROR then
        Result := WSAGetLastError;
    end;
  end;
  if Result = stOk then
  begin
    if l <> 0 then
    begin
      SetLength(RecBuf, l);
      RecIp := WinSock.inet_ntoa(RecAdr.sin_addr);
      RecPort := WinSock.HToNs(RecAdr.sin_port);
    end
    else
    begin
      RecBuf := '';
      RecIp := '';
      RecPort := 0;
    end;
    FLastErr := 0;
  end;
  LoadLastErr(Result);
end;

procedure TSimpUdp.DoOnMsgRead;
begin
  ReadFromSocket(RecBuf, RecIp, RecPort);
  if Assigned(FOnMsgRead) then
    FOnMsgRead(self, RecIp, RecPort, RecBuf);
end;

// ------------------------- TSimpTCP -------------------------------------
constructor TSimpTcp.Create;
begin
  inherited Create;
  RecWaitTime := 1000; // 200 milisekund
  SndWaitTime := 1000; // 200 milisekund
  FNonBlkMode := true;
  FRestReadStrLN := '';
end;

function TSimpTcp.Open: TStatus;
var
  N: integer;
  s: integer;
  Size: integer;
begin
  FAsync := false;
  Result := inherited Open;
  Sd := WinSock.Socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if Result <> INVALID_SOCKET then
  begin
    if FNonBlkMode then
      s := 1 // 1-nonbloking mode;
    else
      s := 0; // 0-bloking mode;
    Result := WinSock.ioctlsocket(Sd, FIONBIO, s);
  end;
  if Result = stOk then
  begin
    Size := $20100;
    Result := setsockopt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@Size), SizeOf(Size));
  end;
  if Result = stOk then
  begin
    N := SizeOf(MaxRecBuf);
    Result := GetSockOpt(Sd, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@MaxRecBuf), N);
  end;
  if Result = stOk then
  begin
    Size := $20100;
    Result := setsockopt(Sd, SOL_SOCKET, SO_SNDBUF, PAnsiChar(@Size), SizeOf(Size));
  end;
  if Result = stOk then
  begin
    N := SizeOf(MaxSndBuf);
    Result := GetSockOpt(Sd, SOL_SOCKET, SO_SNDBUF, PAnsiChar(@MaxSndBuf), N);
  end;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Close: TStatus;
begin
  WinSock.shutdown(Sd, SD_Send);
  Result := WinSock.CloseSocket(Sd);
  Sd := INVALID_SOCKET;
  Result := LoadLastErr(Result);
  FConnected := false;
end;

procedure TSimpTcp.DoOnConnect;
begin
  inherited;
  if Assigned(OnConnect) then
    OnConnect(self);
end;

procedure TSimpTcp.DoOnClose;
begin
  inherited;
  if Assigned(OnClose) then
    OnClose(self);
end;

procedure TSimpTcp.DoOnMsgWrite;
begin
  inherited;
  if Assigned(OnMsgWrite) then
    OnMsgWrite(self);
end;

function TSimpTcp.Connect: TStatus;
var
  Addr: sockaddr_in;
begin
  Result := stError;
  if FillINetStruct(Addr, FIp, FPort) = stOk then
  begin
    // socket is non-blocking (connection attempt cannot be completed immediately)
    // so there will be error on connect
    { Result := } WinSock.Connect(Sd, Addr, SizeOf(Addr));
    FConnected := CheckWrite;
    if FConnected then
      Result := stOk;
  end
end;

function TSimpTcp.ReOpen: TStatus;
begin
  Close;
  Result := Open;
  if Result = stOk then
    Result := Connect;
end;

function TSimpTcp.Write(Var buf; Len: integer): TStatus;
begin
  Result := WinSock.Send(Sd, buf, Len, 0);
  SetMsgFlow(Len);
  Result := LoadLastErr(Result);
end;

function TSimpTcp.WriteStr(txt: string): TStatus;
begin
  Result := Write(txt[1], length(txt));
end;

function TSimpTcp.WriteStream(Stream: TMemoryStream): TStatus;
begin
  Result := Write(pByte(Stream.memory)^, Stream.Size);
end;

function TSimpTcp.Read(Var buf; var Len: integer): TStatus;
var
  l: integer;
begin
  l := WinSock.recv(Sd, buf, Len, 0);
  if l <> SOCKET_ERROR then
  begin
    Len := l;
    Result := stOk;
  end
  else
  begin
    Result := WSAGetLastError;
  end;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.ReadStr(Var txt: string): TStatus;
  function ReadStr1(Var txt: string): TStatus;
  var
    l: integer;
  begin
    txt := '';
    Result := WinSock.ioctlsocket(Sd, FIONREAD, l);
    if (Result = stOk) and (l > 0) then
    begin
      SetLength(txt, l);
      Result := Read(txt[1], l);
    end;
  end;

var
  tx1: string;
begin
  txt := '';
  repeat
    Result := ReadStr1(tx1);
    txt := txt + tx1;
    if Result <> stOk then
      break;
    if (tx1 = '') and (txt = '') then
      sleep(50);
  until tx1 = '';
end;

procedure TSimpTcp.DoOnMsgRead;
begin
  if Assigned(OnMsgRead) then
    OnMsgRead(self);
end;

function TSimpTcp.ClearInpBuf: TStatus;
var
  buf: array of byte;
  l: integer;
begin
  repeat
    Result := WinSock.ioctlsocket(Sd, FIONREAD, l);
    if (Result = stOk) and (l > 0) then
    begin
      SetLength(buf, l);
      Result := Read(buf[0], l);
    end;
  until (Result <> stOk) or (l = 0);
  Result := LoadLastErr(Result);
end;

function TSimpTcp.ReciveToBufTime(StartT: cardinal; var buf; Count: integer): TStatus;
type
  TByteArray = array [0 .. MAXINT - 1] of byte;
var
  l: integer;
  Done: boolean;
  Ptr: integer;
  Size: integer;
begin
  Ptr := 0;
  Size := Count;
  mBreakFlag := false;
  SetMsgFlow(0);
  repeat
    Result := WinSock.ioctlsocket(Sd, FIONREAD, l);
    if l > 0 then
    begin
      if l > Count then
        l := Count;
      Result := Read(TByteArray(buf)[Ptr], l);
      Count := Count - l;
      Ptr := Ptr + l;
      SetMsgFlow(Size - Count);
      StartT := GetTickCount;
    end
    else
      sleep(5);
    Done := (Count = 0);
  until (integer(GetTickCount - StartT) > RecWaitTime) or (Result <> stOk) or Done or mBreakFlag;
  if mBreakFlag then
  begin
    Result := stUserBreak;
    Exit;
  end;
  if not(Done) then
  begin
    WSASetLastError(WSAETIMEDOUT); // WSAEMSGSIZE
    Result := LoadLastErr(WSAETIMEDOUT);
  end;
end;

function TSimpTcp.ReadStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
var
  FrameSize: DWORD; // Wielkoœæ ramki
  Count: integer; //
  buf : TBytes;
begin
  Result := ReciveToBufTime(GetTickCount, FrameSize, SizeOf(FrameSize));
  if Result <> stOk then
    Exit;
  FrameSize := DSwap(FrameSize); // -SizeOf(DWORD);

  if FrameSize > dword(MaxBytes) then
  begin
    Result := stFrmTooLarge;
    Exit;
  end;

  setlength(buf,frameSize+1);
  Result := ReciveToBufTime(GetTickCount, buf[0], FrameSize);
  if Result = stOk then
  begin
    buf[FrameSize]:=0;
    Stream.SetSize(FrameSize + 1);
    Stream.Seek(0, soFromBeginning);
    Stream.WriteBuffer(buf[0], FrameSize + 1);
  end;
end;

function TSimpTcp.ReadBinaryStream(Stream: TMemoryStream; MaxBytes: integer): TStatus;
var
  FrameSize: DWORD; // Wielkoœæ ramki
  Count: integer; //
  p, buf: PChar;
begin
  Count := SizeOf(FrameSize);
  Result := ReciveToBufTime(GetTickCount, FrameSize, Count);
  if Result <> stOk then
    Exit;
  FrameSize := DSwap(FrameSize); // -SizeOf(DWORD);

  if FrameSize > cardinal(MaxBytes) then
  begin
    Result := stFrmTooLarge;
    Exit;
  end;

  GetMem(buf, FrameSize + 1);
  p := buf;
  Result := ReciveToBufTime(GetTickCount, p^, FrameSize);
  if Result = stOk then
  begin
    Stream.SetSize(FrameSize);
    Stream.Seek(0, soFromBeginning);
    Stream.WriteBuffer(buf^, FrameSize);
  end;

  if buf <> nil then
    FreeMem(buf);
end;

// ------------------------- TLockString --------------------------------
constructor TLockString.Create;
begin
  inherited;
  InitializeCriticalSection(CriSection);
  flNew := false;
end;

destructor TLockString.Destroy;
begin
  DeleteCriticalSection(CriSection);
  inherited;
end;

procedure TLockString.Lock;
begin
  EnterCriticalSection(CriSection);
end;

procedure TLockString.Unlock;
begin
  LeaveCriticalSection(CriSection);
end;

function TLockString.FGetString: string;
begin
  Lock;
  Result := FMyStr;
  flNew := false;
  Unlock;
end;

procedure TLockString.FSetString(s: string);
begin
  Lock;
  FMyStr := s;
  flNew := true;
  Unlock;
end;

function TLockString.IsNew: boolean;
begin
  Result := flNew;
end;

// ------------------------- TClientTask --------------------------------

constructor TClientTask.Create(aOwnerList: TClientTaskList);
begin
  inherited Create(true);
  FOwnerList := aOwnerList;
  FSimpTcp := TSimpTcp.Create;
  FSimpTcp.OnClose := OnSocketClose;
  FOwnerList.Add(self);
end;

destructor TClientTask.Destroy;
begin
  FSimpTcp.Free;
  FOwnerList.Remoove(self);
  inherited;
end;

procedure TClientTask.OnSocketClose(Sender: TObject);
begin
  SocketClose;
end;

procedure TClientTask.SocketClose;
begin

end;

procedure TClientTask.Start(aSd: TSocket; RecIp: string; RecPort: word);
begin
  FSimpTcp.Sd := aSd;
  ClientIP := RecIp;
  ClientPort := RecPort;
  StrToIP(ClientIP, ClientIPBin);
  // FSimpTcp.SetWsaEvents([wsaCLOSE]);
  Resume;
end;

procedure TClientTask.Stop;
begin
  Terminate;
  FSimpTcp.Close;
end;

procedure TClientTask.Closed;
begin

end;

procedure TClientTask.ReciveMsg(s: string);
begin

end;

procedure TClientTask.Execute;
const
  BUF_LEN = 10000;
var
  Buffer: string;
  Len: integer;
  st: integer;
begin
  while not(terminated) do
  begin
    SetLength(Buffer, BUF_LEN);
    Len := BUF_LEN;
    st := FSimpTcp.Read(Buffer[1], Len);
    if st = stOk then
    begin
      if Len > 0 then
      begin
        SetLength(Buffer, Len);
        ReciveMsg(Buffer);
      end
      else
      begin
        break;
      end;
    end
    else
    begin
      if st <> WSAEWOULDBLOCK then
      begin
        break;
      end;
    end;
    sleep(50);
  end;
  FSimpTcp.Close;
  Closed;
  FreeOnTerminate := true;
end;

procedure TClientTask.Send(txt: string);
var
  st: integer;
begin
  st := FSimpTcp.Write(txt[1], length(txt));
  if st <> stOk then
  begin
    Terminate;
  end;
end;

// ------------------------- TClientTaskList --------------------------------
constructor TClientTaskList.Create;
begin
  inherited Create(false);
  InitializeCriticalSection(FCriSection);
end;

destructor TClientTaskList.Destroy;
var
  quit: boolean;
begin
  CloseClients;
  while true do
  begin
    Lock;
    quit := (Count = 0);
    Unlock;
    if quit then
      break;
    sleep(100);
  end;
  DeleteCriticalSection(FCriSection);
  inherited;
end;

procedure TClientTaskList.Add(task: TClientTask);
begin
  Lock;
  try
    inherited Add(task);
  finally
    Unlock;
  end;
end;

procedure TClientTaskList.Remoove(task: TClientTask);
var
  N: integer;
begin
  Lock;
  try
    N := IndexOf(task);
    if N >= 0 then
      Delete(N);
  finally
    Unlock;
  end;
end;

function TClientTaskList.FGetItem(Index: integer): TClientTask;
begin
  Result := inherited GetItem(index) as TClientTask;
end;

procedure TClientTaskList.Lock;
begin
  EnterCriticalSection(FCriSection);
end;

procedure TClientTaskList.Unlock;
begin
  LeaveCriticalSection(FCriSection);
end;

procedure TClientTaskList.CloseClients;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].Stop;
  end;
end;

procedure TClientTaskList.WaitForAll;
var
  i: integer;
begin
  for i := Count - 1 downto 0 do
  begin
    Items[i].WaitFor;
  end;
end;

// ------------------------- TSerwerLisenTask --------------------------------
constructor TSerwerLisenTask.Create(aOwner: TSimpServerTCP);
begin
  inherited Create(true);
  FOwner := aOwner;
  FDoListen := false;
  FListenSocket := INVALID_SOCKET
end;

destructor TSerwerLisenTask.Destroy;
begin
  Resume;
  Terminate;
  if FListenSocket <> INVALID_SOCKET then
    WinSock.CloseSocket(FListenSocket);
  WaitFor;
  inherited;
end;

procedure TSerwerLisenTask.StartListen(Sd: TSocket; aClientTaskClass: TClientTaskClass);
begin
  ClientTaskClass := aClientTaskClass;
  FListenSocket := Sd;
  FDoListen := true;
  Resume;
end;

procedure TSerwerLisenTask.StopListen;
begin
  FDoListen := false;
end;

procedure TSerwerLisenTask.Execute;
var
  st: integer;
  AddrIn: TSockAddrIn;
  Addr_len: integer;
  NewSd: TSocket;
  RecIp: string;
  RecPort: word;
  ClientTask: TClientTask;
begin
  while not(terminated) do
  begin
    if FDoListen then
    begin
      st := WinSock.listen(FListenSocket, 2); // SOMAXCONN);
      if terminated then
        break;
      if st = stOk then
      begin
        Addr_len := SizeOf(AddrIn);
        NewSd := WinSock.accept(FListenSocket, @AddrIn, @Addr_len);
        if terminated then
          break;
        if NewSd <> INVALID_SOCKET then
        begin
          RecIp := WinSock.inet_ntoa(AddrIn.sin_addr);
          RecPort := WinSock.HToNs(AddrIn.sin_port);
          ClientTask := ClientTaskClass.Create(FOwner.FClientTaskList);
          ClientTask.Start(NewSd, RecIp, RecPort);
          FLastErr := stOk;
        end
        else
        begin
          FLastErr := WinSock.WSAGetLastError;
        end;
      end
      else
        FLastErr := WinSock.WSAGetLastError;
      sleep(100);
    end
    else
      sleep(250);
  end;
end;

// ------------------------- TSimpServerTCP --------------------------------
constructor TSimpServerTCP.Create;
begin
  inherited;
  FClientTaskList := TClientTaskList.Create;
  FListenTask := TSerwerLisenTask.Create(self);
end;

destructor TSimpServerTCP.Destroy;
begin
  FListenTask.Free;
  FClientTaskList.CloseClients;
  sleep(200);
  FClientTaskList.Free;
  inherited;
end;

function TSimpServerTCP.StartListen(aClientTaskClass: TClientTaskClass): integer;
var
  st: integer;
  Addr: TSockAddr;
begin
  FNonBlkMode := false;
  st := Open;
  if st = stOk then
  begin
    Addr.sin_family := AF_INET;
    Addr.sin_port := WinSock.HToNs(Port);
    Addr.sin_addr.S_addr := 0;
    st := WinSock.bind(Sd, Addr, SizeOf(Addr));
    if st = stOk then
    begin
      FListenTask.StartListen(Sd, aClientTaskClass);
    end
    else
    begin
      st := WinSock.WSAGetLastError;
    end;
  end;
  Result := st;
end;

procedure TSimpServerTCP.StopListen;
begin
  FClientTaskList.CloseClients;
  FListenTask.StopListen;
  CloseSocket(Sd);
end;

function TSimpServerTCP.GetClientsCnt: integer;
begin
  Result := FClientTaskList.Count;
end;



// ---------------------------------------------------------------------------
// ASYNCH                                                              .
// ---------------------------------------------------------------------------

// ------------------------- TAsynchClient --------------------------------
constructor TAsynchClient.Create(aOwner: TAsynchServerTCP);
begin
  inherited Create;
  FOwner := aOwner;
end;

destructor TAsynchClient.Destroy;
begin
  FOwner.FClientList.Extract(self);
  inherited;
end;

procedure TAsynchClient.DoCloseMe;
begin
  PostMessage(FOwner.GetHandle, wm_CloseClient, integer(self), 0);
end;

procedure TAsynchClient.DoOnClose;
begin
  inherited;
  DoCloseMe;
end;

procedure TAsynchClient.Start(aSd: TSocket; RecIp: string; RecPort: word);
begin
  Sd := aSd;
  IP := RecIp;
  Port := RecPort;
  Async := true;
end;

// ------------------------- TAsynchClientList --------------------------------
function TAsynchClientList.FGetItem(Index: integer): TAsynchClient;
begin
  Result := inherited GetItem(index) as TAsynchClient;
end;

procedure TAsynchClientList.Add(task: TAsynchClient);
begin
  inherited Add(task);
end;

// ------------------------- TAsynchServerTCP --------------------------------
constructor TAsynchServerTCP.Create(aAsynchClientClass: TAsynchClientClass);
begin
  inherited Create;
  FClientList := TAsynchClientList.Create;
  FClientClass := aAsynchClientClass;
end;

destructor TAsynchServerTCP.Destroy;
begin
  FClientList.Free;
  inherited;
end;

function TAsynchServerTCP.FGetItem(Index: integer): TAsynchClient;
begin
  Result := FClientList.Items[Index];
end;

procedure TAsynchServerTCP.wmCloseClient(var AMessage: TMessage);
var
  Kli: TAsynchClient;
  N: integer;
begin
  Kli := TAsynchClient(AMessage.WParam);
  N := FClientList.IndexOf(Kli);
  if N >= 0 then
    FClientList.Delete(N);
end;

function TAsynchServerTCP.Count: integer;
begin
  Result := FClientList.Count;
end;

procedure TAsynchServerTCP.DoOnAccept;
var
  NewSd: TSocket;
  AddrIn: TSockAddrIn;
  Addr_len: integer;
  RecIp: string;
  RecPort: word;
  ClientTask: TAsynchClient;
begin
  Addr_len := SizeOf(AddrIn);
  NewSd := WinSock.accept(Sd, @AddrIn, @Addr_len);
  if NewSd <> INVALID_SOCKET then
  begin
    RecIp := WinSock.inet_ntoa(AddrIn.sin_addr);
    RecPort := WinSock.HToNs(AddrIn.sin_port);
    ClientTask := FClientClass.Create(self);
    FClientList.Add(ClientTask);
    ClientTask.Start(NewSd, RecIp, RecPort);
    FLastErr := stOk;
  end
  else
  begin
    FLastErr := WinSock.WSAGetLastError;
  end;
end;

function TAsynchServerTCP.StartListen: integer;
var
  st: integer;
  Addr: TSockAddr;
begin
  FNonBlkMode := true;
  st := Open;
  if st = stOk then
  begin
    Addr.sin_family := AF_INET;
    Addr.sin_port := WinSock.HToNs(Port);
    Addr.sin_addr.S_addr := 0;
    st := WinSock.bind(Sd, Addr, SizeOf(Addr));
    if st = stOk then
    begin
      FWsaEvents := FWsaEvents + [wsaACCEPT];
      Async := true;
      st := WinSock.listen(Sd, 2); // SOMAXCONN);
    end
    else
    begin
      st := WinSock.WSAGetLastError;
    end;
  end;
  Result := st;
end;

procedure TAsynchServerTCP.StopListen;
begin
  CloseSocket(Sd);
end;


// ------------------------- inicjalizacja WSA --------------------------------

procedure InitSockets;
var
  sData: TWSAData;
begin
  if WSAStartup($101, sData) <> SOCKET_ERROR then
  begin
    SocketsVersion := sData.wVersion;
    SocketRevision := sData.wHighVersion;
    SocketsOk := true;
  end
  else
  begin
    SocketsOk := false;
  end;
end;

procedure DoneSockets;
begin
  WSACleanup;
end;

initialization

InitSockets;

finalization

DoneSockets;

end.
