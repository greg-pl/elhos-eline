inherited SerialNumForm: TSerialNumForm
  Caption = 'SerialNumForm'
  ClientHeight = 108
  ClientWidth = 334
  ExplicitWidth = 350
  ExplicitHeight = 147
  PixelsPerInch = 96
  TextHeight = 13
  object NumerSerEdit: TLabeledEdit
    Left = 80
    Top = 24
    Width = 145
    Height = 24
    EditLabel.Width = 83
    EditLabel.Height = 16
    EditLabel.Caption = 'Numer seryjny'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -13
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object SendBtn: TButton
    Left = 120
    Top = 62
    Width = 75
    Height = 25
    Caption = 'Ustaw'
    TabOrder = 1
    OnClick = SendBtnClick
  end
end
