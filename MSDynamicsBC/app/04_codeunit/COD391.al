codeunit 391 "Shipment Header - Edit"
{
    // version NAVW111.00

    Permissions = TableData "Sales Shipment Header"=m;
    TableNo = "Sales Shipment Header";

    trigger OnRun()
    begin
        SalesShptHeader := Rec;
        SalesShptHeader.LockTable;
        SalesShptHeader.Find;
        SalesShptHeader."Shipping Agent Code" := "Shipping Agent Code";
        SalesShptHeader."Shipping Agent Service Code" := "Shipping Agent Service Code";
        SalesShptHeader."Package Tracking No." := "Package Tracking No.";
        OnBeforeSalesShptHeaderModify(SalesShptHeader,Rec);
        SalesShptHeader.TestField("No.","No.");
        SalesShptHeader.Modify;
        Rec := SalesShptHeader;
    end;

    var
        SalesShptHeader: Record "Sales Shipment Header";

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesShptHeaderModify(var SalesShptHeader: Record "Sales Shipment Header";FromSalesShptHeader: Record "Sales Shipment Header")
    begin
    end;
}

