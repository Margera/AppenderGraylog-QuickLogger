unit uInterface;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uGraylogAppender,   System.Generics.Collections;

type
  TForm1 = class(TForm)
    edtAdd: TButton;
    edtValor: TEdit;
    edtEnviar: TButton;
    edtKey: TEdit;
    edtMgs: TEdit;
    mmFields: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure edtAddClick(Sender: TObject);
    procedure edtEnviarClick(Sender: TObject);
  public
    Fields: TFields;
    Log: TGraylogAppender;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.edtAddClick(Sender: TObject);
var
  enumerator: TPair<string, Variant>;
  tagValue: Variant;
begin
   Fields.Add(edtKey.Text, edtValor.Text);

   mmFields.Lines.Clear;

   for enumerator in Fields do
   begin
      if Fields.TryGetValue(enumerator.Key, tagValue) then
         mmFields.Lines.Add(enumerator.key+':'+ tagValue);
   end;
end;

procedure TForm1.edtEnviarClick(Sender: TObject);
begin
   Log.Info('Hello', Fields);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Fields := TFields.Create;
   Log := TGraylogAppender.Create('http://localhost', 12201);
end;

end.

