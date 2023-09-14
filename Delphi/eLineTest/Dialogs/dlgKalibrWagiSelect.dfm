object KalibrWagiSelectDlg: TKalibrWagiSelectDlg
  Left = 227
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Dialog'
  ClientHeight = 129
  ClientWidth = 346
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 93
    Height = 18
    Caption = 'Numer punktu'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object OKBtn: TButton
    Left = 263
    Top = 16
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 263
    Top = 46
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object ValueEdit: TLabeledEdit
    Left = 24
    Top = 85
    Width = 137
    Height = 24
    EditLabel.Width = 138
    EditLabel.Height = 18
    EditLabel.Caption = 'Waga wzorcowa [kg]'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -15
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object PointNrBox: TComboBox
    Left = 24
    Top = 27
    Width = 49
    Height = 26
    Style = csDropDownList
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    ParentFont = False
    TabOrder = 3
    Text = '1'
    OnChange = PointNrBoxChange
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6')
  end
end
