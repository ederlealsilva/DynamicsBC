codeunit 5781 "Whse. Validate Source Header"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure SalesHeaderVerifyChange(var NewSalesHeader: Record "Sales Header";var OldSalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        with NewSalesHeader do begin
          if "Shipping Advice" = OldSalesHeader."Shipping Advice" then
            exit;

          SalesLine.Reset;
          SalesLine.SetRange("Document Type",OldSalesHeader."Document Type");
          SalesLine.SetRange("Document No.",OldSalesHeader."No.");
          if SalesLine.FindSet then
            repeat
              ChangeWhseLines(
                DATABASE::"Sales Line",
                SalesLine."Document Type",
                SalesLine."Document No.",
                SalesLine."Line No.",
                0,
                "Shipping Advice");
            until SalesLine.Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure ServiceHeaderVerifyChange(var NewServiceHeader: Record "Service Header";var OldServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
    begin
        with NewServiceHeader do begin
          if "Shipping Advice" = OldServiceHeader."Shipping Advice" then
            exit;

          ServiceLine.Reset;
          ServiceLine.SetRange("Document Type",OldServiceHeader."Document Type");
          ServiceLine.SetRange("Document No.",OldServiceHeader."No.");
          if ServiceLine.Find('-') then
            repeat
              ChangeWhseLines(
                DATABASE::"Service Line",
                ServiceLine."Document Type",
                ServiceLine."Document No.",
                ServiceLine."Line No.",
                0,
                "Shipping Advice");
            until ServiceLine.Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure TransHeaderVerifyChange(var NewTransHeader: Record "Transfer Header";var OldTransHeader: Record "Transfer Header")
    var
        TransLine: Record "Transfer Line";
    begin
        with NewTransHeader do begin
          if "Shipping Advice" = OldTransHeader."Shipping Advice" then
            exit;

          TransLine.Reset;
          TransLine.SetRange("Document No.",OldTransHeader."No.");
          if TransLine.Find('-') then
            repeat
              ChangeWhseLines(
                DATABASE::"Transfer Line",
                0,// Outbound Transfer
                TransLine."Document No.",
                TransLine."Line No.",
                0,
                "Shipping Advice");
            until TransLine.Next = 0;
        end;
    end;

    local procedure ChangeWhseLines(SourceType: Integer;SourceSubType: Option;SourceNo: Code[20];SourceLineNo: Integer;SourceSublineNo: Integer;ShipAdvice: Integer)
    var
        WhseActivLine: Record "Warehouse Activity Line";
        WhseShptLine: Record "Warehouse Shipment Line";
        WhseWkshLine: Record "Whse. Worksheet Line";
    begin
        WhseShptLine.Reset;
        WhseShptLine.SetSourceFilter(SourceType,SourceSubType,SourceNo,SourceLineNo,false);
        WhseShptLine.ModifyAll("Shipping Advice",ShipAdvice);

        WhseActivLine.Reset;
        WhseActivLine.SetSourceFilter(SourceType,SourceSubType,SourceNo,SourceLineNo,SourceSublineNo,false);
        WhseActivLine.ModifyAll("Shipping Advice",ShipAdvice);

        WhseWkshLine.Reset;
        WhseWkshLine.SetSourceFilter(SourceType,SourceSubType,SourceNo,SourceLineNo,false);
        WhseWkshLine.ModifyAll("Shipping Advice",ShipAdvice);
    end;
}

