table 9501 "Email Attachment"
{
    // version NAVW113.00

    Caption = 'Email Attachment';
    ObsoleteReason = 'We are reverting the fix that was using this table as it was not possible to solve the problem this way.';
    ObsoleteState = Pending;

    fields
    {
        field(1;"Email Item ID";Guid)
        {
            Caption = 'Email Item ID';
            TableRelation = "Email Item".ID;
        }
        field(2;Number;Integer)
        {
            Caption = 'Number';
        }
        field(10;"File Path";Text[250])
        {
            Caption = 'File Path';
        }
        field(11;Name;Text[50])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1;"Email Item ID",Number)
        {
        }
    }

    fieldgroups
    {
    }

    procedure InsertAttachment(EmailItemId: Guid;NewNumber: Integer;FilePath: Text[250];NewName: Text[50])
    var
        EmailAttachment: Record "Email Attachment";
    begin
        Clear(EmailAttachment);
        EmailAttachment.Validate("Email Item ID",EmailItemId);
        if Number = 0 then
          Number := GetNextNumberForEmailItemId(EmailItemId);
        EmailAttachment.Validate(Number,NewNumber);
        EmailAttachment.Validate("File Path",FilePath);
        EmailAttachment.Validate(Name,NewName);
        EmailAttachment.Insert(true);
    end;

    local procedure GetNextNumberForEmailItemId(EmailItemId: Guid): Integer
    var
        EmailAttachment: Record "Email Attachment";
    begin
        EmailAttachment.SetRange("Email Item ID",EmailItemId);
        if EmailAttachment.FindLast then
          exit(EmailAttachment.Number + 10000);
        exit(10000);
    end;
}

