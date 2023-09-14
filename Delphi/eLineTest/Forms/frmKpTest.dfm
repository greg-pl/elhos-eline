inherited KpTestForm: TKpTestForm
  BorderIcons = [biSystemMenu]
  Caption = 'KpTestForm'
  ClientHeight = 582
  ClientWidth = 549
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  ExplicitWidth = 565
  ExplicitHeight = 621
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 373
    Width = 549
    Height = 8
    Cursor = crVSplit
    Align = alBottom
    Color = clTeal
    ParentColor = False
    ExplicitTop = 269
    ExplicitWidth = 564
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 549
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 559
    object MsgCntText: TStaticText
      Left = 8
      Top = 3
      Width = 65
      Height = 18
      AutoSize = False
      BorderStyle = sbsSingle
      Caption = '0'
      TabOrder = 0
    end
  end
  object DigiPanel: TPanel
    Left = 0
    Top = 381
    Width = 549
    Height = 201
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitTop = 391
    ExplicitWidth = 559
    object Bn8Panel: TPanel
      Left = 484
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      DesignSize = (
        69
        199)
      object Dg7Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin7Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel8: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg8Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG8'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn7Panel: TPanel
      Left = 415
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      DesignSize = (
        69
        199)
      object Dg6Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin6Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel7: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg7Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG7'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn6Panel: TPanel
      Left = 346
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 2
      DesignSize = (
        69
        199)
      object Dg5Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin5Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel6: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg6Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG6'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn5Panel: TPanel
      Left = 277
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 3
      DesignSize = (
        69
        199)
      object Dg4Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin4Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel5: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg5Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG5'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn4Panel: TPanel
      Left = 208
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 4
      DesignSize = (
        69
        199)
      object Dg3Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin3Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel4: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg4Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG4'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn3Panel: TPanel
      Left = 139
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 5
      DesignSize = (
        69
        199)
      object Dg2Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin2Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel3: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg3Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG3'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn2Panel: TPanel
      Left = 70
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 6
      DesignSize = (
        69
        199)
      object Dg1Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin1Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel2: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg2Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG2'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Bn1Panel: TPanel
      Left = 1
      Top = 1
      Width = 69
      Height = 199
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 7
      DesignSize = (
        69
        199)
      object Dg0Shape: TShape
        Left = 8
        Top = 25
        Width = 41
        Height = 17
        Anchors = [akLeft, akTop, akRight]
      end
      object Bin0Paint: TPaintBox
        Left = 6
        Top = 56
        Width = 56
        Height = 135
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = Bin0PaintPaint
      end
      object Bevel1: TBevel
        Left = 1
        Top = 1
        Width = 67
        Height = 50
        Align = alTop
        Shape = bsBottomLine
      end
      object NameDg1Text: TStaticText
        Left = 8
        Top = 4
        Width = 31
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DG1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object AnPanel: TPanel
    Left = 0
    Top = 25
    Width = 549
    Height = 348
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 2
    ExplicitWidth = 559
    ExplicitHeight = 358
    object Kn1Panel: TPanel
      Left = 1
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      FullRepaint = False
      ParentDoubleBuffered = False
      TabOrder = 0
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh1Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH1'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An0Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText2: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn2Panel: TPanel
      Left = 70
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh2Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH2'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An1Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText30: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN2'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn3Panel: TPanel
      Left = 139
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 2
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh3Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH3'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An2Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText28: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN3'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn4Panel: TPanel
      Left = 208
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 3
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh4Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH4'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An3Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText26: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN4'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn5Panel: TPanel
      Left = 277
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 4
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh5Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH5'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An4Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText24: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN5'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn6Panel: TPanel
      Left = 346
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 5
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh6Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH6'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An5Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText22: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN6'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn7Panel: TPanel
      Left = 415
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 6
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh7Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH7'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An6Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText20: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN7'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Kn8Panel: TPanel
      Left = 484
      Top = 1
      Width = 69
      Height = 346
      Align = alLeft
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 7
      ExplicitHeight = 356
      DesignSize = (
        69
        346)
      object Wh8Btn: TSpeedButton
        Left = 8
        Top = 317
        Width = 41
        Height = 22
        AllowAllUp = True
        Anchors = [akLeft, akBottom]
        GroupIndex = 1
        Caption = 'WH8'
        OnClick = Wh1BtnClick
        ExplicitTop = 316
      end
      object An7Paint: TPaintBox
        Left = 6
        Top = 32
        Width = 56
        Height = 276
        Anchors = [akLeft, akTop, akRight, akBottom]
        OnPaint = An0PaintPaint
        ExplicitHeight = 275
      end
      object StaticText18: TStaticText
        Left = 8
        Top = 8
        Width = 30
        Height = 20
        Caption = 'AN8'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object TestTimer: TTimer
    Interval = 5000
    OnTimer = TestTimerTimer
    Left = 496
    Top = 184
  end
end
