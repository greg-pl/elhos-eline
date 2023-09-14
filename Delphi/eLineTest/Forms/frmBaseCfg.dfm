inherited BaseCfgForm: TBaseCfgForm
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'BaseCfgForm'
  ClientHeight = 515
  ClientWidth = 402
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  ExplicitWidth = 408
  ExplicitHeight = 544
  PixelsPerInch = 96
  TextHeight = 13
  object BottomPanel: TPanel
    Left = 0
    Top = 474
    Width = 402
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    DesignSize = (
      402
      41)
    object CheckButton: TButton
      Left = 143
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Sprawd'#378
      TabOrder = 3
    end
    object SaveBtn: TBitBtn
      Left = 40
      Top = 8
      Width = 25
      Height = 25
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888880000000000000880330000008803088033000000880308803300000088
        0308803300000000030880333333333333088033000000003308803088888888
        0308803088888888030880308888888803088030888888880308803088888888
        0008803088888888080880000000000000088888888888888888}
      TabOrder = 1
      OnClick = SaveBtnClick
    end
    object OpenBtn: TBitBtn
      Left = 8
      Top = 8
      Width = 25
      Height = 25
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        88888888888888888888000000000008888800333333333088880B0333333333
        08880FB03333333330880BFB0333333333080FBFB000000000000BFBFBFBFB08
        88880FBFBFBFBF0888880BFB0000000888888000888888880008888888888888
        8008888888880888080888888888800088888888888888888888}
      TabOrder = 0
      OnClick = OpenBtnClick
    end
    object ReadButton: TButton
      Left = 229
      Top = 8
      Width = 75
      Height = 25
      Action = ReadAct
      Anchors = [akTop, akRight]
      TabOrder = 4
    end
    object SendButton: TButton
      Left = 317
      Top = 8
      Width = 75
      Height = 25
      Action = SendAct
      Anchors = [akTop, akRight]
      Default = True
      TabOrder = 5
    end
    object ChangesBtn: TBitBtn
      Left = 84
      Top = 8
      Width = 25
      Height = 25
      Hint = 'Sprawd'#378' czy s'#261' wprowadzone zmiany.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1FFFFFFFFFFFFFFF1FFFFFFFFF11FFFF1F
        FFFFFFFF11FFFF1FFFFFFFFFFFFFF11FFFFFFFFF11FFFF1FFFFFFFFF11FFFFFF
        FFFFFFFFF11FFFFFFFFFFFFFFF11FFFFFFFFFF11FF11FFFFFFFFFF11FF11FFFF
        FFFFFF111111FFFFFFFFFFF1111FFFFFFFFFFFFFFFFFFFFFFFFF}
      ParentFont = False
      TabOrder = 2
      OnClick = ChangesBtnClick
      OnContextPopup = ChangesBtnContextPopup
    end
  end
  object BaseActionList: TActionList
    Left = 344
    Top = 319
    object SendAct: TAction
      Caption = 'Wy'#347'lij'
      OnExecute = SendActExecute
      OnUpdate = SendActUpdate
    end
    object ReadAct: TAction
      Caption = 'Odczytaj'
      OnExecute = ReadActExecute
      OnUpdate = ReadActUpdate
    end
  end
end
