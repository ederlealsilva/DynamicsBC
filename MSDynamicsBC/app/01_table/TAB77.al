table 77 "Report Selections"
{
    // version NAVW113.00

    Caption = 'Report Selections';

    fields
    {
        field(1;Usage;Option)
        {
            Caption = 'Usage';
            OptionCaption = 'S.Quote,S.Order,S.Invoice,S.Cr.Memo,S.Test,P.Quote,P.Order,P.Invoice,P.Cr.Memo,P.Receipt,P.Ret.Shpt.,P.Test,B.Stmt,B.Recon.Test,B.Check,Reminder,Fin.Charge,Rem.Test,F.C.Test,Prod. Order,S.Blanket,P.Blanket,M1,M2,M3,M4,Inv1,Inv2,Inv3,SM.Quote,SM.Order,SM.Invoice,SM.Credit Memo,SM.Contract Quote,SM.Contract,SM.Test,S.Return,P.Return,S.Shipment,S.Ret.Rcpt.,S.Work Order,Invt. Period Test,SM.Shipment,S.Test Prepmt.,P.Test Prepmt.,S.Arch. Quote,S.Arch. Order,P.Arch. Quote,P.Arch. Order,S. Arch. Return Order,P. Arch. Return Order,Asm. Order,P.Assembly Order,S.Order Pick Instruction,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,C.Statement,V.Remittance,JQ,S.Invoice Draft,Pro Forma S. Invoice,S. Arch. Blanket Order,P. Arch. Blanket Order';
            OptionMembers = "S.Quote","S.Order","S.Invoice","S.Cr.Memo","S.Test","P.Quote","P.Order","P.Invoice","P.Cr.Memo","P.Receipt","P.Ret.Shpt.","P.Test","B.Stmt","B.Recon.Test","B.Check",Reminder,"Fin.Charge","Rem.Test","F.C.Test","Prod. Order","S.Blanket","P.Blanket",M1,M2,M3,M4,Inv1,Inv2,Inv3,"SM.Quote","SM.Order","SM.Invoice","SM.Credit Memo","SM.Contract Quote","SM.Contract","SM.Test","S.Return","P.Return","S.Shipment","S.Ret.Rcpt.","S.Work Order","Invt. Period Test","SM.Shipment","S.Test Prepmt.","P.Test Prepmt.","S.Arch. Quote","S.Arch. Order","P.Arch. Quote","P.Arch. Order","S. Arch. Return Order","P. Arch. Return Order","Asm. Order","P.Assembly Order","S.Order Pick Instruction",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"C.Statement","V.Remittance",JQ,"S.Invoice Draft","Pro Forma S. Invoice","S. Arch. Blanket Order","P. Arch. Blanket Order";
        }
        field(2;Sequence;Code[10])
        {
            Caption = 'Sequence';
            Numeric = true;
        }
        field(3;"Report ID";Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Report Caption");
                Validate("Use for Email Body",false);
            end;
        }
        field(4;"Report Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Report ID")));
            Caption = 'Report Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7;"Custom Report Layout Code";Code[20])
        {
            Caption = 'Custom Report Layout Code';
            Editable = false;
            TableRelation = "Custom Report Layout".Code WHERE (Code=FIELD("Custom Report Layout Code"));
        }
        field(19;"Use for Email Attachment";Boolean)
        {
            Caption = 'Use for Email Attachment';
            InitValue = true;

            trigger OnValidate()
            begin
                if not "Use for Email Body" then
                  Validate("Email Body Layout Code",'');
            end;
        }
        field(20;"Use for Email Body";Boolean)
        {
            Caption = 'Use for Email Body';

            trigger OnValidate()
            begin
                if not "Use for Email Body" then
                  Validate("Email Body Layout Code",'');
            end;
        }
        field(21;"Email Body Layout Code";Code[20])
        {
            Caption = 'Email Body Layout Code';
            TableRelation = IF ("Email Body Layout Type"=CONST("Custom Report Layout")) "Custom Report Layout".Code WHERE (Code=FIELD("Email Body Layout Code"),
                                                                                                                           "Report ID"=FIELD("Report ID"))
                                                                                                                           ELSE IF ("Email Body Layout Type"=CONST("HTML Layout")) "O365 HTML Template".Code;

            trigger OnValidate()
            begin
                if "Email Body Layout Code" <> '' then
                  TestField("Use for Email Body",true);
                CalcFields("Email Body Layout Description");
            end;
        }
        field(22;"Email Body Layout Description";Text[250])
        {
            CalcFormula = Lookup("Custom Report Layout".Description WHERE (Code=FIELD("Email Body Layout Code")));
            Caption = 'Email Body Layout Description';
            Editable = false;
            FieldClass = FlowField;

            trigger OnLookup()
            var
                CustomReportLayout: Record "Custom Report Layout";
            begin
                if "Email Body Layout Type" = "Email Body Layout Type"::"Custom Report Layout" then
                  if CustomReportLayout.LookupLayoutOK("Report ID") then
                    Validate("Email Body Layout Code",CustomReportLayout.Code);
            end;
        }
        field(25;"Email Body Layout Type";Option)
        {
            Caption = 'Email Body Layout Type';
            OptionCaption = 'Custom Report Layout,HTML Layout';
            OptionMembers = "Custom Report Layout","HTML Layout";
        }
    }

    keys
    {
        key(Key1;Usage,Sequence)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("Report ID");
        CheckEmailBodyUsage;
    end;

    trigger OnModify()
    begin
        TestField("Report ID");
        CheckEmailBodyUsage;
    end;

    var
        ReportSelection2: Record "Report Selections";
        MustSelectAndEmailBodyOrAttahmentErr: Label 'You must select an email body or attachment in report selection for %1.', Comment='%1 = Usage, for example Sales Invoice';
        EmailBodyIsAlreadyDefinedErr: Label 'An email body is already defined for %1.', Comment='%1 = Usage, for example Sales Invoice';
        CannotBeUsedAsAnEmailBodyErr: Label 'Report %1 uses the %2 which cannot be used as an email body.', Comment='%1 = Report ID,%2 = Type';
        ReportLayoutSelection: Record "Report Layout Selection";
        OneRecordWillBeSentQst: Label 'Only the first of the selected documents can be scheduled in the job queue.\\Do you want to continue?';

    [Scope('Personalization')]
    procedure NewRecord()
    begin
        ReportSelection2.SetRange(Usage,Usage);
        if ReportSelection2.FindLast and (ReportSelection2.Sequence <> '') then
          Sequence := IncStr(ReportSelection2.Sequence)
        else
          Sequence := '1';
    end;

    local procedure CheckEmailBodyUsage()
    var
        ReportSelections: Record "Report Selections";
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if "Use for Email Body" then begin
          ReportSelections.FilterEmailBodyUsage(Usage);
          ReportSelections.SetFilter(Sequence,'<>%1',Sequence);
          if not ReportSelections.IsEmpty then
            Error(EmailBodyIsAlreadyDefinedErr,Usage);

          if "Email Body Layout Code" = '' then
            if ReportLayoutSelection.GetDefaultType("Report ID") =
               ReportLayoutSelection.Type::"RDLC (built-in)"
            then
              Error(CannotBeUsedAsAnEmailBodyErr,"Report ID",ReportLayoutSelection.Type);
        end;
    end;

    [Scope('Personalization')]
    procedure FilterPrintUsage(ReportUsage: Integer)
    begin
        Reset;
        SetRange(Usage,ReportUsage);
    end;

    [Scope('Personalization')]
    procedure FilterEmailUsage(ReportUsage: Integer)
    begin
        Reset;
        SetRange(Usage,ReportUsage);
        SetRange("Use for Email Body",true);
    end;

    [Scope('Personalization')]
    procedure FilterEmailBodyUsage(ReportUsage: Integer)
    begin
        Reset;
        SetRange(Usage,ReportUsage);
        SetRange("Use for Email Body",true);
    end;

    [Scope('Personalization')]
    procedure FilterEmailAttachmentUsage(ReportUsage: Integer)
    begin
        Reset;
        SetRange(Usage,ReportUsage);
        SetRange("Use for Email Attachment",true);
    end;

    [Scope('Personalization')]
    procedure FindPrintUsage(ReportUsage: Integer;CustNo: Code[20];var ReportSelections: Record "Report Selections")
    begin
        FindPrintUsageInternal(ReportUsage,CustNo,ReportSelections,DATABASE::Customer);
    end;

    [Scope('Personalization')]
    procedure FindPrintUsageVendor(ReportUsage: Integer;VendorNo: Code[20];var ReportSelections: Record "Report Selections")
    begin
        FindPrintUsageInternal(ReportUsage,VendorNo,ReportSelections,DATABASE::Vendor);
    end;

    local procedure FindPrintUsageInternal(ReportUsage: Integer;AccountNo: Code[20];var ReportSelections: Record "Report Selections";TableNo: Integer)
    begin
        FilterPrintUsage(ReportUsage);
        SetFilter("Report ID",'<>0');

        FindReportSelections(ReportSelections,AccountNo,TableNo);
        ReportSelections.FindSet;
    end;

    [Scope('Personalization')]
    procedure FindEmailAttachmentUsage(ReportUsage: Integer;CustNo: Code[20];var ReportSelections: Record "Report Selections"): Boolean
    begin
        FilterEmailAttachmentUsage(ReportUsage);
        SetFilter("Report ID",'<>0');
        SetRange("Use for Email Attachment",true);

        FindReportSelections(ReportSelections,CustNo,DATABASE::Customer);
        exit(ReportSelections.FindSet);
    end;

    [Scope('Personalization')]
    procedure FindEmailAttachmentUsageVendor(ReportUsage: Integer;VendorNo: Code[20];var ReportSelections: Record "Report Selections"): Boolean
    begin
        FilterEmailAttachmentUsage(ReportUsage);
        SetFilter("Report ID",'<>0');
        SetRange("Use for Email Attachment",true);

        FindReportSelections(ReportSelections,VendorNo,DATABASE::Vendor);
        exit(ReportSelections.FindSet);
    end;

    [Scope('Personalization')]
    procedure FindEmailBodyUsage(ReportUsage: Integer;CustNo: Code[20];var ReportSelections: Record "Report Selections"): Boolean
    begin
        FilterEmailBodyUsage(ReportUsage);
        SetFilter("Report ID",'<>0');

        FindReportSelections(ReportSelections,CustNo,DATABASE::Customer);
        exit(ReportSelections.FindSet);
    end;

    [Scope('Personalization')]
    procedure FindEmailBodyUsageVendor(ReportUsage: Integer;VendorNo: Code[20];var ReportSelections: Record "Report Selections"): Boolean
    begin
        FilterEmailBodyUsage(ReportUsage);
        SetFilter("Report ID",'<>0');

        FindReportSelections(ReportSelections,VendorNo,DATABASE::Vendor);
        exit(ReportSelections.FindSet);
    end;

    [Scope('Personalization')]
    procedure PrintWithCheck(ReportUsage: Integer;RecordVariant: Variant;CustomerNoFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrintWithCheck(ReportUsage,RecordVariant,CustomerNoFieldNo,Handled);
        if Handled then
          exit;

        PrintWithGUIYesNoWithCheck(ReportUsage,RecordVariant,true,CustomerNoFieldNo);
    end;

    [Scope('Personalization')]
    procedure PrintWithGUIYesNoWithCheck(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;CustomerNoFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrintWithGUIYesNoWithCheck(ReportUsage,RecordVariant,IsGUI,CustomerNoFieldNo,Handled);
        if Handled then
          exit;

        PrintDocumentsWithCheckGUIYesNoCommon(ReportUsage,RecordVariant,IsGUI,CustomerNoFieldNo,true,DATABASE::Customer);
    end;

    [Scope('Personalization')]
    procedure PrintWithGUIYesNoWithCheckVendor(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;VendorNoFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrintWithGUIYesNoWithCheckVendor(ReportUsage,RecordVariant,IsGUI,VendorNoFieldNo,Handled);
        if Handled then
          exit;

        PrintDocumentsWithCheckGUIYesNoCommon(ReportUsage,RecordVariant,IsGUI,VendorNoFieldNo,true,DATABASE::Vendor);
    end;

    [Scope('Personalization')]
    procedure Print(ReportUsage: Integer;RecordVariant: Variant;CustomerNoFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrint(ReportUsage,RecordVariant,CustomerNoFieldNo,Handled);
        if Handled then
          exit;

        PrintWithGUIYesNo(ReportUsage,RecordVariant,true,CustomerNoFieldNo);
    end;

    [Scope('Personalization')]
    procedure PrintWithGUIYesNo(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;CustomerNoFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrintWithGUIYesNo(ReportUsage,RecordVariant,IsGUI,CustomerNoFieldNo,Handled);
        if Handled then
          exit;

        PrintDocumentsWithCheckGUIYesNoCommon(ReportUsage,RecordVariant,IsGUI,CustomerNoFieldNo,false,DATABASE::Customer);
    end;

    [Scope('Personalization')]
    procedure PrintWithGUIYesNoVendor(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;VendorNoFieldNo: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrintWithGUIYesNoVendor(ReportUsage,RecordVariant,IsGUI,VendorNoFieldNo,Handled);
        if Handled then
          exit;

        PrintDocumentsWithCheckGUIYesNoCommon(ReportUsage,RecordVariant,IsGUI,VendorNoFieldNo,false,DATABASE::Vendor);
    end;

    local procedure PrintDocumentsWithCheckGUIYesNoCommon(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;AccountNoFieldNo: Integer;WithCheck: Boolean;TableNo: Integer)
    var
        TempReportSelections: Record "Report Selections" temporary;
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        RecRef: RecordRef;
        RecRefToPrint: RecordRef;
        RecVarToPrint: Variant;
        AccountNoFilter: Text;
    begin
        OnBeforeSetReportLayout(RecordVariant);

        RecRef.GetTable(RecordVariant);
        GetUniqueAccountNos(TempNameValueBuffer,RecRef,AccountNoFieldNo);

        SelectTempReportSelectionsToPrint(TempReportSelections,TempNameValueBuffer,WithCheck,ReportUsage,TableNo);

        if TempReportSelections.FindSet then
          repeat
            if TempReportSelections."Custom Report Layout Code" <> '' then
              ReportLayoutSelection.SetTempLayoutSelected(TempReportSelections."Custom Report Layout Code")
            else
              ReportLayoutSelection.SetTempLayoutSelected('');

            TempNameValueBuffer.FindSet;
            AccountNoFilter := GetAccountNoFilterForCustomReportLayout(TempReportSelections,TempNameValueBuffer,TableNo);
            GetFilteredRecordRef(RecRefToPrint,RecRef,AccountNoFieldNo,AccountNoFilter);
            RecVarToPrint := RecRefToPrint;

            REPORT.RunModal(TempReportSelections."Report ID",IsGUI,false,RecVarToPrint);

            ReportLayoutSelection.SetTempLayoutSelected('');
          until TempReportSelections.Next = 0;
    end;

    local procedure GetFilteredRecordRef(var RecRefToPrint: RecordRef;RecRefSource: RecordRef;AccountNoFieldNo: Integer;AccountNoFilter: Text)
    var
        AccountNoFieldRef: FieldRef;
        CurrentFilterGroup: Integer;
    begin
        RecRefToPrint := RecRefSource.Duplicate;

        if (AccountNoFieldNo <> 0) and (AccountNoFilter <> '') then begin
          CurrentFilterGroup := RecRefToPrint.FilterGroup;
          RecRefToPrint.FilterGroup(10);
          AccountNoFieldRef := RecRefToPrint.Field(AccountNoFieldNo);
          AccountNoFieldRef.SetFilter(AccountNoFilter);
          RecRefToPrint.FilterGroup(CurrentFilterGroup);
        end;

        if RecRefToPrint.FindSet then;
    end;

    local procedure GetAccountNoFilterForCustomReportLayout(var TempReportSelections: Record "Report Selections" temporary;var TempNameValueBuffer: Record "Name/Value Buffer" temporary;TableNo: Integer): Text
    var
        CustomReportSelection: Record "Custom Report Selection";
        AccountNo: Code[20];
        AccountNoFilter: Text;
        AccountHasCustomSelection: Boolean;
        ReportInvolvedInCustomSelection: Boolean;
    begin
        CustomReportSelection.SetRange("Source Type",TableNo);
        CustomReportSelection.SetRange(Usage,TempReportSelections.Usage);
        CustomReportSelection.SetRange("Report ID",TempReportSelections."Report ID");

        ReportInvolvedInCustomSelection := not CustomReportSelection.IsEmpty;

        AccountNoFilter := '';

        TempNameValueBuffer.FindSet;
        repeat
          AccountNo := CopyStr(TempNameValueBuffer.Name,1,MaxStrLen(AccountNo));
          CustomReportSelection.SetRange("Source No.",AccountNo);

          if ReportInvolvedInCustomSelection then begin
            CustomReportSelection.SetRange("Custom Report Layout Code",TempReportSelections."Custom Report Layout Code");

            AccountHasCustomSelection := not CustomReportSelection.IsEmpty;
            if AccountHasCustomSelection then
              AccountNoFilter += AccountNo + '|';

            CustomReportSelection.SetRange("Custom Report Layout Code");
          end else begin
            CustomReportSelection.SetRange("Report ID");

            AccountHasCustomSelection := not CustomReportSelection.IsEmpty;
            if not AccountHasCustomSelection then
              AccountNoFilter += AccountNo + '|';

            CustomReportSelection.SetRange("Report ID",TempReportSelections."Report ID");
          end;

        until TempNameValueBuffer.Next = 0;

        AccountNoFilter := DelChr(AccountNoFilter,'>','|');
        exit(AccountNoFilter);
    end;

    local procedure SelectTempReportSelections(var TempReportSelections: Record "Report Selections" temporary;AccountNo: Code[20];WithCheck: Boolean;ReportUsage: Option;TableNo: Integer)
    begin
        if WithCheck then begin
          FilterPrintUsage(ReportUsage);
          FindReportSelections(TempReportSelections,AccountNo,TableNo);
          if not TempReportSelections.FindSet then
            FindSet;
        end else
          FindPrintUsageInternal(ReportUsage,AccountNo,TempReportSelections,TableNo);
    end;

    local procedure SelectTempReportSelectionsToPrint(var TempReportSelections: Record "Report Selections" temporary;var TempNameValueBuffer: Record "Name/Value Buffer" temporary;WithCheck: Boolean;ReportUsage: Option;TableNo: Integer)
    var
        TempReportSelectionsAccount: Record "Report Selections" temporary;
        AccountNo: Code[20];
        LastSequence: Code[10];
    begin
        if TempNameValueBuffer.FindSet then
          repeat
            AccountNo := CopyStr(TempNameValueBuffer.Name,1,MaxStrLen(AccountNo));
            TempReportSelectionsAccount.Reset;
            TempReportSelectionsAccount.DeleteAll;
            SelectTempReportSelections(TempReportSelectionsAccount,AccountNo,WithCheck,ReportUsage,TableNo);
            if TempReportSelectionsAccount.FindSet then
              repeat
                LastSequence := GetLastSequenceNo(TempReportSelections,ReportUsage);
                if not HasReportWithUsage(TempReportSelections,ReportUsage,TempReportSelectionsAccount."Report ID") then begin
                  TempReportSelections := TempReportSelectionsAccount;
                  if LastSequence = '' then
                    TempReportSelections.Sequence := '1'
                  else
                    TempReportSelections.Sequence := IncStr(LastSequence);
                  TempReportSelections.Insert;
                end;
              until TempReportSelectionsAccount.Next = 0;
          until TempNameValueBuffer.Next = 0;
    end;

    procedure GetHtmlReport(var ServerEmailBodyFilePath: Text[250];ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20])
    var
        TempBodyReportSelections: Record "Report Selections" temporary;
    begin
        ServerEmailBodyFilePath := '';

        FindPrintUsage(ReportUsage,CustNo,TempBodyReportSelections);

        ServerEmailBodyFilePath :=
          SaveReportAsHTML(TempBodyReportSelections."Report ID",RecordVariant,TempBodyReportSelections."Custom Report Layout Code");
    end;

    procedure GetPdfReport(var ServerEmailBodyFilePath: Text[250];ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20])
    var
        TempBodyReportSelections: Record "Report Selections" temporary;
    begin
        ServerEmailBodyFilePath := '';

        FindPrintUsage(ReportUsage,CustNo,TempBodyReportSelections);

        ServerEmailBodyFilePath :=
          SaveReportAsPDF(TempBodyReportSelections."Report ID",RecordVariant,TempBodyReportSelections."Custom Report Layout Code");
    end;

    procedure GetEmailBodyInPdf(var ServerEmailBodyFilePath: Text[250];ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20];var CustEmailAddress: Text[250]): Boolean
    var
        TempBodyReportSelections: Record "Report Selections" temporary;
    begin
        ServerEmailBodyFilePath := '';

        CustEmailAddress := GetEmailAddressIgnoringLayout(ReportUsage,RecordVariant,CustNo);

        if not FindEmailBodyUsage(ReportUsage,CustNo,TempBodyReportSelections) then
          exit(false);

        ServerEmailBodyFilePath :=
          SaveReportAsPDF(TempBodyReportSelections."Report ID",RecordVariant,TempBodyReportSelections."Email Body Layout Code");

        CustEmailAddress := GetEmailAddress(ReportUsage,RecordVariant,CustNo,TempBodyReportSelections);

        exit(true);
    end;

    procedure GetEmailBody(var ServerEmailBodyFilePath: Text[250];ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20];var CustEmailAddress: Text[250]): Boolean
    begin
        exit(GetEmailBodyCustomText(ServerEmailBodyFilePath,ReportUsage,RecordVariant,CustNo,CustEmailAddress,''));
    end;

    procedure GetEmailBodyCustomText(var ServerEmailBodyFilePath: Text[250];ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20];var CustEmailAddress: Text[250];EmailBodyText: Text): Boolean
    var
        TempBodyReportSelections: Record "Report Selections" temporary;
        O365HTMLTemplMgt: Codeunit "O365 HTML Templ. Mgt.";
    begin
        ServerEmailBodyFilePath := '';

        OnBeforeGetEmailBodyCustomer;

        if CustEmailAddress = '' then
          CustEmailAddress := GetEmailAddressIgnoringLayout(ReportUsage,RecordVariant,CustNo);

        if not FindEmailBodyUsage(ReportUsage,CustNo,TempBodyReportSelections) then
          exit(false);

        case "Email Body Layout Type" of
          "Email Body Layout Type"::"Custom Report Layout":
            ServerEmailBodyFilePath :=
              SaveReportAsHTML(TempBodyReportSelections."Report ID",RecordVariant,TempBodyReportSelections."Email Body Layout Code");
          "Email Body Layout Type"::"HTML Layout":
            ServerEmailBodyFilePath :=
              O365HTMLTemplMgt.CreateEmailBodyFromReportSelections(Rec,RecordVariant,CustEmailAddress,EmailBodyText);
        end;

        CustEmailAddress := GetEmailAddress(ReportUsage,RecordVariant,CustNo,TempBodyReportSelections);

        OnAfterGetEmailBodyCustomer(CustEmailAddress,ServerEmailBodyFilePath);

        exit(true);
    end;

    local procedure GetEmailAddressIgnoringLayout(ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20]): Text[250]
    var
        TempBodyReportSelections: Record "Report Selections" temporary;
        EmailAddress: Text[250];
    begin
        EmailAddress := GetEmailAddress(ReportUsage,RecordVariant,CustNo,TempBodyReportSelections);
        exit(EmailAddress);
    end;

    local procedure GetEmailAddress(ReportUsage: Integer;RecordVariant: Variant;CustNo: Code[20];var TempBodyReportSelections: Record "Report Selections" temporary): Text[250]
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        DocumentNo: Code[20];
        EmailAddress: Text[250];
    begin
        RecordRef.GetTable(RecordVariant);
        if not RecordRef.IsEmpty then
          if DataTypeManagement.FindFieldByName(RecordRef,FieldRef,'No.') then begin
            DocumentNo := FieldRef.Value;
            EmailAddress := GetDocumentEmailAddress(DocumentNo,ReportUsage);
            if EmailAddress <> '' then
              exit(EmailAddress);
          end;

        if not TempBodyReportSelections.IsEmpty then begin
          EmailAddress :=
            FindEmailAddressForEmailLayout(TempBodyReportSelections."Email Body Layout Code",CustNo,ReportUsage,DATABASE::Customer);
          if EmailAddress <> '' then
            exit(EmailAddress);
        end;

        EmailAddress := GetCustEmailAddress(CustNo,ReportUsage);
        exit(EmailAddress);
    end;

    procedure GetEmailBodyVendor(var ServerEmailBodyFilePath: Text[250];ReportUsage: Integer;RecordVariant: Variant;VendorNo: Code[20];var VendorEmailAddress: Text[250]): Boolean
    var
        TempBodyReportSelections: Record "Report Selections" temporary;
        FoundVendorEmailAddress: Text[250];
    begin
        ServerEmailBodyFilePath := '';

        OnBeforeGetEmailBodyVendor;

        VendorEmailAddress := GetVendorEmailAddress(VendorNo,RecordVariant,ReportUsage);

        if not FindEmailBodyUsageVendor(ReportUsage,VendorNo,TempBodyReportSelections) then
          exit(false);

        ServerEmailBodyFilePath :=
          SaveReportAsHTML(TempBodyReportSelections."Report ID",RecordVariant,TempBodyReportSelections."Email Body Layout Code");

        FoundVendorEmailAddress :=
          FindEmailAddressForEmailLayout(TempBodyReportSelections."Email Body Layout Code",VendorNo,ReportUsage,DATABASE::Vendor);
        if FoundVendorEmailAddress <> '' then
          VendorEmailAddress := FoundVendorEmailAddress;

        OnAfterGetEmailBodyVendor(VendorEmailAddress,ServerEmailBodyFilePath);

        exit(true);
    end;

    procedure SendEmailInBackground(JobQueueEntry: Record "Job Queue Entry")
    var
        RecRef: RecordRef;
        ReportUsage: Integer;
        DocNo: Code[20];
        DocName: Text[150];
        No: Code[20];
        ParamString: Text;
    begin
        // Called from codeunit 260 OnRun trigger - in a background process.
        RecRef.Get(JobQueueEntry."Record ID to Process");
        RecRef.LockTable;
        RecRef.Find;
        RecRef.SetRecFilter;
        ParamString := JobQueueEntry."Parameter String";  // Are set in function SendEmailToCust
        GetJobQueueParameters(ParamString,ReportUsage,DocNo,DocName,No);

        if ParamString = 'Vendor' then
          SendEmailToVendorDirectly(ReportUsage,RecRef,DocNo,DocName,false,No)
        else
          SendEmailToCustDirectly(ReportUsage,RecRef,DocNo,DocName,false,No);
    end;

    procedure GetJobQueueParameters(var ParameterString: Text;var ReportUsage: Integer;var DocNo: Code[20];var DocName: Text[150];var CustNo: Code[20]) WasSuccessful: Boolean
    begin
        WasSuccessful := Evaluate(ReportUsage,GetNextJobQueueParam(ParameterString));
        WasSuccessful := WasSuccessful and Evaluate(DocNo,GetNextJobQueueParam(ParameterString));
        WasSuccessful := WasSuccessful and Evaluate(DocName,GetNextJobQueueParam(ParameterString));
        WasSuccessful := WasSuccessful and Evaluate(CustNo,GetNextJobQueueParam(ParameterString));
    end;

    local procedure GetNextJobQueueParam(var Parameter: Text): Text
    var
        i: Integer;
        Result: Text;
    begin
        i := StrPos(Parameter,'|');
        if i > 0 then
          Result := CopyStr(Parameter,1,i - 1);
        if (i + 1) < StrLen(Parameter) then
          Parameter := CopyStr(Parameter,i + 1);
        exit(Result);
    end;

    procedure SendEmailToCust(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];ShowDialog: Boolean;CustNo: Code[20])
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
        JobQueueEntry: Record "Job Queue Entry";
        GraphMail: Codeunit "Graph Mail";
        SMTPMail: Codeunit "SMTP Mail";
        OfficeMgt: Codeunit "Office Management";
        RecRef: RecordRef;
        UpdateDocumentSentHistory: Boolean;
        Handled: Boolean;
    begin
        OnBeforeSendEmailToCust(ReportUsage,RecordVariant,DocNo,DocName,ShowDialog,CustNo,Handled);
        if Handled then
          exit;

        RecRef.GetTable(RecordVariant);

        if GraphMail.IsEnabled and GraphMail.HasConfiguration then begin
          if O365DocumentSentHistory.NewInProgressFromRecRef(RecRef) then begin
            O365DocumentSentHistory.SetStatusAsFailed;
            UpdateDocumentSentHistory := true;
          end;

          if SendEmailToCustDirectly(ReportUsage,RecordVariant,DocNo,DocName,ShowDialog,CustNo) and UpdateDocumentSentHistory then
            O365DocumentSentHistory.SetStatusAsSuccessfullyFinished;

          exit;
        end;

        if ShowDialog or
           (not SMTPMail.IsEnabled) or
           (GetEmailAddressIgnoringLayout(ReportUsage,RecordVariant,CustNo) = '') or
           OfficeMgt.IsAvailable
        then begin
          SendEmailToCustDirectly(ReportUsage,RecordVariant,DocNo,DocName,true,CustNo);
          exit;
        end;

        RecRef.GetTable(RecordVariant);
        if RecordsCanBeSent(RecRef) then begin
          JobQueueEntry.Init;
          JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
          JobQueueEntry."Object ID to Run" := CODEUNIT::"Document-Mailing";
          JobQueueEntry."Maximum No. of Attempts to Run" := 3;
          JobQueueEntry."Record ID to Process" := RecRef.RecordId;
          JobQueueEntry."Parameter String" := StrSubstNo('%1|%2|%3|%4|',ReportUsage,DocNo,DocName,CustNo);
          JobQueueEntry.Description := CopyStr(DocName,1,MaxStrLen(JobQueueEntry.Description));
          CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry);
        end;
    end;

    procedure SendEmailToVendor(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];ShowDialog: Boolean;VendorNo: Code[20])
    var
        O365DocumentSentHistory: Record "O365 Document Sent History";
        JobQueueEntry: Record "Job Queue Entry";
        GraphMail: Codeunit "Graph Mail";
        SMTPMail: Codeunit "SMTP Mail";
        OfficeMgt: Codeunit "Office Management";
        RecRef: RecordRef;
        VendorEmail: Text[250];
        UpdateDocumentSentHistory: Boolean;
        Handled: Boolean;
    begin
        OnBeforeSendEmailToVendor(ReportUsage,RecordVariant,DocNo,DocName,ShowDialog,VendorNo,Handled);
        if Handled then
          exit;

        RecRef.GetTable(RecordVariant);

        if GraphMail.IsEnabled and GraphMail.HasConfiguration then begin
          if O365DocumentSentHistory.NewInProgressFromRecRef(RecRef) then begin
            O365DocumentSentHistory.SetStatusAsFailed;
            UpdateDocumentSentHistory := true;
          end;

          if SendEmailToVendorDirectly(ReportUsage,RecordVariant,DocNo,DocName,ShowDialog,VendorNo) and UpdateDocumentSentHistory then
            O365DocumentSentHistory.SetStatusAsSuccessfullyFinished;

          exit;
        end;

        VendorEmail := GetVendorEmailAddress(VendorNo,RecordVariant,ReportUsage);
        if ShowDialog or not SMTPMail.IsEnabled or (VendorEmail = '') or OfficeMgt.IsAvailable then begin
          SendEmailToVendorDirectly(ReportUsage,RecordVariant,DocNo,DocName,true,VendorNo);
          exit;
        end;

        JobQueueEntry.Init;
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"Document-Mailing";
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Record ID to Process" := RecRef.RecordId;
        JobQueueEntry."Parameter String" := StrSubstNo('%1|%2|%3|%4|%5',ReportUsage,DocNo,DocName,VendorNo,'Vendor');
        JobQueueEntry.Description := CopyStr(DocName,1,MaxStrLen(JobQueueEntry.Description));
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue",JobQueueEntry);
    end;

    local procedure SendEmailToCustDirectly(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];ShowDialog: Boolean;CustNo: Code[20]): Boolean
    var
        TempAttachReportSelections: Record "Report Selections" temporary;
        CustomReportSelection: Record "Custom Report Selection";
        EmailParameter: Record "Email Parameter";
        MailManagement: Codeunit "Mail Management";
        FoundBody: Boolean;
        FoundAttachment: Boolean;
        ServerEmailBodyFilePath: Text[250];
        EmailAddress: Text[250];
        EmailBodyText: Text;
    begin
        if EmailParameter.GetEntryWithReportUsage(DocNo,ReportUsage,EmailParameter."Parameter Type"::Body) then
          EmailBodyText := EmailParameter.GetParameterValue;

        OnBeforeSetReportLayout(RecordVariant);
        BindSubscription(MailManagement);
        FoundBody := GetEmailBodyCustomText(ServerEmailBodyFilePath,ReportUsage,RecordVariant,CustNo,EmailAddress,EmailBodyText);
        UnbindSubscription(MailManagement);
        FoundAttachment := FindEmailAttachmentUsage(ReportUsage,CustNo,TempAttachReportSelections);

        CustomReportSelection.SetRange("Source Type",DATABASE::Customer);
        CustomReportSelection.SetFilter("Source No.",CustNo);
        exit(SendEmailDirectly(
            ReportUsage,RecordVariant,DocNo,DocName,FoundBody,FoundAttachment,ServerEmailBodyFilePath,EmailAddress,ShowDialog,
            TempAttachReportSelections,CustomReportSelection));
    end;

    local procedure SendEmailToVendorDirectly(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];ShowDialog: Boolean;VendorNo: Code[20]): Boolean
    var
        TempAttachReportSelections: Record "Report Selections" temporary;
        CustomReportSelection: Record "Custom Report Selection";
        MailManagement: Codeunit "Mail Management";
        FoundBody: Boolean;
        FoundAttachment: Boolean;
        ServerEmailBodyFilePath: Text[250];
        EmailAddress: Text[250];
    begin
        OnBeforeSetReportLayout(RecordVariant);
        BindSubscription(MailManagement);
        FoundBody := GetEmailBodyVendor(ServerEmailBodyFilePath,ReportUsage,RecordVariant,VendorNo,EmailAddress);
        UnbindSubscription(MailManagement);
        FoundAttachment := FindEmailAttachmentUsageVendor(ReportUsage,VendorNo,TempAttachReportSelections);

        CustomReportSelection.SetRange("Source Type",DATABASE::Vendor);
        CustomReportSelection.SetFilter("Source No.",VendorNo);
        exit(SendEmailDirectly(
            ReportUsage,RecordVariant,DocNo,DocName,FoundBody,FoundAttachment,ServerEmailBodyFilePath,EmailAddress,ShowDialog,
            TempAttachReportSelections,CustomReportSelection));
    end;

    local procedure SendEmailDirectly(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];FoundBody: Boolean;FoundAttachment: Boolean;ServerEmailBodyFilePath: Text[250];var DefaultEmailAddress: Text[250];ShowDialog: Boolean;var TempAttachReportSelections: Record "Report Selections" temporary;var CustomReportSelection: Record "Custom Report Selection") AllEmailsWereSuccessful: Boolean
    var
        DocumentMailing: Codeunit "Document-Mailing";
        OfficeAttachmentManager: Codeunit "Office Attachment Manager";
        ServerAttachmentFilePath: Text[250];
        EmailAddress: Text[250];
    begin
        AllEmailsWereSuccessful := true;

        ShowNoBodyNoAttachmentError(ReportUsage,FoundBody,FoundAttachment);

        if FoundBody and not FoundAttachment then
          AllEmailsWereSuccessful :=
            DocumentMailing.EmailFile('','',ServerEmailBodyFilePath,DocNo,EmailAddress,DocName,not ShowDialog,ReportUsage);

        if FoundAttachment then begin
          if ReportUsage = Usage::JQ then begin
            Usage := ReportUsage;
            CustomReportSelection.SetFilter(Usage,GetFilter(Usage));
            if CustomReportSelection.FindFirst then
              if CustomReportSelection."Send To Email" <> '' then
                DefaultEmailAddress := CustomReportSelection."Send To Email";
          end;

          with TempAttachReportSelections do begin
            OfficeAttachmentManager.IncrementCount(Count - 1);
            repeat
              EmailAddress := CopyStr(
                  GetNextEmailAddressFromCustomReportSelection(CustomReportSelection,DefaultEmailAddress,Usage,Sequence),
                  1,MaxStrLen(EmailAddress));
              ServerAttachmentFilePath := SaveReportAsPDF("Report ID",RecordVariant,"Custom Report Layout Code");
              AllEmailsWereSuccessful := AllEmailsWereSuccessful and DocumentMailing.EmailFile(
                  ServerAttachmentFilePath,
                  '',
                  ServerEmailBodyFilePath,
                  DocNo,
                  EmailAddress,
                  DocName,
                  not ShowDialog,
                  ReportUsage);
            until Next = 0;
          end;
        end;

        exit(AllEmailsWereSuccessful);
    end;

    procedure SendToDisk(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text;CustNo: Code[20])
    var
        TempReportSelections: Record "Report Selections" temporary;
        ElectronicDocumentFormat: Record "Electronic Document Format";
        FileManagement: Codeunit "File Management";
        ServerAttachmentFilePath: Text[250];
        ClientAttachmentFileName: Text;
    begin
        OnBeforeSetReportLayout(RecordVariant);
        FindPrintUsage(ReportUsage,CustNo,TempReportSelections);
        with TempReportSelections do
          repeat
            ServerAttachmentFilePath := SaveReportAsPDF("Report ID",RecordVariant,"Custom Report Layout Code");
            ClientAttachmentFileName := ElectronicDocumentFormat.GetAttachmentFileName(DocNo,DocName,'pdf');

            FileManagement.DownloadHandler(
              ServerAttachmentFilePath,
              '',
              '',
              FileManagement.GetToFilterText('',ClientAttachmentFileName),
              ClientAttachmentFileName);
          until Next = 0;
    end;

    procedure SendToDiskVendor(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text;VendorNo: Code[20])
    var
        TempReportSelections: Record "Report Selections" temporary;
        ElectronicDocumentFormat: Record "Electronic Document Format";
        FileManagement: Codeunit "File Management";
        ServerAttachmentFilePath: Text[250];
        ClientAttachmentFileName: Text;
    begin
        OnBeforeSetReportLayout(RecordVariant);
        FindPrintUsageVendor(ReportUsage,VendorNo,TempReportSelections);
        with TempReportSelections do
          repeat
            ServerAttachmentFilePath := SaveReportAsPDF("Report ID",RecordVariant,"Custom Report Layout Code");
            ClientAttachmentFileName := ElectronicDocumentFormat.GetAttachmentFileName(DocNo,DocName,'pdf');

            FileManagement.DownloadHandler(
              ServerAttachmentFilePath,
              '',
              '',
              FileManagement.GetToFilterText('',ClientAttachmentFileName),
              ClientAttachmentFileName);
          until Next = 0;
    end;

    procedure SendToZip(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];CustNo: Code[20];var FileManagement: Codeunit "File Management")
    var
        TempReportSelections: Record "Report Selections" temporary;
        ElectronicDocumentFormat: Record "Electronic Document Format";
        ServerAttachmentFilePath: Text;
    begin
        OnBeforeSetReportLayout(RecordVariant);
        FindPrintUsage(ReportUsage,CustNo,TempReportSelections);
        with TempReportSelections do
          repeat
            ServerAttachmentFilePath := SaveReportAsPDF("Report ID",RecordVariant,"Custom Report Layout Code");
            FileManagement.AddFileToZipArchive(
              ServerAttachmentFilePath,
              ElectronicDocumentFormat.GetAttachmentFileName(DocNo,'Invoice','pdf'));
          until Next = 0;
    end;

    procedure SendToZipVendor(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];VendorNo: Code[20];var FileManagement: Codeunit "File Management")
    var
        TempReportSelections: Record "Report Selections" temporary;
        ElectronicDocumentFormat: Record "Electronic Document Format";
        ServerAttachmentFilePath: Text;
    begin
        OnBeforeSetReportLayout(RecordVariant);
        FindPrintUsageVendor(ReportUsage,VendorNo,TempReportSelections);
        with TempReportSelections do
          repeat
            ServerAttachmentFilePath := SaveReportAsPDF("Report ID",RecordVariant,"Custom Report Layout Code");
            FileManagement.AddFileToZipArchive(
              ServerAttachmentFilePath,
              ElectronicDocumentFormat.GetAttachmentFileName(DocNo,'Purchase Order','pdf'));
          until Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetDocumentEmailAddress(DocumentNo: Code[20];ReportUsage: Integer): Text[250]
    var
        EmailParameter: Record "Email Parameter";
        ToAddress: Text;
    begin
        if EmailParameter.GetEntryWithReportUsage(DocumentNo,ReportUsage,EmailParameter."Parameter Type"::Address) then
          ToAddress := EmailParameter.GetParameterValue;
        exit(ToAddress);
    end;

    [Scope('Personalization')]
    procedure GetCustEmailAddress(BillToCustomerNo: Code[20];ReportUsage: Option): Text[250]
    var
        Customer: Record Customer;
        Contact: Record Contact;
        ToAddress: Text;
        IsHandled: Boolean;
    begin
        OnBeforeGetCustEmailAddress(BillToCustomerNo,ToAddress,ReportUsage,IsHandled);
        if IsHandled then
          exit(ToAddress);

        if Customer.Get(BillToCustomerNo) then
          ToAddress := Customer."E-Mail"
        else
          if Contact.Get(BillToCustomerNo) then
            ToAddress := Contact."E-Mail";
        exit(ToAddress);
    end;

    [Scope('Personalization')]
    procedure GetVendorEmailAddress(BuyFromVendorNo: Code[20];RecVar: Variant;ReportUsage: Option): Text[250]
    var
        Vendor: Record Vendor;
        ToAddress: Text[250];
        IsHandled: Boolean;
    begin
        OnBeforeGetVendorEmailAddress(BuyFromVendorNo,ToAddress,ReportUsage,IsHandled);
        if IsHandled then
          exit(ToAddress);

        ToAddress := GetPurchaseOrderEmailAddress(BuyFromVendorNo,RecVar,ReportUsage);

        if ToAddress = '' then
          if Vendor.Get(BuyFromVendorNo) then
            ToAddress := Vendor."E-Mail";

        exit(ToAddress);
    end;

    local procedure GetPurchaseOrderEmailAddress(BuyFromVendorNo: Code[20];RecVar: Variant;ReportUsage: Option): Text[250]
    var
        PurchaseHeader: Record "Purchase Header";
        OrderAddress: Record "Order Address";
        RecRef: RecordRef;
    begin
        if BuyFromVendorNo = '' then
          exit('');

        if ReportUsage <> Usage::"P.Order" then
          exit('');

        RecRef.GetTable(RecVar);
        if RecRef.Number <> DATABASE::"Purchase Header" then
          exit('');

        PurchaseHeader := RecVar;
        if PurchaseHeader."Order Address Code" = '' then
          exit('');

        if not OrderAddress.Get(BuyFromVendorNo,PurchaseHeader."Order Address Code") then
          exit('');

        exit(OrderAddress."E-Mail");
    end;

    local procedure SaveReportAsPDF(ReportID: Integer;RecordVariant: Variant;LayoutCode: Code[20]) FilePath: Text[250]
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        FileMgt: Codeunit "File Management";
    begin
        OnBeforeSetReportLayout(RecordVariant);
        FilePath := CopyStr(FileMgt.ServerTempFileName('pdf'),1,250);

        ReportLayoutSelection.SetTempLayoutSelected(LayoutCode);
        REPORT.SaveAsPdf(ReportID,FilePath,RecordVariant);
        ReportLayoutSelection.SetTempLayoutSelected('');

        Commit;
    end;

    local procedure SaveReportAsHTML(ReportID: Integer;RecordVariant: Variant;LayoutCode: Code[20]) FilePath: Text[250]
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        FileMgt: Codeunit "File Management";
    begin
        OnBeforeSetReportLayout(RecordVariant);
        FilePath := CopyStr(FileMgt.ServerTempFileName('html'),1,250);

        ReportLayoutSelection.SetTempLayoutSelected(LayoutCode);
        REPORT.SaveAsHtml(ReportID,FilePath,RecordVariant);
        ReportLayoutSelection.SetTempLayoutSelected('');

        Commit;
    end;

    local procedure FindReportSelections(var ReportSelections: Record "Report Selections";AccountNo: Code[20];TableNo: Integer): Boolean
    var
        Handled: Boolean;
    begin
        if CopyCustomReportSectionToReportSelection(AccountNo,ReportSelections,TableNo) then
          exit(true);

        OnFindReportSelections(ReportSelections,Handled,Rec);
        if Handled then
          exit(true);

        exit(CopyReportSelectionToReportSelection(ReportSelections));
    end;

    local procedure CopyCustomReportSectionToReportSelection(AccountNo: Code[20];var ToReportSelections: Record "Report Selections";TableNo: Integer): Boolean
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        GetCustomReportSelectionByUsageFilter(CustomReportSelection,AccountNo,GetFilter(Usage),TableNo);
        CopyToReportSelection(ToReportSelections,CustomReportSelection);

        if not ToReportSelections.FindSet then
          exit(false);
        exit(true);
    end;

    local procedure CopyToReportSelection(var ToReportSelections: Record "Report Selections";var CustomReportSelection: Record "Custom Report Selection")
    begin
        ToReportSelections.Reset;
        ToReportSelections.DeleteAll;
        if CustomReportSelection.FindSet then
          repeat
            ToReportSelections.Usage := CustomReportSelection.Usage;
            ToReportSelections.Sequence := Format(CustomReportSelection.Sequence);
            ToReportSelections."Report ID" := CustomReportSelection."Report ID";
            ToReportSelections."Custom Report Layout Code" := CustomReportSelection."Custom Report Layout Code";
            ToReportSelections."Email Body Layout Code" := CustomReportSelection."Email Body Layout Code";
            ToReportSelections."Use for Email Attachment" := CustomReportSelection."Use for Email Attachment";
            ToReportSelections."Use for Email Body" := CustomReportSelection."Use for Email Body";
            ToReportSelections.Insert;
          until CustomReportSelection.Next = 0;
    end;

    local procedure CopyReportSelectionToReportSelection(var ToReportSelections: Record "Report Selections"): Boolean
    begin
        ToReportSelections.Reset;
        ToReportSelections.DeleteAll;
        if FindSet then
          repeat
            ToReportSelections := Rec;
            if ToReportSelections.Insert then;
          until Next = 0;

        exit(ToReportSelections.FindSet);
    end;

    local procedure GetCustomReportSelection(var CustomReportSelection: Record "Custom Report Selection";AccountNo: Code[20];TableNo: Integer): Boolean
    begin
        CustomReportSelection.SetRange("Source Type",TableNo);
        CustomReportSelection.SetFilter("Source No.",AccountNo);
        if CustomReportSelection.IsEmpty then
          exit(false);

        CustomReportSelection.SetFilter("Use for Email Attachment",GetFilter("Use for Email Attachment"));
        CustomReportSelection.SetFilter("Use for Email Body",GetFilter("Use for Email Body"));
    end;

    local procedure GetCustomReportSelectionByUsageFilter(var CustomReportSelection: Record "Custom Report Selection";AccountNo: Code[20];ReportUsageFilter: Text;TableNo: Integer): Boolean
    begin
        CustomReportSelection.SetFilter(Usage,ReportUsageFilter);
        exit(GetCustomReportSelection(CustomReportSelection,AccountNo,TableNo));
    end;

    local procedure GetCustomReportSelectionByUsageOption(var CustomReportSelection: Record "Custom Report Selection";AccountNo: Code[20];ReportUsage: Integer;TableNo: Integer): Boolean
    begin
        CustomReportSelection.SetRange(Usage,ReportUsage);
        exit(GetCustomReportSelection(CustomReportSelection,AccountNo,TableNo));
    end;

    local procedure GetNextEmailAddressFromCustomReportSelection(var CustomReportSelection: Record "Custom Report Selection";DefaultEmailAddress: Text;UsageValue: Option;SequenceText: Text): Text
    var
        SequenceInteger: Integer;
    begin
        if Evaluate(SequenceInteger,SequenceText) then begin
          CustomReportSelection.SetRange(Usage,UsageValue);
          CustomReportSelection.SetRange(Sequence,SequenceInteger);
          if CustomReportSelection.FindFirst then
            if CustomReportSelection."Send To Email" <> '' then
              exit(CustomReportSelection."Send To Email");
        end;
        exit(DefaultEmailAddress);
    end;

    local procedure GetUniqueAccountNos(var TempNameValueBuffer: Record "Name/Value Buffer" temporary;RecRef: RecordRef;AccountNoFieldNo: Integer)
    var
        TempCustomer: Record Customer temporary;
        AccountNoFieldRef: FieldRef;
    begin
        if AccountNoFieldNo <> 0 then begin
          AccountNoFieldRef := RecRef.Field(AccountNoFieldNo);
          if RecRef.FindSet then
            repeat
              TempNameValueBuffer.ID += 1;
              TempNameValueBuffer.Name := AccountNoFieldRef.Value;
              TempCustomer."No." := AccountNoFieldRef.Value; // to avoid duplicate No. insertion into Name/Value buffer
              if TempCustomer.Insert then
                TempNameValueBuffer.Insert;
            until RecRef.Next = 0;
        end else begin
          TempNameValueBuffer.Init;
          TempNameValueBuffer.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure PrintForUsage(ReportUsage: Integer)
    var
        Handled: Boolean;
    begin
        OnBeforePrintForUsage(ReportUsage,Handled);
        if Handled then
          exit;

        FilterPrintUsage(ReportUsage);
        if FindSet then
          repeat
            REPORT.RunModal("Report ID",true);
          until Next = 0;
    end;

    local procedure FindEmailAddressForEmailLayout(LayoutCode: Code[20];AccountNo: Code[20];ReportUsage: Integer;TableNo: Integer): Text[200]
    var
        CustomReportSelection: Record "Custom Report Selection";
    begin
        // Search for a potential email address from Custom Report Selections
        GetCustomReportSelectionByUsageOption(CustomReportSelection,AccountNo,ReportUsage,TableNo);
        CustomReportSelection.SetFilter("Send To Email",'<>%1','');
        CustomReportSelection.SetRange("Email Body Layout Code",LayoutCode);
        if CustomReportSelection.FindFirst then
          exit(CustomReportSelection."Send To Email");

        // Relax the filter and search for an email address
        CustomReportSelection.SetFilter("Use for Email Body",'');
        CustomReportSelection.SetRange("Email Body Layout Code",'');
        if CustomReportSelection.FindFirst then
          exit(CustomReportSelection."Send To Email");
        exit('');
    end;

    local procedure ShowNoBodyNoAttachmentError(ReportUsage: Integer;FoundBody: Boolean;FoundAttachment: Boolean)
    begin
        if not (FoundBody or FoundAttachment) then begin
          Usage := ReportUsage;
          Error(MustSelectAndEmailBodyOrAttahmentErr,Usage);
        end;
    end;

    procedure ReportUsageToDocumentType(var DocumentType: Option;ReportUsage: Integer): Boolean
    var
        SalesHeader: Record "Sales Header";
    begin
        case ReportUsage of
          Usage::"S.Invoice",Usage::"S.Invoice Draft",Usage::"P.Invoice":
            DocumentType := SalesHeader."Document Type"::Invoice;
          Usage::"S.Quote",Usage::"P.Quote":
            DocumentType := SalesHeader."Document Type"::Quote;
          Usage::"S.Cr.Memo",Usage::"P.Cr.Memo":
            DocumentType := SalesHeader."Document Type"::"Credit Memo";
          Usage::"S.Order",Usage::"P.Order":
            DocumentType := SalesHeader."Document Type"::Order;
          else
            exit(false);
        end;
        exit(true);
    end;

    procedure SendEmailInForeground(DocRecordID: RecordID;DocNo: Code[20];DocName: Text[150];ReportUsage: Integer;SourceIsCustomer: Boolean;SourceNo: Code[20]): Boolean
    var
        RecRef: RecordRef;
    begin
        // Blocks the user until the email is sent; use SendEmailInBackground for normal purposes.

        if not RecRef.Get(DocRecordID) then
          exit(false);

        RecRef.LockTable;
        RecRef.Find;
        RecRef.SetRecFilter;

        if SourceIsCustomer then
          exit(SendEmailToCustDirectly(ReportUsage,RecRef,DocNo,DocName,false,SourceNo));

        exit(SendEmailToVendorDirectly(ReportUsage,RecRef,DocNo,DocName,false,SourceNo));
    end;

    local procedure RecordsCanBeSent(RecRef: RecordRef): Boolean
    begin
        if RecRef.Count > 1 then
          exit(Confirm(OneRecordWillBeSentQst));

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustEmailAddress(BillToCustomerNo: Code[20];var ToAddress: Text;ReportUsage: Option;var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetVendorEmailAddress(BuyFromVendorNo: Code[20];var ToAddress: Text;ReportUsage: Option;var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrint(ReportUsage: Integer;RecordVariant: Variant;CustomerNoFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintForUsage(var ReportUsage: Integer;var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintWithCheck(ReportUsage: Integer;RecordVariant: Variant;CustomerNoFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintWithGUIYesNoWithCheck(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;CustomerNoFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintWithGUIYesNoWithCheckVendor(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;VendorNoFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintWithGUIYesNo(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;CustomerNoFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintWithGUIYesNoVendor(ReportUsage: Integer;RecordVariant: Variant;IsGUI: Boolean;VendorNoFieldNo: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeSetReportLayout(RecordVariant: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendEmailToCust(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];ShowDialog: Boolean;CustNo: Code[20];var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendEmailToVendor(ReportUsage: Integer;RecordVariant: Variant;DocNo: Code[20];DocName: Text[150];ShowDialog: Boolean;VendorNo: Code[20];var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnFindReportSelections(var FilterReportSelections: Record "Report Selections";var IsHandled: Boolean;var ReturnReportSelections: Record "Report Selections")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetEmailBodyCustomer()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetEmailBodyCustomer(CustomerEmailAddress: Text[250];ServerEmailBodyFilePath: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetEmailBodyVendor()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetEmailBodyVendor(VendorEmailAddress: Text[250];ServerEmailBodyFilePath: Text[250])
    begin
    end;

    local procedure GetLastSequenceNo(var TempReportSelectionsSource: Record "Report Selections" temporary;ReportUsage: Option): Code[10]
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        TempReportSelections.Copy(TempReportSelectionsSource,true);
        TempReportSelections.SetRange(Usage,ReportUsage);
        if TempReportSelections.FindLast then;
        if TempReportSelections.Sequence = '' then
          TempReportSelections.Sequence := '1';
        exit(TempReportSelections.Sequence);
    end;

    local procedure HasReportWithUsage(var TempReportSelectionsSource: Record "Report Selections" temporary;ReportUsage: Option;ReportID: Integer): Boolean
    var
        TempReportSelections: Record "Report Selections" temporary;
    begin
        TempReportSelections.Copy(TempReportSelectionsSource,true);
        TempReportSelections.SetRange(Usage,ReportUsage);
        TempReportSelections.SetRange("Report ID",ReportID);
        exit(TempReportSelections.FindFirst);
    end;
}

