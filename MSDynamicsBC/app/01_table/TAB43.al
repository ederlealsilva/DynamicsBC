table 43 "Purch. Comment Line"
{
    // version NAVW111.00

    Caption = 'Purch. Comment Line';
    DrillDownPageID = "Purch. Comment List";
    LookupPageID = "Purch. Comment List";

    fields
    {
        field(1;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Receipt,Posted Invoice,Posted Credit Memo,Posted Return Shipment';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Receipt,"Posted Invoice","Posted Credit Memo","Posted Return Shipment";
        }
        field(2;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(3;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(4;Date;Date)
        {
            Caption = 'Date';
        }
        field(5;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(6;Comment;Text[80])
        {
            Caption = 'Comment';
        }
        field(7;"Document Line No.";Integer)
        {
            Caption = 'Document Line No.';
        }
    }

    keys
    {
        key(Key1;"Document Type","No.","Document Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetUpNewLine()
    var
        PurchCommentLine: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type","Document Type");
        PurchCommentLine.SetRange("No.","No.");
        PurchCommentLine.SetRange("Document Line No.","Document Line No.");
        PurchCommentLine.SetRange(Date,WorkDate);
        if not PurchCommentLine.FindFirst then
          Date := WorkDate;
    end;

    [Scope('Personalization')]
    procedure CopyComments(FromDocumentType: Integer;ToDocumentType: Integer;FromNumber: Code[20];ToNumber: Code[20])
    var
        PurchCommentLine: Record "Purch. Comment Line";
        PurchCommentLine2: Record "Purch. Comment Line";
    begin
        PurchCommentLine.SetRange("Document Type",FromDocumentType);
        PurchCommentLine.SetRange("No.",FromNumber);
        if PurchCommentLine.FindSet then
          repeat
            PurchCommentLine2 := PurchCommentLine;
            PurchCommentLine2."Document Type" := ToDocumentType;
            PurchCommentLine2."No." := ToNumber;
            PurchCommentLine2.Insert;
          until PurchCommentLine.Next = 0;
    end;

    [Scope('Personalization')]
    procedure DeleteComments(DocType: Option;DocNo: Code[20])
    begin
        SetRange("Document Type",DocType);
        SetRange("No.",DocNo);
        if not IsEmpty then
          DeleteAll;
    end;

    procedure ShowComments(DocType: Option;DocNo: Code[20];DocLineNo: Integer)
    var
        PurchCommentSheet: Page "Purch. Comment Sheet";
    begin
        SetRange("Document Type",DocType);
        SetRange("No.",DocNo);
        SetRange("Document Line No.",DocLineNo);
        Clear(PurchCommentSheet);
        PurchCommentSheet.SetTableView(Rec);
        PurchCommentSheet.RunModal;
    end;
}

