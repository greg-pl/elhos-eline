unit frmHostTestPilot;

interface

uses
  System.UITypes,Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  Vcl.Grids, Vcl.ValEdit, Vcl.ComCtrls,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition,
  MyUtils;

type
  THostTestPilotForm = class(TBaseELineForm)
    Panel6: TPanel;
    Shape1: TShape;
    elineBtn8Shape: TShape;
    elineBtn3Shape: TShape;
    elineBtn6Shape: TShape;
    elineBtn2Shape: TShape;
    elineBtn1Shape: TShape;
    elineBtn5Shape: TShape;
    elineBtn7Shape: TShape;
    elineBtn4Shape: TShape;
    elineBtn10Shape: TShape;
    elineBtn9Shape: TShape;
    elineLampShape: TShape;
    elineBtn8Txt: TLabel;
    elineBtn10Txt: TLabel;
    elineBtn9Txt: TLabel;
    elineBtn7Txt: TLabel;
    elineBtn6Txt: TLabel;
    elineBtn4Txt: TLabel;
    elineBtn5Txt: TLabel;
    elineBtn1Txt: TLabel;
    elineBtn2Txt: TLabel;
    elineBtn3Txt: TLabel;
    Timer1: TTimer;
    ActionList1: TActionList;
    Action1: TAction;
    Button8: TButton;
    Button10: TButton;
    Button9: TButton;
    Button11: TButton;
    VL: TValueListEditor;
    StatusBar1: TStatusBar;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure actELineGetPilotInfoExecute(Sender: TObject);
    procedure actELinePilotClrCountersExecute(Sender: TObject);
    procedure actELineSetChannelNrExecute(Sender: TObject);
    procedure actELinePilotGoSleepExecute(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private const
    ELINE_KEY_CNT = 10;
    procedure SendPilotCmd(cmd: TKpilotCmd);

  private type
    TShapeEx = record
      Sh: TShape;
      Lab: TLabel;
      memColor: TColor;
    end;

    TELineRec = record
      Shapes: array [0 .. ELINE_KEY_CNT - 1] of TShapeEx;
    end;
  private
    elineRec: TELineRec;
    mLastSendCnt: integer;
  private
    { Private declarations }
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}

uses
  MMSystem;

// definicje zgodne z "RadioTypes.h" ale nie publiczne

type
  TPilotCmdEx = ( //
    plcmdUNKNOWN = 0, //
    plcmdDATA = 1, // {P-->} ramka danych z pilota
    plcmdINFO = 2, // {P-->} ramka informacyjna z pilota
    plcmdACK = 3, // {P-->} potwierdzenie komend
    plcmdSETUP = 4, // {-->P} ramka konfiguracyjna do pilota
    plcmdCLR_CNT = 5, // {-->P} rozkaz kasowania liczników
    plcmdGET_INFO = 6, // {-->P} wyœlij info rekord
    plcmdEXIT_SETUP = 7, // {P-->} informacja o wyjœciu z trybu setup
    plcmdCHIP_SN = 8, // {P-->} ramka informacyjna 2 z pilota
    plcmdGO_SLEEP = 9 // {-->P} uœpij pilot
    );

  TPilotCmdResult = ( //
    plerrOK = 0, //
    plerrBAD_ARG = 1, //
    plerrFLASH_ERR = 2 //
    );

  TPilot_InfoStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    free: TByte3;
    firmVer: word; // versja virmware
    firmRev: word; // revision firmware
    startCnt: cardinal; // licznik pobudek pilota od w³o¿enia baterii
    keyGlobSendCnt: cardinal; // licznik wys³anych ramek od w³o¿enia baterii
    PackTime: cardinal; // data.czas skasowania liczników
    SumaXor: cardinal;
  end;

  // {P-->} ramka informacyjna2 z pilota
  TPilot_ChipIDStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    free: TByte3;
    ChipID: array [0 .. 2] of cardinal; // numer seryjny procesora pilota
    SumaXor: cardinal;
  end;

  TPilot_AckStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    ackCmd: byte; // kod potwierdzanego rozkazu
    ackCmdNr: byte; // numer potwierdzanego rozkazu
    ackError: byte; // status wykonania operacji
    free2: cardinal;
    SumaXor: cardinal;
  end;

