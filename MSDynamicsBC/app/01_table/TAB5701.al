table 5701 "Stockkeeping Unit Comment Line"
{
    // version NAVW111.00

    Caption = 'Stockkeeping Unit Comment Line';
    DrillDownPageID = "Stockkeeping Unit Comment List";
    LookupPageID = "Stockkeeping Unit Comment List";

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
        }
        field(3;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location WHERE ("Use As In-Transit"=CONST(false));
        }
        field(4;"Line No.";Integer)
        {
            BlankZero = false;
            Caption = 'Line No.';
        }
        field(5;Date;Date)
        {
            Caption = 'Date';
        }
        field(6;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(7;Comment;Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code","Location Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetUpNewLine()
    var
        stockkeepingcommentline: Record "Stockkeeping Unit Comment Line";
    begin
        stockkeepingcommentline.SetRange("Item No.","Item No.");
        stockkeepingcommentline.SetRange("Variant Code","Variant Code");
        stockkeepingcommentline.SetRange("Location Code","Location Code");
        stockkeepingcommentline.SetRange(Date,WorkDate);
        if not stockkeepingcommentline.FindFirst then
          Date := WorkDate;
    end;
}

