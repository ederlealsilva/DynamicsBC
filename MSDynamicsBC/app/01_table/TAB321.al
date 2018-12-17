table 321 "Tax Group"
{
    // version NAVW111.00

    Caption = 'Tax Group';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Tax Groups";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(8000;Id;Guid)
        {
            Caption = 'Id';
        }
        field(8005;"Last Modified DateTime";DateTime)
        {
            Caption = 'Last Modified DateTime';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        SetLastModifiedDateTime;
    end;

    trigger OnModify()
    begin
        SetLastModifiedDateTime;
    end;

    trigger OnRename()
    begin
        SetLastModifiedDateTime;
    end;

    [Scope('Personalization')]
    procedure CreateTaxGroup(NewTaxGroupCode: Code[20])
    begin
        Init;
        Code := NewTaxGroupCode;
        Description := NewTaxGroupCode;
        Insert;
    end;

    local procedure SetLastModifiedDateTime()
    begin
        "Last Modified DateTime" := CurrentDateTime;
    end;
}

