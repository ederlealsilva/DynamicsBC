table 8451 "Intrastat Checklist Setup"
{
    // version NAVW113.00

    Caption = 'Intrastat Checklist Setup';

    fields
    {
        field(1;"Field No.";Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.Get(DATABASE::"Intrastat Jnl. Line","Field No.");
                "Field Name" := Field.FieldName;
            end;
        }
        field(2;"Field Name";Text[30])
        {
            Caption = 'Field Name';
        }
    }

    keys
    {
        key(Key1;"Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure LookupFieldName()
    var
        "Field": Record "Field";
        FieldList: Page "Field List";
    begin
        Clear(FieldList);
        Field.SetRange(TableNo,DATABASE::"Intrastat Jnl. Line");
        Field.SetFilter("No.",'<>1&<>2&<>3');
        Field.SetRange(Class,Field.Class::Normal);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        FieldList.SetTableView(Field);
        FieldList.LookupMode := true;
        if FieldList.RunModal = ACTION::LookupOK then begin
          FieldList.GetRecord(Field);
          Validate("Field No.",Field."No.");
        end;
    end;
}

