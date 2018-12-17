codeunit 7323 "Whse.-Act.-Post (Yes/No)"
{
    // version NAVW113.00

    TableNo = "Warehouse Activity Line";

    trigger OnRun()
    begin
        WhseActivLine.Copy(Rec);
        Code;
        Copy(WhseActivLine);
    end;

    var
        Text000: Label '&Receive,Receive &and Invoice';
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivityPost: Codeunit "Whse.-Activity-Post";
        Selection: Integer;
        Text001: Label '&Ship,Ship &and Invoice';
        Text002: Label 'Do you want to post the %1 and %2?';
        PrintDoc: Boolean;

    local procedure "Code"()
    var
        HideDialog: Boolean;
    begin
        HideDialog := false;
        OnBeforeConfirmPost(WhseActivLine,HideDialog,Selection);

        with WhseActivLine do begin
          if not HideDialog then
            case "Activity Type" of
              "Activity Type"::"Invt. Put-away":
                if not SelectForPutAway then
                  exit;
              else
                if not SelectForOtherTypes then
                  exit;
            end;

          WhseActivityPost.SetInvoiceSourceDoc(Selection = 2);
          WhseActivityPost.PrintDocument(PrintDoc);
          WhseActivityPost.Run(WhseActivLine);
          Clear(WhseActivityPost);
        end;
    end;

    [Scope('Personalization')]
    procedure PrintDocument(SetPrint: Boolean)
    begin
        PrintDoc := SetPrint;
    end;

    local procedure SelectForPutAway(): Boolean
    begin
        with WhseActivLine do
          if ("Source Document" = "Source Document"::"Prod. Output") or
             ("Source Document" = "Source Document"::"Inbound Transfer") or
             ("Source Document" = "Source Document"::"Prod. Consumption")
          then begin
            if not Confirm(Text002,false,"Activity Type","Source Document") then
              exit(false);
          end else begin
            Selection := StrMenu(Text000,2);
            if Selection = 0 then
              exit(false);
          end;

        exit(true);
    end;

    local procedure SelectForOtherTypes(): Boolean
    begin
        with WhseActivLine do
          if ("Source Document" = "Source Document"::"Prod. Consumption") or
             ("Source Document" = "Source Document"::"Outbound Transfer")
          then begin
            if not Confirm(Text002,false,"Activity Type","Source Document") then
              exit(false);
          end else begin
            Selection := StrMenu(Text001,2);
            if Selection = 0 then
              exit(false);
          end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmPost(var WhseActivLine: Record "Warehouse Activity Line";var HideDialog: Boolean;var Selection: Integer)
    begin
    end;
}

