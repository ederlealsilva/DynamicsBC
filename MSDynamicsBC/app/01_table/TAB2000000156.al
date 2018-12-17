table 2000000156 "NAV App Published App"
{
    // version NAVW113.00

    Caption = 'NAV App Published App';
    DataPerCompany = false;

    fields
    {
        field(1;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(2;"Version Major";Integer)
        {
            Caption = 'Version Major';
        }
        field(3;"Version Minor";Integer)
        {
            Caption = 'Version Minor';
        }
        field(4;"Version Build";Integer)
        {
            Caption = 'Version Build';
        }
        field(5;"Version Revision";Integer)
        {
            Caption = 'Version Revision';
        }
        field(6;"Package ID";Guid)
        {
            Caption = 'Package ID';
        }
        field(7;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(8;Publisher;Text[250])
        {
            Caption = 'Publisher';
        }
        field(9;"Content Hash";Text[250])
        {
            Caption = 'Content Hash';
        }
        field(10;"Hash Algorithm";Integer)
        {
            Caption = 'Hash Algorithm';
        }
    }

    keys
    {
        key(Key1;"App ID","Version Major","Version Minor","Version Build","Version Revision")
        {
        }
    }

    fieldgroups
    {
    }
}

