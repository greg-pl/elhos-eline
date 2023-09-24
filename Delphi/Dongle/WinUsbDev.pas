unit WinUsbDev;

interface

uses
  Windows, SysUtils, Classes, Registry, Messages, AnsiStrings,
  WinUsbDll;

type
  TOnDataRecived = procedure(Sender: TObject; PipeId: integer; buf: TBytes) of object;

  TWinUsbDev = class(TObject)
  private type
    TRdThread = class(TThread)
    private
      FCriSection: TRTLCriticalSection;
      mOwnerHandle: THandle;
      mUsbHandle: THandle;
      mPipeID: byte;
      function ReadData(buf: TBytes): integer;

    protected
      procedure Execute; override;
    public
      constructor Create(aHandle: THandle; aPipeID: byte);
      destructor Destroy; override;
      procedure setUsbHandle(h: THandle);
    end;

    TDescriptor = record // Generic descriptor
      Length: byte;
      DescriptorType: byte;
      Data: Array [0 .. 1000] of byte; // will crash if descriptor is longer.
    end;

  private const
    HPOS_EVENT = 0;
    HPOS_SOCKET = 1;

    wm_DataRecived = wm_user + 100;

  public type
    TDscrTypeDef = packed record // Generic descriptor
      Length: byte;
      DescriptorType: byte;
      bcdVer: word;
      bDeviceClass: byte;
      bDeviceSubClass: byte;
      bDeviceProtocol: byte;
      bMaxPacketSize: byte;
      idVendor: word;
      idProduct: word;
      bcdDevice: word;
      ManufStrIdx: byte;
      ProductStrIdx: byte;
      SerialStrIdx: byte;
      NumConfiguration: byte;
    end;

    TRecData = class(TObject)
      Data: TBytes;
      constructor Create(buf: TBytes; len: integer);
    end;

    TPipeInfois = array of WINUSB_PIPE_INFORMATION;

  private
    mHandleTab: TWOHandleArray;
    hWinUsbHandle: THandle;
    hDevice: THandle;
    RdThreadTab: array of TRdThread;
    mMyHandle: THandle;
    procedure WndProc(var AMessage: TMessage);
    procedure wmDataRecived(var AMessage: TMessage); message wm_DataRecived;
    procedure TerminateThreads;
  public
    OnDataRecived: TOnDataRecived;
    constructor Create;
    destructor Destroy; override;

    function open(Vid, pid: integer): boolean;
    function isOpened: boolean;
    function readDevDescription(var descr: TDscrTypeDef): boolean;
    procedure getPipeInfo(var info: TPipeInfois);

    function writePipe(PipeId: byte; var Data; len: integer): boolean; overload;
    function writePipe(PipeId: byte; buf: TBytes): boolean; overload;

    procedure Close;
  end;

implementation

constructor TWinUsbDev.TRdThread.Create(aHandle: THandle; aPipeID: byte);
begin
  inherited Create;
  mPipeID := aPipeID;
  InitializeCriticalSection(FCriSection);
  mUsbHandle := INVALID_HANDLE_VALUE;
  mOwnerHandle := aHandle;
end;

destructor TWinUsbDev.TRdThread.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  inherited;
end;

function TWinUsbDev.TRdThread.ReadData(buf: TBytes): integer;
var
  Overlapped: TOverlapped;
  BytesRead: Cardinal;
  q: boolean;
  tt: Cardinal;
  t1: Cardinal;
begin
  try
    tt := GetTickCount;
    q := WinUsb_ReadPipe(mUsbHandle, mPipeID, @buf[0], Length(buf), BytesRead, nil);
    t1 := GetTickCount - tt;
    //OutputDebugString(pchar(Format('N=%u T1=%u ', [BytesRead, t1])));
    Result := BytesRead;
    if not(q) then
      Result := 0;
  except
    Result := 0;
  end;
end;

procedure TWinUsbDev.TRdThread.Execute;
var
  Data: TBytes;
  n: integer;
  recData: TRecData;
begin
  setLength(Data, 1024);
  while not(Terminated) do
  begin
    if mUsbHandle <> INVALID_HANDLE_VALUE then
    begin
      n := ReadData(Data);
      if n > 0 then
      begin
        recData := TRecData.Create(Data, n);
        postMessage(mOwnerHandle, wm_DataRecived, integer(recData), mPipeID);
        // OutputDebugString(pchar(Format('Odebrano n=%u', [n])));
      end;
    end
    else
    begin
      sleep(100);
    end;
  end;
  OutputDebugString(pchar(Format('ID=%u Finished', [mPipeID])));
end;

procedure TWinUsbDev.TRdThread.setUsbHandle(h: THandle);
begin
  EnterCriticalSection(FCriSection);
  try
    mUsbHandle := h;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

constructor TWinUsbDev.TRecData.Create(buf: TBytes; len: integer);
begin
  inherited Create;
  setLength(Data, len);
  move(buf[0], Data[0], len);
end;



// --------------------------------------------------------------------------
// TWinUsbDev.
// --------------------------------------------------------------------------

constructor TWinUsbDev.Create;
begin
  inherited;
  hWinUsbHandle := INVALID_HANDLE_VALUE;
  hDevice := INVALID_HANDLE_VALUE;
  mHandleTab[HPOS_EVENT] := CreateEvent(nil, False, True, nil);
  mMyHandle := Classes.AllocateHWnd(WndProc);
