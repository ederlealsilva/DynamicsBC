table 1205 "Credit Transfer Register"
{
    // version NAVW113.00

    Caption = 'Credit Transfer Register';
    DataCaptionFields = Identifier,"Created Date-Time";
    DrillDownPageID = "Credit Transfer Registers";
    LookupPageID = "Credit Transfer Registers";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
        }
        field(2;Identifier;Code[20])
        {
            Caption = 'Identifier';
        }
        field(3;"Created Date-Time";DateTime)
        {
            Caption = 'Created Date-Time';
        }
        field(4;"Created by User";Code[50])
        {
            Caption = 'Created by User';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(5;Status;Option)
        {
            Caption = 'Status';
            Editable = false;
            OptionCaption = 'Canceled,File Created,File Re-exported';
            OptionMembers = Canceled,"File Created","File Re-exported";
        }
        field(6;"No. of Transfers";Integer)
        {
            CalcFormula = Count("Credit Transfer Entry" WHERE ("Credit Transfer Register No."=FIELD("No.")));
            Caption = 'No. of Transfers';
            FieldClass = FlowField;
        }
        field(7;"From Bank Account No.";Code[20])
        {
            Caption = 'From Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(8;"From Bank Account Name";Text[50])
        {
            CalcFormula = Lookup("Bank Account".Name WHERE ("No."=FIELD("From Bank Account No.")));
            Caption = 'From Bank Account Name';
            FieldClass = FlowField;
        }
        field(9;"Exported File";BLOB)
        {
            Caption = 'Exported File';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PaymentsFileNotFoundErr: Label 'The original payment file was not found.\Export a new file from the Payment Journal window.';
        ExportToServerFile: Boolean;

    [Scope('Personalization')]
    procedure CreateNew(NewIdentifier: Code[20];NewBankAccountNo: Code[20])
    begin
        Reset;
        LockTable;
        if FindLast then;
        Init;
        "No." += 1;
        Identifier := NewIdentifier;
        "Created Date-Time" := CurrentDateTime;
        "Created by User" := UserId;
        "From Bank Account No." := NewBankAccountNo;
        Insert;
    end;

    [Scope('Personalization')]
    procedure SetStatus(NewStatus: Option)
    begin
        LockTable;
        Find;
        Status := NewStatus;
        Modify;
    end;

    procedure Reexport()
    var
        CreditTransReExportHistory: Record "Credit Trans Re-export History";
        TempPaymentFileTempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
    begin
        CalcFields("Exported File");
        TempPaymentFileTempBlob.Init;
        TempPaymentFileTempBlob.Blob := "Exported File";

        if not TempPaymentFileTempBlob.Blob.HasValue then
          Error(PaymentsFileNotFoundErr);

        CreditTransReExportHistory.Init;
        CreditTransReExportHistory."Credit Transfer Register No." := "No.";
        CreditTransReExportHistory.Insert(true);

        if FileMgt.BLOBExport(TempPaymentFileTempBlob,StrSubstNo('%1.XML',Identifier),not ExportToServerFile) <> '' then begin
          Status := Status::"File Re-exported";
          Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFileContent(var DataExch: Record "Data Exch.")
    begin
        LockTable;
        Find;
        DataExch.CalcFields("File Content");
        "Exported File" := DataExch."File Content";
        Modify;
    end;

    [Scope('Personalization')]
    procedure EnableExportToServerFile()
    begin
        ExportToServerFile := true;
    end;
}

