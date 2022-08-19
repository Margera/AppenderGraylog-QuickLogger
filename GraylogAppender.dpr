program GraylogAppender;

uses
  Vcl.Forms,
  uInterface in 'uInterface.pas' {Form1},
  uGraylogAppender in 'uGraylogAppender.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
