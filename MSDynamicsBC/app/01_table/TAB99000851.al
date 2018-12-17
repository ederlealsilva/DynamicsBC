table 99000851 "Production Forecast Name"
{
    // version NAVW18.00

    Caption = 'Production Forecast Name';
    DrillDownPageID = "Demand Forecast Names";
    LookupPageID = "Demand Forecast Names";

    fields
    {
        field(1;Name;Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2;Description;Text[50])
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
    var
        ProdForecastEntry: Record "Production Forecast Entry";
    begin
        ProdForecastEntry.SetRange("Production Forecast Name",Name);
        if not ProdForecastEntry.IsEmpty then begin
          if GuiAllowed then
            if not Confirm(Confirm001Qst,true,Name) then
              Error('');
          ProdForecastEntry.DeleteAll;
        end;
    end;

    var
        Confirm001Qst: Label 'The Production Forecast %1 has entries. Do you want to delete it anyway?';
}

