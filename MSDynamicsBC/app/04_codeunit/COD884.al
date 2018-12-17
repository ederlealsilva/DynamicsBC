codeunit 884 "ReadSoft OCR Master Data Sync"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        SyncVendorsUriTxt: Label 'masterdata/rest/%1/suppliers', Locked=true;
        SyncVendorBankAccountsUriTxt: Label 'masterdata/rest/%1/supplierbankaccounts', Locked=true;
        SyncModifiedVendorsMsg: Label 'Send updated vendors to the OCR service.';
        SyncBankAccountsMsg: Label 'Send vendor bank accounts to the OCR service.';
        SyncSuccessfulSimpleMsg: Label 'Synchronization succeeded.';
        SyncSuccessfulDetailedMsg: Label 'Synchronization succeeded. Created: %1, Updated: %2, Deleted: %3', Comment='%1 number of created entities, %2 number of updated entities, %3 number of deleted entities';
        SyncFailedSimpleMsg: Label 'Synchronization failed.';
        SyncFailedDetailedMsg: Label 'Synchronization failed. Code: %1, Message: %2', Comment='%1 error code, %2 error message';
        InvalidResponseMsg: Label 'Response is invalid.';
        MasterDataSyncMsg: Label 'Master data synchronization.\#1########################################', Comment='#1 place holder for SendingPackageMsg ';
        SendingPackageMsg: Label 'Sending package %1 of %2', Comment='%1 package number, %2 package count';
        MaxPortionSizeTxt: Label '3000', Locked=true;
        MethodPutTok: Label 'PUT', Locked=true;
        MethodPostTok: Label 'POST', Locked=true;
        OCRServiceSetup: Record "OCR Service Setup";
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
        Window: Dialog;
        WindowUpdateDateTime: DateTime;
        OrganizationId: Text;
        PackageNo: Integer;
        PackageCount: Integer;
        MaxPortionSizeValue: Integer;

    [Scope('Personalization')]
    procedure SyncMasterData(Resync: Boolean;Silent: Boolean): Boolean
    var
        LastSyncTime: DateTime;
        SyncStartTime: DateTime;
    begin
        OCRServiceMgt.GetOcrServiceSetupExtended(OCRServiceSetup,true);
        OCRServiceSetup.TestField("Master Data Sync Enabled");

        if Resync then begin
          Clear(OCRServiceSetup."Master Data Last Sync");
          OCRServiceSetup.Modify;
          Commit;
        end;

        LastSyncTime := OCRServiceSetup."Master Data Last Sync";
        SyncStartTime := CurrentDateTime;

        if not SyncVendors(LastSyncTime,SyncStartTime) then begin
          if not Silent then
            Message(SyncFailedSimpleMsg);
          exit(false);
        end;

        OCRServiceSetup."Master Data Last Sync" := SyncStartTime;
        OCRServiceSetup.Modify;
        if not Silent then
          Message(SyncSuccessfulSimpleMsg);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure ResetLastSyncTime()
    begin
        if not IsSyncEnabled then
          exit;
        OCRServiceSetup.Get;
        if OCRServiceSetup."Master Data Last Sync" = 0DT then
          exit;
        Clear(OCRServiceSetup."Master Data Last Sync");
        OCRServiceSetup.Modify;
        Commit;
    end;

    [Scope('Personalization')]
    procedure IsSyncEnabled(): Boolean
    var
        OCRServiceSetup: Record "OCR Service Setup";
    begin
        if not OCRServiceSetup.Get then
          exit(false);

        if not OCRServiceSetup."Master Data Sync Enabled" then
          exit(false);

        if not OCRServiceSetup.Enabled then
          exit(false);

        if OCRServiceSetup."Service URL" = '' then
          exit(false);

        exit(true);
    end;

    local procedure CheckSyncResponse(var ResponseStream: InStream;ActivityDescription: Text): Boolean
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        XMLRootNode: DotNet XmlNode;
        XMLNode: DotNet XmlNode;
        NoOfCreated: Integer;
        NoOfUpdated: Integer;
        NoOfDeleted: Integer;
        ErrorCode: Text;
        ErrorMessage: Text;
    begin
        XMLDOMManagement.LoadXMLNodeFromInStream(ResponseStream,XMLRootNode);
        case XMLRootNode.Name of
          'UpdateResult':
            begin
              if XMLDOMManagement.FindNode(XMLRootNode,'Created',XMLNode) then
                Evaluate(NoOfCreated,XMLNode.InnerText,9);
              if XMLDOMManagement.FindNode(XMLRootNode,'Updated',XMLNode) then
                Evaluate(NoOfUpdated,XMLNode.InnerText,9);
              if XMLDOMManagement.FindNode(XMLRootNode,'Deleted',XMLNode) then
                Evaluate(NoOfDeleted,XMLNode.InnerText,9);
              OCRServiceMgt.LogActivitySucceeded(
                OCRServiceSetup.RecordId,ActivityDescription,StrSubstNo(SyncSuccessfulDetailedMsg,NoOfCreated,NoOfUpdated,NoOfDeleted));
              exit(true);
            end;
          'ServiceError':
            begin
              if XMLDOMManagement.FindNode(XMLRootNode,'Code',XMLNode) then
                ErrorCode := XMLNode.InnerText;
              if XMLDOMManagement.FindNode(XMLRootNode,'Message',XMLNode) then
                ErrorMessage := XMLNode.InnerText;
              OCRServiceMgt.LogActivityFailed(
                OCRServiceSetup.RecordId,ActivityDescription,StrSubstNo(SyncFailedDetailedMsg,ErrorCode,ErrorMessage));
              exit(false);
            end;
          else begin
            OCRServiceMgt.LogActivityFailed(OCRServiceSetup.RecordId,ActivityDescription,InvalidResponseMsg);
            exit(false);
          end;
        end;
    end;

    local procedure SyncVendors(StartDateTime: DateTime;EndDateTime: DateTime): Boolean
    var
        TempBlobModifiedVendor: Record TempBlob temporary;
        TempBlobBankAccount: Record TempBlob temporary;
        ModifiedVendorCount: Integer;
        BankAccountCount: Integer;
        ModifyVendorPackageCount: Integer;
        BankAccountPackageCount: Integer;
        TotalPackageCount: Integer;
        Success: Boolean;
        ModifiedVendorFirstPortionAction: Code[6];
    begin
        if StartDateTime > 0DT then
          ModifiedVendorFirstPortionAction := MethodPostTok
        else
          ModifiedVendorFirstPortionAction := MethodPutTok;

        GetModifiedVendors(TempBlobModifiedVendor,StartDateTime,EndDateTime);
        GetVendorBankAccounts(TempBlobBankAccount,StartDateTime,EndDateTime);

        ModifiedVendorCount := TempBlobModifiedVendor.Count;
        BankAccountCount := TempBlobBankAccount.Count;

        if (ModifiedVendorCount > 0) or (StartDateTime = 0DT) then
          ModifyVendorPackageCount := (ModifiedVendorCount div MaxPortionSize) + 1;
        if BankAccountCount > 0 then
          BankAccountPackageCount := (TempBlobBankAccount.Count div MaxPortionSize) + 1;
        TotalPackageCount := ModifyVendorPackageCount + BankAccountPackageCount;

        if TotalPackageCount = 0 then
          exit(true);

        CheckOrganizationId;

        OpenWindow(TotalPackageCount);

        Success := SyncMasterDataEntities(
            TempBlobModifiedVendor,VendorsUri,ModifiedVendorFirstPortionAction,MethodPostTok,
            'Suppliers',SyncModifiedVendorsMsg,MaxPortionSize);

        if Success then
          Success := SyncMasterDataEntities(
              TempBlobBankAccount,VendorBankAccountsUri,MethodPutTok,MethodPutTok,
              'SupplierBankAccounts',SyncBankAccountsMsg,MaxPortionSize);

        CloseWindow;

        exit(Success);
    end;

    local procedure SyncMasterDataEntities(var TempBlob: Record TempBlob temporary;RequestUri: Text;FirstPortionAction: Code[6];NextPortionAction: Code[6];RootNodeName: Text;ActivityDescription: Text;PortionSize: Integer): Boolean
    var
        ResponseStream: InStream;
        EntityCount: Integer;
        PortionCount: Integer;
        PortionNumber: Integer;
        LastPortion: Boolean;
        Data: Text;
        RequestAction: Code[6];
    begin
        EntityCount := TempBlob.Count;

        if EntityCount = 0 then begin
          if FirstPortionAction <> MethodPutTok then
            exit(true);
          PortionCount := 1;
          PortionSize := 0;
        end else begin
          PortionCount := (EntityCount div PortionSize) + 1;
          TempBlob.FindFirst;
        end;

        RequestAction := FirstPortionAction;
        for PortionNumber := 1 to PortionCount do begin
          UpdateWindow;
          Data := GetMasterDataEntitiesXml(TempBlob,RootNodeName,PortionSize,LastPortion);
          if not OCRServiceMgt.RsoRequest(RequestUri,RequestAction,Data,ResponseStream) then begin
            OCRServiceMgt.LogActivityFailed(OCRServiceSetup.RecordId,ActivityDescription,SyncFailedSimpleMsg);
            exit(false);
          end;
          if not CheckSyncResponse(ResponseStream,ActivityDescription) then
            exit(false);
          if LastPortion then
            break;
          RequestAction := NextPortionAction;
        end;
        exit(true);
    end;

    local procedure GetModifiedVendors(var TempBlob: Record TempBlob;StartDateTime: DateTime;EndDateTime: DateTime)
    var
        OCRVendors: Query "OCR Vendors";
        Index: Integer;
        Data: Text;
    begin
        OCRVendors.SetRange(Modified_On,StartDateTime,EndDateTime);
        if OCRVendors.Open then
          while OCRVendors.Read do begin
            Index += 1;
            Data := GetModifiedVendorXml(OCRVendors);
            PutToBuffer(TempBlob,Index,Data);
          end;
    end;

    local procedure GetVendorBankAccounts(var TempBlob: Record TempBlob;StartDateTime: DateTime;EndDateTime: DateTime)
    var
        OCRVendorBankAccounts: Query "OCR Vendor Bank Accounts";
        VendorId: Guid;
        AccountIndex: Integer;
        VendorIndex: Integer;
        Data: Text;
    begin
        OCRVendorBankAccounts.SetRange(Modified_On,StartDateTime,EndDateTime);
        if not OCRVendorBankAccounts.Open then
          exit;

        while OCRVendorBankAccounts.Read do begin
          if AccountIndex = 0 then
            VendorId := OCRVendorBankAccounts.Id;
          AccountIndex += 1;
          if VendorId <> OCRVendorBankAccounts.Id then begin
            VendorIndex += 1;
            PutToBuffer(TempBlob,VendorIndex,Data);
            VendorId := OCRVendorBankAccounts.Id;
            Data := '';
          end;
          Data += GetVendorBankAccountXml(OCRVendorBankAccounts);
        end;
        VendorIndex += 1;
        PutToBuffer(TempBlob,VendorIndex,Data);
    end;

    local procedure GetMasterDataEntitiesXml(var TempBlob: Record TempBlob;RootNodeName: Text;PortionSize: Integer;var LastPortion: Boolean): Text
    var
        Data: Text;
        "Count": Integer;
    begin
        Data := '';
        if PortionSize = 0 then
          LastPortion := true
        else
          for Count := 1 to PortionSize do begin
            Data += GetFromBuffer(TempBlob);
            if TempBlob.Next = 0 then begin
              LastPortion := true;
              break;
            end;
          end;
        Data := StrSubstNo('<%1 xmlns:i="http://www.w3.org/2001/XMLSchema-instance">%2</%3>',RootNodeName,Data,RootNodeName);
        exit(Data);
    end;

    local procedure GetModifiedVendorXml(var OCRVendors: Query "OCR Vendors"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        DotNetXmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
        XmlNodeChild: DotNet XmlNode;
        Blocked: Boolean;
    begin
        Blocked := OCRVendors.Blocked <> OCRVendors.Blocked::" ";
        DotNetXmlDocument := DotNetXmlDocument.XmlDocument;
        XMLDOMManagement.AddRootElement(DotNetXmlDocument,'Supplier',XmlNode);

        // when using XML as the input for API, the element order needs to match exactly
        XMLDOMManagement.AddElement(XmlNode,'SupplierNumber',OCRVendors.No,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'Name',OCRVendors.Name,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'TaxRegistrationNumber',OCRVendors.VAT_Registration_No,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'Street',OCRVendors.Address,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'PostalCode',OCRVendors.Post_Code,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'City',OCRVendors.City,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'Blocked',Format(Blocked,0,9),'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'TelephoneNumber',OCRVendors.Phone_No,'',XmlNodeChild);

        exit(DotNetXmlDocument.OuterXml);
    end;

    local procedure GetVendorBankAccountXml(var OCRVendorBankAccounts: Query "OCR Vendor Bank Accounts"): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        DotNetXmlDocument: DotNet XmlDocument;
        XmlNode: DotNet XmlNode;
        XmlNodeChild: DotNet XmlNode;
    begin
        DotNetXmlDocument := DotNetXmlDocument.XmlDocument;
        XMLDOMManagement.AddRootElement(DotNetXmlDocument,'SupplierBankAccount',XmlNode);

        // when using XML as the input for API, the element order needs to match exactly
        XMLDOMManagement.AddElement(XmlNode,'BankName',OCRVendorBankAccounts.Name,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'SupplierNumber',OCRVendorBankAccounts.No,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'BankNumber',OCRVendorBankAccounts.Bank_Branch_No,'',XmlNodeChild);
        XMLDOMManagement.AddElement(XmlNode,'AccountNumber',OCRVendorBankAccounts.Bank_Account_No,'',XmlNodeChild);

        exit(DotNetXmlDocument.OuterXml);
    end;

    local procedure PutToBuffer(var TempBlob: Record TempBlob;Index: Integer;Data: Text)
    var
        OutStream: OutStream;
    begin
        TempBlob.Init;
        TempBlob."Primary Key" := Index;
        TempBlob.Blob.CreateOutStream(OutStream);
        OutStream.WriteText(Data);
        TempBlob.Insert;
    end;

    local procedure GetFromBuffer(var TempBlob: Record TempBlob): Text
    var
        InStream: InStream;
        Data: Text;
    begin
        if TempBlob.IsEmpty then
          exit;
        TempBlob.CalcFields(Blob);
        TempBlob.Blob.CreateInStream(InStream);
        InStream.ReadText(Data);
        exit(Data);
    end;

    local procedure VendorsUri(): Text
    begin
        exit(StrSubstNo(SyncVendorsUriTxt,OrganizationId));
    end;

    local procedure VendorBankAccountsUri(): Text
    begin
        exit(StrSubstNo(SyncVendorBankAccountsUriTxt,OrganizationId));
    end;

    local procedure CheckOrganizationId()
    begin
        OrganizationId := OCRServiceSetup."Organization ID";
        if OrganizationId = '' then begin
          OCRServiceMgt.UpdateOrganizationInfo(OCRServiceSetup);
          OrganizationId := OCRServiceSetup."Organization ID";
        end;
        OCRServiceSetup.TestField("Organization ID");
    end;

    local procedure MaxPortionSize(): Integer
    begin
        if MaxPortionSizeValue = 0 then
          Evaluate(MaxPortionSizeValue,MaxPortionSizeTxt);
        exit(MaxPortionSizeValue);
    end;

    local procedure OpenWindow("Count": Integer)
    begin
        PackageNo := 0;
        PackageCount := Count;
        WindowUpdateDateTime := CurrentDateTime;
        Window.Open(MasterDataSyncMsg);
        Window.Update(1,'');
    end;

    local procedure UpdateWindow()
    begin
        PackageNo += 1;
        if CurrentDateTime - WindowUpdateDateTime >= 300 then begin
          WindowUpdateDateTime := CurrentDateTime;
          Window.Update(1,StrSubstNo(SendingPackageMsg,PackageNo,PackageCount));
        end;
    end;

    local procedure CloseWindow()
    begin
        Window.Close;
    end;
}

