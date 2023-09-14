unit KeyLoaderDef;

interface

uses SysUtils, crcUnit;

const
  DATA_VERSION = 2;
  KEYLOG_PACKET_SIZE = 32;
  KEYLOG_DATA_SIZE = KEYLOG_PACKET_SIZE - 8; // 24 bytes
  KEY_CNT_MAX = 128;
  SIGN_RPL_XOR = $15A6;
  SIGN_REPL_SIGN = $4747;

type

  TKeyLogPacket = packed record
    Sign: word;
    Cmd: byte;
    RecNr: byte;
    RepSign: word;
    Data: array [0 .. KEYLOG_DATA_SIZE - 1] of byte;
    Crc: word;
    procedure Clear;
    procedure ValidRec;
    procedure loadfromTab(buf: TBytes);
    procedure loadData(var dt);
    function checkValid(inPkt: TKeyLogPacket): boolean;
  end;

  // rozkaz inkrementacji/dekrementacji
  PKeyLogIncRec = ^TKeyLogIncRec;

  TKeyLogIncRec = packed record
    RecNr: byte; // numer rekordu, w którym należy zwiększyć licznik
    IncDec: byte; // 0-Decrementation 1-Incrementation
  end;

  TKeyLogInfo = packed record
    SerNumber: word;
    ProductionDate: word;
    Version: byte;
    free: array [0 .. 2] of byte;
    procedure Clear;
  end;

  PKeyLogInfoRec = ^TKeyLogInfoRec;

  TKeyLogInfoRec = packed record
    Ver: word;
    Rev: word;
    PacketCnt: byte;
    Info: TKeyLogInfo;
    procedure Clear;
    procedure Load(var w);
  end;

  // Size=8
  PKeyLogData = ^TKeyLogData;

  TKeyLogData = packed record
    Mode: byte; // 0, 0xff-Close, 1-Open, 2-TimeOpen
    free: byte;
    ValidDate: word;
    ValidCnt: word;
    Free2: word;
    procedure Clear;
    procedure Load(var w);
  end;

  PKeyLogKey3 = ^TKeyLogKey3;
  TKeyLogKey3 = array [0 .. 2] of TKeyLogData;



  // ----------------------
  // Query
  // ----------------------

const
  REC_NR_OUT_IN = 47;
  REC_NR_OUT_ADD = 117;
  ACTIV_ON = $67;
  ACTIV_OFF = $23;
  keyBAD_RPL = 0;
  keyNO_ACTIV = 1;
  keyACTIV = 2;

type
  // struktura zapytania o aktywność
  PKeyLogQueryIn = ^TKeyLogQueryIn;

  TKeyLogQueryIn = packed record
    tabK1: array [0 .. 3] of word;
    RecNrMx: byte;
    Zero: byte;
    time: word;
    tabK2: array [0 .. 5] of word;
  end;

  // struktura odpowiedzi
  PKeyLogQueryOut = ^TKeyLogQueryOut;

  TKeyLogQueryOut = packed record
    tabK1: array [0 .. 6] of word;
    RecNrMx: byte;
    Activ: byte;
    tabK2: array [0 .. 3] of word;
    function compare(const dst: TKeyLogQueryOut): boolean;
  end;

const
  kmdON = 1;
  kmdDEMO = 2;

function UnpackDate(dt: word): TDateTime;
function PackDate(Tm: TDateTime): word;
function getKeyName(keynr: integer): string;
function getKeyMod(Mode: integer): string;

procedure KeyLogQueryBuild(var inp: TKeyLogQueryIn; RecNr: byte);
function KeyLogCheckQueryReply(const outDt: TKeyLogQueryOut; const inpDt: TKeyLogQueryIn): byte;
procedure KeyLogQueryReply(var outDt: TKeyLogQueryOut; const inpDt: TKeyLogQueryIn; RecNr: byte; onV: byte);

implementation

procedure TKeyLogPacket.Clear;
begin
  fillchar(self, sizeof(self), 0);
end;

procedure TKeyLogPacket.ValidRec;
type
  EL = record
    kod: AnsiChar;
    Sign: word;
  end;
const
  TabSign: array [0 .. 6] of EL = ( //
    (kod: 'F'; Sign: $11E7), //
    (kod: 'R'; Sign: $2E69), //
    (kod: 'T'; Sign: $10A0), //
    (kod: 'X'; Sign: $2580), //
    (kod: 'W'; Sign: $C3AB), //
    (kod: 'I'; Sign: $8E29), //
    (kod: 'Q'; Sign: $4AC5)); //

var
  i: integer;
begin
  Sign := 0;
  for i := 0 to 6 do
  begin
    if ord(TabSign[i].kod) = Cmd then
    begin
      Sign := TabSign[i].Sign;
      break;
    end;
  end;
  if Sign = 0 then
    raise Exception.Create('Nieznany kod polecenia');
  TCrc.SetIt(self, sizeof(self))
end;

procedure TKeyLogPacket.loadfromTab(buf: TBytes);
begin
  if length(buf) >= sizeof(self) then
    move(buf[0], self, sizeof(self));
end;

procedure TKeyLogPacket.loadData(var dt);
begin
  move(dt, Data, sizeof(Data));
end;

