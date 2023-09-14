inherited UpgradeForm: TUpgradeForm
  Caption = 'UpgradeForm'
  ClientWidth = 588
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  ExplicitWidth = 604
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 342
    Top = 0
    Width = 246
    Height = 320
    Align = alRight
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitLeft = 336
    ExplicitHeight = 339
  end
  object Button1: TButton
    Left = 289
    Top = 24
    Width = 41
    Height = 25
    Caption = '...'
    TabOrder = 1
    OnClick = Button1Click
  end
  object FileNameEdit: TLabeledEdit
    Left = 16
    Top = 26
    Width = 257
    Height = 21
    TabStop = False
    Color = clInfoBk
    EditLabel.Width = 43
    EditLabel.Height = 13
    EditLabel.Caption = 'FileName'
    ReadOnly = True
    TabOrder = 2
  end
  object CheckClearBtn: TButton
    Left = 177
    Top = 284
    Width = 153
    Height = 25
    Caption = 'Sprawd'#378' czy flash czysty'
    TabOrder = 3
    OnClick = CheckClearBtnClick
  end
  object SendFileBtn: TButton
    Left = 8
    Top = 253
    Width = 153
    Height = 25
    Caption = 'Wy'#347'lij plik'
    TabOrder = 4
    OnClick = SendFileBtnClick
  end
  object ClearFlashBtn: TButton
    Left = 177
    Top = 253
    Width = 153
    Height = 25
    Caption = 'Wyczy'#347#263' flash'
    TabOrder = 5
    OnClick = ClearFlashBtnClick
  end
  object VerifyBtn: TButton
    Left = 8
    Top = 165
    Width = 153
    Height = 25
    Caption = 'Verify'
    TabOrder = 6
    OnClick = VerifyBtnClick
  end
  object ExecProgBtn: TButton
    Left = 8
    Top = 284
    Width = 153
    Height = 25
    Caption = 'Programuj'
    TabOrder = 7
    OnClick = ExecProgBtnClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 320
    Width = 588
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 200
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
    ExplicitLeft = 168
    ExplicitTop = 312
    ExplicitWidth = 0
  end
  object VerGrid: TStringGrid
    Left = 16
    Top = 53
    Width = 314
    Height = 62
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    ColCount = 3
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 3
    TabOrder = 9
    OnDblClick = VerGridDblClick
    ColWidths = (
      54
      76
      181)
  end
  object AutoUpdateBtn: TButton
    Left = 8
    Top = 134
    Width = 153
    Height = 25
    Caption = 'Wykonaj update'
    TabOrder = 10
    OnClick = AutoUpdateBtnClick
  end
  object VerifyUserFlashBtn: TButton
    Left = 8
    Top = 222
    Width = 153
    Height = 25
    Caption = 'Verify user flash'
    TabOrder = 11
    OnClick = VerifyUserFlashBtnClick
  end
end
