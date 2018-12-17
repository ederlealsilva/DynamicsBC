table 1110 "Cost Budget Name"
{
    // version NAVW113.00

    Caption = 'Cost Budget Name';
    LookupPageID = "Cost Budget Names";

    fields
    {
        field(1;Name;Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2;Description;Text[80])
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
        fieldgroup(DropDown;Name,Description)
        {
        }
    }

    trigger OnDelete()
    var
        CostBudgetEntry: Record "Cost Budget Entry";
        CostBudgetRegister: Record "Cost Budget Register";
    begin
        CostBudgetEntry.SetCurrentKey("Budget Name");
        CostBudgetEntry.SetRange("Budget Name",Name);
        CostBudgetEntry.DeleteAll;

        CostBudgetRegister.SetCurrentKey("Cost Budget Name");
        CostBudgetRegister.SetRange("Cost Budget Name",Name);
        CostBudgetRegister.DeleteAll;
    end;

    trigger OnInsert()
    begin
        TestField(Name);
    end;
}

