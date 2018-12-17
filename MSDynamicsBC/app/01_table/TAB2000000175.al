table 2000000175 "Scheduled Task"
{
    // version NAVW113.00

    Caption = 'Scheduled Task';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;ID;Guid)
        {
            Caption = 'ID';
        }
        field(2;"User ID";Guid)
        {
            Caption = 'User ID';
        }
        field(3;"User Name";Text[50])
        {
            Caption = 'User Name';
        }
        field(4;"User Language ID";Integer)
        {
            Caption = 'User Language ID';
        }
        field(5;"User Format ID";Integer)
        {
            Caption = 'User Format ID';
        }
        field(6;"User Time Zone";Text[32])
        {
            Caption = 'User Time Zone';
        }
        field(7;"User App ID";Text[20])
        {
            Caption = 'User App ID';
        }
        field(10;Company;Text[30])
        {
            Caption = 'Company';
            TableRelation = Company.Name;
        }
        field(11;"Is Ready";Boolean)
        {
            Caption = 'Is Ready';
        }
        field(12;"Not Before";DateTime)
        {
            Caption = 'Not Before';
        }
        field(20;"Run Codeunit";Integer)
        {
            Caption = 'Run Codeunit';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(21;"Failure Codeunit";Integer)
        {
            Caption = 'Failure Codeunit';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Codeunit));
        }
        field(22;"Record";RecordID)
        {
            Caption = 'Record';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;"Record")
        {
        }
    }

    fieldgroups
    {
    }
}

