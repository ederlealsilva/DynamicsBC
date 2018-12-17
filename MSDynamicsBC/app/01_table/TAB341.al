table 341 "Item Discount Group"
{
    // version NAVW19.00

    Caption = 'Item Discount Group';
    LookupPageID = "Item Disc. Groups";

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
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Code",Description)
        {
        }
    }

    trigger OnDelete()
    var
        SalesLineDiscount: Record "Sales Line Discount";
    begin
        SalesLineDiscount.SetRange(Type,SalesLineDiscount.Type::"Item Disc. Group");
        SalesLineDiscount.SetRange(Code,Code);
        SalesLineDiscount.DeleteAll(true);
    end;
}

