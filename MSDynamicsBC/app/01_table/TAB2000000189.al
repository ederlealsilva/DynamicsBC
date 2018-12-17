table 2000000189 "Tenant License State"
{
    // version NAVW113.00

    Caption = 'Tenant License State';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Start Date";DateTime)
        {
            Caption = 'Start Date';
        }
        field(2;"End Date";DateTime)
        {
            Caption = 'End Date';
        }
        field(3;State;Option)
        {
            Caption = 'State';
            OptionCaption = 'Evaluation,Trial,Paid,Warning,Suspended,Deleted,,,,LockedOut';
            OptionMembers = Evaluation,Trial,Paid,Warning,Suspended,Deleted,,,,LockedOut;
        }
        field(4;"User Security ID";Guid)
        {
            Caption = 'User Security ID';
            TableRelation = User."User Security ID";
        }
    }

    keys
    {
        key(Key1;"Start Date")
        {
        }
    }

    fieldgroups
    {
    }
}

