table 2000000144 "Power BI Blob"
{
    // version NAVW113.00

    Caption = 'Power BI Blob';
    DataPerCompany = false;

    fields
    {
        field(1;Id;Guid)
        {
            Caption = 'Id';
        }
        field(2;"Blob File";BLOB)
        {
            Caption = 'Blob File';
        }
        field(3;Name;Text[200])
        {
            Caption = 'Name';
        }
        field(4;Version;Integer)
        {
            Caption = 'Version';
        }
        field(5;"GP Enabled";Boolean)
        {
            Caption = 'GP Enabled';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }
}

