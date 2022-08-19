unit uGraylogAppender;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Quick.Logger,
  Quick.Logger.Provider.GrayLog;

type
  TFields = class
  private
    fField : TDictionary<string,Variant>;
    function GetTag(const aKey: string) : Variant;
    procedure SetTag(const aKey: string; const aValue: Variant);
  public
    constructor Create;
    destructor Destroy; override;
    property Items[const Key: string]: Variant read GetTag write SetTag; default;
    function TryGetValue(const aKey : string; out oValue: Variant) : Boolean;
    procedure Add(const aKey: string; aValue: Variant);
  end;

   TGraylogAppender = class
   public
     constructor Create(sGraylogHost: string; iGraylogPort: integer);
     procedure Info(const cMsg: string); overload;
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
      procedure WriteLog();
   end;

implementation

{ TFields }

constructor TFields.Create;
begin
   fField := TDictionary<string,Variant>.Create;
end;

destructor TFields.Destroy;
begin
   fField.Free;
   inherited;
end;

procedure TFields.Add(const aKey: string; aValue: Variant);
begin
   fField.Add(aKey.ToUpper,aValue);
end;

function TFields.GetTag(const aKey: string): Variant;
begin
   if not fField.TryGetValue(aKey,Result) then
      raise Exception.CreateFmt('Log Tag "%s" not found!',[aKey]);
end;

procedure TFields.SetTag(const aKey: string; const aValue: Variant);
begin
   fField.AddOrSetValue(aKey.ToUpper, aValue);
end;

function TFields.TryGetValue(const aKey : string; out oValue : Variant): Boolean;
begin
   Result := fField.TryGetValue(aKey.ToUpper, oValue);
end;

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
   end;

//   Logger.RedirectOwnErrorsToProvider := GlobalLogFileProvider;
   Logger.Info('Create Graylog Appender');

   inherited Create;
end;

procedure TGraylogAppender.Info(const cMsg: string);
begin
   Logger.Info(cMsg);
end;

procedure TGraylogAppender.Info(const cMsg: string; aFields: TFields);
begin

   Logger.Info();
end;

procedure TGraylogAppender.WriteLog(cLogItem: TLogItem);
var
  json : TJSONObject;
  tagName : string;
  tagValue : string;
begin
  json := TJSONObject.Create;
  try
    json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('version',fGrayLogVersion);
    json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('host',SystemInfo.HostName);
    if fShortMessageAsEventType then
    begin
      json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('short_message',EventTypeName[cLogItem.EventType]);
      json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('full_message',cLogItem.Msg);
    end
    else
    begin
      json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('type',EventTypeName[cLogItem.EventType]);
      json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('short_message',cLogItem.Msg);
    end;
    {$IFDEF FPC}
      json.Add('timestamp',TJSONInt64Number.Create(DateTimeToUnix(cLogItem.EventDate)));
      json.Add('level',TJSONInt64Number.Create(EventTypeToSysLogLevel(cLogItem.EventType)));
    {$ELSE}
      {$IFDEF DELPHIXE7_UP}
      json.AddPair('timestamp',TJSONNumber.Create(DateTimeToUnix(cLogItem.EventDate,fJsonOutputOptions.UseUTCTime)));
      {$ELSE}
      json.AddPair('timestamp',TJSONNumber.Create(DateTimeToUnix(cLogItem.EventDate)));
      {$ENDIF}
      json.AddPair('level',TJSONNumber.Create(EventTypeToSysLogLevel(cLogItem.EventType)));
    {$ENDIF}

    if iiAppName in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_application',AppName);
    if iiEnvironment in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_environment',Environment);
    if iiPlatform in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_platform',PlatformInfo);
    if iiOSVersion in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_OS',SystemInfo.OSVersion);
    if iiUserName in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_user',SystemInfo.UserName);
    if iiThreadId in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_treadid',cLogItem.ThreadId.ToString);
    if iiProcessId in IncludedInfo then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}('_pid',SystemInfo.ProcessId.ToString);

    for tagName in IncludedTags do
    begin
      if fCustomTags.TryGetValue(tagName,tagValue) then json.{$IFDEF FPC}Add{$ELSE}AddPair{$ENDIF}(tagName,tagValue);
    end;

    {$IFDEF DELPHIXE8_UP}
    Result := json.ToJSON
    {$ELSE}
      {$IFDEF FPC}
      Result := json.AsJSON;
      {$ELSE}
      Result := json.ToString;
      {$ENDIF}
    {$ENDIF}
  finally
    json.Free;
  end;
end;

end.
