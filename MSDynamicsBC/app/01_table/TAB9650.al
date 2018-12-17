table 9650 "Custom Report Layout"
{
    // version NAVW113.00

    Caption = 'Custom Report Layout';
    DataPerCompany = false;
    DrillDownPageID = "Custom Report Layouts";
    LookupPageID = "Custom Report Layouts";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;"Report ID";Integer)
        {
            Caption = 'Report ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(3;"Report Name";Text[80])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(6;Type;Option)
        {
            Caption = 'Type';
            InitValue = Word;
            OptionCaption = 'RDLC,Word';
            OptionMembers = RDLC,Word;
        }
        field(7;"Layout";BLOB)
        {
            Caption = 'Layout';
        }
        field(8;"Last Modified";DateTime)
        {
            Caption = 'Last Modified';
            Editable = false;
        }
        field(9;"Last Modified by User";Code[50])
        {
            Caption = 'Last Modified by User';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("Last Modified by User");
            end;
        }
        field(10;"File Extension";Text[30])
        {
            Caption = 'File Extension';
            Editable = false;
        }
        field(11;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(12;"Custom XML Part";BLOB)
        {
            Caption = 'Custom XML Part';
        }
        field(13;"App ID";Guid)
        {
            Caption = 'App ID';
            Editable = false;
        }
        field(14;"Built-In";Boolean)
        {
            Caption = 'Built-In';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Report ID","Company Name",Type)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;Description)
        {
        }
    }

    trigger OnDelete()
    begin
        if "Built-In" then
          Error(DeleteBuiltInLayoutErr);
    end;

    trigger OnInsert()
    begin
        TestField("Report ID");
        if Code = '' then
          Code := GetDefaultCode("Report ID");
        SetUpdated;
    end;

    trigger OnModify()
    begin
        TestField("Report ID");
        SetUpdated;
    end;

    var
        ImportWordTxt: Label 'Import Word Document';
        ImportRdlcTxt: Label 'Import Report Layout';
        FileFilterWordTxt: Label 'Word Files (*.docx)|*.docx', Comment='{Split=r''\|''}{Locked=s''1''}';
        FileFilterRdlcTxt: Label 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', Comment='{Split=r''\|''}{Locked=s''1''}';
        NoRecordsErr: Label 'There is no record in the list.';
        BuiltInTxt: Label 'Built-in layout';
        CopyOfTxt: Label 'Copy of %1';
        NewLayoutTxt: Label 'New layout';
        ErrorInLayoutErr: Label 'The following issue has been found in the layout %1 for report ID  %2:\%3.', Comment='%1=a name, %2=a number, %3=a sentence/error description.';
        TemplateValidationQst: Label 'The RDLC layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the layout validation:\%1\Do you want to continue?', Comment='%1 = an error message.';
        TemplateValidationErr: Label 'The RDLC layout does not comply with the current report design (for example, fields are missing or the report ID is wrong).\The following errors were detected during the document validation:\%1\You must update the layout to match the current report design.';
        AbortWithValidationErr: Label 'The RDLC layout action has been canceled because of validation errors.';
        ModifyBuiltInLayoutQst: Label 'This is a built-in custom report layout, and it cannot be modified.\\Do you want to modify a copy of the custom report layout instead?';
        NoLayoutSelectedMsg: Label 'You must specify if you want to insert a Word layout or an RDLC layout for the report.';
        DeleteBuiltInLayoutErr: Label 'This is a built-in custom report layout, and it cannot be deleted.';
        ModifyBuiltInLayoutErr: Label 'This is a built-in custom report layout, and it cannot be modified.';

    local procedure SetUpdated()
    begin
        "Last Modified" := RoundDateTime(CurrentDateTime);
        "Last Modified by User" := UserId;
    end;

    procedure InitBuiltInLayout(ReportID: Integer;LayoutType: Option): Code[20]
    var
        CustomReportLayout: Record "Custom Report Layout";
        TempBlob: Record TempBlob;
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        InStr: InStream;
        OutStr: OutStream;
    begin
        if ReportID = 0 then
          exit;

        CustomReportLayout.Init;
        CustomReportLayout."Report ID" := ReportID;
        CustomReportLayout.Type := LayoutType;
        CustomReportLayout.Description := CopyStr(StrSubstNo(CopyOfTxt,BuiltInTxt),1,MaxStrLen(Description));
        CustomReportLayout."Built-In" := false;
        CustomReportLayout.Code := GetDefaultCode(ReportID);
        CustomReportLayout.Insert(true);

        case LayoutType of
          CustomReportLayout.Type::Word:
            begin
              TempBlob.Blob.CreateOutStream(OutStr);
              if not REPORT.WordLayout(ReportID,InStr) then begin
                DocumentReportMgt.NewWordLayout(ReportID,OutStr);
                CustomReportLayout.Description := CopyStr(NewLayoutTxt,1,MaxStrLen(Description));
              end else
                CopyStream(OutStr,InStr);
              CustomReportLayout.SetLayoutBlob(TempBlob);
            end;
          CustomReportLayout.Type::RDLC:
            if REPORT.RdlcLayout(ReportID,InStr) then begin
              TempBlob.Blob.CreateOutStream(OutStr);
              CopyStream(OutStr,InStr);
              CustomReportLayout.SetLayoutBlob(TempBlob);
            end;
        end;

        CustomReportLayout.SetDefaultCustomXmlPart;

        exit(CustomReportLayout.Code);
    end;

    procedure CopyBuiltInLayout()
    var
        ReportLayoutLookup: Page "Report Layout Lookup";
        ReportID: Integer;
    begin
        FilterGroup(4);
        if GetFilter("Report ID") = '' then
          FilterGroup(0);
        if GetFilter("Report ID") <> '' then
          if Evaluate(ReportID,GetFilter("Report ID")) then
            ReportLayoutLookup.SetReportID(ReportID);
        FilterGroup(0);
        if ReportLayoutLookup.RunModal = ACTION::OK then begin
          if not ReportLayoutLookup.SelectedAddWordLayot and not ReportLayoutLookup.SelectedAddRdlcLayot then begin
            Message(NoLayoutSelectedMsg);
            exit;
          end;

          if ReportLayoutLookup.SelectedAddWordLayot then
            InitBuiltInLayout(ReportLayoutLookup.SelectedReportID,Type::Word);
          if ReportLayoutLookup.SelectedAddRdlcLayot then
            InitBuiltInLayout(ReportLayoutLookup.SelectedReportID,Type::RDLC);
        end;
    end;

    procedure GetCustomRdlc(ReportID: Integer) RdlcTxt: Text
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        InStream: InStream;
        CustomLayoutCode: Code[20];
    begin
        // Temporarily selected layout for Design-time report execution?
        if ReportLayoutSelection.GetTempLayoutSelected <> '' then
          CustomLayoutCode := ReportLayoutSelection.GetTempLayoutSelected
        else  // Normal selection
          if ReportLayoutSelection.HasCustomLayout(ReportID) = 1 then
            CustomLayoutCode := ReportLayoutSelection."Custom Report Layout Code";

        if (CustomLayoutCode <> '') and Get(CustomLayoutCode) then begin
          TestField(Type,Type::RDLC);
          if UpdateLayout(true,false) then
            Commit; // Save the updated layout
          RdlcTxt := GetLayout;
        end else begin
          REPORT.RdlcLayout(ReportID,InStream);
          InStream.Read(RdlcTxt);
        end;

        OnAfterReportGetCustomRdlc("Report ID",RdlcTxt);
    end;

    procedure CopyRecord(): Code[20]
    var
        CustomReportLayout: Record "Custom Report Layout";
        TempBlob: Record TempBlob;
    begin
        if IsEmpty then
          Error(NoRecordsErr);

        CalcFields(Layout,"Custom XML Part");
        CustomReportLayout := Rec;

        Description := CopyStr(StrSubstNo(CopyOfTxt,Description),1,MaxStrLen(Description));
        Code := GetDefaultCode("Report ID");
        "Built-In" := false;
        Insert(true);

        if CustomReportLayout."Built-In" then begin
          CustomReportLayout.GetLayoutBlob(TempBlob);
          SetLayoutBlob(TempBlob);
        end;

        if not HasCustomXmlPart then
          SetDefaultCustomXmlPart;

        exit(Code);
    end;

    procedure ImportLayout(DefaultFileName: Text)
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
        FileName: Text;
        FileFilterTxt: Text;
        ImportTxt: Text;
    begin
        if IsEmpty then
          Error(NoRecordsErr);

        if not CanBeModified then
          exit;

        case Type of
          Type::Word:
            begin
              ImportTxt := ImportWordTxt;
              FileFilterTxt := FileFilterWordTxt;
            end;
          Type::RDLC:
            begin
              ImportTxt := ImportRdlcTxt;
              FileFilterTxt := FileFilterRdlcTxt;
            end;
        end;
        FileName := FileMgt.BLOBImportWithFilter(TempBlob,ImportTxt,DefaultFileName,FileFilterTxt,FileFilterTxt);
        if FileName = '' then
          exit;

        ImportLayoutBlob(TempBlob,UpperCase(FileMgt.GetExtension(FileName)));
    end;

    procedure ImportLayoutBlob(var TempBlob: Record TempBlob;FileExtension: Text[30])
    var
        OutputTempBlob: Record TempBlob;
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        DocumentOutStream: OutStream;
        ErrorMessage: Text;
        XmlPart: Text;
    begin
        // Layout is stored in the DocumentInStream (RDLC requires UTF8 encoding for which reason is stream is created in the case block.
        // Result is stored in the DocumentOutStream (..)
        TestField("Report ID");
        OutputTempBlob.Blob.CreateOutStream(DocumentOutStream);
        XmlPart := GetWordXmlPart("Report ID");

        case Type of
          Type::Word:
            begin
              // Run update
              TempBlob.Blob.CreateInStream(DocumentInStream);
              ErrorMessage := DocumentReportMgt.TryUpdateWordLayout(DocumentInStream,DocumentOutStream,'',XmlPart);
              // Validate the Word document layout against the layout of the current report
              if ErrorMessage = '' then begin
                CopyStream(DocumentOutStream,DocumentInStream);
                DocumentReportMgt.ValidateWordLayout("Report ID",DocumentInStream,true,true);
              end;
            end;
          Type::RDLC:
            begin
              // Update the Rdlc document layout against the layout of the current report
              TempBlob.Blob.CreateInStream(DocumentInStream,TEXTENCODING::UTF8);
              ErrorMessage := DocumentReportMgt.TryUpdateRdlcLayout("Report ID",DocumentInStream,DocumentOutStream,'',XmlPart,false);
            end;
        end;

        SetLayoutBlob(OutputTempBlob);

        if FileExtension <> '' then
          "File Extension" := FileExtension;
        SetDefaultCustomXmlPart;
        Modify(true);
        Commit;

        if ErrorMessage <> '' then
          Message(ErrorMessage);
    end;

    procedure ExportLayout(DefaultFileName: Text;ShowFileDialog: Boolean): Text
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        UpdateLayout(true,false); // Don't block on errors (return false) as we in all cases want to have an export file to edit.

        GetLayoutBlob(TempBlob);
        if not TempBlob.Blob.HasValue then
          exit('');

        if DefaultFileName = '' then
          DefaultFileName := '*.' + GetFileExtension;

        exit(FileMgt.BLOBExport(TempBlob,DefaultFileName,ShowFileDialog));
    end;

    procedure ValidateLayout(useConfirm: Boolean;UpdateContext: Boolean): Boolean
    var
        TempBlob: Record TempBlob;
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        ValidationErrorFormat: Text;
    begin
        TestField("Report ID");
        GetLayoutBlob(TempBlob);
        if not TempBlob.Blob.HasValue then
          exit;

        TempBlob.Blob.CreateInStream(DocumentInStream);

        case Type of
          Type::Word:
            exit(DocumentReportMgt.ValidateWordLayout("Report ID",DocumentInStream,useConfirm,UpdateContext));
          Type::RDLC:
            if not TryValidateRdlcReport(DocumentInStream) then begin
              if useConfirm then begin
                if not Confirm(TemplateValidationQst,false,GetLastErrorText) then
                  Error(AbortWithValidationErr);
              end else begin
                ValidationErrorFormat := TemplateValidationErr;
                Error(ValidationErrorFormat,GetLastErrorText);
              end;
              exit(false);
            end;
        end;

        exit(true);
    end;

    procedure UpdateLayout(ContinueOnError: Boolean;IgnoreDelete: Boolean): Boolean
    var
        ErrorMessage: Text;
    begin
        ErrorMessage := TryUpdateLayout(IgnoreDelete);

        if ErrorMessage = '' then begin
          if Type = Type::Word then
            exit(ValidateLayout(true,true));
          exit(true); // We have no validate for RDLC
        end;

        ErrorMessage := StrSubstNo(ErrorInLayoutErr,Description,"Report ID",ErrorMessage);
        if ContinueOnError then begin
          Message(ErrorMessage);
          exit(true);
        end;

        Error(ErrorMessage);
    end;

    procedure TryUpdateLayout(IgnoreDelete: Boolean): Text
    var
        InTempBlob: Record TempBlob;
        OutTempBlob: Record TempBlob;
        DocumentReportMgt: Codeunit "Document Report Mgt.";
        DocumentInStream: InStream;
        DocumentOutStream: OutStream;
        WordXmlPart: Text;
        ErrorMessage: Text;
    begin
        GetLayoutBlob(InTempBlob);
        if not InTempBlob.Blob.HasValue then
          exit('');

        TestCustomXmlPart;
        TestField("Report ID");

        WordXmlPart := GetWordXmlPart("Report ID");
        InTempBlob.Blob.CreateInStream(DocumentInStream);

        case Type of
          Type::Word:
            begin
              OutTempBlob.Blob.CreateOutStream(DocumentOutStream);
              ErrorMessage := DocumentReportMgt.TryUpdateWordLayout(DocumentInStream,DocumentOutStream,GetCustomXmlPart,WordXmlPart);
            end;
          Type::RDLC:
            begin
              OutTempBlob.Blob.CreateOutStream(DocumentOutStream,TEXTENCODING::UTF8);
              ErrorMessage := DocumentReportMgt.TryUpdateRdlcLayout(
                  "Report ID",DocumentInStream,DocumentOutStream,GetCustomXmlPart,WordXmlPart,IgnoreDelete);
            end;
        end;

        SetCustomXmlPart(WordXmlPart);

        if OutTempBlob.Blob.HasValue then
          SetLayoutBlob(OutTempBlob);

        exit(ErrorMessage);
    end;

    local procedure GetWordXML(var TempBlob: Record TempBlob)
    var
        OutStr: OutStream;
    begin
        TestField("Report ID");
        TempBlob.Blob.CreateOutStream(OutStr,TEXTENCODING::UTF16);
        OutStr.WriteText(REPORT.WordXmlPart("Report ID"));
    end;

    procedure ExportSchema(DefaultFileName: Text;ShowFileDialog: Boolean): Text
    var
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
    begin
        TestField(Type,Type::Word);

        if DefaultFileName = '' then
          DefaultFileName := '*.xml';

        GetWordXML(TempBlob);
        if TempBlob.Blob.HasValue then
          exit(FileMgt.BLOBExport(TempBlob,DefaultFileName,ShowFileDialog));
    end;

    procedure EditLayout()
    begin
        if CanBeModified then begin
          UpdateLayout(true,true); // Don't block on errors (return false) as we in all cases want to have an export file to edit.

          case Type of
            Type::Word:
              CODEUNIT.Run(CODEUNIT::"Edit MS Word Report Layout",Rec);
            Type::RDLC:
              CODEUNIT.Run(CODEUNIT::"Edit RDLC Report Layout",Rec);
          end;
        end;
    end;

    local procedure GetFileExtension(): Text[4]
    begin
        case Type of
          Type::Word:
            exit('docx');
          Type::RDLC:
            exit('rdl');
        end;
    end;

    procedure GetWordXmlPart(ReportID: Integer): Text
    var
        WordXmlPart: Text;
    begin
        // Store the current design as an extended WordXmlPart. This data is used for later updates / refactorings.
        WordXmlPart := REPORT.WordXmlPart(ReportID,true);
        exit(WordXmlPart);
    end;

    [Scope('Personalization')]
    procedure RunCustomReport()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if "Report ID" = 0 then
          exit;

        ReportLayoutSelection.SetTempLayoutSelected(Code);
        REPORT.RunModal("Report ID");
        ReportLayoutSelection.SetTempLayoutSelected('');
    end;

    procedure ApplyUpgrade(var ReportUpgrade: DotNet ReportUpgradeSet;var ReportChangeLogCollection: DotNet IReportChangeLogCollection;testOnly: Boolean)
    var
        InTempBlob: Record TempBlob;
        OutTempBlob: Record TempBlob;
        TempReportChangeLogCollection: DotNet IReportChangeLogCollection;
        DataInStream: InStream;
        DataOutStream: OutStream;
        ModifyLayout: Boolean;
    begin
        GetLayoutBlob(InTempBlob);
        if not InTempBlob.Blob.HasValue then
          exit;

        if ReportUpgrade.ChangeCount < 1 then
          exit;

        Clear(DataInStream);
        Clear(DataOutStream);

        if Type = Type::Word then begin
          InTempBlob.Blob.CreateInStream(DataInStream);
          OutTempBlob.Blob.CreateOutStream(DataOutStream);
        end else begin
          InTempBlob.Blob.CreateInStream(DataInStream,TEXTENCODING::UTF8);
          OutTempBlob.Blob.CreateOutStream(DataOutStream,TEXTENCODING::UTF8);
        end;

        TempReportChangeLogCollection := ReportUpgrade.Upgrade(Description,DataInStream,DataOutStream);

        if not testOnly then begin
          if TempReportChangeLogCollection.Failures = 0 then begin
            SetDefaultCustomXmlPart;
            ModifyLayout := true;
          end;
          if OutTempBlob.Blob.HasValue then begin
            SetLayoutBlob(OutTempBlob);
            ModifyLayout := true;
          end;
          if ModifyLayout then
            Commit;
        end;

        if TempReportChangeLogCollection.Count > 0 then begin
          if IsNull(ReportChangeLogCollection) then
            ReportChangeLogCollection := TempReportChangeLogCollection
          else
            ReportChangeLogCollection.AddRange(TempReportChangeLogCollection);
        end;
    end;

    [TryFunction]
    local procedure TryValidateRdlcReport(var InStr: InStream)
    var
        RdlcReportManager: DotNet RdlcReportManager;
        RdlcString: Text;
    begin
        InStr.Read(RdlcString);
        RdlcReportManager.ValidateReport("Report ID",RdlcString);
    end;

    local procedure FilterOnReport(ReportID: Integer)
    begin
        Reset;
        SetCurrentKey("Report ID","Company Name",Type);
        SetFilter("Company Name",'%1|%2','',StrSubstNo('@%1',CompanyName));
        SetRange("Report ID",ReportID);
    end;

    [Scope('Personalization')]
    procedure LookupLayoutOK(ReportID: Integer): Boolean
    begin
        FilterOnReport(ReportID);
        exit(PAGE.RunModal(PAGE::"Custom Report Layouts",Rec) = ACTION::LookupOK);
    end;

    [Scope('Personalization')]
    procedure GetDefaultCode(ReportID: Integer): Code[20]
    var
        CustomReportLayout: Record "Custom Report Layout";
        NewCode: Code[20];
    begin
        CustomReportLayout.SetRange("Report ID",ReportID);
        CustomReportLayout.SetFilter(Code,StrSubstNo('%1-*',ReportID));
        if CustomReportLayout.FindLast then
          NewCode := IncStr(CustomReportLayout.Code)
        else
          NewCode := StrSubstNo('%1-000001',ReportID);

        exit(NewCode);
    end;

    procedure CanBeModified(): Boolean
    begin
        if not "Built-In" then
          exit(true);

        if not Confirm(ModifyBuiltInLayoutQst) then
          exit(false);

        CopyRecord;
        exit(true);
    end;

    procedure NewExtensionLayout(ExtensionAppId: Guid;LayoutDataTable: DotNet DataTable)
    var
        Row: DotNet DataRow;
        Version: Text;
    begin
        Row := LayoutDataTable.Rows.Item(0);
        if LayoutDataTable.Columns.Contains('NavApplicationVersion') then
          Version := Row.Item('NavApplicationVersion');

        case Version of
          else
            HandleW10Layout(ExtensionAppId,Row,LayoutDataTable);
        end;
    end;

    local procedure HandleW10Layout(ExtensionAppId: Guid;Row: DotNet DataRow;LayoutDataTable: DotNet DataTable)
    var
        CustomReportLayout: Record "Custom Report Layout";
        LayoutCode: Code[20];
    begin
        if not LayoutDataTable.Columns.Contains('Code') then begin
          LayoutCode := 'MS-EXT-0000000001';
          CustomReportLayout.SetFilter(Code,'MS-EXT-*');
          if CustomReportLayout.FindLast then
            LayoutCode := IncStr(CustomReportLayout.Code);
        end else
          LayoutCode := Row.Item('Code');

        CustomReportLayout.Reset;
        CustomReportLayout.Init;
        CustomReportLayout.Code := LayoutCode;
        CustomReportLayout."App ID" := ExtensionAppId;
        CustomReportLayout.Type := Row.Item('Type');
        CustomReportLayout."Custom XML Part" := Row.Item('CustomXMLPart');
        CustomReportLayout.Description := Row.Item('Description');
        CustomReportLayout.Layout := Row.Item('Layout');
        CustomReportLayout."Report ID" := Row.Item('ReportID');
        CustomReportLayout.CalcFields("Report Name");
        CustomReportLayout."Built-In" := true;
        CustomReportLayout.Insert;
    end;

    [Scope('Personalization')]
    procedure HasLayout(): Boolean
    begin
        if "Built-In" then
          exit(HasBuiltInLayout);
        exit(HasNonBuiltInLayout);
    end;

    [Scope('Personalization')]
    procedure HasCustomXmlPart(): Boolean
    begin
        if "Built-In" then
          exit(HasBuiltInCustomXmlPart);
        exit(HasNonBuiltInCustomXmlPart);
    end;

    [Scope('Personalization')]
    procedure GetLayout(): Text
    begin
        if "Built-In" then
          exit(GetBuiltInLayout);
        exit(GetNonBuiltInLayout);
    end;

    [Scope('Personalization')]
    procedure GetCustomXmlPart(): Text
    begin
        if "Built-In" then
          exit(GetBuiltInCustomXmlPart);
        exit(GetNonBuiltInCustomXmlPart);
    end;

    [Scope('Personalization')]
    procedure GetLayoutBlob(var TempBlob: Record TempBlob)
    var
        ReportLayout: Record "Report Layout";
    begin
        TempBlob.Init;
        if not "Built-In" then begin
          CalcFields(Layout);
          TempBlob.Blob := Layout;
        end else begin
          ReportLayout.Get(Code);
          ReportLayout.CalcFields(Layout);
          TempBlob.Blob := ReportLayout.Layout;
        end;
    end;

    [Scope('Personalization')]
    procedure ClearLayout()
    begin
        if "Built-In" then
          Error(ModifyBuiltInLayoutErr);
        SetNonBuiltInLayout('');
    end;

    [Scope('Personalization')]
    procedure ClearCustomXmlPart()
    begin
        if "Built-In" then
          Error(ModifyBuiltInLayoutErr);
        SetNonBuiltInCustomXmlPart('');
    end;

    [Scope('Personalization')]
    procedure TestLayout()
    var
        ReportLayout: Record "Report Layout";
    begin
        if not "Built-In" then begin
          CalcFields(Layout);
          TestField(Layout);
          exit;
        end;
        ReportLayout.Get(Code);
        ReportLayout.CalcFields(Layout);
        ReportLayout.TestField(Layout);
    end;

    [Scope('Personalization')]
    procedure TestCustomXmlPart()
    var
        ReportLayout: Record "Report Layout";
    begin
        if not "Built-In" then begin
          CalcFields("Custom XML Part");
          TestField("Custom XML Part");
          exit;
        end;
        ReportLayout.Get(Code);
        ReportLayout.CalcFields("Custom XML Part");
        ReportLayout.TestField("Custom XML Part");
    end;

    [Scope('Personalization')]
    procedure SetLayout(Content: Text)
    begin
        if "Built-In" then
          Error(ModifyBuiltInLayoutErr);
        SetNonBuiltInLayout(Content);
    end;

    [Scope('Personalization')]
    procedure SetCustomXmlPart(Content: Text)
    begin
        if "Built-In" then
          Error(ModifyBuiltInLayoutErr);
        SetNonBuiltInCustomXmlPart(Content);
    end;

    [Scope('Personalization')]
    procedure SetDefaultCustomXmlPart()
    begin
        SetCustomXmlPart(GetWordXmlPart("Report ID"));
    end;

    [Scope('Personalization')]
    procedure SetLayoutBlob(var TempBlob: Record TempBlob)
    begin
        if "Built-In" then
          Error(ModifyBuiltInLayoutErr);
        Clear(Layout);
        if TempBlob.Blob.HasValue then
          Layout := TempBlob.Blob;
        Modify;
    end;

    local procedure HasNonBuiltInLayout(): Boolean
    begin
        CalcFields(Layout);
        exit(Layout.HasValue);
    end;

    local procedure HasNonBuiltInCustomXmlPart(): Boolean
    begin
        CalcFields("Custom XML Part");
        exit("Custom XML Part".HasValue);
    end;

    local procedure HasBuiltInLayout(): Boolean
    var
        ReportLayout: Record "Report Layout";
    begin
        if not ReportLayout.Get(Code) then
          exit(false);

        ReportLayout.CalcFields(Layout);
        exit(ReportLayout.Layout.HasValue);
    end;

    local procedure HasBuiltInCustomXmlPart(): Boolean
    var
        ReportLayout: Record "Report Layout";
    begin
        if not ReportLayout.Get(Code) then
          exit(false);

        ReportLayout.CalcFields("Custom XML Part");
        exit(ReportLayout."Custom XML Part".HasValue);
    end;

    local procedure GetNonBuiltInLayout(): Text
    var
        InStr: InStream;
        Content: Text;
    begin
        CalcFields(Layout);
        if not Layout.HasValue then
          exit('');

        if Type = Type::RDLC then
          Layout.CreateInStream(InStr,TEXTENCODING::UTF8)
        else
          Layout.CreateInStream(InStr);

        InStr.Read(Content);
        exit(Content);
    end;

    local procedure GetNonBuiltInCustomXmlPart(): Text
    var
        InStr: InStream;
        Content: Text;
    begin
        CalcFields("Custom XML Part");
        if not "Custom XML Part".HasValue then
          exit('');

        "Custom XML Part".CreateInStream(InStr,TEXTENCODING::UTF16);
        InStr.Read(Content);
        exit(Content);
    end;

    local procedure GetBuiltInLayout(): Text
    var
        ReportLayout: Record "Report Layout";
        InStr: InStream;
        Content: Text;
    begin
        if not ReportLayout.Get(Code) then
          exit('');

        ReportLayout.CalcFields(Layout);
        if not ReportLayout.Layout.HasValue then
          exit('');

        if Type = Type::RDLC then
          ReportLayout.Layout.CreateInStream(InStr,TEXTENCODING::UTF8)
        else
          ReportLayout.Layout.CreateInStream(InStr);

        InStr.Read(Content);
        exit(Content);
    end;

    local procedure GetBuiltInCustomXmlPart(): Text
    var
        ReportLayout: Record "Report Layout";
        InStr: InStream;
        Content: Text;
    begin
        if not ReportLayout.Get(Code) then
          exit('');

        ReportLayout.CalcFields("Custom XML Part");
        if not ReportLayout."Custom XML Part".HasValue then
          exit('');

        ReportLayout."Custom XML Part".CreateInStream(InStr,TEXTENCODING::UTF16);
        InStr.Read(Content);
        exit(Content);
    end;

    local procedure SetNonBuiltInLayout(Content: Text)
    var
        OutStr: OutStream;
    begin
        Clear(Layout);
        if Content <> '' then begin
          if Type = Type::RDLC then
            Layout.CreateOutStream(OutStr,TEXTENCODING::UTF8)
          else
            Layout.CreateOutStream(OutStr);
          OutStr.Write(Content);
        end;
        Modify;
    end;

    local procedure SetNonBuiltInCustomXmlPart(Content: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Custom XML Part");
        if Content <> '' then begin
          "Custom XML Part".CreateOutStream(OutStr,TEXTENCODING::UTF16);
          OutStr.Write(Content);
        end;
        Modify;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReportGetCustomRdlc(ReportId: Integer;var RdlcText: Text)
    begin
    end;
}

