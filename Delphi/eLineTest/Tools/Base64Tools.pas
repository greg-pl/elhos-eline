unit Base64Tools;

interface
uses
  SysUtils;

function DecodeBase64(const Input: AnsiString): TBytes;
function EncodeBase64(const Inp: TBytes): AnsiString;

implementation

const
  Base64: array [0 .. 63] of AnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function DecodeBase64(const Input: AnsiString): TBytes;
var
  Error: boolean;

  function knvChar(ch: AnsiChar): byte;
  begin
    if (ch >= 'A') and (ch <= 'Z') then
      Result := ord(ch) - ord('A')
    else if (ch >= 'a') and (ch <= 'z') then
      Result := ord(ch) - ord('a') + 26
    else if (ch >= '0') and (ch <= '9') then
      Result := ord(ch) - ord('0') + 52
    else if ch = '+' then
      Result := 62
    else if ch = '/' then
      Result := 63
    else
    begin
      Result := 0;
      Error := true;
    end;
  end;

  procedure knv3Bt(inpOfs: integer; outOfs: integer);
  var
    b1, b2, b3, b4: byte;
  begin
    b1 := knvChar(Input[inpOfs + 0]);
    b2 := knvChar(Input[inpOfs + 1]);
    b3 := knvChar(Input[inpOfs + 2]);
    b4 := knvChar(Input[inpOfs + 3]);
    Result[outOfs + 0] := (b1 shl 2) or ((b2 shr 4) and $03);
    Result[outOfs + 1] := ((b2 shl 4) and $F0) or ((b3 shr 2) and $0F);
    Result[outOfs + 2] := ((b3 shl 6) and $C0) or b4;
  end;

  procedure knv2Bt(inpOfs: integer; outOfs: integer);
  var
    b1, b2, b3: byte;
  begin
    b1 := knvChar(Input[inpOfs + 0]);
    b2 := knvChar(Input[inpOfs + 1]);
    b3 := knvChar(Input[inpOfs + 2]);
    Result[outOfs + 0] := (b1 shl 2) or ((b2 shr 4) and $03);
    Result[outOfs + 1] := ((b2 shl 4) and $F0) or ((b3 shr 2) and $0F)
  end;

  procedure knv1Bt(inpOfs: integer; outOfs: integer);
  var
    b1, b2: byte;
  begin
    b1 := knvChar(Input[inpOfs + 0]);
    b2 := knvChar(Input[inpOfs + 1]);
    Result[outOfs + 0] := (b1 shl 2) or ((b2 shr 4) and $03);
  end;

var
  n, i: integer;
  last: integer;
begin
  setlength(Result, 0);
  Error := false;
  n := length(Input);
  if ((n mod 4) = 0) and (n > 0) then
  begin
    last := 0;
    if Input[n] = '=' then
    begin
      last := 2;
      if Input[n - 1] = '=' then
      begin
        last := 1;
      end;
    end;
    n := n div 4;
    if last <> 0 then
      dec(n);

    setlength(Result, n * 3 + last);
    for i := 0 to n - 1 do
    begin
      knv3Bt(1 + 4 * i, 3 * i)
    end;

    case last of
      2:
        knv2Bt(1 + 4 * n, 3 * n);
      1:
        knv1Bt(1 + 4 * n, 3 * n);
    end;
  end;
  if Error then
    setlength(Result, 0);
end;

function EncodeBase64(const Inp: TBytes): AnsiString;

  procedure Enc3B(ofs: integer; const Byte1, Byte2, Byte3: byte);
  begin
    Result[ofs + 0] := Base64[Byte1 shr 2];
    Result[ofs + 1] := Base64[((Byte1 shl 4) or (Byte2 shr 4)) and $3F];
    Result[ofs + 2] := Base64[((Byte2 shl 2) or (Byte3 shr 6)) and $3F];
    Result[ofs + 3] := Base64[Byte3 and $3F];
  end;

  procedure Enc2B(ofs: integer; const Byte1, Byte2: byte);
  begin
    Result[ofs + 0] := Base64[Byte1 shr 2];
    Result[ofs + 1] := Base64[((Byte1 shl 4) or (Byte2 shr 4)) and $3F];
    Result[ofs + 2] := Base64[(Byte2 shl 2) and $3F];
    Result[ofs + 3] := '=';
  end;

  procedure Enc1B(ofs: integer; const Byte1: byte);
  begin
    Result[ofs + 0] := Base64[Byte1 shr 2];
    Result[ofs + 1] := Base64[(Byte1 shl 4) and $3F];
    Result[ofs + 2] := '=';
    Result[ofs + 3] := '=';
  end;

var
  i, n: integer;
  j, m: integer;
begin
  n := length(Inp);
  m := 4 * ((n + 2) div 3);
  setlength(Result, m);

  i := 0;
  j := 1;
  while i < n do
  begin
    case n - i of
      3 .. MaxInt:
        Enc3B(j, Inp[i], Inp[i + 1], Inp[i + 2]);
      2:
        Enc2B(j, Inp[i], Inp[i + 1]);
      1:
        Enc1B(j, Inp[i]);
    end;
    Inc(i, 3);
    Inc(j, 4);
  end;
end;



end.
