table 1173 "Document Attachment"
{
    // version NAVW113.00

    Caption = 'Document Attachment';

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            Editable = false;
        }
        field(2;"Table ID";Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(3;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(4;"Attached Date";DateTime)
        {
            Caption = 'Attached Date';
        }
        field(5;"File Name";Text[250])
        {
            Caption = 'Attachment';
            NotBlank = true;

            trigger OnValidate()
            var
                DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
            begin
                if "File Name" = '' then
                  Error(EmptyFileNameErr);

                if DocumentAttachmentMgmt.IsDuplicateFile("Table ID","No.","Document Type","Line No.","File Name","File Extension") = true then
                  Error(DuplicateErr);
            end;
        }
        field(6;"File Type";Option)
        {
            Caption = 'File Type';
            OptionCaption = ' ,Image,PDF,Word,Excel,PowerPoint,Email,XML,Other';
            OptionMembers = " ",Image,PDF,Word,Excel,PowerPoint,Email,XML,Other;
        }
        field(7;"File Extension";Text[30])
        {
            Caption = 'File Extension';

            trigger OnValidate()
            begin
                case LowerCase("File Extension") of
                  'jpg','jpeg','bmp','png','tiff','tif','gif':
                    "File Type" := "File Type"::Image;
                  'pdf':
                    "File Type" := "File Type"::PDF;
                  'docx','doc':
                    "File Type" := "File Type"::Word;
                  'xlsx','xls':
                    "File Type" := "File Type"::Excel;
                  'pptx','ppt':
                    "File Type" := "File Type"::PowerPoint;
                  'msg':
                    "File Type" := "File Type"::Email;
                  'xml':
                    "File Type" := "File Type"::XML;
                  else
                    "File Type" := "File Type"::Other;
                end;
            end;
        }
        field(8;"Document Reference ID";Media)
        {
            Caption = 'Document Reference ID';
        }
        field(9;"Attached By";Guid)
        {
            Caption = 'Attached By';
            Editable = false;
            TableRelation = User."User Security ID" WHERE ("License Type"=CONST("Full User"));
        }
        field(10;User;Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("Attached By"),
                                                         "License Type"=CONST("Full User")));
            Caption = 'User';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11;"Document Flow Purchase";Boolean)
        {
            Caption = 'Flow to Purch. Trx';

            trigger OnValidate()
            begin
                if not "Document Reference ID".HasValue then
                  Error(NoDocumentAttachedErr);
            end;
        }
        field(12;"Document Flow Sales";Boolean)
        {
            Caption = 'Flow to Sales Trx';

            trigger OnValidate()
            begin
                if not "Document Reference ID".HasValue then
                  Error(NoDocumentAttachedErr);
            end;
        }
        field(13;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(14;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
    }

    keys
    {
        key(Key1;"Table ID","No.","Document Type","Line No.",ID)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"No.","File Name","File Extension","File Type")
        {
        }
    }

    trigger OnInsert()
    begin
        if IncomingFileName <> '' then begin
          Validate("File Extension",FileManagement.GetExtension(IncomingFileName));
          Validate("File Name",CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName),1,MaxStrLen("File Name")));
        end;

        if not "Document Reference ID".HasValue then
          Error(NoDocumentAttachedErr);

        Validate("Attached Date",CurrentDateTime);
        "Attached By" := UserSecurityId;
    end;

    var
        NoDocumentAttachedErr: Label 'Please attach a document first.';
        EmptyFileNameErr: Label 'Please choose a file to attach.';
        NoContentErr: Label 'The selected file has no content. Please choose another file.';
        FileManagement: Codeunit "File Management";
        IncomingFileName: Text;
        DuplicateErr: Label 'This file is already attached to the document. Please choose another file.';

    procedure Export(ShowFileDialog: Boolean): Text
    var
        TempBlob: Record TempBlob;
        FileManagement: Codeunit "File Management";
        DocumentStream: OutStream;
        FullFileName: Text;
    begin
        if ID = 0 then
          exit;
        // Ensure document has value in DB
        if not "Document Reference ID".HasValue then
          exit;

        FullFileName := "File Name" + '.' + "File Extension";
        TempBlob.Blob.CreateOutStream(DocumentStream);
        "Document Reference ID".ExportStream(DocumentStream);
        exit(FileManagement.BLOBExport(TempBlob,FullFileName,ShowFileDialog));
    end;

    procedure SaveAttachment(RecRef: RecordRef;FileName: Text;TempBlob: Record TempBlob)
    var
        FieldRef: FieldRef;
        DocStream: InStream;
        RecNo: Code[20];
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        LineNo: Integer;
    begin
        if FileName = '' then
          Error(EmptyFileNameErr);
        // Validate file/media is not empty
        if not TempBlob.Blob.HasValue then
          Error(NoContentErr);

        IncomingFileName := FileName;

        Validate("File Extension",FileManagement.GetExtension(IncomingFileName));
        Validate("File Name",CopyStr(FileManagement.GetFileNameWithoutExtension(IncomingFileName),1,MaxStrLen("File Name")));

        TempBlob.Blob.CreateInStream(DocStream);
        // IMPORTSTREAM(stream,description, mime-type,filename)
        // description and mime-type are set empty and will be automatically set by platform code from the stream
        "Document Reference ID".ImportStream(DocStream,'','',IncomingFileName);
        if not "Document Reference ID".HasValue then
          Error(NoDocumentAttachedErr);

        Validate("Table ID",RecRef.Number);

        case RecRef.Number of
          DATABASE::Customer,
          DATABASE::Vendor,
          DATABASE::Item,
          DATABASE::Employee,
          DATABASE::"Fixed Asset",
          DATABASE::Resource,
          DATABASE::Job:
            begin
              FieldRef := RecRef.Field(1);
              RecNo := FieldRef.Value;
              Validate("No.",RecNo);
            end;
        end;

        case RecRef.Number of
          DATABASE::"Sales Header",
          DATABASE::"Purchase Header",
          DATABASE::"Sales Line",
          DATABASE::"Purchase Line":
            begin
              FieldRef := RecRef.Field(1);
              DocType := FieldRef.Value;
              Validate("Document Type",DocType);

              FieldRef := RecRef.Field(3);
              RecNo := FieldRef.Value;
              Validate("No.",RecNo);
            end;
        end;

        case RecRef.Number of
          DATABASE::"Sales Line",
          DATABASE::"Purchase Line":
            begin
              FieldRef := RecRef.Field(4);
              LineNo := FieldRef.Value;
              Validate("Line No.",LineNo);
            end;
        end;

        case RecRef.Number of
          DATABASE::"Sales Invoice Header",
          DATABASE::"Sales Cr.Memo Header",
          DATABASE::"Purch. Inv. Header",
          DATABASE::"Purch. Cr. Memo Hdr.":
            begin
              FieldRef := RecRef.Field(3);
              RecNo := FieldRef.Value;
              Validate("No.",RecNo);
            end;
        end;

        case RecRef.Number of
          DATABASE::"Sales Invoice Line",
          DATABASE::"Sales Cr.Memo Line",
          DATABASE::"Purch. Inv. Line",
          DATABASE::"Purch. Cr. Memo Line":
            begin
              FieldRef := RecRef.Field(3);
              RecNo := FieldRef.Value;
              Validate("No.",RecNo);

              FieldRef := RecRef.Field(4);
              LineNo := FieldRef.Value;
              Validate("Line No.",LineNo);
            end;
        end;

        Insert(true);
    end;
}

