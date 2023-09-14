unit Rfm69SkanerCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Registry,
  SkanerCmmUnit,
  InterRsd, Vcl.Samples.Spin;

type
  TCfgForm = class(TForm)
    CfgPageControl: TPageControl;
    Uniwersalna: TTabSheet;
    TabSheet4: TTabSheet;
    Szarpak: TTabSheet;
    ImageList2: TImageList;
    ToolBar1: TToolBar;
    ToolButton8: TToolButton;
    ToolButton24: TToolButton;
    ActionList1: TActionList;
    actSendCfg: TAction;
    ToolButton1: TToolButton;
    TrybLedBox: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    GeoNrKanaluBox: TComboBox;
    GeoKana³FreqLabel: TLabel;
    Panel1: TPanel;
    TxPowerEdit: TSpinEdit;
    Label3: TLabel;
    UniFreqEdit: TLabeledEdit;
    Label6: TLabel;
    UniBaudRateBox: TComboBox;
    SzaNrKanaluBox: TComboBox;
    SzaKana³FreqLabel: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    PaModeBox: TComboBox;
    sheetSLine: TTabSheet;
    sLineKanalFreqLabel: TLabel;
    Label8: TLabel;
    eLineNrKanaluBox: TComboBox;
    procedure actSendCfgExecute(Sender: TObject);
    procedure actSendCfgUpdate(Sender: TObject);
    procedure GeoNrKanaluBoxChange(Sender: TObject);
    procedure TabSheet4Show(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure UniFreqEditExit(Sender: TObject);
    procedure UniFreqEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SzaNrKanaluBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure eLineNrKanaluBoxChange(Sender: TObject);
  private
    function SK: TSkanerDev;
    procedure SaveToRegistry;
    procedure ReadFromRegistry;

  public
    ConfigAndClose: boolean;
    function getRfm69Cfg: TRfm69SkanerCfg;
    function getELineChannelNr: byte;
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  Rfm69Main;

function TCfgForm.SK: TSkanerDev;
begin
  Result := MainForm.Skaner;
end;

procedure TCfgForm.SzaNrKanaluBoxChange(Sender: TObject);
begin
  SzaKana³FreqLabel.Caption := Format('Czêstotliwoœæ =%u',
    [SZA_FREQ_BASE + (Sender as TComboBox).ItemIndex * SZA_FREQ_CHANNEL_WIDE]);
end;

procedure TCfgForm.eLineNrKanaluBoxChange(Sender: TObject);
begin
  sLineKanalFreqLabel.Caption := Format('Czêstotliwoœæ =%u',
    [ELINE_FREQ_BASE + (Sender as TComboBox).ItemIndex * ELINE_FREQ_CHANNEL_WIDE]);
end;

procedure TCfgForm.GeoNrKanaluBoxChange(Sender: TObject);
begin
  GeoKana³FreqLabel.Caption := Format('Czêstotliwoœæ =%u',
    [GEO_FREQ_BASE + GeoNrKanaluBox.ItemIndex * GEO_FREQ_CHANNEL_WIDE]);
end;

procedure TCfgForm.UniFreqEditExit(Sender: TObject);
var
  f: double;
begin
  f := StrToFloat(UniFreqEdit.Text);
  if f < MIN_UNIFREQ then
  begin
    Application.MessageBox(pchar(Format('Minimalna czêstotliwoœæ [%f]MHz', [MIN_UNIFREQ])), '', mb_ok);
    UniFreqEdit.Text := FloatToStr(MIN_UNIFREQ);
  end;
  if f > MAX_UNIFREQ then
  begin
    Application.MessageBox(pchar(Format('Maksymalna czêstotliwoœæ [%f]MHz', [MAX_UNIFREQ])), '', mb_ok);
    UniFreqEdit.Text := FloatToStr(MAX_UNIFREQ);
  end;

end;

procedure TCfgForm.UniFreqEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = 13) or (Key = 10) then
    UniFreqEditExit(Sender);
end;

function TCfgForm.getELineChannelNr: byte;
begin
  Result := eLineNrKanaluBox.ItemIndex;
end;


