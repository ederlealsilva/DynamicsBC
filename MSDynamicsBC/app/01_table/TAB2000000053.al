table 2000000053 "Access Control"
{
    // version NAVW113.00

    Caption = 'Access Control';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"User Security ID";Guid)
        {
            Caption = 'User Security ID';
            TableRelation = User."User Security ID";
        }
        field(2;"Role ID";Code[20])
        {
            Caption = 'Role ID';
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(3;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(5;"User Name";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("User Security ID")));
            Caption = 'User Name';
            FieldClass = FlowField;
        }
        field(7;"Role Name";Text[30])
        {
            CalcFormula = Lookup("Aggregate Permission Set".Name WHERE (Scope=FIELD(Scope),
                                                                        "App ID"=FIELD("App ID"),
                                                                        "Role ID"=FIELD("Role ID")));
            Caption = 'Role Name';
            FieldClass = FlowField;
        }
        field(8;Scope;Option)
        {
            Caption = 'Scope';
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
            TableRelation = "Aggregate Permission Set".Scope;
        }
        field(9;"App ID";Guid)
        {
            Caption = 'App ID';
            TableRelation = "Aggregate Permission Set"."App ID";
        }
        field(10;"App Name";Text[250])
        {
            CalcFormula = Lookup("Aggregate Permission Set"."App Name" WHERE (Scope=FIELD(Scope),
                                                                              "App ID"=FIELD("App ID"),
                                                                              "Role ID"=FIELD("Role ID")));
            Caption = 'App Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"User Security ID","Role ID","Company Name",Scope,"App ID")
        {
        }
        key(Key2;"Role ID")
        {
        }
    }

    fieldgroups
    {
    }
}

