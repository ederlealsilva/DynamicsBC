table 1508 "Workflow Category"
{
    // version NAVW113.00

    Caption = 'Workflow Category';
    LookupPageID = "Workflow Categories";
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

