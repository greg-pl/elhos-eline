unit dlgAnBinUsage;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Grids,
  elinedef;

type

  TAnBinUsageDlg = class(TForm)
    UGrid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public type
    TUseTab = record
      AnUse: array [0 .. 7] of TKPService.T;
      DgUse: array [0 .. 7] of TKPService.T;
      procedure clear;
    end;

  procedure setTab(tab: TUseTab);
  end;

implementation

{$R *.dfm}

procedure TAnBinUsageDlg.TUseTab.clear;
var
  i: integer;
begin
  for i := 0 to 7 do
  begin
    AnUse[i] := TKPService.T(-1);
    DgUse[i] := TKPService.T(-1);
  end;
end;

procedure TAnBinUsageDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TAnBinUsageDlg.FormCreate(Sender: TObject);
begin
  UGrid.Rows[0].CommaText := 'nr AN BIN';
  UGrid.Cols[0].CommaText := 'nr 1 2 3 4 5 6 7 8';

end;

procedure TAnBinUsageDlg.setTab(tab: TUseTab);
var
  i: integer;
  s: string;
begin
  for i := 0 to 7 do
  begin
    s := '';
    if TKPService.isOK(tab.AnUse[i]) then
      s := TKPService.getServName(tab.AnUse[i]);
    UGrid.Cells[1, i + 1] := s;

    s := '';
    if TKPService.isOK(tab.DgUse[i]) then
      s := TKPService.getServName(tab.DgUse[i]);
    UGrid.Cells[2, i + 1] := s;

  end;
end;

end.
