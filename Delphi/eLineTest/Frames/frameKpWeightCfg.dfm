object KpWeightCfgFrame: TKpWeightCfgFrame
  Left = 0
  Top = 0
  Width = 464
  Height = 389
  TabOrder = 0
  object PaintBox1: TPaintBox
    Left = 8
    Top = 34
    Width = 162
    Height = 155
    OnMouseDown = PaintBoxMouseDown
    OnPaint = PaintBoxPaint
  end
  object WagaAktivBox: TCheckBox
    Left = 16
    Top = 11
    Width = 97
    Height = 17
    Caption = 'Aktywny'
    TabOrder = 0
  end
  object PT_Panel: TPanel
    Left = 304
    Top = 139
    Width = 121
    Height = 129
    TabOrder = 5
    object Label10: TLabel
      Left = 8
      Top = 8
      Width = 68
      Height = 13
      Caption = 'PT - Prawy ty'#322
    end
    object WagaPTKorektaEdit: TLabeledEdit
      Left = 8
      Top = 60
      Width = 89
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'Korekta'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
    object WagaPTAnInpBox: TComboBox
      Tag = -1
      Left = 8
      Top = 24
      Width = 57
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
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
    object WagaPTZeroEdit: TLabeledEdit
      Left = 8
      Top = 100
      Width = 89
      Height = 21
      EditLabel.Width = 44
      EditLabel.Height = 13
      EditLabel.Caption = 'Zero [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
  end
  object LT_Panel: TPanel
    Left = 176
    Top = 139
    Width = 121
    Height = 129
    TabOrder = 4
    object Label12: TLabel
      Left = 8
      Top = 8
      Width = 62
      Height = 13
      Caption = 'LT - Lewy ty'#322
    end
    object WagaLTKorektaEdit: TLabeledEdit
      Left = 8
      Top = 60
      Width = 89
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'Korekta'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
    object WagaLTAnInpBox: TComboBox
      Tag = -1
      Left = 8
      Top = 24
      Width = 57
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
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
    object WagaLTZeroEdit: TLabeledEdit
      Left = 8
      Top = 100
      Width = 89
      Height = 21
      EditLabel.Width = 44
      EditLabel.Height = 13
      EditLabel.Caption = 'Zero [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
  end
  object PP_Panel: TPanel
    Left = 304
    Top = 3
    Width = 121
    Height = 129
    TabOrder = 3
    object Label9: TLabel
      Left = 8
      Top = 8
      Width = 82
      Height = 13
      Caption = 'PP - Prawy prz'#243'd'
    end
    object WagaPPKorektaEdit: TLabeledEdit
      Left = 8
      Top = 60
      Width = 89
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'Korekta'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
    object WagaPPAnInpBox: TComboBox
      Tag = -1
      Left = 8
      Top = 24
      Width = 57
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
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
    object WagaPPZeroEdit: TLabeledEdit
      Left = 8
      Top = 100
      Width = 89
      Height = 21
      EditLabel.Width = 44
      EditLabel.Height = 13
      EditLabel.Caption = 'Zero [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
  end
  object LP_Panel: TPanel
    Left = 177
    Top = 3
    Width = 121
    Height = 129
    TabOrder = 2
    object Label14: TLabel
      Left = 8
      Top = 8
      Width = 76
      Height = 13
      Caption = 'LP - Lewy prz'#243'd'
    end
    object WagaLPKorektaEdit: TLabeledEdit
      Left = 8
      Top = 60
      Width = 89
      Height = 21
      EditLabel.Width = 37
      EditLabel.Height = 13
      EditLabel.Caption = 'Korekta'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
    object WagaLPAnInpBox: TComboBox
      Tag = -1
      Left = 8
      Top = 24
      Width = 57
      Height = 21
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
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
    object WagaLPZeroEdit: TLabeledEdit
      Left = 8
      Top = 100
      Width = 89
      Height = 21
      EditLabel.Width = 44
      EditLabel.Height = 13
      EditLabel.Caption = 'Zero [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnExit = WagaLTKorektaEditExit
      OnKeyPress = WagaLTKorektaEditKeyPress
    end
  end
  object GroupBox2: TGroupBox
    Left = 3
    Top = 195
    Width = 167
    Height = 113
    Caption = 'Kalibracja Wagi'
    TabOrder = 1
    OnClick = GroupBox2Click
    object WagaP1ValEdit: TLabeledEdit
      Left = 8
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 114
      EditLabel.Height = 13
      EditLabel.Caption = 'Wielko'#347#263' punktu P1 (kg)'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object WagaP1KalibrEdit: TLabeledEdit
      Left = 8
      Top = 80
      Width = 113
      Height = 21
      EditLabel.Width = 113
      EditLabel.Height = 13
      EditLabel.Caption = 'Kalibracja punkt P1 [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
end
