table 5068 Salutation
{
    // version NAVW17.00

    Caption = 'Salutation';
    LookupPageID = Salutations;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
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

    trigger OnDelete()
    var
        SalutationFormula: Record "Salutation Formula";
    begin
        SalutationFormula.SetRange("Salutation Code",Code);
        SalutationFormula.DeleteAll;
    end;
}

