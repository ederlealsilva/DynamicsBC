table 84 "Acc. Schedule Name"
{
    // version NAVW111.00

    Caption = 'Acc. Schedule Name';
    DataCaptionFields = Name,Description;
    LookupPageID = "Account Schedule Names";

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
        field(3;"Default Column Layout";Code[10])
        {
            Caption = 'Default Column Layout';
            TableRelation = "Column Layout Name";
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
    }

    trigger OnDelete()
    begin
        AccSchedLine.SetRange("Schedule Name",Name);
        AccSchedLine.DeleteAll;
    end;

    var
        AccSchedLine: Record "Acc. Schedule Line";

    [Scope('Personalization')]
    procedure Print()
    var
        AccountSchedule: Report "Account Schedule";
    begin
        AccountSchedule.SetAccSchedName(Name);
        AccountSchedule.SetColumnLayoutName("Default Column Layout");
        AccountSchedule.Run;
    end;
}

