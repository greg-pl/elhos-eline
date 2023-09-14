inherited HostTestHdwForm: THostTestHdwForm
  Caption = 'HostTestHdwForm'
  ClientHeight = 428
  ClientWidth = 555
  OnCreate = FormCreate
  ExplicitWidth = 571
  ExplicitHeight = 467
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 177
    Height = 241
    BevelOuter = bvLowered
    TabOrder = 0
    OnDblClick = Panel1DblClick
    object Pk1Button: TSpeedButton
      Left = 16
      Top = 8
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'PK1'
      OnClick = Pk1ButtonClick
    end
    object Pk1Shape: TShape
      Left = 132
      Top = 8
      Width = 23
      Height = 23
    end
    object Pk2Button: TSpeedButton
      Left = 16
      Top = 36
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 2
      Caption = 'PK2'
      OnClick = Pk1ButtonClick
    end
    object Pk2Shape: TShape
      Left = 132
      Top = 36
      Width = 23
      Height = 23
    end
    object Pk3Button: TSpeedButton
      Left = 16
      Top = 64
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 3
      Caption = 'PK3'
      OnClick = Pk1ButtonClick
    end
    object Pk3Shape: TShape
      Left = 132
      Top = 64
      Width = 23
      Height = 23
    end
    object Pk4Button: TSpeedButton
      Left = 16
      Top = 92
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 4
      Caption = 'PK4'
      OnClick = Pk1ButtonClick
    end
    object Pk4Shape: TShape
      Left = 132
      Top = 92
      Width = 23
      Height = 23
    end
    object Pk5Shape: TShape
      Left = 132
      Top = 121
      Width = 23
      Height = 23
    end
    object Pk6Button: TSpeedButton
      Left = 16
      Top = 149
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 6
      Caption = 'PK6'
      OnClick = Pk1ButtonClick
    end
    object Pk6Shape: TShape
      Left = 132
      Top = 149
      Width = 23
      Height = 23
    end
    object Pk7Button: TSpeedButton
      Left = 16
      Top = 177
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 7
      Caption = 'PK7'
      OnClick = Pk1ButtonClick
    end
    object Pk7Shape: TShape
      Left = 132
      Top = 177
      Width = 23
      Height = 23
    end
    object Pk8Button: TSpeedButton
      Left = 16
      Top = 206
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 8
      Caption = 'PK8'
      OnClick = Pk1ButtonClick
    end
    object Pk8Shape: TShape
      Left = 132
      Top = 206
      Width = 23
      Height = 23
    end
    object Pk5Button: TSpeedButton
      Left = 16
      Top = 121
      Width = 100
      Height = 22
      AllowAllUp = True
      GroupIndex = 5
      Caption = 'PK5'
      OnClick = Pk1ButtonClick
    end
  end
  object Panel2: TPanel
    Left = 191
    Top = 8
    Width = 130
    Height = 162
    BevelOuter = bvLowered
    TabOrder = 1
    object BeepBtn: TButton
      Left = 16
      Top = 16
      Width = 100
      Height = 22
      Caption = 'Beep <K>'
      TabOrder = 0
      OnClick = BeepBtnClick
    end
    object Button2: TButton
      Tag = 1
      Left = 16
      Top = 44
      Width = 100
      Height = 22
      Caption = 'Beep <KK>'
      TabOrder = 1
      OnClick = BeepBtnClick
    end
    object Button3: TButton
      Tag = 2
      Left = 16
      Top = 72
      Width = 100
      Height = 22
      Caption = 'Beep <KKK>'
      TabOrder = 2
      OnClick = BeepBtnClick
    end
    object Button4: TButton
      Tag = 3
      Left = 16
      Top = 100
      Width = 100
      Height = 22
      Caption = 'Beep <D>'
      TabOrder = 3
      OnClick = BeepBtnClick
    end
    object Button5: TButton
      Tag = 4
      Left = 16
      Top = 128
      Width = 100
      Height = 22
      Caption = 'Beep <DD>'
      TabOrder = 4
      OnClick = BeepBtnClick
    end
  end
  object Panel3: TPanel
    Left = 191
    Top = 176
    Width = 130
    Height = 73
    BevelOuter = bvLowered
    TabOrder = 2
    object Inp1Shape: TShape
      Left = 68
      Top = 14
      Width = 23
      Height = 16
    end
    object Label1: TLabel
      Left = 16
      Top = 13
      Width = 40
      Height = 16
      Caption = 'INP1'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Lucida Console'
      Font.Style = []
      ParentFont = False
    end
    object Inp2Shape: TShape
      Left = 68
      Top = 39
      Width = 23
      Height = 16
    end
    object Label2: TLabel
      Left = 16
      Top = 38
      Width = 40
      Height = 16
      Caption = 'INP2'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Lucida Console'
      Font.Style = []
      ParentFont = False
    end
  end
end
