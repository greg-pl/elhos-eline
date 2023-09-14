unit InterRsd;

interface

uses
  SysUtils, Classes, Messages, Windows, Forms; // MyUtils;

const
  stOk = 0;
  stNotOpen = 1;
  stSetupErr = 2;
  stTimeOut = 3;
  stCanError = 4;
  stBadId = 10;
  stTimeErr = 11;
  stNoDevice = 12;
  stNoOpen = 13;
  stWriteErr = 14;
  stNoAck = 15;

  stNoImpl = 217;

  wm_NewLine = WM_USER + 200;
  wm_BinData = WM_USER + 201;

  RD_BUF_SIZE = 64 * 1024;
  RD_PART = 1000;

type
  TBytes = array of byte;
  TAnsiChars = array of ansiChar;

  TStrmMode = (smBINARY, smTEXT);

  TThreadList = class(TObject)
  private
    FList: TStringList;
    FCriSection: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Put(s: string);
    function Get(var s: string): boolean;
    function GetItem(RdPtr: integer; var Answ: string): boolean;
    function GetHead: integer;
    procedure Clear;
  end;

  TInpBuf = array [0 .. RD_PART - 1] of byte;

  TBuffer = class(TObject)
  private
    Buf: array of byte;
    FSize: integer;
    FHead: integer;
    FTail: integer;
    FCriSection: TRTLCriticalSection;
  public
    constructor Create(Size: integer);
    destructor Destroy; override;
    procedure CopyToStr(var s: string; Wsk, EndStr: integer);
    function CopyToByteArr(Wsk, EndWsk: integer): TBytes;
    function GetAll: TBytes;
    function TryGetAll: TBytes;
    procedure IncPtr(var Ptr: integer);
    procedure DecPtr(var Ptr: integer);
    function ReadLine(var s: string): boolean;
    function SizeToEnd: integer;
    procedure IncHead(L: integer);
    function getDtCnt: integer;
    function getFreeCnt: integer;
    procedure Clear;
    function PushBuffer(InBuf: TInpBuf; Cnt: integer): boolean;
  end;

  TComDevice = class;

  TRdThread = class(TThread)
  private
    FOwner: TComDevice;
    FStrmMode: TStrmMode;
    Buffer: TBuffer;
    procedure DoReadFromCom;
  protected
    procedure Execute; override;
  public
    LoopCnt: integer;
    Starttick: cardinal;
    FRdy: integer;
    constructor Create(aOwner: TComDevice; mode: TStrmMode);
    destructor Destroy; override;
  end;

  TStatus = integer;
  TBaudRate = (br110, br300, br600, br1200, br2400, br4800, br9600, br14400, br19200, br38400, br56000, br57600,
    br115200);

  TCallBackFunc = procedure(Sender: TObject; Ev: integer; R: real) of object;
  TOnLineRecived = procedure(Sender: TObject; s: string) of object;

  TComDevice = class(TObject)
  private
    ComHandle: THandle;
    FStrmMode: TStrmMode;
    FWrCriSection: TRTLCriticalSection;

    RdThread: TRdThread;
    FLastRecTick: cardinal;

  private // parametry w OpenDev
    FComNr: integer;
    FReciveList: TThreadList;

    procedure FlushRxBuf;
    function RsRead(var Buffer; Count: integer): integer;

    procedure WndProc(var AMessage: TMessage);
    function SetupState(Baund: TBaudRate): TStatus;
    procedure wmNewLine(var Message: TMessage); message wm_NewLine;
    procedure wmBinData(var Message: TMessage); message wm_BinData;

  protected
    // funkcja wywo³ywana przez w¹tek RdThread
    procedure AsynchNewLine(s: string); virtual;
    procedure AsynchBinData(Cnt: integer); virtual;
    procedure AsynchRecIdle; virtual;

  protected
    FHandle: THandle;
    function RsWrite(var Buffer; Count: integer): TStatus;
    procedure RsWriteStr(s: string);
    function RsWriteBuf(Buf: TBytes): TStatus; overload;
    function RsWriteBuf(Buf: TAnsiChars): TStatus; overload;

    function GetBaudRate: TBaudRate; virtual;

    procedure ClrRecData;
    property LastRecTick: cardinal read FLastRecTick;
    procedure doNewLine; virtual;
    procedure doBinData(dtCnt: integer); virtual;
  public
    constructor Create(mode: TStrmMode);
    destructor Destroy; override;
    property ComNr: integer read FComNr;
    function OpenDev(ComNr: integer): TStatus;
    function ReOpenDev: TStatus;
    function CloseDev: TStatus; virtual;
    function Connected: boolean;
    function GetErrStr(Code: TStatus): string;
    function WriteMessage(Msg: string): TStatus; overload;
    function WriteMessage(Msg: TAnsiChars): TStatus; overload;
    function GetReciveLine(var s: string): boolean;
    function GetBytes: TBytes;
    function GetBytesCnt: integer;
    function TryGetBytes: TBytes;
    function GetThreadStr: string;

  end;

