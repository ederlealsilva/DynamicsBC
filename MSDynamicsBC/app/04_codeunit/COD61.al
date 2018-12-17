codeunit 61 "Sales-Disc. (Yes/No)"
{
    // version NAVW110.0

    TableNo = "Sales Line";

    trigger OnRun()
    begin
        SalesLine.Copy(Rec);
        with SalesLine do begin
          if Confirm(Text000,false) then
            CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount",SalesLine);
        end;
        Rec := SalesLine;
    end;

    var
        Text000: Label 'Do you want to calculate the invoice discount?';
        SalesLine: Record "Sales Line";
}

