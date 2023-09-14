inherited HostFalownikiForm: THostFalownikiForm
  Caption = 'HostFalownikiForm'
  ClientHeight = 411
  ClientWidth = 584
  Constraints.MinHeight = 450
  Constraints.MinWidth = 540
  OnCreate = FormCreate
  ExplicitWidth = 600
  ExplicitHeight = 450
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 584
    Height = 411
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Rozkazy'
      OnResize = TabSheet1Resize
      inline Fal1Frame: THostFalownikFrame
        Left = 0
        Top = 0
        Width = 273
        Height = 383
        Align = alLeft
        TabOrder = 0
        ExplicitWidth = 273
        ExplicitHeight = 383
        inherited BckPanel: TPanel
          Width = 273
          Height = 383
          Align = alClient
          ExplicitWidth = 273
          ExplicitHeight = 383
        end
      end
      inline Fal2Frame: THostFalownikFrame
        Left = 273
        Top = 0
        Width = 303
        Height = 383
        Align = alClient
        TabOrder = 1
        ExplicitLeft = 273
        ExplicitWidth = 303
        ExplicitHeight = 383
        inherited BckPanel: TPanel
          Width = 303
          Height = 383
          Align = alClient
          ExplicitWidth = 303
          ExplicitHeight = 383
        end
      end
    end
  end
end
