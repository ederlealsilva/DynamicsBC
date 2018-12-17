table 1270 "OCR Service Setup"
{
    // version NAVW113.00

    Caption = 'OCR Service Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"User Name";Text[50])
        {
            Caption = 'User Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3;"Password Key";Guid)
        {
            Caption = 'Password Key';
            TableRelation = "Service Password".Key;
        }
        field(4;"Sign-up URL";Text[250])
        {
            Caption = 'Sign-up URL';
            ExtendedDatatype = URL;
        }
        field(5;"Service URL";Text[250])
        {
            Caption = 'Service URL';
            ExtendedDatatype = URL;

            trigger OnValidate()
            var
                HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
            begin
                if "Service URL" = '' then
                  exit;
                HttpWebRequestMgt.CheckUrl("Service URL");
                while (StrLen("Service URL") > 8) and ("Service URL"[StrLen("Service URL")] = '/') do
                  "Service URL" := CopyStr("Service URL",1,StrLen("Service URL") - 1);
            end;
        }
        field(6;"Sign-in URL";Text[250])
        {
            Caption = 'Sign-in URL';
            ExtendedDatatype = URL;
        }
        field(7;"Authorization Key";Guid)
        {
            Caption = 'Authorization Key';
            TableRelation = "Service Password".Key;
        }
        field(8;"Customer Name";Text[80])
        {
            Caption = 'Customer Name';
            Editable = false;
        }
        field(9;"Customer ID";Text[50])
        {
            Caption = 'Customer ID';
            Editable = false;
        }
        field(10;"Customer Status";Text[30])
        {
            Caption = 'Customer Status';
            Editable = false;
        }
        field(11;"Organization ID";Text[50])
        {
            Caption = 'Organization ID';
            Editable = false;
        }
        field(12;"Default OCR Doc. Template";Code[20])
        {
            Caption = 'Default OCR Doc. Template';
            TableRelation = "OCR Service Document Template";

            trigger OnLookup()
            var
                OCRServiceDocumentTemplate: Record "OCR Service Document Template";
                OCRServiceMgt: Codeunit "OCR Service Mgt.";
            begin
                if OCRServiceDocumentTemplate.IsEmpty then begin
                  OCRServiceMgt.SetupConnection(Rec);
                  Commit;
                end;

                if PAGE.RunModal(PAGE::"OCR Service Document Templates",OCRServiceDocumentTemplate) = ACTION::LookupOK then
                  "Default OCR Doc. Template" := OCRServiceDocumentTemplate.Code;
            end;

            trigger OnValidate()
            var
                IncomingDocument: Record "Incoming Document";
            begin
                if xRec."Default OCR Doc. Template" <> '' then
                  exit;
                IncomingDocument.SetRange("OCR Service Doc. Template Code",'');
                IncomingDocument.ModifyAll("OCR Service Doc. Template Code","Default OCR Doc. Template");
            end;
        }
        field(13;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                CompanyInformation: Record "Company Information";
                OCRServiceMgt: Codeunit "OCR Service Mgt.";
                OCRMasterDataMgt: Codeunit "OCR Master Data Mgt.";
            begin
                if Enabled then begin
                  OCRServiceMgt.SetupConnection(Rec);
                  if "Default OCR Doc. Template" = '' then
                    if CompanyInformation.Get then
                      case CompanyInformation."Country/Region Code" of
                        'US','USA':
                          Validate("Default OCR Doc. Template",'USA_PO');
                        'CA':
                          Validate("Default OCR Doc. Template",'CAN_PO');
                      end;
                  Modify;
                  TestField("Default OCR Doc. Template");
                  if "Master Data Sync Enabled" then
                    OCRMasterDataMgt.UpdateIntegrationRecords(true);
                  ScheduleJobQueueEntries;
                  if Confirm(JobQEntriesCreatedQst) then
                    ShowJobQueueEntry;
                end else
                  CancelJobQueueEntries;
            end;
        }
        field(14;"Master Data Sync Enabled";Boolean)
        {
            Caption = 'Master Data Sync Enabled';

            trigger OnValidate()
            var
                OCRMasterDataMgt: Codeunit "OCR Master Data Mgt.";
            begin
                if "Master Data Sync Enabled" and Enabled then begin
                  Modify;
                  OCRMasterDataMgt.UpdateIntegrationRecords(true);
                  ScheduleJobQueueSync;
                end else
                  CancelJobQueueSync;
            end;
        }
        field(15;"Master Data Last Sync";DateTime)
        {
            Caption = 'Master Data Last Sync';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        OCRServiceDocTemplate: Record "OCR Service Document Template";
    begin
        DeletePassword("Password Key");
        DeletePassword("Authorization Key");
        OCRServiceDocTemplate.DeleteAll(true)
    end;

    trigger OnInsert()
    begin
        TestField("Primary Key",'');
        SetURLsToDefault;
    end;

    var
        MustBeEnabledErr: Label 'The OCR service is not enabled.\\In the OCR Service Setup window, select the Enabled check box.', Comment='OCR = Optical Character Recognition';
        JobQEntriesCreatedQst: Label 'Job queue entries for sending and receiving electronic documents have been created.\\Do you want to open the Job Queue Entries window?';

    [Scope('Personalization')]
    procedure SavePassword(var PasswordKey: Guid;PasswordText: Text)
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid(PasswordKey) or not ServicePassword.Get(PasswordKey) then begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Insert(true);
          PasswordKey := ServicePassword.Key;
          Modify;
        end else begin
          ServicePassword.SavePassword(PasswordText);
          ServicePassword.Modify;
        end;
        Commit;
    end;

    [Scope('Personalization')]
    procedure GetPassword(PasswordKey: Guid): Text
    var
        ServicePassword: Record "Service Password";
    begin
        ServicePassword.Get(PasswordKey);
        exit(ServicePassword.GetPassword);
    end;

    local procedure DeletePassword(PasswordKey: Guid)
    var
        ServicePassword: Record "Service Password";
    begin
        if ServicePassword.Get(PasswordKey) then
          ServicePassword.Delete;
    end;

    [Scope('Personalization')]
    procedure HasPassword(PasswordKey: Guid): Boolean
    var
        ServicePassword: Record "Service Password";
    begin
        if not ServicePassword.Get(PasswordKey) then
          exit(false);
        exit(ServicePassword.GetPassword <> '');
    end;

    [Scope('Personalization')]
    procedure SetURLsToDefault()
    var
        OCRServiceMgt: Codeunit "OCR Service Mgt.";
    begin
        OCRServiceMgt.SetURLsToDefaultRSO(Rec);
    end;

    [Scope('Personalization')]
    procedure CheckEnabled()
    begin
        if not Enabled then
          Error(MustBeEnabledErr);
    end;

    local procedure ScheduleJobQueueEntries()
    begin
        ScheduleJobQueueReceive;
        ScheduleJobQueueSend;
        ScheduleJobQueueSync;
    end;

    [Scope('Personalization')]
    procedure ScheduleJobQueueSend()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecId: RecordID;
    begin
        CancelJobQueueSend;
        JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"OCR - Send to Service",DummyRecId);
    end;

    [Scope('Personalization')]
    procedure ScheduleJobQueueReceive()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecId: RecordID;
    begin
        CancelJobQueueReceive;
        JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"OCR - Receive from Service",DummyRecId);
    end;

    [Scope('Personalization')]
    procedure ScheduleJobQueueSync()
    var
        OCRSyncMasterData: Codeunit "OCR - Sync Master Data";
    begin
        OCRSyncMasterData.ScheduleJob;
    end;

    local procedure CancelJobQueueEntries()
    begin
        CancelJobQueueReceive;
        CancelJobQueueSend;
        CancelJobQueueSync;
    end;

    local procedure CancelJobQueueEntry(ObjType: Option;ObjID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(ObjType,ObjID) then
          JobQueueEntry.Cancel;
    end;

    [Scope('Personalization')]
    procedure CancelJobQueueSend()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CancelJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"OCR - Send to Service");
    end;

    [Scope('Personalization')]
    procedure CancelJobQueueReceive()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        CancelJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          CODEUNIT::"OCR - Receive from Service");
    end;

    [Scope('Personalization')]
    procedure CancelJobQueueSync()
    var
        OCRSyncMasterData: Codeunit "OCR - Sync Master Data";
    begin
        OCRSyncMasterData.CancelJob;
    end;

    [Scope('Personalization')]
    procedure ShowJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run",JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run",'%1|%2|%3',
          CODEUNIT::"OCR - Send to Service",
          CODEUNIT::"OCR - Receive from Service",
          CODEUNIT::"OCR - Sync Master Data");
        if JobQueueEntry.FindFirst then
          PAGE.Run(PAGE::"Job Queue Entries",JobQueueEntry);
    end;
}

