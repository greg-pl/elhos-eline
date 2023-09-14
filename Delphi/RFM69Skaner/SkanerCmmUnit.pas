unit SkanerCmmUnit;

interface

uses
  System.Contnrs,
  classes, Registry, Windows, SysUtils, InterRsd,
  CrcUnit;

const
  DT_LEN = 32;
  FRAME_DT_LEN = 29;
  HEAD_CNT = 4;
  MEAS_PERIOD = 80.0; // okres pomiaru
  SLOT_WIDTH = 10.0; // szerokoœc slotu dla danej g³owicy
  MEAS_PERIOD_ALL = 1920.0; // okres pomiaru
  DEV_MOST = 15;
  TIME_INVALID = -1000000;

type
  TMesgType = ( //
    nuRADIO_CFG = 1, //
    nuRADIO_DATA, //
    nuRED_PULSE //
    );

const
  VAL_TYS = 1000;
  VAL_MILION = VAL_TYS * VAL_TYS;

  GEO_FREQ_BASE = 863 * VAL_MILION;
  GEO_FREQ_CHANNEL_WIDE = 400 * VAL_TYS;

  SZA_FREQ_CHANNEL_WIDE = 100 * VAL_TYS;
  SZA_FREQ_BASE = 868 * VAL_MILION;

  ELINE_FREQ_CHANNEL_WIDE = 100 * VAL_TYS;
  ELINE_FREQ_BASE = 868 * VAL_MILION + 50 * VAL_TYS;

  MIN_UNIFREQ = 863.0;
  MAX_UNIFREQ = 880.0;

type

  TRadioBaudRate = (bd4800, bd19200, bd38400, bd300000);

  TRfm69SkanerCfg = packed record
    LedBottomMode: byte;
    free: array [0 .. 6] of byte;
    ChannelFreq: integer;
    BaudRate: byte;
    TxPower: byte;
    HighPower: byte;
    free2: array [0 .. 4] of byte;
  end;

  // ------------------------------------------------------------------------------
  // Geometria
  // ------------------------------------------------------------------------------

  TGeomCmd = (cmrUNKNOW, //
    cmrACK, // potwierdzenie operacji
    cmrPING, // test po³¹czenia
    cmrGET_FIRM_VER, // odczyt wersji firmware,
    cmrTIME_SYNCH, // 4 synchronizacja czasu (milisekund)
    cmrGET_DT, // 3 odczyt danych
    cmrSOUND, // 5 wygenerowanie dŸwiêku
    cmrLED_DT, // sterowanie diodami LED na Panelu
    cmrWR_CFG, // zapis danych kalibruj¹cych
    cmrRD_CFG, // odczt danych kalibruj¹cych
    cmrWR_SERVICE_CFG, // zapis danych servisowych
    cmrRD_SERVICE_CFG, // odczt danych servisowych
    cmrWR_PRODUC_CFG, // zapis danych producenta
    cmrRD_PRODUC_CFG, // odczt danych producenta
    cmrSET_MOST_MODE, // Tryb pracy mostu
    cmrGET_MOST_MODE, // Tryb pracy mostu
    cmrUSER_CMD, cmrSAVE_HOSTDATA, // dane wspó³dzielone dla hostów
    cmrLOAD_HOSTDATA, // dane wspó³dzielone dla hostów
    cmrSAVEFLASH_HOSTDATA, // zapisanie danych wspó³dzielonych do pamiêci FLASH
    cmrTIME_SYNCH_REP, // 0x14 synchronizacja czasu (milisekund), powielenie z opóŸnieniem
    cmrWR_SPEC_CFG, // 0x15=21  zapis danych konfiguracyjnych do ustawiania scenariuszy
    cmrVL_SPEC_CFG, // 0x16=22 zapis danych konf. do ustawiania scenariuszy, ale bez zapisywania do pamiêci FLASH
    cmrRD_SPEC_CFG, // 0x17=23  odczt danych konfiguracyjnych do ustawiania scenariuszy
    cmrMAX__);

  // dane otrzymane z radia
  TGeometriaRec = packed record
    srcDev: byte;
    Cmd: byte; // TGeomCmd;
    data: array [0 .. FRAME_DT_LEN - 1] of byte;
    dtLen: byte;
    function getSrcNr: string;
    function getHeadNr: integer;
    function getGeoCmd: TGeomCmd;

  end;

  // ------------------------------------------------------------------------------
  // Szarpak
  // ------------------------------------------------------------------------------
