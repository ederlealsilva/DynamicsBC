table 5306 "Outlook Synch. Lookup Name"
{
    // version NAVW16.00

    Caption = 'Outlook Synch. Lookup Name';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2;Name;Text[80])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;Name)
        {
        }
    }

    fieldgroups
    {
    }
}

