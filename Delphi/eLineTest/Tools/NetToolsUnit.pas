unit NetToolsUnit;

interface

uses
  SysUtils,
  WinSock2,
  Classes;

type
  TStatus = integer;

const
  stOk = 0;
  stTimeOut = 1;
  stNotOpen = 2;
  stUserBreak = 3;
  stFrmTooLarge = 4;
  stError = -1;

var
  SocketsVersion: integer;
  SocketRevision: integer;
  SocketsOk: boolean;

function StrToInetAdr(IP: string; var IPd: cardinal): TStatus;
function DSwap(X: cardinal): cardinal;
function IpToStr(IP: cardinal): string;
procedure GetLocalAdresses(SL: TStrings);
function GetLocalAdress: string;
function GetHostName: string;
function StrToIP(s: string; var IP: cardinal): boolean; overload;
function StrToIP(s: string): cardinal; overload;
function FillINetStruct(var Addr: TSockAddr; IP: string; Port: word): TStatus; overload;
function FillINetStruct(var Addr: TSockAddr; IPd: cardinal; Port: word): TStatus; overload;


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
          err := true
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

function StrToIP(s: string): cardinal;
begin
  if StrToIP(s,Result)=false then
    raise Exception.Create('Incorrect IP string');
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
  s1: AnsiString;
begin
  SetLength(Result, 250);
  WinSock2.GetHostName(PAnsiChar(s1), length(s1));
  s1 := PAnsiChar(s1);
  Result := String(s1);
end;

procedure GetLocalAdresses(SL: TStrings);
type
  TaPInAddr = Array [0 .. 250] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  i: integer;
  AHost: PHostEnt;
  PAdrPtr: PaPInAddr;
  HostName : AnsiString;
begin
  SL.Clear;
  HostName := AnsiString(GetHostName);
  AHost := GetHostByName(PAnsiChar(HostName));
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
      WSASetLastError(WSAEFAULT);
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


function FillINetStruct(var Addr: TSockAddr; IP: string; Port: word): TStatus;
var
  IPd: cardinal;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sa_family := PF_INET;
  sockaddr_in(Addr).sin_port := HToNs(Port);
  Result := StrToInetAdr(IP, IPd);
  sockaddr_in(Addr).sin_addr.S_addr := IPd;
end;

function FillINetStruct(var Addr: TSockAddr; IPd: cardinal; Port: word): TStatus;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sa_family := PF_INET;
  sockaddr_in(Addr).sin_port := HToNs(Port);
  sockaddr_in(Addr).sin_addr.S_addr := integer(IPd);
  Result := stOk;
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
