table 1612 "Office Admin. Credentials"
{
    // version NAVW111.00

    Caption = 'Office Admin. Credentials';
    Permissions = TableData "Service Password"=rimd,
                  TableData "Office Admin. Credentials"=r;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;Email;Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;
            NotBlank = true;
        }
        field(3;Password;Text[250])
        {
            Caption = 'Password';
            ExtendedDatatype = Masked;
            NotBlank = true;
        }
        field(4;Endpoint;Text[250])
        {
            Caption = 'Endpoint';
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

    trigger OnInsert()
    begin
        if Endpoint = '' then
          Validate(Endpoint,DefaultEndpoint);
    end;

    trigger OnModify()
    begin
        if Endpoint = '' then
          Validate(Endpoint,DefaultEndpoint);
    end;

    [Scope('Personalization')]
    procedure DefaultEndpoint(): Text[250]
    begin
        exit('https://ps.outlook.com/powershell-liveid');
    end;

    procedure SavePassword(PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
        PasswordKeyGUID: Guid;
    begin
        PasswordText := DelChr(PasswordText,'=',' ');
        if Password <> '' then
          Evaluate(PasswordKeyGUID,Password);
        if IsNullGuid(PasswordKeyGUID) or not ServicePassword.Get(PasswordKeyGUID) then begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Insert(true);
          Password := ServicePassword.Key;
          Modify;
        end else begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Modify;
        end;
    end;

    procedure GetPassword(): Text
    var
        ServicePassword: Record "Service Password";
        PasswordKeyGUID: Guid;
    begin
        if Password <> '' then
          Evaluate(PasswordKeyGUID,Password);
        if not IsNullGuid(PasswordKeyGUID) then
          if ServicePassword.Get(PasswordKeyGUID) then
            exit(ServicePassword.GetPassword);
    end;
}

