table 7307 "Put-away Template Header"
{
    // version NAVW113.00

    Caption = 'Put-away Template Header';
    LookupPageID = "Put-away Template List";
    ReplicateData = false;

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
        PutAwayTemplateLine: Record "Put-away Template Line";
    begin
        PutAwayTemplateLine.SetRange("Put-away Template Code",Code);
        PutAwayTemplateLine.DeleteAll;
    end;
}

