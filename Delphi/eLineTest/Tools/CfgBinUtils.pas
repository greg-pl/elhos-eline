unit CfgBinUtils;

interface

uses
  SysUtils, MyUtils, Classes, Contnrs, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.UITypes,
  NetToolsUnit;

type
  TMsgOut = procedure(txt: string) of object;

  TCfgTool = class(TObjectList)
  private

  public type
    TCfgKind = (ckBool, ckByte, ckWord, ckInt, ckFloat, ckString, ckIP);

    TCfgBinItem = class(Tobject)
    private
      mKind: TCfgKind;
      mAdr: TBytes;
      mOrgVal: TBytes;
      mVal: TBytes;
      mLoaded: boolean;
      mWCotrl: Tobject;
      mParamStr: String;
    public
      mUserIdx: integer;

      function getAsString: string;
      function getAsInt: integer;
      function getAsWord: word;
      function getAsDWord: cardinal;
      function getAsByte: byte;
      function getAsBool: boolean;
      function getAsFloat: single;

      procedure setAsString(v: string);
      procedure setAsInt(v: integer);
      procedure setAsDWord(v: cardinal);
      procedure setAsByte(v: byte);
      procedure setAsWord(v: word);
      procedure setAsBool(v: boolean);
      procedure setAsFloat(v: single);
    public
      procedure updateWControl;
      procedure loadFromControls;
      procedure clearWControls;
      procedure clearChangesSign;

      function isDiffrent(MsgOut: TMsgOut): boolean;
      function getgetDifferences: TBytes;
      procedure AckChanges;
      function getAdrAsStr: string;
      function getValAsStr: string;
      function setValAsStr(vstr: string): boolean;

    end;

    TCfgNotify = class(Tobject)

    public
      procedure OnClearChgSign(sender: TCfgBinItem); virtual; abstract;
      procedure OnSetChgSign(sender: TCfgBinItem); virtual; abstract;
      procedure OnClearControl(sender: TCfgBinItem); virtual; abstract;
      procedure OnLoadFromControl(sender: TCfgBinItem); virtual; abstract;
      procedure OnUpdateControl(sender: TCfgBinItem); virtual; abstract;

    end;

  private
    function FGetItem(index: integer): TCfgBinItem;

    function find(vek: TBytes): TCfgBinItem; overload;
    procedure loadFromControls;
  protected
    function getItemV(vek: TBytes): TCfgBinItem;
    function find(vek: string): TCfgBinItem; overload;

  public
    Constructor Create;
    procedure loadValBuf(MsgOut: TMsgOut; mem: TBytes);

    property Items[Index: integer]: TCfgBinItem read FGetItem;
    function AddItem(kind: TCfgKind; vek: TBytes; winCtrl: Tobject): TCfgBinItem; overload;
    function AddItem(kind: TCfgKind; vek: TBytes; winCtrl: Tobject; paramStr: string): TCfgBinItem; overload;
    function AddItem(kind: TCfgKind; vek: TBytes; winCtrl: Tobject; userIdx: integer): TCfgBinItem; overload;
    procedure clearWControls;
    procedure clearChangesSign;
    procedure AckChanges;
    function getDifferences: TBytes;
    function getDifferencesCount(MsgOut: TMsgOut): integer;
    procedure SaveToFile(Title, FName: string);
    procedure LoadFromFile(FName: string);
  end;

implementation

function TCfgTool.TCfgBinItem.getAsString: string;
begin
  Result := TBytesTool.ToStr(mVal);
end;

function TCfgTool.TCfgBinItem.getAsInt: integer;
begin
  if length(mVal) <> 4 then
    raise Exception.Create('TCfgBinTool, Incorect INT item data length');
  Result := TBytesTool.rdInt(mVal, 0);
end;

function TCfgTool.TCfgBinItem.getAsWord: word;
begin
  if length(mVal) <> 2 then
    raise Exception.Create('TCfgBinTool, Incorect WORD item data length');
  Result := TBytesTool.rdWord(mVal, 0);
end;

function TCfgTool.TCfgBinItem.getAsDWord: cardinal;
begin
  if length(mVal) <> 4 then
    raise Exception.Create('TCfgBinTool, Incorect DWORD item data length');
  Result := TBytesTool.rdDWord(mVal, 0);
end;

function TCfgTool.TCfgBinItem.getAsFloat: single;
begin
  if length(mVal) <> 4 then
    raise Exception.Create('TCfgBinTool, Incorect FLOAT item data length');
  Result := TBytesTool.rdFloat(mVal, 0);
