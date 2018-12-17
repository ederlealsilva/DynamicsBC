table 953 "Time Sheet Comment Line"
{
    // version NAVW111.00

    Caption = 'Time Sheet Comment Line';

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(2;"Time Sheet Line No.";Integer)
        {
            Caption = 'Time Sheet Line No.';
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
    }

    keys
    {
        key(Key1;"No.","Time Sheet Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetUpNewLine()
    var
        TimeSheetCommentLine: Record "Time Sheet Comment Line";
    begin
        TimeSheetCommentLine.SetRange("No.","No.");
        TimeSheetCommentLine.SetRange("Time Sheet Line No.","Time Sheet Line No.");
        TimeSheetCommentLine.SetRange(Date,WorkDate);
        if TimeSheetCommentLine.IsEmpty then
          Date := WorkDate;
    end;
}

