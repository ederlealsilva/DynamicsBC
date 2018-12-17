table 301 "Finance Charge Text"
{
    // version NAVW17.00

    Caption = 'Finance Charge Text';
    DrillDownPageID = "Reminder Text";
    LookupPageID = "Reminder Text";

    fields
    {
        field(1;"Fin. Charge Terms Code";Code[10])
        {
            Caption = 'Fin. Charge Terms Code';
            NotBlank = true;
            TableRelation = "Finance Charge Terms";
        }
        field(2;Position;Option)
        {
            Caption = 'Position';
            OptionCaption = 'Beginning,Ending';
            OptionMembers = Beginning,Ending;
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(4;Text;Text[100])
        {
            Caption = 'Text';
        }
    }

    keys
    {
        key(Key1;"Fin. Charge Terms Code",Position,"Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

