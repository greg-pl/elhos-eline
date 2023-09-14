unit frmHostTestHdw;

interface

uses
  System.UITypes, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.StdCtrls,

  frmBaseELineUnit,
  BaseDevCmmUnit,
  eLineDef,
  CmmObjDefinition,
  HostDevUnit;

type
  THostTestHdwForm = class(TBaseELineForm)
    Panel1: TPanel;

    Pk1Button: TSpeedButton;
    Pk2Button: TSpeedButton;
    Pk3Button: TSpeedButton;
    Pk4Button: TSpeedButton;
    Pk5Button: TSpeedButton;
    Pk6Button: TSpeedButton;
    Pk7Button: TSpeedButton;
    Pk8Button: TSpeedButton;

    Pk1Shape: TShape;
    Pk2Shape: TShape;
    Pk3Shape: TShape;
    Pk4Shape: TShape;
    Pk5Shape: TShape;
    Pk6Shape: TShape;
    Pk7Shape: TShape;
    Pk8Shape: TShape;
    Panel2: TPanel;
    BeepBtn: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Panel3: TPanel;
    Inp1Shape: TShape;
    Label1: TLabel;
    Inp2Shape: TShape;
    Label2: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure Pk1ButtonClick(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure BeepBtnClick(Sender: TObject);
  private type
    TPkRec = record
      btn: TSpeedButton;
      Sh: TShape;
    end;
  private const
    PK_CNT = 8;
    function findPk(btn: TObject): integer;

  private
    pkTab: array [0 .. PK_CNT - 1] of TPkRec;
    function hostDev: THostDev;
  public
    procedure setELineDev(aDev: TBaseELineDev); override;
    procedure RecivedObj(obj: TKobj); override;
    procedure BringUp; override;
  end;

implementation

{$R *.dfm}

procedure THostTestHdwForm.FormCreate(Sender: TObject);
begin
  inherited;
  pkTab[0].btn := Pk1Button;
  pkTab[1].btn := Pk2Button;
  pkTab[2].btn := Pk3Button;
  pkTab[3].btn := Pk4Button;
  pkTab[4].btn := Pk5Button;
  pkTab[5].btn := Pk6Button;
  pkTab[6].btn := Pk7Button;
  pkTab[7].btn := Pk8Button;

  pkTab[0].Sh := Pk1Shape;
  pkTab[1].Sh := Pk2Shape;
  pkTab[2].Sh := Pk3Shape;
  pkTab[3].Sh := Pk4Shape;
  pkTab[4].Sh := Pk5Shape;
  pkTab[5].Sh := Pk6Shape;
  pkTab[6].Sh := Pk7Shape;
  pkTab[7].Sh := Pk8Shape;

end;

function THostTestHdwForm.hostDev: THostDev;
begin
  result := mELineDev as THostDev;
end;

procedure THostTestHdwForm.setELineDev(aDev: TBaseELineDev);
begin
  inherited;
  caption := 'HosTest :' + mELineDev.getCpxName;
  BringUp;
end;

procedure THostTestHdwForm.BeepBtnClick(Sender: TObject);
begin
  inherited;
  hostDev.sendBeep((Sender as TButton).Tag);
end;

procedure THostTestHdwForm.BringUp;
begin
  inherited;
  hostDev.reqPK;
end;

procedure THostTestHdwForm.RecivedObj(obj: TKobj);
  procedure SetShapeColor(Sh: TShape; q: boolean);
  begin
    if q then
      Sh.Brush.Color := TColorRec.Lime
    else
      Sh.Brush.Color := TColorRec.Gray;
  end;

  procedure SetPkState(pknr: integer; q: boolean);
  begin
    if q then
      pkTab[pknr].Sh.Brush.Color := TColorRec.Lime
    else
      pkTab[pknr].Sh.Brush.Color := TColorRec.Gray;
  end;

var
  pknr: integer;
  q: boolean;
  i: integer;
  b: byte;
begin
  if (obj.srcDev = dsdHOST) then
  begin
    case obj.obCode of

      ord(msgHostGetOut):
        begin
          // satn wszystkich przekaŸników
          b := obj.data[0];
          for i := 0 to PK_CNT - 1 do
          begin
            q := ((b and (1 shl i)) <> 0);
            SetPkState(i, q);
            pkTab[i].btn.Down := q;
          end;
        end;
      ord(msgHostSetOut):
        begin
          // potwierdzenie wykonania operaci
          pknr := obj.data[0];
          q := obj.data[1] <> 0;
          SetPkState(pknr, q);

        end;
      ord(msgHostInpState):
        begin
          // stan wejœci INP1, INP2
          b := obj.data[0];
          SetShapeColor(Inp1Shape, ((b and $01) <> 0));
          SetShapeColor(Inp2Shape, ((b and $02) <> 0));
        end;
    end;
  end;
end;

procedure THostTestHdwForm.Panel1DblClick(Sender: TObject);
begin
  inherited;
  hostDev.sendReqPK;
end;

procedure THostTestHdwForm.Pk1ButtonClick(Sender: TObject);
var
  idx: integer;
  q: boolean;
begin
  inherited;
  idx := findPk(Sender);
  if idx >= 0 then
  begin
    pkTab[idx].Sh.Brush.Color := TColorRec.Pink;
    q := (Sender as TSpeedButton).Down;
    hostDev.sendPK(idx, q);
  end;
end;

function THostTestHdwForm.findPk(btn: TObject): integer;
var
  i: integer;
begin
  result := -1;
  for i := 0 to PK_CNT - 1 do
  begin
    if pkTab[i].btn = btn then
    begin
      result := i;
      break;
    end;
  end;
end;

end.
