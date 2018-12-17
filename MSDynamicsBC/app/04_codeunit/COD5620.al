codeunit 5620 "FA Reg.-FALedger"
{
    // version NAVW17.00

    TableNo = "FA Register";

    trigger OnRun()
    begin
        FALedgEntry.SetRange("Entry No.","From Entry No.","To Entry No.");
        PAGE.Run(PAGE::"FA Ledger Entries",FALedgEntry);
    end;

    var
        FALedgEntry: Record "FA Ledger Entry";
}

