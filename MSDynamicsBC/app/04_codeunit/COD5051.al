codeunit 5051 SegManagement
{
    // version NAVW113.00

    Permissions = TableData "Interaction Log Entry"=rimd;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label '%1 for Segment No. %2 already exists.';
        Text001: Label 'Segment %1 is empty.';
        Text002: Label 'Follow-up on segment %1';
        InteractionTmplSetup: Record "Interaction Template Setup";
        Text003: Label 'Interaction Template %1 has assigned Interaction Template Language %2.\It is not allowed to have languages assigned to templates used for system document logging.';
        Text004: Label 'Interactions';
        InterTemplateSalesInvoicesNotSpecifiedErr: Label 'The Invoices field on the Sales FastTab in the Interaction Template Setup window must be filled in.';

    procedure LogSegment(SegHeader: Record "Segment Header";Deliver: Boolean;Followup: Boolean)
    var
        SegLine: Record "Segment Line";
        LoggedSeg: Record "Logged Segment";
        InteractLogEntry: Record "Interaction Log Entry";
        Attachment: Record Attachment;
        InteractTemplate: Record "Interaction Template";
        DeliverySorterTemp: Record "Delivery Sorter" temporary;
        AttachmentManagement: Codeunit AttachmentManagement;
        SegmentNo: Code[20];
        CampaignNo: Code[20];
        NextInteractLogEntryNo: Integer;
    begin
        LoggedSeg.LockTable;
        LoggedSeg.SetCurrentKey("Segment No.");
        LoggedSeg.SetRange("Segment No.",SegHeader."No.");
        if not LoggedSeg.IsEmpty then
          Error(Text000,LoggedSeg.TableCaption,SegHeader."No.");

        SegHeader.TestField(Description);

        LoggedSeg.Reset;
        LoggedSeg.Init;
        LoggedSeg."Entry No." := GetNextLoggedSegmentEntryNo;
        LoggedSeg."Segment No." := SegHeader."No.";
        LoggedSeg.Description := SegHeader.Description;
        LoggedSeg."Creation Date" := Today;
        LoggedSeg."User ID" := UserId;
        LoggedSeg.Insert;

        SegLine.LockTable;
        SegLine.SetCurrentKey("Segment No.","Campaign No.",Date);
        SegLine.SetRange("Segment No.",SegHeader."No.");
        SegLine.SetFilter("Campaign No.",'<>%1','');
        SegLine.SetFilter("Contact No.",'<>%1','');
        if SegLine.FindSet then
          repeat
            SegLine."Campaign Entry No." := GetCampaignEntryNo(SegLine,LoggedSeg."Entry No.");
            SegLine.Modify;
          until SegLine.Next = 0;

        SegLine.Reset;
        SegLine.SetRange("Segment No.",SegHeader."No.");
        SegLine.SetFilter("Contact No.",'<>%1','');

        if SegLine.FindSet then begin
          if InteractTemplate.Get(SegHeader."Interaction Template Code") then;
          NextInteractLogEntryNo := GetNextInteractionLogEntryNo;
          repeat
            TestFields(SegLine);
            InteractLogEntry.Init;
            InteractLogEntry."Entry No." := NextInteractLogEntryNo;
            InteractLogEntry."Logged Segment Entry No." := LoggedSeg."Entry No.";
            InteractLogEntry.CopyFromSegment(SegLine);
            if Deliver and ((SegLine."Correspondence Type" <> 0) or (InteractTemplate."Correspondence Type (Default)" <> 0)) then begin
              InteractLogEntry."Delivery Status" := InteractLogEntry."Delivery Status"::"In Progress";
              SegLine.TestField("Attachment No.");
              DeliverySorterTemp."No." := InteractLogEntry."Entry No.";
              DeliverySorterTemp."Attachment No." := InteractLogEntry."Attachment No.";
              DeliverySorterTemp."Correspondence Type" := InteractLogEntry."Correspondence Type";
              DeliverySorterTemp.Subject := InteractLogEntry.Subject;
              DeliverySorterTemp."Send Word Docs. as Attmt." := InteractLogEntry."Send Word Docs. as Attmt.";
              DeliverySorterTemp."Language Code" := SegLine."Language Code";
              DeliverySorterTemp.Insert;
            end;
            InteractLogEntry.Insert;
            Attachment.LockTable;
            if Attachment.Get(SegLine."Attachment No.") and (not Attachment."Read Only") then begin
              Attachment."Read Only" := true;
              Attachment.Modify(true);
            end;
            NextInteractLogEntryNo += 1;
          until SegLine.Next = 0;
        end else
          Error(Text001,SegHeader."No.");

        SegmentNo := SegHeader."No.";
        CampaignNo := SegHeader."Campaign No.";
        SegHeader.Delete(true);

        if Followup then begin
          Clear(SegHeader);
          SegHeader."Campaign No." := CampaignNo;
          SegHeader.Description := CopyStr(StrSubstNo(Text002,SegmentNo),1,50);
          SegHeader.Insert(true);
          SegHeader.ReuseLogged(LoggedSeg."Entry No.");
        end;

        if Deliver then
          AttachmentManagement.Send(DeliverySorterTemp);
    end;

    [Scope('Personalization')]
    procedure LogInteraction(SegLine: Record "Segment Line";var AttachmentTemp: Record Attachment;var InterLogEntryCommentLineTmp: Record "Inter. Log Entry Comment Line";Deliver: Boolean;Postponed: Boolean) NextInteractLogEntryNo: Integer
    var
        InteractLogEntry: Record "Interaction Log Entry";
        Attachment: Record Attachment;
        MarketingSetup: Record "Marketing Setup";
        DeliverySorterTemp: Record "Delivery Sorter" temporary;
        InterLogEntryCommentLine: Record "Inter. Log Entry Comment Line";
        AttachmentManagement: Codeunit AttachmentManagement;
        FileMgt: Codeunit "File Management";
        FileName: Text;
    begin
        if not Postponed then
          TestFields(SegLine);
        if (SegLine."Campaign No." <> '') and (not Postponed) then
          SegLine."Campaign Entry No." := GetCampaignEntryNo(SegLine,0);

        if AttachmentTemp."Attachment File".HasValue then begin
          with Attachment do begin
            LockTable;
            if (SegLine."Line No." <> 0) and Get(SegLine."Attachment No.") then begin
              RemoveAttachment(false);
              AttachmentTemp."No." := SegLine."Attachment No.";
            end;

            Copy(AttachmentTemp);
            "Read Only" := true;
            WizSaveAttachment;
            Insert(true);
          end;

          MarketingSetup.Get;
          if MarketingSetup."Attachment Storage Type" = MarketingSetup."Attachment Storage Type"::"Disk File" then
            if Attachment."No." <> 0 then begin
              FileName := Attachment.ConstDiskFileName;
              if FileName <> '' then begin
                FileMgt.DeleteServerFile(FileName);
                AttachmentTemp.ExportAttachmentToServerFile(FileName);
              end;
            end;
          SegLine."Attachment No." := Attachment."No.";
        end;

        if SegLine."Line No." = 0 then begin
          NextInteractLogEntryNo := GetNextInteractionLogEntryNo;

          InteractLogEntry.Init;
          InteractLogEntry."Entry No." := NextInteractLogEntryNo;
          InteractLogEntry.CopyFromSegment(SegLine);
          InteractLogEntry.Postponed := Postponed;
          InteractLogEntry.Insert
        end else begin
          InteractLogEntry.Get(SegLine."Line No.");
          InteractLogEntry.CopyFromSegment(SegLine);
          InteractLogEntry.Postponed := Postponed;
          InteractLogEntry.Modify;
          InterLogEntryCommentLine.SetRange("Entry No.",InteractLogEntry."Entry No.");
          InterLogEntryCommentLine.DeleteAll;
        end;

        if InterLogEntryCommentLineTmp.FindSet then
          repeat
            InterLogEntryCommentLine.Init;
            InterLogEntryCommentLine := InterLogEntryCommentLineTmp;
            InterLogEntryCommentLine."Entry No." := InteractLogEntry."Entry No.";
            InterLogEntryCommentLine.Insert;
          until InterLogEntryCommentLineTmp.Next = 0;

        if Deliver and (SegLine."Correspondence Type" <> 0) and (not Postponed) then begin
          InteractLogEntry."Delivery Status" := InteractLogEntry."Delivery Status"::"In Progress";
          DeliverySorterTemp."No." := InteractLogEntry."Entry No.";
          DeliverySorterTemp."Attachment No." := Attachment."No.";
          DeliverySorterTemp."Correspondence Type" := InteractLogEntry."Correspondence Type";
          DeliverySorterTemp.Subject := InteractLogEntry.Subject;
          DeliverySorterTemp."Send Word Docs. as Attmt." := false;
          DeliverySorterTemp."Language Code" := SegLine."Language Code";
          DeliverySorterTemp.Insert;
          AttachmentManagement.Send(DeliverySorterTemp);
        end;
    end;

    [Scope('Personalization')]
    procedure LogDocument(DocumentType: Integer;DocumentNo: Code[20];DocNoOccurrence: Integer;VersionNo: Integer;AccountTableNo: Integer;AccountNo: Code[20];SalespersonCode: Code[20];CampaignNo: Code[20];Description: Text[50];OpportunityNo: Code[20])
    var
        InteractTmpl: Record "Interaction Template";
        SegLine: Record "Segment Line" temporary;
        ContBusRel: Record "Contact Business Relation";
        Attachment: Record Attachment;
        Cont: Record Contact;
        InteractTmplLanguage: Record "Interaction Tmpl. Language";
        InterLogEntryCommentLine: Record "Inter. Log Entry Comment Line" temporary;
        InteractTmplCode: Code[10];
        ContNo: Code[20];
    begin
        InteractTmplCode := FindInteractTmplCode(DocumentType);
        if InteractTmplCode = '' then
          exit;

        InteractTmpl.Get(InteractTmplCode);

        InteractTmplLanguage.SetRange("Interaction Template Code",InteractTmplCode);
        if InteractTmplLanguage.FindFirst then
          Error(Text003,InteractTmplCode,InteractTmplLanguage."Language Code");

        if Description = '' then
          Description := InteractTmpl.Description;

        case AccountTableNo of
          DATABASE::Customer:
            begin
              ContNo := FindContactFromContBusRelation(ContBusRel."Link to Table"::Customer,AccountNo);
              if ContNo = '' then
                exit;
            end;
          DATABASE::Vendor:
            begin
              ContNo := FindContactFromContBusRelation(ContBusRel."Link to Table"::Vendor,AccountNo);
              if ContNo = '' then
                exit;
            end;
          DATABASE::Contact:
            begin
              if not Cont.Get(AccountNo) then
                exit;
              if SalespersonCode = '' then
                SalespersonCode := Cont."Salesperson Code";
              ContNo := AccountNo;
            end;
        end;

        SegLine.Init;
        SegLine."Document Type" := DocumentType;
        SegLine."Document No." := DocumentNo;
        SegLine."Doc. No. Occurrence" := DocNoOccurrence;
        SegLine."Version No." := VersionNo;
        SegLine.Validate("Contact No.",ContNo);
        SegLine.Date := Today;
        SegLine."Time of Interaction" := Time;
        SegLine.Description := Description;
        SegLine."Salesperson Code" := SalespersonCode;
        SegLine."Opportunity No." := OpportunityNo;
        SegLine.Insert;
        SegLine.Validate("Interaction Template Code",InteractTmplCode);
        if CampaignNo <> '' then
          SegLine."Campaign No." := CampaignNo;
        SegLine.Modify;

        LogInteraction(SegLine,Attachment,InterLogEntryCommentLine,false,false);
    end;

    [Scope('Personalization')]
    procedure FindInteractTmplCode(DocumentType: Integer) InteractTmplCode: Code[10]
    begin
        if not InteractionTmplSetup.ReadPermission then
          exit('');
        if InteractionTmplSetup.Get then
          case DocumentType of
            1:
              InteractTmplCode := InteractionTmplSetup."Sales Quotes";
            2:
              InteractTmplCode := InteractionTmplSetup."Sales Blnkt. Ord";
            3:
              InteractTmplCode := InteractionTmplSetup."Sales Ord. Cnfrmn.";
            4:
              InteractTmplCode := InteractionTmplSetup."Sales Invoices";
            5:
              InteractTmplCode := InteractionTmplSetup."Sales Shpt. Note";
            6:
              InteractTmplCode := InteractionTmplSetup."Sales Cr. Memo";
            7:
              InteractTmplCode := InteractionTmplSetup."Sales Statement";
            8:
              InteractTmplCode := InteractionTmplSetup."Sales Rmdr.";
            9:
              InteractTmplCode := InteractionTmplSetup."Serv Ord Create";
            10:
              InteractTmplCode := InteractionTmplSetup."Serv Ord Post";
            11:
              InteractTmplCode := InteractionTmplSetup."Purch. Quotes";
            12:
              InteractTmplCode := InteractionTmplSetup."Purch Blnkt Ord";
            13:
              InteractTmplCode := InteractionTmplSetup."Purch. Orders";
            14:
              InteractTmplCode := InteractionTmplSetup."Purch Invoices";
            15:
              InteractTmplCode := InteractionTmplSetup."Purch. Rcpt.";
            16:
              InteractTmplCode := InteractionTmplSetup."Purch Cr Memos";
            17:
              InteractTmplCode := InteractionTmplSetup."Cover Sheets";
            18:
              InteractTmplCode := InteractionTmplSetup."Sales Return Order";
            19:
              InteractTmplCode := InteractionTmplSetup."Sales Finance Charge Memo";
            20:
              InteractTmplCode := InteractionTmplSetup."Sales Return Receipt";
            21:
              InteractTmplCode := InteractionTmplSetup."Purch. Return Shipment";
            22:
              InteractTmplCode := InteractionTmplSetup."Purch. Return Ord. Cnfrmn.";
            23:
              InteractTmplCode := InteractionTmplSetup."Service Contract";
            24:
              InteractTmplCode := InteractionTmplSetup."Service Contract Quote";
            25:
              InteractTmplCode := InteractionTmplSetup."Service Quote";
          end;
        exit(InteractTmplCode);
    end;

    local procedure TestFields(var SegLine: Record "Segment Line")
    var
        Cont: Record Contact;
        Salesperson: Record "Salesperson/Purchaser";
        Campaign: Record Campaign;
        InteractTmpl: Record "Interaction Template";
        ContAltAddr: Record "Contact Alt. Address";
    begin
        with SegLine do begin
          TestField(Date);
          TestField("Contact No.");
          Cont.Get("Contact No.");
          if "Document Type" = "Document Type"::" " then begin
            TestField("Salesperson Code");
            Salesperson.Get("Salesperson Code");
          end;
          TestField("Interaction Template Code");
          InteractTmpl.Get("Interaction Template Code");
          if "Campaign No." <> '' then
            Campaign.Get("Campaign No.");
          case "Correspondence Type" of
            "Correspondence Type"::Email:
              begin
                if Cont."E-Mail" = '' then
                  "Correspondence Type" := "Correspondence Type"::" ";

                if ContAltAddr.Get("Contact No.","Contact Alt. Address Code") then
                  if ContAltAddr."E-Mail" <> '' then
                    "Correspondence Type" := "Correspondence Type"::Email;
              end;
            "Correspondence Type"::Fax:
              begin
                if Cont."Fax No." = '' then
                  "Correspondence Type" := "Correspondence Type"::" ";

                if ContAltAddr.Get("Contact No.","Contact Alt. Address Code") then
                  if ContAltAddr."Fax No." <> '' then
                    "Correspondence Type" := "Correspondence Type"::Fax;
              end;
          end;
        end;
    end;

    local procedure CopyFieldsToCampaignEntry(var CampaignEntry: Record "Campaign Entry";var SegLine: Record "Segment Line")
    var
        SegHeader: Record "Segment Header";
    begin
        CampaignEntry.CopyFromSegment(SegLine);
        if SegLine."Segment No." <> '' then begin
          SegHeader.Get(SegLine."Segment No.");
          CampaignEntry.Description := SegHeader.Description;
        end else begin
          CampaignEntry.Description :=
            CopyStr(FindInteractTmplSetupCaption(SegLine."Document Type"),1,MaxStrLen(CampaignEntry.Description));
          if CampaignEntry.Description = '' then
            CampaignEntry.Description := Text004;
        end;
    end;

    local procedure FindInteractTmplSetupCaption(DocumentType: Integer) InteractTmplSetupCaption: Text[80]
    begin
        InteractionTmplSetup.Get;
        case DocumentType of
          1:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Quotes");
          2:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Blnkt. Ord");
          3:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Ord. Cnfrmn.");
          4:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Invoices");
          5:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Shpt. Note");
          6:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Cr. Memo");
          7:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Statement");
          8:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Rmdr.");
          9:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Serv Ord Create");
          10:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Serv Ord Post");
          11:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch. Quotes");
          12:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch Blnkt Ord");
          13:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch. Orders");
          14:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch Invoices");
          15:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch. Rcpt.");
          16:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch Cr Memos");
          17:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Cover Sheets");
          18:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Return Order");
          19:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Finance Charge Memo");
          20:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Sales Return Receipt");
          21:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch. Return Shipment");
          22:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Purch. Return Ord. Cnfrmn.");
          23:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Service Contract");
          24:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Service Contract Quote");
          25:
            InteractTmplSetupCaption := InteractionTmplSetup.FieldCaption("Service Quote");
        end;
        exit(InteractTmplSetupCaption);
    end;

    local procedure FindContactFromContBusRelation(LinkToTable: Option;AccountNo: Code[20]): Code[20]
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        with ContBusRel do begin
          SetRange("Link to Table",LinkToTable);
          SetRange("No.",AccountNo);
          if FindFirst then
            exit("Contact No.");
        end;
    end;

    [Scope('Personalization')]
    procedure CreateCampaignEntryOnSalesInvoicePosting(SalesInvHeader: Record "Sales Invoice Header")
    var
        Campaign: Record Campaign;
        CampaignTargetGr: Record "Campaign Target Group";
        ContBusRel: Record "Contact Business Relation";
        InteractionLogEntry: Record "Interaction Log Entry";
        InteractTemplate: Record "Interaction Template";
        InteractionTemplateCode: Code[10];
        ContNo: Code[20];
    begin
        with SalesInvHeader do begin
          CampaignTargetGr.SetRange(Type,CampaignTargetGr.Type::Customer);
          CampaignTargetGr.SetRange("No.","Bill-to Customer No.");
          if not CampaignTargetGr.FindFirst then
            exit;

          Campaign.Get(CampaignTargetGr."Campaign No.");
          if ("Posting Date" < Campaign."Starting Date") or ("Posting Date" > Campaign."Ending Date") then
            exit;

          ContNo := FindContactFromContBusRelation(ContBusRel."Link to Table"::Customer,"Bill-to Customer No.");

          // Check if Interaction Log Entry already exist for initial Sales Order
          InteractionTemplateCode := FindInteractTmplCode(SalesInvoiceInterDocType);
          if InteractionTemplateCode = '' then
            Error(InterTemplateSalesInvoicesNotSpecifiedErr);
          InteractTemplate.Get(InteractionTemplateCode);
          InteractionLogEntry.SetRange("Contact No.",ContNo);
          InteractionLogEntry.SetRange("Document Type",SalesInvoiceInterDocType);
          InteractionLogEntry.SetRange("Document No.","Order No.");
          InteractionLogEntry.SetRange("Interaction Group Code",InteractTemplate."Interaction Group Code");
          if not InteractionLogEntry.IsEmpty then
            exit;

          LogDocument(
            SalesInvoiceInterDocType,"No.",0,0,DATABASE::Contact,"Bill-to Contact No.","Salesperson Code",
            CampaignTargetGr."Campaign No.","Posting Description",'');
        end;
    end;

    [Scope('Personalization')]
    procedure SalesOrderConfirmInterDocType(): Integer
    begin
        exit(3);
    end;

    [Scope('Personalization')]
    procedure SalesInvoiceInterDocType(): Integer
    begin
        exit(4);
    end;

    local procedure GetNextInteractionLogEntryNo(): Integer
    var
        [SecurityFiltering(SecurityFilter::Ignored)]InteractionLogEntry: Record "Interaction Log Entry";
    begin
        with InteractionLogEntry do begin
          LockTable;
          if FindLast then;
          exit("Entry No." + 1);
        end;
    end;

    local procedure GetNextLoggedSegmentEntryNo(): Integer
    var
        [SecurityFiltering(SecurityFilter::Ignored)]LoggedSegment: Record "Logged Segment";
    begin
        with LoggedSegment do begin
          LockTable;
          if FindLast then;
          exit("Entry No." + 1);
        end;
    end;

    local procedure GetNextCampaignEntryNo(): Integer
    var
        [SecurityFiltering(SecurityFilter::Ignored)]CampaignEntry: Record "Campaign Entry";
    begin
        with CampaignEntry do begin
          LockTable;
          if FindLast then;
          exit("Entry No." + 1);
        end;
    end;

    local procedure GetCampaignEntryNo(SegmentLine: Record "Segment Line";LoggedSegmentEntryNo: Integer): Integer
    var
        CampaignEntry: Record "Campaign Entry";
    begin
        CampaignEntry.SetCurrentKey("Campaign No.",Date,"Document Type");
        CampaignEntry.SetRange("Document Type",SegmentLine."Document Type");
        CampaignEntry.SetRange("Campaign No.",SegmentLine."Campaign No.");
        CampaignEntry.SetRange("Segment No.",SegmentLine."Segment No.");
        if CampaignEntry.FindFirst then
          exit(CampaignEntry."Entry No.");

        CampaignEntry.Reset;
        CampaignEntry.Init;
        CampaignEntry."Entry No." := GetNextCampaignEntryNo;
        if LoggedSegmentEntryNo <> 0 then
          CampaignEntry."Register No." := LoggedSegmentEntryNo;
        CopyFieldsToCampaignEntry(CampaignEntry,SegmentLine);
        CampaignEntry.Insert;
        exit(CampaignEntry."Entry No.");
    end;
}

