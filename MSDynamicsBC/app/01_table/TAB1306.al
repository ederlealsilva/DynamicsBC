table 1306 "User Preference"
{
    // version NAVW113.00

    Caption = 'User Preference';
    ReplicateData = false;

    fields
    {
        field(1;"User ID";Text[132])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(2;"Instruction Code";Code[50])
        {
            Caption = 'Instruction Code';
        }
        field(3;"User Selection";BLOB)
        {
            Caption = 'User Selection';
        }
    }

    keys
    {
        key(Key1;"User ID","Instruction Code")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure DisableInstruction(InstrCode: Code[50])
    var
        UserPreference: Record "User Preference";
    begin
        if not UserPreference.Get(UserId,InstrCode) then begin
          UserPreference.Init;
          UserPreference."User ID" := UserId;
          UserPreference."Instruction Code" := InstrCode;
          UserPreference.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure EnableInstruction(InstrCode: Code[50])
    var
        UserPreference: Record "User Preference";
    begin
        if UserPreference.Get(UserId,InstrCode) then
          UserPreference.Delete;
    end;

    [Scope('Personalization')]
    procedure GetUserSelectionAsText() ReturnValue: Text
    var
        Instream: InStream;
    begin
        "User Selection".CreateInStream(Instream);
        Instream.ReadText(ReturnValue);
    end;

    [Scope('Personalization')]
    procedure SetUserSelection(Variant: Variant)
    var
        OutStream: OutStream;
    begin
        "User Selection".CreateOutStream(OutStream);
        OutStream.WriteText(Format(Variant));
    end;
}

