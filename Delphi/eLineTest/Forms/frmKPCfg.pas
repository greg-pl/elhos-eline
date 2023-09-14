unit frmKPCfg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Math,

  frmBaseCfg,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CfgBinUtils,
  dlgAnBinUsage,
  CmmObjDefinition, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons,
  System.Actions, Vcl.ActnList, frameKpBreakCfg, frameKpSuspensCfg,
  frameKpWeightCfg, frameKpSlipsideCfg, Vcl.Grids;

type
  TKPCfgForm = class(TBaseCfgForm)
    MainPageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    OwnNameEdit: TLabeledEdit;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    SuspensionPageControl: TPageControl;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    BreaksPageControl: TPageControl;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    WeightPageControl: TPageControl;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    RightBreaksFrm: TKpBreaksCfgFrame;
    LeftBreaksFrm: TKpBreaksCfgFrame;
    TabSheet12: TTabSheet;
    NetIpEdit: TLabeledEdit;
    NetMaskaEdit: TLabeledEdit;
    NetBramaEdit: TLabeledEdit;
    RightSuspFrm: TKpSuspensCfgFrame;
    LeftSuspFrm: TKpSuspensCfgFrame;
    BinAcGrid: TStringGrid;
    SlipSideFrm: TKpSlipsideCfgFrame;
    LeftWeightFrm: TKpWeightCfgFrame;
    RightWeightFrm: TKpWeightCfgFrame;
    UsageBtn: TBitBtn;
    HostIpEdit: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BinAcGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure CheckButtonClick(Sender: TObject);
    procedure UsageBtnClick(Sender: TObject);

  private const
    idxBinInp = 100;
    idxSuspendTabL = 200;
    idxSuspendTabR = 300;

  private type
    THostCfgCode = ( //
{$INCLUDE .\..\..\PROG\Common\Tags\KP.itm }
      msgKPLast);
    TCodes = array of THostCfgCode;

    TMyCfgNotify = class(TCfgTool.TCfgNotify)
    private type
      TGroup = (grBinAc, grSuspenL, grSuspenR);
    private
      function getGroup(idx: Integer): TGroup;
    public
      mOwner: TKPCfgForm;
      constructor create(Owner: TKPCfgForm);
      procedure OnClearChgSign(Sender: TCfgTool.TCfgBinItem); override;
      procedure OnSetChgSign(Sender: TCfgTool.TCfgBinItem); override;
      procedure OnClearControl(Sender: TCfgTool.TCfgBinItem); override;
      procedure OnLoadFromControl(Sender: TCfgTool.TCfgBinItem); override;
      procedure OnUpdateControl(Sender: TCfgTool.TCfgBinItem); override;
    end;

  private
    MyCfgNotify: TMyCfgNotify;
    mUsageForm: TAnBinUsageDlg;
    function KnvTab(codes: TCodes): TBytes;
    function CheckCfg: boolean;
    class function getTakNieStr(s: string): boolean;

  protected
    function getDefaultExt: string; override;
    function getFileFilter: string; override;
  public
    procedure showService(service: TKPService.T);
  end;

implementation

{$R *.dfm}

uses
  MyUtils,
  NetToolsUnit;

constructor TKPCfgForm.TMyCfgNotify.create(Owner: TKPCfgForm);
begin
  inherited create;
  mOwner := Owner;
end;

function TKPCfgForm.TMyCfgNotify.getGroup(idx: Integer): TGroup;
begin
  if (idx >= idxBinInp) and (idx < idxBinInp + 99) then
    Result := grBinAc
  else if (idx >= idxSuspendTabL) and (idx < idxSuspendTabL + 99) then
    Result := grSuspenL
  else if (idx >= idxSuspendTabR) and (idx < idxSuspendTabR + 99) then
    Result := grSuspenR
  else
    raise Exception.create('TMyCfgNotify: index error');
end;