const
  DEVICE_STEROWNIK = 0;
  DEVICE_PILOT = 1;
  DEVICE_SKANER = 2;

type
  TSzPilotMsg = ( //
    // kierowane do pilota
    skPlCmdNoBeep = 1, //
    skPlCmdBeep, //
    skPlCmdBeep2, //
    skPlCmdLampOn, //
    skPlCmdLampOff, //
    skPlCmdSetUpChannel, // ustawienie numeru kana³u

    // kierowane do Sterownika
    skStCmdNoBeep = 21, //
    skStCmdBeep, //
    skStCmdBeep2 //

    );

  TSzarpakData = packed record
    frameCnt: byte;
    frameType: byte;
    keys: word;
    nKeys: word;
    batVolt: word;
    lamp: byte;
    Ver: byte;
    Rev: word;
    OptByte1: byte;
    OptByte2: byte;
    free: array [0 .. 3] of byte;
    suma: word;
    function CheckFrame: boolean;
    function CheckFrameCrc: boolean;
    function CheckKeyBits: boolean;
  end;

  // ------------------------------------------------------------------------------
  // Format u¿ywany przez skaner
  // ------------------------------------------------------------------------------
const
  MAX_RAW_DATA_LEN = 64;

type
  TAckRec = packed record
    ackFun: byte;
  end;

  TRadioRecBuf = array [0 .. MAX_RAW_DATA_LEN - 1] of byte;

  TRadioData = record
    function SetFromStr(s: string): boolean;
    function AsString(len: integer): string;

    case M: byte of
      0:
        (RecBuf: TRadioRecBuf);
      1:
        (Ge: TGeometriaRec);
      2:
        (Sz: TSzarpakData);
      3:
        (Ack: TAckRec);
  end;

  TSkData = packed record
    tick: cardinal; // czas w milisekundach
    mick: byte; // u³amek milisekundy
    sender: byte; // Numer radia nadaj¹cego ramkê
    RSSI: byte; // si³a sygna³u radiowego
    dtLen: byte; // d³ugoœc danych w ramce radiowej
    frameNr: integer; // numer kolejny ramki
  end;

  TSkanerRec = packed record
    SkData: TSkData; // dane do³ozone przez SzSkaner
    RadioDt: TRadioData; // ramka odebrana przez radio
    function LoadfromSkString(s: String): boolean;
    function AsString(lev: integer): string;
    function GetTime: double;
    function getAsSaveStr: string;
    function loadFromSaveStr(s: string): boolean;
    function DataAsString: string;
  end;

  TSkanerObj = class(TObject)
  public type
    TGeoInfo = record
      RelTime: double; // czas relatywny do ramki synchronizacji czasu
      DataRelTime: double; // czas relatywny do ramki tego samego typu
      SyncFrame: integer; // numer ramki, która jest synchronizacj¹ czasu dla tej ramki
    end;
  public
    idx: integer;
    SkRec: TSkanerRec;
    GeoInfo: TGeoInfo;
    constructor Create;
    function AsString: string;
    function timeInRegion(valOk, deviation: double): boolean;
    function getSlotTime: double;
  end;

  TFiltrRssi = class(TObject)
  private const
    FILTR_LEN = 8;
  private
    ptr: integer;
    buf: array [0 .. FILTR_LEN - 1] of byte;
  public
    constructor Create;
    procedure Add(RSSI: integer);
    function Srednia: byte;
  end;

  TSkanerMode = (skmUNI, skmGEO);

  TSkanerDtList = class(TObjectList)
  private
    // dane oostatniej ramce synchronizacji czasu
    mStartTick: cardinal;
    mSyncTimeFrame: integer;
    mSyncTime: double;
    mDtSynchTime: double;
    mLastMostPing: double; // czas ramki Ping z Most
    mDtFrameTime: array [0 .. HEAD_CNT - 1] of double;
    function FGetItem(Index: integer): TSkanerObj;
  public const
    DEV_CNT = 5;
  public
    FiltrRssi: array [0 .. DEV_CNT - 1] of TFiltrRssi;
    SkanerMode: TSkanerMode;

    constructor Create;
    destructor Destroy; override;
    property Items[Index: integer]: TSkanerObj read FGetItem;
    function AddSKL(D: TSkanerObj): boolean;
    procedure Start;
    procedure SaveToFile(FName: string);
    procedure SaveToSL(SL: TStringList);
    procedure LoadFromFile(FName: string);
    procedure LoadFromSL(SL: TStringList);

  end;

  TSkanerDev = class;

  TSkanerCom = class(TComDevice)
  private
    mOwner: TSkanerDev;
  protected
    procedure doNewLine; override;

  public
    constructor Create(Owner: TSkanerDev);

  end;

  TDataNotify = procedure(Dender: TObject; D: TSkanerObj) of object;
  TAckSendingNotify = procedure(sender: TObject; msgType: TMesgType) of object;

  TSkanerDev = class(TObject)
  private
    mFirstData: boolean;
    mFirstTick: cardinal;
    Com: TSkanerCom;
    function WriteMessage(msg: TBytes): TStatus;
  public
    OnDataNotify: TDataNotify;
    OnAckSendNotify: TAckSendingNotify;
    SkanerDtList: TSkanerDtList;
    constructor Create;
    destructor Destroy; override;
    procedure dorecLine(s: string);
    function Connected: boolean;
    procedure CloseDev;
    function OpenDev(ComNr: integer): TStatus;
    function ComNr: integer;
    function GetErrStr(st: TStatus): string;
    function GetComThreadStr: string;
    function WriteCfgMessage(msg: TBytes): TStatus; overload;
    function WriteCfgMessage(SzSkanerCfg: TRfm69SkanerCfg): TStatus; overload;

    function WriteDataMessage(slotNr: byte; msg: TBytes): TStatus; overload;
    function WriteDataMessage(slotNr: byte; var w; size: integer): TStatus; overload;
    function WriteLedMessage: TStatus;
  end;