var
  Starttick: cardinal;

implementation

const
  dcb_Binary = $00000001;
  dcb_Parity = $00000002;
  dcb_OutxCtsFlow = $00000004;
  dcb_OutxDsrFlow = $00000008;
  dcb_DtrControl = $00000030;
  dcb_DsrSensivity = $00000040;
  dcb_TXContinueOnXOff = $00000080;
  dcb_OutX = $00000100;
  dcb_InX = $00000200;
  dcb_ErrorChar = $00000400;
  dcb_Null = $00000800;
  dcb_RtsControl = $00003000;
  dcb_AbortOnError = $00004000;

function HexByte(b: byte): string;
begin
  Result := IntToHex(b, 2);
end;

function HexDWord(w: cardinal): string;
begin
  Result := IntToHex(w, 8);
end;

function GetByte(s: string; pos: integer): byte;
var
  E: integer;
begin
  if Length(s) >= pos + 1 then
    Val('$' + copy(s, pos, 2), Result, E)
  else
    Result := 0;
end;

function GetWord(s: string; pos: integer): Word;
var
  E: integer;
begin
  if Length(s) >= pos + 3 then
    Val('$' + copy(s, pos, 4), Result, E)
  else
    Result := 0;
end;

function GetDWord(s: string; pos: integer): cardinal;
var
  E: integer;
begin
  if Length(s) >= pos + 7 then
    Val('$' + copy(s, pos, 8), Result, E)
  else
    Result := 0;
end;

// -- TThreadList ----------------------------------------------------------------
constructor TThreadList.Create;
begin
  inherited;
  FList := TStringList.Create;
  InitializeCriticalSection(FCriSection);
end;

destructor TThreadList.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  FList.Free;
  inherited;
end;

procedure TThreadList.Clear;
begin
  EnterCriticalSection(FCriSection);
  try
    FList.Clear;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

procedure TThreadList.Put(s: string);
begin
  EnterCriticalSection(FCriSection);
  try
    FList.Add(s);
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

function TThreadList.Get(var s: string): boolean;
begin
  EnterCriticalSection(FCriSection);
  try
    Result := (FList.Count > 0);
    if Result then
    begin
      s := FList.Strings[0];
      FList.Delete(0);
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

function TThreadList.GetItem(RdPtr: integer; var Answ: string): boolean;
begin
  EnterCriticalSection(FCriSection);
  try
    Result := (FList.Count > RdPtr);
    if Result then
    begin
      Answ := FList.Strings[RdPtr];
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

function TThreadList.GetHead: integer;
begin
  EnterCriticalSection(FCriSection);
  try
    Result := FList.Count;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

// --- TBuffer ---------------------------------------------------------------
constructor TBuffer.Create(Size: integer);
begin
  inherited Create;
  FSize := Size;
  SetLength(Buf, Size);
  FHead := 0;
  FTail := 0;
  InitializeCriticalSection(FCriSection);
end;

destructor TBuffer.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  inherited;
end;

function TBuffer.PushBuffer(InBuf: TInpBuf; Cnt: integer): boolean;
var
  sp: integer;
  cnt1: integer;
