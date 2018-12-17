table 1260 "Bank Data Conv. Service Setup"
{
    // version NAVW113.00

    Caption = 'Bank Data Conv. Service Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"User Name";Text[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            Editable = true;
        }
        field(3;"Password Key";Guid)
        {
            Caption = 'Password Key';
            TableRelation = "Service Password".Key;
        }
        field(4;"Sign-up URL";Text[250])
        {
            Caption = 'Sign-up URL';
            ExtendedDatatype = URL;
        }
        field(5;"Service URL";Text[250])
        {
            Caption = 'Service URL';

            trigger OnValidate()
            var
                WebRequestHelper: Codeunit "Web Request Helper";
            begin
                if "Service URL" <> '' then
                  WebRequestHelper.IsSecureHttpUrl("Service URL");
            end;
        }
        field(6;"Support URL";Text[250])
        {
            Caption = 'Support URL';
            ExtendedDatatype = URL;
        }
        field(7;"Namespace API Version";Text[10])
        {
            Caption = 'Namespace API Version';
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

    trigger OnDelete()
    begin
        DeletePassword;
    end;

    trigger OnInsert()
    var
        BankDataConvServMgt: Codeunit "Bank Data Conv. Serv. Mgt.";
    begin
        if "User Name" = '' then
          BankDataConvServMgt.InitDefaultURLs(Rec);
    end;

    var
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
        PermissionManager: Codeunit "Permission Manager";
        UserNameSecretTxt: Label 'amcname', Locked=true;
        PasswordSecretTxt: Label 'amcpassword', Locked=true;
        CompanyInformationMgt: Codeunit "Company Information Mgt.";

    [Scope('Personalization')]
    procedure SavePassword(PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid("Password Key") or not ServicePassword.Get("Password Key") then begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Insert(true);
          "Password Key" := ServicePassword.Key;
        end else begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Modify;
        end;
    end;

    procedure GetUserName(): Text[50]
    begin
        if DemoSaaSCompany and ("User Name" = '') then
          exit(RetrieveSaaSUserName);

        exit("User Name");
    end;

    procedure GetPassword(): Text
    var
        ServicePassword: Record "Service Password";
    begin
        // if Demo Company and empty User Name retrieve from Azure Key Vault
        if DemoSaaSCompany and ("User Name" = '') then
          exit(RetrieveSaaSPass);

        ServicePassword.Get("Password Key");
        exit(ServicePassword.GetPassword);
    end;

    local procedure DeletePassword()
    var
        ServicePassword: Record "Service Password";
    begin
        if ServicePassword.Get("Password Key") then
          ServicePassword.Delete;
    end;

    [Scope('Personalization')]
    procedure HasUserName(): Boolean
    begin
        // if Demo Company try to retrieve from Azure Key Vault
        if DemoSaaSCompany then
          exit(true);

        exit("User Name" <> '');
    end;

    [Scope('Personalization')]
    procedure HasPassword(): Boolean
    var
        ServicePassword: Record "Service Password";
    begin
        if DemoSaaSCompany and ("User Name" = '') then
          exit(true);

        exit(ServicePassword.Get("Password Key"));
    end;

    [Scope('Personalization')]
    procedure SetURLsToDefault()
    var
        BankDataConvServMgt: Codeunit "Bank Data Conv. Serv. Mgt.";
    begin
        BankDataConvServMgt.SetURLsToDefault(Rec);
    end;

    local procedure RetrieveSaaSUserName(): Text[50]
    var
        UserNameValue: Text[50];
    begin
        if AzureKeyVaultManagement.GetAzureKeyVaultSecret(UserNameValue,UserNameSecretTxt) then
          exit(UserNameValue);
    end;

    local procedure RetrieveSaaSPass(): Text
    var
        PasswordValue: Text;
    begin
        if AzureKeyVaultManagement.GetAzureKeyVaultSecret(PasswordValue,PasswordSecretTxt) then
          exit(PasswordValue);
    end;

    local procedure DemoSaaSCompany(): Boolean
    begin
        exit(PermissionManager.SoftwareAsAService and CompanyInformationMgt.IsDemoCompany);
    end;
}

