inherited CfgHistoryForm: TCfgHistoryForm
  Caption = 'CfgHistoryForm'
  ClientHeight = 288
  OnShow = FormShow
  ExplicitHeight = 327
  PixelsPerInch = 96
  TextHeight = 13
  object SGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 582
    Height = 288
    Align = alClient
    ColCount = 4
    DefaultColWidth = 30
    DefaultRowHeight = 20
    RowCount = 33
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ParentFont = False
    TabOrder = 0
    OnDblClick = SGridDblClick
    ColWidths = (
      30
      81
      141
      163)
  end
end