begin
  Result := true;
  sp := getFreeCnt;
  if Cnt > sp then
  begin
    // nie mieœci siê w buforze. Obciêcie
    Cnt := sp;
    Result := false;
  end;

  if FHead >= FTail then
  begin
    sp := FSize - FHead;
    cnt1 := Cnt;
    if cnt1 > sp then
      cnt1 := sp;
    move(InBuf[0], Buf[FHead], cnt1);
    inc(FHead, cnt1);
    if FHead = FSize then
      FHead := 0;
    dec(Cnt, cnt1);
    if Cnt <> 0 then
    begin
      move(InBuf[cnt1], Buf[0], Cnt);
      FHead := Cnt;
    end;
  end
  else
  begin
    move(InBuf[0], Buf[FHead], Cnt);
    inc(FHead, Cnt);
    if FHead = FSize then
      FHead := 0;
  end;

  if FHead >= FSize then
  begin
    raise exception.Create('B³¹d wk³adania do bufora');
  end;

end;

procedure TBuffer.IncPtr(var Ptr: integer);
begin
  inc(Ptr);
  if Ptr >= FSize then
    Ptr := 0;
end;

procedure TBuffer.DecPtr(var Ptr: integer);
begin
  if Ptr = 0 then
    Ptr := FSize;
  dec(Ptr);
end;

function TBuffer.SizeToEnd: integer;
begin
  Result := FSize - FHead;
end;

// wywo³ywana z w¹tku
procedure TBuffer.IncHead(L: integer);
begin
  EnterCriticalSection(FCriSection);
  try
    inc(FHead, L);
    if FHead >= FSize then
      dec(FHead, FSize);
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

// wywo³ywana spoza w¹tku
procedure TBuffer.CopyToStr(var s: string; Wsk, EndStr: integer);
var
  i, N: integer;
begin
  N := EndStr - Wsk;
  if N < 0 then
    N := N + RD_BUF_SIZE;
  SetLength(s, N);
  for i := 0 to N - 1 do
  begin
    s[i + 1] := char(Buf[Wsk]);
    IncPtr(Wsk);
  end;
end;

// wywo³ywana spoza w¹tku
function TBuffer.CopyToByteArr(Wsk, EndWsk: integer): TBytes;
var
  i, N: integer;
begin
  N := EndWsk - Wsk;
  if N < 0 then
    N := N + RD_BUF_SIZE;
  SetLength(Result, N);
  if N > 0 then
  begin
    for i := 0 to N - 1 do
    begin
      Result[i] := Buf[Wsk];
      IncPtr(Wsk);
    end;
  end;
end;

// wywo³ywana spoza w¹tku
function TBuffer.GetAll: TBytes;
var
  h: integer;
begin
  h := FHead;
  Result := CopyToByteArr(FTail, h);
  FTail := h;
end;

function TBuffer.TryGetAll: TBytes;
var
  h: integer;
begin
  h := FHead;
  Result := CopyToByteArr(FTail, h);
end;

function TBuffer.getDtCnt: integer;
var
  h: integer;
begin
  h := FHead;
  Result := h - FTail;
  if Result < 0 then
    Result := Result + FSize;
end;

function TBuffer.getFreeCnt: integer;
begin
  Result := (FSize - 1) - getDtCnt;
end;

procedure TBuffer.Clear;
begin
  FHead := 0;
  FTail := 0;
end;

function TBuffer.ReadLine(var s: string): boolean;
const
  CtrlChar: set of byte = [10, 13];
var
  Ptr: integer;
  Ptr2: integer;
  Ptr3: integer;
  a: byte;
  h: integer;
begin
  Ptr := FTail;
  Result := false;
  h := FHead;
  while Ptr <> h do
  begin
    a := Buf[Ptr];
    IncPtr(Ptr);
    if a = 10 then
    begin
      Ptr2 := Ptr;
      Ptr3 := Ptr2;
      DecPtr(Ptr3);
      if Buf[Ptr3] in CtrlChar then
      begin
        Ptr2 := Ptr3;
        DecPtr(Ptr3);
        if Buf[Ptr3] in CtrlChar then
          Ptr2 := Ptr3;
      end;
      CopyToStr(s, FTail, Ptr2);

      Result := true;
      FTail := Ptr;
      break;
    end;
  end;
end;

