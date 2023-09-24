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
  object OpenBtn: TButton
    Left = 16
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 0
    OnClick = OpenBtnClick
  end
  object Wr16Btn: TButton
    Left = 16
    Top = 255
    Width = 75
    Height = 25
    Caption = 'Wr_64'
    TabOrder = 1
    OnClick = Wr16BtnClick
  end
  object Wr128Btn: TButton
    Left = 16
    Top = 295
    Width = 75
    Height = 25
    Caption = 'Wr_128'
    TabOrder = 2
    OnClick = Wr128BtnClick
  end
  object CloseBtn: TButton
    Left = 16
    Top = 119
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 3
    OnClick = CloseBtnClick
  end
  object PipeInfoBtn: TButton
    Left = 16
    Top = 198
    Width = 75
    Height = 25
    Caption = 'PipeInfo'
    TabOrder = 4
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
    TabOrder = 5
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
    TabOrder = 6
    Text = '0295'
  end
  object Panel1: TPanel
    Left = 97
    Top = 0
    Width = 401
    Height = 545
    Align = alRight
    Caption = 'Panel1'
    TabOrder = 7
    object Splitter1: TSplitter
      Left = 1
      Top = 373
      Width = 399
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 51
      ExplicitWidth = 188
    end
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 399
      Height = 372
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 183
      ExplicitHeight = 50
    end
    object LogMemo: TMemo
      Left = 1
      Top = 376
      Width = 399
      Height = 168
      Align = alBottom
      TabOrder = 1
      ExplicitTop = 379
    end
  end
  object DevDscrBtn: TButton
    Left = 16
    Top = 167
    Width = 75
    Height = 25
    Caption = 'DevDscr'
    TabOrder = 8
    OnClick = DevDscrBtnClick
  end
  object RepeatBox: TCheckBox
    Left = 18
    Top = 336
    Width = 68
    Height = 17
    Caption = 'Repeat'
    TabOrder = 9
    OnClick = RepeatBoxClick
  end
end
