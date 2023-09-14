object TypLiniselectDlg: TTypLiniselectDlg
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
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
  object TypLiniiGroup: TRadioGroup
    Left = 8
    Top = 8
    Width = 249
    Height = 113
    Caption = 'TypLinii'
    ItemIndex = 0
    Items.Strings = (
      'Linia Osobowa'
      'Linia Ci'#281#380'arowa')
    TabOrder = 2
  end
end
