table 2000000169 "NAV App Tenant Add-In"
{
    // version NAVW113.00

    Caption = 'NAV App Tenant Add-In';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(2;"Add-In Name";Text[220])
        {
            Caption = 'Add-In Name';
        }
        field(3;"Public Key Token";Text[20])
        {
            Caption = 'Public Key Token';
        }
        field(4;Version;Text[25])
        {
            Caption = 'Version';
        }
        field(5;Category;Option)
        {
            Caption = 'Category';
            OptionCaption = 'JavaScript Control Add-in,DotNet Control Add-in,DotNet Interoperability,Language Resource';
            OptionMembers = "JavaScript Control Add-in","DotNet Control Add-in","DotNet Interoperability","Language Resource";
        }
        field(6;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(7;Resource;BLOB)
        {
            Caption = 'Resource';
        }
    }

    keys
    {
        key(Key1;"App ID","Add-In Name","Public Key Token",Version)
        {
        }
    }

    fieldgroups
    {
    }
}

