report 5692 "Calculate Depreciation"
{
    // version NAVW113.00

    ApplicationArea = #FixedAssets;
    Caption = 'Calculate Depreciation';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Fixed Asset";"Fixed Asset")
        {
            RequestFilterFields = "No.","FA Class Code","FA Subclass Code","Budgeted Asset";

            trigger OnAfterGetRecord()
            begin
                if Inactive or Blocked then
                  CurrReport.Skip;

                CalculateDepr.Calculate(
                  DeprAmount,Custom1Amount,NumberOfDays,Custom1NumberOfDays,
                  "No.",DeprBookCode,DeprUntilDate,EntryAmounts,0D,DaysInPeriod);
                if (DeprAmount <> 0) or (Custom1Amount <> 0) then
                  Window.Update(1,"No.")
                else
                  Window.Update(2,"No.");

                if Custom1Amount <> 0 then
                  if not DeprBook."G/L Integration - Custom 1" or "Budgeted Asset" then begin
                    FAJnlLineTmp."FA No." := "No.";
                    FAJnlLineTmp."FA Posting Type" := FAJnlLineTmp."FA Posting Type"::"Custom 1";
                    FAJnlLineTmp.Amount := Custom1Amount;
                    FAJnlLineTmp."No. of Depreciation Days" := Custom1NumberOfDays;
                    FAJnlLineTmp."FA Error Entry No." := Custom1ErrorNo;
                    FAJnlLineTmp."Line No." := FAJnlLineTmp."Line No." + 1;
                    FAJnlLineTmp.Insert;
                  end else begin
                    GenJnlLineTmp."Account No." := "No.";
                    GenJnlLineTmp."FA Posting Type" := GenJnlLineTmp."FA Posting Type"::"Custom 1";
                    GenJnlLineTmp.Amount := Custom1Amount;
                    GenJnlLineTmp."No. of Depreciation Days" := Custom1NumberOfDays;
                    GenJnlLineTmp."FA Error Entry No." := Custom1ErrorNo;
                    GenJnlLineTmp."Line No." := GenJnlLineTmp."Line No." + 1;
                    GenJnlLineTmp.Insert;
                  end;

                if DeprAmount <> 0 then
                  if not DeprBook."G/L Integration - Depreciation" or "Budgeted Asset" then begin
                    FAJnlLineTmp."FA No." := "No.";
                    FAJnlLineTmp."FA Posting Type" := FAJnlLineTmp."FA Posting Type"::Depreciation;
                    FAJnlLineTmp.Amount := DeprAmount;
                    FAJnlLineTmp."No. of Depreciation Days" := NumberOfDays;
                    FAJnlLineTmp."FA Error Entry No." := ErrorNo;
                    FAJnlLineTmp."Line No." := FAJnlLineTmp."Line No." + 1;
                    FAJnlLineTmp.Insert;
                  end else begin
                    GenJnlLineTmp."Account No." := "No.";
                    GenJnlLineTmp."FA Posting Type" := GenJnlLineTmp."FA Posting Type"::Depreciation;
                    GenJnlLineTmp.Amount := DeprAmount;
                    GenJnlLineTmp."No. of Depreciation Days" := NumberOfDays;
                    GenJnlLineTmp."FA Error Entry No." := ErrorNo;
                    GenJnlLineTmp."Line No." := GenJnlLineTmp."Line No." + 1;
                    GenJnlLineTmp.Insert;
                  end;
            end;

            trigger OnPostDataItem()
            begin
                with FAJnlLine do begin
                  if FAJnlLineTmp.Find('-') then begin
                    LockTable;
                    FAJnlSetup.FAJnlName(DeprBook,FAJnlLine,FAJnlNextLineNo);
                    NoSeries := FAJnlSetup.GetFANoSeries(FAJnlLine);
                    if DocumentNo = '' then
                      DocumentNo2 := FAJnlSetup.GetFAJnlDocumentNo(FAJnlLine,DeprUntilDate,true)
                    else
                      DocumentNo2 := DocumentNo;
                  end;
                  if FAJnlLineTmp.Find('-') then
                    repeat
                      Init;
                      "Line No." := 0;
                      FAJnlSetup.SetFAJnlTrailCodes(FAJnlLine);
                      LineNo := LineNo + 1;
                      Window.Update(3,LineNo);
                      "Posting Date" := PostingDate;
                      "FA Posting Date" := DeprUntilDate;
                      if "Posting Date" = "FA Posting Date" then
                        "Posting Date" := 0D;
                      "FA Posting Type" := FAJnlLineTmp."FA Posting Type";
                      Validate("FA No.",FAJnlLineTmp."FA No.");
                      "Document No." := DocumentNo2;
                      "Posting No. Series" := NoSeries;
                      Description := PostingDescription;
                      Validate("Depreciation Book Code",DeprBookCode);
                      Validate(Amount,FAJnlLineTmp.Amount);
                      "No. of Depreciation Days" := FAJnlLineTmp."No. of Depreciation Days";
                      "FA Error Entry No." := FAJnlLineTmp."FA Error Entry No.";
                      FAJnlNextLineNo := FAJnlNextLineNo + 10000;
                      "Line No." := FAJnlNextLineNo;
                      Insert(true);
                      FAJnlLineCreatedCount += 1;
                    until FAJnlLineTmp.Next = 0;
                end;

                with GenJnlLine do begin
                  if GenJnlLineTmp.Find('-') then begin
                    LockTable;
                    FAJnlSetup.GenJnlName(DeprBook,GenJnlLine,GenJnlNextLineNo);
                    NoSeries := FAJnlSetup.GetGenNoSeries(GenJnlLine);
                    if DocumentNo = '' then
                      DocumentNo2 := FAJnlSetup.GetGenJnlDocumentNo(GenJnlLine,DeprUntilDate,true)
                    else
                      DocumentNo2 := DocumentNo;
                  end;
                  if GenJnlLineTmp.Find('-') then
                    repeat
                      Init;
                      "Line No." := 0;
                      FAJnlSetup.SetGenJnlTrailCodes(GenJnlLine);
                      LineNo := LineNo + 1;
                      Window.Update(3,LineNo);
                      "Posting Date" := PostingDate;
                      "FA Posting Date" := DeprUntilDate;
                      if "Posting Date" = "FA Posting Date" then
                        "FA Posting Date" := 0D;
                      "FA Posting Type" := GenJnlLineTmp."FA Posting Type";
                      "Account Type" := "Account Type"::"Fixed Asset";
                      Validate("Account No.",GenJnlLineTmp."Account No.");
                      Description := PostingDescription;
                      "Document No." := DocumentNo2;
                      "Posting No. Series" := NoSeries;
                      Validate("Depreciation Book Code",DeprBookCode);
                      Validate(Amount,GenJnlLineTmp.Amount);
                      "No. of Depreciation Days" := GenJnlLineTmp."No. of Depreciation Days";
                      "FA Error Entry No." := GenJnlLineTmp."FA Error Entry No.";
                      GenJnlNextLineNo := GenJnlNextLineNo + 1000;
                      "Line No." := GenJnlNextLineNo;
                      Insert(true);
                      GenJnlLineCreatedCount += 1;
                      if BalAccount then
                        FAInsertGLAcc.GetBalAcc2(GenJnlLine,GenJnlNextLineNo);
                    until GenJnlLineTmp.Next = 0;
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DepreciationBook;DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the code for the depreciation book to be included in the report or batch job.';
                    }
                    field(FAPostingDate;DeprUntilDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'FA Posting Date';
                        Importance = Additional;
                        ToolTip = 'Specifies the fixed asset posting date to be used by the batch job. The batch job includes ledger entries up to this date. This date appears in the FA Posting Date field in the resulting journal lines. If the Use Same FA+G/L Posting Dates field has been activated in the depreciation book that is used in the batch job, then this date must be the same as the posting date entered in the Posting Date field.';

                        trigger OnValidate()
                        begin
                            DeprUntilDateModified := true;
                        end;
                    }
                    field(UseForceNoOfDays;UseForceNoOfDays)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Use Force No. of Days';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want the program to use the number of days, as specified in the field below, in the depreciation calculation.';

                        trigger OnValidate()
                        begin
                            if not UseForceNoOfDays then
                              DaysInPeriod := 0;
                        end;
                    }
                    field(ForceNoOfDays;DaysInPeriod)
                    {
                        ApplicationArea = FixedAssets;
                        BlankZero = true;
                        Caption = 'Force No. of Days';
                        Importance = Additional;
                        MinValue = 0;
                        ToolTip = 'Specifies if you want the program to use the number of days, as specified in the field below, in the depreciation calculation.';

                        trigger OnValidate()
                        begin
                            if not UseForceNoOfDays and (DaysInPeriod <> 0) then
                              Error(Text006);
                        end;
                    }
                    field(PostingDate;PostingDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the posting date to be used by the batch job.';

                        trigger OnValidate()
                        begin
                            if not DeprUntilDateModified then
                              DeprUntilDate := PostingDate;
                        end;
                    }
                    field(DocumentNo;DocumentNo)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies, if you leave the field empty, the next available number on the resulting journal line. If a number series is not set up, enter the document number that you want assigned to the resulting journal line.';
                    }
                    field(PostingDescription;PostingDescription)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Posting Description';
                        ToolTip = 'Specifies the posting date to be used by the batch job as a filter.';
                    }
                    field(InsertBalAccount;BalAccount)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Insert Bal. Account';
                        Importance = Additional;
                        ToolTip = 'Specifies if you want the batch job to automatically insert fixed asset entries with balancing accounts.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            BalAccount := true;
            PostingDate := WorkDate;
            DeprUntilDate := WorkDate;
            if DeprBookCode = '' then begin
              FASetup.Get;
              DeprBookCode := FASetup."Default Depr. Book";
            end;
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        PageGenJnlLine: Record "Gen. Journal Line";
        PageFAJnlLine: Record "FA Journal Line";
    begin
        Window.Close;
        if (FAJnlLineCreatedCount = 0) and (GenJnlLineCreatedCount = 0) then begin
          Message(CompletionStatsMsg);
          exit;
        end;

        if FAJnlLineCreatedCount > 0 then
          if Confirm(CompletionStatsFAJnlQst,true,FAJnlLineCreatedCount)
          then begin
            PageFAJnlLine.SetRange("Journal Template Name",FAJnlLine."Journal Template Name");
            PageFAJnlLine.SetRange("Journal Batch Name",FAJnlLine."Journal Batch Name");
            PageFAJnlLine.FindFirst;
            PAGE.Run(PAGE::"Fixed Asset Journal",PageFAJnlLine);
          end;

        if GenJnlLineCreatedCount > 0 then
          if Confirm(CompletionStatsGenJnlQst,true,GenJnlLineCreatedCount)
          then begin
            PageGenJnlLine.SetRange("Journal Template Name",GenJnlLine."Journal Template Name");
            PageGenJnlLine.SetRange("Journal Batch Name",GenJnlLine."Journal Batch Name");
            PageGenJnlLine.FindFirst;
            PAGE.Run(PAGE::"Fixed Asset G/L Journal",PageGenJnlLine);
          end;
    end;

    trigger OnPreReport()
    begin
        DeprBook.Get(DeprBookCode);
        if DeprUntilDate = 0D then
          Error(Text000,FAJnlLine.FieldCaption("FA Posting Date"));
        if PostingDate = 0D then
          PostingDate := DeprUntilDate;
        if UseForceNoOfDays and (DaysInPeriod = 0) then
          Error(Text001);

        if DeprBook."Use Same FA+G/L Posting Dates" and (DeprUntilDate <> PostingDate) then
          Error(
            Text002,
            FAJnlLine.FieldCaption("FA Posting Date"),
            FAJnlLine.FieldCaption("Posting Date"),
            DeprBook.FieldCaption("Use Same FA+G/L Posting Dates"),
            false,
            DeprBook.TableCaption,
            DeprBook.FieldCaption(Code),
            DeprBook.Code);

        Window.Open(
          Text003 +
          Text004 +
          Text005);
    end;

    var
        Text000: Label 'You must specify %1.';
        Text001: Label 'Force No. of Days must be activated.';
        Text002: Label '%1 and %2 must be identical. %3 must be %4 in %5 %6 = %7.';
        Text003: Label 'Depreciating fixed asset      #1##########\';
        Text004: Label 'Not depreciating fixed asset  #2##########\';
        Text005: Label 'Inserting journal lines       #3##########';
        Text006: Label 'Use Force No. of Days must be activated.';
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLineTmp: Record "Gen. Journal Line" temporary;
        FASetup: Record "FA Setup";
        FAJnlLine: Record "FA Journal Line";
        FAJnlLineTmp: Record "FA Journal Line" temporary;
        DeprBook: Record "Depreciation Book";
        FAJnlSetup: Record "FA Journal Setup";
        CalculateDepr: Codeunit "Calculate Depreciation";
        FAInsertGLAcc: Codeunit "FA Insert G/L Account";
        Window: Dialog;
        DeprAmount: Decimal;
        Custom1Amount: Decimal;
        NumberOfDays: Integer;
        Custom1NumberOfDays: Integer;
        DeprUntilDate: Date;
        UseForceNoOfDays: Boolean;
        DaysInPeriod: Integer;
        PostingDate: Date;
        DocumentNo: Code[20];
        DocumentNo2: Code[20];
        NoSeries: Code[20];
        PostingDescription: Text[50];
        DeprBookCode: Code[10];
        BalAccount: Boolean;
        ErrorNo: Integer;
        Custom1ErrorNo: Integer;
        FAJnlNextLineNo: Integer;
        GenJnlNextLineNo: Integer;
        EntryAmounts: array [4] of Decimal;
        LineNo: Integer;
        CompletionStatsMsg: Label 'The depreciation has been calculated.\\No journal lines were created.';
        FAJnlLineCreatedCount: Integer;
        GenJnlLineCreatedCount: Integer;
        CompletionStatsFAJnlQst: Label 'The depreciation has been calculated.\\%1 fixed asset journal lines were created.\\Do you want to open the Fixed Asset Journal window?', Comment='The depreciation has been calculated.\\5 fixed asset journal lines were created.\\Do you want to open the Fixed Asset Journal window?';
        CompletionStatsGenJnlQst: Label 'The depreciation has been calculated.\\%1 fixed asset G/L journal lines were created.\\Do you want to open the Fixed Asset G/L Journal window?', Comment='The depreciation has been calculated.\\2 fixed asset G/L  journal lines were created.\\Do you want to open the Fixed Asset G/L Journal window?';
        DeprUntilDateModified: Boolean;

    procedure InitializeRequest(DeprBookCodeFrom: Code[10];DeprUntilDateFrom: Date;UseForceNoOfDaysFrom: Boolean;DaysInPeriodFrom: Integer;PostingDateFrom: Date;DocumentNoFrom: Code[20];PostingDescriptionFrom: Text[50];BalAccountFrom: Boolean)
    begin
        DeprBookCode := DeprBookCodeFrom;
        DeprUntilDate := DeprUntilDateFrom;
        UseForceNoOfDays := UseForceNoOfDaysFrom;
        DaysInPeriod := DaysInPeriodFrom;
        PostingDate := PostingDateFrom;
        DocumentNo := DocumentNoFrom;
        PostingDescription := PostingDescriptionFrom;
        BalAccount := BalAccountFrom;
    end;
}

