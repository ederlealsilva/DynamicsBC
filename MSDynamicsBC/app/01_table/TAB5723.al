table 5723 "Product Group"
{
    // version NAVW113.00

    Caption = 'Product Group';
    LookupPageID = "Product Groups";
    ObsoleteReason = 'Product Groups became first level children of Item Categories.';
    ObsoleteState = Removed;

    fields
    {
        field(1;"Item Category Code";Code[20])
        {
            Caption = 'Item Category Code';
            NotBlank = true;
            TableRelation = "Item Category".Code;
            ValidateTableRelation = false;
        }
        field(2;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(7300;"Warehouse Class Code";Code[10])
        {
            Caption = 'Warehouse Class Code';
            TableRelation = "Warehouse Class";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1;"Item Category Code","Code")
        {
        }
    }

    fieldgroups
    {
    }
}

