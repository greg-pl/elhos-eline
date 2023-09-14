object KpSlipsideCfgFrame: TKpSlipsideCfgFrame
  Left = 0
  Top = 0
  Width = 547
  Height = 450
  TabOrder = 0
  object Label7: TLabel
    Left = 240
    Top = 184
    Width = 132
    Height = 13
    Caption = 'Pod'#322#261'czenie czujnika zjazdu'
  end
  object Label6: TLabel
    Left = 32
    Top = 184
    Width = 139
    Height = 13
    Caption = 'Pod'#322#261'czenie czujnika najazdu'
  end
  object Label5: TLabel
    Left = 8
    Top = 48
    Width = 147
    Height = 13
    Caption = 'Pod'#322'.czujnika wychylenia p'#322'yty'
  end
  object Label1: TLabel
    Left = 8
    Top = 144
    Width = 50
    Height = 13
    Caption = 'Tryb p'#322'yty'
  end
  object DeActivTimeEdit: TLabeledEdit
    Left = 208
    Top = 280
    Width = 81
    Height = 21
    EditLabel.Width = 204
    EditLabel.Height = 13
    EditLabel.Caption = 'Czas deaktywacji p'#322'yty po zjechaniu  [sek]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 9
  end
  object MaxMeasEdit: TLabeledEdit
    Left = 8
    Top = 280
    Width = 81
    Height = 21
    EditLabel.Width = 150
    EditLabel.Height = 13
    EditLabel.Caption = 'Maksymalny czas pomiaru [sek]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
  end
  object ZjazdInvertBox: TCheckBox
    Left = 240
    Top = 232
    Width = 137
    Height = 17
    Caption = 'Negacja czujnika zjazdu'
    TabOrder = 7
  end
  object NajazdInvertBox: TCheckBox
    Left = 32
    Top = 232
    Width = 145
    Height = 17
    Caption = 'Negacja czujnika najazdu'
    TabOrder = 6
  end
  object ZjazdInpNrBox: TComboBox
    Tag = -1
    Left = 240
    Top = 200
    Width = 57
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 5
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
  object DeadBandEdit: TLabeledEdit
    Left = 8
    Top = 112
    Width = 81
    Height = 21
    EditLabel.Width = 96
    EditLabel.Height = 13
    EditLabel.Caption = 'Strefa martwa [mm]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object GroupBox3: TGroupBox
    Left = 168
    Top = 16
    Width = 273
    Height = 113
    Caption = 'Kalibracja belki'
    TabOrder = 3
    object P1ValEdit: TLabeledEdit
      Left = 144
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 119
      EditLabel.Height = 13
      EditLabel.Caption = 'Wielko'#347#263' punktu P1 (mm)'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object P1KalibrEdit: TLabeledEdit
      Left = 144
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
      TabOrder = 3
    end
    object P0KalibrEdit: TLabeledEdit
      Left = 8
      Top = 80
      Width = 113
      Height = 21
      EditLabel.Width = 113
      EditLabel.Height = 13
      EditLabel.Caption = 'Kalibracja punkt P0 [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object P0ValEdit: TLabeledEdit
      Left = 8
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 119
      EditLabel.Height = 13
      EditLabel.Caption = 'Wielko'#347#263' punktu P0 (mm)'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
  end
  object NajazdInpNrBox: TComboBox
    Tag = -1
    Left = 32
    Top = 200
    Width = 57
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 4
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
  object AnInpBox: TComboBox
    Tag = -1
    Left = 8
    Top = 64
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
    Left = 8
    Top = 16
    Width = 97
    Height = 17
    Caption = 'Aktywny'
    TabOrder = 0
  end
  object MinMeasEdit: TLabeledEdit
    Left = 8
    Top = 328
    Width = 81
    Height = 21
    EditLabel.Width = 138
    EditLabel.Height = 13
    EditLabel.Caption = 'Minimalny czas pomiaru [sek]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 10
  end
  object MaxFlipEdit: TLabeledEdit
    Left = 8
    Top = 376
    Width = 81
    Height = 21
    EditLabel.Width = 185
    EditLabel.Height = 13
    EditLabel.Caption = 'Maksymalna warto'#347#263' przerzucenia [%]'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 11
  end
  object MaxStartShiftEdit: TLabeledEdit
    Left = 208
    Top = 328
    Width = 81
    Height = 21
    EditLabel.Width = 263
    EditLabel.Height = 13
    EditLabel.Caption = 'Maksymalna warto'#347#263' przesuni'#281'cia poczatkowego [mm] '
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 12
  end
  object TypPlytyBox: TComboBox
    Tag = -1
    Left = 8
    Top = 160
    Width = 209
    Height = 21
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 13
    Text = 'P'#322'yta bez czujnik'#243'w'
    Items.Strings = (
      'P'#322'yta bez czujnik'#243'w'
      'P'#322'yta z czujnikiem przejazdu'
      'P'#322'yta z czujnikiem najazdu i zjazdu')
  end
  object MaxFlipTimeEdit: TLabeledEdit
    Left = 208
    Top = 376
    Width = 81
    Height = 21
    EditLabel.Width = 160
    EditLabel.Height = 13
    EditLabel.Caption = 'Maksymalna czas "przelotu" p'#322'yty'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 14
  end
end