function TKeyLogPacket.checkValid(inPkt: TKeyLogPacket): boolean;
begin
  Result := (Sign = SIGN_REPL_SIGN);
  Result := Result and ((inPkt.Sign xor RepSign) = SIGN_RPL_XOR);
  Result := Result and TCrc.Check(self, sizeof(self));
end;

procedure TKeyLogInfo.Clear;
begin
  fillchar(self, sizeof(self), 0);
end;

procedure TKeyLogInfoRec.Clear;
begin
  fillchar(self, sizeof(self), 0);
end;

procedure TKeyLogInfoRec.Load(var w);
begin
  move(w, self, sizeof(self));
end;

procedure TKeyLogData.Clear;
begin
  fillchar(self, sizeof(self), 0);
end;

procedure TKeyLogData.Load(var w);
begin
  move(w, self, sizeof(self));
end;

function UnpackDate(dt: word): TDateTime;
const
  ZeroTime: TDateTime = 0;
begin
  if dt = 0 then
    Result := ZeroTime
  else
  begin
    try
      Result := FileDateToDateTime(dt shl 16);
    except
      Result := ZeroTime;
    end;
  end;
end;

function PackDate(Tm: TDateTime): word;
begin
  Result := DateTimeToFileDate(Tm) shr 16;
end;

function getKeyName(keynr: integer): string;
begin
  case keynr of
    0:
      Result := 'Wspomaganie';
    1:
      Result := 'Kierunki kół';
    2:
      Result := '4x4';
    3:
      Result := 'Urz. zewnętrzne';
    4:
      Result := 'Waga';
  else
    Result := '';
  end;
end;

function getKeyMod(Mode: integer): string;
begin
  Result := '---';
  case Mode of
    kmdON:
      Result := 'ON';
    kmdDEMO:
      Result := 'DEMO';
  end;
end;

// ---------------------

function getRandom16: word;
begin
  Result := word(Random($10000));
end;

function TKeyLogQueryOut.compare(const dst: TKeyLogQueryOut): boolean;
var
  p1, p2: pByte;
  n, i: integer;
begin
  p1 := pByte(@dst);
  p2 := pByte(@self);
  n := sizeof(self);
  Result := true;
  for i := 0 to n - 1 do
  begin
    if p1^ <> p2^ then
    begin
      Result := false;
      break;
    end;
    inc(p1);
    inc(p2);
  end;
end;

// funkcja wykonywana przez pytającego
procedure KeyLogQueryBuild(var inp: TKeyLogQueryIn; RecNr: byte);
var
  i: integer;
begin
  for i := 0 to 3 do
    inp.tabK1[i] := getRandom16;
  for i := 0 to 7 do
    inp.tabK2[i] := getRandom16;
  inp.RecNrMx := RecNr + REC_NR_OUT_IN;
  inp.Zero := 0;
  inp.time := PackDate(Now);
end;

// funkcja wykonywana przez odpowiadajacego
procedure KeyLogQueryReply(var outDt: TKeyLogQueryOut; const inpDt: TKeyLogQueryIn; RecNr: byte; onV: byte);
begin
  outDt.tabK1[0] := inpDt.tabK2[0] - inpDt.tabK2[3] + 14567;
  outDt.tabK1[1] := inpDt.tabK2[1] + inpDt.tabK1[2] * 2;
  outDt.tabK1[2] := inpDt.tabK2[2] xor inpDt.tabK1[0];
  outDt.tabK1[3] := inpDt.tabK2[3] + inpDt.tabK2[0];
  outDt.tabK1[4] := inpDt.tabK2[4] - inpDt.tabK1[2];
  outDt.tabK1[5] := inpDt.tabK2[5] - inpDt.tabK2[0] + inpDt.tabK2[4];
  outDt.tabK1[6] := inpDt.tabK2[5] + (inpDt.tabK1[1] xor inpDt.tabK1[2]);

  outDt.tabK2[0] := inpDt.tabK1[0] + 20040 + inpDt.tabK1[3];
  outDt.tabK2[1] := inpDt.tabK1[1] - inpDt.tabK2[3];
  outDt.tabK2[2] := inpDt.tabK1[2] + inpDt.tabK2[2];
  outDt.tabK2[3] := inpDt.tabK1[3] + inpDt.tabK2[4] + inpDt.tabK2[5] + inpDt.tabK2[3];

  outDt.RecNrMx := RecNr + REC_NR_OUT_ADD;
  if onV <> 0 then
    outDt.Activ := ACTIV_ON
  else
    outDt.Activ := ACTIV_OFF;
end;

// funkcja wykonywana przez pytającego
function KeyLogCheckQueryReply(const outDt: TKeyLogQueryOut; const inpDt: TKeyLogQueryIn): byte;
var
  myOut: TKeyLogQueryOut;
  RecNr: byte;
  onV: byte;
begin

  RecNr := outDt.RecNrMx - REC_NR_OUT_ADD;
  if outDt.Activ = ACTIV_ON then
    onV := 1
  else
    onV := 0;

  KeyLogQueryReply(myOut, inpDt, RecNr, onV);
  if myOut.compare(outDt) then
  begin
    if onV <> 0 then
      Result := keyACTIV
    else
      Result := keyNO_ACTIV;
  end
  else
    Result := keyBAD_RPL;
end;

end.
