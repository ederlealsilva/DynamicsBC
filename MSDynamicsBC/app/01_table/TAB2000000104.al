table 2000000104 "Debugger Watch"
{
    // version NAVW113.00

    Caption = 'Debugger Watch';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
        }
        field(7;Path;Text[124])
        {
            Caption = 'Path';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;Path)
        {
        }
    }

    fieldgroups
    {
    }
}

