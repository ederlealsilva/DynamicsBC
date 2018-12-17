codeunit 5771 "Whse.-Sales Release"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        WhseRqst: Record "Warehouse Request";
        SalesLine: Record "Sales Line";
        Location: Record Location;
        OldLocationCode: Code[10];
        First: Boolean;

    [Scope('Personalization')]
    procedure Release(SalesHeader: Record "Sales Header")
    var
        WhseType: Option Inbound,Outbound;
        OldWhseType: Option Inbound,Outbound;
    begin
        with SalesHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              WhseRqst."Source Document" := WhseRqst."Source Document"::"Sales Order";
            "Document Type"::"Return Order":
              WhseRqst."Source Document" := WhseRqst."Source Document"::"Sales Return Order";
            else
              exit;
          end;

          SalesLine.SetCurrentKey("Document Type","Document No.","Location Code");
          SalesLine.SetRange("Document Type","Document Type");
          SalesLine.SetRange("Document No.","No.");
          SalesLine.SetRange(Type,SalesLine.Type::Item);
          SalesLine.SetRange("Drop Shipment",false);
          SalesLine.SetRange("Job No.",'');
          if SalesLine.FindSet then begin
            First := true;
            repeat
              if (("Document Type" = "Document Type"::Order) and (SalesLine.Quantity >= 0)) or
                 (("Document Type" = "Document Type"::"Return Order") and (SalesLine.Quantity < 0))
              then
                WhseType := WhseType::Outbound
              else
                WhseType := WhseType::Inbound;

              if First or (SalesLine."Location Code" <> OldLocationCode) or (WhseType <> OldWhseType) then
                CreateWhseRqst(SalesHeader,SalesLine,WhseType);

              First := false;
              OldLocationCode := SalesLine."Location Code";
              OldWhseType := WhseType;
            until SalesLine.Next = 0;
          end;

          WhseRqst.Reset;
          WhseRqst.SetCurrentKey("Source Type","Source Subtype","Source No.");
          WhseRqst.SetRange(Type,WhseRqst.Type);
          WhseRqst.SetRange("Source Type",DATABASE::"Sales Line");
          WhseRqst.SetRange("Source Subtype","Document Type");
          WhseRqst.SetRange("Source No.","No.");
          WhseRqst.SetRange("Document Status",Status::Open);
          if not WhseRqst.IsEmpty then
            WhseRqst.DeleteAll(true);
        end;

        OnAfterRelease(SalesHeader);
    end;

    [Scope('Personalization')]
    procedure Reopen(SalesHeader: Record "Sales Header")
    var
        WhseRqst: Record "Warehouse Request";
    begin
        with SalesHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              WhseRqst.Type := WhseRqst.Type::Outbound;
            "Document Type"::"Return Order":
              WhseRqst.Type := WhseRqst.Type::Inbound;
          end;

          WhseRqst.Reset;
          WhseRqst.SetCurrentKey("Source Type","Source Subtype","Source No.");
          WhseRqst.SetRange(Type,WhseRqst.Type);
          WhseRqst.SetRange("Source Type",DATABASE::"Sales Line");
          WhseRqst.SetRange("Source Subtype","Document Type");
          WhseRqst.SetRange("Source No.","No.");
          WhseRqst.SetRange("Document Status",Status::Released);
          WhseRqst.LockTable;
          if not WhseRqst.IsEmpty then
            WhseRqst.ModifyAll("Document Status",WhseRqst."Document Status"::Open);
        end;

        OnAfterReopen(SalesHeader);
    end;

    local procedure CreateWhseRqst(SalesHeader: Record "Sales Header";var SalesLine: Record "Sales Line";WhseType: Option Inbound,Outbound)
    var
        SalesLine2: Record "Sales Line";
    begin
        if ((WhseType = WhseType::Outbound) and
            (Location.RequireShipment(SalesLine."Location Code") or
             Location.RequirePicking(SalesLine."Location Code"))) or
           ((WhseType = WhseType::Inbound) and
            (Location.RequireReceive(SalesLine."Location Code") or
             Location.RequirePutaway(SalesLine."Location Code")))
        then begin
          SalesLine2.Copy(SalesLine);
          SalesLine2.SetRange("Location Code",SalesLine."Location Code");
          SalesLine2.SetRange("Unit of Measure Code",'');
          if SalesLine2.FindFirst then
            SalesLine2.TestField("Unit of Measure Code");

          WhseRqst.Type := WhseType;
          WhseRqst."Source Type" := DATABASE::"Sales Line";
          WhseRqst."Source Subtype" := SalesHeader."Document Type";
          WhseRqst."Source No." := SalesHeader."No.";
          WhseRqst."Shipment Method Code" := SalesHeader."Shipment Method Code";
          WhseRqst."Shipping Agent Code" := SalesHeader."Shipping Agent Code";
          WhseRqst."Shipping Advice" := SalesHeader."Shipping Advice";
          WhseRqst."Document Status" := SalesHeader.Status::Released;
          WhseRqst."Location Code" := SalesLine."Location Code";
          WhseRqst."Destination Type" := WhseRqst."Destination Type"::Customer;
          WhseRqst."Destination No." := SalesHeader."Sell-to Customer No.";
          WhseRqst."External Document No." := SalesHeader."External Document No.";
          if WhseType = WhseType::Inbound then
            WhseRqst."Expected Receipt Date" := SalesHeader."Shipment Date"
          else
            WhseRqst."Shipment Date" := SalesHeader."Shipment Date";
          SalesHeader.SetRange("Location Filter",SalesLine."Location Code");
          SalesHeader.CalcFields("Completely Shipped");
          WhseRqst."Completely Handled" := SalesHeader."Completely Shipped";
          OnBeforeCreateWhseRequest(WhseRqst,SalesHeader,SalesLine);
          if not WhseRqst.Insert then
            WhseRqst.Modify;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWhseRequest(var WhseRqst: Record "Warehouse Request";SalesHeader: Record "Sales Header";SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var SalesHeader: Record "Sales Header")
    begin
    end;
}

