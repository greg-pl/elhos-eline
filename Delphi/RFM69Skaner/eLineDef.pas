unit eLineDef;

interface

const
  ELinePilot_SIGN = $5B07AF12;
  ELinePilot_CLR_SIGN = $3A;
  ELinePilot_SRC_PILOT = 1;
  ELinePilot_SRC_HOST = 2;

type

  ELineCmd = ( //
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

  PELinePilot_Begin = ^TELinePilot_Begin;

  TELinePilot_Begin = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
  end;

  // {P-->} ramka danych z pilota
  PELinePilot_DataStruct = ^TELinePilot_DataStruct;

  TELinePilot_DataStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    repCnt: byte; // licznik powtórzeñ pilota
    keySendCnt: word;
    key_code: word; // kod klawisza
    n_key_code: word; // negacja key_code
    SumaXor: cardinal;
  end;

  // {P-->} ramka informacyjna z pilota
  PELinePilot_InfoStruct = ^TELinePilot_InfoStruct;
  TELinePilot_InfoStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    free: array [0 .. 2] of byte;
    firmVer: word; // versja virmware
    firmRev: word; // revision firmware
    startCnt: cardinal; // licznik pobudek pilota od w³o¿enia baterii
    keyGlobSendCnt: cardinal; // licznik wys³anych ramek od w³o¿enia baterii
    PackTime: cardinal; // data.czas skasowania liczników
    SumaXor: cardinal;
  end;

  //{P-->} ramka informacyjna2 z pilota
  PPilot_ChipIDStruct =^TPilot_ChipIDStruct;
  TPilot_ChipIDStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    free: array [0 .. 2] of byte;
    ChipID: array [0 .. 2] of cardinal; // numer seryjny procesora pilota
    SumaXor: cardinal;
  end;

  // {-->P} ramka konfiguracyjna do pilota
  PELinePilot_SetupStruct = ^TELinePilot_SetupStruct;
  TELinePilot_SetupStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    channelNr: byte; // numer kana³u
    n_channelNr: byte; // negacja channelNr
	  txPower : byte; //sila nadajnika
	  cmdNr: cardinal;
    SumaXor: cardinal;
  end;

  PELinePilot_CmdStruct = ^TELinePilot_CmdStruct;
  TELinePilot_CmdStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    cmdNr: byte; // numer rozkazu
    free: array [0 .. 1] of byte;
    PackTime: cardinal; // data.cza skasowania liczników
    SumaXor: cardinal;
  end;

  PELinePilot_AckStruct = ^TELinePilot_AckStruct;
  TELinePilot_AckStruct = packed record
    Sign: cardinal; // kod sta³y ramki
    cmd: byte;
    ackCmd: byte; // kod potwierdzanego rozkazu
    ackCmdNr: byte; // numer potwierdzanego rozkazu
    ackError: byte;
    free2: cardinal;
    SumaXor: cardinal;
  end;

procedure eLineBuildXor(var w; cnt: integer);

implementation

procedure eLineBuildXor(var w; cnt: integer);
var
  n, i: integer;
  XorW: cardinal;
  dtP: PCardinal;
begin
  if (cnt mod 4) = 0 then
  begin
    n := (cnt div 4) - 1;
    if n > 0 then
    begin
      XorW := 0;
      dtP := PCardinal(@w);
      for i := 0 to n - 1 do
      begin
        XorW := XorW xor dtP^;
        inc(dtP);
      end;
      dtP^ := XorW;
    end;
  end
end;

end.
