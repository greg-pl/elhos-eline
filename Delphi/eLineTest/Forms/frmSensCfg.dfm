inherited SensCfgForm: TSensCfgForm
  Caption = 'SensCfgForm'
  ClientHeight = 410
  ClientWidth = 551
  ExplicitWidth = 557
  ExplicitHeight = 439
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 51
    Width = 59
    Height = 13
    Caption = 'Typ czujnika'
  end
  object OwnNameEdit: TLabeledEdit [1]
    Left = 11
    Top = 16
    Width = 73
    Height = 21
    EditLabel.Width = 69
    EditLabel.Height = 13
    EditLabel.Caption = 'Nazwa w'#322'asna'
    LabelPosition = lpRight
    TabOrder = 0
  end
  object SensorTypeBox: TComboBox [2]
    Tag = -1
    Left = 8
    Top = 67
    Width = 86
    Height = 21
    Style = csDropDownList
    ItemIndex = 4
    TabOrder = 1
    Text = 'Ci'#347'nienie'
    Items.Strings = (
      '-'
      '-'
      '-'
      'Nacisk'
      'Ci'#347'nienie')
  end
  inline KalibrInpFrame: TKalibrFrame [3]
    Left = 8
    Top = 104
    Width = 264
    Height = 121
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 104
    ExplicitHeight = 121
    inherited GroupBox5: TGroupBox
      Caption = 'Kalibracja INP'
    end
  end
  inherited BottomPanel: TPanel [4]
    Top = 369
    Width = 551
    TabOrder = 6
    ExplicitTop = 369
    ExplicitWidth = 551
    inherited CheckButton: TButton
      Left = 292
      ExplicitLeft = 292
    end
    inherited ReadButton: TButton
      Left = 378
      ExplicitLeft = 378
    end
    inherited SendButton: TButton
      Left = 466
      ExplicitLeft = 466
    end
  end
  inline KalibrV12Frame: TKalibrFrame
    Left = 278
    Top = 104
    Width = 264
    Height = 121
    TabOrder = 4
    ExplicitLeft = 278
    ExplicitTop = 104
    ExplicitHeight = 121
    inherited GroupBox5: TGroupBox
      Caption = 'Kalibracja V12'
    end
  end
  inline KalibrVBatFrame: TKalibrFrame
    Left = 8
    Top = 239
    Width = 264
    Height = 121
    TabOrder = 3
    ExplicitLeft = 8
    ExplicitTop = 239
    ExplicitHeight = 121
    inherited GroupBox5: TGroupBox
      Caption = 'Kalibracja VBAT'
    end
  end
  inline KalibrI12Frame: TKalibrFrame
    Left = 278
    Top = 239
    Width = 264
    Height = 121
    TabOrder = 5
    ExplicitLeft = 278
    ExplicitTop = 239
    ExplicitHeight = 121
    inherited GroupBox5: TGroupBox
      Caption = 'Kalibracja I12'
    end
  end
  inherited BaseActionList: TActionList
    Left = 488
    Top = 23
  end
end
