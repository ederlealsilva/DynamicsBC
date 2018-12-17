table 5840 "Standard Cost Worksheet Name"
{
    // version NAVW17.00

    Caption = 'Standard Cost Worksheet Name';
    LookupPageID = "Standard Cost Worksheet Names";

    fields
    {
        field(2;Name;Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;Name)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        StdCostWksh.SetRange("Standard Cost Worksheet Name",Name);
        StdCostWksh.DeleteAll(true);
    end;

    var
        StdCostWksh: Record "Standard Cost Worksheet";
}

