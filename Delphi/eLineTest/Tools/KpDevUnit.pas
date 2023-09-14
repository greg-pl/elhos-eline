unit KpDevUnit;

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
  TKpDev = class(TBaseELineDev)

  public
    function isService(serv: TKPService.T): boolean;
    class function getTrkDev(service: TKPService.T): TTrkDev;

    procedure sendWhiteWireTestMode(nr: integer; state: boolean);
    procedure sendBreakWhiteWire(mService: TKPService.T; state: boolean);
    procedure sendNeedTestData(q: boolean);
    procedure sendGetPLSState();
    procedure sendRunMeasure(mService: TKPService.T; run: boolean; mode: byte);
    procedure sendRunKalibr(mService: TKPService.T; PkNr: byte; kalibVal: single);
    procedure sendSlipSideZeroShift;

  end;

implementation

uses
  MyUtils;

function TKpDev.isService(serv: TKPService.T): boolean;
begin
  result := (DevState.DevInfo.DevSpecData and TKPService.getBitMask(serv)) <> 0;
end;

procedure TKpDev.sendWhiteWireTestMode(nr: integer; state: boolean);
var
  buf: TBytes;
begin
  setlength(buf, 2);
  buf[0] := nr;
  buf[1] := byte(state);
  addReqest(dsdKP, ord(msgKPSetPLS), buf);
  sendBufferNow;
end;

procedure TKpDev.sendNeedTestData(q: boolean);
var
  b: byte;
begin
  b := byte(q);
  addReqest(dsdKP, ord(msgKPGetTestData), b, 1);
end;

procedure TKpDev.sendGetPLSState();
begin
  addReqest(dsdKP, ord(msgKPGetPLS));
end;

class function TKpDev.getTrkDev(service: TKPService.T): TTrkDev;
begin
  result := TTrkDev(ord(dsdFIRST_SERVICE) + ord(service));
end;

procedure TKpDev.sendRunMeasure(mService: TKPService.T; run: boolean; mode: byte);
var
  buf: TBytes;
begin
  setlength(buf, 2);
  buf[0] := byte(run);
  buf[1] := byte(mode);

  addReqest(getTrkDev(mService), ord(msgStartMeas), buf);
end;

procedure TKpDev.sendRunKalibr(mService: TKPService.T; PkNr: byte; kalibVal: single);
var
  buf: TBytes;
begin
  setlength(buf, 5);
  buf[0] := PkNr;
  TBytesTool.setFloat(buf, 1, kalibVal);

  addReqest(getTrkDev(mService), ord(msgMakeKalibr), buf);
end;

procedure TKpDev.sendBreakWhiteWire(mService: TKPService.T; state: boolean);
begin
  addReqest(getTrkDev(mService), ord(msgRollTurnOnWhiteL), byte(state), 1);
  sendBufferNow;
end;

procedure TKpDev.sendSlipSideZeroShift;
begin
  addReqest(dsdSLIP_SIDE, ord(msgSlipSideSetZeroShift));
  sendBufferNow;

end;

end.
