codeunit 1220 "SEPA CT-Export File"
{
    // version NAVW113.00

    Permissions = TableData "Data Exch. Field"=rimd;
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        ExpUserFeedbackGenJnl: Codeunit "Exp. User Feedback Gen. Jnl.";
    begin
        LockTable;
        BankAccount.Get("Bal. Account No.");
        if Export(Rec,BankAccount.GetPaymentExportXMLPortID) then
          ExpUserFeedbackGenJnl.SetExportFlagOnGenJnlLine(Rec);
    end;

    var
        ExportToServerFile: Boolean;

    procedure Export(var GenJnlLine: Record "Gen. Journal Line";XMLPortID: Integer): Boolean
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        TempBlob: Record TempBlob;
        FileManagement: Codeunit "File Management";
        OutStr: OutStream;
        UseCommonDialog: Boolean;
    begin
        TempBlob.Init;
        TempBlob.Blob.CreateOutStream(OutStr);
        XMLPORT.Export(XMLPortID,OutStr,GenJnlLine);

        CreditTransferRegister.FindLast;
        UseCommonDialog := not ExportToServerFile;
        if FileManagement.BLOBExport(TempBlob,StrSubstNo('%1.XML',CreditTransferRegister.Identifier),UseCommonDialog) <> '' then
          SetCreditTransferRegisterToFileCreated(CreditTransferRegister,TempBlob);

        exit(CreditTransferRegister.Status = CreditTransferRegister.Status::"File Created");
    end;

    local procedure SetCreditTransferRegisterToFileCreated(var CreditTransferRegister: Record "Credit Transfer Register";var TempBlob: Record TempBlob)
    begin
        CreditTransferRegister.Status := CreditTransferRegister.Status::"File Created";
        CreditTransferRegister."Exported File" := TempBlob.Blob;
        CreditTransferRegister.Modify;
    end;

    [Scope('Personalization')]
    procedure EnableExportToServerFile()
    begin
        ExportToServerFile := true;
    end;
}

