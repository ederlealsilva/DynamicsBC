codeunit 5951 "Service-Disc. (Yes/No)"
{
    // version NAVW110.0

    TableNo = "Service Line";

    trigger OnRun()
    begin
        ServiceLine.Copy(Rec);
        with ServiceLine do begin
          if Confirm(Text000,false) then
            CODEUNIT.Run(CODEUNIT::"Service-Calc. Discount",ServiceLine);
        end;
        Rec := ServiceLine;
    end;

    var
        Text000: Label 'Do you want to calculate the invoice discount?';
        ServiceLine: Record "Service Line";
}

