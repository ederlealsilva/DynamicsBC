codeunit 71 "Purch.-Disc. (Yes/No)"
{
    // version NAVW110.0

    TableNo = "Purchase Line";

    trigger OnRun()
    begin
        if Confirm(Text000,false) then
          CODEUNIT.Run(CODEUNIT::"Purch.-Calc.Discount",Rec);
    end;

    var
        Text000: Label 'Do you want to calculate the invoice discount?';
}