end;

function TCfgTool.TCfgBinItem.getAsByte: byte;
begin
  if length(mVal) <> 1 then
    raise Exception.Create('TCfgBinTool, Incorect BYTE item data length');
  Result := mVal[0];
end;

function TCfgTool.TCfgBinItem.getAsBool: boolean;
begin
  Result := (getAsByte = 1);
end;

// -----------------------
procedure TCfgTool.TCfgBinItem.setAsString(v: string);
begin
  mVal := TBytesTool.FromStringZ(v);
end;

procedure TCfgTool.TCfgBinItem.setAsInt(v: integer);
begin
  setlength(mVal, 4);
  TBytesTool.setDWord(mVal, 0, cardinal(v));
end;

procedure TCfgTool.TCfgBinItem.setAsDWord(v: cardinal);
begin
  setlength(mVal, 4);
  TBytesTool.setDWord(mVal, 0, v);
end;

procedure TCfgTool.TCfgBinItem.setAsWord(v: word);
begin
  setlength(mVal, 2);
  TBytesTool.setWord(mVal, 0, v);
end;

procedure TCfgTool.TCfgBinItem.setAsByte(v: byte);
begin
  setlength(mVal, 1);
  mVal[0] := v;
end;

procedure TCfgTool.TCfgBinItem.setAsBool(v: boolean);
begin
  setAsByte(byte(v));
end;

procedure TCfgTool.TCfgBinItem.setAsFloat(v: single);
begin
  setlength(mVal, 4);
  TBytesTool.setFloat(mVal, 0, v);
end;

procedure TCfgTool.TCfgBinItem.clearWControls;
begin
  if mWCotrl is TCheckBox then
    (mWCotrl as TCheckBox).checked := false;
  if mWCotrl is TLabeledEdit then
    (mWCotrl as TLabeledEdit).Text := '';
  if mWCotrl is TRadioGroup then
    (mWCotrl as TRadioGroup).ItemIndex := -1;
  if mWCotrl is TComboBox then
    (mWCotrl as TComboBox).ItemIndex := -1;
  if mWCotrl is TCfgNotify then
    (mWCotrl as TCfgNotify).OnClearControl(self);

end;

//
procedure TCfgTool.TCfgBinItem.loadFromControls;
begin
  mVal := nil;
  if mWCotrl = nil then
  begin
    // nie ma kontrolki, to nie ma zmian
    mVal := TBytesTool.CopTab(mOrgVal);
  end
  else if mWCotrl is TCfgNotify then
  begin
    try
      (mWCotrl as TCfgNotify).OnLoadFromControl(self);
    except
      raise Exception.Create(Format('Load error: obj=%s Index=%u', [TBytesTool.ToDotStr(mAdr), mUserIdx]));
    end;
  end
  else
  begin

    case mKind of
      ckBool:
        begin
          if mWCotrl is TCheckBox then
            setAsBool((mWCotrl as TCheckBox).checked);
        end;
      ckByte:
        begin
          if mWCotrl is TLabeledEdit then
            setAsByte(StrToInt((mWCotrl as TLabeledEdit).Text));
          if mWCotrl is TRadioGroup then
            setAsByte((mWCotrl as TRadioGroup).ItemIndex);
          if mWCotrl is TComboBox then
            setAsByte((mWCotrl as TComboBox).ItemIndex);
        end;
      ckWord:
        begin
          if mWCotrl is TLabeledEdit then
            setAsWord(StrToInt((mWCotrl as TLabeledEdit).Text));
          if mWCotrl is TRadioGroup then
            setAsWord((mWCotrl as TRadioGroup).ItemIndex)
        end;

      ckString:
        begin
          if mWCotrl is TLabeledEdit then
            setAsString((mWCotrl as TLabeledEdit).Text);
        end;
      ckIP:
        begin
          try
            if mWCotrl is TLabeledEdit then
              setAsInt(StrToIp((mWCotrl as TLabeledEdit).Text));
          except
            raise Exception.Create('B³¹d konwersji do IP : ' + (mWCotrl as TLabeledEdit).EditLabel.Caption);
          end;
        end;
      ckInt:
        begin
          if mWCotrl is TLabeledEdit then
            setAsInt(StrToInt((mWCotrl as TLabeledEdit).Text));
          if mWCotrl is TRadioGroup then
            setAsInt((mWCotrl as TRadioGroup).ItemIndex);

        end;
      ckFloat:
        begin
          if mWCotrl is TLabeledEdit then
          begin
            try
              setAsFloat(StrToFloatZero((mWCotrl as TLabeledEdit).Text));
            except
              raise Exception.Create('B³¹d konwersji do liczby: ' + (mWCotrl as TLabeledEdit).EditLabel.Caption);
            end;
          end;
        end;

    end;
  end;
