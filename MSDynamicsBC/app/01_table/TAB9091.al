table 9091 "Postcode Service Config"
{
    // version NAVW111.00

    Caption = 'Postcode Service Config';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;ServiceKey;Text[250])
        {
            Caption = 'ServiceKey';
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

    procedure SaveServiceKey(ServiceKeyText: Text)
    var
        ServicePassword: Record "Service Password";
        ServiceKeyGUID: Guid;
    begin
        if ServiceKey <> '' then
          Evaluate(ServiceKeyGUID,ServiceKey);

        if IsNullGuid(ServiceKeyGUID) or not ServicePassword.Get(ServiceKeyGUID) then begin
          ServicePassword.SavePassword(ServiceKeyText);
          ServicePassword.Insert(true);
          ServiceKey := ServicePassword.Key;
          Modify;
        end else begin
          ServicePassword.SavePassword(ServiceKeyText);
          ServicePassword.Modify;
        end;
    end;

    procedure GetServiceKey(): Text
    var
        ServicePassword: Record "Service Password";
        ServiceKeyGUID: Guid;
    begin
        if ServiceKey <> '' then
          Evaluate(ServiceKeyGUID,ServiceKey);

        if not IsNullGuid(ServiceKeyGUID) then
          if ServicePassword.Get(ServiceKeyGUID) then
            exit(ServicePassword.GetPassword);
    end;
}

