table 1900 "Cancelled Document"
{
    // version NAVW111.00

    Caption = 'Cancelled Document';
    Permissions = TableData "Cancelled Document"=rimd;

    fields
    {
        field(1;"Source ID";Integer)
        {
            Caption = 'Source ID';
        }
        field(2;"Cancelled Doc. No.";Code[20])
        {
            Caption = 'Cancelled Doc. No.';
            TableRelation = IF ("Source ID"=CONST(112)) "Sales Invoice Header"."No."
                            ELSE IF ("Source ID"=CONST(122)) "Purch. Inv. Header"."No."
                            ELSE IF ("Source ID"=CONST(114)) "Sales Cr.Memo Header"."No."
                            ELSE IF ("Source ID"=CONST(124)) "Purch. Cr. Memo Hdr."."No.";
        }
        field(3;"Cancelled By Doc. No.";Code[20])
        {
            Caption = 'Cancelled By Doc. No.';
            TableRelation = IF ("Source ID"=CONST(114)) "Sales Invoice Header"."No."
                            ELSE IF ("Source ID"=CONST(124)) "Purch. Inv. Header"."No."
                            ELSE IF ("Source ID"=CONST(112)) "Sales Cr.Memo Header"."No."
                            ELSE IF ("Source ID"=CONST(122)) "Purch. Cr. Memo Hdr."."No.";
        }
    }

    keys
    {
        key(Key1;"Source ID","Cancelled Doc. No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure InsertSalesInvToCrMemoCancelledDocument(InvNo: Code[20];CrMemoNo: Code[20])
    begin
        InsertEntry(DATABASE::"Sales Invoice Header",InvNo,CrMemoNo);
    end;

    [Scope('Personalization')]
    procedure InsertSalesCrMemoToInvCancelledDocument(CrMemoNo: Code[20];InvNo: Code[20])
    begin
        InsertEntry(DATABASE::"Sales Cr.Memo Header",CrMemoNo,InvNo);
        RemoveSalesInvCancelledDocument;
    end;

    [Scope('Personalization')]
    procedure InsertPurchInvToCrMemoCancelledDocument(InvNo: Code[20];CrMemoNo: Code[20])
    begin
        InsertEntry(DATABASE::"Purch. Inv. Header",InvNo,CrMemoNo);
    end;

    [Scope('Personalization')]
    procedure InsertPurchCrMemoToInvCancelledDocument(CrMemoNo: Code[20];InvNo: Code[20])
    begin
        InsertEntry(DATABASE::"Purch. Cr. Memo Hdr.",CrMemoNo,InvNo);
        RemovePurchInvCancelledDocument;
    end;

    local procedure InsertEntry(SourceID: Integer;CanceledDocNo: Code[20];CanceledByDocNo: Code[20])
    begin
        Init;
        Validate("Source ID",SourceID);
        Validate("Cancelled Doc. No.",CanceledDocNo);
        Validate("Cancelled By Doc. No.",CanceledByDocNo);
        Insert(true);
    end;

    local procedure RemoveSalesInvCancelledDocument()
    begin
        FindSalesCorrectiveCrMemo("Cancelled Doc. No.");
        DeleteAll(true);
    end;

    local procedure RemovePurchInvCancelledDocument()
    begin
        FindPurchCorrectiveCrMemo("Cancelled Doc. No.");
        DeleteAll(true);
    end;

    [Scope('Personalization')]
    procedure FindSalesCancelledInvoice(CanceledDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledDocNo(DATABASE::"Sales Invoice Header",CanceledDocNo));
    end;

    [Scope('Personalization')]
    procedure FindSalesCorrectiveInvoice(CanceledByDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledByDocNo(DATABASE::"Sales Cr.Memo Header",CanceledByDocNo));
    end;

    [Scope('Personalization')]
    procedure FindPurchCancelledInvoice(CanceledDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledDocNo(DATABASE::"Purch. Inv. Header",CanceledDocNo));
    end;

    [Scope('Personalization')]
    procedure FindPurchCorrectiveInvoice(CanceledByDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledByDocNo(DATABASE::"Purch. Cr. Memo Hdr.",CanceledByDocNo));
    end;

    [Scope('Personalization')]
    procedure FindSalesCorrectiveCrMemo(CanceledByDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledByDocNo(DATABASE::"Sales Invoice Header",CanceledByDocNo));
    end;

    [Scope('Personalization')]
    procedure FindSalesCancelledCrMemo(CanceledDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledDocNo(DATABASE::"Sales Cr.Memo Header",CanceledDocNo));
    end;

    [Scope('Personalization')]
    procedure FindPurchCorrectiveCrMemo(CanceledByDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledByDocNo(DATABASE::"Purch. Inv. Header",CanceledByDocNo));
    end;

    [Scope('Personalization')]
    procedure FindPurchCancelledCrMemo(CanceledDocNo: Code[20]): Boolean
    begin
        exit(FindWithCancelledDocNo(DATABASE::"Purch. Cr. Memo Hdr.",CanceledDocNo));
    end;

    local procedure FindWithCancelledDocNo(SourceID: Integer;CanceledDocNo: Code[20]): Boolean
    begin
        exit(Get(SourceID,CanceledDocNo));
    end;

    local procedure FindWithCancelledByDocNo(SourceID: Integer;CanceledByDocNo: Code[20]): Boolean
    begin
        Reset;
        SetRange("Source ID",SourceID);
        SetRange("Cancelled By Doc. No.",CanceledByDocNo);
        exit(FindFirst);
    end;
}