procedure TKPCfgForm.TMyCfgNotify.OnClearControl(Sender: TCfgTool.TCfgBinItem);
  procedure clearGridBinAc(idx: Integer);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    case x of
      0:
        mOwner.BinAcGrid.Cells[1, y + 1] := '';
      1:
        mOwner.BinAcGrid.Cells[2, y + 1] := '';
      2:
        mOwner.BinAcGrid.Cells[3, y + 1] := '';
    end;
    mOwner.BinAcGrid.Invalidate;
    mOwner.BinAcGrid.Refresh;

  end;

  procedure clearGridSusp(Frame: TKpSuspensCfgFrame; idx: Integer);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    case x of
      0:
        Frame.PGrid.Cells[1, y + 1] := '';
      1:
        Frame.PGrid.Cells[2, y + 1] := '';
    end;
    Frame.PGrid.Invalidate;
    Frame.PGrid.Refresh;
  end;

var
  gr: TGroup;
begin
  gr := getGroup(Sender.mUserIdx);
  case gr of
    grBinAc:
      clearGridBinAc(Sender.mUserIdx - idxBinInp);

    grSuspenL:
      clearGridSusp(mOwner.LeftSuspFrm, Sender.mUserIdx - idxSuspendTabL);

    grSuspenR:
      clearGridSusp(mOwner.RightSuspFrm, Sender.mUserIdx - idxSuspendTabR);
  end;
end;

