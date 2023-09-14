inherited KeyLogform: TKeyLogform
  Caption = 'KeyLogform'
  ClientHeight = 450
  OnShow = FormShow
  ExplicitHeight = 489
  PixelsPerInch = 96
  TextHeight = 13
  object VL: TValueListEditor
    Left = 0
    Top = 0
    Width = 582
    Height = 137
    Align = alTop
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
    ParentFont = False
    TabOrder = 0
    OnDblClick = VLDblClick
    ColWidths = (
      150
      426)
  end
  object Grid: TStringGrid
    Left = 0
    Top = 137
    Width = 582
    Height = 313
    Align = alClient
    DefaultColWidth = 30
    DefaultRowHeight = 20
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
    ParentFont = False
    TabOrder = 1
    OnDblClick = GridDblClick
    ColWidths = (
      30
      147
      65
      93
      163)
  end
end
