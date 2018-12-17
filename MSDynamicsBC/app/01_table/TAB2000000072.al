table 2000000072 "Profile"
{
    // version NAVW110.0

    Caption = 'Profile';
    DataPerCompany = false;

    fields
    {
        field(3;"Profile ID";Code[30])
        {
            Caption = 'Profile ID';
        }
        field(12;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(15;"Role Center ID";Integer)
        {
            Caption = 'Role Center ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Page));
        }
        field(18;"Default Role Center";Boolean)
        {
            Caption = 'Default Role Center';
        }
        field(21;"Use Comments";Boolean)
        {
            Caption = 'Use Comments';
        }
        field(24;"Use Notes";Boolean)
        {
            Caption = 'Use Notes';
        }
        field(27;"Use Record Notes";Boolean)
        {
            Caption = 'Use Record Notes';
        }
        field(30;"Record Notebook";Text[250])
        {
            Caption = 'Record Notebook';
        }
        field(33;"Use Page Notes";Boolean)
        {
            Caption = 'Use Page Notes';
        }
        field(36;"Page Notebook";Text[250])
        {
            Caption = 'Page Notebook';
        }
        field(39;"Disable Personalization";Boolean)
        {
            Caption = 'Disable Personalization';
        }
    }

    keys
    {
        key(Key1;"Profile ID")
        {
        }
    }

    fieldgroups
    {
    }
}

