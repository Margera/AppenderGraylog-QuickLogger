object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object edtAdd: TButton
    Left = 455
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Adicionar'
    TabOrder = 0
    OnClick = edtAddClick
  end
  object edtValor: TEdit
    Left = 328
    Top = 18
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Valor'
  end
  object edtEnviar: TButton
    Left = 455
    Top = 47
    Width = 75
    Height = 25
    Caption = 'Enviar'
    TabOrder = 2
    OnClick = edtEnviarClick
  end
  object edtKey: TEdit
    Left = 201
    Top = 18
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'key'
  end
  object edtMgs: TEdit
    Left = 74
    Top = 18
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'Mensagem'
  end
  object mmFields: TMemo
    Left = 201
    Top = 45
    Width = 128
    Height = 84
    TabOrder = 5
  end
end