end;

// wstawia w kontrolki dane z mNewVal
procedure TCfgTool.TCfgBinItem.updateWControl;
begin
  if mWCotrl is TCfgNotify then
  begin
    (mWCotrl as TCfgNotify).OnUpdateControl(self);
  end
  else
  begin

    case mKind of
      ckBool:
        begin
          if mWCotrl is TCheckBox then
            (mWCotrl as TCheckBox).checked := getAsBool;
        end;
      ckByte:
        begin
          if mWCotrl is TLabeledEdit then
            (mWCotrl as TLabeledEdit).Text := IntToStr(getAsByte);
          if mWCotrl is TRadioGroup then
            (mWCotrl as TRadioGroup).ItemIndex := getAsByte;
          if mWCotrl is TComboBox then
            (mWCotrl as TComboBox).ItemIndex := getAsByte;

        end;
      ckWord:
        begin
          if mWCotrl is TLabeledEdit then
            (mWCotrl as TLabeledEdit).Text := IntToStr(getAsWord);
          if mWCotrl is TRadioGroup then
            (mWCotrl as TRadioGroup).ItemIndex := getAsWord;
        end;

      ckString:
        begin
          if mWCotrl is TLabeledEdit then
            (mWCotrl as TLabeledEdit).Text := getAsString;
        end;
      ckIP:
        begin
          if mWCotrl is TLabeledEdit then
            (mWCotrl as TLabeledEdit).Text := IpToStr(getAsDWord);
        end;
      ckInt:
        begin
          if mWCotrl is TLabeledEdit then
            (mWCotrl as TLabeledEdit).Text := IntToStr(getAsInt);
          if mWCotrl is TRadioGroup then
            (mWCotrl as TRadioGroup).ItemIndex := getAsInt;

        end;
      ckFloat:
        begin
          if mWCotrl is TLabeledEdit then
            (mWCotrl as TLabeledEdit).Text := Format(mParamStr, [getAsFloat]);
        end;

    end;
  end;
end;

procedure TCfgTool.TCfgBinItem.AckChanges;
begin
  mOrgVal := TBytesTool.CopTab(mVal);
  clearChangesSign;
end;

procedure TCfgTool.TCfgBinItem.clearChangesSign;
begin
  if Assigned(mWCotrl) then
  begin

    if mWCotrl is TCheckBox then
      (mWCotrl as TCheckBox).Font.Color := TColorRec.Black;
    if mWCotrl is TLabeledEdit then
    begin
      (mWCotrl as TLabeledEdit).EditLabel.Font.Color := TColorRec.Black;
    end;
    if mWCotrl is TRadioGroup then
    begin
      (mWCotrl as TRadioGroup).Font.Color := TColorRec.Black;
    end;
    if mWCotrl is TComboBox then
    begin
      (mWCotrl as TComboBox).Font.Color := TColorRec.Black;
    end;
    if mWCotrl is TCfgNotify then
    begin
      (mWCotrl as TCfgNotify).OnClearChgSign(self)
    end;
  end;
end;

function TCfgTool.TCfgBinItem.isDiffrent(MsgOut: TMsgOut): boolean;
var
  txt: string;
begin
  Result := not TBytesTool.Compare(mOrgVal, mVal);
  if Result then
  begin
    if Assigned(MsgOut) then
    begin
      txt := TBytesTool.ToDotStr(mAdr);
      if mWCotrl is TWinControl then
        txt := txt + '-' + (mWCotrl as TWinControl).Name;
      MsgOut(txt);
    end;

    if mWCotrl is TCheckBox then
      (mWCotrl as TCheckBox).Font.Color := TColorRec.Blue;
    if mWCotrl is TLabeledEdit then
    begin
      (mWCotrl as TLabeledEdit).EditLabel.Font.Color := TColorRec.Blue;
    end;
    if mWCotrl is TRadioGroup then
    begin
      (mWCotrl as TRadioGroup).Font.Color := TColorRec.Blue;
    end;
    if mWCotrl is TComboBox then
    begin
      (mWCotrl as TComboBox).Font.Color := TColorRec.Blue;
    end;
    if mWCotrl is TCfgNotify then
    begin
      (mWCotrl as TCfgNotify).OnSetChgSign(self);
    end;

  end;
