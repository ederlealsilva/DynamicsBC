codeunit 5766 "Whse.-Post Receipt + Pr. Pos."
{
    // version NAVW19.00

    TableNo = "Warehouse Receipt Line";

    trigger OnRun()
    begin
        WhseReceiptLine.Copy(Rec);
        Code;
    end;

    var
        PostedWhseRcptHeader: Record "Posted Whse. Receipt Header";
        WhseReceiptLine: Record "Warehouse Receipt Line";
        Text001: Label 'Number of posted whse. receipts printed: 1.';

    local procedure "Code"()
    var
        WhsePostReceipt: Codeunit "Whse.-Post Receipt";
    begin
        with WhseReceiptLine do begin
          WhsePostReceipt.Run(WhseReceiptLine);
          WhsePostReceipt.GetResultMessage;

          PostedWhseRcptHeader.SetRange("Whse. Receipt No.","No.");
          PostedWhseRcptHeader.SetRange("Location Code","Location Code");
          PostedWhseRcptHeader.FindLast;
          PostedWhseRcptHeader.SetRange("No.",PostedWhseRcptHeader."No.");
          REPORT.Run(REPORT::"Whse. - Posted Receipt",false,false,PostedWhseRcptHeader);
          Message(Text001);

          Clear(WhsePostReceipt);
        end;
    end;
}