procedure TKPCfgForm.TMyCfgNotify.OnSetChgSign(Sender: TCfgTool.TCfgBinItem);

  procedure SetChgSignBinAc(idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    mOwner.BinAcGrid.Objects[1 + x, y + 1] := self;
  end;

  procedure SetChgSignSuspendFrame(Frame: TKpSuspensCfgFrame; idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    Frame.PGrid.Objects[x + 1, y + 1] := self;
  end;

var
  gr: TGroup;
begin
  gr := getGroup(Sender.mUserIdx);
  case gr of
    grBinAc:
      SetChgSignBinAc(Sender.mUserIdx - idxBinInp, Sender);

    grSuspenL:
      SetChgSignSuspendFrame(mOwner.LeftSuspFrm, Sender.mUserIdx - idxSuspendTabL, Sender);

    grSuspenR:
      SetChgSignSuspendFrame(mOwner.RightSuspFrm, Sender.mUserIdx - idxSuspendTabR, Sender);
  end;
end;

procedure TKPCfgForm.TMyCfgNotify.OnClearChgSign(Sender: TCfgTool.TCfgBinItem);
  procedure ClearChgSignBinAc(idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    mOwner.BinAcGrid.Objects[1 + x, y + 1] := nil;
  end;

  procedure ClearChgSignSuspendFrame(Frame: TKpSuspensCfgFrame; idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    Frame.PGrid.Objects[x + 1, y + 1] := nil;
  end;

var
  gr: TGroup;
begin
  gr := getGroup(Sender.mUserIdx);
  case gr of
    grBinAc:
      ClearChgSignBinAc(Sender.mUserIdx - idxBinInp, Sender);

    grSuspenL:
      ClearChgSignSuspendFrame(mOwner.LeftSuspFrm, Sender.mUserIdx - idxSuspendTabL, Sender);

    grSuspenR:
      ClearChgSignSuspendFrame(mOwner.RightSuspFrm, Sender.mUserIdx - idxSuspendTabR, Sender);
  end;
end;

class function TKPCfgForm.getTakNieStr(s: string): boolean;
begin
  s := uppercase(s);
  Result := (s = 'TAK') or (s = 'T');
end;

procedure TKPCfgForm.TMyCfgNotify.OnLoadFromControl(Sender: TCfgTool.TCfgBinItem);

  procedure loadFromBinAc(idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    case x of
      0:
        Sender.setAsBool(getTakNieStr(mOwner.BinAcGrid.Cells[1, y + 1]));
      1:
        Sender.setAsWord(StrToint(mOwner.BinAcGrid.Cells[2, y + 1]));
      2:
        Sender.setAsWord(StrToint(mOwner.BinAcGrid.Cells[3, y + 1]));
    end;

  end;

  procedure loadFromSuspendFrame(Frame: TKpSuspensCfgFrame; idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    case x of
      0:
        Sender.setAsFloat(StrToFloatZero(Frame.PGrid.Cells[1, y + 1]));
      1:
        Sender.setAsFloat(StrToFloatZero(Frame.PGrid.Cells[2, y + 1]));
    end;

  end;

var
  gr: TGroup;
begin
  gr := getGroup(Sender.mUserIdx);
  case gr of
    grBinAc:
      loadFromBinAc(Sender.mUserIdx - idxBinInp, Sender);

    grSuspenL:
      loadFromSuspendFrame(mOwner.LeftSuspFrm, Sender.mUserIdx - idxSuspendTabL, Sender);

    grSuspenR:
      loadFromSuspendFrame(mOwner.RightSuspFrm, Sender.mUserIdx - idxSuspendTabR, Sender);
  end;
end;

procedure TKPCfgForm.TMyCfgNotify.OnUpdateControl(Sender: TCfgTool.TCfgBinItem);
  function TakNieStr(q: boolean): string;
  begin
    if q then
      Result := 'TAK'
    else
      Result := '-';
  end;

  procedure fillBinAc(idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    case x of
      0:
        mOwner.BinAcGrid.Cells[1, y + 1] := TakNieStr(Sender.getAsBool);
      1:
        mOwner.BinAcGrid.Cells[2, y + 1] := IntToStr(Sender.getAsWord);
      2:
        mOwner.BinAcGrid.Cells[3, y + 1] := IntToStr(Sender.getAsWord);

    end;

  end;

  procedure fillSuspendFrame(Frame: TKpSuspensCfgFrame; idx: Integer; Sender: TCfgTool.TCfgBinItem);
  var
    x, y: Integer;
  begin
    y := idx mod 10;
    x := idx div 10;
    if y = 0 then
    begin
      case x of
        0:
          Frame.PGrid.Cells[1, y + 1] := Formatfloat('0.0', Sender.getAsFloat);
        1:
          Frame.PGrid.Cells[2, y + 1] := Formatfloat('0.0', Sender.getAsFloat);
      end;

    end
    else
    begin
      case x of
        0:
          Frame.PGrid.Cells[1, y + 1] := FormatfloatZero('0.0', Sender.getAsFloat);
        1:
          Frame.PGrid.Cells[2, y + 1] := FormatfloatZero('0.0', Sender.getAsFloat);
      end;
    end;
    Frame.UpdateChart;

  end;

var
  gr: TGroup;
begin
  gr := getGroup(Sender.mUserIdx);
  case gr of
    grBinAc:
      fillBinAc(Sender.mUserIdx - idxBinInp, Sender);

    grSuspenL:
      fillSuspendFrame(mOwner.LeftSuspFrm, Sender.mUserIdx - idxSuspendTabL, Sender);

    grSuspenR:
      fillSuspendFrame(mOwner.RightSuspFrm, Sender.mUserIdx - idxSuspendTabR, Sender);
  end;
end;

// ------------------------------------------------------------------
procedure TKPCfgForm.BinAcGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  inherited;
  DrawColorStringGridCell(Sender as TStringGrid, ACol, ARow, Rect, State);
end;

procedure TKPCfgForm.FormCreate(Sender: TObject);

// MeasValEdit - wartoœæ zmierzona wyra¿ona w procentach
// FizValEdit - wartoœæ wprowadzona w wartoœciach fizycznych
  procedure addKalibrPoint(codes: TCodes; FizValEdit, MeasValEdit: TLabeledEdit);
  var
    n: Integer;
  begin
    n := length(codes);
    setlength(codes, n + 1);
    codes[n] := cfgX_xValFiz;
    mRSett.AddItem(ckFloat, KnvTab(codes), FizValEdit);
    codes[n] := cfgX_xValMeas;
    mRSett.AddItem(ckFloat, KnvTab(codes), MeasValEdit);
  end;

  procedure addKalibrZero(codes: TCodes; Z0OpenEdit, Z0CloseEdit: TLabeledEdit);
  var
    n: Integer;
  begin
    n := length(codes);
    setlength(codes, n + 1);
    codes[n] := cfgX_xInpVal_Open;
    mRSett.AddItem(ckFloat, KnvTab(codes), Z0OpenEdit);
    codes[n] := cfgX_xInpVal_Close;
    mRSett.AddItem(ckFloat, KnvTab(codes), Z0CloseEdit);
  end;

  procedure KalibrDtDblZero(codes: TCodes; Z0OpenEdit, Z0CloseEdit, P1ValEdit, P1KalibrEdit: TLabeledEdit);
  var
    n: Integer;
  begin
    n := length(codes);
    setlength(codes, n + 1);
    codes[n] := cfgX_zZ0;
    addKalibrZero(codes, Z0OpenEdit, Z0CloseEdit);
    codes[n] := cfgX_zP1;
    addKalibrPoint(codes, P1ValEdit, P1KalibrEdit);
  end;

// PxMeasValEdit - wartoœæ zmierzona wyra¿ona w procentach
// PxFizValEdit - wartoœæ wprowadzona w wartoœciach fizycznych
  procedure KalibrDtDbl(codes: TCodes; P0FizValEdit, P0MeasValEdit, P1FizValEdit, P1MeasValEdit: TLabeledEdit);
  var
    n: Integer;
  begin
    n := length(codes);
    setlength(codes, n + 1);
    codes[n] := cfgX_yP0;
    addKalibrPoint(codes, P0FizValEdit, P0MeasValEdit);
    codes[n] := cfgX_yP1;
    addKalibrPoint(codes, P1FizValEdit, P1MeasValEdit);
  end;

  procedure AddBreaks(frm: TKpBreaksCfgFrame; cd: THostCfgCode);

  begin
    mRSett.AddItem(ckBool, KnvTab([cd, cfgB_bEnab]), frm.AktivBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_bAnInutNr]), frm.AnInpNrBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_bPressBitNr]), frm.PressBitBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_bRollBitNr]), frm.SpeedBitBox);
    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_bRollDiameter]), frm.DiameterEdit);
    mRSett.AddItem(ckInt, KnvTab([cd, cfgB_bRollImpCnt]), frm.ImpCnt);
    KalibrDtDblZero([cd, cfgB_bKalibr], frm.Z0OpenEdit, frm.Z0CloseEdit, frm.P1ValEdit, frm.P1KalibrEdit);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_bKalibQuqlity]), nil);
  end;

  procedure AddSuspens(frm: TKpSuspensCfgFrame; cd: THostCfgCode);
  var
    i: Integer;
    base: Integer;
  begin
    mRSett.AddItem(ckBool, KnvTab([cd, cfgB_sEnab]), frm.AktivBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_sAnInutNr]), frm.AnInpBox);

    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_sDeadZone]), frm.DeadBandEdit);
    mRSett.AddItem(ckWord, KnvTab([cd, cfgB_sDeactivTime]), frm.ReturnTimeEdit);
    // procedure KalibrDtDbl(codes: TCodes; P0FizValEdit, P0MeasValEdit, P1FizValEdit, P1MeasValEdit: TLabeledEdit);
    KalibrDtDbl([cd, cfgB_sKalibrLin], frm.L0FizValEdit, frm.L0MeasValEdit, frm.L1FizValEdit, frm.L1MeasValEdit);

    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_sKalibQuqlity]), nil);

    if cd = cfgA_SUSP_L then
      base := idxSuspendTabL
    else
      base := idxSuspendTabR;

    for i := 0 to 5 do
    begin
      mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_sKalibr, THostCfgCode(i + 1), cfgX_xValFiz]), MyCfgNotify, base + 0 + i);
      mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_sKalibr, THostCfgCode(i + 1), cfgX_xValMeas]), MyCfgNotify,
        base + 10 + i);
    end;

  end;

  procedure AddSlipSide(frm: TKpSlipsideCfgFrame; cd: THostCfgCode);
  begin
    // OK
    mRSett.AddItem(ckBool, KnvTab([cd, cfgB_pEnab]), frm.AktivBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_pTypPlyty]), frm.TypPlytyBox);

    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_pAnInutNr]), frm.AnInpBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_pPressNajazdNr]), frm.NajazdInpNrBox);
    mRSett.AddItem(ckByte, KnvTab([cd, cfgB_pPressZjazdNr]), frm.ZjazdInpNrBox);

    mRSett.AddItem(ckBool, KnvTab([cd, cfgB_pInvertNajazd]), frm.NajazdInvertBox);
    mRSett.AddItem(ckBool, KnvTab([cd, cfgB_pInvertZjazd]), frm.ZjazdInvertBox);
    KalibrDtDbl([cd, cfgB_pKalibr], frm.P0ValEdit, frm.P0KalibrEdit, frm.P1ValEdit, frm.P1KalibrEdit);

    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pMaxMeasTime]), frm.MaxMeasEdit);
    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pMinMeasTime]), frm.MinMeasEdit);
    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pDeActivTime]), frm.DeActivTimeEdit);

    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pMaxMeasFlip]), frm.MaxFlipEdit);
    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pMaxZeroShift]), frm.MaxStartShiftEdit);
    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pDeadZone]), frm.DeadBandEdit);
    mRSett.AddItem(ckFloat, KnvTab([cd, cfgB_pMaxFlipTime]), frm.MaxFlipTimeEdit);

  end;

  procedure AddWeight(frm: TKpWeightCfgFrame; cd: THostCfgCode);
    procedure AddWeightChn(cd1, cd2, cd3: THostCfgCode; AnInpBox: TComboBox; KorektaEdit: TLabeledEdit;
      ZeroEdit: TLabeledEdit);
    begin
      mRSett.AddItem(ckByte, KnvTab([cd1, cd2, cd3, cfgC_wAnInputNr]), AnInpBox);
      mRSett.AddItem(ckFloat, KnvTab([cd1, cd2, cd3, cfgC_wWspSkali]), KorektaEdit);
      mRSett.AddItem(ckWord, KnvTab([cd1, cd2, cd3, cfgC_wAnZero]), ZeroEdit);
    end;

  begin
    mRSett.AddItem(ckBool, KnvTab([cd, cfgB_wEnab]), frm.WagaAktivBox);
    addKalibrPoint([cd, cfgB_wKalibr], frm.WagaP1ValEdit, frm.WagaP1KalibrEdit);

    AddWeightChn(cd, cfgB_wChnKalibr, THostCfgCode(1), frm.WagaLPAnInpBox, frm.WagaLPKorektaEdit, frm.WagaLPZeroEdit);
    AddWeightChn(cd, cfgB_wChnKalibr, THostCfgCode(2), frm.WagaPPAnInpBox, frm.WagaPPKorektaEdit, frm.WagaPPZeroEdit);
    AddWeightChn(cd, cfgB_wChnKalibr, THostCfgCode(3), frm.WagaLTAnInpBox, frm.WagaLTKorektaEdit, frm.WagaLTZeroEdit);
    AddWeightChn(cd, cfgB_wChnKalibr, THostCfgCode(4), frm.WagaPTAnInpBox, frm.WagaPTKorektaEdit, frm.WagaPTZeroEdit);
  end;