procedure THostTestPilotForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  caption := 'Pilot: ' + mELineDev.getCpxName;
  BringUp;
end;

procedure THostTestPilotForm.Timer1Timer(Sender: TObject);
var
  i: integer;
begin
  inherited;
  Timer1.Enabled := false;
  for i := 0 to ELINE_KEY_CNT - 1 do
  begin
    elineRec.Shapes[i].Sh.Brush.Color := elineRec.Shapes[i].memColor;
  end;
  sndPlaySound(nil, SND_ASYNC);

end;

procedure THostTestPilotForm.Timer2Timer(Sender: TObject);
begin
  inherited;
  StatusBar1.SimpleText := '';
end;

const
  InfoCap: array [0 .. 4] of string = ( //
    'Firmware pilota', //
    'Iloœæ w³¹czeñ', //
    'Iloœæ wys³anych naciœniêæ', //
    'Czas zerowania liczników', //
    'ChipID');

procedure THostTestPilotForm.SendPilotCmd(cmd: TKpilotCmd);
var
  b: byte;
begin
  b := ord(cmd);
  mELineDev.addReqest(dsdHOST, ord(msgPilotCmd), b, 1);
end;

procedure THostTestPilotForm.actELineGetPilotInfoExecute(Sender: TObject);
begin
  inherited;
  SendPilotCmd(kpltGET_INFO);
  VL.Values[InfoCap[0]] := '';
  VL.Values[InfoCap[1]] := '';
  VL.Values[InfoCap[2]] := '';
  VL.Values[InfoCap[3]] := '';
  VL.Values[InfoCap[4]] := '';
end;

procedure THostTestPilotForm.actELinePilotClrCountersExecute(Sender: TObject);
var
  buf: TBytes;
begin
  inherited;
  setlength(buf, 5);
  buf[0] := ord(kpltCLR_CNT);
  TBytesTool.setDWord(buf, 1, DateTimeToFileDate(now));
  mELineDev.addReqest(dsdHOST, ord(msgPilotCmd), buf);

end;

procedure THostTestPilotForm.actELinePilotGoSleepExecute(Sender: TObject);
begin
  inherited;
  SendPilotCmd(kpltGO_SLEEP);
end;

procedure THostTestPilotForm.actELineSetChannelNrExecute(Sender: TObject);
begin
  inherited;
  SendPilotCmd(kpltSET_SETUP);
end;

procedure THostTestPilotForm.BringUp;
begin
  inherited;
end;

procedure THostTestPilotForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  inherited;
  elineRec.Shapes[0].Sh := elineBtn1Shape;
  elineRec.Shapes[1].Sh := elineBtn2Shape;
  elineRec.Shapes[2].Sh := elineBtn3Shape;
  elineRec.Shapes[3].Sh := elineBtn4Shape;
  elineRec.Shapes[4].Sh := elineBtn5Shape;
  elineRec.Shapes[5].Sh := elineBtn6Shape;
  elineRec.Shapes[6].Sh := elineBtn7Shape;
  elineRec.Shapes[7].Sh := elineBtn8Shape;
  elineRec.Shapes[8].Sh := elineBtn9Shape;
  elineRec.Shapes[9].Sh := elineBtn10Shape;

  elineRec.Shapes[0].Lab := elineBtn1Txt;
  elineRec.Shapes[1].Lab := elineBtn2Txt;
  elineRec.Shapes[2].Lab := elineBtn3Txt;
  elineRec.Shapes[3].Lab := elineBtn4Txt;
  elineRec.Shapes[4].Lab := elineBtn5Txt;
  elineRec.Shapes[5].Lab := elineBtn6Txt;
  elineRec.Shapes[6].Lab := elineBtn7Txt;
  elineRec.Shapes[7].Lab := elineBtn8Txt;
  elineRec.Shapes[8].Lab := elineBtn9Txt;
  elineRec.Shapes[9].Lab := elineBtn10Txt;

  for i := 0 to ELINE_KEY_CNT - 1 do
  begin
    elineRec.Shapes[i].memColor := elineRec.Shapes[i].Sh.Brush.Color;
    elineRec.Shapes[i].Lab.Transparent := true;
  end;

