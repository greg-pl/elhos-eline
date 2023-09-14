unit eLineDef;

interface

uses
  Classes, Windows, WinSock, Messages, Types, SysUtils, Contnrs,
  System.AnsiStrings, DateUtils;

type
  // kody b³edów zwracane przez hardware
  TKStatus = class
  public type
    T = (
{$INCLUDE .\..\..\PROG\Common\Tags\errors.def   }
      stUnknowErrDelphi, stDelphiBase = 100);
  class function getTxt(code: integer): string; overload;
  class function getTxt(code: T): string; overload;
  class function getCode(code: integer): T;

  end;

  // lista objektów docelowych
  TTrkDev = (
{$INCLUDE .\..\..\PROG\Common\Tags\Group.dsd  }
  );

  // kody danych przekazywanych miêdzy obiektami
  // wspólne dla wszystkich kart

  TDevCommonObjCode = ( //
{$INCLUDE .\..\..\PROG\Common\Tags\DevCommon.ctg }
    msgDevCommonLast);

  THostObjCode = ( //
{$INCLUDE .\..\..\PROG\Common\Tags\Host.ctg }
    msgHostLast);

  TKpObjCode = ( //
{$INCLUDE .\..\..\PROG\Common\Tags\Kp.ctg }
    msgKpLast);

  TServiceObjCode = ( //
{$INCLUDE .\..\..\PROG\Common\Tags\ServiceCommon.ctg }
    msgServiceLast);

  TSensorObjCode = ( //
{$INCLUDE .\..\..\ESP32\eLineRmt\Main\Sensor.ctg }
    msgSensorLast);

const
  TRACK_BUF_SIZE = 1024;
  TRACK_IP_PORT = 9111;

const
  SIZE_SERIAL_NR = 12;
  SIZE_DEV_NAME = 32;
  CFG_HIST_CNT = 32;
  AMOR_KALIBR_CNT = 6;
  CHANNEL_DATA_LEN = 100;

  // definicja sta³ycch do okreœlenia jakoœci kalibracji
  CALIBR_BY_MEASURE = 1; // kalibracja powsta³a w wyniku pomiaru
  CALIBR_BY_TEXT = 2; // kalibracja zosta³a poprzez wpisanie wspó³czynników
  CALIBR_BY_FUN = 3; // kalibracja poprzez funkcjê wyliczaj¹c¹

type
  TByte3 = array [0 .. 2] of byte;

  TElineDevType = class
  public type
    T = ( //
      elTYP_UNKN = 0, //
      elTYP_HOST, //
      elTYP_KP, //
      elTYP_SENS_F, // czujnik nacisku
      elTYP_SENS_P // czujnik ciœnienia
      );
  public
    class function getDevType(code: byte): T; overload;
    class function getDevType(name: string): T; overload;
    class function getTypNameHid(typ: T): string;
  end;

  TKPService = class
  public type
    T = ( //
      uuBREAK_L = 0, //
      uuBREAK_R, //
      uuSUSP_L, //
      uuSUSP_R, //
      uuSLIP_SIDE, //
      uuWEIGHT_L, //
      uuWEIGHT_R //
      );
  public
    class function getBitMask(serv: T): cardinal;
    class function getServName(serv: T): string;
    class function getServNameHid(serv: T): string;
    class function isOK(serv: T): boolean;
  end;

  TKDATE = packed record
    rk: byte; //
    ms: byte; //
    dz: byte; //
    gd: byte; //
    mn: byte; //
    sc: byte; //
    se: byte; // setne czêœci sekundy
    timeSource: byte; //
    function getAsString: string;
    function getAsTime: TDateTime;
    procedure setTm(tm: TDateTime);
    procedure setNow;
    function getAsBytes: TBytes;
  end;

  TKVerInfo = packed record
    ver: word;
    rev: word;
    time: TKDATE;
    function getAsString: string;
    function getAsFullString: string;
    function loadFromStream(buf: TBytes; verOfset: integer): boolean;
    function loadFromBytes(buf: TBytes): boolean;
    function CompareTo(const Ver2: TKVerInfo): boolean;
  end;

  TKDevInfo = packed Record
    devType: byte;
    hdwVer: byte;
    firmVer: TKVerInfo;
    DevSpecData: cardinal;
    DevID: array [0 .. SIZE_DEV_NAME - 1] of AnsiChar;
    SerialNr: array [0 .. SIZE_SERIAL_NR - 1] of AnsiChar;
    procedure load(buf: TBytes);

    function getDevType: TElineDevType.T;
    function getDevTypAsStr: string;
    function getSerialNr: string;
    function getDevID: string;
    // HOST
    function getHostLineType: byte;
    function getHostFalownikType: byte;
    // KP
    function BuildLRStr(b: byte): string;
    function getActivBreaksLRStr: string;
    function getActivSuspensLRStr: string;
    function getActivSlipSideStr: string;
    function getActivWeightLRStr: string;

  end;

  TKHistoryItem = packed record
    ID: cardinal; // numer kolejny wpisu
    keySrvNr: word; // numer dongla serwisowego
    packedDate: word;
    function isValid: boolean;
    function getDateAsTime: TDateTime;
    function getDateAsStr: string;
  end;

  TKHistoryRec = packed record
    tab: array [0 .. CFG_HIST_CNT - 1] of TKHistoryItem;
    function getNewest: integer;
  end;

  // ---- keyLog -----------------------------------------------------
