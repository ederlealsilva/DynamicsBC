table 952 "Time Sheet Detail"
{
    // version NAVW113.00

    Caption = 'Time Sheet Detail';

    fields
    {
        field(1;"Time Sheet No.";Code[20])
        {
            Caption = 'Time Sheet No.';
            TableRelation = "Time Sheet Header";
        }
        field(2;"Time Sheet Line No.";Integer)
        {
            Caption = 'Time Sheet Line No.';
        }
        field(3;Date;Date)
        {
            Caption = 'Date';
        }
        field(4;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Resource,Job,Service,Absence,Assembly Order';
            OptionMembers = " ",Resource,Job,Service,Absence,"Assembly Order";
        }
        field(5;"Resource No.";Code[20])
        {
            Caption = 'Resource No.';
            TableRelation = Resource;
        }
        field(6;"Job No.";Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;
        }
        field(7;"Job Task No.";Code[20])
        {
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No." WHERE ("Job No."=FIELD("Job No."));
        }
        field(9;"Cause of Absence Code";Code[10])
        {
            Caption = 'Cause of Absence Code';
            TableRelation = "Cause of Absence";
        }
        field(13;"Service Order No.";Code[20])
        {
            Caption = 'Service Order No.';
            TableRelation = IF (Posted=CONST(false)) "Service Header"."No." WHERE ("Document Type"=CONST(Order));
        }
        field(14;"Service Order Line No.";Integer)
        {
            Caption = 'Service Order Line No.';
        }
        field(15;Quantity;Decimal)
        {
            Caption = 'Quantity';
            Editable = false;
        }
        field(16;"Posted Quantity";Decimal)
        {
            Caption = 'Posted Quantity';
        }
        field(18;"Assembly Order No.";Code[20])
        {
            Caption = 'Assembly Order No.';
            TableRelation = IF (Posted=CONST(false)) "Assembly Header"."No." WHERE ("Document Type"=CONST(Order));
        }
        field(19;"Assembly Order Line No.";Integer)
        {
            Caption = 'Assembly Order Line No.';
        }
        field(20;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Submitted,Rejected,Approved';
            OptionMembers = Open,Submitted,Rejected,Approved;
        }
        field(23;Posted;Boolean)
        {
            Caption = 'Posted';
        }
    }

    keys
    {
        key(Key1;"Time Sheet No.","Time Sheet Line No.",Date)
        {
        }
        key(Key2;Type,"Job No.","Job Task No.",Status,Posted)
        {
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TimeSheetMgt.CheckAccPeriod(Date);
    end;

    trigger OnModify()
    begin
        TimeSheetMgt.CheckAccPeriod(Date);
    end;

    var
        TimeSheetMgt: Codeunit "Time Sheet Management";

    [Scope('Personalization')]
    procedure CopyFromTimeSheetLine(TimeSheetLine: Record "Time Sheet Line")
    begin
        "Time Sheet No." := TimeSheetLine."Time Sheet No.";
        "Time Sheet Line No." := TimeSheetLine."Line No.";
        Type := TimeSheetLine.Type;
        "Job No." := TimeSheetLine."Job No.";
        "Job Task No." := TimeSheetLine."Job Task No.";
        "Cause of Absence Code" := TimeSheetLine."Cause of Absence Code";
        "Service Order No." := TimeSheetLine."Service Order No.";
        "Service Order Line No." := TimeSheetLine."Service Order Line No.";
        "Assembly Order No." := TimeSheetLine."Assembly Order No.";
        "Assembly Order Line No." := TimeSheetLine."Assembly Order Line No.";
        Status := TimeSheetLine.Status;

        OnAfterCopyFromTimeSheetLine(Rec,TimeSheetLine);
    end;

    [Scope('Personalization')]
    procedure GetMaxQtyToPost(): Decimal
    begin
        exit(Quantity - "Posted Quantity");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromTimeSheetLine(var TimeSheetDetail: Record "Time Sheet Detail";TimeSheetLine: Record "Time Sheet Line")
    begin
    end;
}

