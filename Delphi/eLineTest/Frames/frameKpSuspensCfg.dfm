object KpSuspensCfgFrame: TKpSuspensCfgFrame
  Left = 0
  Top = 0
  Width = 666
  Height = 541
  TabOrder = 0
  object Label4: TLabel
    Left = 16
    Top = 35
    Width = 98
    Height = 13
    Caption = 'Pod'#322#261'czenie czujnika'
  end
  object Label8: TLabel
    Left = 16
    Top = 162
    Width = 74
    Height = 13
    Caption = 'Kalibracja masy'
  end
  object AmorKalibrInfoText: TLabel
    Left = 16
    Top = 304
    Width = 233
    Height = 13
    AutoSize = False
    Caption = '...'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object AktivBox: TCheckBox
    Left = 16
    Top = 11
    Width = 97
    Height = 17
    Caption = 'Aktywny'
    TabOrder = 0
  end
  object AnInpBox: TComboBox
    Tag = -1
    Left = 16
    Top = 51
    Width = 57
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'AN1'
    Items.Strings = (
      'AN1'
      'AN2'
      'AN3'
      'AN4'
      'AN5'
      'AN6'
      'AN7'
      'AN8')
  end
  object DeadBandEdit: TLabeledEdit
    Left = 16
    Top = 91
    Width = 81
    Height = 21
    EditLabel.Width = 99
    EditLabel.Height = 13
    EditLabel.Caption = 'Strefa martwa [daN]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object GroupBox5: TGroupBox
    Left = 176
    Top = 3
    Width = 257
    Height = 113
    Caption = 'Kalibracja wychylenia'
    TabOrder = 5
    object L0MeasValEdit: TLabeledEdit
      Left = 8
      Top = 80
      Width = 113
      Height = 21
      EditLabel.Width = 112
      EditLabel.Height = 13
      EditLabel.Caption = 'Kalibracja punkt L0 [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object L0FizValEdit: TLabeledEdit
      Left = 8
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 108
      EditLabel.Height = 13
      EditLabel.Caption = 'Podaj wychyl. L0 [mm]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object L1MeasValEdit: TLabeledEdit
      Left = 128
      Top = 80
      Width = 113
      Height = 21
      EditLabel.Width = 112
      EditLabel.Height = 13
      EditLabel.Caption = 'Kalibracja punkt L1 [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object L1FizValEdit: TLabeledEdit
      Left = 128
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 108
      EditLabel.Height = 13
      EditLabel.Caption = 'Podaj wychyl. L1 [mm]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
  object PGrid: TStringGrid
    Left = 11
    Top = 176
    Width = 209
    Height = 145
    ColCount = 3
    DefaultColWidth = 20
    DefaultRowHeight = 18
    RowCount = 7
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 4
    OnSetEditText = PGridSetEditText
    ColWidths = (
      20
      88
      91)
  end
  object Chart: TChart
    Left = 232
    Top = 151
    Width = 208
    Height = 194
    BackWall.Brush.Style = bsClear
    Legend.Visible = False
    MarginRight = 10
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    Title.AdjustFrame = False
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Maximum = 1000.000000000000000000
    BottomAxis.Title.Caption = 'Masa [kg]'
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Maximum = 100.000000000000000000
    LeftAxis.Title.Caption = 'pomiar [%]'
    View3D = False
    View3DWalls = False
    BevelOuter = bvNone
    TabOrder = 7
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
    object Series1: TLineSeries
      SeriesColor = clRed
      Title = 'AmrSeries'
      Brush.BackColor = clDefault
      Pointer.HorizSize = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.VertSize = 2
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object LiczP1Btn: TButton
    Left = 360
    Top = 123
    Width = 75
    Height = 25
    Caption = 'Wylicz P1/L1'
    TabOrder = 6
    OnClick = LiczP1BtnClick
  end
  object ReturnTimeEdit: TLabeledEdit
    Left = 16
    Top = 135
    Width = 81
    Height = 21
    EditLabel.Width = 205
    EditLabel.Height = 13
    EditLabel.Caption = 'Czas powrotu do stanu nieaktywnego [ms]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
end