// ------------------------------------------------------------------
constructor TRdThread.Create(aOwner: TComDevice; mode: TStrmMode);
begin
  inherited Create(true);
  FRdy := 0;
  FStrmMode := mode;
  FOwner := aOwner;
  Buffer := TBuffer.Create(RD_BUF_SIZE);
end;

destructor TRdThread.Destroy;
begin
  OutputDebugString('TRdThread.Destroy');
  Terminate;
  WaitFor;
  Buffer.Free;
  inherited;
end;

procedure TRdThread.DoReadFromCom;
var
  RdCnt: integer;
  s1: string;
  lnNr: integer;
  lastTick, t1: cardinal;
  InBuf: TInpBuf;
begin
  LoopCnt := 0;

  FOwner.FlushRxBuf;
  OutputDebugString('DoReadFromCom.Enter');
  lnNr := 0;
  lastTick := GetTickCount;
  while not(Terminated) and FOwner.Connected do
  begin
    try
      inc(LoopCnt);
      RdCnt := FOwner.RsRead(InBuf, RD_PART);
      Buffer.PushBuffer(InBuf, RdCnt);

      if RdCnt > 0 then
      begin
        // OutputDebugString(pchar(Format('DoReadFromCom. Read Cnt=%u', [RdCnt])));
        FOwner.FLastRecTick := GetTickCount;
        if FStrmMode = smTEXT then
        begin
          while Buffer.ReadLine(s1) do
          begin
            inc(lnNr);
            t1 := GetTickCount;
            // OutputDebugString(pchar(Format('DoReadFromCom.Line:%u tick=%u rdy=%d len=%u T=%u H=%u ',[lnNr, t1 - lastTick, FRdy, Length(s1), Buffer.FTail, Buffer.FHead])));

            lastTick := t1;
            if FRdy = 1 then
              FOwner.AsynchNewLine(s1);
          end;
        end
        else
        begin
          FOwner.AsynchBinData(Buffer.getDtCnt);
          // OutputDebugString(pchar(format('DoReadFromCom  T=%u rdCnt=%u Loop=%u',[GetTickCount-StartTick,rdCnt,LopCnt])));
        end;
      end
      else
      begin
        if FStrmMode = smBINARY then
          FOwner.AsynchRecIdle;
      end;
    except

      OutputDebugString(pchar((ExceptOBject as exception).Message));

    end;
  end;
  OutputDebugString('DoReadFromCom.Exit');
end;

procedure TRdThread.Execute;
begin
  OutputDebugString(pchar(Format('TRdThread, ID=%u', [GetCurrentThreadId])));
  Starttick := GetTickCount;
  while not(Terminated) do
  begin
    if FOwner.Connected and (FRdy = 1) then
    begin
      OutputDebugString('TRdThread, DoReadFromCom');
      DoReadFromCom;
    end
    else
    begin
      // OutputDebugString(pchar(Format('TRdThread, rdy=%d', [FRdy])));
      sleep(250);
    end;
  end;
end;

// ------------------------------------------------------------------
constructor TComDevice.Create(mode: TStrmMode);
begin
  inherited Create;
  FStrmMode := mode;
{$WARN SYMBOL_DEPRECATED OFF}
  FHandle := AllocateHWnd(WndProc);
{$WARN SYMBOL_DEPRECATED ON}
  InitializeCriticalSection(FWrCriSection);
  ComHandle := INVALID_HANDLE_VALUE;
  RdThread := TRdThread.Create(self, mode);
  FReciveList := nil;
  if mode = smTEXT then
  begin
    FReciveList := TThreadList.Create;
  end;
  RdThread.Resume;
end;

destructor TComDevice.Destroy;
begin
{$WARN SYMBOL_DEPRECATED OFF}
  DeallocateHWnd(FHandle);
{$WARN SYMBOL_DEPRECATED ON}
  CloseDev;
  RdThread.Terminate;
  RdThread.WaitFor;
  RdThread.Free;
  DeleteCriticalSection(FWrCriSection);
  if Assigned(FReciveList) then
    FReciveList.Free;
  inherited;
end;

procedure TComDevice.WndProc(var AMessage: TMessage);
begin
  Dispatch(AMessage);
end;

function TComDevice.Connected: boolean;
begin
  Result := (ComHandle <> INVALID_HANDLE_VALUE);
