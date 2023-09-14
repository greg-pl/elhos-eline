unit frameHostFalownik;

interface

uses
  System.UITypes, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  THostFalownikFrame = class;

  TOnClickFalNotify = procedure(Sender: THostFalownikFrame; Fun: integer) of object;

  THostFalownikFrame = class(TFrame)
    Button1: TButton;
    NameLab: TLabel;
    BckPanel: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ActShape: TShape;
    Timer1: TTimer;
    StatusText: TLabeledEdit;
    Button7: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ackFlag: boolean;
    sendTick: cardinal;
  public
    OnClickFal: TOnClickFalNotify;
    procedure AckCommand(cmd : byte; status : byte);
  end;

implementation

{$R *.dfm}

uses
  eLineDef;

procedure THostFalownikFrame.Button1Click(Sender: TObject);
begin
  if Assigned(OnClickFal) then
    OnClickFal(self, (Sender as TButton).Tag);
  ActShape.Brush.Color := TColorRec.Pink;
  ackFlag := false;
  sendTick := gettickcount;
  Timer1.Interval := 4000;
  Timer1.Enabled := true;
  StatusText.Text := '';
end;

procedure THostFalownikFrame.AckCommand(cmd : byte; status : byte);
begin
  ackFlag := true;
  StatusText.Text := TKStatus.getTxt(status);

  if gettickcount - sendTick > 100 then
  begin
    ActShape.Brush.Color := TColorRec.Gray;

  end
  else
  begin
    Timer1.Interval := 100;
    Timer1.Enabled := true;
  end;

end;

procedure THostFalownikFrame.Timer1Timer(Sender: TObject);
begin
  if ackFlag then
    ActShape.Brush.Color := TColorRec.Gray
  else
  begin
    ActShape.Brush.Color := TColorRec.Red;
    StatusText.Text := 'TIME_OUT';
  end;
  Timer1.Enabled := false;

end;

end.