procedure LoadRsPorts(Coms: TStrings);
function GetComNr(s: string): integer;
function WzTimeStr(tm: double): string;
function GetGeomCmdName(b: byte): string;
function inRegion(val, valOk, deviation: double): boolean;
function getdBm(RSSI: byte): double;
function getdBmStr(RSSI: byte): string;

implementation

const
  GeomCmdName: array [TGeomCmd] of string = ('UNKNOW', //
    'ACK', // potwierdzenie operacji
    'PING', // test po³¹czenia
    'GET_FIRM_VER', // odczyt wersji firmware,
    'TIME_SYNCH', // 4 synchronizacja czasu (milisekund)
    'GET_DT', // 3 odczyt danych
    'SOUND', // 5 wygenerowanie dŸwiêku
    'LED_DT', // sterowanie diodami LED na Panelu
    'WR_CFG', // zapis danych kalibruj¹cych
    'RD_CFG', // odczt danych kalibruj¹cych
    'WR_SERVICE_CFG', // zapis danych servisowych
    'RD_SERVICE_CFG', // odczt danych servisowych
    'WR_PRODUC_CFG', // zapis danych producenta
    'RD_PRODUC_CFG', // odczt danych producenta
    'SET_MOST_MODE', // Tryb pracy mostu
    'GET_MOST_MODE', // Tryb pracy mostu
    'USER_CMD', 'SAVE_HOSTDATA', // dane wspó³dzielone dla hostów
    'LOAD_HOSTDATA', // dane wspó³dzielone dla hostów
    'SAVEFLASH_HOSTDATA', // zapisanie danych wspó³dzielonych do pamiêci FLASH
    'TIME_SYNCH_REP', // 0x14 synchronizacja czasu (milisekund), powielenie z opóŸnieniem
    'WR_SPEC_CFG', // 0x15=21  zapis danych konfiguracyjnych do ustawiania scenariuszy
    'VL_SPEC_CFG', // 0x16=22 zapis danych konf. do ustawiania scenariuszy, ale bez zapisywania do pamiêci FLASH
    'RD_SPEC_CFG', // 0x17=23  odczt danych konfiguracyjnych do ustawiania scenariuszy
    'MAX__');

function GetGeomCmdName(b: byte): string;
begin
  if (b >= ord(low(TGeomCmd))) and (b <= ord(high(TGeomCmd))) then
    Result := GeomCmdName[TGeomCmd(b)]
  else
    Result := '??:' + IntToStr(b);
end;

function inRegion(val, valOk, deviation: double): boolean;
begin
  Result := abs(val - valOk) <= deviation;
