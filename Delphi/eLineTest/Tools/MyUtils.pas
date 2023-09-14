unit MyUtils;

interface

uses
  Classes, Windows, WinSock, Messages, Types, SysUtils, Contnrs,
  Registry;

type
  TMicroSekTime = class(TObject)
  private
    FCaption: string;
    FStartTm: Int64;
    FStopTm: Int64;
    FResolution: Int64;
  public
    constructor Create(Caption: string);
    procedure Start;
    procedure Stop;
    procedure DebugPrintTm(title: string);

    function GetTm: real; // pobranie czasu w mikrosekundach
    function getDeltaAsUSek: integer;
  end;

  TBytesTool = class(TObject)
  public
    class function LoadfromHex(inp: string): TBytes;
    class function ToStr(const buf: TBytes): string;
    class function ToDotStr(const buf: TBytes): string;

    class function FromString(str: String): TBytes;
    class function FromStringZ(str: String): TBytes;
    class function rdInt(const buf: TBytes; ofs: integer): integer;
    class function rdWord(const buf: TBytes; ofs: integer): word;
    class function rdDWord(const buf: TBytes; ofs: integer): cardinal;
    class function rdFloat(const buf: TBytes; ofs: integer): single;

    class procedure setWord(const buf: TBytes; ofs: integer; w: word);
    class procedure setDWord(const buf: TBytes; ofs: integer; w: cardinal);
    class procedure setFloat(const buf: TBytes; ofs: integer; w: single);

    class function CopTab(const buf: TBytes): TBytes;
    class function CopyFrom(const buf: TBytes; ofs, size: integer): TBytes;
    class function LoadFromDotString(vek: string): TBytes;
    class function Compare(buf1, buf2: TBytes): boolean;
    class function add(buf1, buf2: TBytes): TBytes;
  end;

  TDataSpeedMeas = class(TObject)
  private const
    BUF_SIZE = 1000;
    TIME_MEAS = 5000;
    MEAS_CNT = 50;

  private type
    TDwords = array of cardinal;
  private
    mBuffer: TDwords;
    mPtr: integer;
    mNextCirc: boolean;
  public
    constructor Create;
    procedure Reset;
    procedure AddItem;
    function getSpeed(var speed: double): boolean;
  end;

  TGlobRegistry = class(TObject)
    class function ReadWspol(WspolName: string; Default: double): double;
    class procedure WriteWspol(KeyName: string; val: double);
  end;

function StrToFloatZero(txt: string): double;
function FloatToStrZero(w: double): string;
function FormatfloatZero(frm: string; w: double): string;

var
  DotFormatSettings: TFormatSettings;
  CommaFormatSettings: TFormatSettings;

implementation

uses
  eLineTestDef;

// ---- TMicroSekTime ----------------------------------------------------------

function StrToFloatZero(txt: string): double;
begin
  if txt = '' then
    Result := 0
  else
    Result := StrToFloat(txt);
end;

function FloatToStrZero(w: double): string;
begin
  if w = 0 then
    Result := ''
  else
    Result := FloatToStr(w);
end;

function FormatfloatZero(frm: string; w: double): string;
begin
  if w = 0 then
    Result := ''
  else
    Result := FormatFloat(frm, w);
end;

constructor TMicroSekTime.Create(Caption: string);
begin
  inherited Create;
  FCaption := Caption;
  QueryPerformanceFrequency(FResolution);
end;

procedure TMicroSekTime.Start;
begin
  QueryPerformanceCounter(FStartTm);
end;

procedure TMicroSekTime.Stop;
begin
  QueryPerformanceCounter(FStopTm);
end;

// pobranie czasu w milisekundach
function TMicroSekTime.GetTm: real;
var
  aTime: Int64;
begin
  QueryPerformanceCounter(aTime);
  Result := 1000.0 * (aTime - FStartTm) / FResolution;
end;

function TMicroSekTime.getDeltaAsUSek: integer;
begin
  Result := trunc(1000000.0 * (FStopTm - FStartTm) / FResolution);
end;

procedure TMicroSekTime.DebugPrintTm(title: string);
begin
  OutputDebugString(pchar(Format(':%s:%s:%f:', [FCaption, title, GetTm])));
