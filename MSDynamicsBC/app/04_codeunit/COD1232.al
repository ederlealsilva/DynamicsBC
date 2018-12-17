codeunit 1232 "SEPA DD-Prepare Source"
{
    // version NAVW18.00

    TableNo = "Direct Debit Collection Entry";

    trigger OnRun()
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
    begin
        DirectDebitCollectionEntry.CopyFilters(Rec);
        CopyLines(DirectDebitCollectionEntry,Rec);
    end;

    local procedure CopyLines(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry";var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    begin
        if not FromDirectDebitCollectionEntry.IsEmpty then begin
          FromDirectDebitCollectionEntry.SetFilter(Status,'%1|%2',
            FromDirectDebitCollectionEntry.Status::New,FromDirectDebitCollectionEntry.Status::"File Created");
          if FromDirectDebitCollectionEntry.FindSet then
            repeat
              ToDirectDebitCollectionEntry := FromDirectDebitCollectionEntry;
              ToDirectDebitCollectionEntry.Insert;
            until FromDirectDebitCollectionEntry.Next = 0
        end else
          CreateTempCollectionEntries(FromDirectDebitCollectionEntry,ToDirectDebitCollectionEntry);
    end;

    local procedure CreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry";var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    begin
        // To fill ToDirectDebitCollectionEntry from the source identified by filters set on FromDirectDebitCollectionEntry
        ToDirectDebitCollectionEntry := FromDirectDebitCollectionEntry;
    end;
}

