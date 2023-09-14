unit UdpSocketUnit;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs,
  WinSock2,
  NetToolsUnit;

type

  TRdEvent = procedure(Sender: TObject; RecBuf: string; RecIp: string; RecPort: word) of object;

  TSimpUdp = class(TObject)
  private type
    TWSAEvent = (wsaREAD, wsaWRITE, wsaOOB, wsaACCEPT, wsaCONNECT, wsaCLOSE);
    TWSAEvents = set of TWSAEvent;
  private const
    wm_SocketEvent = wm_user + 100;
  private type
    TSockDt = record
      sd: TSocket;
      myIp: AnsiString;
      binIP: u_long;
    end;

    TSockList = record
      buf: array of TSockDt;
      function cnt: integer;
      procedure clear;
      function find(sd: TSocket): integer;
      function findBestSocket(dstIp: string): integer;

    end;

  private
    SockList: TSockList;
    FWsaEvents: TWSAEvents;
    FOwnHandle: THandle;
    FLastErr: integer;
    FPort: word;
    FConnected: boolean;

    function LoadLastErr(Res: TStatus): TStatus;
    function SetWsaEvents(sd: TSocket): integer;

    procedure WndProc(var AMessage: TMessage);
    procedure wmSocketEvent(var AMessage: TMessage); message wm_SocketEvent;
    function ReadFromSocket(sd: TSocket; var RecBuf: string; var RecIp: string; var RecPort: word): TStatus;
    procedure MsgReadHd(sd: TSocket);
  protected
    FOnMsgRead: TRdEvent;
    procedure DoOnMsgRead(RecIp: string; RecPort: word; RecBuf: string); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    function Open: TStatus; virtual;
    function Close: TStatus; virtual;
    function IsConnected: boolean; // inline;
    property Port: word read FPort write FPort;

    property LastErr: integer read FLastErr;

    function SendBuf(sd: TSocket; DestIp: string; DestPort: word; var buf; Len: integer): TStatus; overload;
    function SendStr(sd: TSocket; DestIp: string; DestPort: word; ToSnd: string): TStatus; overload;

    function SendBuf(DestIp: string; DestPort: word; var buf; Len: integer): TStatus; overload;
    function SendStr(DestIp: string; DestPort: word; ToSnd: string): TStatus; overload;

    function BrodcastStr(DestPort: word; ToSnd: string): TStatus;
    function EnableBrodcast(Enable: boolean): TStatus;
    property OnMsgRead: TRdEvent read FOnMsgRead write FOnMsgRead;
    class function GetIPs: TStrings;

  end;

implementation

// -------------------------- TSimpSock ----------------------------------

function TSimpUdp.TSockList.cnt: integer;
begin
  result := length(buf);
end;

procedure TSimpUdp.TSockList.clear;
begin
  setlength(buf, 0);
end;

function TSimpUdp.TSockList.find(sd: TSocket): integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to length(buf) - 1 do
  begin
    if buf[i].sd = sd then
    begin
      result := i;
      break;
    end;
  end;
end;

function TSimpUdp.TSockList.findBestSocket(dstIp: string): integer;
  function getAgreeBit(a1, a2: cardinal): integer;
  var
    mask: cardinal;
  begin
    mask := $00000001;
    result := 0;
    while result < 32 do
    begin
      if (a1 and mask) <> (a2 and mask) then
      begin
        break;
      end;
      inc(result);
      mask := mask shl 1;
    end;
  end;

var
  i: integer;
  u: u_long;
  ag: byte;
  mx: integer;
begin
  u := inet_addr(PAnsiChar(AnsiString(dstIp)));
  mx := -1;
  result := -1;
  for i := 0 to cnt - 1 do
  begin
    ag := getAgreeBit(buf[i].binIP, u);
    if ag > mx then
    begin
      mx := ag;
      result := i;
    end;
  end;

end;

constructor TSimpUdp.Create;
begin
  inherited Create;
  SockList.clear;
  FPort := 0;
  FWsaEvents := [wsaREAD];
  FOwnHandle := Classes.AllocateHWnd(WndProc);
