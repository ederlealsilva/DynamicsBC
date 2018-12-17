table 1432 "Net Promoter Score Setup"
{
    // version NAVW113.00

    Caption = 'Net Promoter Score Setup';
    DataPerCompany = false;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"API URL";BLOB)
        {
            Caption = 'API URL';
        }
        field(3;"Expire Time";DateTime)
        {
            Caption = 'Expire Time';
        }
        field(4;"Time Between Requests";Integer)
        {
            Caption = 'Time Between Requests';
            ObsoleteReason = 'This field is not needed and it is not used anymore.';
            ObsoleteState = Removed;
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
        NpsApiUrlTxt: Label 'NpsApiUrl', Locked=true;
        NpsCacheLifeTimeTxt: Label 'NpsCacheLifeTime', Locked=true;

    procedure GetApiUrl(): Text
    var
        InStream: InStream;
        ApiUrl: Text;
    begin
        SetApiUrl;

        if not Get then
          exit('');

        ApiUrl := '';
        CalcFields("API URL");
        if "API URL".HasValue then begin
          "API URL".CreateInStream(InStream);
          InStream.Read(ApiUrl);
        end;
        exit(ApiUrl);
    end;

    local procedure SetApiUrl()
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        OutStream: OutStream;
        ApiUrl: Text;
        CacheLifeTime: Integer;
    begin
        if Get then
          if CurrentDateTime < "Expire Time" then
            exit;

        CacheLifeTime := MinCacheLifeTime;
        if AzureKeyVaultManagement.IsEnable then
          if AzureKeyVaultManagement.GetAzureKeyVaultSecret(ApiUrl,NpsApiUrlTxt) then
            CacheLifeTime := GetCacheLifeTime;

        LockTable;

        if not Get then begin
          Init;
          "Primary Key" := '';
          Insert;
        end;

        if ApiUrl = '' then
          Clear("API URL")
        else begin
          "API URL".CreateOutStream(OutStream);
          OutStream.Write(ApiUrl);
        end;
        "Expire Time" := CurrentDateTime + CacheLifeTime * MillisecondsInMinute;
        Modify;

        Commit;
    end;

    local procedure GetCacheLifeTime(): Integer
    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        CacheLifeTimeValue: Text;
        CacheLifeTimeNumber: Integer;
    begin
        if AzureKeyVaultManagement.GetAzureKeyVaultSecret(CacheLifeTimeValue,NpsCacheLifeTimeTxt) then
          if Evaluate(CacheLifeTimeNumber,CacheLifeTimeValue) then begin
            if CacheLifeTimeNumber < MinCacheLifeTime then
              CacheLifeTimeNumber := MinCacheLifeTime;
            exit(CacheLifeTimeNumber);
          end;
        exit(MinCacheLifeTime);
    end;

    local procedure MinCacheLifeTime(): Integer
    begin
        exit(1); // one minute
    end;

    local procedure MillisecondsInMinute(): Integer
    begin
        exit(60000);
    end;
}

