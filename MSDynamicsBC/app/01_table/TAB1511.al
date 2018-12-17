table 1511 "Notification Entry"
{
    // version NAVW113.00

    Caption = 'Notification Entry';
    ReplicateData = false;

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'New Record,Approval,Overdue';
            OptionMembers = "New Record",Approval,Overdue;
        }
        field(4;"Recipient User ID";Code[50])
        {
            Caption = 'Recipient User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup"."User ID";
            ValidateTableRelation = false;
        }
        field(5;"Triggered By Record";RecordID)
        {
            Caption = 'Triggered By Record';
            DataClassification = SystemMetadata;
        }
        field(6;"Link Target Page";Integer)
        {
            Caption = 'Link Target Page';
            TableRelation = "Page Metadata".ID;
        }
        field(7;"Custom Link";Text[250])
        {
            Caption = 'Custom Link';
            ExtendedDatatype = URL;
        }
        field(8;"Error Message";Text[250])
        {
            Caption = 'Error Message';
            Editable = false;
        }
        field(9;"Created Date-Time";DateTime)
        {
            Caption = 'Created Date-Time';
            Editable = false;
        }
        field(10;"Created By";Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(15;"Error Message 2";Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(16;"Error Message 3";Text[250])
        {
            Caption = 'Error Message 3';
        }
        field(17;"Error Message 4";Text[250])
        {
            Caption = 'Error Message 4';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;"Created Date-Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Created Date-Time" := RoundDateTime(CurrentDateTime,60000);
        "Created By" := UserId;
    end;

    var
        DataTypeManagement: Codeunit "Data Type Management";

    [Scope('Personalization')]
    procedure CreateNew(NewType: Option "New Record",Approval,Overdue;NewUserID: Code[50];NewRecord: Variant;NewLinkTargetPage: Integer;NewCustomLink: Text[250])
    var
        NotificationSchedule: Record "Notification Schedule";
        NewRecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(NewRecord,NewRecRef) then
          exit;

        Clear(Rec);
        Type := NewType;
        "Recipient User ID" := NewUserID;
        "Triggered By Record" := NewRecRef.RecordId;
        "Link Target Page" := NewLinkTargetPage;
        "Custom Link" := NewCustomLink;
        Insert(true);

        NotificationSchedule.ScheduleNotification(Rec);
    end;

    [Scope('Personalization')]
    procedure GetErrorMessage(): Text
    var
        TextMgt: Codeunit TextManagement;
    begin
        exit(TextMgt.GetRecordErrorMessage("Error Message","Error Message 2","Error Message 3","Error Message 4"));
    end;

    [Scope('Personalization')]
    procedure SetErrorMessage(ErrorText: Text)
    var
        TextMgt: Codeunit TextManagement;
    begin
        TextMgt.SetRecordErrorMessage("Error Message","Error Message 2","Error Message 3","Error Message 4",ErrorText);
    end;
}

