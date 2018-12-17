codeunit 745 "VAT Report Suggest Lines"
{
    // version NAVW111.00

    TableNo = "VAT Report Header";

    trigger OnRun()
    begin
        REPORT.RunModal(REPORT::"VAT Report Request Page",true,false,Rec);
    end;
}

