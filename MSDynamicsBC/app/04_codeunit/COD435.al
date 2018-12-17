codeunit 435 "IC Inbox Import"
{
    // version NAVW113.00

    TableNo = "IC Inbox Transaction";

    trigger OnRun()
    var
        CompanyInfo: Record "Company Information";
        ICPartner: Record "IC Partner";
        TempICOutboxTrans: Record "IC Outbox Transaction" temporary;
        TempICOutBoxJnlLine: Record "IC Outbox Jnl. Line" temporary;
        TempICIOBoxJnlDim: Record "IC Inbox/Outbox Jnl. Line Dim." temporary;
        TempICOutBoxSalesHdr: Record "IC Outbox Sales Header" temporary;
        TempICOutBoxSalesLine: Record "IC Outbox Sales Line" temporary;
        TempICOutBoxPurchHdr: Record "IC Outbox Purchase Header" temporary;
        TempICOutBoxPurchLine: Record "IC Outbox Purchase Line" temporary;
        TempICDocDim: Record "IC Document Dimension" temporary;
        ICInboxJnlLine: Record "IC Inbox Jnl. Line";
        ICInboxSalesHdr: Record "IC Inbox Sales Header";
        ICInboxSalesLine: Record "IC Inbox Sales Line";
        ICInboxPurchHdr: Record "IC Inbox Purchase Header";
        ICInboxPurchLine: Record "IC Inbox Purchase Line";
        ICInboxJnlLineDim: Record "IC Inbox/Outbox Jnl. Line Dim.";
        ICInboxDocDim: Record "IC Document Dimension";
        ICInboxOutboxMgt: Codeunit ICInboxOutboxMgt;
        FileMgt: Codeunit "File Management";
        PermissionManager: Codeunit "Permission Manager";
        ICOutboxImpExpXML: XMLport "IC Outbox Imp/Exp";
        IStr: InStream;
        IFile: File;
        FileName: Text;
        FromICPartnerCode: Code[20];
        ToICPartnerCode: Code[20];
        NewTableID: Integer;
    begin
        CompanyInfo.Get;
        CompanyInfo.TestField("IC Partner Code");
        if ClientFileName = '' then begin
          if CompanyInfo."IC Inbox Type" = CompanyInfo."IC Inbox Type"::"File Location" then
            ClientFileName := FileMgt.CombinePath(CompanyInfo."IC Inbox Details",'*.xml');
          FileName := FileMgt.UploadFile(StrSubstNo(SelectFileMsg,TableCaption),ClientFileName);
        end else
          FileName := FileMgt.UploadFileToServer(ClientFileName);

        if FileName = '' then
          Error(EnterFileNameErr);

        IFile.Open(FileName);
        IFile.CreateInStream(IStr);
        ICOutboxImpExpXML.SetSource(IStr);
        ICOutboxImpExpXML.Import;
        IFile.Close;
        FromICPartnerCode := ICOutboxImpExpXML.GetFromICPartnerCode;
        ToICPartnerCode := ICOutboxImpExpXML.GetToICPartnerCode;
        if ToICPartnerCode <> CompanyInfo."IC Partner Code" then
          Error(
            WrongCompanyErr,ICPartner.TableCaption,ToICPartnerCode,
            CompanyInfo.FieldCaption("IC Partner Code"),CompanyInfo."IC Partner Code");

        ICOutboxImpExpXML.GetICOutboxTrans(TempICOutboxTrans);
        ICOutboxImpExpXML.GetICOutBoxJnlLine(TempICOutBoxJnlLine);
        ICOutboxImpExpXML.GetICIOBoxJnlDim(TempICIOBoxJnlDim);
        ICOutboxImpExpXML.GetICOutBoxSalesHdr(TempICOutBoxSalesHdr);
        ICOutboxImpExpXML.GetICOutBoxSalesLine(TempICOutBoxSalesLine);
        ICOutboxImpExpXML.GetICOutBoxPurchHdr(TempICOutBoxPurchHdr);
        ICOutboxImpExpXML.GetICOutBoxPurchLine(TempICOutBoxPurchLine);
        ICOutboxImpExpXML.GetICSalesDocDim(TempICDocDim);
        ICOutboxImpExpXML.GetICSalesDocLineDim(TempICDocDim);
        ICOutboxImpExpXML.GetICPurchDocDim(TempICDocDim);
        ICOutboxImpExpXML.GetICPurchDocLineDim(TempICDocDim);
        FromICPartnerCode := ICOutboxImpExpXML.GetFromICPartnerCode;

        if TempICOutboxTrans.Find('-') then
          repeat
            ICInboxOutboxMgt.OutboxTransToInbox(TempICOutboxTrans,Rec,FromICPartnerCode);

            TempICOutBoxJnlLine.SetRange("Transaction No.",TempICOutboxTrans."Transaction No.");
            TempICOutBoxJnlLine.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
            TempICOutBoxJnlLine.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
            if TempICOutBoxJnlLine.Find('-') then
              repeat
                ICInboxOutboxMgt.OutboxJnlLineToInbox(Rec,TempICOutBoxJnlLine,ICInboxJnlLine);
                TempICIOBoxJnlDim.SetRange("Transaction No.",TempICOutboxTrans."Transaction No.");
                TempICIOBoxJnlDim.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
                TempICIOBoxJnlDim.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
                TempICIOBoxJnlDim.SetRange("Line No.",ICInboxJnlLine."Line No.");
                if TempICIOBoxJnlDim.Find('-') then
                  repeat
                    ICInboxOutboxMgt.OutboxJnlLineDimToInbox(
                      ICInboxJnlLine,TempICIOBoxJnlDim,ICInboxJnlLineDim,DATABASE::"IC Inbox Jnl. Line");
                  until TempICIOBoxJnlDim.Next = 0;
              until TempICOutBoxJnlLine.Next = 0;

            TempICOutBoxSalesHdr.SetRange("IC Transaction No.",TempICOutboxTrans."Transaction No.");
            TempICOutBoxSalesHdr.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
            TempICOutBoxSalesHdr.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
            if TempICOutBoxSalesHdr.Find('-') then
              repeat
                ICInboxOutboxMgt.OutboxSalesHdrToInbox(Rec,TempICOutBoxSalesHdr,ICInboxPurchHdr);
              until TempICOutBoxSalesHdr.Next = 0;

            TempICOutBoxSalesLine.SetRange("IC Transaction No.",TempICOutboxTrans."Transaction No.");
            TempICOutBoxSalesLine.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
            TempICOutBoxSalesLine.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
            if TempICOutBoxSalesLine.Find('-') then
              repeat
                ICInboxOutboxMgt.OutboxSalesLineToInbox(Rec,TempICOutBoxSalesLine,ICInboxPurchLine);
              until TempICOutBoxSalesLine.Next = 0;

            TempICOutBoxPurchHdr.SetRange("IC Transaction No.",TempICOutboxTrans."Transaction No.");
            TempICOutBoxPurchHdr.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
            TempICOutBoxPurchHdr.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
            if TempICOutBoxPurchHdr.Find('-') then
              repeat
                ICInboxOutboxMgt.OutboxPurchHdrToInbox(Rec,TempICOutBoxPurchHdr,ICInboxSalesHdr);
              until TempICOutBoxPurchHdr.Next = 0;

            TempICOutBoxPurchLine.SetRange("IC Transaction No.",TempICOutboxTrans."Transaction No.");
            TempICOutBoxPurchLine.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
            TempICOutBoxPurchLine.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
            if TempICOutBoxPurchLine.Find('-') then
              repeat
                ICInboxOutboxMgt.OutboxPurchLineToInbox(Rec,TempICOutBoxPurchLine,ICInboxSalesLine);
              until TempICOutBoxPurchLine.Next = 0;

            TempICDocDim.SetRange("Transaction No.",TempICOutboxTrans."Transaction No.");
            TempICDocDim.SetRange("IC Partner Code",TempICOutboxTrans."IC Partner Code");
            TempICDocDim.SetRange("Transaction Source",TempICOutboxTrans."Transaction Source");
            if TempICDocDim.Find('-') then
              repeat
                case TempICDocDim."Table ID" of
                  DATABASE::"IC Outbox Sales Header":
                    NewTableID := DATABASE::"IC Inbox Purchase Header";
                  DATABASE::"IC Outbox Sales Line":
                    NewTableID := DATABASE::"IC Inbox Purchase Line";
                  DATABASE::"IC Outbox Purchase Header":
                    NewTableID := DATABASE::"IC Inbox Sales Header";
                  DATABASE::"IC Outbox Purchase Line":
                    NewTableID := DATABASE::"IC Inbox Sales Line";
                end;
                ICInboxOutboxMgt.OutboxDocDimToInbox(
                  TempICDocDim,ICInboxDocDim,NewTableID,FromICPartnerCode,"Transaction Source");
              until TempICDocDim.Next = 0;
          until TempICOutboxTrans.Next = 0;

        if not PermissionManager.SoftwareAsAService then
          FileMgt.MoveAndRenameClientFile(ClientFileName,FileMgt.GetFileName(ClientFileName),ArchiveTok);
    end;

    var
        SelectFileMsg: Label 'Select file to import into %1', Comment='%1 = IC Inbox Import';
        ArchiveTok: Label 'Archive';
        WrongCompanyErr: Label 'The selected xml file contains data sent to %1 %2. Current company''s %3 is %4.', Comment='The selected xml file contains data sent to IC Partner 001. Current company''s IC Partner Code is 002.';
        EnterFileNameErr: Label 'Enter the file name.';
        ClientFileName: Text;

    [Scope('Personalization')]
    procedure SetFileName(NewFileName: Text)
    begin
        ClientFileName := NewFileName;
    end;
}