end;

destructor TSimpUdp.Destroy;
begin
  Close;
  Classes.DeallocateHWnd(FOwnHandle);
  inherited;
end;

function TSimpUdp.LoadLastErr(Res: TStatus): TStatus;
begin
  if Res = stOk then
    FLastErr := WSAGetLastError
  else
    FLastErr := Res;
  result := FLastErr
end;

function TSimpUdp.Open: TStatus;
var
  Addr: TSockAddr;
  SL: TStrings;
  i: integer;
  State: integer;

begin
  SL := GetIPs;
  result := stOk;
  if SockList.cnt > 0 then
  begin
    result := Close;
  end;

  setlength(SockList.buf, SL.Count);
  for i := 0 to SL.Count - 1 do
  begin
    SockList.buf[i].myIp := AnsiString(SL.Strings[i]);
    SockList.buf[i].binIP := inet_addr(PAnsiChar(SockList.buf[i].myIp));

    SockList.buf[i].sd := WinSock2.Socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if SockList.buf[i].sd = INVALID_SOCKET then
      result := WSAGetLastError;
    State := 1;
    setsockopt(SockList.buf[i].sd, SOL_SOCKET, SO_BROADCAST, @State, SizeOf(State));

    result := FillINetStruct(Addr, SockList.buf[i].binIP, FPort);
    if result = stOk then
    begin
      result := bind(SockList.buf[i].sd, Addr, SizeOf(Addr));
      if result = stOk then
      begin
        SetWsaEvents(SockList.buf[i].sd);
        FConnected := true;
      end;
    end;
  end;
  result := LoadLastErr(result);
end;

function TSimpUdp.Close: TStatus;
var
  i: integer;
begin
  result := stOk;
  if SockList.cnt > 0 then
  begin
    for i := 0 to SockList.cnt - 1 do
    begin
      WSAAsyncSelect(SockList.buf[i].sd, FOwnHandle, 0, 0);
      result := shutdown(SockList.buf[i].sd, SD_Send);
      if result = stOk then
        result := CloseSocket(SockList.buf[i].sd);
      if result = stOk then
        SockList.buf[i].sd := INVALID_SOCKET;
    end;
    result := LoadLastErr(result);
  end;
  SockList.clear;
  FConnected := false;
end;

procedure TSimpUdp.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

procedure TSimpUdp.wmSocketEvent(var AMessage: TMessage);
var
  Ev: word;
  sd: TSocket;
  idx: integer;
begin
  try
    Ev := LoWord(AMessage.LParam);
    sd := TSocket(AMessage.WParam);
    idx := SockList.find(sd);

    if idx >= 0 then
    begin
      if (Ev and FD_READ) <> 0 then
        MsgReadHd(sd);
    end;
  except

  end;
end;

function TSimpUdp.SetWsaEvents(sd: TSocket): integer;
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
  result := WSAAsyncSelect(sd, FOwnHandle, wm_SocketEvent, w);
  if result <> 0 then
    result := WSAGetLastError;
end;

function TSimpUdp.IsConnected: boolean;
begin
  result := FConnected;
end;

function TSimpUdp.EnableBrodcast(Enable: boolean): TStatus;
var
  State: integer;
  i: integer;
begin
  result := 0;
  for i := 0 to SockList.cnt - 1 do
  begin
    if Enable then
      State := 1
    else
      State := 0;
    result := setsockopt(SockList.buf[i].sd, SOL_SOCKET, SO_BROADCAST, @State, SizeOf(State));
  end;
  result := LoadLastErr(result);
end;

function TSimpUdp.SendBuf(sd: TSocket; DestIp: string; DestPort: word; var buf; Len: integer): TStatus;
var
  Addr: TSockAddr;
begin
  result := FillINetStruct(Addr, DestIp, DestPort);

  if result = stOk then
  begin
    result := sendto(sd, buf, Len, 0, @Addr, SizeOf(Addr));
    if result < WSABASEERR then
      result := 0;
  end;

  result := LoadLastErr(result);