var
  i: Integer;
begin
  inherited;
  BinAcGrid.Rows[0].CommaText := 'lp. "Tryb AC" "próg LOW[%]", "próg HIGH[%]"';
  BinAcGrid.Cols[0].CommaText := 'lp. 1 2 3 4 5 6 7 8';
  mUsageForm := nil;

  MyCfgNotify := TMyCfgNotify.create(self);
  // main
  mRSett.AddItem(ckString, KnvTab([cfgA_DEVID]), OwnNameEdit);
  mRSett.AddItem(ckIP, KnvTab([cfgA_TCP, cfgB_tIp]), NetIpEdit);
  mRSett.AddItem(ckIP, KnvTab([cfgA_TCP, cfgB_tMask]), NetMaskaEdit);
  mRSett.AddItem(ckIP, KnvTab([cfgA_TCP, cfgB_tGw]), NetBramaEdit);
  mRSett.AddItem(ckIP, KnvTab([cfgA_HostIP]), HostIpEdit);



  // Binary inputs
  for i := 0 to 7 do
  begin
    mRSett.AddItem(ckBool, KnvTab([cfgA_BIN_AC, cfgB_bChn, THostCfgCode(i + 1), cfgC_bEnab]), MyCfgNotify,
      idxBinInp + 0 + i);
    mRSett.AddItem(ckWord, KnvTab([cfgA_BIN_AC, cfgB_bChn, THostCfgCode(i + 1), cfgC_bLimitL]), MyCfgNotify,
      idxBinInp + 10 + i);
    mRSett.AddItem(ckWord, KnvTab([cfgA_BIN_AC, cfgB_bChn, THostCfgCode(i + 1), cfgC_bLimitH]), MyCfgNotify,
      idxBinInp + 20 + i);
  end;

  // breaks
  AddBreaks(LeftBreaksFrm, cfgA_BREAK_L);
  AddBreaks(RightBreaksFrm, cfgA_BREAK_R);
  // suspens
  AddSuspens(LeftSuspFrm, cfgA_SUSP_L);
  AddSuspens(RightSuspFrm, cfgA_SUSP_R);
  // SlipSide
  AddSlipSide(SlipSideFrm, cfgA_SLIPSIDE);
  // Weight
  AddWeight(LeftWeightFrm, cfgA_WEIGHT_L);
  AddWeight(RightWeightFrm, cfgA_WEIGHT_R);

