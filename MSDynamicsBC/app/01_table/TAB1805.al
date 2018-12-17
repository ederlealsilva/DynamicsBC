table 1805 "Encrypted Key/Value"
{
    // version NAVW111.00

    Caption = 'Encrypted Key/Value';
    DataPerCompany = false;

    fields
    {
        field(1;"Key";Code[50])
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

    [Scope('Personalization')]
    procedure GetValue(): Text
    var
        EncryptionManagement: Codeunit "Encryption Management";
        InStr: InStream;
        Result: Text;
    begin
        if not Value.HasValue then
          exit('');

        CalcFields(Value);
        Value.CreateInStream(InStr);
        InStr.Read(Result);

        if EncryptionManagement.IsEncryptionEnabled then
          exit(EncryptionManagement.Decrypt(Result));

        exit('');
    end;

    [Scope('Personalization')]
    procedure InsertValue(NewValue: Text)
    var
        EncryptionManagement: Codeunit "Encryption Management";
        OutStr: OutStream;
        EncryptedText: Text;
    begin
        // Encryption must be enabled on insert
        EncryptedText := EncryptionManagement.Encrypt(NewValue);
        Value.CreateOutStream(OutStr);
        OutStr.Write(EncryptedText);
    end;
}

