table 6082 "Service Price Adjustment Group"
{
    // version NAVW17.00

    Caption = 'Service Price Adjustment Group';
    LookupPageID = "Serv. Price Adjmt. Group";

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
        ServPriceAdjmtDetail: Record "Serv. Price Adjustment Detail";
    begin
        ServPriceAdjmtDetail.SetRange("Serv. Price Adjmt. Gr. Code",Code);
        if ServPriceAdjmtDetail.FindFirst then
          ServPriceAdjmtDetail.DeleteAll;
    end;
}

