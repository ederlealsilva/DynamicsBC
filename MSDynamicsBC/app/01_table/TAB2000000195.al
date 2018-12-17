table 2000000195 "Membership Entitlement"
{
    // version NAVW113.00

    Caption = 'Membership Entitlement';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Azure AD Plan,Azure AD Role,User Security ID,Application ID,NAV Application ID,Azure AD Delegated Role';
            OptionMembers = "Azure AD Plan","Azure AD Role","User Security ID","Application ID","NAV Application ID","Azure AD Delegated Role";
        }
        field(2;ID;Text[250])
        {
            Caption = 'ID';
        }
        field(3;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(4;"Entitlement Set ID";Code[20])
        {
            Caption = 'Entitlement Set ID';
            TableRelation = "Entitlement Set".ID WHERE (ID=FIELD("Entitlement Set ID"));
        }
        field(5;"Entitlement Set Name";Text[250])
        {
            CalcFormula = Lookup("Entitlement Set".Name WHERE (ID=FIELD("Entitlement Set ID")));
            Caption = 'Entitlement Set Name';
            FieldClass = FlowField;
        }
        field(6;"Is Evaluation";Boolean)
        {
            Caption = 'Is Evaluation';
        }
    }

    keys
    {
        key(Key1;Type,ID,"Entitlement Set ID")
        {
        }
    }

    fieldgroups
    {
    }
}

