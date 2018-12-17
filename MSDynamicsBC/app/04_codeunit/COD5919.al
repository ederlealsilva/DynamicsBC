codeunit 5919 "Serv Reg.-Show WarrLdgEntries"
{
    // version NAVW17.00

    TableNo = "Service Register";

    trigger OnRun()
    begin
        WarrLedgEntry.Reset;
        WarrLedgEntry.SetRange("Entry No.","From Warranty Entry No.","To Warranty Entry No.");
        PAGE.Run(PAGE::"Warranty Ledger Entries",WarrLedgEntry);
    end;

    var
        WarrLedgEntry: Record "Warranty Ledger Entry";
}