end;

function getdBm(RSSI: byte): double;
begin
  Result := -RSSI / 2;

end;

function getdBmStr(RSSI: byte): string;
begin
  Result := Format('%.1f', [getdBm(RSSI)]);
end;

function WzTimeStr(tm: double): string;
begin
  if tm > TIME_INVALID then
    Result := Format('%.2f', [tm])
  else
    Result := '-';
end;

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

const
  STX: char = #2;
  ETX: char = #3;

function TGeometriaRec.getHeadNr: integer;
var
  M: integer;
begin
  M := (srcDev shr 4);
  Result := -1;
  if M = 1 then
    Result := 0;
  if M = 2 then
    Result := 1;
  if M = 4 then
    Result := 2;
  if M = 8 then
    Result := 3;
  if M = 15 then
    Result := DEV_MOST;
end;

function TGeometriaRec.getSrcNr: string;
var
  M: integer;
  i: integer;
begin
  M := (srcDev shr 4);
  Result := '';
  for i := 0 to 3 do
  begin
    if (M and (1 shl i)) <> 0 then
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + IntToStr(i + 1);
    end;
  end;

end;

function TGeometriaRec.getGeoCmd: TGeomCmd;
var
  b: integer;
begin
  b := Cmd;
  if (b >= ord(low(TGeomCmd))) and (b <= ord(high(TGeomCmd))) then
    Result := TGeomCmd(b)
  else
    Result := cmrUNKNOW;
end;

function TSzarpakData.CheckFrameCrc: boolean;
begin
  Result := TCrc.Check(self, sizeof(self));
end;

function TSzarpakData.CheckKeyBits: boolean;
begin
  Result := keys = not(nKeys);
end;

function TSzarpakData.CheckFrame: boolean;
begin
  Result := CheckFrameCrc and CheckKeyBits;
end;

function TRadioData.SetFromStr(s: string): boolean;
var
  n, i: integer;
  s1: string;
begin
  try
    for i := 0 to n - 1 do
    begin
      s1 := '$' + copy(s, 1 + i * 2, 2);
      RecBuf[i] := StrToInt(s1);
    end;
    Result := true;
  except
    Result := false;
  end;
end;

function TRadioData.AsString(len: integer): string;
var
  i: integer;
begin
  if len > MAX_RAW_DATA_LEN then
    len := MAX_RAW_DATA_LEN;

  Result := '';
  for i := 0 to len - 1 do
    Result := Result + IntToHex(RecBuf[i], 2);
end;

function TSkanerRec.LoadfromSkString(s: String): boolean;
const
  SK_REC_LEN = sizeof(TSkData) + sizeof(TRadioRecBuf);
type
  TSkRecData = packed record
    case V: byte of
      0:
        (buf: array [0 .. MAX_RAW_DATA_LEN - 1] of byte);
      1:
        (SkData: TSkData;
          RadioRecBuf: TRadioRecBuf;
        );
  end;

var
  n: integer;
  Sz: integer;
  sz1: integer;
  i: integer;
  w: integer;
  s1: string;
  suma: integer;
  suma2: integer;
  mRec: TSkRecData;
begin
  Result := false;
  n := length(s);
  if (s[1] = STX) and (s[n] = ETX) then
  begin
    try
      sz1 := (n - 4 - 2) div 2;
      if sz1 > MAX_RAW_DATA_LEN then
        sz1 := MAX_RAW_DATA_LEN;
      w := 2;
      suma := 0;
      for i := 0 to sz1 - 1 do
      begin
        suma := suma + ord(s[w]);
        suma := suma + ord(s[w + 1]);

        s1 := '$' + copy(s, w, 2);
        mRec.buf[i] := StrToInt(s1);
        inc(w, 2);
      end;
      s1 := '$' + copy(s, w, 4);
      suma2 := StrToInt(s1);

      Result := (suma = suma2);
      SkData := mRec.SkData;
      RadioDt.RecBuf := mRec.RadioRecBuf;
    except
      Result := false;
    end;
    if not Result then
      OutputDebugString('Uszkodzona ramka');
  end;

end;

function TSkanerRec.GetTime: double;
begin
  Result := SkData.tick + SkData.mick / 100.0;
end;