function TCfgForm.getRfm69Cfg: TRfm69SkanerCfg;

  procedure ReadPageUni(var cfg: TRfm69SkanerCfg);
  begin
    cfg.LedBottomMode := TrybLedBox.ItemIndex;
    cfg.BaudRate := UniBaudRateBox.ItemIndex;
    cfg.ChannelFreq := trunc(VAL_MILION * StrToFloat(UniFreqEdit.Text));
  end;

  procedure ReadPageGeometria(var cfg: TRfm69SkanerCfg);
  begin
    cfg.LedBottomMode := 0; // linijka do przodu
    cfg.ChannelFreq := GeoNrKanaluBox.ItemIndex * GEO_FREQ_CHANNEL_WIDE;
    cfg.BaudRate := ord(bd300000);
  end;

  procedure ReadPageSzarpak(var cfg: TRfm69SkanerCfg);
  begin
    cfg.LedBottomMode := 2; // do œrodka
    cfg.ChannelFreq := SZA_FREQ_BASE + SzaNrKanaluBox.ItemIndex * SZA_FREQ_CHANNEL_WIDE;
    cfg.BaudRate := ord(bd19200);
  end;

  procedure ReadPageELine(var cfg: TRfm69SkanerCfg);
  begin
    cfg.LedBottomMode := 3; //
    cfg.ChannelFreq := ELINE_FREQ_BASE + eLineNrKanaluBox.ItemIndex * ELINE_FREQ_CHANNEL_WIDE;
    cfg.BaudRate := ord(bd19200);
  end;

var
  buf: TBytes;
  SzSkanerCfg: TRfm69SkanerCfg;
begin
  fillchar(SzSkanerCfg, sizeof(SzSkanerCfg), 0);
  case CfgPageControl.ActivePageIndex of
    0:
      ReadPageUni(SzSkanerCfg);
    1:
      ReadPageGeometria(SzSkanerCfg);
    2:
      ReadPageSzarpak(SzSkanerCfg);
    3:
      ReadPageELine(SzSkanerCfg);
  end;
  SzSkanerCfg.TxPower := TxPowerEdit.Value;
  SzSkanerCfg.HighPower := PaModeBox.ItemIndex;
  Result := SzSkanerCfg;
end;

procedure TCfgForm.actSendCfgExecute(Sender: TObject);
var
  SzSkanerCfg: TRfm69SkanerCfg;
begin
  SzSkanerCfg := getRfm69Cfg;
  SK.WriteCfgMessage(SzSkanerCfg);
end;

procedure TCfgForm.actSendCfgUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := SK.Connected;
end;

procedure TCfgForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveToRegistry;
end;

procedure TCfgForm.FormCreate(Sender: TObject);
begin
  ConfigAndClose := false;
  ReadFromRegistry;
end;

procedure TCfgForm.FormShow(Sender: TObject);
begin
  if ConfigAndClose then
  begin
    actSendCfgExecute(nil);
    PostMessage(Handle, wm_close, 0, 0);
  end;
end;

// Sheet Geometria
procedure TCfgForm.TabSheet4Show(Sender: TObject);
begin
  GeoNrKanaluBoxChange(nil);
end;

procedure TCfgForm.SaveToRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, true) then
    begin
      Reg.WriteInteger('CfgPage', CfgPageControl.ActivePageIndex);
      Reg.WriteInteger('TxPower', TxPowerEdit.Value);
      Reg.WriteInteger('GeoNrKanalu', GeoNrKanaluBox.ItemIndex);
      Reg.WriteInteger('SzaNrKanalu', SzaNrKanaluBox.ItemIndex);
      Reg.WriteInteger('eLineNrKanalu', eLineNrKanaluBox.ItemIndex);
      Reg.WriteInteger('TrybLed', TrybLedBox.ItemIndex);
      Reg.WriteInteger('UniBaudRate', UniBaudRateBox.ItemIndex);
      Reg.WriteString('UniFreq', UniFreqEdit.Text);
      Reg.WriteInteger('PAMode', PaModeBox.ItemIndex);

    end;
  finally
    Reg.Free;
  end;
end;

procedure TCfgForm.ReadFromRegistry;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if Reg.OpenKey(REG_KEY, false) then
    begin
      if Reg.ValueExists('CfgPage') then
        CfgPageControl.ActivePageIndex := Reg.ReadInteger('CfgPage');

      if Reg.ValueExists('TxPower') then
        TxPowerEdit.Value := Reg.ReadInteger('TxPower');

      if Reg.ValueExists('GeoNrKanalu') then
        GeoNrKanaluBox.ItemIndex := Reg.ReadInteger('GeoNrKanalu');

      if Reg.ValueExists('SzaNrKanalu') then
        SzaNrKanaluBox.ItemIndex := Reg.ReadInteger('SzaNrKanalu');

      if Reg.ValueExists('eLineNrKanalu') then
        eLineNrKanaluBox.ItemIndex := Reg.ReadInteger('eLineNrKanalu');

      if Reg.ValueExists('TrybLed') then
        TrybLedBox.ItemIndex := Reg.ReadInteger('TrybLed');

      if Reg.ValueExists('UniBaudRate') then
        UniBaudRateBox.ItemIndex := Reg.ReadInteger('UniBaudRate');

      if Reg.ValueExists('UniFreq') then
        UniFreqEdit.Text := Reg.ReadString('UniFreq');

      if Reg.ValueExists('PAMode') then
        PaModeBox.ItemIndex := Reg.ReadInteger('PAMode');

    end;
  finally
    Reg.Free;
  end;
end;

end.
