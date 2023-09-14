unit CmmObjDefinition;

interface

uses
  Classes, Windows, WinSock, Messages, Types, SysUtils, Contnrs,
  eLineDef;

type


  { -----------------------------------------------------------------------------
    Budowa elementu strumienia danych
    +------+------+------+-------+---- .......  ----+
    |SizeL |SizeH |DevNr |CmmCode|Dane              |
    +------+------+------+-------+---- .......  ----+
    Size : word - rozmiar ca³ej paczki
    DstNr : TTrkDev - kod numeru servisu w ramach urzadzenia
    CmmCode :TTrackObjCode - kod danych
    Dane : bytes - dane o dowolnej d³ugoœci


    ----------------------------------------------------------------------------- }

  TOutTrackStream = class(TObject)
  private const
    BEGIN_SIZE = 2048;
    GROW_SIZE = 256;
  private
    mBuf: TBytes;
    mPtr: integer;
  public
    constructor Create;
    procedure clear;
    procedure addItem(dst: TTrkDev; code: byte; const dt; dt_size: integer);
    procedure addBuf(dst: TTrkDev; code: byte; dt: TBytes);
    procedure addBool(dst: TTrkDev; code: byte; v: boolean);
    procedure addFloat(dst: TTrkDev; code: byte; v: single);
    procedure addByte(dst: TTrkDev; code: byte; v: byte);
    procedure addWord(dst: TTrkDev; code: byte; v: word);
    procedure addInt(dst: TTrkDev; code: byte; v: integer);
    function getBuf: TBytes;
    function getDtLen: integer;
  end;

  TKItemHead = packed record
    objSize: word;
    dstDev: byte;
    cmmCode: byte;
  end;

  PKItem = ^TKItem;

  TKItem = packed record
    objSize: word;
    dstDev: byte;
    cmmCode: byte;
    dt: array [0 .. 2] of byte;
  end;

  TKRec = record
    srcDev: TTrkDev;
    obCode: byte;
    data: pointer;
    data_sz: integer;
    function asBool: boolean;
    function asByte: byte;
    function asWord: byte;
    function asDWord: byte;
    function asInt: byte;
    function asFloat: single;
    function asBuf: TBytes;
  end;

  TKObj = class(TObject)
  public
    srcDev: TTrkDev;
    obCode: integer;
    data: TBytes;
    destructor Destroy; override;
  end;

  TInTrackStream = class(TObject)
  private
    mBuf: TBytes;
    mPtr: integer;
  public
    procedure setBuffer(buf: TBytes);
    function PopObj(

      var obj: TKRec): boolean; overload;
    function PopObj(var obj: TKObj): boolean; overload;
  end;

implementation

// -----------------------------------------------------------------------------
// TOutTrackStream
// -----------------------------------------------------------------------------

constructor TOutTrackStream.Create;
begin
  setlength(mBuf, BEGIN_SIZE);
  mPtr := 0;
end;

procedure TOutTrackStream.clear;
begin
  setlength(mBuf, BEGIN_SIZE);
  mPtr := 0;
end;

procedure TOutTrackStream.addItem(dst: TTrkDev; code: byte; const dt; dt_size: integer);
var
  sz: integer;
  new_ptr: integer;
  new_sz: integer;
  item: PKItem;
begin
  sz := sizeof(TKItemHead) + dt_size;
  new_ptr := mPtr + sz;
  if new_ptr > length(mBuf) then
  begin
    new_sz := length(mBuf) + GROW_SIZE;
    if new_sz < new_ptr then
      new_sz := new_ptr + GROW_SIZE;
    setlength(mBuf, new_sz);
  end;
  item := PKItem(@mBuf[mPtr]);
  item.objSize := sz;
  item.dstDev := byte(dst);
  item.cmmCode := code;
  if dt_size > 0 then
    move(dt, item.dt, dt_size);
  mPtr := new_ptr;
end;

procedure TOutTrackStream.addBuf(dst: TTrkDev; code: byte; dt: TBytes);
begin
  addItem(dst, code, dt[0], length(dt));
end;

procedure TOutTrackStream.addBool(dst: TTrkDev; code: byte; v: boolean);
begin
  addByte(dst, code, byte(v));
end;

procedure TOutTrackStream.addFloat(dst: TTrkDev; code: byte; v: single);
begin
  addItem(dst, code, v, sizeof(v));
end;

procedure TOutTrackStream.addByte(dst: TTrkDev; code: byte; v: byte);
begin
  addItem(dst, code, v, sizeof(v));
end;

procedure TOutTrackStream.addWord(dst: TTrkDev; code: byte; v: word);
begin
  addItem(dst, code, v, sizeof(v));
end;

procedure TOutTrackStream.addInt(dst: TTrkDev; code: byte; v: integer);
begin
  addItem(dst, code, v, sizeof(v));
end;

function TOutTrackStream.getBuf: TBytes;
begin
  setlength(Result, mPtr);
  move(mBuf[0], Result[0], mPtr);
end;

function TOutTrackStream.getDtLen: integer;
begin
  Result := mPtr;
end;

// -----------------------------------------------------------------------------
// TKObj
// -----------------------------------------------------------------------------
function TKRec.asByte: byte;
begin
  Result := pByte(data)^;
end;

function TKRec.asBool: boolean;
begin
  Result := (asByte <> 0);
end;

function TKRec.asWord: byte;
begin
  Result := pWord(data)^;
end;

function TKRec.asDWord: byte;
begin
  Result := pcardinal(data)^;
end;

function TKRec.asInt: byte;
begin
  Result := pInteger(data)^;
end;

function TKRec.asFloat: single;
begin
  Result := pSingle(data)^;
end;

function TKRec.asBuf: TBytes;
begin
  setlength(Result, data_sz);
  move(data^, Result[0], data_sz);
end;

// -----------------------------------------------------------------------------
// TInTrackStream
// -----------------------------------------------------------------------------

destructor TKObj.Destroy;
begin
  inherited;
  setlength(data, 0);
end;

procedure TInTrackStream.setBuffer(buf: TBytes);
begin
  mBuf := buf;
  mPtr := 0;
end;

function TInTrackStream.PopObj(

  var obj: TKRec): boolean;
var
  kItem: PKItem;
begin
  Result := false;
  if mPtr + 4 <= length(mBuf) then
  begin
    kItem := PKItem(@mBuf[mPtr]);
    if kItem.objSize + mPtr <= length(mBuf) then
    begin
      obj.srcDev := TTrkDev(kItem.dstDev);
      obj.obCode := kItem.cmmCode;
      obj.data_sz := kItem.objSize - sizeof(TKItemHead);
      obj.data := @kItem.dt;
      inc(mPtr, kItem.objSize);
      Result := true;
    end;
  end;
end;

function TInTrackStream.PopObj(

  var obj: TKObj): boolean;
var
  kRec: TKRec;
begin
  Result := PopObj(kRec);
  if Result then
  begin
    obj := TKObj.Create;
    obj.srcDev := kRec.srcDev;
    obj.obCode := kRec.obCode;
    setlength(obj.data, kRec.data_sz);
    move(kRec.data^, obj.data[0], kRec.data_sz);
  end;
end;

end.
