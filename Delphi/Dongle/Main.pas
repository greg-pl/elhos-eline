unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  WinUsbDll, WinUsbDev, Vcl.StdCtrls, Vcl.ExtCtrls, AnsiStrings;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    OpenBtn: TButton;
    DevDscrBtn: TButton;
    Wr16Btn: TButton;
    Wr128Btn: TButton;
    CloseBtn: TButton;
    PipeInfoBtn: TButton;
    VendorIdEdit: TLabeledEdit;
    ProductIdEdit: TLabeledEdit;
    Panel1: TPanel;
    LogMemo: TMemo;
    Splitter1: TSplitter;
    RepeatBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure DevDscrBtnClick(Sender: TObject);
    procedure Wr16BtnClick(Sender: TObject);
    procedure Wr128BtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PipeInfoBtnClick(Sender: TObject);
    procedure RepeatBoxClick(Sender: TObject);
  private
    Dev: TWinUsbDev;
    SendRepeatCounter: integer;
    StartSendTick: cardinal;
    procedure Wr(s: string);
    procedure Log(s: string);
    function OkErr(q: boolean): string;
    procedure OnDataRecivedProc(Sender: TObject; PipeId: integer; buf: TBytes);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.CloseBtnClick(Sender: TObject);
begin
  Dev.Close;
end;

procedure TForm1.DevDscrBtnClick(Sender: TObject);
var
  descr: TWinUsbDev.TDscrTypeDef;
begin
  if Dev.readDevDescription(descr) then
  begin
    Wr(Format('VID:PID = %.4X:%.4X', [descr.idVendor, descr.idProduct]));
  end
  else
    Wr('ReadDevDescription Error');
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Dev.Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Dev := TWinUsbDev.Create;
  Dev.OnDataRecived := OnDataRecivedProc;
end;

procedure TForm1.OnDataRecivedProc(Sender: TObject; PipeId: integer; buf: TBytes);
var
  s1: AnsiString;
  n: integer;
  bb: TBytes;
  i: integer;
begin
  n := Length(buf);
  setlength(s1, n);
  move(buf[0], s1[1], n);

  PipeId := PipeId and $7F;
  if PipeId = 1 then
  begin
    if RepeatBox.Checked then
    begin
      if SendRepeatCounter < 10000 then
      begin
        if SendRepeatCounter = 0 then
          StartSendTick := gettickcount;
        setlength(bb, 64);
        for i := 0 to Length(bb) - 1 do
          bb[i] := $40 + i;
        if Dev.writePipe(1, bb) = false then
          RepeatBox.Checked := false;
        inc(SendRepeatCounter);
      end
      else
      begin
        Wr(Format('Tick=%u', [gettickcount - StartSendTick]));
        RepeatBox.Checked := false;
      end;
    end
    else
    begin
      Wr(Format('DataRecived Tick=%u PipeID=0x%X, N=%u', [gettickcount, PipeId, Length(buf)]));
    end;
  end
  else if PipeId = 2 then
  begin
    Log(s1);
  end;

end;

procedure TForm1.Wr(s: string);
begin
  Memo1.Lines.Add(s);
end;

procedure TForm1.Log(s: string);
begin
  LogMemo.Lines.Add(s);
end;

function TForm1.OkErr(q: boolean): string;
begin
  if q then
    Result := 'Ok'
  else
    Result := 'Error';
end;

procedure TForm1.OpenBtnClick(Sender: TObject);
var
  pID, vID: word;
begin
  pID := StrToInt('$' + ProductIdEdit.Text);
  vID := StrToInt('$' + VendorIdEdit.Text);

  Wr('Open:' + OkErr(Dev.open(vID, pID)));
end;

procedure TForm1.PipeInfoBtnClick(Sender: TObject);
var
  PipeInfos: TWinUsbDev.TPipeInfois;
  i, n: integer;
begin
  Dev.getPipeInfo(PipeInfos);
  n := Length(PipeInfos);
  if n > 0 then
  begin
    for i := 0 to n - 1 do
    begin
      Wr(Format('Pipe_%u  T=%u Id=0x%.2X MaxPkt=0x%.2X Interv=%u', [i, (PipeInfos[i].PipeType and $FF),
        (PipeInfos[i].PipeId and $FF), PipeInfos[i].MaximumPacketSize, PipeInfos[i].Interval]));
    end;
  end
  else
    Wr('No pipe');

end;

procedure TForm1.RepeatBoxClick(Sender: TObject);
begin
  SendRepeatCounter := 0;
end;

procedure TForm1.Wr128BtnClick(Sender: TObject);
var
  bb: TBytes;
  i: integer;
begin
  setlength(bb, 128);
  for i := 0 to Length(bb) - 1 do
    bb[i] := $60 + i;
  Wr('Write:' + OkErr(Dev.writePipe(1, bb)));
end;

procedure TForm1.Wr16BtnClick(Sender: TObject);
var
  bb: TBytes;
  i: integer;
begin
  setlength(bb, 64);
  for i := 0 to Length(bb) - 1 do
    bb[i] := $40 + i;
  Wr(Format('Write:%s', [OkErr(Dev.writePipe(1, bb))]));
end;

end.
