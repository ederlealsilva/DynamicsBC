table 2000000152 "NAV App Data Archive"
{
    // version NAVW113.00

    Caption = 'NAV App Data Archive';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(3;"Company Name";Text[30])
        {
            Caption = 'Company Name';
        }
        field(4;"Version Major";Integer)
        {
            Caption = 'Version Major';
        }
        field(5;"Version Minor";Integer)
        {
            Caption = 'Version Minor';
        }
        field(6;"Version Build";Integer)
        {
            Caption = 'Version Build';
        }
        field(7;"Version Revision";Integer)
        {
            Caption = 'Version Revision';
        }
        field(8;"Archive Table Name";Text[128])
        {
            Caption = 'Archive Table Name';
        }
        field(9;Metadata;BLOB)
        {
            Caption = 'Metadata';
        }
        field(10;"Table Blob Version";Integer)
        {
            Caption = 'Table Blob Version';
        }
    }

    keys
    {
        key(Key1;"App ID","Table ID","Company Name")
        {
        }
    }

    fieldgroups
    {
    }
}

