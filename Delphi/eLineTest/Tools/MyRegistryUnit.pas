unit MyRegistryUnit;

interface

uses
  SysUtils, Windows, Registry, Forms, Classes,
  Vcl.Grids;

type

  TMyRegistry = class(TRegistry)
    function ReadBool(ValName: string): boolean;
    function ReadInteger(ValName: string): integer;
    function ReadString(ValName: string): string;
    function ReadFloat(ValName: string): Extended;

    function ReadBoolDef(ValName: string; Default: boolean): boolean;
    function ReadIntegerDef(ValName: string; Default: integer): integer;
    function ReadStringDef(ValName: string; Default: string): string;
    function ReadFloatDef(ValName: string; Default: Extended): Extended;

    procedure SaveFormRect(form: TForm);
    procedure LoadFormRect(form: TForm);
    procedure SaveGridColWidth(Grid: TStringGrid);
    procedure LoadGridColWidth(Grid: TStringGrid);

  end;

implementation

function TMyRegistry.ReadBool(ValName: string): boolean;
begin
  if ValueExists(ValName) then
    Result := inherited ReadBool(ValName)
  else
    Result := false;
end;

function TMyRegistry.ReadInteger(ValName: string): integer;
begin
  if ValueExists(ValName) then
    Result := inherited ReadInteger(ValName)
  else
    Result := 0;
end;

function TMyRegistry.ReadString(ValName: string): string;
begin
  if ValueExists(ValName) then
    Result := inherited ReadString(ValName)
  else
    Result := '';
end;

function TMyRegistry.ReadFloat(ValName: string): Extended;
begin
  if ValueExists(ValName) then
    Result := inherited ReadFloat(ValName)
  else
    Result := 0.0;
end;

function TMyRegistry.ReadBoolDef(ValName: string; Default: boolean): boolean;
begin
  if ValueExists(ValName) then
    Result := ReadBool(ValName)
  else
    Result := Default;
end;

function TMyRegistry.ReadIntegerDef(ValName: string; Default: integer): integer;
begin
  if ValueExists(ValName) then
    Result := ReadInteger(ValName)
  else
    Result := Default;
end;

function TMyRegistry.ReadStringDef(ValName: string; Default: string): string;
begin
  if ValueExists(ValName) then
    Result := ReadString(ValName)
  else
    Result := Default;
end;

function TMyRegistry.ReadFloatDef(ValName: string; Default: Extended): Extended;
begin
  if ValueExists(ValName) then
    Result := ReadFloat(ValName)
  else
    Result := Default;
end;

procedure TMyRegistry.SaveFormRect(form: TForm);
begin
  WriteInteger('Left', form.Left);
  WriteInteger('Top', form.Top);
  WriteInteger('Width', form.Width);
  WriteInteger('Height', form.Height);
end;

procedure TMyRegistry.LoadFormRect(form: TForm);
begin
  form.Left := ReadIntegerDef('Left', form.Left);
  form.Top := ReadIntegerDef('Top', form.Top);
  form.Width := ReadIntegerDef('Width', form.Width);
  form.Height := ReadIntegerDef('Height', form.Height);

end;

procedure TMyRegistry.SaveGridColWidth(Grid: TStringGrid);
var
  i: integer;
  SL: TStringList;

begin
  SL := TStringList.Create;
  try
    for i := 0 to Grid.ColCount - 1 do
    begin
      SL.Add(IntToStr(Grid.ColWidths[i]));
    end;
    WriteString(Grid.Name + '_ColW', SL.CommaText);
  finally
    SL.Free;
  end;
end;

procedure TMyRegistry.LoadGridColWidth(Grid: TStringGrid);
var
  i: integer;
  SL: TStringList;
  n: integer;
  dx: integer;

begin
  SL := TStringList.Create;
  try
    try
      SL.CommaText := ReadString(Grid.Name + '_ColW');
      n := Grid.ColCount;
      if SL.Count < n then
        n := SL.Count;
      for i := 0 to n - 1 do
      begin
        if tryStrToInt(SL.Strings[i], dx) then
        begin
          if dx < 10 then
            dx := 10;
          Grid.ColWidths[i] := dx;
        end;
      end;
    except

    end;
  finally
    SL.Free;
  end;
end;

end.
