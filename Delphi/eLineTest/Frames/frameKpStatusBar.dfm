object KpStatusFrame: TKpStatusFrame
  Left = 0
  Top = 0
  Width = 1140
  Height = 32
  TabOrder = 0
  object CloseBtn: TButton
    Left = 3
    Top = 3
    Width = 22
    Height = 22
    Caption = 'X'
    TabOrder = 0
    OnClick = CloseBtnClick
  end
  object MsgCntEdit: TLabeledEdit
    Left = 77
    Top = 3
    Width = 57
    Height = 21
    TabStop = False
    Color = clInfoBk
    EditLabel.Width = 36
    EditLabel.Height = 13
    EditLabel.Caption = 'MsgCnt'
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
end
