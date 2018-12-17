table 2020 "Image Analysis Setup"
{
    // version NAVW113.00

    Caption = 'Image Analysis Setup';
    DataPerCompany = false;
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Period start date";DateTime)
        {
            Caption = 'Period start date';
            ObsoleteReason = 'Use of Table 2003 to track usage instead.';
            ObsoleteState = Removed;
        }
        field(3;"Number of calls";Integer)
        {
            Caption = 'Number of calls';
            ObsoleteReason = 'Use of Table 2003 to track usage instead.';
            ObsoleteState = Removed;
        }
        field(4;"Api Uri";Text[250])
        {
            Caption = 'Api Uri';

            trigger OnValidate()
            begin
                ValidateApiUri;
            end;
        }
        field(5;"Api Key Key";Guid)
        {
            Caption = 'Api Key Key';
            ExtendedDatatype = Masked;
        }
        field(6;"Limit value";Integer)
        {
            Caption = 'Limit value';
            ObsoleteReason = 'Use of Table 2003 to track usage instead.';
            ObsoleteState = Removed;
        }
        field(7;"Limit type";Option)
        {
            Caption = 'Limit type';
            ObsoleteReason = 'Use of Table 2003 to track usage instead.';
            ObsoleteState = Removed;
            OptionCaption = 'Year,Month,Day,Hour';
            OptionMembers = Year,Month,Day,Hour;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        TooManyCallsErr: Label 'Sorry, you''ll have to wait until the start of the next %2. You can analyze %1 images per %2, and you''ve already hit the limit.', Comment='%1 is the number of calls per time unit allowed, %2 is the time unit duration (year, month, day, or hour)';
        InvalidApiUriErr: Label 'The Api Uri must be a valid Uri for Cognitive Services.';
        DoYouWantURICorrectedQst: Label 'The API URI must end with "/analyze." Should we add that for you?';

    procedure Increment()
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    begin
        GetSingleInstance;
        if (GetApiKey <> '' ) and ("Api Uri" <> '') then
          exit; // unlimited access for user's own service

        CortanaIntelligenceUsage.IncrementTotalProcessingTime(CortanaIntelligenceUsage.Service::"Computer Vision",1);
    end;

    [Scope('Personalization')]
    procedure IsUsageLimitReached(var UsageLimitError: Text;MaxCallsPerPeriod: Integer;PeriodType: Option Year,Month,Day,Hour): Boolean
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    begin
        if (GetApiKey <> '' ) and ("Api Uri" <> '') then
          exit(false); // unlimited access for user's own service

        if CortanaIntelligenceUsage.IsAzureMLLimitReached(CortanaIntelligenceUsage.Service::"Computer Vision",MaxCallsPerPeriod) then begin
          UsageLimitError := StrSubstNo(TooManyCallsErr,Format(MaxCallsPerPeriod),LowerCase(Format(PeriodType)));
          exit(true);
        end;

        exit(false);
    end;

    procedure ValidateApiUri()
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        "Api Uri" := DelChr("Api Uri",'>',' /');
        // For security reasons we are making sure its a cognitive services URI that is being inserted
        if "Api Uri" <> '' then
          if not TypeHelper.IsMatch("Api Uri",'https://([a-z0-9]|\.)*\.api\.cognitive\.microsoft.com/.*') then
            Error(InvalidApiUriErr);

        if not GuiAllowed then
          exit;
        if StrPos(LowerCase("Api Uri"),'/vision/') = 0 then
          exit;

        // Uri must end in /analyze if it is the default vision URI
        if not EndsInAnalyze("Api Uri") then
          if Confirm(DoYouWantURICorrectedQst) then
            "Api Uri" += '/analyze';
    end;

    local procedure EndsInAnalyze(ApiUri: Text): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.TextEndsWith(LowerCase(ApiUri),'/analyze'));
    end;

    [Scope('Personalization')]
    procedure SetApiKey(ApiKey: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid("Api Key Key") or not ServicePassword.Get("Api Key Key") then begin
          ServicePassword.SavePassword(ApiKey);
          ServicePassword.Insert(true);
          "Api Key Key" := ServicePassword.Key;
        end else begin
          ServicePassword.SavePassword(ApiKey);
          ServicePassword.Modify(true);
        end;
    end;

    [Scope('Personalization')]
    procedure GetApiKey(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        if not IsNullGuid("Api Key Key") then
          if ServicePassword.Get("Api Key Key") then
            exit(ServicePassword.GetPassword);
    end;

    [Scope('Personalization')]
    procedure GetSingleInstance()
    begin
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

