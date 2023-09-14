inherited HostTestPilotForm: THostTestPilotForm
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'HostTestPilotForm'
  ClientHeight = 311
  ClientWidth = 465
  FormStyle = fsMDIChild
  Visible = True
  OnCreate = FormCreate
  ExplicitWidth = 471
  ExplicitHeight = 340
  PixelsPerInch = 96
  TextHeight = 13
  object Panel6: TPanel
    Left = 8
    Top = 8
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
      ExplicitTop = 8
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
  object Button8: TButton
    Left = 176
    Top = 243
    Width = 120
    Height = 25
    Action = actELineGetPilotInfo
    TabOrder = 1
  end
  object Button10: TButton
    Left = 176
    Top = 212
    Width = 120
    Height = 25
    Action = actELineSetChannelNr
    TabOrder = 2
  end
  object Button9: TButton
    Left = 320
    Top = 243
    Width = 120
    Height = 25
    Action = actELinePilotClrCounters
    TabOrder = 3
  end
  object Button11: TButton
    Left = 320
    Top = 212
    Width = 120
    Height = 25
    Action = actELinePilotGoSleep
    TabOrder = 4
  end
  object VL: TValueListEditor
    Left = 160
    Top = 8
    Width = 297
    Height = 198
    TabOrder = 5
    ColWidths = (
      131
      160)
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 292
    Width = 465
    Height = 19
    Panels = <>
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer1Timer
    Left = 272
    Top = 16
  end
  object ActionList1: TActionList
    Left = 344
    Top = 16
    object Action1: TAction
      Caption = 'Action1'
    end
    object actELineGetPilotInfo: TAction
      Category = 'ELine'
      Caption = 'Odczytaj informacje'
      OnExecute = actELineGetPilotInfoExecute
    end
    object actELinePilotClrCounters: TAction
      Category = 'ELine'
      Caption = 'Zeruj liczniki'
      OnExecute = actELinePilotClrCountersExecute
    end
    object actELineSetChannelNr: TAction
      Category = 'ELine'
      Caption = 'Ustaw numer kana'#322'u'
      OnExecute = actELineSetChannelNrExecute
    end
    object actELinePilotGoSleep: TAction
      Category = 'ELine'
      Caption = 'U'#347'pij pilota'
      OnExecute = actELinePilotGoSleepExecute
    end
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = Timer2Timer
    Left = 272
    Top = 72
  end
end
