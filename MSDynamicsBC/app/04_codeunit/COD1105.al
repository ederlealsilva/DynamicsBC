codeunit 1105 "Transfer GL Entries to CA"
{
    // version NAVW113.00

    Permissions = TableData "G/L Entry"=rm;

    trigger OnRun()
    begin
        ConfirmTransferGLtoCA;
    end;

    var
        CostAccSetup: Record "Cost Accounting Setup";
        GLEntry: Record "G/L Entry";
        CostType: Record "Cost Type";
        TempCostJnlLine: Record "Cost Journal Line" temporary;
        CostRegister: Record "Cost Register";
        CostAccMgt: Codeunit "Cost Account Mgt";
        Window: Dialog;
        LastLineNo: Integer;
        NoOfCombinedEntries: Integer;
        FirstGLEntryNo: Integer;
        LastGLEntryNo: Integer;
        NoOfJnlLines: Integer;
        TotalDebit: Decimal;
        TotalCredit: Decimal;
        PostingDate: Date;
        BatchRun: Boolean;
        GotCostAccSetup: Boolean;
        Text000: Label 'Income statement accounts that have cost centers or cost objects will be transferred to Cost Accounting.\All entries since the last transfer will be processed.\\The link between cost type and G/L account will be verified.\\Do you want to start the transfer?';
        Text001: Label 'Transfer G/L Entries to Cost Accounting.\G/L Entry No.          #1########\Cost Type              #2########\Combined entries       #3########\No. of Cost Entries    #4########';
        Text002: Label 'G/L entries from No. %1 have been processed. %2 cost entries have been created.';
        Text003: Label 'Combined entries per month %1', Comment='%1 - Posting Date.';
        Text004: Label 'Combined entries per day %1', Comment='%1 - Posting Date';
        Text005: Label 'Could not transfer general ledger entries to Cost Accounting.';
        Text006: Label 'Posting Cost Entries @1@@@@@@@@@@\';

    local procedure ConfirmTransferGLtoCA()
    begin
        if not Confirm(Text000) then
          exit;

        TransferGLtoCA;

        Message(Text002,FirstGLEntryNo,NoOfJnlLines);
    end;

    [Scope('Personalization')]
    procedure TransferGLtoCA()
    begin
        ClearAll;

        CostAccMgt.LinkCostTypesToGLAccounts;

        Window.Open(Text001);

        BatchRun := true;
        GetGLEntries;

        Window.Close;
    end;

    [Scope('Personalization')]
    procedure GetGLEntries()
    var
        SourceCodeSetup: Record "Source Code Setup";
        CostCenterCode: Code[20];
        CostObjectCode: Code[20];
        CombinedEntryText: Text[50];
    begin
        GetCostAccSetup;
        SourceCodeSetup.Get;
        SourceCodeSetup.TestField("G/L Entry to CA");

        if not BatchRun then begin
          if not CostAccSetup."Auto Transfer from G/L" then
            exit;
          TempCostJnlLine.DeleteAll;
          ClearAll;
          GetCostAccSetup;
        end;

        CostRegister.LockTable;
        CostRegister.SetCurrentKey(Source);
        CostRegister.SetRange(Source,CostRegister.Source::"Transfer from G/L");
        if CostRegister.FindLast then
          FirstGLEntryNo := CostRegister."To G/L Entry No." + 1
        else
          FirstGLEntryNo := 1;

        if GLEntry.FindLast then
          LastGLEntryNo := GLEntry."Entry No.";

        GLEntry.SetRange("Entry No.",FirstGLEntryNo,LastGLEntryNo);
        GLEntry.SetFilter("Posting Date",'%1..',CostAccSetup."Starting Date for G/L Transfer");

        if GLEntry.FindSet then
          repeat
            if BatchRun and ((GLEntry."Entry No." mod 100) = 0) then
              Window.Update(1,Format(GLEntry."Entry No."));
            CostCenterCode := '';
            CostObjectCode := '';

            if not SkipGLEntry(GLEntry) then
              case true of // only need Cost Center or Cost Object
                GetCostCenterCode(GLEntry."Dimension Set ID",CostCenterCode),
                GetCostObjectCode(GLEntry."Dimension Set ID",CostObjectCode):
                  begin
                    case CostType."Combine Entries" of
                      CostType."Combine Entries"::None:
                        PostingDate := GLEntry."Posting Date";
                      CostType."Combine Entries"::Month:
                        begin
                          PostingDate := CalcDate('<CM>',GLEntry."Posting Date");
                          CombinedEntryText := StrSubstNo(Text003,PostingDate);
                        end;
                      CostType."Combine Entries"::Day:
                        begin
                          PostingDate := GLEntry."Posting Date";
                          CombinedEntryText := StrSubstNo(Text004,PostingDate);
                        end;
                    end;

                    if CostType."Combine Entries" <> CostType."Combine Entries"::None then begin
                      TempCostJnlLine.Reset;
                      TempCostJnlLine.SetRange("Cost Type No.",CostType."No.");
                      if CostCenterCode <> '' then
                        TempCostJnlLine.SetRange("Cost Center Code",CostCenterCode)
                      else
                        TempCostJnlLine.SetRange("Cost Object Code",CostObjectCode);
                      TempCostJnlLine.SetRange("Posting Date",PostingDate);
                      if TempCostJnlLine.FindFirst then
                        ModifyCostJournalLine(CombinedEntryText)
                      else
                        InsertCostJournalLine(CostCenterCode,CostObjectCode);
                    end else
                      InsertCostJournalLine(CostCenterCode,CostObjectCode);

                    if BatchRun and ((GLEntry."Entry No." mod 100) = 0) then begin
                      Window.Update(2,CostType."No.");
                      Window.Update(3,Format(NoOfCombinedEntries));
                      Window.Update(4,Format(NoOfJnlLines));
                    end;
                  end;
              end;
          until GLEntry.Next = 0;

        if NoOfJnlLines = 0 then begin
          if BatchRun then begin
            Window.Close;
            Error(Text005);
          end;
          exit;
        end;

        PostCostJournalLines;
    end;

    local procedure InsertCostJournalLine(CostCenterCode: Code[20];CostObjectCode: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get;
        TempCostJnlLine.Init;
        LastLineNo := LastLineNo + 10000;
        TempCostJnlLine."Line No." := LastLineNo;
        TempCostJnlLine."Cost Type No." := CostType."No.";
        TempCostJnlLine."Posting Date" := PostingDate;
        TempCostJnlLine."Document No." := GLEntry."Document No.";
        TempCostJnlLine.Description := GLEntry.Description;
        TempCostJnlLine.Amount := GLEntry.Amount;
        TempCostJnlLine."Additional-Currency Amount" := GLEntry."Additional-Currency Amount";
        TempCostJnlLine."Add.-Currency Credit Amount" := GLEntry."Add.-Currency Credit Amount";
        TempCostJnlLine."Add.-Currency Debit Amount" := GLEntry."Add.-Currency Debit Amount";
        if CostAccMgt.CostCenterExists(CostCenterCode) then
          TempCostJnlLine."Cost Center Code" := CostCenterCode;
        if CostAccMgt.CostObjectExists(CostObjectCode) then
          TempCostJnlLine."Cost Object Code" := CostObjectCode;
        TempCostJnlLine."Source Code" := SourceCodeSetup."G/L Entry to CA";
        TempCostJnlLine."G/L Entry No." := GLEntry."Entry No.";
        TempCostJnlLine."System-Created Entry" := true;
        TempCostJnlLine.Insert;

        NoOfJnlLines := NoOfJnlLines + 1;
        MaintainTotals(GLEntry.Amount);
    end;

    local procedure ModifyCostJournalLine(EntryText: Text[50])
    begin
        TempCostJnlLine.Description := EntryText;
        TempCostJnlLine.Amount := TempCostJnlLine.Amount + GLEntry.Amount;
        TempCostJnlLine."Additional-Currency Amount" :=
          TempCostJnlLine."Additional-Currency Amount" + GLEntry."Additional-Currency Amount";
        TempCostJnlLine."Add.-Currency Debit Amount" :=
          TempCostJnlLine."Add.-Currency Debit Amount" + GLEntry."Add.-Currency Debit Amount";
        TempCostJnlLine."Add.-Currency Credit Amount" :=
          TempCostJnlLine."Add.-Currency Credit Amount" + GLEntry."Add.-Currency Credit Amount";
        TempCostJnlLine."Document No." := GLEntry."Document No.";
        TempCostJnlLine."G/L Entry No." := GLEntry."Entry No.";
        TempCostJnlLine.Modify;
        NoOfCombinedEntries := NoOfCombinedEntries + 1;
        MaintainTotals(GLEntry.Amount);
    end;

    local procedure PostCostJournalLines()
    var
        CostJnlLine: Record "Cost Journal Line";
        CAJnlPostLine: Codeunit "CA Jnl.-Post Line";
        Window2: Dialog;
        CostJnlLineStep: Integer;
        JournalLineCount: Integer;
    begin
        TempCostJnlLine.Reset;
        Window2.Open(Text006);
        if TempCostJnlLine.Count > 0 then
          JournalLineCount := 10000 * 100000 div TempCostJnlLine.Count;
        TempCostJnlLine.SetCurrentKey("G/L Entry No.");
        if TempCostJnlLine.FindSet then
          repeat
            CostJnlLineStep := CostJnlLineStep + JournalLineCount;
            Window2.Update(1,CostJnlLineStep div 100000);
            CostJnlLine := TempCostJnlLine;
            CAJnlPostLine.RunWithCheck(CostJnlLine);
          until TempCostJnlLine.Next = 0;
        Window2.Close;
    end;

    local procedure GetCostAccSetup()
    begin
        if not GotCostAccSetup then begin
          CostAccSetup.Get;
          GotCostAccSetup := true;
        end;
    end;

    local procedure MaintainTotals(Amount: Decimal)
    begin
        if Amount > 0 then
          TotalDebit := TotalDebit + GLEntry.Amount
        else
          TotalCredit := TotalCredit - GLEntry.Amount;
    end;

    local procedure SkipGLEntry(GLEntry: Record "G/L Entry"): Boolean
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get(GLEntry."G/L Account No.");
        case true of // exit on first TRUE, skipping the other checks
          GLEntry.Amount = 0,
          IsBalanceSheetAccount(GLAcc),
          not IsLinkedToCostType(GLAcc),
          not IsNormalDate(GLEntry."Posting Date"):
            exit(true);
        end;
    end;

    local procedure IsBalanceSheetAccount(GLAcc: Record "G/L Account"): Boolean
    begin
        exit(GLAcc."Income/Balance" = GLAcc."Income/Balance"::"Balance Sheet");
    end;

    local procedure IsLinkedToCostType(GLAcc: Record "G/L Account"): Boolean
    begin
        exit(CostType.Get(GLAcc."Cost Type No."));
    end;

    local procedure IsNormalDate(Date: Date): Boolean
    begin
        exit(Date = NormalDate(Date));
    end;

    local procedure GetCostCenterCode(DimSetID: Integer;var CostCenterCode: Code[20]): Boolean
    begin
        CostCenterCode := CostAccMgt.GetCostCenterCodeFromDimSet(DimSetID);
        exit(CostCenterCode <> '');
    end;

    local procedure GetCostObjectCode(DimSetID: Integer;var CostObjectCode: Code[20]): Boolean
    begin
        CostObjectCode := CostAccMgt.GetCostObjectCodeFromDimSet(DimSetID);
        exit(CostObjectCode <> '');
    end;
}

