table 750 "Standard General Journal"
{
    // version NAVW113.00

    Caption = 'Standard General Journal';
    LookupPageID = "Standard General Journals";

    fields
    {
        field(1;"Journal Template Name";Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            TableRelation = "Gen. Journal Template";
        }
        field(2;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Journal Template Name","Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        StdGenJnlLine: Record "Standard General Journal Line";
    begin
        StdGenJnlLine.SetRange("Journal Template Name","Journal Template Name");
        StdGenJnlLine.SetRange("Standard Journal Code",Code);

        StdGenJnlLine.DeleteAll(true);
    end;

    var
        GenJnlBatch: Record "Gen. Journal Batch";
        LastGenJnlLine: Record "Gen. Journal Line";
        GenJnlLine: Record "Gen. Journal Line";
        Window: Dialog;
        WindowUpdateDateTime: DateTime;
        NoOfJournalsToBeCreated: Integer;
        Text000: Label 'Getting Standard General Journal Lines @1@@@@@@@';
        NoOfJournalsCreated: Integer;

    [Scope('Personalization')]
    procedure CreateGenJnlFromStdJnl(StdGenJnl: Record "Standard General Journal";JnlBatchName: Code[10])
    var
        StdGenJnlLine: Record "Standard General Journal Line";
    begin
        Initialize(StdGenJnl,JnlBatchName);

        StdGenJnlLine.SetRange("Journal Template Name",StdGenJnl."Journal Template Name");
        StdGenJnlLine.SetRange("Standard Journal Code",StdGenJnl.Code);
        OpenWindow(Text000,StdGenJnlLine.Count);
        if StdGenJnlLine.Find('-') then
          repeat
            UpdateWindow;
            CopyGenJnlFromStdJnl(StdGenJnlLine);
          until StdGenJnlLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure Initialize(var StdGenJnl: Record "Standard General Journal";JnlBatchName: Code[10])
    begin
        GenJnlLine."Journal Template Name" := StdGenJnl."Journal Template Name";
        GenJnlLine."Journal Batch Name" := JnlBatchName;
        GenJnlLine.SetRange("Journal Template Name",StdGenJnl."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name",JnlBatchName);

        LastGenJnlLine.SetRange("Journal Template Name",StdGenJnl."Journal Template Name");
        LastGenJnlLine.SetRange("Journal Batch Name",JnlBatchName);

        if LastGenJnlLine.FindLast then;

        GenJnlBatch.SetRange("Journal Template Name",StdGenJnl."Journal Template Name");
        GenJnlBatch.SetRange(Name,JnlBatchName);

        if GenJnlBatch.FindFirst then;
    end;

    local procedure CopyGenJnlFromStdJnl(StdGenJnlLine: Record "Standard General Journal Line")
    var
        GenJnlManagement: Codeunit GenJnlManagement;
        Balance: Decimal;
        TotalBalance: Decimal;
        ShowBalance: Boolean;
        ShowTotalBalance: Boolean;
    begin
        GenJnlLine.Init;
        GenJnlLine."Line No." := 0;
        GenJnlManagement.CalcBalance(GenJnlLine,LastGenJnlLine,Balance,TotalBalance,ShowBalance,ShowTotalBalance);
        GenJnlLine.SetUpNewLine(LastGenJnlLine,Balance,true);
        if LastGenJnlLine."Line No." <> 0 then
          GenJnlLine."Line No." := LastGenJnlLine."Line No." + 10000
        else
          GenJnlLine."Line No." := 10000;

        GenJnlLine.TransferFields(StdGenJnlLine,false);
        GenJnlLine.UpdateLineBalance;
        GenJnlLine."Currency Factor" := 0;
        GenJnlLine.Validate("Currency Code");

        if GenJnlLine."VAT Prod. Posting Group" <> '' then
          GenJnlLine.Validate("VAT Prod. Posting Group");
        if (GenJnlLine."VAT %" <> 0) and GenJnlBatch."Allow VAT Difference" then
          GenJnlLine.Validate("VAT Amount",StdGenJnlLine."VAT Amount");
        GenJnlLine.Validate("Bal. VAT Prod. Posting Group");
        GenJnlLine."Dimension Set ID" := StdGenJnlLine."Dimension Set ID";
        if GenJnlBatch."Allow VAT Difference" then
          GenJnlLine.Validate("Bal. VAT Amount",StdGenJnlLine."Bal. VAT Amount");
        OnAfterCopyGenJnlFromStdJnl(GenJnlLine,StdGenJnlLine);
        GenJnlLine.Insert(true);

        LastGenJnlLine := GenJnlLine;
    end;

    local procedure OpenWindow(DisplayText: Text[250];NoOfJournalsToBeCreated2: Integer)
    begin
        NoOfJournalsCreated := 0;
        NoOfJournalsToBeCreated := NoOfJournalsToBeCreated2;
        WindowUpdateDateTime := CurrentDateTime;
        Window.Open(DisplayText);
    end;

    local procedure UpdateWindow()
    begin
        NoOfJournalsCreated := NoOfJournalsCreated + 1;
        if CurrentDateTime - WindowUpdateDateTime >= 300 then begin
          WindowUpdateDateTime := CurrentDateTime;
          Window.Update(1,Round(NoOfJournalsCreated / NoOfJournalsToBeCreated * 10000,1));
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyGenJnlFromStdJnl(var GenJournalLine: Record "Gen. Journal Line";StdGenJournalLine: Record "Standard General Journal Line")
    begin
    end;
}

