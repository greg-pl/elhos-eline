inherited KPCfgForm: TKPCfgForm
  Caption = 'KPCfgForm'
  ClientHeight = 505
  ClientWidth = 487
  ExplicitWidth = 493
  ExplicitHeight = 534
  PixelsPerInch = 96
  TextHeight = 13
  inherited BottomPanel: TPanel
    Top = 464
    Width = 487
    TabOrder = 1
    ExplicitTop = 464
    ExplicitWidth = 487
    DesignSize = (
      487
      41)
    inherited CheckButton: TButton
      Left = 172
      OnClick = CheckButtonClick
      ExplicitLeft = 172
    end
    inherited ReadButton: TButton
      Left = 258
      ExplicitLeft = 258
    end
    inherited SendButton: TButton
      Left = 346
      ExplicitLeft = 346
    end
    object UsageBtn: TBitBtn
      Left = 118
      Top = 8
      Width = 25
      Height = 25
      Hint = 'Wy'#347'wietl wykorzystanie AN i DIN'
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
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9998FFFFFFFFFFF898F89FFFF
        FFFFFFF98FFF9FFFFFFFFFF99FFFFFFFFFFFFFF898FFFFFFFFFFFFFF99FFFFFF
        FFFFFFFFF98FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF98FFF
        FFFFFFFFFFF99FFFFFFFFFFFFFFF9FFFFFFFFFFFFFFFFFFFFFFF}
      ParentFont = False
      TabOrder = 6
      OnClick = UsageBtnClick
    end
  end
  object MainPageControl: TPageControl [1]
    Left = 0
    Top = 0
    Width = 487
    Height = 464
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'G'#322#243'wne'
      object OwnNameEdit: TLabeledEdit
        Left = 11
        Top = 16
        Width = 73
        Height = 21
        EditLabel.Width = 69
        EditLabel.Height = 13
        EditLabel.Caption = 'Nazwa w'#322'asna'
        LabelPosition = lpRight
        TabOrder = 0
      end
      object NetIpEdit: TLabeledEdit
        Left = 11
        Top = 56
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
        TabOrder = 1
      end
      object NetMaskaEdit: TLabeledEdit
        Left = 11
        Top = 80
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
        TabOrder = 2
      end
      object NetBramaEdit: TLabeledEdit
        Left = 11
        Top = 104
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
        TabOrder = 3
      end
      object HostIpEdit: TLabeledEdit
        Left = 11
        Top = 160
        Width = 137
        Height = 24
        EditLabel.Width = 50
        EditLabel.Height = 13
        EditLabel.Caption = 'IP HOST-a'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        LabelPosition = lpRight
        ParentFont = False
        TabOrder = 4
      end
    end
    object TabSheet12: TTabSheet
      Caption = 'Wej.binarne'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object BinAcGrid: TStringGrid
        Left = 16
        Top = 16
        Width = 433
        Height = 241
        ColCount = 4
        DefaultColWidth = 30
        DrawingStyle = gdsClassic
        RowCount = 9
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Lucida Console'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
        ParentFont = False
        TabOrder = 0
        OnDrawCell = BinAcGridDrawCell
        ColWidths = (
          30
          99
          143
          139)
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Rolki'
      ImageIndex = 1
      object BreaksPageControl: TPageControl
        Left = 0
        Top = 0
        Width = 479
        Height = 436
        ActivePage = TabSheet8
        Align = alClient
        TabOrder = 0
        object TabSheet8: TTabSheet
          Caption = 'Lewy'
          inline LeftBreaksFrm: TKpBreaksCfgFrame
            Left = 0
            Top = 0
            Width = 471
            Height = 408
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 471
            ExplicitHeight = 408
          end
        end
        object TabSheet9: TTabSheet
          Caption = 'Prawy'
          ImageIndex = 1
          inline RightBreaksFrm: TKpBreaksCfgFrame
            Left = 0
            Top = 0
            Width = 471
            Height = 408
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 471
            ExplicitHeight = 408
          end
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Amortyzatory'
      ImageIndex = 2
      object SuspensionPageControl: TPageControl
        Left = 0
        Top = 0
        Width = 479
        Height = 436
        ActivePage = TabSheet6
        Align = alClient
        TabOrder = 0
        object TabSheet6: TTabSheet
          Caption = 'Lewy'
          inline LeftSuspFrm: TKpSuspensCfgFrame
            Left = 0
            Top = 0
            Width = 471
            Height = 408
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 471
            ExplicitHeight = 408
            inherited DeadBandEdit: TLabeledEdit
              EditLabel.ExplicitWidth = 104
            end
            inherited GroupBox5: TGroupBox
              inherited L0MeasValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 86
              end
              inherited L0FizValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 74
              end
              inherited L1MeasValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 86
              end
              inherited L1FizValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 74
              end
            end
            inherited PGrid: TStringGrid
              OnDrawCell = BinAcGridDrawCell
            end
            inherited ReturnTimeEdit: TLabeledEdit
              EditLabel.ExplicitWidth = 110
            end
          end
        end
        object TabSheet7: TTabSheet
          Caption = 'Prawy'
          ImageIndex = 1
          inline RightSuspFrm: TKpSuspensCfgFrame
            Left = 0
            Top = 0
            Width = 471
            Height = 408
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 471
            ExplicitHeight = 408
            inherited DeadBandEdit: TLabeledEdit
              EditLabel.ExplicitWidth = 104
            end
            inherited GroupBox5: TGroupBox
              inherited L0MeasValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 86
              end
              inherited L0FizValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 74
              end
              inherited L1MeasValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 86
              end
              inherited L1FizValEdit: TLabeledEdit
                EditLabel.ExplicitWidth = 74
              end
            end
            inherited PGrid: TStringGrid
              OnDrawCell = BinAcGridDrawCell
            end
            inherited ReturnTimeEdit: TLabeledEdit
              EditLabel.ExplicitWidth = 110
            end
          end
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Zbie'#380'no'#347#263
      ImageIndex = 3
      inline SlipSideFrm: TKpSlipsideCfgFrame
        Left = 0
        Top = 0
        Width = 479
        Height = 436
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 479
        ExplicitHeight = 436
        inherited GroupBox3: TGroupBox
          inherited P1ValEdit: TLabeledEdit
            EditLabel.ExplicitWidth = 91
          end
          inherited P1KalibrEdit: TLabeledEdit
            EditLabel.ExplicitWidth = 103
          end
          inherited P0KalibrEdit: TLabeledEdit
            EditLabel.ExplicitWidth = 103
          end
          inherited P0ValEdit: TLabeledEdit
            EditLabel.ExplicitWidth = 91
          end
        end
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'Waga'
      ImageIndex = 4
      object WeightPageControl: TPageControl
        Left = 0
        Top = 0
        Width = 479
        Height = 436
        ActivePage = TabSheet10
        Align = alClient
        TabOrder = 0
        object TabSheet10: TTabSheet
          Caption = 'Lewy'
          inline LeftWeightFrm: TKpWeightCfgFrame
            Left = 0
            Top = 0
            Width = 471
            Height = 408
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 471
            ExplicitHeight = 408
            inherited PT_Panel: TPanel
              inherited WagaPTKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaPTZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
            inherited LT_Panel: TPanel
              inherited WagaLTKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaLTZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
            inherited PP_Panel: TPanel
              inherited WagaPPKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaPPZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
            inherited LP_Panel: TPanel
              inherited WagaLPKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaLPZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
          end
        end
        object TabSheet11: TTabSheet
          Caption = 'Prawy'
          ImageIndex = 1
          inline RightWeightFrm: TKpWeightCfgFrame
            Left = 0
            Top = 0
            Width = 471
            Height = 408
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 471
            ExplicitHeight = 408
            inherited PT_Panel: TPanel
              inherited WagaPTKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaPTZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
            inherited LT_Panel: TPanel
              inherited WagaLTKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaLTZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
            inherited PP_Panel: TPanel
              inherited WagaPPKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaPPZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
            inherited LP_Panel: TPanel
              inherited WagaLPKorektaEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
              inherited WagaLPZeroEdit: TLabeledEdit
                OnExit = nil
                OnKeyPress = nil
              end
            end
          end
        end
      end
    end
  end
  inherited BaseActionList: TActionList
    Left = 392
    Top = 223
  end
end
