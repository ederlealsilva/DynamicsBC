codeunit 242 "Item Jnl.-Post+Print"
{
    // version NAVW17.00

    TableNo = "Item Journal Line";

    trigger OnRun()
    begin
        ItemJnlLine.Copy(Rec);
        Code;
        Copy(ItemJnlLine);
    end;

    var
        Text000: Label 'cannot be filtered when posting recurring journals';
        Text001: Label 'Do you want to post the journal lines and print the posting report?';
        Text002: Label 'There is nothing to post.';
        Text003: Label 'The journal lines were successfully posted.';
        Text004: Label 'The journal lines were successfully posted. ';
        Text005: Label 'You are now in the %1 journal.';
        ItemJnlTemplate: Record "Item Journal Template";
        ItemJnlLine: Record "Item Journal Line";
        ItemReg: Record "Item Register";
        WhseReg: Record "Warehouse Register";
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        TempJnlBatchName: Code[10];

    local procedure "Code"()
    begin
        with ItemJnlLine do begin
          ItemJnlTemplate.Get("Journal Template Name");
          ItemJnlTemplate.TestField("Posting Report ID");
          if ItemJnlTemplate.Recurring and (GetFilter("Posting Date") <> '') then
            FieldError("Posting Date",Text000);

          if not Confirm(Text001,false) then
            exit;

          TempJnlBatchName := "Journal Batch Name";

          ItemJnlPostBatch.Run(ItemJnlLine);

          if ItemReg.Get(ItemJnlPostBatch.GetItemRegNo) then begin
            ItemReg.SetRecFilter;
            REPORT.Run(ItemJnlTemplate."Posting Report ID",false,false,ItemReg);
          end;

          if WhseReg.Get(ItemJnlPostBatch.GetWhseRegNo) then begin
            WhseReg.SetRecFilter;
            REPORT.Run(ItemJnlTemplate."Whse. Register Report ID",false,false,WhseReg);
          end;

          if (ItemJnlPostBatch.GetItemRegNo = 0) and
             (ItemJnlPostBatch.GetWhseRegNo = 0)
          then
            Message(Text002)
          else
            if TempJnlBatchName = "Journal Batch Name" then
              Message(Text003)
            else
              Message(
                Text004 +
                Text005,
                "Journal Batch Name");

          if not Find('=><') or (TempJnlBatchName <> "Journal Batch Name") then begin
            Reset;
            FilterGroup(2);
            SetRange("Journal Template Name","Journal Template Name");
            SetRange("Journal Batch Name","Journal Batch Name");
            FilterGroup(0);
            "Line No." := 1;
          end;
        end;
    end;
}

