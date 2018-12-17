table 2000000073 "User Personalization"
{
    // version NAVW113.00

    Caption = 'User Personalization';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(3;"User SID";Guid)
        {
            Caption = 'User SID';
            TableRelation = User."User Security ID";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(6;"User ID";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("User SID")));
            Caption = 'User ID';
            FieldClass = FlowField;
        }
        field(9;"Profile ID";Code[30])
        {
            Caption = 'Profile ID';
            TableRelation = "All Profile"."Profile ID";
        }
        field(10;"App ID";Guid)
        {
            Caption = 'App ID';
        }
        field(11;Scope;Option)
        {
            Caption = 'Scope';
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
        }
        field(12;"Language ID";Integer)
        {
            Caption = 'Language ID';
        }
        field(15;Company;Text[30])
        {
            Caption = 'Company';
            TableRelation = Company.Name;
        }
        field(18;"Debugger Break On Error";Boolean)
        {
            Caption = 'Debugger Break On Error';
            InitValue = true;
        }
        field(21;"Debugger Break On Rec Changes";Boolean)
        {
            Caption = 'Debugger Break On Rec Changes';
        }
        field(24;"Debugger Skip System Triggers";Boolean)
        {
            Caption = 'Debugger Skip System Triggers';
            InitValue = true;
        }
        field(27;"Locale ID";Integer)
        {
            Caption = 'Locale ID';
        }
        field(30;"Time Zone";Text[180])
        {
            Caption = 'Time Zone';
        }
        field(31;"License Type";Option)
        {
            CalcFormula = Lookup(User."License Type" WHERE ("User Security ID"=FIELD("User SID")));
            Caption = 'License Type';
            FieldClass = FlowField;
            OptionCaption = 'Full User,Limited User,Device Only User,Windows Group,External User';
            OptionMembers = "Full User","Limited User","Device Only User","Windows Group","External User";
        }
    }

    keys
    {
        key(Key1;"User SID")
        {
        }
        key(Key2;"Profile ID")
        {
        }
        key(Key3;Company)
        {
        }
    }

    fieldgroups
    {
    }
}