end;

destructor TWinUsbDev.Destroy;
var
  i, n: integer;
begin
  Close;
  TerminateThreads;
end;

procedure TWinUsbDev.TerminateThreads;
var
  i, n: integer;
begin
  n := Length(RdThreadTab);
  if n > 0 then
  begin
    for i := 0 to n - 1 do
    begin
      RdThreadTab[i].Terminate;
      RdThreadTab[i].WaitFor;
      RdThreadTab[i].Free;
    end;
    setLength(RdThreadTab, 0);
  end;
end;

procedure TWinUsbDev.WndProc(var AMessage: TMessage);
begin
  inherited;
  Dispatch(AMessage);
end;

procedure TWinUsbDev.wmDataRecived(var AMessage: TMessage);
var
  Rec: TRecData;
  PipeId: integer;
begin
  Rec := TRecData(Pointer(AMessage.WParam));
  PipeId := AMessage.LParam;
  if Assigned(OnDataRecived) then
    OnDataRecived(self, PipeId, Rec.Data);
  Rec.Free;
end;

function TWinUsbDev.open(Vid, pid: integer): boolean;
var
  Key: string;
  Reg: TRegistry;
  SL: TStringList;
  FName: string;
  pipeInfo: TPipeInfois;
  n, i, k: integer;
begin
  Result := False;
  FName := '';
  Reg := TRegistry.Create(KEY_READ);
  SL := TStringList.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Key := Format('\SYSTEM\CurrentControlSet\Enum\USB\VID_%.4X&PID_%.4X\', [Vid, pid]);
    if Reg.OpenKey(Key, False) then
    begin
      Reg.GetKeyNames(SL);
      if SL.count > 0 then
      begin
        Key := Key + SL.Strings[0] + '\Device Parameters\';
        if Reg.OpenKey(Key, False) then
        begin
          FName := Reg.ReadString('SymbolicName');
        end;
      end;
    end;
  finally
    SL.Free;
    Reg.Free;
  end;

  if FName <> '' then
  begin
    hDevice := CreateFile(pchar(FName), GENERIC_WRITE or GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);
    if hDevice <> INVALID_HANDLE_VALUE then
    begin
      Result := WinUsb_Initialize(hDevice, hWinUsbHandle);
      if Result then
      begin

        getPipeInfo(pipeInfo);
        n := Length(pipeInfo);
        k := 0;
        for i := 0 to n - 1 do
        begin
          if (pipeInfo[i].PipeId and $80) <> 0 then
            inc(k);
        end;
        setLength(RdThreadTab, k);
        k := 0;
        for i := 0 to n - 1 do
        begin
          if (pipeInfo[i].PipeId and $80) <> 0 then
          begin
            RdThreadTab[k] := TRdThread.Create(mMyHandle, pipeInfo[i].PipeId);
            RdThreadTab[k].FreeOnTerminate := False;
            RdThreadTab[k].setUsbHandle(hWinUsbHandle);
            inc(k);
          end;
        end;

      end;
    end;
  end;
end;

procedure TWinUsbDev.Close;
begin
  if hWinUsbHandle <> INVALID_HANDLE_VALUE then
  begin
    WinUsb_Free(hWinUsbHandle);
    CloseHandle(hDevice);
    hDevice := INVALID_HANDLE_VALUE;
    hWinUsbHandle := INVALID_HANDLE_VALUE;
    TerminateThreads;
  end;
end;

function TWinUsbDev.isOpened: boolean;
begin
  Result := (hWinUsbHandle <> INVALID_HANDLE_VALUE);
end;

function TWinUsbDev.readDevDescription(var descr: TDscrTypeDef): boolean;
var
  BytesRead: Cardinal;
begin
  if hWinUsbHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := WinUsb_GetDescriptor(hWinUsbHandle, 1 { Device Descriptor } , 0, $0409, @descr, SizeOf(descr), BytesRead);
    Result := Result and (BytesRead = SizeOf(descr));
  end
  else
    Result := False;
end;

procedure TWinUsbDev.getPipeInfo(var info: TPipeInfois);
var
  i: integer;
  n: integer;
  pipeInfo: WINUSB_PIPE_INFORMATION;
begin
  setLength(info, 0);
  i := 0;
  while WinUsb_QueryPipe(hWinUsbHandle, 0, i, @pipeInfo) do
  begin
    n := Length(info);
    setLength(info, n + 1);
    info[n] := pipeInfo;
    inc(i);
  end;
end;

function TWinUsbDev.writePipe(PipeId: byte; var Data; len: integer): boolean;
var
  BytesWritten: Cardinal;
begin
  if hWinUsbHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := WinUsb_WritePipe(hWinUsbHandle, 1, @Data, len, BytesWritten, nil);
    Result := Result and (BytesWritten = len);
  end
  else
    Result := False;
end;

function TWinUsbDev.writePipe(PipeId: byte; buf: TBytes): boolean;
begin
  if Length(buf) > 0 then
    Result := writePipe(PipeId, buf[0], Length(buf))
  else
    Result := True;
end;

end.
