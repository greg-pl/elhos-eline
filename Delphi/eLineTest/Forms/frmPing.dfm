inherited PingForm: TPingForm
  Caption = 'PingForm'
  ClientHeight = 257
  ClientWidth = 237
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  ExplicitWidth = 253
  ExplicitHeight = 296
  PixelsPerInch = 96
  TextHeight = 13
  object MultiSendBtn: TSpeedButton
    Left = 116
    Top = 216
    Width = 77
    Height = 25
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'Multi'
    OnClick = MultiSendBtnClick
  end
  object SendOneBtn: TButton
    Left = 16
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Send One'
    TabOrder = 0
    OnClick = SendOneBtnClick
  end
  object SentCntEdit: TLabeledEdit
    Left = 16
    Top = 32
    Width = 123
    Height = 23
    TabStop = False
    EditLabel.Width = 103
    EditLabel.Height = 18
    EditLabel.Caption = 'Ilo'#347#263' wys'#322'anych'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -15
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
  object ReciveCntEdit: TLabeledEdit
    Left = 16
    Top = 80
    Width = 121
    Height = 23
    TabStop = False
    EditLabel.Width = 111
    EditLabel.Height = 18
    EditLabel.Caption = 'Ilo'#347#263' odebranych'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -15
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
  end
  object ReciveOkCntEdit: TLabeledEdit
    Left = 16
    Top = 128
    Width = 121
    Height = 23
    TabStop = False
    EditLabel.Width = 181
    EditLabel.Height = 18
    EditLabel.Caption = 'Ilo'#347#263' poprawnie odebranych'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -15
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 3
  end
  object TimeEdit: TLabeledEdit
    Left = 18
    Top = 173
    Width = 121
    Height = 23
    TabStop = False
    EditLabel.Width = 105
    EditLabel.Height = 18
    EditLabel.Caption = 'Czas odpowiedzi'
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clWindowText
    EditLabel.Font.Height = -15
    EditLabel.Font.Name = 'Tahoma'
    EditLabel.Font.Style = []
    EditLabel.ParentFont = False
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Lucida Console'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 4
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 184
    Top = 32
  end
end
