table 2000000069 "Add-in"
{
    // version NAVW19.00

    Caption = 'Add-in';
    DataPerCompany = false;

    fields
    {
        field(1;"Add-in Name";Text[220])
        {
            Caption = 'Add-in Name';
        }
        field(5;"Public Key Token";Text[20])
        {
            Caption = 'Public Key Token';
        }
        field(8;Version;Text[25])
        {
            Caption = 'Version';
        }
        field(15;Category;Option)
        {
            Caption = 'Category';
            OptionCaption = 'JavaScript Control Add-in,DotNet Control Add-in,DotNet Interoperability,Language Resource';
            OptionMembers = "JavaScript Control Add-in","DotNet Control Add-in","DotNet Interoperability","Language Resource";
        }
        field(20;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(25;Resource;BLOB)
        {
            Caption = 'Resource';
        }
    }

    keys
    {
        key(Key1;"Add-in Name","Public Key Token",Version)
        {
        }
    }

    fieldgroups
    {
    }
}