const
  KEYLOG_MAX_PACK_NR = 21;

type

  // programowalna struktura zapisywana w Eeprom KeyLog'a
  TKKeyLogInfo = packed record
    SerNumber: word;
    ProductionDate: word;
    Version: byte; // wersja zapisanych danych
    free: TByte3;
    function getKonfigurationDate: TDateTime;
    function getKonfigurationDateAsStr: string;
  end;

  TKKeyLogInfoRec = packed record
    ver: word;
    rev: word;
    PacketCnt: byte;
    KeyLogInfo: TKKeyLogInfo;
  end;

  TKKeyLogMode = (kmdOFF = 0, kmdON, kmdDEMO);

  TKKeyLogItem = packed record
    Mode: byte; // 0, 0xff-Close, 1-Open, 2-TimeOpen
    free: byte;
    ValidDate: word;
    ValidCnt: word;
    Free2: word;
    function getValidDate: TDateTime;
    function getValidDateAsStr: string;

  end;

  TKKeyLogData = packed record
    info: TKKeyLogInfoRec;
    tab: array [0 .. KEYLOG_MAX_PACK_NR - 1] of TKKeyLogItem;
  end;

  // ---- Pilot -----------------------------------------------------

  TKpilotCmd = (kpltGET_INFO = 1, kpltGO_SLEEP, kpltSET_SETUP, kpltCLR_CNT);

  TKpilotData = packed record
    code: word; // kod klawisza
    SendCnt: word; // licznik wys³anych klawiszy od WakeUP
    repCnt: byte; // licznik powtórzeñ pilota
    free: TByte3;
  end;

  // ---- Falowniki -----------------------------------------------------

  TFalownikNr = ( //
    falNR1 = 1, //
    falNR2 //
    );

  TFalownikCmd = ( //
    falTURNOFF = 1, //
    falTURN_FORW_SPEED1, //
    falTURN_FORW_SPEED2, //
    falTURN_BACK_SPEED1, //
    falTURN_BACK_SPEED2, //
    falTURN_EXITSUPPORT, //
    falTURN_FORW, //
    falTURN_BACK, //
    falTURNOFFFREE //
    );

  TKFalownikCmd = packed record
    status: byte;
    falNr: byte;
    falCmd: byte;
  end;

  // ---- Waga -----------------------------------------------------
  TKWeightData = packed record
    samplNr: integer;
    chnProc: array [0 .. 3] of single;
    chnVal: array [0 .. 3] of single;
    weight: single;
  end;

  // ---- Urz¹dzenie rolkowe -----------------------------------------------------
  TBreakFlags = ( //
    breakFlag_pressRol = $0001, // stan rolki najazdowej
    breakFlag_pls = $0002 // stan lini WhiteWire
    );

  TWspLin = packed record
    a: single;
    b: single;
  end;

  TChannelBuf = array [0 .. CHANNEL_DATA_LEN - 1] of word;

  TKBreakData = packed record
    bufferNr: integer;
    silHamowProc: single;
    silHamow: single;
    speed: single;
    flags: cardinal;
    wsp: TWspLin;
    buffer: TChannelBuf;
    function getFlagBit(bit: TBreakFlags): boolean;
    function getFlagInt(bit: TBreakFlags): integer;
  end;

  // ---- Amortyzatory -----------------------------------------------------

  TKSuspensDataRec = packed record
    bufferNr: integer;
    proc: single;
    wychyl: single;
    waga: single;
    flags: cardinal;
    wsp: TWspLin;
    buffer: TChannelBuf;
    function getFlagActiv: boolean;
  end;

  TKSuspensDataRecErrCfg = packed record
    bufferNr: integer;
    anProc: single;
  end;

  // ---- zbie¿noœæ -----------------------------------------------------

  TKSlipSideDataRec = packed record
    bufferNr: integer;
    proc: single;
    wychyl: single;
    startShift: single; // po³o¿enie p³yty w momencie otrzymania rozkazu startPomiaru
    flags: cardinal;
    wsp: TWspLin;
    buffer: TChannelBuf;
    function getFlagActiv: boolean;
    function getTypPlyty: byte;
    function getTypPlytyStr: string;
    function getNajazdSensorActiv: boolean;
    function getZjazdSensorActiv: boolean;
  end;

  TKSlipSideDataRecErrCfg = packed record
    bufferNr: integer;
    proc: single;
  end;

  TSlipSideResult = ( //
    sslOK = 0, //
    sslTimeTooLong, //
    sslTimeTooShort, //
    sslFlipExceeded, //
    sslMaxStartShiftExceeded);

  TKSlipSideMeasEnd = packed record
    status: integer; // SlipSideResult
    wychyl: single; // wychylenie maksymalne, wielkoœæ ze znakiem
    measTime: single; // czas w sekundach
    function getStatusTxt: string;
  end;

  // ---- Sensory -----------------------------------------------------