end;

function TSimpUdp.SendBuf(DestIp: string; DestPort: word; var buf; Len: integer): TStatus;
var
  idx: integer;
begin
  result := 0;
  idx := SockList.findBestSocket(DestIp);
  if idx >= 0 then
    result := SendBuf(SockList.buf[idx].sd, DestIp, DestPort, buf, Len);
  result := LoadLastErr(result);
end;

function TSimpUdp.SendStr(sd: TSocket; DestIp: string; DestPort: word; ToSnd: string): TStatus;
var
  str1: AnsiString;
begin
  if ToSnd <> '' then
  begin
    str1 := AnsiString(ToSnd);
    result := SendBuf(sd, DestIp, DestPort, str1[1], length(str1));
  end
  else
    result := stOk;
end;

function TSimpUdp.SendStr(DestIp: string; DestPort: word; ToSnd: string): TStatus;
var
  str1: AnsiString;
begin
  if ToSnd <> '' then
  begin
    str1 := AnsiString(ToSnd);
    result := SendBuf(DestIp, DestPort, str1[1], length(str1));
  end
  else
    result := stOk;
end;

function TSimpUdp.BrodcastStr(DestPort: word; ToSnd: string): TStatus;
var
  i: integer;
begin
  result := 0;
  for i := 0 to SockList.cnt - 1 do
  begin
    result := SendStr(SockList.buf[i].sd, '255.255.255.255', DestPort, ToSnd);
    sleep(50);
  end;
end;

function TSimpUdp.ReadFromSocket(sd: TSocket; var RecBuf: string; var RecIp: string; var RecPort: word): TStatus;
var
  AddrSize: integer;
  RecAdr: TSockAddr;
  Len: u_long;
  l: integer;
  aRecBuf: AnsiString;
  aRecIp: AnsiString;
begin
  l := 0;
  result := ioctlsocket(sd, FIONREAD, Len);
  if result = stOk then
  begin
    if Len <> 0 then
    begin
      setlength(aRecBuf, Len + 1);
      AddrSize := SizeOf(RecAdr);
      l := recvfrom(sd, aRecBuf[1], length(aRecBuf), 0, RecAdr, AddrSize);
      if l = SOCKET_ERROR then
        result := WSAGetLastError;
    end;
  end;
  if result = stOk then
  begin
    if l <> 0 then
    begin
      setlength(aRecBuf, l);
      aRecIp := inet_ntoa(sockaddr_in(RecAdr).sin_addr);
      RecPort := HToNs(sockaddr_in(RecAdr).sin_port);
      RecBuf := String(aRecBuf);
      RecIp := String(aRecIp);
    end
    else
    begin
      RecBuf := '';
      RecIp := '';
      RecPort := 0;
    end;
    FLastErr := 0;
  end;
  LoadLastErr(result);
end;

procedure TSimpUdp.DoOnMsgRead(RecIp: string; RecPort: word; RecBuf: string);
begin

end;

procedure TSimpUdp.MsgReadHd(sd: TSocket);
var
  RecBuf: string;
  RecIp: string;
  RecPort: word;
begin
  inherited;
  ReadFromSocket(sd, RecBuf, RecIp, RecPort);
  if Assigned(FOnMsgRead) then
    FOnMsgRead(self, RecBuf, RecIp, RecPort);
end;

class function TSimpUdp.GetIPs: TStrings;
type
  TaPInAddr = array [0 .. 10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pPtr: PaPInAddr;
  i: integer;
  s1: AnsiString;

begin
  result := TStringList.Create;
  phe := gethostbyname('localhost');
  if phe = nil then
    Exit;
  s1 := phe^.h_name;
  phe := gethostbyname(PAnsiChar(s1));
  if phe = nil then
    Exit;
  s1 := phe^.h_name;

  pPtr := PaPInAddr(phe^.h_addr_list);
  i := 0;
  while pPtr^[i] <> nil do
  begin
    result.Add(String(inet_ntoa(pPtr^[i]^)));
    inc(i);
  end;

end;

end.
