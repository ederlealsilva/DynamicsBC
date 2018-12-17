table 6700 "Exchange Sync"
{
    // version NAVW113.00

    Caption = 'Exchange Sync';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2;Enabled;Boolean)
        {
            Caption = 'Enabled';
        }
        field(3;"Exchange Service URI";Text[250])
        {
            Caption = 'Exchange Service URI';
            DataClassification = SystemMetadata;
        }
        field(4;"Exchange Account Password Key";Guid)
        {
            Caption = 'Exchange Account Password Key';
            TableRelation = "Service Password".Key;
        }
        field(5;"Last Sync Date Time";DateTime)
        {
            Caption = 'Last Sync Date Time';
            Editable = false;
        }
        field(7;"Folder ID";Text[30])
        {
            Caption = 'Folder ID';
        }
        field(9;"Filter";BLOB)
        {
            Caption = 'Filter';
        }
    }

    keys
    {
        key(Key1;"User ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeletePassword("Exchange Account Password Key");
    end;

    var
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';

    [Scope('Personalization')]
    procedure SetExchangeAccountPassword(PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        PasswordText := DelChr(PasswordText,'=',' ');

        if IsNullGuid("Exchange Account Password Key") or not ServicePassword.Get("Exchange Account Password Key") then begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Insert(true);
          "Exchange Account Password Key" := ServicePassword.Key;
        end else begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Modify;
        end;

        if PasswordText <> '' then
          CheckEncryption;
    end;

    procedure GetExchangeEndpoint() Endpoint: Text[250]
    var
        ExchangeWebServicesServer: Codeunit "Exchange Web Services Server";
    begin
        Endpoint := "Exchange Service URI";
        if Endpoint = '' then
          Endpoint := CopyStr(ExchangeWebServicesServer.GetEndpoint,1,250);
    end;

    local procedure CheckEncryption()
    begin
        if not EncryptionEnabled then
          if Confirm(EncryptionIsNotActivatedQst) then
            PAGE.Run(PAGE::"Data Encryption Management");
    end;

    local procedure DeletePassword(PasswordKey: Guid)
    var
        ServicePassword: Record "Service Password";
    begin
        if ServicePassword.Get(PasswordKey) then
          ServicePassword.Delete;
    end;

    [Scope('Personalization')]
    procedure SaveFilter(FilterText: Text)
    var
        WriteStream: OutStream;
    begin
        Clear(Filter);
        Filter.CreateOutStream(WriteStream);
        WriteStream.WriteText(FilterText);
    end;

    [Scope('Personalization')]
    procedure GetSavedFilter() FilterText: Text
    var
        ReadStream: InStream;
    begin
        CalcFields(Filter);
        Filter.CreateInStream(ReadStream);
        ReadStream.ReadText(FilterText);
    end;

    [Scope('Personalization')]
    procedure DeleteActivityLog()
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.SetRange("Record ID",RecordId);
        ActivityLog.DeleteAll;
    end;
}

