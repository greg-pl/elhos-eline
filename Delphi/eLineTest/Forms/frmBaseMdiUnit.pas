unit frmBaseMdiUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TBaseMdiForm = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  protected
    procedure MainFormMsgOut(txt: string);
  public
    { Public declarations }
  end;

  TBaseMdiFormClass = class of TBaseMdiForm;

function findMdiForm(aClass: TBaseMdiFormClass): TBaseMdiForm;
function ExecMdiForm(ParenForm: TForm; aClass: TBaseMdiFormClass): TBaseMdiForm;

implementation

{$R *.dfm}

uses
  Main;

function findMdiForm(aClass: TBaseMdiFormClass): TBaseMdiForm;
var
  i: integer;
  Form: TForm;
begin
  result := nil;
  for i := 0 to Application.MainForm.MDIChildCount - 1 do
  begin
    Form := Application.MainForm.MDIChildren[i];
    if Form is aClass then
    begin
      result := Form as TBaseMdiForm;
      break;
    end;
  end;
end;

function ExecMdiForm(ParenForm: TForm; aClass: TBaseMdiFormClass): TBaseMdiForm;
var
  Form: TBaseMdiForm;
begin
  Form := findMdiForm(aClass);
  if Assigned(Form) then
    Form.BringToFront
  else
  begin
    Form := aClass.Create(ParenForm);
    Form.Show;
  end;
  result := Form;
end;

procedure TBaseMdiForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TBaseMdiForm.MainFormMsgOut(txt: string);
begin
  MainForm.Wr(txt);
end;

end.
