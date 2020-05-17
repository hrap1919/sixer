object Form1: TForm1
  Left = 196
  Top = 131
  AutoSize = True
  Caption = 'Form1'
  ClientHeight = 25
  ClientWidth = 221
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFF
    0888888888880888888888880888FFFF0888888888880888888888880888FFFF
    0888888888880888888888880888FFFF0888888888880888888888880888FFF0
    F088888888808088888888808088F00FFF008888800888008888800888080FFF
    FFFF008008888888008008888888FFFFFFFFFF0888888888880888888888FFAA
    AAAFFF0888888888880888888888FFFAFFFFFF0888888888880888888888FFFF
    AFFFFF0888888888880888888888FFFFFAFFFF0888888888880888888888FFFF
    FFAFFF0888888888880888888888FFAFFFAFFF0888888888880888888888FFFA
    AAFFF0F08888888880808888888800FFFFF00FFF00888880088800888888FF00
    F00FFFFFFF008008888888008008FFFF0FFFFFFFFFFF0888888888880888FFFF
    0FFFFCCCFFFF0888888888880888FFFF0FFFFFCFFFFF0888888888880888FFFF
    0FFFFFCFFFFF0888888888880888FFFF0FFFFFCFFFFF0888888888880888FFFF
    0FFFFFCFFFFF0888888888880888FFFF0FFFFCCFFFFF0888888888880888FFF0
    F0FFFFCFFFF08088888888808088F00FFF00FFFFF00888008888800888080FFF
    FFFF00F008888888008008888888FFFFFFFFFF0888888888880888888888FFFC
    CCFFFF0888888888880888888888FFFFCFFFFF0888888888880888888888FFFF
    CFFFFF0888888888880888888888FFFFCFFFFF08888888888808888888880000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 196
    Top = 8
    Width = 25
    Height = 13
    AutoSize = False
    Caption = '0'
  end
  object Label2: TLabel
    Left = 104
    Top = 8
    Width = 32
    Height = 13
    AutoSize = False
    Caption = 'Mines:'
  end
  object Label3: TLabel
    Left = 136
    Top = 8
    Width = 25
    Height = 13
    AutoSize = False
    Caption = 'Label3'
  end
  object Label4: TLabel
    Left = 168
    Top = 8
    Width = 26
    Height = 13
    Caption = 'Time:'
  end
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 49
    Height = 25
    Caption = 'New'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 50
    Top = 0
    Width = 49
    Height = 25
    Caption = 'Pause'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
  end
  object MainMenu1: TMainMenu
    Left = 56
    object N1: TMenuItem
      Caption = 'Options'
      object NewProfile1: TMenuItem
        Caption = 'New Profile'
        OnClick = NewProfile1Click
      end
      object LoadProfile1: TMenuItem
        Caption = 'Load Profile'
        OnClick = loadprofile
      end
      object safeprofile1: TMenuItem
        Caption = 'Save Profile'
        Enabled = False
      end
      object TOP111: TMenuItem
        Caption = 'TOP 11'
        OnClick = TOP111Click
      end
    end
    object N2: TMenuItem
      Caption = 'Exit'
      OnClick = N2Click
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Sixer Profiles|*.six'
    Title = 'Open Profile'
    Left = 128
  end
end
