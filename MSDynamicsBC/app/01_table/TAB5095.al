table 5095 "Duplicate Search String Setup"
{
    // version NAVW113.00

    Caption = 'Duplicate Search String Setup';

    fields
    {
        field(1;"Field No.";Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                Field.Get(DATABASE::Contact,"Field No.");
                "Field Name" := Field.FieldName;
            end;
        }
        field(2;"Part of Field";Option)
        {
            Caption = 'Part of Field';
            OptionCaption = 'First,Last';
            OptionMembers = First,Last;
        }
        field(3;Length;Integer)
        {
            Caption = 'Length';
            InitValue = 5;
            MaxValue = 10;
            MinValue = 2;
        }
        field(4;"Field Name";Text[30])
        {
            Caption = 'Field Name';
        }
    }

    keys
    {
        key(Key1;"Field No.","Part of Field")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ContDuplicateSearchString: Record "Cont. Duplicate Search String";
    begin
        ContDuplicateSearchString.SetRange("Field No.","Field No.");
        ContDuplicateSearchString.SetRange("Part of Field","Part of Field");
        ContDuplicateSearchString.DeleteAll;
    end;

    [Scope('Personalization')]
    procedure CreateDefaultSetup()
    var
        Contact: Record Contact;
    begin
        DeleteAll;

        InsertDuplicateSearchString(Contact.FieldNo(Name),5);
        InsertDuplicateSearchString(Contact.FieldNo(Address),5);
        InsertDuplicateSearchString(Contact.FieldNo(City),5);
        InsertDuplicateSearchString(Contact.FieldNo("Phone No."),5);
        InsertDuplicateSearchString(Contact.FieldNo("VAT Registration No."),5);
        InsertDuplicateSearchString(Contact.FieldNo("Post Code"),5);
        InsertDuplicateSearchString(Contact.FieldNo("E-Mail"),5);
        InsertDuplicateSearchString(Contact.FieldNo("Mobile Phone No."),5);
    end;

    local procedure InsertDuplicateSearchString(FieldNo: Integer;SearchLength: Integer)
    begin
        Init;
        Validate("Field No.",FieldNo);
        Validate("Part of Field","Part of Field"::First);
        Validate(Length,SearchLength);
        Insert;

        Validate("Part of Field","Part of Field"::Last);
        Insert;
    end;

    [Scope('Personalization')]
    procedure LookupFieldName()
    var
        "Field": Record "Field";
        FieldList: Page "Field List";
    begin
        Clear(FieldList);
        Field.SetRange(TableNo,DATABASE::Contact);
        Field.SetFilter(Type,'%1|%2',Field.Type::Text,Field.Type::Code);
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