end;

procedure THostTestPilotForm.RecivedObj(obj: TKobj);
const
  FName = 'KbdKeyTap.wav';

  procedure ShowKey(code: word);
  var
    i: integer;
  begin
    for i := 0 to ELINE_KEY_CNT - 1 do
    begin
      if (code and (1 shl i)) <> 0 then
      begin
        elineRec.Shapes[i].Sh.Brush.Color := clYellow;
      end;
    end;
    Timer1.Enabled := true;
    sndPlaySound(pchar(FName), SND_ASYNC);

  end;

var
  Dt: TKpilotData;
  n1, n2: integer;
  Sign: cardinal;
  cmd: byte;
  plInfo: TPilot_InfoStruct;
  ChipID: TPilot_ChipIDStruct;
  AckDt: TPilot_AckStruct;
  tm: TDateTime;
  txt: string;
begin
  if (obj.srcDev = dsdHOST) then
  begin
    if obj.obCode = ord(msgPilotKey) then
    begin
      n1 := sizeof(Dt);
      n2 := length(obj.data);
      if n1 = n2 then
      begin
        move(obj.data[0], Dt, n1);
        VL.Values['Numer repetycji'] := IntToStr(Dt.repCnt);
        txt := IntToStr(Dt.SendCnt);
        if mLastSendCnt + 1 <> Dt.SendCnt then
          txt := txt + ' !';
        VL.Values['Numer od wybudzenia'] := txt;
        mLastSendCnt := Dt.SendCnt;
        ShowKey(Dt.code);
      end;

    end
    else if obj.obCode = ord(msgPilotDtEx) then
    begin
      n2 := length(obj.data);
      if n2 >= 5 then
      begin
        Sign := TBytesTool.rdDWord(obj.data, 0);
        cmd := obj.data[4];
        case cmd of
          ord(plcmdINFO):
            begin
              n1 := sizeof(plInfo);
              if n1 = n2 then
              begin
                move(obj.data[0], plInfo, sizeof(plInfo));
                VL.Values[InfoCap[0]] := Format('%u.%.3u', [plInfo.firmVer, plInfo.firmRev]);
                VL.Values[InfoCap[1]] := IntToStr(plInfo.startCnt);
                VL.Values[InfoCap[2]] := IntToStr(plInfo.keyGlobSendCnt);

                try
                  tm := FileDateToDateTime(plInfo.PackTime);
                  VL.Values[InfoCap[3]] := DateTimeToStr(tm);
                except

                end;
              end;
            end;
          ord(plcmdCHIP_SN):
            begin
              n1 := sizeof(ChipID);
              if n1 = n2 then
              begin
                move(obj.data[0], ChipID, sizeof(ChipID));
                VL.Values[InfoCap[4]] := Format('%.8X:%.8X:%.8X', [ChipID.ChipID[0], ChipID.ChipID[1],
                  ChipID.ChipID[2]]);
              end;

            end;
          ord(plcmdACK):
            begin
              n1 := sizeof(AckDt);
              if n1 = n2 then
              begin
                move(obj.data[0], AckDt, sizeof(AckDt));
                if AckDt.ackCmd = byte(ord(plcmdCLR_CNT)) then
                begin
                  if AckDt.ackError = byte(ord(plerrOK)) then
                    Application.MessageBox('Ok', 'Zerowaie liczników pilota', MB_OK)
                  else
                    Application.MessageBox(pchar(Format('B³ad kasownia liczników, kod=%d', [AckDt.ackError])),
                      'Zerowaie liczników pilota', MB_OK);
                end
                else
                begin

                    StatusBar1.SimpleText := Format('ACK: cmd=%u cndnr=%u err=%d',[ord(AckDt.ackCmd),AckDt.ackCmdNr,ackDt.ackError]);
                    Timer2.Enabled := true;
                end;

              end;

            end;
        end;

      end;
    end;
  end;
end;

end.