end;

procedure TKPCfgForm.FormDestroy(Sender: TObject);
begin
  inherited;
  MyCfgNotify.Free;
end;

function TKPCfgForm.KnvTab(codes: TCodes): TBytes;
var
  n, i: Integer;
begin
  n := length(codes);
  setlength(Result, n);
  for i := 0 to n - 1 do
    Result[i] := ord(codes[i]);
end;

function TKPCfgForm.getDefaultExt: string;
begin
  Result := '.kpcfg';
end;

function TKPCfgForm.getFileFilter: string;
begin
  Result := 'Konfiguracja KP eLine|*.kpcfg|Wszystkie pliki|*.*';
end;

procedure TKPCfgForm.CheckButtonClick(Sender: TObject);
var
  q: boolean;
begin
  inherited;
  q := CheckCfg;
  if q then
    Application.MessageBox('Konfigracja poprawna', 'Konfiguracja KP', mb_OK);

end;

procedure TKPCfgForm.showService(service: TKPService.T);
begin
  case service of
    uuBREAK_L:
      begin
        MainPageControl.ActivePageIndex := 2;
        BreaksPageControl.ActivePageIndex := 0;
      end;

    uuBREAK_R:
      begin
        MainPageControl.ActivePageIndex := 2;
        BreaksPageControl.ActivePageIndex := 1;
      end;

    uuSUSP_L:
      begin
        MainPageControl.ActivePageIndex := 3;
        SuspensionPageControl.ActivePageIndex := 0;
      end;
    uuSUSP_R:
      begin
        MainPageControl.ActivePageIndex := 3;
        SuspensionPageControl.ActivePageIndex := 1;
      end;
    uuSLIP_SIDE:
      begin
        MainPageControl.ActivePageIndex := 4;
      end;
    uuWEIGHT_L:
      begin
        MainPageControl.ActivePageIndex := 5;
        WeightPageControl.ActivePageIndex := 0;
      end;
    uuWEIGHT_R:
      begin
        MainPageControl.ActivePageIndex := 5;
        WeightPageControl.ActivePageIndex := 1;
      end;
  end;

