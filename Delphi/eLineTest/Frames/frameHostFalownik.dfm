object HostFalownikFrame: THostFalownikFrame
  Left = 0
  Top = 0
  Width = 269
  Height = 442
  TabOrder = 0
  object BckPanel: TPanel
    Left = 0
    Top = 0
    Width = 269
    Height = 393
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    object NameLab: TLabel
      Left = 16
      Top = 24
      Width = 66
      Height = 19
      Caption = 'NameLab'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ActShape: TShape
      Left = 192
      Top = 24
      Width = 41
      Height = 26
    end
    object Button1: TButton
      Tag = 1
      Left = 16
      Top = 136
      Width = 217
      Height = 25
      Caption = 'Wy'#322#261'cz'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Tag = 5
      Left = 16
      Top = 56
      Width = 217
      Height = 25
      Caption = 'Za'#322#261'cz Wstecz Speed_2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button3: TButton
      Tag = 4
      Left = 16
      Top = 87
      Width = 217
      Height = 25
      Caption = 'Za'#322#261'cz Wstecz Speed_1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button4: TButton
      Tag = 6
      Left = 16
      Top = 199
      Width = 217
      Height = 25
      Caption = 'Za'#322#261'cz wspomaganie'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button5: TButton
      Tag = 2
      Left = 16
      Top = 247
      Width = 217
      Height = 25
      Caption = 'Za'#322#261'cz Prz'#243'd Speed_1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = Button1Click
    end
    object Button6: TButton
      Tag = 3
      Left = 16
      Top = 287
      Width = 217
      Height = 25
      Caption = 'Za'#322#261'cz Prz'#243'd Speed_2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnClick = Button1Click
    end
    object StatusText: TLabeledEdit
      Left = 16
      Top = 340
      Width = 217
      Height = 24
      Color = clGradientInactiveCaption
      EditLabel.Width = 120
      EditLabel.Height = 13
      EditLabel.Caption = 'Status operacji'
      EditLabel.Font.Charset = EASTEUROPE_CHARSET
      EditLabel.Font.Color = clWindowText
      EditLabel.Font.Height = -13
      EditLabel.Font.Name = 'Lucida Console'
      EditLabel.Font.Style = []
      EditLabel.ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 6
    end
    object Button7: TButton
      Tag = 9
      Left = 16
      Top = 168
      Width = 217
      Height = 25
      Caption = 'Wy'#322#261'cz - wolny wybieg'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnClick = Button1Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 216
    Top = 176
  end
end
