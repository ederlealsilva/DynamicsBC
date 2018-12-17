table 1261 "Service Password"
{
    // version NAVW111.00

    Caption = 'Service Password';

    fields
    {
        field(1;"Key";Guid)
        {
            Caption = 'Key';
        }
        field(2;Value;BLOB)
        {
            Caption = 'Value';
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Key := CreateGuid;
    end;

    [Scope('Personalization')]
    procedure SavePassword(PasswordText: Text)
    var
        EncryptionManagement: Codeunit "Encryption Management";
        OutStream: OutStream;
    begin
        if EncryptionManagement.IsEncryptionPossible then
          PasswordText := EncryptionManagement.Encrypt(PasswordText);
        Value.CreateOutStream(OutStream);
        OutStream.Write(PasswordText);
    end;

    [Scope('Personalization')]
    procedure GetPassword(): Text
    var
        EncryptionManagement: Codeunit "Encryption Management";
        InStream: InStream;
        PasswordText: Text;
    begin
        CalcFields(Value);
        Value.CreateInStream(InStream);
        InStream.Read(PasswordText);
        if EncryptionManagement.IsEncryptionPossible then
          exit(EncryptionManagement.Decrypt(PasswordText));
        exit(PasswordText);
    end;
}