end;

function TCfgTool.TCfgBinItem.getgetDifferences: TBytes;
var
  n1, n2: integer;
  n: integer;
begin
  Result := nil;
  if TBytesTool.Compare(mOrgVal, mVal) = false then
  begin
    n1 := length(mAdr);
    n2 := length(mVal);
    n := 1 + n1 + 1 + n2;
    setlength(Result, n);
    Result[0] := n;
    System.move(mAdr[0], Result[1], n1);
    Result[1 + n1] := 0;
    System.move(mVal[0], Result[2 + n1], n2);
  end;
end;

function TCfgTool.TCfgBinItem.getAdrAsStr: string;
begin
  Result := TBytesTool.ToDotStr(mAdr);
end;

// wykorzytywna podaczas zapisywania do pliku
function TCfgTool.TCfgBinItem.getValAsStr: string;
begin
  case mKind of
    ckBool, ckByte:
      Result := IntToStr(mVal[0]);
    ckWord:
      Result := IntToStr(TBytesTool.rdWord(mVal, 0));
    ckInt:
      Result := IntToStr(TBytesTool.rdInt(mVal, 0));
    ckFloat:
      Result := Format(mParamStr, [TBytesTool.rdFloat(mVal, 0)], DotFormatSettings);
    ckString:
      Result := TBytesTool.ToStr(mVal);
    ckIP:
      Result := IpToStr(TBytesTool.rdDWord(mVal, 0));
  end;
end;

// wykorzytywna podaczas ³adowania z pliku
function TCfgTool.TCfgBinItem.setValAsStr(vstr: string): boolean;
var
  a: integer;
  f: single;
  w: cardinal;
begin
  case mKind of
    ckBool:
      begin
        Result := TryStrToInt(vstr, a);
        if Result then
          setAsBool(a = 1);
      end;
    ckByte:
      begin
        Result := TryStrToInt(vstr, a);
        if Result then
          setAsByte(a);
      end;
    ckWord:
      begin
        Result := TryStrToInt(vstr, a);
        if Result then
          setAsWord(a);
      end;

    ckInt:
      begin
        Result := TryStrToInt(vstr, a);
        if Result then
          setAsInt(a);
      end;
    ckFloat:
      begin
        Result := TryStrToFloat(vstr, f, DotFormatSettings);
        if Result then
          setAsFloat(f);
      end;
    ckString:
      begin
        setAsString(vstr);
        Result := true;
      end;
    ckIP:
      begin
        Result := StrToIp(vstr, w);
        if Result then
          setAsDWord(w);
      end;
  else
    Result := false;
  end;
  if Result then
    updateWControl;
end;

// --------------------------------------------------
Constructor TCfgTool.Create;
begin
  inherited;

end;

// ³adowanie danych biarnych po odczycie z HDW
procedure TCfgTool.loadValBuf(MsgOut: TMsgOut; mem: TBytes);
var
  ptr: integer;

  function Pop(var adr_vek: TBytes; var val_Vek: TBytes): boolean;
  var
    n, n1: integer;
    sz, k_sz, d_sz: integer;
  begin
    Result := false;
    n := length(mem);
    if ptr < n then
    begin
      sz := mem[ptr];
      n1 := ptr + sz;
      if n1 <= n then
      begin
        k_sz := 1;
        while mem[ptr + 1 + k_sz] <> 0 do
        begin
          inc(k_sz);
        end;
        d_sz := sz - (1 + k_sz + 1);

        adr_vek := TBytesTool.CopyFrom(mem, ptr + 1, k_sz);
        val_Vek := TBytesTool.CopyFrom(mem, ptr + 1 + k_sz + 1, d_sz);
        inc(ptr, sz);
        Result := true;
      end;
    end;
  end;

var
  item: TCfgBinItem;
  adr_vek: TBytes;
  val_Vek: TBytes;
  i: integer;
  txt: string;