end;

class function TBytesTool.LoadfromHex(inp: string): TBytes;
var
  buf: TBytes;
  i, n: integer;
begin
  setlength(buf, 0);
  n := length(inp);
  if (n mod 2) = 0 then
  begin
    n := n div 2;
    setlength(buf, n);
    for i := 0 to n - 1 do
    begin
      buf[i] := StrToint('$' + copy(inp, 1 + 2 * i, 2));
    end;
  end;
  Result := buf;
end;

class function TBytesTool.ToStr(const buf: TBytes): string;
var
  s1: AnsiString;
  n: integer;
begin
  n := length(buf);
  setlength(s1, n);
  move(buf[0], s1[1], n);
  Result := String(s1);
  n := StrLen(pchar(Result));
  setlength(Result, n);
end;

class function TBytesTool.ToDotStr(const buf: TBytes): string;
var
  n, i: integer;
begin
  Result := '';
  n := length(buf);
  for i := 0 to n - 1 do
  begin
    if Result <> '' then
      Result := Result + '.';
    Result := Result + IntToStr(buf[i]);
  end;
end;

class function TBytesTool.FromString(str: String): TBytes;
var
  s1: AnsiString;
begin
  s1 := AnsiString(str);
  setlength(Result, length(s1));
  move(s1[1], Result[0], length(Result));
end;

class function TBytesTool.FromStringZ(str: String): TBytes;
var
  s1: AnsiString;
begin
  s1 := AnsiString(str);
  setlength(Result, length(s1) + 1);
  move(s1[1], Result[0], length(Result));
  Result[length(s1)] := 0;
end;

class function TBytesTool.rdInt(const buf: TBytes; ofs: integer): integer;
begin
  Result := buf[ofs];
  Result := Result or (buf[ofs + 1] shl 8);
  Result := Result or (buf[ofs + 2] shl 16);
  Result := Result or (buf[ofs + 3] shl 24);
end;

class function TBytesTool.rdWord(const buf: TBytes; ofs: integer): word;
begin
  Result := buf[ofs];
  Result := Result or (buf[ofs + 1] shl 8);
end;

class function TBytesTool.rdDWord(const buf: TBytes; ofs: integer): cardinal;
begin
  Result := buf[ofs];
  Result := Result or (buf[ofs + 1] shl 8);
  Result := Result or (buf[ofs + 2] shl 16);
  Result := Result or (buf[ofs + 3] shl 24);
end;

class procedure TBytesTool.setWord(const buf: TBytes; ofs: integer; w: word);
begin
  if ofs + 2 <= length(buf) then
  begin
    buf[ofs + 0] := w and $FF;
    buf[ofs + 1] := (w shr 8) and $FF;
  end;
end;

class procedure TBytesTool.setDWord(const buf: TBytes; ofs: integer; w: cardinal);
begin
  if ofs + 4 <= length(buf) then
  begin
    buf[ofs + 0] := w and $FF;
    buf[ofs + 1] := (w shr 8) and $FF;
    buf[ofs + 2] := (w shr 16) and $FF;
    buf[ofs + 3] := (w shr 24) and $FF;
  end;
end;

class procedure TBytesTool.setFloat(const buf: TBytes; ofs: integer; w: single);
var
  ww: cardinal;
begin
  ww := PCardinal(@w)^;
  setDWord(buf, ofs, ww);
end;

class function TBytesTool.rdFloat(const buf: TBytes; ofs: integer): single;
var
  w: cardinal;
begin
  w := rdDWord(buf, ofs);
  Result := PSingle(@w)^;
end;

class function TBytesTool.CopTab(const buf: TBytes): TBytes;
begin
  Result := nil;
  if buf <> nil then
  begin
    setlength(Result, length(buf));
    move(buf[0], Result[0], length(Result));
  end;
end;

class function TBytesTool.CopyFrom(const buf: TBytes; ofs, size: integer): TBytes;
begin
  Result := nil;
  if ofs + size <= length(buf) then
  begin
    setlength(Result, size);
    move(buf[ofs], Result[0], size);
  end;
end;

class function TBytesTool.LoadFromDotString(vek: string): TBytes;
var
  SL: TStringList;
  buf: TBytes;
  i: integer;
