table 1540 "Workflow User Group"
{
    // version NAVW113.00

    Caption = 'Workflow User Group';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Workflow User Groups";
    ReplicateData = false;

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
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

    trigger OnDelete()
    var
        WorkflowUserGroupMember: Record "Workflow User Group Member";
    begin
        WorkflowUserGroupMember.SetRange("Workflow User Group Code",Code);
        WorkflowUserGroupMember.DeleteAll(true);
    end;
}

