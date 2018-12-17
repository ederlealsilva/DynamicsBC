table 2114 "O365 HTML Template"
{
    // version NAVW113.00

    Caption = 'O365 HTML Template';
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(7;"Media Resources Ref";Code[50])
        {
            Caption = 'Media Resources Ref';
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
}