begin
  Result := nil;
  SL := TStringList.Create;
  try
    SL.Delimiter := '.';
    SL.DelimitedText := vek;
    try
      setlength(buf, SL.Count);
      for i := 0 to SL.Count - 1 do
      begin
        buf[i] := StrToint(SL.Strings[i]);
      end;
      Result := buf;
    finally

    end;
  finally
    SL.Free;
  end;

end;

class function TBytesTool.Compare(buf1, buf2: TBytes): boolean;
var
  i, n: integer;
begin
  Result := false;
  if length(buf1) = length(buf2) then
  begin
    Result := true;
    n := length(buf1);
    for i := 0 to n - 1 do
    begin
      if buf1[i] <> buf2[i] then
      begin
        Result := false;
        break;
      end;
    end;
  end;
end;

class function TBytesTool.add(buf1, buf2: TBytes): TBytes;
var
  n1, n2: integer;
begin
  if buf1 = nil then
    Result := buf2
  else if buf2 = nil then
    Result := buf1
  else
  begin
    n1 := length(buf1);
    n2 := length(buf2);
    setlength(Result, n1 + n2);
    move(buf1[0], Result[0], n1);
    move(buf2[0], Result[n1], n2);
  end;
end;

// --- TDataSpeedMeas ---------------------------------------------------------
constructor TDataSpeedMeas.Create;
begin
  setlength(mBuffer, BUF_SIZE);
  mPtr := 0;
  mNextCirc := false;

end;

procedure TDataSpeedMeas.Reset;
begin
  mPtr := 0;
  mNextCirc := false;
end;

procedure TDataSpeedMeas.AddItem;
begin
  mBuffer[mPtr] := GetTickCount;
  inc(mPtr);
  if mPtr = BUF_SIZE then
  begin
    mPtr := 0;
    mNextCirc := true;
  end;

end;

function TDataSpeedMeas.getSpeed(var speed: double): boolean;
  function decPtr(var n: integer): boolean;
  begin
    if (n = 0) and not mNextCirc then
      Result := false
    else
    begin
      if n = 0 then
        n := BUF_SIZE;
      dec(n);
      Result := true;
    end;
  end;

var
  ptr: integer;
  lastTick: cardinal;
  k: integer;
  q: boolean;
  dt : cardinal;
begin

  if (mNextCirc = false) and (mPtr < 10) then
    Result := false
  else
  begin
    ptr := mPtr;
    decPtr(ptr);
    lastTick := mBuffer[ptr];
    k := 0;
    while true do
    begin
      if not decPtr(ptr) then
      begin
        Result := false;
        break;
      end;
      inc(k);
      dt := lastTick - mBuffer[ptr];
      q := (dt > TIME_MEAS);
      q := q or ((dt > 10) and (k > MEAS_CNT));

      if q then
      begin
        speed := k / (dt / 1000.0);
        Result := true;
        break;
      end;
    end;
  end;

end;

// ------------------------------------------------------------

class function TGlobRegistry.ReadWspol(WspolName: string; Default: double): double;
var
  Registry: TRegistry;

  procedure WriteToReg;
  begin
    Registry.WriteString(WspolName, FloatToStr(Default, DotFormatSettings));
  end;

var
  s: string;
begin
  Result := Default;
  Registry := TRegistry.Create;
  try
    if Registry.OpenKey(REG_KEY, true) then
    begin
      if Registry.ValueExists(WspolName) then
      begin
        s := Registry.ReadString(WspolName);
        if not(TryStrToFloat(s, Result, CommaFormatSettings)) then
        begin
          if not(TryStrToFloat(s, Result, DotFormatSettings)) then
          begin
            WriteToReg;
          end;
        end;
      end
      else
      begin
        WriteToReg;
      end;
    end;
  finally
    Registry.Free;
  end;
end;

class procedure TGlobRegistry.WriteWspol(KeyName: string; val: double);
begin

end;

initialization

{$WARN SYMBOL_PLATFORM OFF}
  DotFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
CommaFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
{$WARN SYMBOL_PLATFORM ON}
DotFormatSettings.DecimalSeparator := '.';
CommaFormatSettings.DecimalSeparator := ',';

end.
