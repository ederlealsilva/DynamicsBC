table 2000000200 "NAV App Tenant Operation"
{
    // version NAVW113.00

    Caption = 'NAV App Tenant Operation';
    DataPerCompany = false;

    fields
    {
        field(1;"Operation ID";Guid)
        {
            Caption = 'Operation ID';
        }
        field(2;"Started On";DateTime)
        {
            Caption = 'Started On';
        }
        field(3;"Operation Type";Option)
        {
            Caption = 'Operation Type';
            OptionCaption = 'DeployTarget,DeployPackage';
            OptionMembers = DeployTarget,DeployPackage;
        }
        field(4;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Unknown,InProgress,Failed,Completed,NotFound';
            OptionMembers = Unknown,InProgress,Failed,Completed,NotFound;
        }
        field(5;Details;BLOB)
        {
            Caption = 'Details';
        }
        field(6;"Metadata Version";Integer)
        {
            Caption = 'Metadata Version';
        }
        field(7;Metadata;BLOB)
        {
            Caption = 'Metadata';
        }
        field(8;"Metadata Key";Text[250])
        {
            Caption = 'Metadata Key';
        }
        field(9;Description;Text[250])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Operation ID")
        {
        }
        key(Key2;"Operation Type","Metadata Key")
        {
        }
    }

    fieldgroups
    {
    }
}

