inherited HostCfgForm: THostCfgForm
  Caption = 'HostCfgForm'
  PixelsPerInch = 96
  TextHeight = 13
  inherited BottomPanel: TPanel
    TabOrder = 1
  end
  object PageControl1: TPageControl [1]
    Left = 0
    Top = 0
    Width = 402
    Height = 474
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'G'#322#243'wne'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      object TypLiniiGroup: TRadioGroup
        Left = 11
        Top = 48
        Width = 193
        Height = 89
        Caption = 'Typ linii'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Items.Strings = (
          'linia ci'#281'zarowa (z falownikami)'
          'linia osobowa (bez falownik'#243'w)'
          'linia ci'#281'zarowa wersja MAHA')
        ParentFont = False
        TabOrder = 0
      end
      object PilotChannelEdit: TLabeledEdit
        Left = 11
        Top = 168
        Width = 33
        Height = 21
        EditLabel.Width = 93
        EditLabel.Height = 13
        EditLabel.Caption = 'Kana'#322' pilota (0..15)'
        EditLabel.Font.Charset = DEFAULT_CHARSET
        EditLabel.Font.Color = clBlack
        EditLabel.Font.Height = -11
        EditLabel.Font.Name = 'Tahoma'
        EditLabel.Font.Style = []
        EditLabel.ParentFont = False
        LabelPosition = lpRight
        TabOrder = 1
      end
      object FalownikTypeEdit: TLabeledEdit
        Left = 11
        Top = 144
        Width = 33
        Height = 21
        EditLabel.Width = 97
        EditLabel.Height = 13
        EditLabel.Caption = 'Typ falownika (1..2)'
        LabelPosition = lpRight
        TabOrder = 2
      end
      object FreqExitSupportText: TLabeledEdit
        Left = 11
        Top = 275
        Width = 73
        Height = 21
        EditLabel.Width = 239
        EditLabel.Height = 13
        EditLabel.Caption = 'Cz'#281'stotliwo'#347'c falownika do wspomagania wyjazdu'
        LabelPosition = lpRight
        TabOrder = 3
      end
      object Freq1Text: TLabeledEdit
        Left = 11
        Top = 227
        Width = 73
        Height = 21
        EditLabel.Width = 231
        EditLabel.Height = 13
        EditLabel.Caption = 'Cz'#281'stotliwo'#347'c falownika dla predko'#347'ci 2.5 [km/h]'
        LabelPosition = lpRight
        TabOrder = 4
      end
      object Freq2Text: TLabeledEdit
        Left = 11
        Top = 251
        Width = 73
        Height = 21
        EditLabel.Width = 221
        EditLabel.Height = 13
        EditLabel.Caption = 'Cz'#281'stotliwo'#347'c falownika dla predko'#347'ci 5 [km/h]'
        LabelPosition = lpRight
        TabOrder = 5
      end
      object PilotTxPowerEdit: TLabeledEdit
        Left = 11
        Top = 192
        Width = 33
        Height = 21
        EditLabel.Width = 193
        EditLabel.Height = 13
        EditLabel.Caption = 'Si'#322'a nadawania odbiornika pilota  (0..31)'
        LabelPosition = lpRight
        TabOrder = 6
      end
      object OwnNameEdit: TLabeledEdit
        Left = 11
        Top = 16
        Width = 73
        Height = 21
        EditLabel.Width = 69
        EditLabel.Height = 13
        EditLabel.Caption = 'Nazwa w'#322'asna'
        LabelPosition = lpRight
        TabOrder = 7
      end
      object BeepWhenPilotBox: TRadioGroup
        Left = 11
        Top = 312
        Width = 193
        Height = 89
        Caption = 'Beep pilota'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Items.Strings = (
          'brak'
          'bardzo kr'#243'tki beep'
          'kr'#243'tki beep')
        ParentFont = False
        TabOrder = 8
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'TCP/IP'
      ImageIndex = 2
      object NetIpEdit: TLabeledEdit
        Left = 8
        Top = 8
        Width = 137
        Height = 24
        EditLabel.Width = 13
        EditLabel.Height = 13
        EditLabel.Caption = ' IP'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        LabelPosition = lpRight
        ParentFont = False
        TabOrder = 0
      end
      object NetMaskaEdit: TLabeledEdit
        Left = 8
        Top = 32
        Width = 137
        Height = 24
        EditLabel.Width = 37
        EditLabel.Height = 13
        EditLabel.Caption = ' MASKA'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        LabelPosition = lpRight
        ParentFont = False
        TabOrder = 1
      end
      object NetBramaEdit: TLabeledEdit
        Left = 8
        Top = 56
        Width = 137
        Height = 24
        EditLabel.Width = 38
        EditLabel.Height = 13
        EditLabel.Caption = ' BRAMA'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        LabelPosition = lpRight
        ParentFont = False
        TabOrder = 2
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Blokady'
      ImageIndex = 1
      object AwariaKeyBox: TCheckBox
        Left = 8
        Top = 8
        Width = 361
        Height = 17
        Caption = 'Aktywuj wy'#322#261'czenie awaryjne rolek przyciskiem pilota'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 0
      end
      object AwariaRolkiBox: TCheckBox
        Left = 8
        Top = 32
        Width = 361
        Height = 17
        Caption = 
          'Aktywuj wy'#322#261'czenie awaryjne rolek po podniesieniu belek najazdow' +
          'ych'
        TabOrder = 1
      end
      object AwariaRolkiTimeEdit: TLabeledEdit
        Left = 24
        Top = 56
        Width = 73
        Height = 21
        EditLabel.Width = 229
        EditLabel.Height = 13
        EditLabel.Caption = ' Czas op'#243'znienia wy'#322'aczenia awaryjnego (Rolki)'
        LabelPosition = lpRight
        TabOrder = 2
      end
      object AwariaPCBox: TCheckBox
        Left = 8
        Top = 88
        Width = 361
        Height = 17
        Caption = 'Aktywuj wy'#322#261'czenie awaryjne urz'#261'dze'#324' przy braku '#322#261'czno'#347'ci z PC'
        TabOrder = 3
      end
      object AwariaPCTimeEdit: TLabeledEdit
        Left = 24
        Top = 112
        Width = 73
        Height = 21
        EditLabel.Width = 220
        EditLabel.Height = 13
        EditLabel.Caption = ' Czas op'#243'znienia wy'#322'aczenia awaryjnego (PC)'
        LabelPosition = lpRight
        TabOrder = 4
      end
      object TurnOffFalByModbusBox: TCheckBox
        Left = 8
        Top = 139
        Width = 321
        Height = 17
        Caption = 'Wy'#322#261'cz falowniki po braku '#322#261'czno'#347'ci z nimi'
        TabOrder = 5
      end
      object TurnOffFalByModbusTime: TLabeledEdit
        Left = 24
        Top = 162
        Width = 73
        Height = 21
        EditLabel.Width = 254
        EditLabel.Height = 13
        EditLabel.Caption = ' Czas op'#243'znienia wy'#322'aczenia awaryjmego falownik'#243'w'
        LabelPosition = lpRight
        TabOrder = 6
      end
    end
  end
end
