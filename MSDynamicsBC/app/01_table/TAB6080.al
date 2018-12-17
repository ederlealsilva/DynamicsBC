table 6080 "Service Price Group"
{
    // version NAVW18.00

    Caption = 'Service Price Group';
    LookupPageID = "Service Price Groups";

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
        key(Key2;Description)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ServPriceGrpSetup: Record "Serv. Price Group Setup";
    begin
        ServPriceGrpSetup.SetRange("Service Price Group Code",Code);
        if ServPriceGrpSetup.FindFirst then
          ServPriceGrpSetup.DeleteAll;
    end;
}

