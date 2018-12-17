codeunit 7306 "Whse.-Act.-Register (Yes/No)"
{
    // version NAVW17.00

    TableNo = "Warehouse Activity Line";

    trigger OnRun()
    begin
        WhseActivLine.Copy(Rec);
        Code;
        Copy(WhseActivLine);
    end;

    var
        Text001: Label 'Do you want to register the %1 Document?';
        WhseActivLine: Record "Warehouse Activity Line";
        WhseActivityRegister: Codeunit "Whse.-Activity-Register";
        WMSMgt: Codeunit "WMS Management";
        Text002: Label 'The document %1 is not supported.';

    local procedure "Code"()
    begin
        with WhseActivLine do begin
          if ("Activity Type" = "Activity Type"::"Invt. Movement") and
             not ("Source Document" in ["Source Document"::" ",
                                        "Source Document"::"Prod. Consumption",
                                        "Source Document"::"Assembly Consumption"])
          then
            Error(Text002,"Source Document");

          WMSMgt.CheckBalanceQtyToHandle(WhseActivLine);

          if not Confirm(Text001,false,"Activity Type") then
            exit;

          WhseActivityRegister.Run(WhseActivLine);
          Clear(WhseActivityRegister);
        end;
    end;
}

