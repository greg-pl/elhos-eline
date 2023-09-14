unit CrcUnit;

interface

uses
  Classes;

type
  STR16 = array [0 .. 15] of AnsiChar;
  STR8 = array [0 .. 7] of AnsiChar;

  PSoftHeader = ^TSoftHeader;

  TSoftHeader = packed record
    size: cardinal;
    CRC: word;
    Free: array [0 .. 9] of byte;
    DataTxt: STR16;
    TimeTxt: STR16;
    VerTxt: STR8;
    RevTxt: STR8;
  end;

  TCrc = class(TObject)
  private
    class function Procedd(CRC: word; Data: byte): word;
    class function FindBlokOffset(const p; size: integer; var BlkOffset: integer): boolean;
  public
    class function Make(const p; count: integer): word;
    class procedure SetIt(const p; count: integer);
    class function Check(const p; count: integer): boolean;
    class function CheckFirmwareMode(const p; count: integer): boolean;
    class function CheckInFirmwareFile(FName: string): boolean;
  end;

implementation

// ---- TCRC ----------------------------------------------------------

const
  CrcTab: array [0 .. 255] of word = ($0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241, $C601, $06C0, $0780,
    $C741, $0500, $C5C1, $C481, $0440, $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40, $0A00, $CAC1, $CB81,
    $0B40, $C901, $09C0, $0880, $C841, $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40, $1E00, $DEC1, $DF81,
    $1F40, $DD01, $1DC0, $1C80, $DC41, $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641, $D201, $12C0, $1380,
    $D341, $1100, $D1C1, $D081, $1040, $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240, $3600, $F6C1, $F781,
    $3740, $F501, $35C0, $3480, $F441, $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41, $FA01, $3AC0, $3B80,
    $FB41, $3900, $F9C1, $F881, $3840, $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41, $EE01, $2EC0, $2F80,
    $EF41, $2D00, $EDC1, $EC81, $2C40, $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640, $2200, $E2C1, $E381,
    $2340, $E101, $21C0, $2080, $E041, $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240, $6600, $A6C1, $A781,
    $6740, $A501, $65C0, $6480, $A441, $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41, $AA01, $6AC0, $6B80,
    $AB41, $6900, $A9C1, $A881, $6840, $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41, $BE01, $7EC0, $7F80,
    $BF41, $7D00, $BDC1, $BC81, $7C40, $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640, $7200, $B2C1, $B381,
    $7340, $B101, $71C0, $7080, $B041, $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241, $9601, $56C0, $5780,
    $9741, $5500, $95C1, $9481, $5440, $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40, $5A00, $9AC1, $9B81,
    $5B40, $9901, $59C0, $5880, $9841, $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40, $4E00, $8EC1, $8F81,
    $4F40, $8D01, $4DC0, $4C80, $8C41, $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641, $8201, $42C0, $4380,
    $8341, $4100, $81C1, $8081, $4040);

class function TCrc.Procedd(CRC: word; Data: byte): word;
begin
  Result := CrcTab[(CRC xor Data) and $FF] xor (CRC shr 8);
end;

{
  function  TDevItem.ProceddCRC(CRC : word; Data : byte):word;
  const
  Gen_poly:word= $A001;
  var
  i    : byte;
  begin
  Crc:=Crc xor Data;
  for i:=1 to 8 do
  begin
  if Crc mod 2=1 then
  Crc:=((Crc div 2) xor Gen_Poly)
  else
  crc:=crc div 2;
  end;
  Result:= Crc;
  end;
}

class function TCrc.Make(const p; count: integer): word;
const
  Gen_poly: word = $A001;
var
  a: byte;
  CRC: word;
  i: integer;
  pb: pByte;
begin
  CRC := $FFFF;
  pb := pByte(@p);
  for i := 0 to count - 1 do
  begin
    a := pb^;
    inc(pb);
    CRC := Procedd(CRC, a);
  end;
  Result := CRC;
end;

class procedure TCrc.SetIt(const p; count: integer);
var
  cr: word;
  pb: pByte;
begin
  cr := Make(p, count - 2);
  pb := pByte(@p);
  inc(pb, count - 2);
  pb^ := lo(cr);
  inc(pb);
  pb^ := hi(cr);
end;

class function TCrc.Check(const p; count: integer): boolean;
begin
  Result := (Make(p, count) = 0);
end;

class function TCrc.FindBlokOffset(const p; size: integer; var BlkOffset: integer): boolean;
const
  MAX_FIND_AREA = $400;
  Pattern: string = 'Date : ##.##.## ' + 'Time : ##:##:## ' + 'Ver.### Rev.### ';

  function CheckPattern(ofs: integer): boolean;
  var
    i, n: integer;
    ch: char;
    ptr: pByte;
  begin
    n := length(Pattern);
    Result := true;
    ptr := pByte(@p);
    inc(ptr, ofs);
    for i := 0 to n - 1 do
    begin
      ch := Pattern[i + 1];
      if (ch <> '#') and (ord(ch) <> ptr^) then
      begin
        Result := false;
        break;
      end;
      inc(ptr);
    end;
  end;

var
  ofs: integer;
  mmL: integer;
begin
  Result := false;
  BlkOffset := 0;
  ofs := $10;
  mmL := size;
  if mmL > MAX_FIND_AREA then
    mmL := MAX_FIND_AREA;
  while ofs + length(Pattern) <= mmL do
  begin
    if CheckPattern(ofs) then
    begin
      BlkOffset := ofs;
      Result := true;
      break;
    end;
    inc(ofs, $10);
  end;
end;

class function TCrc.CheckFirmwareMode(const p; count: integer): boolean;
var
  Buf: array of byte;
  Header: PSoftHeader;
  MemCrc: word;
  MyCrc: word;
  offset: integer;
begin
  Result := false;
  if FindBlokOffset(p, count, offset) then
  begin
    setlength(Buf, count);
    move(p, Buf[0], count);
    Header := PSoftHeader(@Buf[offset]);
    MemCrc := Header.CRC;
    Header.CRC := 0;
    MyCrc := Make(Buf[0], count);
    if (count = integer(Header.size)) and (MemCrc = MyCrc) then
      Result := true;
  end;
end;


class function TCrc.CheckInFirmwareFile(FName: string): boolean;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(FName);
    Result := TCrc.CheckFirmwareMode(Stream.Memory^,Stream.size);
  finally
    Stream.Free;
  end;
end;


end.
