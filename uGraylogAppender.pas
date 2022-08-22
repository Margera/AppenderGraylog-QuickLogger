unit uGraylogAppender;

interface

uses
  System.SysUtils,
  uFuncoesJson,
  System.Variants,
  System.Generics.Collections,
  Quick.Logger,
  Quick.Logger.Provider.GrayLog;

type
  TFields = TDictionary<string,Variant>; 
//  TFields = class
//  private
//    fField : TDictionary<string,Variant>;
//    function GetTag(const aKey: string) : Variant;
//    procedure SetTag(const aKey: string; const aValue: Variant);
//  public
//    constructor Create;
//    destructor Destroy; override;
//    property Items[const Key: string]: Variant read GetTag write SetTag; default;
//    function TryGetValue(const aKey : string; out oValue: Variant) : Boolean;
//    procedure Add(const aKey: string; aValue: Variant);
//  end;

   TGraylogAppender = class
   public
     constructor Create(sGraylogHost: string; iGraylogPort: integer);
//     procedure Info(const cMsg: string); overload;
     procedure Info(const cMsg: string; aFields: TFields = nil); overload;
//     procedure Warn(const cMsg: string); overload;
//     procedure Warn(const cMsg: string; cValues : array of const); overload;
//     procedure Error(const cMsg: string); overload;
//     procedure Error(const cMsg: string; cValues : array of const); overload;
//     procedure Critical(const cMsg: string); overload;
//     procedure Critical(const cMsg: string; cValues: array of const); overload;
//     procedure Succ(const cMsg: string); overload;
//     procedure Succ(const cMsg: string; cValues: array of const); overload;
//     procedure Done(const cMsg: string); overload;
//     procedure Done(const cMsg: string; cValues: array of const); overload;
//     procedure Debug(const cMsg: string); overload;
//     procedure Debug(const cMsg: string; cValues: array of const); overload;
//     procedure Trace(const cMsg: string); overload;
//     procedure Trace(const cMsg: string; cValues: array of const); overload;
//     procedure &Except(const cMsg: string); overload;
//     procedure &Except(const cMsg: string; cValues: array of const); overload;
//     procedure &Except(const cMsg, cException, cStackTrace: string); overload;
//     procedure &Except(const cMsg: string; cValues: array of const; const cException, cStackTrace: string); overload;
     procedure WriteLog(cMsg: string; aFields: TFields; event: TEventType);
   end;

implementation


{ TFields }

//constructor TFields.Create;
//begin
//   fField := TDictionary<string,Variant>.Create;
//end;
//
//destructor TFields.Destroy;
//begin
//   fField.Free;
//   inherited;
//end;
//
//procedure TFields.Add(const aKey: string; aValue: Variant);
//begin
//   fField.Add(aKey.ToUpper,aValue);
//end;
//
//function TFields.GetTag(const aKey: string): Variant;
//begin
//   if not fField.TryGetValue(aKey,Result) then
//      raise Exception.CreateFmt('Log Tag "%s" not found!',[aKey]);
//end;
//
//procedure TFields.SetTag(const aKey: string; const aValue: Variant);
//begin
//   fField.AddOrSetValue(aKey.ToUpper, aValue);
//end;
//
//function TFields.TryGetValue(const aKey : string; out oValue : Variant): Boolean;
//begin
//   Result := fField.TryGetValue(aKey.ToUpper, oValue);
//end;

{ TGraylogAppender }

constructor TGraylogAppender.Create(sGraylogHost: string; iGraylogPort: integer);
var
  lUrl: string;
begin
   lUrl := Format('%s:%d', [sGraylogHost, iGraylogPort]);

   Logger.Providers.Add(GlobalLogGrayLogProvider);
   with GlobalLogGrayLogProvider do
   begin
      URL := lUrl;
      LogLevel := LOG_DEBUG;
      MaxFailsToRestart := 15;
      MaxFailsToStop := 0;
      Environment := 'Production';
      PlatformInfo := 'IIS';
      AppName := 'APIv2';
      IncludedInfo := [iiAppName,iiEnvironment,iiPlatform];
      Enabled := True;

      CustomMsgOutput := True;
   end;

//   Logger.RedirectOwnErrorsToProvider := GlobalLogFileProvider;
   Logger.Info('Create Graylog Appender');

   inherited Create;
end;

//procedure TGraylogAppender.Info(const cMsg: string);
//begin
//   Logger.Info(cMsg);
//end;

procedure TGraylogAppender.Info(const cMsg: string; aFields: TFields);
begin
//   Logger.Info(cMsg);
//   Logger.Add();
   WriteLog(cMsg, aFields, etInfo);
end;

procedure TGraylogAppender.WriteLog(cMsg: string; aFields: TFields; event: TEventType);
var
  json : TJSONObject;
  tagName : string;
  tagValue : Variant;
  i: Integer;

  enumerator: TPair<string, Variant>;
begin
   json := TJSONObject.Create;
   try
      if aFields <> nil then
      begin
         for enumerator in aFields do
         begin
            if aFields.TryGetValue(enumerator.Key, tagValue) then
            begin
               if VarType(tagValue) = varInteger then
                  json.AlterarInserirCampo(enumerator.Key, VarToStr(tagValue))
               else
                  json.AlterarInserirCampo(enumerator.Key, StrToIntDef(tagValue,0));
            end;
         end;
      end;

    json.Add('version', Logger.GetVersion);
//    json.Add('host',SystemInfo.HostName);
//    if fShortMessageAsEventType then
//    begin
//      json.Add('short_message',EventTypeName[cLogItem.EventType]);
//      json.Add('full_message',cLogItem.Msg);
//    end
//    else
//    begin
//      json.Add('type',EventTypeName[cLogItem.EventType]);
      json.Add('short_message', cMsg);
//    end;

//   json.Add('timestamp',TJSONInt64Number.Create(DateTimeToUnix(cLogItem.EventDate)));
//   json.Add('level',TJSONInt64Number.Create(EventTypeToSysLogLevel(cLogItem.EventType)));

//    json.Add('_application',Logger.Providers.First. AppName);
//    json.Add('_environment',Environment);
//    json.Add('_platform',PlatformInfo);

      Logger.Add(json.ToString, event);
   finally
      json.Free;
   end;
end;

end.
