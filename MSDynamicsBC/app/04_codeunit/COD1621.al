codeunit 1621 "PEPPOL Service Validation"
{
    // version NAVW19.00

    TableNo = "Service Header";

    trigger OnRun()
    var
        PEPPOLValidation: Codeunit "PEPPOL Validation";
    begin
        PEPPOLValidation.CheckServiceHeader(Rec);
    end;
}

