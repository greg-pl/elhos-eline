object KpBreaksCfgFrame: TKpBreaksCfgFrame
  Left = 0
  Top = 0
  Width = 438
  Height = 329
  TabOrder = 0
  object Label3: TLabel
    Left = 16
    Top = 139
    Width = 141
    Height = 13
    Caption = 'Pod'#322#261'czenie czujnika obrot'#243'w'
  end
  object Label2: TLabel
    Left = 16
    Top = 91
    Width = 139
    Height = 13
    Caption = 'Pod'#322#261'czenie czujnika najazdu'
  end
  object Label1: TLabel
    Left = 16
    Top = 43
    Width = 115
    Height = 13
    Caption = 'Pod'#322#261'czenie tensometru'
  end
  object LiczP1ManuBtn: TButton
    Left = 176
    Top = 259
    Width = 153
    Height = 25
    Caption = 'Wylicz P1 - podaj wsp'#243#322'. A'
    TabOrder = 6
    OnClick = LiczP1BtnClick
  end
  object LiczP1Btn: TButton
    Left = 360
    Top = 259
    Width = 75
    Height = 25
    Caption = 'Wylicz P1'
    TabOrder = 7
    OnClick = LiczP1BtnClick
  end
  object SpeedBitBox: TComboBox
    Tag = -1
    Left = 16
    Top = 155
    Width = 57
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 3
    Text = 'DIG1'
    Items.Strings = (
      'DIG1'
      'DIG2'
      'DIG3'
      'DIG4'
      'DIG5'
      'DIG6'
      'DIG7'
      'DIG8')
  end
  object PressBitBox: TComboBox
    Tag = -1
    Left = 16
    Top = 107
    Width = 57
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = 'DIG1'
    Items.Strings = (
      'DIG1'
      'DIG2'
      'DIG3'
      'DIG4'
      'DIG5'
      'DIG6'
      'DIG7'
      'DIG8')
  end
  object AnInpNrBox: TComboBox
    Tag = -1
    Left = 16
    Top = 59
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
  object AktivBox: TCheckBox
    Left = 16
    Top = 11
    Width = 97
    Height = 17
    Caption = 'Aktywny'
    TabOrder = 0
  end
  object ParametryRolki_GroupBox: TGroupBox
    Left = 176
    Top = 3
    Width = 249
    Height = 105
    Caption = 'Parametry rolki'
    TabOrder = 4
    object DiameterEdit: TLabeledEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 21
      EditLabel.Width = 68
      EditLabel.Height = 13
      EditLabel.Caption = #346'rednica (mm)'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object ImpCnt: TLabeledEdit
      Left = 8
      Top = 76
      Width = 121
      Height = 21
      EditLabel.Width = 112
      EditLabel.Height = 13
      EditLabel.Caption = 'Ilo'#347#263' impuls'#243'w na obr'#243't'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object Kalibr_GroupBox: TGroupBox
    Left = 176
    Top = 123
    Width = 249
    Height = 121
    Caption = 'Kalibracja belki'
    TabOrder = 5
    object RollKalibrInfoText: TLabel
      Left = 8
      Top = 96
      Width = 233
      Height = 13
      AutoSize = False
      Caption = '...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Z0CloseEdit: TLabeledEdit
      Left = 8
      Top = 72
      Width = 113
      Height = 21
      EditLabel.Width = 110
      EditLabel.Height = 13
      EditLabel.Caption = 'Kalibr.Zera - Close [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object P1ValEdit: TLabeledEdit
      Left = 127
      Top = 32
      Width = 113
      Height = 21
      EditLabel.Width = 96
      EditLabel.Height = 13
      EditLabel.Caption = 'Wielko'#347#263' pkt. P1 (N)'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object P1KalibrEdit: TLabeledEdit
      Left = 128
      Top = 72
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
      TabOrder = 3
    end
    object Z0OpenEdit: TLabeledEdit
      Left = 8
      Top = 32
      Width = 113
      Height = 21
      EditLabel.Width = 110
      EditLabel.Height = 13
      EditLabel.Caption = 'Kalibr.Zera - Open [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
  end
end