function TSkanerRec.AsString(lev: integer): string;
begin
  Result := Format('%u. T=%.2f R:%u S:%u Cmd=%u', [SkData.frameNr, GetTime, SkData.sender, RadioDt.Ge.srcDev,
    RadioDt.Ge.Cmd]);
end;

function TSkanerRec.getAsSaveStr: string;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.Add(IntToStr(SkData.tick));
    SL.Add(IntToStr(SkData.mick));
    SL.Add(IntToStr(SkData.sender));
    SL.Add(IntToStr(SkData.RSSI));
    SL.Add(IntToStr(SkData.dtLen));
    SL.Add(IntToStr(SkData.frameNr));
    SL.Add(RadioDt.AsString(SkData.dtLen));
    SL.Delimiter := ';';
    Result := SL.DelimitedText;
  finally
    SL.free;
  end;
end;

function TSkanerRec.loadFromSaveStr(s: string): boolean;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try

    SL.Delimiter := ';';
    SL.DelimitedText := s;
    try
      SkData.tick := StrToInt(SL.Strings[0]);
      SkData.mick := StrToInt(SL.Strings[1]);
      SkData.sender := StrToInt(SL.Strings[2]);
      SkData.RSSI := StrToInt(SL.Strings[3]);
      SkData.dtLen := StrToInt(SL.Strings[4]);
      SkData.frameNr := StrToInt(SL.Strings[5]);
      Result := RadioDt.SetFromStr(SL.Strings[6]);
    except
      Result := false;

    end;
  finally
    SL.free;
  end;
end;

function TSkanerRec.DataAsString: string;
var
  buf: array of byte;
  n, i: integer;
  n1: integer;
begin
  n := sizeof(RadioDt.RecBuf);
  setlength(buf, n);
  Move(RadioDt.RecBuf, buf[0], n);

  n1 := SkData.dtLen;
  if n1 > n then
    n1 := n;

  Result := '';
  for i := 0 to n1 - 1 do
    Result := Result + IntToHex(buf[i], 2);

end;

// -------------------------------------------------------------------------------
constructor TSkanerObj.Create;
begin
  inherited;
  GeoInfo.RelTime := TIME_INVALID;
  GeoInfo.DataRelTime := TIME_INVALID;
end;

function TSkanerObj.timeInRegion(valOk, deviation: double): boolean;
begin
  Result := inRegion(GeoInfo.RelTime, valOk, deviation);
end;

function TSkanerObj.getSlotTime: double;
var
  hNr: integer;
  n: integer;
begin
  Result := TIME_INVALID;
  hNr := SkRec.RadioDt.Ge.getHeadNr;
  if hNr >= 0 then
  begin
    n := trunc(GeoInfo.RelTime / MEAS_PERIOD);
    Result := GeoInfo.RelTime - n * MEAS_PERIOD;
    if hNr <> 15 then
    begin
      Result := Result - (hNr + 1) * SLOT_WIDTH;
    end
    else
    begin

    end;
  end;
end;

function TSkanerObj.AsString: string;
begin
  Result := SkRec.AsString(0);
  Result := Result + Format('Tr=%.2f', [GeoInfo.RelTime]);
end;
// ------------------------------------------------------------------------

constructor TFiltrRssi.Create;
begin
  inherited;
  ptr := -1;
end;

procedure TFiltrRssi.Add(RSSI: integer);
var
  i: integer;
begin
  if ptr = -1 then
  begin
    for i := 0 to FILTR_LEN - 1 do
      buf[i] := RSSI;
    ptr := 0;
  end
  else
  begin
    buf[ptr] := RSSI;
    inc(ptr);
    if ptr >= FILTR_LEN then
      ptr := 0;
  end;
end;

function TFiltrRssi.Srednia: byte;
var
  i: integer;
  suma: integer;
begin
  suma := 0;
  for i := 0 to FILTR_LEN - 1 do
    suma := suma + buf[i];
  Result := (suma + FILTR_LEN div 2) div FILTR_LEN;
end;

// ------------------------------------------------------------------------
constructor TSkanerDtList.Create;
var
  i: integer;
begin
  inherited Create(true);
  Start;
  for i := 0 to DEV_CNT - 1 do
    FiltrRssi[i] := TFiltrRssi.Create;
  SkanerMode := skmUNI;
end;

destructor TSkanerDtList.Destroy;
var
  i: integer;
begin
  inherited;
  for i := 0 to DEV_CNT - 1 do
    FiltrRssi[i].free;