end;

function TComDevice.OpenDev(ComNr: integer): TStatus;
begin
  FComNr := ComNr;
  Result := ReOpenDev;
end;

function TComDevice.SetupState(Baund: TBaudRate): TStatus;
var
  DCB: TDCB;
  Timeouts: TCommTimeouts;
begin
  Result := stSetupErr;
  RdThread.FRdy := -2;
  if GetCommState(ComHandle, DCB) then
  begin
    RdThread.FRdy := -3;
    DCB.Flags := DCB.Flags or dcb_Binary;
    DCB.Parity := NOPARITY;
    DCB.StopBits := ONESTOPBIT;
    case Baund of
      br110:
        DCB.BaudRate := CBR_110;
      br300:
        DCB.BaudRate := CBR_300;
      br600:
        DCB.BaudRate := CBR_600;
      br1200:
        DCB.BaudRate := CBR_1200;
      br2400:
        DCB.BaudRate := CBR_2400;
      br4800:
        DCB.BaudRate := CBR_4800;
      br9600:
        DCB.BaudRate := CBR_9600;
      br14400:
        DCB.BaudRate := CBR_14400;
      br19200:
        DCB.BaudRate := CBR_19200;
      br38400:
        DCB.BaudRate := CBR_38400;
      br56000:
        DCB.BaudRate := CBR_56000;
      br57600:
        DCB.BaudRate := CBR_57600;
      br115200:
        DCB.BaudRate := CBR_115200;
    end;
    DCB.ByteSize := 8;

    if SetCommState(ComHandle, DCB) then
    begin
      RdThread.FRdy := -4;
      if GetCommTimeouts(ComHandle, Timeouts) then
      begin
        RdThread.FRdy := -5;
        {
          Timeouts.ReadIntervalTimeout := 0;
          Timeouts.ReadTotalTimeoutMultiplier := 0;
          Timeouts.ReadTotalTimeoutConstant := 5;
        }

        Timeouts.ReadIntervalTimeout := MAXDWORD;
        Timeouts.ReadTotalTimeoutMultiplier := MAXDWORD;
        Timeouts.ReadTotalTimeoutConstant := 2;

        Timeouts.WriteTotalTimeoutMultiplier := 0;
        Timeouts.WriteTotalTimeoutConstant := 0;
        if SetCommTimeouts(ComHandle, Timeouts) then
        begin
          RdThread.FRdy := -6;
          if SetupComm(ComHandle, $4000, $4000) then
          begin
            RdThread.FRdy := -7;
            Result := stOk;
          end;
        end;
      end;
    end;
  end;
end;

function TComDevice.ReOpenDev: TStatus;
var
  s: string;