end;

procedure TKPCfgForm.UsageBtnClick(Sender: TObject);

var
  useTab: TAnBinUsageDlg.TUseTab;

  procedure InserRollDev(serv: TKPService.T; frm: TKpBreaksCfgFrame);
  begin
    if frm.AktivBox.Checked then
    begin
      useTab.DgUse[frm.PressBitBox.ItemIndex] := serv;
      useTab.DgUse[frm.SpeedBitBox.ItemIndex] := serv;
      useTab.AnUse[frm.AnInpNrBox.ItemIndex] := serv;
    end;
  end;

  procedure InserDamperDev(serv: TKPService.T; frm: TKpSuspensCfgFrame);
  begin
    if frm.AktivBox.Checked then
    begin
      useTab.AnUse[frm.AnInpBox.ItemIndex] := serv;
    end;
  end;

  procedure InserConvergenceDev(serv: TKPService.T; frm: TKpSlipsideCfgFrame);
  begin
    if frm.AktivBox.Checked then
    begin
      useTab.AnUse[frm.AnInpBox.ItemIndex] := serv;
      case frm.TypPlytyBox.ItemIndex of
        1:
          begin
            useTab.DgUse[frm.NajazdInpNrBox.ItemIndex] := serv;
          end;
        2:
          begin
            useTab.DgUse[frm.NajazdInpNrBox.ItemIndex] := serv;
            useTab.DgUse[frm.ZjazdInpNrBox.ItemIndex] := serv;
          end;
      end;
    end;
  end;

  procedure InserScaleDev(serv: TKPService.T; frm: TKpWeightCfgFrame);
  begin
    if frm.WagaAktivBox.Checked then
    begin
      useTab.AnUse[frm.WagaLPAnInpBox.ItemIndex] := serv;
      useTab.AnUse[frm.WagaPPAnInpBox.ItemIndex] := serv;
      useTab.AnUse[frm.WagaLTAnInpBox.ItemIndex] := serv;
      useTab.AnUse[frm.WagaPTAnInpBox.ItemIndex] := serv;
    end;
  end;

