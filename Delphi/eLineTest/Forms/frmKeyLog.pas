unit frmKeyLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  MMSystem,
  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition, Vcl.Grids, Vcl.ValEdit;

type
  TKeyLogform = class(TBaseELineForm)
    VL: TValueListEditor;
    Grid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure VLDblClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
  private

  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure BringUp; override;
    procedure RecivedObj(obj: TKobj); override;
  end;

implementation

{$R *.dfm}

procedure TKeyLogform.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  Caption := 'KeyLog:' + mELineDev.getCpxName;
  BringUp;
end;

procedure TKeyLogform.VLDblClick(Sender: TObject);
begin
  inherited;
  BringUp;
end;

procedure TKeyLogform.GridDblClick(Sender: TObject);
begin
  inherited;
  BringUp;
end;

procedure TKeyLogform.BringUp;
var
  i: integer;
begin
  mELineDev.addReqest(dsdHOST, ord(msgRdKeyLog));
  VL.Strings.Clear;
  for i := 0 to KEYLOG_MAX_PACK_NR - 1 do
  begin
    Grid.Rows[i + 1].CommaText := IntToStr(i + 1);
  end;
end;

procedure TKeyLogform.FormShow(Sender: TObject);
begin
  inherited;
  Grid.Rows[0].CommaText := 'lp. Nazwa Stan Licznik "Data wa¿noœci"';
end;

procedure TKeyLogform.RecivedObj(obj: TKobj);
var
  data: TKKeyLogData;
  n1, n2: integer;
  i: integer;
  txt: string;
begin
  if (obj.srcDev = dsdHOST) and (obj.obCode = ord(msgRdKeyLog)) then
  begin

    n1 := length(obj.data);
    n2 := sizeof(data);
    if n1 = n2 then
    begin
      move(obj.data[0], data, n2);
      VL.Values['Firmware'] := Format('%u.%.3u', [data.info.ver, data.info.rev]);
      VL.Values['Iloœæ pakietów'] := Format('%u', [data.info.PacketCnt]);
      VL.Values['Wersja danych'] := Format('%u', [data.info.KeyLogInfo.Version]);
      VL.Values['Numer seryjny'] := Format('%u', [data.info.KeyLogInfo.SerNumber]);
      VL.Values['Data konfiguracji'] := data.info.KeyLogInfo.getKonfigurationDateAsStr;
      Grid.RowCount := KEYLOG_MAX_PACK_NR + 1;
      for i := 0 to KEYLOG_MAX_PACK_NR - 1 do
      begin
        Grid.Rows[i + 1].CommaText := IntToStr(i + 1);
        txt := '';
        case i of
          0:
            txt := 'Wspom';
          1:
            txt := 'Kier.kó³';
          2:
            txt := '4x4';
          3:
            txt := 'Urz.zewnêtrzne';
          4:
            txt := 'Waga';
        end;
        Grid.Cells[1, i + 1] := txt;

        case data.tab[i].Mode of
          ord(kmdON):
            begin
              Grid.Cells[2, i + 1] := 'ON';
            end;
          ord(kmdDEMO):
            begin
              Grid.Cells[2, i + 1] := 'DEMO';
              Grid.Cells[3, i + 1] := IntToStr(data.tab[i].ValidCnt);
              Grid.Cells[4, i + 1] := data.tab[i].getValidDateAsStr;

            end;

        else
          Grid.Cells[2, i + 1] := '---';
        end;
      end;
    end;
  end;
end;

end.
