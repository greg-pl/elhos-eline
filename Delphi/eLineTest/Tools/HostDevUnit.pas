unit HostDevUnit;

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
  THostDev = class(TBaseELineDev)

  public
    constructor Create;
    procedure sendPK(pkNr: integer; state: boolean);
    procedure sendReqPK;
    procedure reqPK;
    procedure sendBeep(beepTyp: byte);
    procedure SendFalownikReq(FalNr: TFalownikNr; cmd: TFalownikCmd);
  end;

implementation

constructor THostDev.Create;
begin
  inherited;
end;

procedure THostDev.reqPK;
begin
  addReqest(dsdHOST, ord(msgHostGetOut));
end;

procedure THostDev.sendPK(pkNr: integer; state: boolean);
var
  buf: TBytes;
begin
  setlength(buf, 2);
  buf[0] := pkNr;
  buf[1] := byte(state);
  addReqest(dsdHOST, ord(msgHostSetOut), buf);

end;

procedure THostDev.sendReqPK;
begin
  addReqest(dsdHOST, ord(msgHostGetOut));
  sendBufferNow;
end;

procedure THostDev.sendBeep(beepTyp: byte);
begin
  addReqest(dsdHOST, ord(msgHostBuzzer), beepTyp, 1);
  sendBufferNow;
end;

procedure THostDev.SendFalownikReq(FalNr: TFalownikNr; cmd: TFalownikCmd);
var
  buf: TBytes;
begin
  setlength(buf, 2);
  buf[0] := ord(FalNr);
  buf[1] := ord(cmd);
  addReqest(dsdHOST, ord(msgHostSterFalownik), buf);
  sendBufferNow;
end;

end.
