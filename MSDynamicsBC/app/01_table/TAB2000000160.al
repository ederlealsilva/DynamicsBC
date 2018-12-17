table 2000000160 "NAV App"
{
    // version NAVW113.00

    Caption = 'NAV App';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Package ID";Guid)
        {
            Caption = 'Package ID';
        }
        field(2;ID;Guid)
        {
            Caption = 'ID';
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
        field(13;Brief;Text[250])
        {
            Caption = 'Brief';
        }
        field(14;Description;BLOB)
        {
            Caption = 'Description';
        }
        field(15;"Privacy Statement";Text[250])
        {
            Caption = 'Privacy Statement';
        }
        field(16;EULA;Text[250])
        {
            Caption = 'EULA';
        }
        field(17;Url;Text[250])
        {
            Caption = 'Url';
        }
        field(18;Help;Text[250])
        {
            Caption = 'Help';
        }
        field(19;Logo;Media)
        {
            Caption = 'Logo';
        }
        field(20;Screenshots;MediaSet)
        {
            Caption = 'Screenshots';
        }
        field(21;Blob;BLOB)
        {
            Caption = 'Blob';
        }
        field(22;responseUrl;Text[250])
        {
            Caption = 'responseUrl';
            FieldClass = FlowField;
        }
        field(23;requestId;Text[250])
        {
            Caption = 'requestId';
            FieldClass = FlowField;
        }
        field(24;Installed;Boolean)
        {
            CalcFormula = Exist("NAV App Installed App" WHERE ("Package ID"=FIELD("Package ID")));
            Caption = 'Installed';
            FieldClass = FlowField;
        }
        field(25;"Package Type";Integer)
        {
            Caption = 'Package Type';
        }
        field(26;Symbols;BLOB)
        {
            Caption = 'Symbols';
        }
        field(27;"Content Hash";Text[250])
        {
            Caption = 'Content Hash';
        }
        field(28;"Tenant ID";Text[128])
        {
            Caption = 'Tenant ID';
        }
        field(29;"Show My Code";Boolean)
        {
            Caption = 'Show My Code';
        }
        field(30;Scope;Integer)
        {
            Caption = 'Scope';
        }
        field(31;"Tenant Visible";Boolean)
        {
            CalcFormula = Lookup("NAV App Extra"."Tenant Visible" WHERE ("Package ID"=FIELD("Package ID")));
            Caption = 'Tenant Visible';
            FieldClass = FlowField;
        }
        field(32;"PerTenant Or Installed";Boolean)
        {
            CalcFormula = Lookup("NAV App Extra"."PerTenant Or Installed" WHERE ("Package ID"=FIELD("Package ID")));
            Caption = 'PerTenant Or Installed';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Package ID")
        {
        }
        key(Key2;Name)
        {
        }
        key(Key3;Publisher)
        {
        }
        key(Key4;Name,"Version Major","Version Minor","Version Build","Version Revision")
        {
        }
    }

    fieldgroups
    {
    }
}