begin
  inherited Create;
  clearChangesSign;
  for i := 0 to count - 1 do
  begin
    Items[i].mLoaded := false;
  end;

  ptr := 0;
  while true do
  begin
    if Pop(adr_vek, val_Vek) = false then
      break;
    item := find(adr_vek);
    if Assigned(MsgOut) then
    begin
      txt := Format('key=%s Fnd=%u', [TBytesTool.ToDotStr(adr_vek), byte(Assigned(item))]);
      if Assigned(item) then
        txt := txt + Format(' UserIdx=%u', [item.mUserIdx]);

      MsgOut(txt);
    end;
    if Assigned(item) then
    begin
      item.mOrgVal := TBytesTool.CopTab(val_Vek);
      item.mVal := val_Vek;

      item.updateWControl;
    end;
  end;
end;

function TCfgTool.FGetItem(index: integer): TCfgBinItem;
begin
  Result := inherited getItem(Index) as TCfgBinItem;
end;

function TCfgTool.find(vek: TBytes): TCfgBinItem;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to count - 1 do
  begin
    if TBytesTool.Compare(Items[i].mAdr, vek) then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TCfgTool.getItemV(vek: TBytes): TCfgBinItem;
begin
  Result := find(vek);
  if Result = nil then
  begin
    Result := TCfgBinItem.Create;
    Result.mAdr := vek;
    add(Result);
  end;
end;

function TCfgTool.find(vek: string): TCfgBinItem;
var
  vekBin: TBytes;
begin
  vekBin := TBytesTool.LoadFromDotString(vek);
  Result := find(vekBin);
end;

function TCfgTool.AddItem(kind: TCfgKind; vek: TBytes; winCtrl: Tobject): TCfgBinItem;
begin
  if find(vek) = nil then
  begin
    Result := TCfgBinItem.Create;
    Result.mKind := kind;
    Result.mWCotrl := winCtrl;
    Result.mAdr := vek;
    Result.mParamStr := '';
    if kind = ckFloat then
      Result.mParamStr := '%f';
    add(Result);
  end
  else
    raise Exception.Create(Format('TCfgBinTool, wektor ju¿ istnieje:<%s>', [TBytesTool.ToDotStr(vek)]));
end;

function TCfgTool.AddItem(kind: TCfgKind; vek: TBytes; winCtrl: Tobject; paramStr: string): TCfgBinItem;
begin
  Result := AddItem(kind, vek, winCtrl);
  Result.mParamStr := paramStr;
end;

function TCfgTool.AddItem(kind: TCfgKind; vek: TBytes; winCtrl: Tobject; userIdx: integer): TCfgBinItem;
begin
  Result := AddItem(kind, vek, winCtrl);
  Result.mUserIdx := userIdx;
end;

procedure TCfgTool.clearWControls;
var
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    Items[i].clearWControls;
  end;
end;

procedure TCfgTool.clearChangesSign;
var
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    Items[i].clearChangesSign;
  end;
end;

procedure TCfgTool.AckChanges;
var
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    Items[i].AckChanges;
  end;
end;

procedure TCfgTool.loadFromControls;
var
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    Items[i].loadFromControls;
  end;
end;

function TCfgTool.getDifferences: TBytes;
var
  i: integer;
begin
  Result := nil;
  loadFromControls;
  for i := 0 to count - 1 do
  begin
    Result := TBytesTool.add(Result, Items[i].getgetDifferences);
  end;
end;

function TCfgTool.getDifferencesCount(MsgOut: TMsgOut): integer;
var
  i: integer;
begin
  Result := 0;
  loadFromControls;
  for i := 0 to count - 1 do
  begin
    if Items[i].isDiffrent(MsgOut) then
      inc(Result);
  end;
end;

procedure TCfgTool.SaveToFile(Title, FName: string);
var
  i: integer;
  SL: TStringList;
  kstr, vstr: string;
begin
  SL := TStringList.Create;
  try
    SL.add(Format('#konfiguracja %s, zapisana %s', [Title, DateTimeToStr(now)]));
    SL.add('');
    loadFromControls;
    for i := 0 to count - 1 do
    begin
      kstr := Items[i].getAdrAsStr;
      vstr := Items[i].getValAsStr;
      SL.Values[kstr] := vstr;
    end;
    SL.SaveToFile(FName);
  finally
    SL.Free;
  end;
end;

procedure TCfgTool.LoadFromFile(FName: string);
var
  i: integer;
  SL: TStringList;
  kstr, vstr: string;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(FName);
    clearChangesSign;
    for i := 0 to count - 1 do
    begin
      kstr := Items[i].getAdrAsStr;
      if SL.IndexOfName(kstr) >= 0 then
      begin
        vstr := SL.Values[kstr];
        Items[i].setValAsStr(vstr);
      end;
    end;
  finally
    SL.Free;
  end;
end;

end.