end;

procedure TSkanerDtList.Start;
begin
  mStartTick := GetTickCount;
  mSyncTimeFrame := -1;
  Clear;
end;

function TSkanerDtList.FGetItem(Index: integer): TSkanerObj;
begin
  Result := inherited GetItem(Index) as TSkanerObj;
end;

function TSkanerDtList.AddSKL(D: TSkanerObj): boolean;
var
  Cmd: TGeomCmd;
  headNr: integer;
  devNr: integer;
  tm: double;
  dt: cardinal;
  doAdd: boolean;

begin
  Result := false;
  dt := GetTickCount - mStartTick;

  doAdd := false;
  case SkanerMode of
    skmUNI:
      doAdd := true;
    skmGEO:
      doAdd := (mSyncTimeFrame >= 0) or (D.SkRec.RadioDt.Ge.getGeoCmd = cmrTIME_SYNCH) or (dt > 5000);
  end;

  if doAdd then
  begin
    inherited Add(D);
    D.idx := Count;
    Cmd := D.SkRec.RadioDt.Ge.getGeoCmd;
    tm := D.SkRec.GetTime;
    D.GeoInfo.RelTime := tm - mSyncTime;
    headNr := D.SkRec.RadioDt.Ge.getHeadNr;
    if headNr < 4 then
      devNr := headNr
    else if headNr = DEV_MOST then
      devNr := 4
    else
      devNr := -1;
    if devNr >= 0 then
      FiltrRssi[devNr].Add(D.SkRec.SkData.RSSI);

    case Cmd of
      cmrGET_DT:
        begin
          if headNr >= 0 then
          begin
            D.GeoInfo.DataRelTime := tm - mDtFrameTime[headNr];
            mDtFrameTime[headNr] := tm;
          end;
        end;

      cmrTIME_SYNCH_REP:
        begin
          D.GeoInfo.DataRelTime := tm - mDtSynchTime;
          mDtSynchTime := tm;

        end;
      cmrPING:
        begin
          if D.SkRec.SkData.sender = 0 then
          begin
            D.GeoInfo.DataRelTime := tm - mLastMostPing;
            mLastMostPing := tm;
          end
          else
          begin
            D.GeoInfo.DataRelTime := tm - mLastMostPing;
          end;
        end;

      cmrTIME_SYNCH:
        begin
          mSyncTime := tm;
          mDtSynchTime := tm;
          mSyncTimeFrame := Count;
        end;
    end;
    D.GeoInfo.SyncFrame := mSyncTimeFrame;
    Result := true;
  end;

end;

procedure TSkanerDtList.SaveToSL(SL: TStringList);
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    SL.Add(Items[i].SkRec.getAsSaveStr);

end;

procedure TSkanerDtList.LoadFromSL(SL: TStringList);
var
  i: integer;
  dt: TSkanerObj;
  RDt: TSkanerRec;
begin
  Clear;
  for i := 0 to SL.Count - 1 do
  begin
    if RDt.loadFromSaveStr(SL.Strings[i]) then
    begin
      dt := TSkanerObj.Create;
      dt.SkRec := RDt;
      if not AddSKL(dt) then
        dt.free;
    end;
  end;
end;

procedure TSkanerDtList.LoadFromFile(FName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FName);
    LoadFromSL(SL);
  finally
    SL.free;
  end;
end;

