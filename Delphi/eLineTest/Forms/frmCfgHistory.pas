unit frmCfgHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids,
  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition;

type
  TCfgHistoryForm = class(TBaseELineForm)
    SGrid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure SGridDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}

procedure TCfgHistoryForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  caption := 'CfgHistory:' + mELineDev.getCpxName;
  BringUp;
end;

procedure TCfgHistoryForm.SGridDblClick(Sender: TObject);
begin
  BringUp;
end;

procedure TCfgHistoryForm.BringUp;
var
  i: integer;
begin
  inherited;
  for i := 0 to CFG_HIST_CNT - 1 do
  begin
    SGrid.Rows[i + 1].CommaText := IntToStr(i + 1);
  end;
  mELineDev.addReqest(dsdDEV_COMMON, ord(msgGetCfgHistory));
end;

procedure TCfgHistoryForm.FormShow(Sender: TObject);
begin
  inherited;
  SGrid.Rows[0].CommaText := 'lp ID Data "Numer klucza"';
end;

procedure TCfgHistoryForm.RecivedObj(obj: TKobj);
var
  History: TKHistoryRec;
  i: integer;
  idx: integer;
  vCnt: integer;
begin
  if (obj.srcDev = dsdDEV_COMMON) and (obj.obCode = ord(msgGetCfgHistory)) then
  begin
    move(obj.data[0], History, SizeOf(History));
    idx := History.getNewest;
    vCnt := 0;
    for i := 0 to CFG_HIST_CNT - 1 do
    begin
      SGrid.Rows[i + 1].CommaText := IntToStr(i + 1);
      if History.tab[idx].isValid then
      begin
        SGrid.Cells[1, i + 1] := IntToStr(History.tab[idx].ID);
        SGrid.Cells[2, i + 1] := History.tab[idx].getDateAsStr;
        SGrid.Cells[3, i + 1] := IntToStr(History.tab[idx].keySrvNr);
        inc(vCnt);
      end;
      if idx = 0 then
        idx := CFG_HIST_CNT;
      dec(idx);
    end;
    if vCnt = 0 then
      Application.MessageBox('Histora jest pusta', 'Histora zmian CFG', MB_OK);

  end;

end;

end.
