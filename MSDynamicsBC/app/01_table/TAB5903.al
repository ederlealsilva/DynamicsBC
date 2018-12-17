table 5903 "Service Order Type"
{
    // version NAVW17.00

    Caption = 'Service Order Type';
    LookupPageID = "Service Order Types";

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
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.DeleteDefaultDim(DATABASE::"Service Order Type",Code);
    end;
}

