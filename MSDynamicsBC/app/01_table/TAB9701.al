table 9701 "Cue Setup"
{
    // version NAVW113.00

    Caption = 'Cue Setup';

    fields
    {
        field(1;"User Name";Code[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User Name");
            end;
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table),
                                                                 "Object Name"=FILTER('*Cue'));

            trigger OnValidate()
            begin
                // Force a calculation, even if the FieldNo hasn't yet been filled out (i.e. the record hasn't been inserted yet)
                CalcFields("Table Name")
            end;
        }
        field(3;"Field No.";Integer)
        {
            Caption = 'Cue ID';
            TableRelation = Field."No.";

            trigger OnLookup()
            var
                "Field": Record "Field";
                FieldsLookup: Page "Fields Lookup";
                "Filter": Text[250];
            begin
                // Look up in the Fields virtual table
                // Filter on Table No=Table No and Type=Decimal|Integer. This should give us approximately the
                // fields that are "valid" for a cue control.
                Field.SetRange(TableNo,"Table ID");
                Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
                Filter := Format(Field.Type::Decimal) + '|' + Format(Field.Type::Integer);
                Field.SetFilter(Type,Filter);
                FieldsLookup.SetTableView(Field);
                FieldsLookup.LookupMode(true);
                if FieldsLookup.RunModal = ACTION::LookupOK then begin
                  FieldsLookup.GetRecord(Field);
                  "Field No." := Field."No.";
                end;
            end;
        }
        field(4;"Field Name";Text[80])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field No.")));
            Caption = 'Cue Name';
            FieldClass = FlowField;
        }
        field(5;"Low Range Style";Option)
        {
            Caption = 'Low Range Style', Comment='The Style to use if the cue''s value is below Threshold 1';
            OptionCaption = 'None,,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate';
            OptionMembers = "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        }
        field(6;"Threshold 1";Decimal)
        {
            Caption = 'Threshold 1';

            trigger OnValidate()
            begin
                ValidateThresholds;
            end;
        }
        field(7;"Middle Range Style";Option)
        {
            Caption = 'Middle Range Style', Comment='The Style to use if the cue''s value is between Threshold 1 and Threshold 2';
            OptionCaption = 'None,,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate';
            OptionMembers = "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        }
        field(8;"Threshold 2";Decimal)
        {
            Caption = 'Threshold 2';

            trigger OnValidate()
            begin
                ValidateThresholds;
            end;
        }
        field(9;"High Range Style";Option)
        {
            Caption = 'High Range Style', Comment='The Style to use if the cue''s value is above Threshold 2';
            OptionCaption = 'None,,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate';
            OptionMembers = "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        }
        field(10;"Table Name";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object ID"=FIELD("Table ID"),
                                                                           "Object Type"=CONST(Table)));
            Caption = 'Table Name';
            FieldClass = FlowField;
        }
        field(11;Personalized;Boolean)
        {
            Caption = 'Personalized';
        }
    }

    keys
    {
        key(Key1;"User Name","Table ID","Field No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Table Name","Field Name","Threshold 1",Personalized,"Threshold 2")
        {
        }
    }

    var
        TextErr001: Label '%1 must be greater than %2.';

    [Scope('Personalization')]
    procedure ConvertStyleToStyleText(Style: Option): Text
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        StyleIndex: Integer;
    begin
        RecordRef.GetTable(Rec);
        FieldRef := RecordRef.Field(FieldNo("Low Range Style"));

        // Default to return the None Style
        StyleIndex := 1;

        // The style must be in the range of existing style options
        if (Style > 0) and (Style <= 10) then
          StyleIndex := Style + 1;

        exit(SelectStr(StyleIndex,FieldRef.OptionString));
    end;

    [Scope('Personalization')]
    procedure GetStyleForValue(CueValue: Decimal): Integer
    begin
        if CueValue < "Threshold 1" then
          exit("Low Range Style");
        if CueValue > "Threshold 2" then
          exit("High Range Style");
        exit("Middle Range Style");
    end;

    local procedure ValidateThresholds()
    begin
        if "Threshold 2" <= "Threshold 1" then
          Error(
            TextErr001,
            FieldCaption("Threshold 2"),
            FieldCaption("Threshold 1"));
    end;
}

