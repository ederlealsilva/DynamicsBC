table 333 "Column Layout Name"
{
    // version NAVW17.00

    Caption = 'Column Layout Name';
    DataCaptionFields = Name,Description;
    LookupPageID = "Column Layout Names";

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
        field(4;"Analysis View Name";Code[10])
        {
            Caption = 'Analysis View Name';
            TableRelation = "Analysis View";
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
        fieldgroup(DropDown;Name,Description,"Analysis View Name")
        {
        }
    }

    trigger OnDelete()
    begin
        ColumnLayout.SetRange("Column Layout Name",Name);
        ColumnLayout.DeleteAll;
    end;

    var
        ColumnLayout: Record "Column Layout";
}

