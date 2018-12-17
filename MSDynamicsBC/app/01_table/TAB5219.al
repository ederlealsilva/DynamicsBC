table 5219 "HR Confidential Comment Line"
{
    // version NAVW111.00

    Caption = 'HR Confidential Comment Line';
    DataCaptionFields = "No.";
    DrillDownPageID = "HR Confidential Comment List";
    LookupPageID = "HR Confidential Comment List";

    fields
    {
        field(1;"Table Name";Option)
        {
            Caption = 'Table Name';
            OptionCaption = 'Confidential Information';
            OptionMembers = "Confidential Information";
        }
        field(2;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = Employee;
        }
        field(3;"Code";Code[10])
        {
            Caption = 'Code';
            TableRelation = Confidential.Code;
        }
        field(4;"Table Line No.";Integer)
        {
            Caption = 'Table Line No.';
        }
        field(6;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(7;Date;Date)
        {
            Caption = 'Date';
        }
        field(9;Comment;Text[80])
        {
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1;"Table Name","No.","Code","Table Line No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetUpNewLine()
    var
        HRConfCommentLine: Record "HR Confidential Comment Line";
    begin
        HRConfCommentLine := Rec;
        HRConfCommentLine.SetRecFilter;
        HRConfCommentLine.SetRange("Line No.");
        HRConfCommentLine.SetRange(Date,WorkDate);
        if not HRConfCommentLine.FindFirst then
          Date := WorkDate;
    end;
}

