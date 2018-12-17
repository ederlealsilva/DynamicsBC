table 9500 "Email Item"
{
    // version NAVW113.00

    Caption = 'Email Item';

    fields
    {
        field(1;ID;Guid)
        {
            Caption = 'ID';
        }
        field(2;"From Name";Text[100])
        {
            Caption = 'From Name';
        }
        field(3;"From Address";Text[250])
        {
            Caption = 'From Address';

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "From Address" <> '' then
                  MailManagement.CheckValidEmailAddresses("From Address");
            end;
        }
        field(4;"Send to";Text[250])
        {
            Caption = 'Send to';

            trigger OnValidate()
            begin
                if "Send to" <> '' then
                  CorrectAndValidateEmailList("Send to");
            end;
        }
        field(5;"Send CC";Text[250])
        {
            Caption = 'Send CC';

            trigger OnValidate()
            begin
                if "Send CC" <> '' then
                  CorrectAndValidateEmailList("Send CC");
            end;
        }
        field(6;"Send BCC";Text[250])
        {
            Caption = 'Send BCC';

            trigger OnValidate()
            begin
                if "Send BCC" <> '' then
                  CorrectAndValidateEmailList("Send BCC");
            end;
        }
        field(7;Subject;Text[250])
        {
            Caption = 'Subject';
        }
        field(8;Body;BLOB)
        {
            Caption = 'Body';
        }
        field(9;"Attachment File Path";Text[250])
        {
            Caption = 'Attachment File Path';
        }
        field(10;"Attachment Name";Text[250])
        {
            Caption = 'Attachment Name';
        }
        field(11;"Plaintext Formatted";Boolean)
        {
            Caption = 'Plaintext Formatted';
            InitValue = true;

            trigger OnValidate()
            begin
                if "Plaintext Formatted" then
                  Validate("Body File Path",'')
                else
                  SetBodyText('');
            end;
        }
        field(12;"Body File Path";Text[250])
        {
            Caption = 'Body File Path';

            trigger OnValidate()
            begin
                if "Body File Path" <> '' then
                  TestField("Plaintext Formatted",false);
            end;
        }
        field(13;"Message Type";Option)
        {
            Caption = 'Message Type';
            OptionCaption = 'Custom Message,From Email Body Template';
            OptionMembers = "Custom Message","From Email Body Template";
        }
        field(21;"Attachment File Path 2";Text[250])
        {
            Caption = 'Attachment File Path 2';
        }
        field(22;"Attachment Name 2";Text[50])
        {
            Caption = 'Attachment Name 2';
        }
        field(23;"Attachment File Path 3";Text[250])
        {
            Caption = 'Attachment File Path 3';
        }
        field(24;"Attachment Name 3";Text[50])
        {
            Caption = 'Attachment Name 3';
        }
        field(25;"Attachment File Path 4";Text[250])
        {
            Caption = 'Attachment File Path 4';
        }
        field(26;"Attachment Name 4";Text[50])
        {
            Caption = 'Attachment Name 4';
        }
        field(27;"Attachment File Path 5";Text[250])
        {
            Caption = 'Attachment File Path 5';
        }
        field(28;"Attachment Name 5";Text[50])
        {
            Caption = 'Attachment Name 5';
        }
        field(29;"Attachment File Path 6";Text[250])
        {
            Caption = 'Attachment File Path 6';
        }
        field(30;"Attachment Name 6";Text[50])
        {
            Caption = 'Attachment Name 6';
        }
        field(31;"Attachment File Path 7";Text[250])
        {
            Caption = 'Attachment File Path 7';
        }
        field(32;"Attachment Name 7";Text[50])
        {
            Caption = 'Attachment Name 7';
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

    var
        O365EmailSetup: Record "O365 Email Setup";

    [Scope('Personalization')]
    procedure Init()
    begin
        ID := CreateGuid;
    end;

    [Scope('Personalization')]
    procedure Send(HideMailDialog: Boolean): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        MailManagement.SendMailOrDownload(Rec,HideMailDialog);
        exit(MailManagement.IsSent);
    end;

    [Scope('Personalization')]
    procedure SetBodyText(Value: Text)
    var
        DataStream: OutStream;
        BodyText: BigText;
    begin
        Clear(Body);
        BodyText.AddText(Value);
        Body.CreateOutStream(DataStream,TEXTENCODING::UTF8);
        BodyText.Write(DataStream);
    end;

    procedure GetBodyText() Value: Text
    var
        TempBlob: Record TempBlob;
        FileManagement: Codeunit "File Management";
        DataStream: InStream;
        BlobInStream: InStream;
        BodyOutStream: OutStream;
        BodyText: BigText;
    begin
        // Note this is intended only to get the body in memory - not from the database.
        Value := '';

        // If the body doesn't have a value, attempt to import the value from the file path, otherwise exit.
        if not Body.HasValue then begin
          if ("Body File Path" <> '') and FileManagement.ServerFileExists("Body File Path") then begin
            TempBlob.Init;
            FileManagement.BLOBImportFromServerFile(TempBlob,"Body File Path");
            TempBlob.Blob.CreateInStream(BlobInStream,TEXTENCODING::UTF8);
            Body.CreateOutStream(BodyOutStream);
            CopyStream(BodyOutStream,BlobInStream);
          end else
            exit;
        end;

        if "Plaintext Formatted" then begin
          Body.CreateInStream(DataStream,TEXTENCODING::UTF8);
          BodyText.Read(DataStream);
          BodyText.GetSubText(Value,1);
        end else begin
          Body.CreateInStream(DataStream,TEXTENCODING::UTF8);
          DataStream.Read(Value);
        end;

        exit(Value);
    end;

    local procedure CorrectAndValidateEmailList(var EmailAddresses: Text[250])
    var
        MailManagement: Codeunit "Mail Management";
    begin
        EmailAddresses := ConvertStr(EmailAddresses,',',';');
        EmailAddresses := DelChr(EmailAddresses,'<>');
        MailManagement.CheckValidEmailAddresses(EmailAddresses);
    end;

    [Scope('Personalization')]
    procedure AddCcBcc()
    begin
        "Send CC" := O365EmailSetup.GetCCAddressesFromO365EmailSetup;
        "Send BCC" := O365EmailSetup.GetBCCAddressesFromO365EmailSetup;
    end;

    procedure AttachIncomingDocuments(SalesInvoiceNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        OutStr: OutStream;
        File: File;
        AttachmentCounter: Integer;
        FilePath: Text[250];
        AttachmentName: Text[50];
        IsPostedDocument: Boolean;
    begin
        if SalesInvoiceNo = '' then
          exit;
        IsPostedDocument := true;
        if not SalesInvoiceHeader.Get(SalesInvoiceNo) then begin
          SalesHeader.SetFilter("Document Type",'%1|%2',SalesHeader."Document Type"::Quote,SalesHeader."Document Type"::Invoice);
          SalesHeader.SetRange("No.",SalesInvoiceNo);
          if not SalesHeader.FindFirst then
            exit;
          if SalesHeader."Incoming Document Entry No." = 0 then
            exit;
          IsPostedDocument := false;
        end;

        if IsPostedDocument then begin
          IncomingDocumentAttachment.SetRange("Document No.",SalesInvoiceNo);
          IncomingDocumentAttachment.SetRange("Posting Date",SalesInvoiceHeader."Posting Date");
        end else
          IncomingDocumentAttachment.SetRange("Incoming Document Entry No.",SalesHeader."Incoming Document Entry No.");

        IncomingDocumentAttachment.SetAutoCalcFields(Content);
        if IncomingDocumentAttachment.FindSet then
          repeat
            if IncomingDocumentAttachment.Content.HasValue then begin
              AttachmentCounter += 1;
              FilePath := CopyStr(FileManagement.ServerTempFileName(IncomingDocumentAttachment."File Extension"),1,MaxStrLen(FilePath));
              File.Create(FilePath);
              File.CreateOutStream(OutStr);
              IncomingDocumentAttachment.Content.CreateInStream(InStr);
              CopyStream(OutStr,InStr);
              File.Close;
              AttachmentName :=
                CopyStr(
                  StrSubstNo(
                    '%1.%2',IncomingDocumentAttachment.Name,IncomingDocumentAttachment."File Extension"),1,MaxStrLen(AttachmentName));

              case AttachmentCounter of
                1:
                  begin
                    "Attachment File Path 2" := FilePath;
                    "Attachment Name 2" := AttachmentName;
                  end;
                2:
                  begin
                    "Attachment File Path 3" := FilePath;
                    "Attachment Name 3" := AttachmentName;
                  end;
                3:
                  begin
                    "Attachment File Path 4" := FilePath;
                    "Attachment Name 4" := AttachmentName;
                  end;
                4:
                  begin
                    "Attachment File Path 5" := FilePath;
                    "Attachment Name 5" := AttachmentName;
                  end;
                5:
                  begin
                    "Attachment File Path 6" := FilePath;
                    "Attachment Name 6" := AttachmentName;
                  end;
                6:
                  begin
                    "Attachment File Path 7" := FilePath;
                    "Attachment Name 7" := AttachmentName;
                  end;
              end;
            end;
          until (AttachmentCounter = 6) or (IncomingDocumentAttachment.Next = 0);
    end;
}

