table 2000000153 "NAV App Installed App"
{
    // version NAVW113.00

    Caption = 'NAV App Installed App';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(2;"Package ID";Guid)
        {
            Caption = 'Package ID';
        }
        field(3;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(4;Publisher;Text[250])
        {
            Caption = 'Publisher';
        }
        field(5;"Version Major";Integer)
        {
            Caption = 'Version Major';
        }
        field(6;"Version Minor";Integer)
        {
            Caption = 'Version Minor';
        }
        field(7;"Version Build";Integer)
        {
            Caption = 'Version Build';
        }
        field(8;"Version Revision";Integer)
        {
            Caption = 'Version Revision';
        }
        field(9;"Compatibility Major";Integer)
        {
            Caption = 'Compatibility Major';
        }
        field(10;"Compatibility Minor";Integer)
        {
            Caption = 'Compatibility Minor';
        }
        field(11;"Compatibility Build";Integer)
        {
            Caption = 'Compatibility Build';
        }
        field(12;"Compatibility Revision";Integer)
        {
            Caption = 'Compatibility Revision';
        }
        field(13;"Content Hash";Text[250])
        {
            Caption = 'Content Hash';
        }
        field(14;"Hash Algorithm";Integer)
        {
            Caption = 'Hash Algorithm';
        }
        field(15;"Extension Type";Integer)
        {
            Caption = 'Extension Type';
        }
    }

    keys
    {
        key(Key1;"App ID")
        {
        }
    }

    fieldgroups
    {
    }
}

