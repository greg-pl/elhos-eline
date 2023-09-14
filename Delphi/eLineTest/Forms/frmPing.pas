unit frmPing;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition,
  MyUtils, Vcl.Buttons, Vcl.ExtCtrls;

type
  TPingForm = class(TBaseELineForm)
    SendOneBtn: TButton;
    SentCntEdit: TLabeledEdit;
    ReciveCntEdit: TLabeledEdit;
    ReciveOkCntEdit: TLabeledEdit;
    MultiSendBtn: TSpeedButton;
    TimeEdit: TLabeledEdit;
    Timer1: TTimer;
    procedure SendOneBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure MultiSendBtnClick(Sender: TObject);
  private type
    TPingRec = record
      nr: integer;
      buf: array [0 .. 39] of byte;
    end;

  private
    pingRec: TPingRec;
    pingNr: integer;
    sendCnt: integer;
    replCnt: integer;
    ReplCntOK: integer;
    uTime: TMicroSekTime;
    mLastFillTick: cardinal;
    multiMode: boolean;
    multiTimeSuma: double;
    multiCnt: integer;
    procedure FillEdits;
    procedure SendPing;
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;

  end;

implementation

{$R *.dfm}

procedure TPingForm.FormCreate(Sender: TObject);
begin
  inherited;
  uTime := TMicroSekTime.Create('');

end;

procedure TPingForm.FormDestroy(Sender: TObject);
begin
  inherited;
  uTime.Free;
end;

procedure TPingForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  caption := 'Ping:' + mELineDev.getIp;
  pingNr := 0;
end;

procedure TPingForm.MultiSendBtnClick(Sender: TObject);
begin
  inherited;
  if MultiSendBtn.Down then
  begin
    SendPing;
    multiTimeSuma := 0;
    multiCnt := 0;
    multiMode := true;
    mLastFillTick := GetTickCount;

  end;
end;

procedure TPingForm.Timer1Timer(Sender: TObject);
begin
  inherited;
  Timer1.Enabled := false;
  SendOneBtn.Enabled := true;
end;

procedure TPingForm.SendPing;
var
  i: integer;
begin
  pingRec.nr := pingNr;
  inc(pingNr);
  for i := 0 to 39 do
    pingRec.buf[i] := 10 + i;
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgPing), pingRec, sizeof(pingRec));
  mELineDev.sendBufferNow;
  inc(sendCnt);
  uTime.Start;
  Timer1.Enabled := false;
  Timer1.Enabled := true;
end;

procedure TPingForm.SendOneBtnClick(Sender: TObject);
begin
  inherited;
  SendPing;
  SendOneBtn.Enabled := false;
  multiMode := false;
end;

procedure TPingForm.FillEdits;
begin
  SentCntEdit.Text := IntToStr(sendCnt);
  ReciveCntEdit.Text := IntToStr(replCnt);
  ReciveOkCntEdit.Text := IntToStr(ReplCntOK);
  if not multiMode then
    TimeEdit.Text := Format('%.3f[ms]', [uTime.GetTm])
  else
    TimeEdit.Text := Format('%.3f[ms]', [multiTimeSuma / multiCnt])
end;

procedure TPingForm.RecivedObj(obj: TKobj);
var
  q: boolean;
begin
  if (obj.srcDev = dsdDEV_COMMON) and (obj.obCode = ord(msgPing)) then
  begin
    uTime.Stop;
    inc(replCnt);
    q := false;
    if sizeof(pingRec) = length(obj.data) then
    begin
      q := CompareMem(@obj.data[0], @pingRec, sizeof(pingRec));
    end;
    if q then
      inc(ReplCntOK);
    if MultiSendBtn.Down then
    begin
      SendPing;
      multiTimeSuma := multiTimeSuma + uTime.GetTm;
      inc(multiCnt);
      if GetTickCount - mLastFillTick > 1000 then
      begin
        mLastFillTick := GetTickCount;
        FillEdits;
      end;
    end
    else
    begin
      FillEdits;
      SendOneBtn.Enabled := true;
    end;
  end;
end;

end.
