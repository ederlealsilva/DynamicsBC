codeunit 135 "Retrieve Document From OCR"
{
    // version NAVW110.0

    TableNo = "Incoming Document";

    trigger OnRun()
    var
        SendIncomingDocumentToOCR: Codeunit "Send Incoming Document to OCR";
    begin
        SendIncomingDocumentToOCR.RetrieveDocFromOCR(Rec);
    end;
}