begin
  Result := stNotOpen;
  s := '\\.\COM' + IntToStr(FComNr);
  ComHandle := CreateFile(pchar(s), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
  if Connected then
  begin
    RdThread.FRdy := -1;
    Result := SetupState(GetBaudRate);
    if Result = stOk then
      RdThread.FRdy := 1;
  end;

end;

function TComDevice.CloseDev: TStatus;
begin
  if Connected then
  begin
    RdThread.FRdy := 0;
    CloseHandle(ComHandle);
    ComHandle := INVALID_HANDLE_VALUE;
  end;
  Result := stOk;
end;

// funkcja wywo³ywana przez w¹tek RdThread
procedure TComDevice.AsynchNewLine(s: string);
begin
  if Assigned(FReciveList) then
  begin
    FReciveList.Put(s);
    PostMessage(FHandle, wm_NewLine, 0, 0);
  end;
end;

procedure TComDevice.AsynchBinData(Cnt: integer);
begin
  PostMessage(FHandle, wm_BinData, Cnt, 0);
end;

procedure TComDevice.AsynchRecIdle;
begin

end;

procedure TComDevice.wmNewLine(var Message: TMessage);
begin
  doNewLine;
end;

procedure TComDevice.wmBinData(var Message: TMessage);
begin
  doBinData(Message.WParam);
end;

procedure TComDevice.doNewLine;
begin

end;

procedure TComDevice.doBinData(dtCnt: integer);
begin
end;

function TComDevice.GetReciveLine(var s: string): boolean;
begin
  if Assigned(FReciveList) then
    Result := FReciveList.Get(s)
  else
    Result := false;
end;

function TComDevice.GetBytes: TBytes;
begin
  if FStrmMode = smBINARY then
    Result := RdThread.Buffer.GetAll
  else
    SetLength(Result, 0);
end;

function TComDevice.TryGetBytes: TBytes;
begin
  if FStrmMode = smBINARY then
    Result := RdThread.Buffer.TryGetAll
  else
    SetLength(Result, 0);
end;

function TComDevice.GetThreadStr: string;
begin
  Result := Format('Tm=%u Loop=%u', [GetTickCount - Starttick, RdThread.LoopCnt]);
end;

function TComDevice.GetBytesCnt: integer;
begin
  if FStrmMode = smBINARY then
    Result := RdThread.Buffer.getDtCnt
  else
    Result := 0;
end;

procedure TComDevice.FlushRxBuf;
begin
  PurgeComm(ComHandle, PURGE_RXCLEAR);
end;

function TComDevice.RsRead(var Buffer; Count: integer): integer;
var
  Overlapped: TOverlapped;
  BytesRead: cardinal;
  q: boolean;
begin
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, true, true, nil);
  ReadFile(ComHandle, Buffer, Count, BytesRead, @Overlapped);
  // WaitForSingleObject(Overlapped.hEvent, INFINITE);
  WaitForSingleObject(Overlapped.hEvent, 5);
  q := GetOverlappedResult(ComHandle, Overlapped, BytesRead, false);
  CloseHandle(Overlapped.hEvent);
  Result := BytesRead;
  if not(q) then
    Result := 0;
end;

function TComDevice.RsWrite(var Buffer; Count: integer): TStatus;
var
  Overlapped: TOverlapped;
  BytesWritten: cardinal;
  q: boolean;

begin
  Result := stOk;
  EnterCriticalSection(FWrCriSection);
  try
    FillChar(Overlapped, SizeOf(Overlapped), 0);
    Overlapped.hEvent := CreateEvent(nil, true, true, nil);
    WriteFile(ComHandle, Buffer, Count, BytesWritten, @Overlapped);

    // WaitForSingleObject(Overlapped.hEvent, INFINITE);
    WaitForSingleObject(Overlapped.hEvent, 1000);
    q := GetOverlappedResult(ComHandle, Overlapped, BytesWritten, false);
    CloseHandle(Overlapped.hEvent);
    Result := BytesWritten;
    if not(q) then
      Result := stWriteErr;
  finally
    LeaveCriticalSection(FWrCriSection);
  end;
end;

procedure TComDevice.RsWriteStr(s: string);
begin
  RsWrite(s[1], Length(s));
end;

function TComDevice.RsWriteBuf(Buf: TBytes): TStatus;
begin
  Result := RsWrite(Buf[0], Length(Buf));
end;

function TComDevice.RsWriteBuf(Buf: TAnsiChars): TStatus;
begin
  Result := RsWrite(Buf[0], Length(Buf));
end;

function TComDevice.GetBaudRate: TBaudRate;
begin
  Result := br9600;
end;

procedure TComDevice.ClrRecData;
begin
  // PurgeComm(ComHandle, PURGE_RXABORT or PURGE_RXCLEAR or PURGE_TXABORT or PURGE_TXCLEAR);
  PurgeComm(ComHandle, PURGE_TXABORT or PURGE_TXCLEAR);
  FReciveList := nil;
  if Assigned(FReciveList) then
    FReciveList.Clear;
  RdThread.Buffer.Clear;
  FLastRecTick := 0;
end;

function TComDevice.GetErrStr(Code: TStatus): string;
begin

end;

function TComDevice.WriteMessage(Msg: string): TStatus;
begin
  if not(Connected) then
  begin
    Result := stNotOpen;
    Exit;
  end;
  RsWriteStr(Msg);
  Result := stOk;
end;

function TComDevice.WriteMessage(Msg: TAnsiChars): TStatus;
begin
  if not(Connected) then
  begin
    Result := stNotOpen;
    Exit;
  end;
  Result := RsWriteBuf(Msg);
end;

initialization

Starttick := GetTickCount;

end.
