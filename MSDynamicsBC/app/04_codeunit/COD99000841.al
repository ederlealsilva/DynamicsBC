codeunit 99000841 "Item Ledger Entry-Reserve"
{
    // version NAVW111.00

    Permissions = TableData "Reservation Entry"=rimd;

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure FilterReservFor(var FilterReservEntry: Record "Reservation Entry";ItemLedgEntry: Record "Item Ledger Entry")
    begin
        FilterReservEntry.SetSourceFilter(DATABASE::"Item Ledger Entry",0,'',ItemLedgEntry."Entry No.",false);
        FilterReservEntry.SetSourceFilter2('',0);
    end;

    [Scope('Personalization')]
    procedure Caption(ItemLedgEntry: Record "Item Ledger Entry") CaptionText: Text[80]
    begin
        CaptionText :=
          StrSubstNo(
            '%1 %2',ItemLedgEntry.TableCaption,ItemLedgEntry."Entry No.");
    end;
}