var

  i: Integer;
  Fnd: boolean;
begin
  inherited;

  useTab.clear;

  InserRollDev(uuBREAK_L, LeftBreaksFrm);
  InserRollDev(uuBREAK_R, RightBreaksFrm);

  InserDamperDev(uuSUSP_L, LeftSuspFrm);
  InserDamperDev(uuSUSP_R, RightSuspFrm);
  InserConvergenceDev(uuSLIP_SIDE, SlipSideFrm);
  InserScaleDev(uuWEIGHT_L, LeftWeightFrm);
  InserScaleDev(uuWEIGHT_R, RightWeightFrm);

  Fnd := false;
  for i := 0 to Application.MainForm.MDIChildCount - 1 do
  begin
    if Application.MainForm.MDIChildren[i] = mUsageForm then
    begin
      Fnd := true;
      break;
    end;
  end;
  if not(Fnd) then
  begin
    mUsageForm := TAnBinUsageDlg.create(self);
    mUsageForm.show;
  end
  else
  begin
    mUsageForm.BringToFront;
  end;

  mUsageForm.setTab(useTab);

end;

function TKPCfgForm.CheckCfg: boolean;
var
  AnUse: array [0 .. 7] of byte;
  DgUse: array [0 .. 7] of byte;

  procedure InserRollDev(frm: TKpBreaksCfgFrame);
  begin
    if frm.AktivBox.Checked then
    begin
      inc(DgUse[frm.PressBitBox.ItemIndex]);
      inc(DgUse[frm.SpeedBitBox.ItemIndex]);
      inc(AnUse[frm.AnInpNrBox.ItemIndex]);
    end;
  end;

  procedure InserDamperDev(frm: TKpSuspensCfgFrame);
  begin
    if frm.AktivBox.Checked then
    begin
      inc(AnUse[frm.AnInpBox.ItemIndex]);
    end;
  end;

  procedure InserConvergenceDev(frm: TKpSlipsideCfgFrame);
  begin
    if frm.AktivBox.Checked then
    begin
      inc(AnUse[frm.AnInpBox.ItemIndex]);
      case frm.TypPlytyBox.ItemIndex of
        1:
          begin
            inc(DgUse[frm.NajazdInpNrBox.ItemIndex]);
          end;
        2:
          begin
            inc(DgUse[frm.NajazdInpNrBox.ItemIndex]);
            inc(DgUse[frm.ZjazdInpNrBox.ItemIndex]);
          end;
      end;

    end;
  end;

  procedure InserScaleDev(frm: TKpWeightCfgFrame);
  begin
    if frm.WagaAktivBox.Checked then
    begin
      inc(AnUse[frm.WagaLPAnInpBox.ItemIndex]);
      inc(AnUse[frm.WagaPPAnInpBox.ItemIndex]);
      inc(AnUse[frm.WagaLTAnInpBox.ItemIndex]);
      inc(AnUse[frm.WagaPTAnInpBox.ItemIndex]);
    end;
  end;

  function CheckBinAsAc: boolean;
  type
    TBinAn = record
      asAC: boolean;
      LewL: single;
      LewH: single;
    end;
  var
    i: Integer;
    s: string;
    binTab: array [0 .. 7] of TBinAn;
  begin
    Result := true;
    for i := 0 to 7 do
    begin
      binTab[i].asAC := getTakNieStr(BinAcGrid.Cells[1, i + 1]);
      binTab[i].LewL := StrToFloatZero(BinAcGrid.Cells[2, i + 1]);
      binTab[i].LewH := StrToFloatZero(BinAcGrid.Cells[3, i + 1]);
    end;

    for i := 0 to 7 do
      if binTab[i].asAC then
      begin
        if binTab[i].LewL > 100 then
        begin
          Result := false;
          s := 'Wejscie nr' + ' ' + IntToStr(i + 1) + '. LOW > 100%';
          Application.MessageBox(pchar(s), pchar('Konfiguracja wejœæ bianrnych'), mb_OK);
          // 'Kalibracja wejœæ binarnych'
        end;

        if binTab[i].LewH > 100 then
        begin
          Result := false;
          s := 'Wejscie nr' + ' ' + IntToStr(i + 1) + '. HIGH > 100%';
          Application.MessageBox(pchar(s), pchar('Konfiguracja wejœæ bianrnych'), mb_OK);
          break;
        end;

        if binTab[i].LewH <= binTab[i].LewL then
        begin
          Result := false;
          s := 'Wejscie nr' + ' ' + IntToStr(i + 1) + '. HIGH < LOW';
          Application.MessageBox(pchar(s), pchar('Konfiguracja wejœæ bianrnych'), mb_OK);
          break;
        end;
      end;
  end;

  function CheckDamperKalibrTab(Name: string; frm: TKpSuspensCfgFrame): boolean;
  type
    TSKalibr = record
      valid: boolean;
      valFiz: single;
      valPom: single;
    end;

    function PtUp(const prev: TSKalibr; const curr: TSKalibr): boolean;
    begin
      Result := (prev.valFiz < curr.valFiz) and (prev.valPom < curr.valFiz);
    end;

  var
    i: Integer;
    tab: array [0 .. AMOR_KALIBR_CNT - 1] of TSKalibr;
    m, pr: double;
    q: boolean;
  begin
    for i := 0 to AMOR_KALIBR_CNT - 1 do
    begin
      q := tryStrToFloat(frm.PGrid.Cells[1, 1 + i], m);
      q := q and tryStrToFloat(frm.PGrid.Cells[2, 1 + i], pr);
      if (m = 0) and (pr = 0) and (i <> 0) then
        q := false;
      tab[i].valid := q;
      tab[i].valFiz := m;
      tab[i].valPom := pr;
    end;

    Result := true;
    for i := 0 to AMOR_KALIBR_CNT - 1 do
    begin
      case i of
        0, 1:
          begin
            if tab[i].valid = false then
            begin
              Result := false;
              Application.MessageBox(pchar('Kalibracja wagi, punkt musi byæ okreœlony P' + IntToStr(i + 1)),
                pchar('Amortyzator' + ' ' + Name), mb_OK);
              break;
            end;
          end;
      else
        begin
          if tab[i].valid and not(PtUp(tab[i - 1], tab[i])) then
          begin
            Result := false;
            Application.MessageBox(pchar('Kalibracja wagi, kolejny punkt musi byæ wiêkszy od poprzedniego'),
              pchar('Amortyzator' + ' ' + Name), mb_OK);
            break;
          end;
          if tab[i].valid and not(tab[i - 1].valid) then
          begin
            Result := false;
            Application.MessageBox(pchar('Kalibracja wagi, tabliaca nie mo¿e mieæ przerw'),
              pchar('Amortyzator' + ' ' + Name), mb_OK);
            break;
          end;
        end;
      end;
    end;
  end;

