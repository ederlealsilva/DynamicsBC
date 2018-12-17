table 1514 "Sent Notification Entry"
{
    // version NAVW113.00

    Caption = 'Sent Notification Entry';
    DrillDownPageID = "Sent Notification Entries";
    LookupPageID = "Sent Notification Entries";
    ReplicateData = false;

    fields
    {
        field(1;ID;Integer)
        {
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
        field(9;"Created Date-Time";DateTime)
        {
            Caption = 'Created Date-Time';
        }
        field(10;"Created By";Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(11;"Sent Date-Time";DateTime)
        {
            Caption = 'Sent Date-Time';
        }
        field(12;"Notification Content";BLOB)
        {
            Caption = 'Notification Content';
        }
        field(13;"Notification Method";Option)
        {
            Caption = 'Notification Method';
            OptionCaption = 'Email,Note';
            OptionMembers = Email,Note;
        }
        field(14;"Aggregated with Entry";Integer)
        {
            Caption = 'Aggregated with Entry';
            TableRelation = "Sent Notification Entry";
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure NewRecord(NotificationEntry: Record "Notification Entry";NotificationContent: Text;NotificationMethod: Option)
    var
        SentNotificationEntry: Record "Sent Notification Entry";
        OutStream: OutStream;
    begin
        Clear(Rec);
        if SentNotificationEntry.FindLast then;
        TransferFields(NotificationEntry);
        ID := SentNotificationEntry.ID + 1;
        "Notification Content".CreateOutStream(OutStream);
        OutStream.WriteText(NotificationContent);
        "Notification Method" := NotificationMethod;
        "Sent Date-Time" := CurrentDateTime;
        Insert(true);
    end;

    procedure ExportContent(UseDialog: Boolean): Text
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        CalcFields("Notification Content");
        if "Notification Content".HasValue then begin
          TempBlob.Blob := "Notification Content";
          if "Notification Method" = "Notification Method"::Note then
            exit(FileMgt.BLOBExport(TempBlob,'*.txt',UseDialog));
          exit(FileMgt.BLOBExport(TempBlob,'*.htm',UseDialog))
        end;
    end;
}

