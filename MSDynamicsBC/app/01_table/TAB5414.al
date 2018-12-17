table 5414 "Prod. Order Comment Line"
{
    // version NAVW111.00

    Caption = 'Prod. Order Comment Line';
    DrillDownPageID = "Prod. Order Comment List";
    LookupPageID = "Prod. Order Comment List";

    fields
    {
        field(1;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Simulated,Planned,Firm Planned,Released,Finished';
            OptionMembers = Simulated,Planned,"Firm Planned",Released,Finished;
        }
        field(2;"Prod. Order No.";Code[20])
        {
            Caption = 'Prod. Order No.';
            NotBlank = true;
            TableRelation = "Production Order"."No." WHERE (Status=FIELD(Status));
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
        key(Key1;Status,"Prod. Order No.","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Status = Status::Finished then
          Error(Text000,Status,TableCaption);
    end;

    trigger OnInsert()
    begin
        if Status = Status::Finished then
          Error(Text000,Status,TableCaption);
    end;

    trigger OnModify()
    begin
        if Status = Status::Finished then
          Error(Text000,Status,TableCaption);
    end;

    var
        Text000: Label 'A %1 %2 cannot be inserted, modified, or deleted.';

    [Scope('Personalization')]
    procedure SetupNewLine()
    var
        ProdOrderCommentLine: Record "Prod. Order Comment Line";
    begin
        ProdOrderCommentLine.SetRange(Status,Status);
        ProdOrderCommentLine.SetRange("Prod. Order No.","Prod. Order No.");
        ProdOrderCommentLine.SetRange(Date,WorkDate);
        if not ProdOrderCommentLine.FindFirst then
          Date := WorkDate;
    end;
}