var
  i: Integer;
  s: string;
begin
  for i := 0 to 7 do
  begin
    AnUse[i] := 0;
    DgUse[i] := 0;
  end;

  InserRollDev(LeftBreaksFrm);
  InserRollDev(RightBreaksFrm);

  InserDamperDev(LeftSuspFrm);
  InserDamperDev(RightSuspFrm);
  InserConvergenceDev(SlipSideFrm);
  InserScaleDev(LeftWeightFrm);
  InserScaleDev(RightWeightFrm);

  Result := true;
  for i := 0 to 7 do
  begin
    if AnUse[i] > 1 then
    begin
      Result := false;
      s := Format('%s AN%u %s.', ['Wejscie', i + 1, 'U¿yte wiêcej ni¿ jeden raz']);
      Application.MessageBox(pchar(s), pchar('Konfiguracja'), mb_OK);
      break;
    end;
    if DgUse[i] > 1 then
    begin
      Result := false;
      s := Format('%s DG%u %s.', ['Wejscie', i + 1, 'U¿yte wiêcej ni¿ jeden raz']);
      Application.MessageBox(pchar(s), pchar('Konfiguracja'), mb_OK);
      break;
    end;
  end;
  Result := Result and CheckDamperKalibrTab('Lewy', LeftSuspFrm);
  Result := Result and CheckDamperKalibrTab('Prawy', RightSuspFrm);
  Result := Result and CheckBinAsAc;
end;

end.
