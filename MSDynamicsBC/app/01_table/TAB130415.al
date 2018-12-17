table 130415 "Semi-Manual Test Wizard"
{
    // version NAVW111.00

    Caption = 'Semi-Manual Test Wizard';

    fields
    {
        field(1;"Codeunit number";Integer)
        {
            BlankZero = true;
            Caption = 'Codeunit number';
        }
        field(2;"Codeunit name";Text[250])
        {
            Caption = 'Codeunit name';
        }
        field(3;"Step number";Integer)
        {
            Caption = 'Step number';
        }
        field(4;"Step heading";Text[250])
        {
            Caption = 'Step heading';
        }
        field(5;"Manual detailed steps";BLOB)
        {
            Caption = 'Manual detailed steps';
        }
        field(6;"Total steps";Integer)
        {
            Caption = 'Total steps';
        }
        field(7;"Skip current step";Boolean)
        {
            Caption = 'Skip current step';
        }
    }

    keys
    {
        key(Key1;"Codeunit name")
        {
        }
    }

    fieldgroups
    {
    }

    var
        InvalidCodeunitErr: Label 'Codeunit %1 does not seem to be valid for a manual test.', Locked=true;

    procedure Initialize(CodeunitId: Integer;CodeunitName: Text[250])
    var
        FailureCondition: Boolean;
    begin
        Init;
        "Codeunit number" := CodeunitId;
        "Codeunit name" := CodeunitName;
        FailureCondition := not CODEUNIT.Run("Codeunit number",Rec);
        FailureCondition := FailureCondition or ("Total steps" = 0);
        if FailureCondition then
          Error(InvalidCodeunitErr,"Codeunit number");
    end;

    procedure SetManualSteps(Steps: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.GetTable(Rec);
        FieldRef := RecordRef.Field(FieldNo("Manual detailed steps"));
        TypeHelper.WriteBlob(FieldRef,Steps);
        RecordRef.SetTable(Rec);
    end;

    procedure GetManualSteps(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.GetTable(Rec);
        FieldRef := RecordRef.Field(FieldNo("Manual detailed steps"));
        exit(TypeHelper.ReadBlob(FieldRef));
    end;
}

