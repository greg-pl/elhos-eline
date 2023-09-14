object KeyLogItemForm: TKeyLogItemForm
  Left = 734
  Top = 503
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Edytuj LogItem'
  ClientHeight = 134
  ClientWidth = 276
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 144
    Top = 8
    Width = 48
    Height = 13
    Caption = 'Wa'#380'ny do'
  end
  object ModeBox: TRadioGroup
    Left = 16
    Top = 8
    Width = 113
    Height = 81
    Caption = ' Mode '
    Items.Strings = (
      'OFF'
      'ON'
      'DEMO')
    TabOrder = 0
    OnClick = ModeBoxClick
  end
  object ValidCntEdit: TLabeledEdit
    Left = 144
    Top = 64
    Width = 121
    Height = 21
    EditLabel.Width = 80
    EditLabel.Height = 13
    EditLabel.Caption = 'Ilo'#347#263' uruchomie'#324
    TabOrder = 1
  end
  object ValidDateEdit: TDateTimePicker
    Left = 144
    Top = 24
    Width = 121
    Height = 21
    Date = 41033.915203043980000000
    Time = 41033.915203043980000000
    TabOrder = 2
  end
  object Button1: TButton
    Left = 112
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object Button2: TButton
    Left = 192
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
