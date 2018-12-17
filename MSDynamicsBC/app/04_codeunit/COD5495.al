codeunit 5495 "Graph Mgt - Sales Order"
{
    // version NAVW111.00

    Permissions = TableData "Sales Invoice Header"=rimd;

    trigger OnRun()
    begin
    end;

    procedure ProcessComplexTypes(var SalesOrderEntityBuffer: Record "Sales Order Entity Buffer";BillToAddressJSON: Text)
    begin
        ParseBillToCustomerAddressFromJSON(BillToAddressJSON,SalesOrderEntityBuffer);
    end;

    procedure ParseBillToCustomerAddressFromJSON(BillToAddressJSON: Text;var SalesOrderEntityBuffer: Record "Sales Order Entity Buffer")
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        RecRef: RecordRef;
    begin
        if BillToAddressJSON <> '' then
          with SalesOrderEntityBuffer do begin
            RecRef.GetTable(SalesOrderEntityBuffer);
            GraphMgtComplexTypes.ApplyPostalAddressFromJSON(BillToAddressJSON,RecRef,
              FieldNo("Sell-to Address"),FieldNo("Sell-to Address 2"),FieldNo("Sell-to City"),FieldNo("Sell-to County"),
              FieldNo("Sell-to Country/Region Code"),FieldNo("Sell-to Post Code"));
            RecRef.SetTable(SalesOrderEntityBuffer);
          end;
    end;

    procedure BillToCustomerAddressToJSON(SalesOrderEntityBuffer: Record "Sales Order Entity Buffer") JSON: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        with SalesOrderEntityBuffer do
          GraphMgtComplexTypes.GetPostalAddressJSON("Sell-to Address","Sell-to Address 2",
            "Sell-to City","Sell-to County","Sell-to Country/Region Code","Sell-to Post Code",JSON);
    end;

    procedure UpdateIntegrationRecordIds(OnlyRecordsWithoutID: Boolean)
    var
        DummySalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        DummyCustomer: Record Customer;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        SalesHeaderRecordRef: RecordRef;
        CustomerRecordRef: RecordRef;
    begin
        CustomerRecordRef.Open(DATABASE::Customer);
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          CustomerRecordRef,DummyCustomer.FieldNo(Id),true);

        SalesHeaderRecordRef.Open(DATABASE::"Sales Header");
        GraphMgtGeneralTools.UpdateIntegrationRecords(
          SalesHeaderRecordRef,DummySalesOrderEntityBuffer.FieldNo(Id),OnlyRecordsWithoutID);
    end;

    local procedure CheckSupportedTable(var RecRef: RecordRef): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        if RecRef.Number = DATABASE::"Sales Header" then begin
          RecRef.SetTable(SalesHeader);
          exit(SalesHeader."Document Type" = SalesHeader."Document Type"::Order);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnUpdateReferencedIdField', '', false, false)]
    local procedure HandleUpdateReferencedIdFieldOnSalesInvoiceHeader(var RecRef: RecordRef;NewId: Guid;var Handled: Boolean)
    var
        DummySalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleUpdateReferencedIdFieldOnItem(
          RecRef,NewId,Handled,RecRef.Number,DummySalesOrderEntityBuffer.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5150, 'OnGetPredefinedIdValue', '', false, false)]
    local procedure HandleGetPredefinedIdValue(var Id: Guid;var RecRef: RecordRef;var Handled: Boolean)
    var
        DummySalesOrderEntityBuffer: Record "Sales Order Entity Buffer";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        if not CheckSupportedTable(RecRef) then
          exit;

        GraphMgtGeneralTools.HandleGetPredefinedIdValue(
          Id,RecRef,Handled,RecRef.Number,DummySalesOrderEntityBuffer.FieldNo(Id));
    end;

    [EventSubscriber(ObjectType::Codeunit, 5465, 'ApiSetup', '', false, false)]
    procedure HandleApiSetup()
    var
        GraphMgtSalesOrderBuffer: Codeunit "Graph Mgt - Sales Order Buffer";
    begin
        UpdateIntegrationRecordIds(false);
        GraphMgtSalesOrderBuffer.UpdateBufferTableRecords;
    end;
}

