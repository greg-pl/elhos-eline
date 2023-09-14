unit SensDevUnit;

interface

uses
  Classes, Windows, Messages, Types, SysUtils, Contnrs, ExtCtrls,
  // WinSock,
  WinSock2,
  CmmObjDefinition,
  DevDefinitionUnit,
  Base64Tools,
  eLineDef,
  NetToolsUnit,
  BaseDevCmmUnit;

type
  TSensDev = class(TBaseELineDev)

  public
    constructor Create;
    procedure sendRunKalibr(PkNr: byte; kalibVal: single);
    procedure sendRunMeasure(run: boolean; mode: byte);
    procedure sendOnOff12V(onOff: boolean);
    procedure sendOnOffOut(onOff: boolean);
  end;

implementation

uses
  MyUtils;

constructor TSensDev.Create;
begin
  inherited;
end;

procedure TSensDev.sendRunKalibr(PkNr: byte; kalibVal: single);
var
  buf: TBytes;
begin
  setlength(buf, 5);
  buf[0] := PkNr;
  TBytesTool.setFloat(buf, 1, kalibVal);

  addReqest(dsdSENSOR, ord(msgSensorMakeKalibr), buf);
end;

procedure TSensDev.sendRunMeasure(run: boolean; mode: byte);
var
  buf: TBytes;
begin
  setlength(buf, 2);
  buf[0] := byte(run);
  buf[1] := byte(mode);

  addReqest(dsdSENSOR, ord(msgSensorStartMeas), buf);
end;

procedure TSensDev.sendOnOff12V(onOff: boolean);
var
  buf: TBytes;
begin
  setlength(buf, 1);
  buf[0] := byte(onOff);

  addReqest(dsdSENSOR, ord(msgOnOff12V), buf);
end;

procedure TSensDev.sendOnOffOut(onOff: boolean);
var
  buf: TBytes;
begin
  setlength(buf, 1);
  buf[0] := byte(onOff);

  addReqest(dsdSENSOR, ord(msgOnOffOut), buf);
end;

end.