const
  SENS_AN_CNT = 4;
  SENS_MEAS_EXP_CNT = 5;

type
  TSensorCh = (schINP,schVBAT,schV12,schI12);

  TSensorMeasData = packed record
    time: cardinal;
    tabProc: array [0 .. SENS_AN_CNT - 1] of single;
    tabFiz: array [0 .. SENS_AN_CNT - 1] of single;
    inp: array [0 .. SENS_MEAS_EXP_CNT - 1] of single;
  end;

implementation

function KnvAnciCharTab(pchar: PAnsiChar; size: integer): string;
var
  s1: AnsiString;
begin
  setlength(s1, size);
  move(pchar^, s1[1], size);
  setlength(s1, System.AnsiStrings.StrLen(PAnsiChar(s1)));
  Result := String(s1);
end;

function TKDATE.getAsTime: TDateTime;
begin
  if not TryEncodeDateTime(2000 + rk, ms, dz, gd, mn, sc, 0, Result) then
    Result := 0;
end;

procedure TKDATE.setTm(tm: TDateTime);
var
  AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: word;
begin
  DecodeDateTime(tm, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
  rk := AYear mod 100;
  ms := AMonth;
  dz := ADay;
  gd := AHour;
  mn := AMinute;
  sc := ASecond;
  se := AMilliSecond div 10;
end;

procedure TKDATE.setNow;
begin
  setTm(now);
end;

function TKDATE.getAsBytes: TBytes;
begin
  setlength(Result, sizeof(self));
  move(self, Result[0], sizeof(self));
end;

function TKDATE.getAsString: string;
var
  tm: TDateTime;
begin
  tm := getAsTime;
  if tm <> 0 then
    DateTimeToString(Result, 'yyyy.mm.dd hh:nn:ss', tm)
  else
    Result := '????.??.??';
end;

function TKVerInfo.getAsString: string;
begin
  Result := Format('%u.%.3u', [ver, rev]);
end;

function TKVerInfo.getAsFullString: string;
begin
  Result := Format('%u.%.3u %s', [ver, rev, time.getAsString]);
end;

function TKVerInfo.CompareTo(const Ver2: TKVerInfo): boolean;
begin
  Result := (ver = Ver2.ver) and (rev = Ver2.rev);
end;

function TKVerInfo.loadFromStream(buf: TBytes; verOfset: integer): boolean;
var
  s: AnsiString;
  ss: string;
begin
  Result := false;
  setlength(s, $30);
  move(buf[verOfset], s[1], $30);
  if (copy(s, 1, 7) = 'Date : ') and //
    (copy(s, 1 + 16, 7) = 'Time : ') and //
    (copy(s, 1 + 32, 4) = 'Ver.') and //
    (copy(s, 1 + 32 + 8, 4) = 'Rev.') then
  begin
    try
      ss := String(s);
      ver := StrToInt(copy(ss, 32 + 5, 3));
      rev := StrToInt(copy(ss, 32 + 8 + 5, 3));
      time.rk := StrToInt(copy(ss, 8, 2));
      time.ms := StrToInt(copy(ss, 11, 2));
      time.dz := StrToInt(copy(ss, 14, 2));
      time.gd := StrToInt(copy(ss, 16 + 8, 2));
      time.mn := StrToInt(copy(ss, 16 + 11, 2));
      time.sc := StrToInt(copy(ss, 16 + 14, 2));
      Result := true;
    except
      Result := false;
    end;
  end;
end;

function TKVerInfo.loadFromBytes(buf: TBytes): boolean;
const
  Pattern: string = //
    'Date : ##.##.## ' + //
    'Time : ##:##:## ' + //
    'Ver.### Rev.### ';

  MAX_FIND_AREA = $800;

  function CheckPattern(ofs: integer): boolean;
  var
    i, n: integer;
    ch: char;
    tab: array of byte;
  begin
    n := length(Pattern);
    setlength(tab, n);
    Result := true;
    move(buf[ofs], tab[0], n);

    for i := 0 to n - 1 do
    begin
      ch := Pattern[i + 1];
      if (ch <> '#') and (ord(ch) <> tab[i]) then
      begin
        Result := false;
        break;
      end;
    end;
  end;

var
  ofs: integer;
  Fnd: boolean;
  mmL: integer;
begin
  Result := false;
  Fnd := false;
  ofs := $10;
  mmL := length(buf);
  if mmL > MAX_FIND_AREA then
    mmL := MAX_FIND_AREA;
  while ofs + length(Pattern) <= mmL do
  begin
    if CheckPattern(ofs) then
    begin
      Fnd := true;
      break;
    end;
    inc(ofs, $10);
  end;
  if Fnd then
  begin
    Result := loadFromStream(buf, ofs);
  end;

end;

// -------------------------------------------------------------------------
procedure TKDevInfo.load(buf: TBytes);
var
  n1, n2: integer;
begin
  n1 := length(buf);
  n2 := sizeof(self);
  if n1 = n2 then
    move(buf[0], self, n1)
  else
    raise exception.Create('TKDevInfo format error');
end;

function TKDevInfo.getDevType: TElineDevType.T;
begin
  Result := TElineDevType.getDevType(devType);
end;

function TKDevInfo.getDevTypAsStr: string;
begin
  Result := TElineDevType.getTypNameHid(getDevType);
end;

function TKDevInfo.getSerialNr: string;
begin
  Result := KnvAnciCharTab(SerialNr, sizeof(SerialNr));
end;

function TKDevInfo.getDevID: string;
begin
  Result := KnvAnciCharTab(DevID, sizeof(DevID));
end;

function TKDevInfo.getHostLineType: byte;
begin
  Result := DevSpecData and $0F;
end;

function TKDevInfo.getHostFalownikType: byte;
begin
  Result := (DevSpecData shr 7) and $07;
end;

function TKDevInfo.BuildLRStr(b: byte): string;
begin
  case b of
    1:
      Result := 'lewy';
    2:
      Result := 'prawy';
    3:
      Result := 'Lewy,prawy';
  else
    Result := '---';
  end;
end;

function TKDevInfo.getActivBreaksLRStr: string;
begin
  Result := BuildLRStr(DevSpecData and $0003);
end;

function TKDevInfo.getActivSuspensLRStr: string;
begin
  Result := BuildLRStr((DevSpecData shr 2) and $0003);
end;

function TKDevInfo.getActivSlipSideStr: string;
begin
  Result := '---';
  if ((DevSpecData shr 4) and $0001) <> 0 then
    Result := 'Jest';
end;

function TKDevInfo.getActivWeightLRStr: string;
begin
  Result := BuildLRStr((DevSpecData shr 5) and $0003);
end;


// ---- TKStatus -------------------------------------------------

class function TKStatus.getTxt(code: integer): string;
begin
  if (code >= 0) and (code < ord(T.stLAST)) then
  begin
    case code of
      ord(stOk):
        Result := 'Ok';

      ord(stError):
        Result := 'HalError';
      ord(stBusy):
        Result := 'HalBusy';
      ord(stTimeOut):
        Result := 'HalTimeOut';

      ord(stCrcError): //
        Result := 'CrcError';
      ord(stCompareErr): //
        Result := 'Compare Error';
      ord(stNoSemafor): //
        Result := 'Zajêty semafor';
      ord(stDataErr): //
        Result := 'B³ad danych';
      ord(stMdbErr1): // b³ad 1 modbus'a
        Result := 'B³¹d modbus 1';
      ord(stMdbErr2): // b³ad 2 modbus'a
        Result := 'B³¹d modbus 2';
      ord(stMdbErr3): // b³ad 3 modbus'a
        Result := 'B³¹d modbus 3';
      ord(stMdbErr4): // b³ad 4 modbus'a
        Result := 'B³¹d modbus 4';
      ord(stMdbError): //
        Result := 'Modbus error';
      ord(stCfgDataErr): //
        Result := 'B³¹d konfiguracji';

      ord(stBelkiUp): //
        Result := 'stBelkiUp';
      ord(stMotocyklMode): //
        Result := 'stMotocyklMode';
      ord(stUnknownFalCmd): //
        Result := 'Nieznana komenda falownik';
      ord(stUnknownFalNr): //
        Result := 'Niepoprawny numer falownika';

      ord(stNotAllignedData):
        Result := 'dane nie wyrównane';
      ord(stAdrTooBig):
        Result := 'Zbyt daleki adres';
      ord(stLengthNoAllign):
        Result := 'D³ugoœæ nie jest wielokrotnoœci¹ 4';
      ord(stCompareError):
        Result := 'B³ad porównania';
      ord(stNotClear):
        Result := 'Flash nie jest czysty';
    else
      Result := Format('nieznany kod:%u', [code]);
    end;
  end;

end;

class function TKStatus.getTxt(code: T): string;
begin
  Result := getTxt(ord(code));
end;

class function TKStatus.getCode(code: integer): T;
begin
  if (code >= 0) and (code < ord(T.stLAST)) then
  begin
    Result := T(code);
  end
  else
    Result := stUnknowErrDelphi;
end;


// ---- TElineDevType -------------------------------------------------

class function TElineDevType.getDevType(code: byte): T;
begin
  if code > byte(ord(high(T))) then
    Result := elTYP_UNKN
  else
    Result := T(code);
end;

class function TElineDevType.getDevType(name: string): T;
begin
  if name = 'eLineHOST' then
    Result := elTYP_HOST
  else if name = 'eLineKP' then
    Result := elTYP_KP
  else if name = 'eLineSENS_F' then
    Result := elTYP_SENS_F
  else if name = 'eLineSENS_P' then
    Result := elTYP_SENS_P
  else
    Result := elTYP_UNKN;
end;

class function TElineDevType.getTypNameHid(typ: T): string;
begin
  case typ of
    elTYP_UNKN:
      Result := '???';
    elTYP_HOST:
      Result := 'HOST';
    elTYP_KP:
      Result := 'KP';
    elTYP_SENS_F:
      Result := 'SENS_F';
    elTYP_SENS_P:
      Result := 'SENS_P'
  else
    Result := 'XXX'
  end;
end;

// ------------------------------------------------------------------------

class function TKPService.getBitMask(serv: T): cardinal;
begin
  Result := $00001 shl ord(serv);

end;

class function TKPService.getServName(serv: T): string;
begin
  case serv of
    uuBREAK_L:
      Result := 'BREAK_L';
    uuBREAK_R:
      Result := 'BREAK_R';
    uuSUSP_L:
      Result := 'SUSPENSION_L';
    uuSUSP_R:
      Result := 'SUSPENSION_R';
    uuSLIP_SIDE:
      Result := 'SLIP SIDE';
    uuWEIGHT_L:
      Result := 'WEIGHT_L';
    uuWEIGHT_R:
      Result := 'WEIGHT_R';
  else
    raise exception.Create('TKPService: Incorrect typr');
  end;
end;

class function TKPService.isOK(serv: T): boolean;
begin
  Result := (serv >= low(T)) and (serv <= high(T));
end;

class function TKPService.getServNameHid(serv: T): string;
begin
  case serv of
    uuBREAK_L:
      Result := 'Hamulec lewy';
    uuBREAK_R:
      Result := 'Hamulec prawy';
    uuSUSP_L:
      Result := 'Tester amort. lewy';
    uuSUSP_R:
      Result := 'Tester amort. prawy';
    uuSLIP_SIDE:
      Result := 'Zbie¿noœæ';
    uuWEIGHT_L:
      Result := 'Waga lewa';
    uuWEIGHT_R:
      Result := 'Waga prawa';
  else
    raise exception.Create('TKPService: Incorrect typr');
  end;
end;




// ------------------------------------------------------------------------

function TKHistoryItem.isValid: boolean;
begin
  Result := (packedDate <> 0) and (packedDate <> $FFFF);
end;

function TKHistoryItem.getDateAsTime: TDateTime;
begin
  try
    Result := FileDateToDateTime(packedDate shl 16)
  except
    Result := 0;
  end;
end;

function TKHistoryItem.getDateAsStr: string;

var
  tm: TDateTime;
begin
  tm := getDateAsTime;
  if tm <> 0 then
    DateTimeToString(Result, 'yyyy.mm.dd', tm)
  else
    Result := '????.??.??';
end;

function TKHistoryRec.getNewest: integer;
var
  i: integer;
  mxId: integer;
  mxIdx: integer;
begin
  mxId := -1;
  mxIdx := -1;
  for i := 0 to CFG_HIST_CNT - 1 do
  begin
    if integer(tab[i].ID) > mxId then
    begin
      mxId := tab[i].ID;
      mxIdx := i;
    end;
  end;
  Result := mxIdx;
end;

function TKKeyLogInfo.getKonfigurationDate: TDateTime;
begin
  try
    Result := FileDateToDateTime(ProductionDate shl 16)
  except
    Result := 0;
  end;

end;

function TKKeyLogInfo.getKonfigurationDateAsStr: string;
var
  tm: TDateTime;
begin
  tm := getKonfigurationDate;
  if tm <> 0 then
    DateTimeToString(Result, 'yyyy.mm.dd', tm)
  else
    Result := '????.??.??';

end;

function TKKeyLogItem.getValidDate: TDateTime;
begin
  try
    Result := FileDateToDateTime(ValidDate shl 16)
  except
    Result := 0;
  end;

end;

function TKKeyLogItem.getValidDateAsStr: string;
var
  tm: TDateTime;
begin
  tm := getValidDate;
  if tm <> 0 then
    DateTimeToString(Result, 'yyyy.mm.dd', tm)
  else
    Result := '????.??.??';
end;

function TKBreakData.getFlagBit(bit: TBreakFlags): boolean;
begin
  Result := ((flags and ord(bit)) <> 0);
end;

function TKBreakData.getFlagInt(bit: TBreakFlags): integer;
begin
  Result := integer(getFlagBit(bit));
end;

function TKSuspensDataRec.getFlagActiv: boolean;
begin
  Result := ((flags and $00001) <> 0);
end;

// -----------------------------
function TKSlipSideDataRec.getFlagActiv: boolean;
begin
  Result := ((flags and $00001) <> 0);
end;

function TKSlipSideDataRec.getTypPlyty: byte;
begin
  Result := (flags shr 4) and $0000F;
end;

function TKSlipSideDataRec.getTypPlytyStr: string;
begin
  case getTypPlyty of
    0:
      Result := 'P³.bez czujników';
    1:
      Result := 'P³.z czujnikiem przejazdu';
    2:
      Result := 'P³.z czujnikami  najazdu i zjazdu';
  else
    Result := 'Nieznany typ p³yty';
  end;
end;

function TKSlipSideDataRec.getNajazdSensorActiv: boolean;
begin
  Result := ((flags and $00002) <> 0);
end;

function TKSlipSideDataRec.getZjazdSensorActiv: boolean;
begin
  Result := ((flags and $00004) <> 0);
end;

function TKSlipSideMeasEnd.getStatusTxt: string;
begin
  case status of
    ord(sslOK):
      Result := 'Ok';
    ord(sslTimeTooLong):
      Result := 'Time too long';
    ord(sslTimeTooShort):
      Result := 'Time too short';
    ord(sslFlipExceeded):
      Result := 'Flip exceeded';

    ord(sslMaxStartShiftExceeded):
      Result := 'Too big zero-shift';
  else
    Result := Format('Unknow status, cd=%d', [status]);
  end;

end;

end.
