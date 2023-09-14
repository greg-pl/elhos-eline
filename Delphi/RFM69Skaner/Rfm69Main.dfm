object MainForm: TMainForm
  Left = 313
  Top = 124
  Caption = 'RFM69 Skaner'
  ClientHeight = 827
  ClientWidth = 874
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 732
    Width = 874
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 29
    ExplicitWidth = 343
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 874
    Height = 29
    Caption = 'ToolBar1'
    Images = ImageList2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object HideSendingBtn: TToolButton
      Left = 0
      Top = 0
      Action = actHideSending
      Down = True
      Style = tbsCheck
    end
    object ToolButton5: TToolButton
      Left = 23
      Top = 0
      Width = 15
      Caption = 'ToolButton5'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object ToolButton3: TToolButton
      Left = 38
      Top = 0
      Action = actClear
    end
    object ToolButton9: TToolButton
      Left = 61
      Top = 0
      Action = actLoad
    end
    object ToolButton15: TToolButton
      Left = 84
      Top = 0
      Action = actSave
    end
    object ToolButton16: TToolButton
      Left = 107
      Top = 0
      Width = 8
      Caption = 'ToolButton16'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 115
      Top = 0
      Action = actOpen
      DropdownMenu = ComListMenu
      Style = tbsDropDown
    end
    object ToolButton4: TToolButton
      Left = 153
      Top = 0
      Action = actLedPulse
    end
    object ToolButton8: TToolButton
      Left = 176
      Top = 0
      Width = 8
      Caption = 'ToolButton8'
      ImageIndex = 37
      Style = tbsSeparator
    end
    object ToolButton6: TToolButton
      Left = 184
      Top = 0
      Action = actSendCfg
    end
    object ToolButton23: TToolButton
      Left = 207
      Top = 0
      Action = actCfg
    end
    object ToolButton24: TToolButton
      Left = 230
      Top = 0
      Width = 8
      Caption = 'ToolButton24'
      ImageIndex = 28
      Style = tbsSeparator
    end
    object RunButton: TToolButton
      Left = 238
      Top = 0
      Action = actRun
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 808
    Width = 874
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 100
      end
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 735
    Width = 874
    Height = 73
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 2
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 46
      Height = 73
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object ClrMemoBtn: TButton
        Left = 9
        Top = 6
        Width = 29
        Height = 25
        Caption = 'X'
        TabOrder = 0
        OnClick = ClrMemoBtnClick
      end
    end
    object Memo1: TMemo
      Left = 46
      Top = 0
      Width = 828
      Height = 73
      Align = alClient
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Lucida Console'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object MainPageControl: TPageControl
    Left = 0
    Top = 29
    Width = 874
    Height = 703
    ActivePage = sLine
    Align = alClient
    TabOrder = 3
    OnChanging = MainPageControlChanging
    object UniSheet: TTabSheet
      Caption = 'Uniwersalnie'
      ImageIndex = 1
      OnShow = UniSheetShow
      object UniSplitter: TSplitter
        Left = 0
        Top = 432
        Width = 866
        Height = 8
        Cursor = crVSplit
        Align = alBottom
        ExplicitTop = 213
        ExplicitWidth = 1015
      end
      object UniLV: TListView
        Left = 0
        Top = 29
        Width = 866
        Height = 403
        Align = alClient
        Columns = <
          item
            Caption = 'Nr'
          end
          item
            Caption = 'Nr ramki'
          end
          item
            Caption = 'Snd'
          end
          item
            Caption = 'RSSI (dBm)'
          end
          item
            Caption = 'Czas'
          end
          item
            Caption = 'Czas wzg'
          end
          item
            Caption = 'Dane'
          end>
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Style = []
        GridLines = True
        HotTrack = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        TabOrder = 0
        ViewStyle = vsReport
        OnCustomDrawSubItem = UniLVCustomDrawSubItem
      end
      object ToolBar3: TToolBar
        Left = 0
        Top = 0
        Width = 866
        Height = 29
        Caption = 'ToolBar2'
        Images = ImageList2
        TabOrder = 1
        object ToolButton2: TToolButton
          Left = 0
          Top = 0
          Width = 19
          Caption = 'ToolButton2'
          Style = tbsSeparator
        end
        object UniSenderEdit: TSpinEdit
          Left = 19
          Top = 0
          Width = 57
          Height = 22
          Hint = 'Numer skrzynki nadawcy'
          MaxValue = 6
          MinValue = -1
          TabOrder = 0
          Value = -1
          OnChange = UniSenderEditChange
        end
      end
      object UniSendPanel: TPanel
        Left = 0
        Top = 440
        Width = 866
        Height = 235
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object UniStringGrid: TStringGrid
          Left = 111
          Top = 0
          Width = 755
          Height = 235
          Align = alClient
          ColCount = 3
          RowCount = 10
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
          TabOrder = 0
          OnMouseDown = UniStringGridMouseDown
          ColWidths = (
            64
            102
            658)
          RowHeights = (
            24
            24
            24
            24
            24
            24
            24
            24
            24
            24)
        end
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 111
          Height = 235
          Align = alLeft
          TabOrder = 1
          object Label2: TLabel
            Left = 5
            Top = 6
            Width = 75
            Height = 19
            Caption = 'Wysy'#322'anie'
            Font.Charset = EASTEUROPE_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Cambria'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label1: TLabel
            Left = 12
            Top = 45
            Width = 45
            Height = 15
            Caption = 'Nr slotu'
            Font.Charset = EASTEUROPE_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Cambria'
            Font.Style = []
            ParentFont = False
          end
          object UniSendSlotNrBox: TComboBox
            Left = 10
            Top = 66
            Width = 52
            Height = 21
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 0
            Text = '0'
            Items.Strings = (
              '0'
              '1'
              '2'
              '3'
              '4'
              '5')
          end
        end
      end
    end
    object GeoSheet: TTabSheet
      Caption = 'Geometria'
      OnShow = GeoSheetShow
      object GeoSplitter: TSplitter
        Left = 0
        Top = 571
        Width = 866
        Height = 8
        Cursor = crVSplit
        Align = alBottom
        ExplicitTop = 161
        ExplicitWidth = 1015
      end
      object Panel3: TPanel
        Left = 0
        Top = 29
        Width = 866
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object RssiMostEdit: TLabeledEdit
          Left = 9
          Top = 14
          Width = 48
          Height = 21
          EditLabel.Width = 23
          EditLabel.Height = 13
          EditLabel.Caption = 'Most'
          TabOrder = 0
        end
        object RssiHead1Edit: TLabeledEdit
          Left = 63
          Top = 14
          Width = 48
          Height = 21
          EditLabel.Width = 32
          EditLabel.Height = 13
          EditLabel.Caption = 'Head1'
          TabOrder = 1
        end
        object RssiHead2Edit: TLabeledEdit
          Left = 117
          Top = 14
          Width = 48
          Height = 21
          EditLabel.Width = 32
          EditLabel.Height = 13
          EditLabel.Caption = 'Head2'
          TabOrder = 2
        end
        object RssiHead3Edit: TLabeledEdit
          Left = 171
          Top = 14
          Width = 48
          Height = 21
          EditLabel.Width = 32
          EditLabel.Height = 13
          EditLabel.Caption = 'Head3'
          TabOrder = 3
        end
        object RssiHead4Edit: TLabeledEdit
          Left = 225
          Top = 14
          Width = 48
          Height = 21
          EditLabel.Width = 32
          EditLabel.Height = 13
          EditLabel.Caption = 'Head4'
          TabOrder = 4
        end
      end
      object LV: TListView
        Left = 0
        Top = 70
        Width = 866
        Height = 501
        Align = alClient
        Columns = <
          item
            Caption = 'Nr'
          end
          item
            Caption = 'Snd'
          end
          item
            Caption = 'HeadNr'
          end
          item
            Caption = 'RSSI (dBm)'
          end
          item
            Caption = 'Nazwa'
          end
          item
            Caption = 'Czas'
          end
          item
            Caption = 'Czas wzg'
          end
          item
            Caption = 'SlotTime'
          end
          item
            Caption = 'Data tm'
          end>
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Style = []
        GridLines = True
        HotTrack = True
        ReadOnly = True
        RowSelect = True
        ParentFont = False
        TabOrder = 1
        ViewStyle = vsReport
        OnCustomDrawSubItem = LVCustomDrawSubItem
      end
      object ToolBar2: TToolBar
        Left = 0
        Top = 0
        Width = 866
        Height = 29
        Caption = 'ToolBar2'
        Images = ImageList2
        TabOrder = 2
        object colHead1Btn: TToolButton
          Left = 0
          Top = 0
          Hint = 'Zaznacz dane g'#322'owicy 1'
          AllowAllUp = True
          Caption = 'colHead1Btn'
          Grouped = True
          ImageIndex = 33
          Style = tbsCheck
          OnClick = colHead1BtnClick
        end
        object colHead2Btn: TToolButton
          Left = 23
          Top = 0
          Hint = 'Zaznacz dane g'#322'owicy 2'
          AllowAllUp = True
          Caption = 'colHead2Btn'
          Grouped = True
          ImageIndex = 34
          Style = tbsCheck
          OnClick = colHead1BtnClick
        end
        object colHead3Btn: TToolButton
          Left = 46
          Top = 0
          Hint = 'Zaznacz dane g'#322'owicy 3'
          AllowAllUp = True
          Caption = 'colHead3Btn'
          Grouped = True
          ImageIndex = 35
          Style = tbsCheck
          OnClick = colHead1BtnClick
        end
        object colHead4Btn: TToolButton
          Left = 69
          Top = 0
          Hint = 'Zaznacz dane g'#322'owicy 4'
          AllowAllUp = True
          Caption = 'colHead4Btn'
          Grouped = True
          ImageIndex = 36
          Style = tbsCheck
          OnClick = colHead1BtnClick
        end
        object colMostBtn: TToolButton
          Left = 92
          Top = 0
          Hint = 'Zaznacz dane z Most'
          AllowAllUp = True
          Caption = 'colMostBtn'
          Grouped = True
          ImageIndex = 11
          Style = tbsCheck
          OnClick = colHead1BtnClick
        end
        object ToolButton7: TToolButton
          Left = 115
          Top = 0
          Width = 16
          Caption = 'ToolButton7'
          ImageIndex = 1
          Style = tbsSeparator
        end
        object CmdBox: TComboBox
          Left = 131
          Top = 0
          Width = 133
          Height = 19
          Hint = 'Zaznacz dane wybranego typu'
          Style = csDropDownList
          DropDownCount = 25
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Lucida Console'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnChange = CmdBoxChange
        end
      end
      object GeoSendPanel: TPanel
        Left = 0
        Top = 579
        Width = 866
        Height = 96
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        object Label3: TLabel
          Left = 14
          Top = 5
          Width = 75
          Height = 19
          Caption = 'Wysy'#322'anie'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Cambria'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
    end
    object SzarpakSheet: TTabSheet
      Caption = 'Szarpak'
      ImageIndex = 2
      object SzLampShape: TShape
        Left = 259
        Top = 256
        Width = 121
        Height = 33
        Shape = stRoundRect
      end
      object Label4: TLabel
        Left = 294
        Top = 265
        Width = 40
        Height = 15
        Caption = 'LAMPA'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Cambria'
        Font.Style = []
        ParentFont = False
      end
      object Label5: TLabel
        Left = 3
        Top = 369
        Width = 70
        Height = 15
        Caption = 'DO LATARKI'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Cambria'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 211
        Top = 369
        Width = 100
        Height = 15
        Caption = 'DO STEROWNIKA'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Cambria'
        Font.Style = []
        ParentFont = False
      end
      object Panel5: TPanel
        Left = 259
        Top = 24
        Width = 121
        Height = 226
        BevelOuter = bvNone
        TabOrder = 0
        object Shape9: TShape
          Left = 0
          Top = 0
          Width = 121
          Height = 208
          Align = alTop
          Shape = stRoundRect
          ExplicitLeft = 8
        end
        object SzBtnOpc1Shape: TShape
          Left = 40
          Top = 133
          Width = 40
          Height = 25
          Shape = stCircle
        end
        object SzBtnLeftShape: TShape
          Left = 18
          Top = 63
          Width = 31
          Height = 25
          Shape = stCircle
        end
        object SzBtnUPShape: TShape
          Left = 18
          Top = 102
          Width = 31
          Height = 25
          Shape = stCircle
        end
        object SzBtnOnOffShape: TShape
          Left = 71
          Top = 24
          Width = 31
          Height = 25
          Shape = stCircle
        end
        object SzBtnLampShape: TShape
          Left = 18
          Top = 24
          Width = 31
          Height = 25
          Shape = stCircle
        end
        object SzBtnOpc2Shape: TShape
          Left = 44
          Top = 168
          Width = 31
          Height = 25
          Shape = stCircle
        end
        object SzBtnDownShape: TShape
          Left = 71
          Top = 102
          Width = 31
          Height = 25
          Shape = stCircle
        end
        object SzBtnRightShape: TShape
          Left = 71
          Top = 71
          Width = 31
          Height = 25
          Shape = stCircle
        end
      end
      object SarpakDtGrid: TStringGrid
        Left = 8
        Top = 24
        Width = 238
        Height = 329
        ColCount = 3
        DefaultColWidth = 30
        Enabled = False
        RowCount = 12
        TabOrder = 1
        ColWidths = (
          30
          127
          68)
      end
      object SzSendMsgNoBeepBtn: TButton
        Left = 3
        Top = 408
        Width = 175
        Height = 25
        Action = actSzPilotMsgNoBeep
        TabOrder = 2
      end
      object SzSendMsgBeepBtn: TButton
        Left = 3
        Top = 448
        Width = 177
        Height = 25
        Action = actSzPilotMsgBeep
        TabOrder = 3
      end
      object Button1: TButton
        Left = 3
        Top = 488
        Width = 177
        Height = 25
        Action = actSzPilotMsgBeep2
        TabOrder = 4
      end
      object Button2: TButton
        Left = 3
        Top = 528
        Width = 177
        Height = 25
        Action = actSzLampOn
        TabOrder = 5
      end
      object Button3: TButton
        Left = 3
        Top = 568
        Width = 177
        Height = 25
        Action = actSzLampOff
        TabOrder = 6
      end
      object Button4: TButton
        Left = 205
        Top = 408
        Width = 212
        Height = 25
        Action = actSzSterowMsgNoBeep
        TabOrder = 7
      end
      object Button5: TButton
        Left = 205
        Top = 448
        Width = 212
        Height = 25
        Action = actSzSterowMsgBeep
        TabOrder = 8
      end
      object Button6: TButton
        Left = 205
        Top = 488
        Width = 212
        Height = 25
        Action = actSzSterowMsg2Beep
        TabOrder = 9
      end
      object Button7: TButton
        Left = 3
        Top = 608
        Width = 127
        Height = 25
        Action = actSzPilotSetCh
        TabOrder = 10
      end
      object SzSetUpChannelBox: TComboBox
        Left = 136
        Top = 610
        Width = 44
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 11
        Text = '0'
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7')
      end
    end
    object sLine: TTabSheet
      Caption = 'sLine'
      ImageIndex = 3
      DesignSize = (
        866
        675)
      object Label7: TLabel
        Left = 11
        Top = 377
        Width = 63
        Height = 15
        Caption = 'DO PILOTA'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Cambria'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 219
        Top = 377
        Width = 60
        Height = 15
        Caption = 'DO HOSTA'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Cambria'
        Font.Style = []
        ParentFont = False
      end
      object Panel6: TPanel
        Left = 275
        Top = 40
        Width = 142
        Height = 289
        BevelOuter = bvNone
        TabOrder = 0
        object Shape1: TShape
          Left = 0
          Top = 0
          Width = 142
          Height = 273
          Align = alTop
          Shape = stRoundRect
        end
        object elineBtn8Shape: TShape
          Left = 56
          Top = 176
          Width = 32
          Height = 32
          Brush.Color = clTeal
          Shape = stCircle
        end
        object elineBtn3Shape: TShape
          Left = 40
          Top = 72
          Width = 64
          Height = 32
          Brush.Color = clRed
          Shape = stRoundRect
        end
        object elineBtn6Shape: TShape
          Left = 16
          Top = 176
          Width = 32
          Height = 32
          Brush.Color = clTeal
          Shape = stCircle
        end
        object elineBtn2Shape: TShape
          Left = 88
          Top = 32
          Width = 32
          Height = 32
          Brush.Color = clRed
          Shape = stCircle
        end
        object elineBtn1Shape: TShape
          Left = 24
          Top = 32
          Width = 32
          Height = 32
          Brush.Color = clRed
          Shape = stCircle
        end
        object elineBtn5Shape: TShape
          Left = 56
          Top = 224
          Width = 32
          Height = 32
          Brush.Color = clTeal
          Shape = stCircle
        end
        object elineBtn7Shape: TShape
          Left = 96
          Top = 176
          Width = 32
          Height = 32
          Brush.Color = clTeal
          Shape = stCircle
        end
        object elineBtn4Shape: TShape
          Left = 56
          Top = 128
          Width = 32
          Height = 32
          Brush.Color = clTeal
          Shape = stCircle
        end
        object elineBtn10Shape: TShape
          Left = 96
          Top = 224
          Width = 32
          Height = 32
          Brush.Color = clPurple
          Shape = stCircle
        end
        object elineBtn9Shape: TShape
          Left = 96
          Top = 128
          Width = 32
          Height = 32
          Brush.Color = clPurple
          Shape = stCircle
        end
        object elineLampShape: TShape
          Left = 64
          Top = 16
          Width = 16
          Height = 16
          Brush.Color = clSilver
        end
        object elineBtn8Txt: TLabel
          Left = 62
          Top = 184
          Width = 21
          Height = 16
          Caption = 'OK'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn10Txt: TLabel
          Left = 99
          Top = 234
          Width = 25
          Height = 13
          Caption = 'ESC'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn9Txt: TLabel
          Left = 102
          Top = 135
          Width = 21
          Height = 16
          Caption = 'Mn'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          Transparent = True
        end
        object elineBtn7Txt: TLabel
          Left = 105
          Top = 184
          Width = 14
          Height = 16
          Caption = '->'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn6Txt: TLabel
          Left = 23
          Top = 184
          Width = 14
          Height = 16
          Caption = '<-'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn4Txt: TLabel
          Left = 67
          Top = 136
          Width = 9
          Height = 16
          Caption = '^'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn5Txt: TLabel
          Left = 68
          Top = 232
          Width = 9
          Height = 16
          Caption = 'v'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWhite
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn1Txt: TLabel
          Left = 35
          Top = 38
          Width = 12
          Height = 20
          Caption = 'L'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn2Txt: TLabel
          Left = 98
          Top = 37
          Width = 14
          Height = 20
          Caption = 'R'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object elineBtn3Txt: TLabel
          Left = 48
          Top = 77
          Width = 46
          Height = 20
          Caption = 'L + R'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object ELineDataGrid: TStringGrid
        Left = 3
        Top = 24
        Width = 254
        Height = 329
        ColCount = 3
        DefaultColWidth = 30
        Enabled = False
        RowCount = 12
        TabOrder = 1
        ColWidths = (
          30
          107
          105)
      end
      object ELineMsgMemo: TMemo
        Left = 438
        Top = 16
        Width = 425
        Height = 656
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Lucida Console'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object Button8: TButton
        Left = 11
        Top = 447
        Width = 175
        Height = 25
        Action = actELineGetPilotInfo
        TabOrder = 3
      end
      object Button9: TButton
        Left = 11
        Top = 478
        Width = 175
        Height = 25
        Action = actELinePilotClrCounters
        TabOrder = 4
      end
      object Button10: TButton
        Left = 11
        Top = 416
        Width = 175
        Height = 25
        Action = actELineSetChannelNr
        TabOrder = 5
      end
      object Button11: TButton
        Left = 11
        Top = 509
        Width = 175
        Height = 25
        Action = actELinePilotGoSleep
        TabOrder = 6
      end
      object Button12: TButton
        Left = 11
        Top = 540
        Width = 175
        Height = 25
        Action = actELinePilotGoSleepSetup
        TabOrder = 7
      end
    end
  end
  object ActionList1: TActionList
    Images = ImageList2
    Left = 656
    Top = 88
    object actOpen: TAction
      Caption = 'actOpen'
      Hint = 'Po'#322#261'czenie'
      ImageIndex = 1
      OnExecute = actOpenExecute
      OnUpdate = actOpenUpdate
    end
    object actClear: TAction
      Caption = 'actClear'
      Hint = 'Wyczy'#347#263' list'#281
      ImageIndex = 23
      OnExecute = actClearExecute
    end
    object actRun: TAction
      Caption = 'actRun'
      Hint = 'Zbieraj dane'
      ImageIndex = 0
      OnExecute = actRunExecute
      OnUpdate = actRunUpdate
    end
    object actSave: TAction
      Caption = 'actSave'
      ImageIndex = 32
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
    object actLoad: TAction
      Caption = 'actLoad'
      ImageIndex = 4
      OnExecute = actLoadExecute
      OnUpdate = actLoadUpdate
    end
    object actSendCfg: TAction
      Caption = 'actSendCfg'
      Hint = 'Wyslij konfiguracj'#281' do skanera'
      ImageIndex = 37
      OnExecute = actSendCfgExecute
      OnUpdate = actSendCfgUpdate
    end
    object actCfg: TAction
      Caption = 'actCfg'
      Hint = 'Konfiguracja radia'
      ImageIndex = 27
      OnExecute = actCfgExecute
      OnUpdate = actCfgUpdate
    end
    object actHideSending: TAction
      Caption = 'actHideSending'
      Hint = 'Poka'#380'/Ukryj panel nadawania'
      ImageIndex = 39
      OnExecute = actHideSendingExecute
    end
    object actLedPulse: TAction
      Caption = 'Puls czerwonej LED na lytce MOST'#39'u'
      ImageIndex = 40
      OnExecute = actLedPulseExecute
      OnUpdate = actLedPulseUpdate
    end
    object actSzPilotMsgNoBeep: TAction
      Category = 'SzarpakLatarka'
      Caption = 'Wy'#347'lij do pilota Msg bez d'#378'wi'#281'ku'
      OnExecute = actSzPilotMsgNoBeepExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzPilotMsgBeep: TAction
      Category = 'SzarpakLatarka'
      Caption = 'Wy'#347'lij do pilota Msg z BEEP'
      OnExecute = actSzPilotMsgBeepExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzPilotMsgBeep2: TAction
      Category = 'SzarpakLatarka'
      Caption = 'Wy'#347'lij do pilota Msg z 2xBEEP'
      OnExecute = actSzPilotMsgBeep2Execute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzLampOn: TAction
      Category = 'SzarpakLatarka'
      Caption = 'W'#322#261'cz latark'#281
      OnExecute = actSzLampOnExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzLampOff: TAction
      Category = 'SzarpakLatarka'
      Caption = 'Wy'#322#261'cz latark'#281
      OnExecute = actSzLampOffExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzSterowMsgNoBeep: TAction
      Category = 'SzarpakSterownik'
      Caption = 'Wy'#347'lij do sterownika Msg bez d'#378'wi'#281'ku'
      OnExecute = actSzSterowMsgNoBeepExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzSterowMsgBeep: TAction
      Category = 'SzarpakSterownik'
      Caption = 'Wy'#347'lij do starownika Msg z BEEP'
      OnExecute = actSzSterowMsgBeepExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzSterowMsg2Beep: TAction
      Category = 'SzarpakSterownik'
      Caption = 'Wy'#347'lij do starownika Msg z 2xBEEP'
      OnExecute = actSzSterowMsg2BeepExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actSzPilotSetCh: TAction
      Category = 'SzarpakLatarka'
      Caption = 'Ustaw numer kana'#322'u'
      OnExecute = actSzPilotSetChExecute
      OnUpdate = actSzPilotMsgBeepUpdate
    end
    object actELineGetPilotInfo: TAction
      Category = 'ELine'
      Caption = 'Odczytaj informacje'
      OnExecute = actELineGetPilotInfoExecute
      OnUpdate = actELineGetPilotInfoUpdate
    end
    object actELinePilotClrCounters: TAction
      Category = 'ELine'
      Caption = 'Zeruj liczniki'
      OnExecute = actELinePilotClrCountersExecute
      OnUpdate = actELineGetPilotInfoUpdate
    end
    object actELineSetChannelNr: TAction
      Category = 'ELine'
      Caption = 'Ustaw numer kana'#322'u (SETUP)'
      OnExecute = actELineSetChannelNrExecute
      OnUpdate = actELineGetPilotInfoUpdate
    end
    object actELinePilotGoSleep: TAction
      Category = 'ELine'
      Caption = 'U'#347'pij pilota'
      OnExecute = actELinePilotGoSleepExecute
      OnUpdate = actELineGetPilotInfoUpdate
    end
    object actELinePilotGoSleepSetup: TAction
      Category = 'ELine'
      Caption = 'U'#347'pij pilota (SETUP)'
      OnExecute = actELinePilotGoSleepSetupExecute
      OnUpdate = actELineGetPilotInfoUpdate
    end
  end
  object ImageList2: TImageList
    Left = 658
    Top = 200
    Bitmap = {
      494C0101290060004C0310001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000040000000B0000000010020000000000000B0
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000808080008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C0008080800000000000000000000000000080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C00000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF00000000008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C00080808000FFFF
      FF0000000000000000000000FF0000008000000080000000000000000000FFFF
      FF00808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000000000000000
      FF00000000000000FF00000080000000FF000000800000008000000000000000
      FF00000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00000000000000FF000000FF000000FF000000FF000000800000000000FFFF
      FF00000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      FF0000000000FFFFFF000000FF000000FF00000080000000FF00000000000000
      FF0000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0080808000FFFF
      FF000000000000000000FFFFFF00FFFFFF000000FF000000000000000000FFFF
      FF0080808000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00C0C0
      C00000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF0000000000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C0008080800000000000000000000000000080808000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000008000000080
      0000000000000000000000800000008000000080000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF00000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00000000000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000
      FF000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000FF000000
      00000000000000000000000000000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000008000000080
      0000008000000080000000800000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000
      00000000000000000000000000000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000008000000080
      0000008000000000000000800000008000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000C0C0
      C000FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000C0C0
      C000FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000008000000080
      0000000000000000000000800000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000000000000000000000800000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000000000000000000000800000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000008000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000000000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000000000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000000000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      0000008000000080000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008000000080000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF00000000000000000000000000FF000000FF00000000000000000000000000
      00000000FF00000000000000FF00000000000000000000000000000000000000
      000000000000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF00000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      000000000000FF000000FF000000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF00
      0000FF000000FF0000000000000000000000000000000000FF00000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000C0C0C000FF000000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000FF000000FF00000000000000000000000000FF00000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      00000000FF00000000000000FF00000000000000000000000000000000000000
      0000FF000000FF000000FF000000FF000000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000FF000000FF00000000000000000000000000FF00000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000FF000000C0C0C000C0C0C000FF0000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF00000000000000000000000000000000000000FF000000FF0000000000
      000000000000FF000000FF000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000FF000000C0C0C00000000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000000000000000000000000000FF000000FF0000000000
      000000000000FF000000FF000000000000000000000000000000000000000000
      00000000000000000000FF000000FF000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FF000000C0C0C00000000000FF000000FF000000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF0000000000000000000000FF000000FF0000000000
      000000000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000FF000000FF00000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000C0C0C00000000000C0C0C000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000FF00
      0000FF000000000000000000000000000000FF000000FF000000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000FF00
      0000FF000000000000000000000000000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000000000000000000000000000C0C0C000FF000000FF000000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000FF00
      0000C0C0C0000000000000000000000000000000000080808000FF000000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808080008080800080808000808080008080
      8000808080008080800080808000808080000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      00000000000000000000FF00000000FF0000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080008080800000000000FFFFFF0000FFFF00FFFFFF0000FFFF000000
      000000000000FFFFFF0000FFFF00000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      00000000000000000000FF00000000FF0000FF00000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF00FFFFFF0000FFFF00FFFFFF000000
      00000000000000000000FFFFFF00000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      000000000000FF00000000FF000000FF000000FF0000FF000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000FFFFFF0000FFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF000000
      000000FFFF000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      000000000000FF00000000FF000000FF000000FF0000FF000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF00FFFFFF000000000000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      0000FF00000000FF000000FF000000FF000000FF000000FF0000FF0000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF0000FFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      0000FF00000000FF000000FF000000FF000000FF000000FF0000FF0000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000000000000000000000FFFF000000
      000000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000000000000000
      0000FF00000000FF000000FF000000FF000000FF000000FF0000FF0000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000FFFFFF000000
      0000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00000000008080800000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF00000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000FF00
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008000000080000000000000000000000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF00000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000008080
      8000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000FF00000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000080808000808080008080800080808000808080008080
      80008080800080808000FF000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      FF000000FF000000FF000000FF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF00000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      FF000000FF000000FF000000FF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000000000C0C0C00000000000FF00FF00FF00FF00FF00FF00FF00
      FF0000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      FF00000000000000FF000000FF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000000000C0C0C00000000000FF00FF00FF00FF00FF00FF00FF00
      FF0000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      FF00000000000000FF000000FF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000000000C0C0C00000000000FF00FF00FF00FF00FF00FF00FF00
      FF0000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000FF0000000000000000000000FF000000FF00000000000000
      FF000000FF000000FF000000FF00000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      00000000FF000000FF000000FF00000000000000FF000000FF00000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000FF000000FF00000000000000000000FF000000FF000000FF
      000000FF000000000000C0C0C00000000000FFFF0000FFFF0000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF00000000000000FF000000FF000000FF000000FF00000000000000
      0000000000000000FF000000FF00000000000000000000FF000000FF000000FF
      000000FF000000000000C0C0C00000000000FFFF0000FFFF0000FFFF0000FFFF
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000FF000000FF00000000000000000000FF000000FF000000FF
      000000FF000000000000C0C0C00000000000FFFF0000FFFF0000FFFF0000FFFF
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      0000000000000000FF000000FF00000000000000000000FF000000FF000000FF
      000000FF000000000000C0C0C00000000000FFFF0000FFFF0000FFFF0000FFFF
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000C0C0C00000000000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF00000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000000000000000000000000000000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000FF000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF00000000000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF00000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000FF00000000000000FF00000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000FF0000000000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      000000000000FF000000FF000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000FF000000FF000000FF000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000FF000000000000000000000000000000000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      000000000000FF000000FF000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000FF000000FF000000FF000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000FF000000FF000000FF000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF0000000000000000000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF0000000000000000000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF00000000000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF00000000000000000000000000000000000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF00000000000000000000000000000000000000FF000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF000000000000000000FF000000FF0000000000
      000000000000000000000000000000000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000FF00000000000000000000000000000000000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF00000000000000000000000000000000000000FF000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF000000000000000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF00000000000000FF00000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000FF00000000000000FF000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000FF0000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF00000000000000FF00000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000FF0000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000FF00000000000000FF000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000FF000000FF000000FF000000FF000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000FF000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000000000000000000000000000000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000080000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF0000000000000000000000000000000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF0000000000000000000000
      00000000FF000000FF000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000808080000000
      FF000000FF000000FF000000FF00000000008080800000000000000000008080
      80000000FF00000000008080800000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF00000000000000000000000000000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF0000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000FF000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF00000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FFFF0000FFFF0000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      FF000000FF000000FF000000FF00000000008080800000000000000000008080
      80000000FF00000000008080800000000000000000000000000000000000FF00
      0000FFFF0000FFFF0000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000C0C0
      C000FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF0000000000000000000000
      00000000FF000000FF000000000000000000000000000000000000000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000000000000000000000000000000FFFF00000000000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C00000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008080000080800000808000008080000080800000808000008080000080
      8000008080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      000000000000000000000000FF00000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000C0C0C00000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      00000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000C0C0C0000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      00000000FF000000FF00000000000000FF000000FF000000FF00000000000000
      0000C0C0C00000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      00000000FF000000000000000000000000000000FF000000FF000000FF000000
      0000C0C0C0000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000800000008000
      000000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FF00
      000000FF000000FF0000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF0000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF0000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF0000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF000000FF0000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF000000FF000000FF0000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      000000FF000000FF0000FF000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000B00000000100010000000000800500000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000F83F000000000000
      E00F000000000000C00700000000000080030000000000008003000000000000
      0001000000000000000100000000000000010000000000000001000000000000
      000100000000000080030000000000008003000000000000C007000000000000
      E00F000000000000F83F000000000000FFFFFFDFFFCFFFFFFFF9FFCFFF8F8001
      FFF9FFC7FF008001E1F9000300008001C0F9000100008001CC41000000008001
      FE49000100008001FE49000300008001E0C9000700008001C1C9000F000F8001
      CFFF001F000F8001CFFF007F007F8001C4FF00FF00FF8001E0FF01FF01FF8001
      F1FF03FF03FF8001FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC001FFE1FFC1FFE3
      8031FFF3FFCFFFC98031E1F3E1E7E1F98031C0F3C0F3C0F98001CC73CC79CC73
      8001FE73FE79FE798001FE43FE49FE598FF1E0E3E0E1E0C18FF1C1F3C1F3C1E3
      8FF1CFFFCFFFCFFF8FF1CFFFCFFFCFFF8FF1C4FFC4FFC4FF8FF5E0FFE0FFE0FF
      8001F1FFF1FFF1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8E75
      F9FFFFFFFFFFBE73F8FFE6678183BE71F0FF80019F99BE75F07F8001CF99BE71
      F07FE667E799F81FE27FE667F399FC3FE23FE667F999FE7FE23F80018183FFFF
      C71F8001FF9F8001C71FE667FF9FEDB7C70FE667FF9FEDB7C78FFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8001FEFF000F
      FE008001FEFF000FFC008001FC7F000FF0008001FC7F000FE0088001F83F000F
      C0048001F83F000F80008001F01F000F80008001F01F008E80008001F01F1144
      80038001E00F0AB880078001E00F057C800F8001C007FAFC801F8001C007FDF8
      FFFF8001FFFFFE04FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0207B8FBFFFF
      9F2100039BF1EFFD9F210001ABF1C7FF9F2900019BFBC3FB9F2900018001E3F7
      9F210001BAFBF1E79B21800198F1F8CF91390001BAF1FC1F803900038DFBFE3F
      843900018001FC1F8E390001DAFBF8CF9F390001AAF1E1E7FFFF0001AAF1C3F3
      FFFF8001AAFBC7FDFFFFC081FFFFFFFFFFFFFFFFEFFFFFFFB6DAB6D8CFFFFFFF
      0001000180038183FFF8FFFB00038101E01AE01B00039F39C008C00B80039F39
      C00FC00FCFFF9F31C00FC00FEFFF9F31C00FC00FFFF79F3FE01FE01FFFF39F3F
      FB7FFB7FC0019F3FF7BFF7BFC0009F01F7BFF7BFC0009F83F87FF87FC001FFFF
      FFFFFFFFFFF3FFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFCF1FCF5FED8FEDA
      FCF7FCF3FE4BFE49FCF7FCF1C01BC018FCF7FCF5C00BC00AFCF7FCF1FE5BFE58
      F03FF03FFECFFECFF87FF87FFFDFFFDFFCFFFCFFFFCFFFCFFFFFFFFFFEDFFEDF
      80018001FE4FFE4FEDB7EDB7C01FC01FEDB7EDB7C00FC00FFFFFFFFFFE5FFE5F
      FFFFFFFFFEDFFEDFFFFFFFFFFFFFFFFFFFDFFFF3FFFFFFFFFFCFFF81FFFFFFFF
      FFC7FE01E3FFFC3F0003F873E0FFFE7F00010000E07FFE7F0000C7FFE01FFE7F
      00011FFFE007FE7F0003FFFFE003FE7F0007FFFFE007FE7F000F1FFFE01FFE7F
      001FC7FFE07FFE7F007F0000E0FFCE7300FFF873E3FFCE7301FFFE01FFFFC003
      03FFFF81FFFFC003FFFFFFF3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      001FFFFFFFFFFFFF000FCF3FCE7F80070007CE7FCE7F9FF70003CC7FCE7F9DF7
      0001C8FFCE7F98F70000C1FFC07F9077001FC0FFC07F9237001FCE7FCE7F9717
      001FCE7FCE7F9F978FF1CE7FCE7F9FD7FFF9C07FC07F9FF7FF75C0FFE0FF8007
      FF8FFFFFFFFF8007FFFFFFFFFFFFFFFFFFFFFFB0FFFFFFFFFFFFFF90FFFF83E0
      E3FFFE00FFFF83E0E0FFFE90FC7F83E0E07FFEBFF01F8080E01FFEFFE00F8000
      E007FEFFE00F8100E003FEFFC0078100E007FEFFC007C001E01FFEFFC807E083
      E07FFEFFEC0FE083E0FFFAFFE60FF1C7E3FF02FFF01FF1C7FFFF00FFFC7FF1C7
      FFFF03FFFFFFFFFFFFFF0BFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object ComListMenu: TPopupMenu
    OnPopup = ComListMenuPopup
    Left = 656
    Top = 144
  end
  object eLineColorRetTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = eLineColorRetTimerTimer
    Left = 660
    Top = 325
  end
  object eLineReturnWorkChannelTimer: TTimer
    Enabled = False
    OnTimer = eLineReturnWorkChannelTimerTimer
    Left = 660
    Top = 389
  end
end
