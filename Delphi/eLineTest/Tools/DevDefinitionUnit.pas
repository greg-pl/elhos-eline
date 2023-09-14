unit DevDefinitionUnit;

interface

uses
  Classes, Windows, WinSock, Messages, Types, SysUtils, Contnrs,
  eLineDef;

type


  TELineDevDefinition = class(TObject)
  private
    mIp: string;
    mDevTypStr: string;
    mDevId: string;
    mNrSer: string;
    mElineDevType: TElineDevType.T;
    mIpChg: boolean;
    mDevIdChg: boolean;
    mNewDev: boolean;
    mReadyFlag: boolean;
    procedure FSetIp(aip: string);
    procedure FSetDevId(aid: string);
  public
    constructor create(IP, SerNum, DevType, devId: string);
    property NrSer: string read mNrSer;
    property DevTypStr: string read mDevTypStr;
    property DevTyp: TElineDevType.T read mElineDevType;
    property IP: string read mIp write FSetIp;
    property devId: string read mDevId write FSetDevId;
    property isIpChg: boolean read mIpChg;
    property isDevIdChg: boolean read mDevIdChg;
    property isNewDev: boolean read mNewDev;
    property isReady: boolean read mReadyFlag;
    procedure clearNewFlag;
    function GetHidName: string;
    procedure clearReadyFlag;
    procedure setReadyFlag;
  end;

  TOnDeviceDeleteNotify = procedure(sender: TELineDevDefinition) of object;

  TELineDevDefinitionList = class(TObjectList)
  private
    function FGetItem(Index: integer): TELineDevDefinition;
  public
    property Items[Index: integer]: TELineDevDefinition read FGetItem;
    function findDevByIP(IP: string): TELineDevDefinition;
    function findDevBySN(sn: string): TELineDevDefinition;
    function findDev(DevTypeStr, sn: string): TELineDevDefinition;
    function AddDev(IP, SerNum, DevType, devId: string): TELineDevDefinition;
    procedure clearReadyFlags;
    procedure deleteNotRdyDevices(onDeviceDelete: TOnDeviceDeleteNotify);
  end;

implementation

constructor TELineDevDefinition.create(IP, SerNum, DevType, devId: string);
begin
  mIp := IP;
  mDevTypStr := DevType;
  mDevId := devId;
  mNrSer := SerNum;
  mElineDevType := TElineDevType.getDevType(DevType);
  mNewDev := true;
  mReadyFlag := true;
  mIpChg := false;
  mDevIdChg := false;
end;


procedure TELineDevDefinition.clearNewFlag;
begin
  mNewDev := false;
end;

procedure TELineDevDefinition.FSetIp(aip: string);
begin
  mIpChg := (mIp <> aip);
  mIp := aip;
end;

procedure TELineDevDefinition.FSetDevId(aid: string);
begin
  mDevIdChg := (mDevId <> aid);
  mDevId := aid;
end;

function TELineDevDefinition.GetHidName: string;
begin
  Result := TElineDevType.getTypNameHid(mElineDevType) + ': ' + mDevId;
end;

procedure TELineDevDefinition.clearReadyFlag;
begin
  mReadyFlag := false;
end;

procedure TELineDevDefinition.setReadyFlag;
begin
  mReadyFlag := true;
end;

// ------- TELineDeviceList ----------------------------------------------------
function TELineDevDefinitionList.FGetItem(Index: integer): TELineDevDefinition;
begin
  Result := inherited GetItem(Index) as TELineDevDefinition;
end;

procedure TELineDevDefinitionList.clearReadyFlags;
var
  i: integer;
begin
  for i := 0 to count - 1 do
  begin
    Items[i].clearReadyFlag;
  end;
end;

procedure TELineDevDefinitionList.deleteNotRdyDevices(onDeviceDelete: TOnDeviceDeleteNotify);
var
  i: integer;
begin
  for i := count - 1 downto 0 do
  begin
    if not(Items[i].isReady) then
    begin
      if Assigned(onDeviceDelete) then
        onDeviceDelete(Items[i]);
      delete(i);
    end;
  end;
end;

function TELineDevDefinitionList.findDevByIP(IP: string): TELineDevDefinition;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to count - 1 do
  begin
    if Items[i].IP = IP then
    begin
      Result := Items[i];
      break;

    end;
  end;
end;

function TELineDevDefinitionList.findDevBySN(sn: string): TELineDevDefinition;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to count - 1 do
  begin
    if Items[i].NrSer = sn then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TELineDevDefinitionList.findDev(DevTypeStr, sn: string): TELineDevDefinition;
var
  i: integer;
  DevType: TElineDevType.T;
begin
  Result := nil;
  DevType := TElineDevType.getDevType(DevTypeStr);
  for i := 0 to count - 1 do
  begin
    if (Items[i].DevTyp = DevType) and (Items[i].NrSer = sn) then
    begin
      Result := Items[i];
      break;
    end;
  end;
end;

function TELineDevDefinitionList.AddDev(IP, SerNum, DevType, devId: string): TELineDevDefinition;
begin
  Result := findDev(DevType, SerNum);
  if Assigned(Result) then
  begin
    Result.clearNewFlag;
    Result.setReadyFlag;
    Result.devId := devId;
    Result.IP := IP;
  end
  else
  begin
    Result := TELineDevDefinition.create(IP, SerNum, DevType, devId);
    Add(Result);
  end;
end;

end.
