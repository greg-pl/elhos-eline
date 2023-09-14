object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 545
  ClientWidth = 498
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 112
    Top = 0
    Width = 386
    Height = 545
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object OpenBtn: TButton
    Left = 16
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 1
    OnClick = OpenBtnClick
  end
  object DevDscrBtn: TButton
    Left = 16
    Top = 167
    Width = 75
    Height = 25
    Caption = 'DevDscr'
    TabOrder = 2
    OnClick = DevDscrBtnClick
  end
  object Wr16Btn: TButton
    Left = 16
    Top = 255
    Width = 75
    Height = 25
    Caption = 'Wr_16'
    TabOrder = 3
    OnClick = Wr16BtnClick
  end
  object Wr128Btn: TButton
    Left = 16
    Top = 295
    Width = 75
    Height = 25
    Caption = 'Wr_128'
    TabOrder = 4
    OnClick = Wr128BtnClick
  end
  object CloseBtn: TButton
    Left = 16
    Top = 119
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 5
    OnClick = CloseBtnClick
  end
  object PipeInfoBtn: TButton
    Left = 16
    Top = 198
    Width = 75
    Height = 25
    Caption = 'PipeInfo'
    TabOrder = 6
    OnClick = PipeInfoBtnClick
  end
  object VendorIdEdit: TLabeledEdit
    Left = 16
    Top = 16
    Width = 75
    Height = 21
    EditLabel.Width = 10
    EditLabel.Height = 13
    EditLabel.Caption = 'VI'
    TabOrder = 7
    Text = '4701'
  end
  object ProductIdEdit: TLabeledEdit
    Left = 16
    Top = 53
    Width = 75
    Height = 21
    EditLabel.Width = 10
    EditLabel.Height = 13
    EditLabel.Caption = 'PI'
    TabOrder = 8
    Text = '0295'
  end
end
