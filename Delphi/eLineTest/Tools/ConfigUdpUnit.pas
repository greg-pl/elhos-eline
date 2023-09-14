unit ConfigUdpUnit;

interface

uses
  SysUtils, Windows, Messages, Classes, ExtCtrls,
  UdpSocketUnit,
  NetToolsUnit;

type
  TOnDeviceIpDef = procedure(Sender: TObject; IP: string; Port: word; SerNum, ip2, mask, gate, devId: string) of object;
  TOnDeviceFound = procedure(Sender: TObject; IP, SerNum, DevType, devId: string) of object;
  TOnDeviceReboot = procedure(Sender: TObject; IP, SerNum: string) of object;

  TConfigUdp = class(TObject)
  private const
    CONDIG_UDP_PORT = 8001;
  private
    FTimer: TTimer;
    FOnDeviceIpDef: TOnDeviceIpDef;
    FOnDeviceFound: TOnDeviceFound;
    FOnDeviceReboot: TOnDeviceReboot;
    FOnListenEnd: TNotifyEvent;
    UdpSocket: TSimpUdp;
    procedure TimerProc(Sender: TObject);
    procedure OnMsgReadProc(Sender: TObject; RecBuf: string; RecIp: string; RecPort: word);
  protected
    function SendStrConfigPort(IpD: string; ToSnd: string): TStatus;
    function BrodcastStrConfigPort(ToSnd: string): TStatus;
  public
    ListenTime: integer;
    constructor Create;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    function IsConnected: boolean;

    function SendHello(IP: string): TStatus;
    function SendFind(IP: string): TStatus;
    function BrodcastFind: TStatus;
    function BrodcastHello: TStatus;
    function SendRebootCmd(IP: string): TStatus;
    property OnDeviceIpDef: TOnDeviceIpDef read FOnDeviceIpDef write FOnDeviceIpDef;
    property OnDeviceFound: TOnDeviceFound read FOnDeviceFound write FOnDeviceFound;
    property OnDeviceReboot: TOnDeviceReboot read FOnDeviceReboot write FOnDeviceReboot;
    property OnListenEnd: TNotifyEvent read FOnListenEnd write FOnListenEnd;
  end;

implementation

constructor TConfigUdp.Create;
begin
  inherited;
  FTimer := TTimer.Create(nil);
  FTimer.OnTimer := TimerProc;
  FTimer.Enabled := false;

  UdpSocket := TSimpUdp.Create;
  UdpSocket.OnMsgRead := OnMsgReadProc;
  UdpSocket.Port := CONDIG_UDP_PORT;

  ListenTime := 2000; // 2 sekund

  FOnListenEnd := nil;
  FOnListenEnd := nil;
  FOnDeviceReboot := nil;
  FOnDeviceIpDef := nil;
end;

destructor TConfigUdp.Destroy;
begin
  UdpSocket.Free;
  FTimer.Free;
  inherited;
end;

procedure TConfigUdp.Open;
var
  n: integer;
begin
  n := 0;
  while true do
  begin
    UdpSocket.Open;
    if UdpSocket.IsConnected then
      break;
    inc(n);
    if n = 10 then
      break;
    UdpSocket.Port := UdpSocket.Port + 1;
  end;

end;

procedure TConfigUdp.Close;
begin
  UdpSocket.Close;
end;

function TConfigUdp.IsConnected: boolean;
begin
  result := UdpSocket.IsConnected;
end;

procedure TConfigUdp.TimerProc(Sender: TObject);
begin
  // Close;
  FTimer.Enabled := false;
  if Assigned(FOnListenEnd) then
    FOnListenEnd(Self);
end;

function TConfigUdp.BrodcastStrConfigPort(ToSnd: string): TStatus;
begin
  UdpSocket.EnableBrodcast(true);
  result := UdpSocket.BrodcastStr(CONDIG_UDP_PORT, ToSnd);
  FTimer.Enabled := false;
  FTimer.Interval := ListenTime;
  FTimer.Enabled := true;
end;

function TConfigUdp.SendStrConfigPort(IpD: string; ToSnd: string): TStatus;
begin
  result := UdpSocket.SendStr(IpD, CONDIG_UDP_PORT, ToSnd);
  FTimer.Enabled := false;
  FTimer.Interval := ListenTime;
  FTimer.Enabled := true;
end;




// 13444 0 192.168.254.117   255.255.255.0 192.168.254.254 RMT_13444
// 13444 6 INTRO eLineRMT_F RMT_13444
// 13444 6 REBOOTING

procedure TConfigUdp.OnMsgReadProc(Sender: TObject; RecBuf: string; RecIp: string; RecPort: word);
var
  SL: TStringList;
  Cmd: integer;
  Fun6Cmd: string;
begin
  inherited;
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.DelimitedText := RecBuf;
    if SL.Count >= 2 then
    begin
      if TryStrToInt(SL.Strings[1], Cmd) then
      begin
        case Cmd of
          1:
            begin
              if SL.Count >= 6 then
              begin
                if Assigned(FOnDeviceFound) then
                begin
                  // 13444 0 192.168.254.117   255.255.255.0 192.168.254.254 RMT_13444
                  // TOnDeviceIpDef = procedure(Sender: TObject; IP: string; Port: word; SerNum, ip2, mask, gate, devId: string) of object;
                  FOnDeviceIpDef(Self, RecIp, RecPort, Trim(SL.Strings[0]), Trim(SL.Strings[2]), Trim(SL.Strings[3]),
                    Trim(SL.Strings[4]), Trim(SL.Strings[5]));
                end;

              end;
            end;
          6:
            begin
              if SL.Count >= 3 then
              begin
                Fun6Cmd := SL.Strings[2];
                if Fun6Cmd = 'INTRO' then
                begin
                  if SL.Count >= 5 then
                  begin
                    if Assigned(FOnDeviceFound) then
                    begin
                      // TOnDeviceFound = procedure(Sender: TObject; IP, SerNum, DevType, DevId: string) of object;
                      FOnDeviceFound(Self, RecIp, Trim(SL.Strings[0]), Trim(SL.Strings[3]), Trim(SL.Strings[4]));
                    end;
                  end;
                end
                else if Fun6Cmd = 'REBOOTING' then
                begin
                  FOnDeviceReboot(Self, RecIp, Trim(SL.Strings[0]));
                end;
              end;
            end;
        end;
      end;
    end;
  finally
    SL.Free;
  end;
end;

function TConfigUdp.SendHello(IP: string): TStatus;
begin
  result := SendStrConfigPort(IP, '0 1');
end;

function TConfigUdp.SendFind(IP: string): TStatus;
begin
  result := SendStrConfigPort(IP, '0 6 FIND');
end;

function TConfigUdp.BrodcastFind: TStatus;
begin
  result := BrodcastStrConfigPort('0 6 FIND');
end;

function TConfigUdp.BrodcastHello: TStatus;
begin
  result := BrodcastStrConfigPort('0 1');
end;

function TConfigUdp.SendRebootCmd(IP: string): TStatus;
begin
  result := SendStrConfigPort(IP, '0 6 REBOOT');
end;

end.
