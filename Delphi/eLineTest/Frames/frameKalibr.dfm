object KalibrFrame: TKalibrFrame
  Left = 0
  Top = 0
  Width = 264
  Height = 129
  TabOrder = 0
  object GroupBox5: TGroupBox
    Left = 0
    Top = 0
    Width = 264
    Height = 115
    Align = alTop
    Caption = 'Kalibracja wychylenia'
    TabOrder = 0
    object P0MeasValEdit: TLabeledEdit
      Left = 9
      Top = 80
      Width = 113
      Height = 21
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Pomiar P0 [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object P0FizValEdit: TLabeledEdit
      Left = 8
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Warto'#347#263' P0 [V]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object P1MeasValEdit: TLabeledEdit
      Left = 128
      Top = 80
      Width = 113
      Height = 21
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = 'Pomiar P1 [%]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object P1FizValEdit: TLabeledEdit
      Left = 128
      Top = 40
      Width = 113
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Warto'#347#263' P1 [V]'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
end
