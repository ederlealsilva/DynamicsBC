table 7 "Standard Text"
{
    // version NAVW111.00

    Caption = 'Standard Text';
    LookupPageID = "Standard Text Codes";

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
    }

    trigger OnDelete()
    begin
        ExtTextHeader.SetRange("Table Name",ExtTextHeader."Table Name"::"Standard Text");
        ExtTextHeader.SetRange("No.",Code);
        ExtTextHeader.DeleteAll(true);
    end;

    trigger OnRename()
    var
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
    begin
        SalesLine.RenameNo(SalesLine.Type::" ",xRec.Code,Code);
        PurchaseLine.RenameNo(PurchaseLine.Type::" ",xRec.Code,Code);
    end;

    var
        ExtTextHeader: Record "Extended Text Header";
}

