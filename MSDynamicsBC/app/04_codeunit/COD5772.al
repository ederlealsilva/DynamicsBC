codeunit 5772 "Whse.-Purch. Release"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        WhseRqst: Record "Warehouse Request";
        PurchLine: Record "Purchase Line";
        Location: Record Location;
        OldLocationCode: Code[10];
        First: Boolean;

    [Scope('Personalization')]
    procedure Release(PurchHeader: Record "Purchase Header")
    var
        WhseType: Option Inbound,Outbound;
        OldWhseType: Option Inbound,Outbound;
    begin
        with PurchHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              WhseRqst."Source Document" := WhseRqst."Source Document"::"Purchase Order";
            "Document Type"::"Return Order":
              WhseRqst."Source Document" := WhseRqst."Source Document"::"Purchase Return Order";
            else
              exit;
          end;

          PurchLine.SetCurrentKey("Document Type","Document No.","Location Code");
          PurchLine.SetRange("Document Type","Document Type");
          PurchLine.SetRange("Document No.","No.");
          PurchLine.SetRange(Type,PurchLine.Type::Item);
          PurchLine.SetRange("Drop Shipment",false);
          PurchLine.SetRange("Job No.",'');
          PurchLine.SetRange("Work Center No.",'');
          if PurchLine.Find('-') then begin
            First := true;
            repeat
              if (("Document Type" = "Document Type"::Order) and (PurchLine.Quantity >= 0)) or
                 (("Document Type" = "Document Type"::"Return Order") and (PurchLine.Quantity < 0))
              then
                WhseType := WhseType::Inbound
              else
                WhseType := WhseType::Outbound;
              if First or (PurchLine."Location Code" <> OldLocationCode) or (WhseType <> OldWhseType) then
                CreateWhseRqst(PurchHeader,PurchLine,WhseType);
              First := false;
              OldLocationCode := PurchLine."Location Code";
              OldWhseType := WhseType;
            until PurchLine.Next = 0;
          end;

          FilterWarehouseRequest(WhseRqst,PurchHeader,WhseRqst."Document Status"::Open);
          if not WhseRqst.IsEmpty then
            WhseRqst.DeleteAll(true);
        end;

        OnAfterRelease(PurchHeader);
    end;

    [Scope('Personalization')]
    procedure Reopen(PurchHeader: Record "Purchase Header")
    begin
        with PurchHeader do begin
          case "Document Type" of
            "Document Type"::Order:
              WhseRqst.Type := WhseRqst.Type::Inbound;
            "Document Type"::"Return Order":
              WhseRqst.Type := WhseRqst.Type::Outbound;
          end;

          FilterWarehouseRequest(WhseRqst,PurchHeader,WhseRqst."Document Status"::Released);
          if not WhseRqst.IsEmpty then
            WhseRqst.ModifyAll("Document Status",WhseRqst."Document Status"::Open);
        end;

        OnAfterReopen(PurchHeader);
    end;

    local procedure CreateWhseRqst(var PurchHeader: Record "Purchase Header";var PurchLine: Record "Purchase Line";WhseType: Option Inbound,Outbound)
    var
        PurchLine2: Record "Purchase Line";
    begin
        if ((WhseType = WhseType::Outbound) and
            (Location.RequireShipment(PurchLine."Location Code") or
             Location.RequirePicking(PurchLine."Location Code"))) or
           ((WhseType = WhseType::Inbound) and
            (Location.RequireReceive(PurchLine."Location Code") or
             Location.RequirePutaway(PurchLine."Location Code")))
        then begin
          PurchLine2.Copy(PurchLine);
          PurchLine2.SetRange("Location Code",PurchLine."Location Code");
          PurchLine2.SetRange("Unit of Measure Code",'');
          if PurchLine2.FindFirst then
            PurchLine2.TestField("Unit of Measure Code");

          WhseRqst.Type := WhseType;
          WhseRqst."Source Type" := DATABASE::"Purchase Line";
          WhseRqst."Source Subtype" := PurchHeader."Document Type";
          WhseRqst."Source No." := PurchHeader."No.";
          WhseRqst."Shipment Method Code" := PurchHeader."Shipment Method Code";
          WhseRqst."Document Status" := PurchHeader.Status::Released;
          WhseRqst."Location Code" := PurchLine."Location Code";
          WhseRqst."Destination Type" := WhseRqst."Destination Type"::Vendor;
          WhseRqst."Destination No." := PurchHeader."Buy-from Vendor No.";
          WhseRqst."External Document No." := PurchHeader."Vendor Shipment No.";
          if WhseType = WhseType::Inbound then
            WhseRqst."Expected Receipt Date" := PurchHeader."Expected Receipt Date"
          else
            WhseRqst."Shipment Date" := PurchHeader."Expected Receipt Date";
          PurchHeader.SetRange("Location Filter",PurchLine."Location Code");
          PurchHeader.CalcFields("Completely Received");
          WhseRqst."Completely Handled" := PurchHeader."Completely Received";
          OnBeforeCreateWhseRequest(WhseRqst,PurchHeader,PurchLine);
          if not WhseRqst.Insert then
            WhseRqst.Modify;
        end;
    end;

    local procedure FilterWarehouseRequest(var WarehouseRequest: Record "Warehouse Request";PurchaseHeader: Record "Purchase Header";DocumentStatus: Option)
    begin
        with WarehouseRequest do begin
          Reset;
          SetCurrentKey("Source Type","Source Subtype","Source No.");
          SetRange(Type,Type);
          SetRange("Source Type",DATABASE::"Purchase Line");
          SetRange("Source Subtype",PurchaseHeader."Document Type");
          SetRange("Source No.",PurchaseHeader."No.");
          SetRange("Document Status",DocumentStatus);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateWhseRequest(var WhseRqst: Record "Warehouse Request";PurchHeader: Record "Purchase Header";PurchLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRelease(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReopen(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}

