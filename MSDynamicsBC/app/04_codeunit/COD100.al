codeunit 100 "Calc. G/L Acc. Where-Used"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        GLAccWhereUsed: Record "G/L Account Where-Used" temporary;
        NextEntryNo: Integer;
        Text000: Label 'The update has been interrupted to respect the warning.';
        "Key": array [8] of Text[50];
        Text002: Label 'You cannot delete a %1 that is used in one or more setup windows.\';
        Text003: Label 'Do you want to open the G/L Account No. Where-Used List Window?';

    [Scope('Personalization')]
    procedure ShowSetupForm(GLAccWhereUsed: Record "G/L Account Where-Used")
    var
        Currency: Record Currency;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        CustPostingGr: Record "Customer Posting Group";
        VendPostingGr: Record "Vendor Posting Group";
        JobPostingGr: Record "Job Posting Group";
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
        GenPostingSetup: Record "General Posting Setup";
        BankAccPostingGr: Record "Bank Account Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        FAPostingGr: Record "FA Posting Group";
        FAAlloc: Record "FA Allocation";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        ServiceContractAccGr: Record "Service Contract Account Group";
        ICPartner: Record "IC Partner";
        PaymentMethod: Record "Payment Method";
    begin
        with GLAccWhereUsed do
          case "Table ID" of
            DATABASE::Currency:
              begin
                Currency.Code := CopyStr("Key 1",1,MaxStrLen(Currency.Code));
                PAGE.Run(0,Currency);
              end;
            DATABASE::"Gen. Journal Template":
              begin
                GenJnlTemplate.Name := CopyStr("Key 1",1,MaxStrLen(GenJnlTemplate.Name));
                PAGE.Run(PAGE::"General Journal Templates",GenJnlTemplate);
              end;
            DATABASE::"Gen. Journal Batch":
              begin
                GenJnlBatch."Journal Template Name" := CopyStr("Key 1",1,MaxStrLen(GenJnlBatch."Journal Template Name"));
                GenJnlBatch.Name := CopyStr("Key 2",1,MaxStrLen(GenJnlBatch.Name));
                GenJnlBatch.SetRange("Journal Template Name",GenJnlBatch."Journal Template Name");
                PAGE.Run(0,GenJnlBatch);
              end;
            DATABASE::"Customer Posting Group":
              begin
                CustPostingGr.Code := CopyStr("Key 1",1,MaxStrLen(CustPostingGr.Code));
                PAGE.Run(0,CustPostingGr);
              end;
            DATABASE::"Vendor Posting Group":
              begin
                VendPostingGr.Code := CopyStr("Key 1",1,MaxStrLen(VendPostingGr.Code));
                PAGE.Run(0,VendPostingGr);
              end;
            DATABASE::"Job Posting Group":
              begin
                JobPostingGr.Code := CopyStr("Key 1",1,MaxStrLen(JobPostingGr.Code));
                PAGE.Run(0,JobPostingGr);
              end;
            DATABASE::"Gen. Jnl. Allocation":
              begin
                GenJnlAlloc."Journal Template Name" := CopyStr("Key 1",1,MaxStrLen(GenJnlAlloc."Journal Template Name"));
                GenJnlAlloc."Journal Batch Name" := CopyStr("Key 2",1,MaxStrLen(GenJnlAlloc."Journal Batch Name"));
                Evaluate(GenJnlAlloc."Journal Line No.","Key 3");
                Evaluate(GenJnlAlloc."Line No.","Key 4");
                GenJnlAlloc.SetRange("Journal Template Name",GenJnlAlloc."Journal Template Name");
                GenJnlAlloc.SetRange("Journal Batch Name",GenJnlAlloc."Journal Batch Name");
                GenJnlAlloc.SetRange("Journal Line No.",GenJnlAlloc."Journal Line No.");
                PAGE.Run(PAGE::Allocations,GenJnlAlloc);
              end;
            DATABASE::"General Posting Setup":
              begin
                GenPostingSetup."Gen. Bus. Posting Group" :=
                  CopyStr("Key 1",1,MaxStrLen(GenPostingSetup."Gen. Bus. Posting Group"));
                GenPostingSetup."Gen. Prod. Posting Group" :=
                  CopyStr("Key 2",1,MaxStrLen(GenPostingSetup."Gen. Prod. Posting Group"));
                PAGE.Run(0,GenPostingSetup);
              end;
            DATABASE::"Bank Account Posting Group":
              begin
                BankAccPostingGr.Code := CopyStr("Key 1",1,MaxStrLen(BankAccPostingGr.Code));
                PAGE.Run(0,BankAccPostingGr);
              end;
            DATABASE::"VAT Posting Setup":
              begin
                VATPostingSetup."VAT Bus. Posting Group" :=
                  CopyStr("Key 1",1,MaxStrLen(VATPostingSetup."VAT Bus. Posting Group"));
                VATPostingSetup."VAT Prod. Posting Group" :=
                  CopyStr("Key 2",1,MaxStrLen(VATPostingSetup."VAT Prod. Posting Group"));
                PAGE.Run(0,VATPostingSetup);
              end;
            DATABASE::"FA Posting Group":
              begin
                FAPostingGr.Code := CopyStr("Key 1",1,MaxStrLen(FAPostingGr.Code));
                PAGE.Run(PAGE::"FA Posting Group Card",FAPostingGr);
              end;
            DATABASE::"FA Allocation":
              begin
                FAAlloc.Code := CopyStr("Key 1",1,MaxStrLen(FAAlloc.Code));
                Evaluate(FAAlloc."Allocation Type","Key 2");
                Evaluate(FAAlloc."Line No.","Key 3");
                FAAlloc.SetRange(Code,FAAlloc.Code);
                FAAlloc.SetRange("Allocation Type",FAAlloc."Allocation Type");
                PAGE.Run(0,FAAlloc);
              end;
            DATABASE::"Inventory Posting Setup":
              begin
                InventoryPostingSetup."Location Code" := CopyStr("Key 1",1,MaxStrLen(InventoryPostingSetup."Location Code"));
                InventoryPostingSetup."Invt. Posting Group Code" :=
                  CopyStr("Key 2",1,MaxStrLen(InventoryPostingSetup."Invt. Posting Group Code"));
                PAGE.Run(PAGE::"Inventory Posting Setup",InventoryPostingSetup);
              end;
            DATABASE::"Service Contract Account Group":
              begin
                ServiceContractAccGr.Code := CopyStr("Key 1",1,MaxStrLen(ServiceContractAccGr.Code));
                PAGE.Run(0,ServiceContractAccGr);
              end;
            DATABASE::"IC Partner":
              begin
                ICPartner.Code := CopyStr("Key 1",1,MaxStrLen(ICPartner.Code));
                PAGE.Run(0,ICPartner);
              end;
            DATABASE::"Payment Method":
              begin
                PaymentMethod.Code := CopyStr("Key 1",1,MaxStrLen(PaymentMethod.Code));
                PAGE.Run(0,PaymentMethod);
              end;
            else
              OnShowExtensionPage(GLAccWhereUsed);
          end;
    end;

    [Scope('Personalization')]
    procedure DeleteGLNo(GLAccNo: Code[20]): Boolean
    var
        GLSetup: Record "General Ledger Setup";
        GLAcc: Record "G/L Account";
    begin
        GLSetup.Get;
        if GLSetup."Check G/L Account Usage" then begin
          CheckPostingGroups(GLAccNo);
          if GLAccWhereUsed.FindFirst then begin
            Commit;
            if Confirm(Text002 + Text003,true,GLAcc.TableCaption) then
              ShowGLAccWhereUsed;
            Error(Text000);
          end;
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure CheckGLAcc(GLAccNo: Code[20])
    begin
        CheckPostingGroups(GLAccNo);
        ShowGLAccWhereUsed;
    end;

    local procedure ShowGLAccWhereUsed()
    begin
        OnBeforeShowGLAccWhereUsed(GLAccWhereUsed);

        GLAccWhereUsed.SetCurrentKey("Table Name");
        PAGE.RunModal(0,GLAccWhereUsed);
    end;

    procedure InsertGroupForRecord(var TempGLAccountWhereUsed: Record "G/L Account Where-Used" temporary;TableID: Integer;TableCaption: Text[80];GLAccNo: Code[20];GLAccNo2: Code[20];FieldCaption: Text[80];"Key": array [8] of Text[80])
    begin
        TempGLAccountWhereUsed."Table ID" := TableID;
        TempGLAccountWhereUsed."Table Name" := TableCaption;
        GLAccWhereUsed.Copy(TempGLAccountWhereUsed,true);
        InsertGroup(GLAccNo,GLAccNo2,FieldCaption,Key);
    end;

    local procedure InsertGroup(GLAccNo: Code[20];GLAccNo2: Code[20];FieldCaption: Text[80];"Key": array [8] of Text[80])
    begin
        if GLAccNo = GLAccNo2 then begin
          if NextEntryNo = 0 then
            NextEntryNo := GetWhereUsedNextEntryNo;

          GLAccWhereUsed."Field Name" := FieldCaption;
          if Key[1] <> '' then
            GLAccWhereUsed.Line := Key[1] + '=' + Key[4]
          else
            GLAccWhereUsed.Line := '';
          if Key[2] <> '' then
            GLAccWhereUsed.Line := GLAccWhereUsed.Line + ', ' + Key[2] + '=' + Key[5];
          if Key[3] <> '' then
            GLAccWhereUsed.Line := GLAccWhereUsed.Line + ', ' + Key[3] + '=' + Key[6];
          if Key[7] <> '' then
            GLAccWhereUsed.Line := GLAccWhereUsed.Line + ', ' + Key[7] + '=' + Key[8];
          GLAccWhereUsed."Entry No." := NextEntryNo;
          GLAccWhereUsed."Key 1" := CopyStr(Key[4],1,MaxStrLen(GLAccWhereUsed."Key 1"));
          GLAccWhereUsed."Key 2" := CopyStr(Key[5],1,MaxStrLen(GLAccWhereUsed."Key 2"));
          GLAccWhereUsed."Key 3" := CopyStr(Key[6],1,MaxStrLen(GLAccWhereUsed."Key 3"));
          GLAccWhereUsed."Key 4" := CopyStr(Key[8],1,MaxStrLen(GLAccWhereUsed."Key 4"));
          NextEntryNo := NextEntryNo + 1;
          GLAccWhereUsed.Insert;
        end;
    end;

    local procedure CheckPostingGroups(GLAccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        NextEntryNo := 0;
        Clear(GLAccWhereUsed);
        GLAccWhereUsed.DeleteAll;
        GLAcc.Get(GLAccNo);
        GLAccWhereUsed."G/L Account No." := GLAccNo;
        GLAccWhereUsed."G/L Account Name" := GLAcc.Name;
        CheckCurrency(GLAccNo);
        CheckGenJnlTemplate(GLAccNo);
        CheckGenJnlBatch(GLAccNo);
        CheckCustPostingGr(GLAccNo);
        CheckVendPostingGr(GLAccNo);
        CheckJobPostingGr(GLAccNo);
        CheckGenJnlAlloc(GLAccNo);
        CheckGenPostingSetup(GLAccNo);
        CheckBankAccPostingGr(GLAccNo);
        CheckVATPostingSetup(GLAccNo);
        CheckFAPostingGr(GLAccNo);
        CheckFAAllocation(GLAccNo);
        CheckInventoryPostingSetup(GLAccNo);
        CheckServiceContractAccGr(GLAccNo);
        CheckICPartner(GLAccNo);
        CheckPaymentMethod(GLAccNo);
        CheckSalesReceivablesSetup(GLAccNo);
        CheckEmployeePostingGroup(GLAccNo);

        OnAfterCheckPostingGroups(GLAccWhereUsed,GLAccNo);
    end;

    local procedure CheckCurrency(GLAccNo: Code[20])
    var
        Currency: Record Currency;
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::Currency;
        GLAccWhereUsed."Table Name" := Currency.TableCaption;
        with Currency do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Unrealized Gains Acc.",FieldCaption("Unrealized Gains Acc."),Key);
              InsertGroup(GLAccNo,"Realized Gains Acc.",FieldCaption("Realized Gains Acc."),Key);
              InsertGroup(GLAccNo,"Unrealized Losses Acc.",FieldCaption("Unrealized Losses Acc."),Key);
              InsertGroup(GLAccNo,"Realized Losses Acc.",FieldCaption("Realized Losses Acc."),Key);
              InsertGroup(GLAccNo,"Realized G/L Losses Account",FieldCaption("Realized G/L Losses Account"),Key);
              InsertGroup(GLAccNo,"Realized G/L Gains Account",FieldCaption("Realized G/L Gains Account"),Key);
              InsertGroup(GLAccNo,"Residual Gains Account",FieldCaption("Residual Gains Account"),Key);
              InsertGroup(GLAccNo,"Residual Losses Account",FieldCaption("Residual Losses Account"),Key);
              InsertGroup(GLAccNo,"Conv. LCY Rndg. Debit Acc.",FieldCaption("Conv. LCY Rndg. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Conv. LCY Rndg. Credit Acc.",FieldCaption("Conv. LCY Rndg. Credit Acc."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckGenJnlTemplate(GLAccNo: Code[20])
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Gen. Journal Template";
        GLAccWhereUsed."Table Name" := GenJnlTemplate.TableCaption;
        with GenJnlTemplate do begin
          Key[1] := FieldCaption(Name);
          if Find('-') then
            repeat
              Key[4] := Name;
              if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then
                InsertGroup(GLAccNo,"Bal. Account No.",FieldCaption("Bal. Account No."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckGenJnlBatch(GLAccNo: Code[20])
    var
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Gen. Journal Batch";
        GLAccWhereUsed."Table Name" := GenJnlBatch.TableCaption;
        with GenJnlBatch do begin
          Key[1] := FieldCaption("Journal Template Name");
          Key[2] := FieldCaption(Name);
          if Find('-') then
            repeat
              Key[4] := "Journal Template Name";
              Key[5] := Name;
              if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then
                InsertGroup(GLAccNo,"Bal. Account No.",FieldCaption("Bal. Account No."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckCustPostingGr(GLAccNo: Code[20])
    var
        CustPostingGr: Record "Customer Posting Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Customer Posting Group";
        GLAccWhereUsed."Table Name" := CustPostingGr.TableCaption;
        with CustPostingGr do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Receivables Account",FieldCaption("Receivables Account"),Key);
              InsertGroup(GLAccNo,"Service Charge Acc.",FieldCaption("Service Charge Acc."),Key);
              InsertGroup(GLAccNo,"Payment Disc. Debit Acc.",FieldCaption("Payment Disc. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Invoice Rounding Account",FieldCaption("Invoice Rounding Account"),Key);
              InsertGroup(GLAccNo,"Additional Fee Account",FieldCaption("Additional Fee Account"),Key);
              InsertGroup(GLAccNo,"Interest Account",FieldCaption("Interest Account"),Key);
              InsertGroup(GLAccNo,"Debit Curr. Appln. Rndg. Acc.",FieldCaption("Debit Curr. Appln. Rndg. Acc."),Key);
              InsertGroup(GLAccNo,"Credit Curr. Appln. Rndg. Acc.",FieldCaption("Credit Curr. Appln. Rndg. Acc."),Key);
              InsertGroup(GLAccNo,"Debit Rounding Account",FieldCaption("Debit Rounding Account"),Key);
              InsertGroup(GLAccNo,"Credit Rounding Account",FieldCaption("Credit Rounding Account"),Key);
              InsertGroup(GLAccNo,"Payment Disc. Credit Acc.",FieldCaption("Payment Disc. Credit Acc."),Key);
              InsertGroup(GLAccNo,"Payment Tolerance Debit Acc.",FieldCaption("Payment Tolerance Debit Acc."),Key);
              InsertGroup(GLAccNo,"Payment Tolerance Credit Acc.",FieldCaption("Payment Tolerance Credit Acc."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckVendPostingGr(GLAccNo: Code[20])
    var
        VendPostingGr: Record "Vendor Posting Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Vendor Posting Group";
        GLAccWhereUsed."Table Name" := VendPostingGr.TableCaption;
        with VendPostingGr do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Payables Account",FieldCaption("Payables Account"),Key);
              InsertGroup(GLAccNo,"Service Charge Acc.",FieldCaption("Service Charge Acc."),Key);
              InsertGroup(GLAccNo,"Payment Disc. Debit Acc.",FieldCaption("Payment Disc. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Invoice Rounding Account",FieldCaption("Invoice Rounding Account"),Key);
              InsertGroup(GLAccNo,"Debit Curr. Appln. Rndg. Acc.",FieldCaption("Debit Curr. Appln. Rndg. Acc."),Key);
              InsertGroup(GLAccNo,"Credit Curr. Appln. Rndg. Acc.",FieldCaption("Credit Curr. Appln. Rndg. Acc."),Key);
              InsertGroup(GLAccNo,"Debit Rounding Account",FieldCaption("Debit Rounding Account"),Key);
              InsertGroup(GLAccNo,"Credit Rounding Account",FieldCaption("Credit Rounding Account"),Key);
              InsertGroup(GLAccNo,"Payment Disc. Credit Acc.",FieldCaption("Payment Disc. Credit Acc."),Key);
              InsertGroup(GLAccNo,"Payment Tolerance Debit Acc.",FieldCaption("Payment Tolerance Debit Acc."),Key);
              InsertGroup(GLAccNo,"Payment Tolerance Credit Acc.",FieldCaption("Payment Tolerance Credit Acc."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckJobPostingGr(GLAccNo: Code[20])
    var
        JobPostingGr: Record "Job Posting Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Job Posting Group";
        GLAccWhereUsed."Table Name" := JobPostingGr.TableCaption;
        with JobPostingGr do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"WIP Costs Account",FieldCaption("WIP Costs Account"),Key);
              InsertGroup(GLAccNo,"WIP Accrued Costs Account",FieldCaption("WIP Accrued Costs Account"),Key);
              InsertGroup(GLAccNo,"Job Costs Applied Account",FieldCaption("Job Costs Applied Account"),Key);
              InsertGroup(GLAccNo,"Job Costs Adjustment Account",FieldCaption("Job Costs Adjustment Account"),Key);
              InsertGroup(GLAccNo,"G/L Expense Acc. (Contract)",FieldCaption("G/L Expense Acc. (Contract)"),Key);
              InsertGroup(GLAccNo,"Job Sales Adjustment Account",FieldCaption("Job Sales Adjustment Account"),Key);
              InsertGroup(GLAccNo,"WIP Accrued Sales Account",FieldCaption("WIP Accrued Sales Account"),Key);
              InsertGroup(GLAccNo,"WIP Invoiced Sales Account",FieldCaption("WIP Invoiced Sales Account"),Key);
              InsertGroup(GLAccNo,"Job Sales Applied Account",FieldCaption("Job Sales Applied Account"),Key);
              InsertGroup(GLAccNo,"Recognized Costs Account",FieldCaption("Recognized Costs Account"),Key);
              InsertGroup(GLAccNo,"Recognized Sales Account",FieldCaption("Recognized Sales Account"),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckGenJnlAlloc(GLAccNo: Code[20])
    var
        GenJnlAlloc: Record "Gen. Jnl. Allocation";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Gen. Jnl. Allocation";
        GLAccWhereUsed."Table Name" := GenJnlAlloc.TableCaption;
        with GenJnlAlloc do begin
          Key[1] := FieldCaption("Journal Template Name");
          Key[2] := FieldCaption("Journal Batch Name");
          Key[3] := FieldCaption("Journal Line No.");
          Key[7] := FieldCaption("Line No.");
          if Find('-') then
            repeat
              Key[4] := "Journal Template Name";
              Key[5] := "Journal Batch Name";
              Key[6] := Format("Journal Line No.");
              Key[8] := Format("Line No.");
              InsertGroup(GLAccNo,"Account No.",FieldCaption("Account No."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckGenPostingSetup(GLAccNo: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"General Posting Setup";
        GLAccWhereUsed."Table Name" := GenPostingSetup.TableCaption;
        with GenPostingSetup do begin
          Key[1] := FieldCaption("Gen. Bus. Posting Group");
          Key[2] := FieldCaption("Gen. Prod. Posting Group");
          if Find('-') then
            repeat
              Key[4] := "Gen. Bus. Posting Group";
              Key[5] := "Gen. Prod. Posting Group";
              InsertGroup(GLAccNo,"Sales Account",FieldCaption("Sales Account"),Key);
              InsertGroup(GLAccNo,"Sales Line Disc. Account",FieldCaption("Sales Line Disc. Account"),Key);
              InsertGroup(GLAccNo,"Sales Inv. Disc. Account",FieldCaption("Sales Inv. Disc. Account"),Key);
              InsertGroup(GLAccNo,"Sales Pmt. Disc. Debit Acc.",FieldCaption("Sales Pmt. Disc. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Purch. Account",FieldCaption("Purch. Account"),Key);
              InsertGroup(GLAccNo,"Purch. Line Disc. Account",FieldCaption("Purch. Line Disc. Account"),Key);
              InsertGroup(GLAccNo,"Purch. Inv. Disc. Account",FieldCaption("Purch. Inv. Disc. Account"),Key);
              InsertGroup(GLAccNo,"Purch. Pmt. Disc. Credit Acc.",FieldCaption("Purch. Pmt. Disc. Credit Acc."),Key);
              InsertGroup(GLAccNo,"COGS Account",FieldCaption("COGS Account"),Key);
              InsertGroup(GLAccNo,"Inventory Adjmt. Account",FieldCaption("Inventory Adjmt. Account"),Key);
              InsertGroup(GLAccNo,"Sales Credit Memo Account",FieldCaption("Sales Credit Memo Account"),Key);
              InsertGroup(GLAccNo,"Purch. Credit Memo Account",FieldCaption("Purch. Credit Memo Account"),Key);
              InsertGroup(GLAccNo,"Sales Pmt. Disc. Credit Acc.",FieldCaption("Sales Pmt. Disc. Credit Acc."),Key);
              InsertGroup(GLAccNo,"Purch. Pmt. Disc. Debit Acc.",FieldCaption("Purch. Pmt. Disc. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Sales Pmt. Tol. Debit Acc.",FieldCaption("Sales Pmt. Tol. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Sales Pmt. Tol. Credit Acc.",FieldCaption("Sales Pmt. Tol. Credit Acc."),Key);
              InsertGroup(GLAccNo,"Purch. Pmt. Tol. Debit Acc.",FieldCaption("Purch. Pmt. Tol. Debit Acc."),Key);
              InsertGroup(GLAccNo,"Purch. Pmt. Tol. Credit Acc.",FieldCaption("Purch. Pmt. Tol. Credit Acc."),Key);
              InsertGroup(GLAccNo,"Purch. FA Disc. Account",FieldCaption("Purch. FA Disc. Account"),Key);
              InsertGroup(GLAccNo,"Invt. Accrual Acc. (Interim)",FieldCaption("Invt. Accrual Acc. (Interim)"),Key);
              InsertGroup(GLAccNo,"COGS Account (Interim)",FieldCaption("COGS Account (Interim)"),Key);
              InsertGroup(GLAccNo,"Direct Cost Applied Account",FieldCaption("Direct Cost Applied Account"),Key);
              InsertGroup(GLAccNo,"Overhead Applied Account",FieldCaption("Overhead Applied Account"),Key);
              InsertGroup(GLAccNo,"Purchase Variance Account",FieldCaption("Purchase Variance Account"),Key);
              InsertGroup(GLAccNo,"Sales Prepayments Account",FieldCaption("Sales Prepayments Account"),Key);
              InsertGroup(GLAccNo,"Purch. Prepayments Account",FieldCaption("Purch. Prepayments Account"),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckBankAccPostingGr(GLAccNo: Code[20])
    var
        BankAccPostingGr: Record "Bank Account Posting Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Bank Account Posting Group";
        GLAccWhereUsed."Table Name" := BankAccPostingGr.TableCaption;
        with BankAccPostingGr do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"G/L Bank Account No.",FieldCaption("G/L Bank Account No."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckVATPostingSetup(GLAccNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"VAT Posting Setup";
        GLAccWhereUsed."Table Name" := VATPostingSetup.TableCaption;
        with VATPostingSetup do begin
          Key[1] := FieldCaption("VAT Bus. Posting Group");
          Key[2] := FieldCaption("VAT Prod. Posting Group");
          if Find('-') then
            repeat
              Key[4] := "VAT Bus. Posting Group";
              Key[5] := "VAT Prod. Posting Group";
              InsertGroup(GLAccNo,"Sales VAT Account",FieldCaption("Sales VAT Account"),Key);
              InsertGroup(GLAccNo,"Sales VAT Unreal. Account",FieldCaption("Sales VAT Unreal. Account"),Key);
              InsertGroup(GLAccNo,"Purchase VAT Account",FieldCaption("Purchase VAT Account"),Key);
              InsertGroup(GLAccNo,"Purch. VAT Unreal. Account",FieldCaption("Purch. VAT Unreal. Account"),Key);
              InsertGroup(GLAccNo,"Reverse Chrg. VAT Acc.",FieldCaption("Reverse Chrg. VAT Acc."),Key);
              InsertGroup(GLAccNo,"Reverse Chrg. VAT Unreal. Acc.",FieldCaption("Reverse Chrg. VAT Unreal. Acc."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckFAPostingGr(GLAccNo: Code[20])
    var
        FAPostingGr: Record "FA Posting Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"FA Posting Group";
        GLAccWhereUsed."Table Name" := FAPostingGr.TableCaption;
        with FAPostingGr do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Acquisition Cost Account",FieldCaption("Acquisition Cost Account"),Key);
              InsertGroup(GLAccNo,"Accum. Depreciation Account",FieldCaption("Accum. Depreciation Account"),Key);
              InsertGroup(GLAccNo,"Write-Down Account",FieldCaption("Write-Down Account"),Key);
              InsertGroup(GLAccNo,"Appreciation Account",FieldCaption("Appreciation Account"),Key);
              InsertGroup(GLAccNo,"Custom 1 Account",FieldCaption("Custom 1 Account"),Key);
              InsertGroup(GLAccNo,"Custom 2 Account",FieldCaption("Custom 2 Account"),Key);
              InsertGroup(GLAccNo,"Acq. Cost Acc. on Disposal",FieldCaption("Acq. Cost Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Accum. Depr. Acc. on Disposal",FieldCaption("Accum. Depr. Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Write-Down Acc. on Disposal",FieldCaption("Write-Down Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Appreciation Acc. on Disposal",FieldCaption("Appreciation Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Custom 1 Account on Disposal",FieldCaption("Custom 1 Account on Disposal"),Key);
              InsertGroup(GLAccNo,"Custom 2 Account on Disposal",FieldCaption("Custom 2 Account on Disposal"),Key);
              InsertGroup(GLAccNo,"Gains Acc. on Disposal",FieldCaption("Gains Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Losses Acc. on Disposal",FieldCaption("Losses Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Book Val. Acc. on Disp. (Gain)",FieldCaption("Book Val. Acc. on Disp. (Gain)"),Key);
              InsertGroup(GLAccNo,"Sales Acc. on Disp. (Gain)",FieldCaption("Sales Acc. on Disp. (Gain)"),Key);
              InsertGroup(GLAccNo,"Write-Down Bal. Acc. on Disp.",FieldCaption("Write-Down Bal. Acc. on Disp."),Key);
              InsertGroup(GLAccNo,"Apprec. Bal. Acc. on Disp.",FieldCaption("Apprec. Bal. Acc. on Disp."),Key);
              InsertGroup(GLAccNo,"Custom 1 Bal. Acc. on Disposal",FieldCaption("Custom 1 Bal. Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Custom 2 Bal. Acc. on Disposal",FieldCaption("Custom 2 Bal. Acc. on Disposal"),Key);
              InsertGroup(GLAccNo,"Maintenance Expense Account",FieldCaption("Maintenance Expense Account"),Key);
              InsertGroup(GLAccNo,"Maintenance Bal. Acc.",FieldCaption("Maintenance Bal. Acc."),Key);
              InsertGroup(GLAccNo,"Acquisition Cost Bal. Acc.",FieldCaption("Acquisition Cost Bal. Acc."),Key);
              InsertGroup(GLAccNo,"Depreciation Expense Acc.",FieldCaption("Depreciation Expense Acc."),Key);
              InsertGroup(GLAccNo,"Write-Down Expense Acc.",FieldCaption("Write-Down Expense Acc."),Key);
              InsertGroup(GLAccNo,"Appreciation Bal. Account",FieldCaption("Appreciation Bal. Account"),Key);
              InsertGroup(GLAccNo,"Custom 1 Expense Acc.",FieldCaption("Custom 1 Expense Acc."),Key);
              InsertGroup(GLAccNo,"Custom 2 Expense Acc.",FieldCaption("Custom 2 Expense Acc."),Key);
              InsertGroup(GLAccNo,"Sales Bal. Acc.",FieldCaption("Sales Bal. Acc."),Key);
              InsertGroup(GLAccNo,"Sales Acc. on Disp. (Loss)",FieldCaption("Sales Acc. on Disp. (Loss)"),Key);
              InsertGroup(GLAccNo,"Book Val. Acc. on Disp. (Loss)",FieldCaption("Book Val. Acc. on Disp. (Loss)"),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckFAAllocation(GLAccNo: Code[20])
    var
        FAAlloc: Record "FA Allocation";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"FA Allocation";
        GLAccWhereUsed."Table Name" := FAAlloc.TableCaption;
        with FAAlloc do begin
          Key[1] := FieldCaption(Code);
          Key[2] := FieldCaption("Allocation Type");
          Key[3] := FieldCaption("Line No.");
          if Find('-') then
            repeat
              Key[4] := Code;
              Key[5] := Format("Allocation Type");
              Key[6] := Format("Line No.");
              InsertGroup(GLAccNo,"Account No.",FieldCaption("Account No."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckInventoryPostingSetup(GLAccNo: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Inventory Posting Setup";
        GLAccWhereUsed."Table Name" := InventoryPostingSetup.TableCaption;
        with InventoryPostingSetup do begin
          Key[1] := FieldCaption("Location Code");
          Key[2] := FieldCaption("Invt. Posting Group Code");
          if Find('-') then
            repeat
              Key[4] := "Location Code";
              Key[5] := "Invt. Posting Group Code";
              InsertGroup(GLAccNo,"Inventory Account",FieldCaption("Inventory Account"),Key);
              InsertGroup(GLAccNo,"Inventory Account (Interim)",FieldCaption("Inventory Account (Interim)"),Key);
              InsertGroup(GLAccNo,"WIP Account",FieldCaption("WIP Account"),Key);
              InsertGroup(GLAccNo,"Material Variance Account",FieldCaption("Material Variance Account"),Key);
              InsertGroup(GLAccNo,"Capacity Variance Account",FieldCaption("Capacity Variance Account"),Key);
              InsertGroup(
                GLAccNo,"Mfg. Overhead Variance Account",FieldCaption("Mfg. Overhead Variance Account"),Key);
              InsertGroup(
                GLAccNo,"Cap. Overhead Variance Account",FieldCaption("Cap. Overhead Variance Account"),Key);
              InsertGroup(
                GLAccNo,"Subcontracted Variance Account",FieldCaption("Subcontracted Variance Account"),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckServiceContractAccGr(GLAccNo: Code[20])
    var
        ServiceContractAccGr: Record "Service Contract Account Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Service Contract Account Group";
        GLAccWhereUsed."Table Name" := ServiceContractAccGr.TableCaption;
        with ServiceContractAccGr do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Non-Prepaid Contract Acc.",FieldCaption("Non-Prepaid Contract Acc."),Key);
              InsertGroup(GLAccNo,"Prepaid Contract Acc.",FieldCaption("Prepaid Contract Acc."),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckICPartner(GLAccNo: Code[20])
    var
        ICPartner: Record "IC Partner";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"IC Partner";
        GLAccWhereUsed."Table Name" := ICPartner.TableCaption;
        with ICPartner do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Receivables Account",FieldCaption("Receivables Account"),Key);
              InsertGroup(GLAccNo,"Payables Account",FieldCaption("Payables Account"),Key);
            until Next = 0;
        end;
    end;

    local procedure CheckPaymentMethod(GLAccNo: Code[20])
    var
        PaymentMethod: Record "Payment Method";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Payment Method";
        GLAccWhereUsed."Table Name" := PaymentMethod.TableCaption;
        with PaymentMethod do begin
          Key[1] := FieldCaption(Code);
          if Find('-') then
            repeat
              if "Bal. Account Type" = "Bal. Account Type"::"G/L Account" then begin
                Key[4] := Code;
                InsertGroup(GLAccNo,"Bal. Account No.",FieldCaption("Bal. Account No."),Key);
              end
            until Next = 0;
        end;
    end;

    local procedure CheckSalesReceivablesSetup(GLAccNo: Code[20])
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Sales & Receivables Setup";
        GLAccWhereUsed."Table Name" := SalesReceivablesSetup.TableCaption;
        with SalesReceivablesSetup do begin
          Key[1] := FieldCaption("Primary Key");
          Get;
          InsertGroup(GLAccNo,"Freight G/L Acc. No.",FieldCaption("Freight G/L Acc. No."),Key);
        end;
    end;

    local procedure CheckEmployeePostingGroup(GLAccNo: Code[20])
    var
        EmployeePostingGroup: Record "Employee Posting Group";
    begin
        Clear(Key);
        GLAccWhereUsed."Table ID" := DATABASE::"Sales & Receivables Setup";
        GLAccWhereUsed."Table Name" := EmployeePostingGroup.TableCaption;
        with EmployeePostingGroup do begin
          Key[1] := FieldCaption(Code);
          if FindSet then
            repeat
              Key[4] := Code;
              InsertGroup(GLAccNo,"Payables Account",FieldCaption("Payables Account"),Key);
            until Next = 0;
        end;
    end;

    local procedure GetWhereUsedNextEntryNo(): Integer
    var
        TempGLAccountWhereUsed: Record "G/L Account Where-Used" temporary;
    begin
        TempGLAccountWhereUsed.Copy(GLAccWhereUsed,true);
        if TempGLAccountWhereUsed.FindLast then
          exit(TempGLAccountWhereUsed."Entry No." + 1);
        exit(1);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckPostingGroups(var TempGLAccountWhereUsed: Record "G/L Account Where-Used" temporary;GLAccNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowGLAccWhereUsed(var GLAccountWhereUsed: Record "G/L Account Where-Used")
    begin
    end;
}

