codeunit 5507 "Graph Mgt - Sales Credit Memo"
{
    // version NAVW111.00

    Permissions = TableData "Sales Cr.Memo Header"=rimd;

    trigger OnRun()
    begin
    end;

    procedure ProcessComplexTypes(var SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";BillToAddressJSON: Text)
    begin
        ParseBillToCustomerAddressFromJSON(BillToAddressJSON,SalesCrMemoEntityBuffer);
    end;

    procedure ParseBillToCustomerAddressFromJSON(BillToAddressJSON: Text;var SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer")
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        RecRef: RecordRef;
    begin
        if BillToAddressJSON <> '' then
          with SalesCrMemoEntityBuffer do begin
            RecRef.GetTable(SalesCrMemoEntityBuffer);
            GraphMgtComplexTypes.ApplyPostalAddressFromJSON(BillToAddressJSON,RecRef,
              FieldNo("Sell-to Address"),FieldNo("Sell-to Address 2"),FieldNo("Sell-to City"),FieldNo("Sell-to County"),
              FieldNo("Sell-to Country/Region Code"),FieldNo("Sell-to Post Code"));
            RecRef.SetTable(SalesCrMemoEntityBuffer);
          end;
    end;

    procedure BillToCustomerAddressToJSON(SalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer") JSON: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        with SalesCrMemoEntityBuffer do
          GraphMgtComplexTypes.GetPostalAddressJSON("Sell-to Address","Sell-to Address 2",
            "Sell-to City","Sell-to County","Sell-to Country/Region Code","Sell-to Post Code",JSON);
    end;

    procedure UpdateIntegrationRecordIds(OnlyRecordsWithoutID: Boolean)
    var
        DummySalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        DummyCustomer: Record Customer;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        SalesHeaderRecordRef: RecordRef;
        SalesCrMemoHeaderRecordRef: RecordRef;
        CustomerRecordRef: RecordRef;
    begin
        CustomerRecordRef.Open(DATABASE::Customer);
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          CustomerRecordRef,DummyCustomer.FieldNo(Id),true);

        SalesHeaderRecordRef.Open(DATABASE::"Sales Header");
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          SalesHeaderRecordRef,DummySalesCrMemoEntityBuffer.FieldNo(Id),OnlyRecordsWithoutID);

        SalesCrMemoHeaderRecordRef.Open(DATABASE::"Sales Cr.Memo Header");
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          SalesCrMemoHeaderRecordRef,DummySalesCrMemoEntityBuffer.FieldNo(Id),OnlyRecordsWithoutID);
    end;

    local procedure CheckSupportedTable(var RecRef: RecordRef): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        case RecRef.Number of
          DATABASE::"Sales Cr.Memo Header":
            exit(true);
          DATABASE::"Sales Header":
            begin
              RecRef.SetTable(SalesHeader);
              exit(SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo");
            end;
          else
            exit(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnSalesInvoiceHeader(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummySalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,RecRef.Number,DummySalesCrMemoEntityBuffer.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummySalesCrMemoEntityBuffer: Record "Sales Cr. Memo Entity Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,RecRef.Number,DummySalesCrMemoEntityBuffer.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    procedure HandleApiSetup()
    var
        GraphMgtSalCrMemoBuf: Codeunit "Graph Mgt - Sal. Cr. Memo Buf.";
    begin
        UpdateIntegrationRecordIds(false);
        GraphMgtSalCrMemoBuf.UpdateBufferTableRecords;
    end;
}

