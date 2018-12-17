table 5123 "Inter. Log Entry Comment Line"
{
    // version NAVW113.00

    Caption = 'Inter. Log Entry Comment Line';
    DrillDownPageID = "Inter. Log Entry Comment List";
    LookupPageID = "Inter. Log Entry Comment List";
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            TableRelation = "Interaction Log Entry"."Entry No.";
        }
        field(4;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Date;Date)
        {
            Caption = 'Date';
        }
        field(6;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(7;Comment;Text[80])
        {
            Caption = 'Comment';
        }
        field(8;"Last Date Modified";Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Entry No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        "Last Date Modified" := Today;
    end;

    [Scope('Personalization')]
    procedure SetUpNewLine()
    var
        InteractionCommentLine: Record "Inter. Log Entry Comment Line";
    begin
        InteractionCommentLine.SetRange("Entry No.","Entry No.");
        InteractionCommentLine.SetRange(Date,WorkDate);
        if not InteractionCommentLine.FindFirst then
          Date := WorkDate;
    end;
}