procedure TSkanerDtList.SaveToFile(FName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SaveToSL(SL);
    SL.SaveToFile(FName);
  finally
    SL.free;
  end;
end;

// ----------------------------------------------------------------
constructor TSkanerCom.Create(Owner: TSkanerDev);
begin
  inherited Create(smTEXT);
  mOwner := Owner;
end;

procedure TSkanerCom.doNewLine;
var
  s: string;
begin
  while true do
  begin
    if not(GetReciveLine(s)) then
      break;
    mOwner.dorecLine(s);
  end;

end;

// -----------------------------------------------------------------
constructor TSkanerDev.Create;
begin
  inherited;
  Com := TSkanerCom.Create(self);
  SkanerDtList := TSkanerDtList.Create;

  OnDataNotify := nil;
end;

destructor TSkanerDev.Destroy;
begin
  Com.free;
  SkanerDtList.free;
  inherited;
end;

function TSkanerDev.ComNr: integer;
begin
  Result := Com.ComNr;
end;

function TSkanerDev.GetErrStr(st: TStatus): string;
begin
  Result := Com.GetErrStr(st);
end;

function TSkanerDev.GetComThreadStr: string;
begin
  Result := Com.GetThreadStr;
end;

function TSkanerDev.Connected: boolean;
begin
  Connected := Com.Connected;
end;

procedure TSkanerDev.CloseDev;
begin
  Com.CloseDev;
end;

function TSkanerDev.OpenDev(ComNr: integer): TStatus;
begin
  Result := Com.OpenDev(ComNr);
  mFirstData := true;

end;

// budowa ramki:
// STX (dane jako HEX) (suma_HEX_4bytes) ETX
function TSkanerDev.WriteMessage(msg: TBytes): TStatus;
var
  n, i: integer;
  buf: TAnsiChars;
  s1: AnsiString;
  suma: word;
begin
  n := length(msg);
  setlength(buf, 1 + 2 * n + 4 + 1); // STX data suma ETX
  buf[0] := ansiChar(STX);
  suma := 0;
  for i := 0 to n - 1 do
  begin
    s1 := AnsiString(IntToHex(msg[i], 2));
    buf[1 + 2 * i + 0] := s1[1];
    buf[1 + 2 * i + 1] := s1[2];
    suma := suma + ord(s1[1]);
    suma := suma + ord(s1[2]);
  end;
  s1 := AnsiString(IntToHex(suma, 4));
  buf[1 + 2 * n + 0] := s1[1];
  buf[1 + 2 * n + 1] := s1[2];
  buf[1 + 2 * n + 2] := s1[3];
  buf[1 + 2 * n + 3] := s1[4];
  buf[1 + 2 * n + 4] := ansiChar(ETX);
  Result := Com.WriteMessage(buf)
end;

function TSkanerDev.WriteCfgMessage(msg: TBytes): TStatus;
var
  msg2: TBytes;
  n: integer;
begin
  n := length(msg);
  setlength(msg2, n + 1);
  Move(msg[0], msg2[1], n);
  msg2[0] := ord(nuRADIO_CFG);
  Result := WriteMessage(msg2);
end;

function TSkanerDev.WriteCfgMessage(SzSkanerCfg: TRfm69SkanerCfg): TStatus;
var
  buf: TBytes;
begin
  setlength(buf, sizeof(SzSkanerCfg));
  Move(SzSkanerCfg, buf[0], sizeof(SzSkanerCfg));
  Result := WriteCfgMessage(buf);
end;

function TSkanerDev.WriteDataMessage(slotNr: byte; msg: TBytes): TStatus;
var
  msg2: TBytes;
  n: integer;
begin
  n := length(msg);
  setlength(msg2, n + 2);
  Move(msg[0], msg2[2], n);
  msg2[0] := ord(nuRADIO_DATA);
  msg2[1] := slotNr;
  Result := WriteMessage(msg2);
end;

function TSkanerDev.WriteDataMessage(slotNr: byte; var w; size: integer): TStatus;
var
  buf: TBytes;
begin
  setlength(buf, size);
  Move(w, buf[0], size);
  Result := WriteDataMessage(slotNr, buf);
end;

function TSkanerDev.WriteLedMessage: TStatus;
var
  msg2: TBytes;
begin
  setlength(msg2, 2);
  msg2[0] := ord(nuRED_PULSE);
  Result := WriteMessage(msg2);
end;

procedure TSkanerDev.dorecLine(s: string);
var
  D: TSkanerRec;
  ob: TSkanerObj;
begin
  if D.LoadfromSkString(s) then
  begin
    if mFirstData then
    begin
      mFirstTick := D.SkData.tick;
      mFirstData := false;
    end;
    D.SkData.tick := D.SkData.tick - mFirstTick;
    ob := TSkanerObj.Create;
    ob.SkRec := D;

    if ob.SkRec.SkData.sender <> DEV_MOST then
    begin
      if SkanerDtList.AddSKL(ob) then
      begin
        if Assigned(OnDataNotify) then
          OnDataNotify(self, ob);
      end
      else
        ob.free;
    end
    else
    begin
      if Assigned(OnAckSendNotify) then
        OnAckSendNotify(self, TMesgType(ob.SkRec.RadioDt.Ack.ackFun));

      ob.free;
    end;
  end;
end;

end.
