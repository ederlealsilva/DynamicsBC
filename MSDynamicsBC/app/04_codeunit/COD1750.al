codeunit 1750 "Data Classification Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        CountryRegion: Record "Country/Region";
        CountryCodeFilter: Text;
        ImportTitleTxt: Label 'Choose the Excel worksheet where data classifications have been added.';
        DataSensitivityOptionStringTxt: Label 'Unclassified,Sensitive,Personal,Company Confidential,Normal', Comment='It needs to be translated as the field Data Sensitivity on Page 1751 Data Classification WorkSheet and field Data Sensitivity of Table 1180 Data Sensitivity Entities';
        DataClassNotifActionTxt: Label 'Open Data Classification Guide';
        DataClassNotifMessageMsg: Label 'Looks like you have %1 in the EU. Have you classified your data? We can help you do that.', Comment='%1=Data Subject';
        DataClassNotifCompanyMessageMsg: Label 'Looks like you do business in the European Union. Have you classified the sensitivity of your data? We can help you do that.';
        ExcelFileNameTxt: Label 'Classifications.xlsx';
        CustomerFilterTxt: Label 'WHERE(Partner Type=FILTER(Person))', Locked=true;
        VendorFilterTxt: Label 'WHERE(Partner Type=FILTER(Person))', Locked=true;
        ContactFilterTxt: Label 'WHERE(Type=FILTER(Person))', Locked=true;
        ResourceFilterTxt: Label 'WHERE(Type=FILTER(Person))', Locked=true;
        SyncFieldsInFieldTableMsg: Label 'Your fields are %1 days old.', Comment='%1=Number of days';
        SyncAllFieldsTxt: Label 'Synchronize all fields';
        UnclassifiedFieldsExistMsg: Label 'You have unclassified fields that require your attention.';
        OpenWorksheetActionLbl: Label 'Open worksheet';
        CompanyTok: Label 'company', Locked=true;
        VendorsTok: Label 'vendors';
        CustomersTok: Label 'customers';
        ContactsTok: Label 'contacts';
        EmployeesTok: Label 'employees';
        ResourcesTok: Label 'resources';
        DontShowAgainTok: Label 'Don''t show me again';
        WrongFormatExcelFileErr: Label 'Looks like the Excel worksheet you provided is not formatted correctly.';
        WrongSensitivityValueErr: Label '%1 is not a valid classification. Classifications can be %2.', Comment='%1=Given Sensitivity %2=Available Options';
        LegalDisclaimerTxt: Label 'Microsoft is providing this Data Classification feature as a matter of convenience only. It''s your responsibility to classify the data appropriately and comply with any laws and regulations that are applicable to you. Microsoft disclaims all responsibility towards any claims related to your classification of the data.';
        SyncFieldsReminderNotificationTxt: Label 'Data Classifications sync reminder';
        SyncFieldsReminderNotificationDescriptionTxt: Label 'Remind me to find unclassified fields every 30 days';
        UnclassifiedFieldsNotificationTxt: Label 'Data Sensitivities are missing';
        UnclassifiedFieldsNotificationDescriptionTxt: Label 'Show a warning when there are fields with missing Data Sensitivity';
        ReviewPrivacySettingsNotificationTxt: Label 'Review your privacy settings reminder';
        ReviewPrivacySettingsNotificationDescriptionTxt: Label 'Show a warning to review your privacy settings when persons from EU are found in your system';

    procedure FillDataSensitivityTable()
    var
        "Field": Record "Field";
        DataSensitivity: Record "Data Sensitivity";
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        Field.SetRange(Enabled,true);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        Field.SetFilter(
          DataClassification,
          StrSubstNo('%1|%2|%3',
            Field.DataClassification::CustomerContent,
            Field.DataClassification::EndUserIdentifiableInformation,
            Field.DataClassification::EndUserPseudonymousIdentifiers));
        Field.FindSet;
        repeat
          DataSensitivity.Init;
          DataSensitivity."Company Name" := CompanyName;
          DataSensitivity."Table No" := Field.TableNo;
          DataSensitivity."Field No" := Field."No.";
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Unclassified;
          DataSensitivity.Insert;
        until Field.Next = 0;
        if FieldsSyncStatus.Get then begin
          FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime;
          FieldsSyncStatus.Modify;
        end else begin
          FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime;
          FieldsSyncStatus.Insert;
        end;
    end;

    procedure ImportExcelSheet()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        DataSensitivity: Record "Data Sensitivity";
        TypeHelper: Codeunit "Type Helper";
        FileManagement: Codeunit "File Management";
        DataClassificationWorksheet: Page "Data Classification Worksheet";
        ExcelStream: InStream;
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FileName: Text;
        Class: Integer;
        TableNoColumn: Integer;
        FieldNoColumn: Integer;
        ClassColumn: Integer;
        Rows: Integer;
        Columns: Integer;
        Index: Integer;
        TableNo: Integer;
        FieldNo: Integer;
        ShouldUploadFile: Boolean;
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        if DataSensitivity.IsEmpty then
          FillDataSensitivityTable;

        ShouldUploadFile := true;
        OnUploadExcelSheet(TempExcelBuffer,ShouldUploadFile);
        if ShouldUploadFile then begin
          FileName := '';
          UploadIntoStream(
            ImportTitleTxt,
            '',
            FileManagement.GetToFilterText('',ExcelFileNameTxt),
            FileName,
            ExcelStream);

          if FileName = '' then
            Error('');
          TempExcelBuffer.OpenBookStream(ExcelStream,DataClassificationWorksheet.Caption);
          TempExcelBuffer.ReadSheet;
        end;

        if TempExcelBuffer.FindLast then;

        Rows := TempExcelBuffer."Row No.";
        Columns := TempExcelBuffer."Column No.";
        if (Rows < 2) or (Columns < 6) then
          Error(WrongFormatExcelFileErr);

        TableNoColumn := 1;
        FieldNoColumn := 2;
        ClassColumn := 6;

        for Index := 2 to Rows do
          if TempExcelBuffer.Get(Index,TableNoColumn) then begin
            Evaluate(TableNo,TempExcelBuffer."Cell Value as Text");

            if TempExcelBuffer.Get(Index,FieldNoColumn) then begin;
              Evaluate(FieldNo,TempExcelBuffer."Cell Value as Text");

              if TempExcelBuffer.Get(Index,ClassColumn) then
                if DataSensitivity.Get(CompanyName,TableNo,FieldNo) then begin
                  Class := TypeHelper.GetOptionNo(TempExcelBuffer."Cell Value as Text",DataSensitivityOptionStringTxt);
                  if Class < 0 then begin
                    // Try the English version
                    RecordRef.Open(DATABASE::"Data Sensitivity");
                    FieldRef := RecordRef.Field(DataSensitivity.FieldNo("Data Sensitivity"));
                    Class := TypeHelper.GetOptionNo(TempExcelBuffer."Cell Value as Text",FieldRef.OptionString);
                    RecordRef.Close;
                  end;
                  if Class < 0 then
                    Error(WrongSensitivityValueErr,TempExcelBuffer."Cell Value as Text",DataSensitivityOptionStringTxt);
                  if Class <> DataSensitivity."Data Sensitivity"::Unclassified then begin
                    DataSensitivity.Validate("Data Sensitivity",Class);
                    DataSensitivity.Validate("Last Modified By",UserSecurityId);
                    DataSensitivity.Validate("Last Modified",CurrentDateTime);
                    DataSensitivity.Modify(true);
                  end;
                end;
            end;
          end;

        TempExcelBuffer.CloseBook;
    end;

    procedure ExportToExcelSheet()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationWorksheet: Page "Data Classification Worksheet";
        ShouldOpenFile: Boolean;
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        if not DataSensitivity.FindSet then
          FillDataSensitivityTable;

        TempExcelBuffer.CreateNewBook(DataClassificationWorksheet.Caption);
        TempExcelBuffer.NewRow;
        TempExcelBuffer.AddColumn(
          DataSensitivity.FieldName("Table No"),false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(
          DataSensitivity.FieldName("Field No"),false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(
          DataSensitivity.FieldName("Table Caption"),false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(
          DataSensitivity.FieldName("Field Caption"),false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(
          DataSensitivity.FieldName("Field Type"),false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(
          DataSensitivity.FieldName("Data Sensitivity"),false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
        repeat
          DataSensitivity.CalcFields("Table Caption");
          DataSensitivity.CalcFields("Field Caption");
          DataSensitivity.CalcFields("Field Type");
          if (DataSensitivity."Table Caption" <> '') and (DataSensitivity."Field Caption" <> '') then begin
            TempExcelBuffer.NewRow;
            TempExcelBuffer.AddColumn(
              DataSensitivity."Table No",false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(
              DataSensitivity."Field No",false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Number);
            TempExcelBuffer.AddColumn(
              DataSensitivity."Table Caption",false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn(
              DataSensitivity."Field Caption",false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
            case DataSensitivity."Field Type" of
              DataSensitivity."Field Type"::BigInteger:
                TempExcelBuffer.AddColumn(
                  'BigInteger',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Binary:
                TempExcelBuffer.AddColumn(
                  'Binary',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::BLOB:
                TempExcelBuffer.AddColumn(
                  'BLOB',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Boolean:
                TempExcelBuffer.AddColumn(
                  'Boolean',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Code:
                TempExcelBuffer.AddColumn(
                  'Code',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Date:
                TempExcelBuffer.AddColumn(
                  'Date',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::DateFormula:
                TempExcelBuffer.AddColumn(
                  'DateFormula',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::DateTime:
                TempExcelBuffer.AddColumn(
                  'DateTime',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Decimal:
                TempExcelBuffer.AddColumn(
                  'Decimal',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Duration:
                TempExcelBuffer.AddColumn(
                  'Duration',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::GUID:
                TempExcelBuffer.AddColumn(
                  'GUID',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Integer:
                TempExcelBuffer.AddColumn(
                  'Integer',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Media:
                TempExcelBuffer.AddColumn(
                  'Media',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::MediaSet:
                TempExcelBuffer.AddColumn(
                  'MediaSet',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::OemCode:
                TempExcelBuffer.AddColumn(
                  'OemCode',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::OemText:
                TempExcelBuffer.AddColumn(
                  'OemText',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Option:
                TempExcelBuffer.AddColumn(
                  'Option',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::RecordID:
                TempExcelBuffer.AddColumn(
                  'RecordID',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::TableFilter:
                TempExcelBuffer.AddColumn(
                  'TableFilter',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Text:
                TempExcelBuffer.AddColumn(
                  'Text',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
              DataSensitivity."Field Type"::Time:
                TempExcelBuffer.AddColumn(
                  'Time',false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
            end;
            TempExcelBuffer.AddColumn(
              DataSensitivity."Data Sensitivity",false,'',false,false,false,'',TempExcelBuffer."Cell Type"::Text);
          end;
        until DataSensitivity.Next = 0;

        TempExcelBuffer.WriteSheet(DataClassificationWorksheet.Caption,CompanyName,UserId);
        TempExcelBuffer.CloseBook;

        ShouldOpenFile := true;
        OnOpenExcelSheet(TempExcelBuffer,ShouldOpenFile);
        if ShouldOpenFile then
          TempExcelBuffer.OpenExcelWithName(ExcelFileNameTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1750, 'OnGetPrivacyMasterTables', '', false, false)]
    local procedure OnGetPrivacyMasterTablesSubscriber(var DataPrivacyEntities: Record "Data Privacy Entities")
    var
        DummyCustomer: Record Customer;
        DummyVendor: Record Vendor;
        DummyContact: Record Contact;
        DummyResource: Record Resource;
        DummyUser: Record User;
        DummyEmployee: Record Employee;
        DummySalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        DataPrivacyEntities.InsertRow(
          DATABASE::Customer,
          PAGE::"Customer List",
          DummyCustomer.FieldNo("No."),
          CustomerFilterTxt);
        DataPrivacyEntities.InsertRow(
          DATABASE::Vendor,
          PAGE::"Vendor List",
          DummyVendor.FieldNo("No."),
          VendorFilterTxt);
        DataPrivacyEntities.InsertRow(
          DATABASE::"Salesperson/Purchaser",
          PAGE::"Salespersons/Purchasers",
          DummySalespersonPurchaser.FieldNo(Code),
          ContactFilterTxt);
        DataPrivacyEntities.InsertRow(
          DATABASE::Contact,
          PAGE::"Contact List",
          DummyContact.FieldNo("No."),
          ContactFilterTxt);
        DataPrivacyEntities.InsertRow(
          DATABASE::Employee,
          PAGE::"Employee List",
          DummyEmployee.FieldNo("No."),
          '');
        DataPrivacyEntities.InsertRow(
          DATABASE::User,
          PAGE::Users,
          DummyUser.FieldNo("User Name"),
          '');
        DataPrivacyEntities.InsertRow(
          DATABASE::Resource,
          PAGE::"Resource List",
          DummyResource.FieldNo("No."),
          ResourceFilterTxt);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetPrivacyMasterTables(var DataPrivacyEntities: Record "Data Privacy Entities")
    begin
    end;

    procedure SetTableClassifications(var DataPrivacyEntities: Record "Data Privacy Entities")
    begin
        DataPrivacyEntities.SetRange(Include,true);
        if DataPrivacyEntities.FindSet then
          repeat
            SetFieldsClassifications(DataPrivacyEntities."Table No.",DataPrivacyEntities."Default Data Sensitivity");
          until DataPrivacyEntities.Next = 0;
    end;

    local procedure SetFieldsClassifications(TableNo: Integer;Class: Option)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        DataSensitivity.SetRange("Table No",TableNo);
        SetSensitivities(DataSensitivity,Class);
    end;

    local procedure FireDataClassificationNotification(EntityName: Text)
    var
        MyNotifications: Record "My Notifications";
        DataClassNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetDataClassificationNotificationId) then
          exit;
        DataClassNotification.Id := GetDataClassificationNotificationId;
        DataClassNotification.AddAction(DataClassNotifActionTxt,CODEUNIT::"Data Classification Mgt.",'OpenDataClassificationWizard');
        if EntityName <> CompanyTok then
          DataClassNotification.Message(StrSubstNo(DataClassNotifMessageMsg,EntityName))
        else
          DataClassNotification.Message(DataClassNotifCompanyMessageMsg);
        DataClassNotification.AddAction(DontShowAgainTok,CODEUNIT::"Data Classification Mgt.",'DisableNotifications');
        DataClassNotification.Send;
    end;

    local procedure FireSyncFieldsNotification(DaysSinceLastSync: Integer)
    var
        MyNotifications: Record "My Notifications";
        SyncFieldsNotification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetSyncFieldsNotificationId) then
          exit;
        SyncFieldsNotification.Id := GetSyncFieldsNotificationId;
        SyncFieldsNotification.Message := StrSubstNo(SyncFieldsInFieldTableMsg,DaysSinceLastSync);
        SyncFieldsNotification.AddAction(SyncAllFieldsTxt,CODEUNIT::"Data Classification Mgt.",'SyncAllFieldsFromNotification');
        SyncFieldsNotification.AddAction(DontShowAgainTok,CODEUNIT::"Data Classification Mgt.",'DisableNotifications');
        SyncFieldsNotification.Send;
    end;

    local procedure FireUnclassifiedFieldsNotification()
    var
        MyNotifications: Record "My Notifications";
        Notification: Notification;
    begin
        if not MyNotifications.IsEnabled(GetUnclassifiedFieldsNotificationId) then
          exit;
        Notification.Id := GetUnclassifiedFieldsNotificationId;
        Notification.Message := UnclassifiedFieldsExistMsg;
        Notification.AddAction(OpenWorksheetActionLbl,CODEUNIT::"Data Classification Mgt.",'OpenClassificationWorksheetPage');
        Notification.AddAction(DontShowAgainTok,CODEUNIT::"Data Classification Mgt.",'DisableNotifications');
        Notification.Send;
    end;

    procedure GetDataClassificationNotificationId(): Guid
    begin
        exit('23593a8e-947b-4b09-8382-36a8aaf89e01');
    end;

    procedure GetSyncFieldsNotificationId(): Guid
    begin
        exit('3bce2004-361a-4e7f-9ae6-2df91f29a195');
    end;

    procedure GetUnclassifiedFieldsNotificationId(): Guid
    begin
        exit('fe7fc3ad-2382-4cbd-93f8-79bcd5b538ae');
    end;

    procedure OpenDataClassificationWizard(Notification: Notification)
    begin
        PAGE.Run(PAGE::"Data Classification Wizard");
    end;

    procedure FindSimilarFields(var DataSensitivity: Record "Data Sensitivity")
    var
        TempDataPrivacyEntities: Record "Data Privacy Entities" temporary;
        FieldNameFilter: Text;
        TableNoFilter: Text;
        PrevTableNo: Integer;
    begin
        if DataSensitivity.FindSet then begin
          repeat
            if PrevTableNo <> DataSensitivity."Table No" then begin
              GetRelatedTablesForTable(TempDataPrivacyEntities,DataSensitivity."Table No");
              PrevTableNo := DataSensitivity."Table No";
            end;
            DataSensitivity.CalcFields("Field Caption");
            FieldNameFilter += StrSubstNo('*%1*|',DelChr(DataSensitivity."Field Caption",'=','()'));
          until DataSensitivity.Next = 0;

          FieldNameFilter := DelChr(FieldNameFilter,'>','|');
          DataSensitivity.Reset;
          DataSensitivity.SetRange("Company Name",CompanyName);
          DataSensitivity.FilterGroup(2);
          DataSensitivity.SetFilter("Field Caption",FieldNameFilter);

          if TempDataPrivacyEntities.FindSet then begin
            repeat
              TableNoFilter += StrSubstNo('%1|',TempDataPrivacyEntities."Table No.");
            until TempDataPrivacyEntities.Next = 0;

            TableNoFilter := DelChr(TableNoFilter,'>','|');
            DataSensitivity.SetFilter("Table No",TableNoFilter);
          end;
        end;
    end;

    procedure GetRelatedTablesForTable(var TempDataPrivacyEntitiesOut: Record "Data Privacy Entities" temporary;TableNo: Integer)
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        TableRelationsMetadata.SetRange("Related Table ID",TableNo);
        if TableRelationsMetadata.FindSet then
          repeat
            TempDataPrivacyEntitiesOut.InsertRow(TableRelationsMetadata."Table ID",0,0,'');
          until TableRelationsMetadata.Next = 0;
    end;

    procedure GetTableNoFilterForTablesWhoseNameContains(Name: Text): Text
    var
        "Field": Record "Field";
        PrevTableNo: Integer;
        TableNoFilter: Text;
    begin
        PrevTableNo := 0;
        Field.SetRange(DataClassification,Field.DataClassification::CustomerContent);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        Field.SetFilter(TableName,StrSubstNo('*%1*',Name));
        if Field.FindSet then begin
          repeat
            if PrevTableNo <> Field.TableNo then
              TableNoFilter += StrSubstNo('%1|',Field.TableNo);
          until Field.Next = 0;

          TableNoFilter := DelChr(TableNoFilter,'>','|');
        end;
        exit(TableNoFilter);
    end;

    procedure PopulateFieldValue(FieldRef: FieldRef;var FieldContentBuffer: Record "Field Content Buffer")
    var
        FieldValueText: Text;
    begin
        if IsFlowField(FieldRef) then
          FieldRef.CalcField;
        Evaluate(FieldValueText,Format(FieldRef.Value,0,9));
        if FieldValueText <> '' then
          if not FieldContentBuffer.Get(FieldValueText) then begin
            FieldContentBuffer.Init;
            FieldContentBuffer.Value := CopyStr(FieldValueText,1,250);
            FieldContentBuffer.Insert;
          end;
    end;

    local procedure IsFlowField(FieldRef: FieldRef): Boolean
    var
        OptionVar: Option Normal,FlowFilter,FlowField;
    begin
        Evaluate(OptionVar,Format(FieldRef.Class));
        exit(OptionVar = OptionVar::FlowField);
    end;

    local procedure IsEUCompany(CompanyInformation: Record "Company Information"): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if not CountryRegion.Get(CompanyInformation."Country/Region Code") then
          exit(false);

        exit(CountryRegion."EU Country/Region Code" <> '');
    end;

    procedure SyncAllFieldsFromNotification(Notification: Notification)
    begin
        SyncAllFields;
        CheckForUnclassifiedFields;
    end;

    procedure SyncAllFields()
    var
        "Field": Record "Field";
    begin
        RunSync(Field);
    end;

    local procedure CheckForUnclassifiedFields()
    var
        DataSensitivity: Record "Data Sensitivity";
        CompanyInformation: Record "Company Information";
    begin
        if not DataSensitivity.WritePermission then
          exit;

        DataSensitivity.SetRange("Company Name",CompanyName);
        DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
        if DataSensitivity.IsEmpty then
          exit;

        if CompanyInformation.Get then;
        if CompanyInformation."Demo Company" then
          exit;

        FireUnclassifiedFieldsNotification;
    end;

    [EventSubscriber(ObjectType::Page, 2501, 'OnAfterActionEvent', 'Install', true, true)]
    local procedure AfterExtensionIsInstalled(var Rec: Record "NAV App")
    var
        DataSensitivity: Record "Data Sensitivity";
        NAVAppObjectMetadata: Record "NAV App Object Metadata";
        "Field": Record "Field";
        FilterText: Text;
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        if DataSensitivity.IsEmpty then
          exit;

        NAVAppObjectMetadata.SetRange("App Package ID",Rec."Package ID");
        NAVAppObjectMetadata.SetRange("Object Type",NAVAppObjectMetadata."Object Type"::Table);
        if NAVAppObjectMetadata.FindSet then begin
          repeat
            FilterText += StrSubstNo('%1|',NAVAppObjectMetadata."Object ID");
          until NAVAppObjectMetadata.Next = 0;

          // Remove the last '|' character
          FilterText := DelChr(FilterText,'>','|');
          Field.SetFilter(TableNo,FilterText);
          SetFilterOnField(Field);
          if Field.FindSet then begin
            repeat
              if not DataSensitivity.Get(CompanyName,Field.TableNo,Field."No.") then begin
                DataSensitivity.Init;
                DataSensitivity."Company Name" := CompanyName;
                DataSensitivity."Table No" := Field.TableNo;
                DataSensitivity."Field No" := Field."No.";
                DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Unclassified;
                DataSensitivity.Insert;
              end;
            until Field.Next = 0;
            CheckForUnclassifiedFields;
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, 2501, 'OnAfterActionEvent', 'Uninstall', true, true)]
    local procedure AfterExtensionIsUninstalled(var Rec: Record "NAV App")
    var
        DataSensitivity: Record "Data Sensitivity";
        NAVAppObjectMetadata: Record "NAV App Object Metadata";
        FilterText: Text;
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        if DataSensitivity.IsEmpty then
          exit;

        // Remove the fields from the Data Sensitivity table without a confirmation through a notification
        // as it should be quite fast to do so.
        NAVAppObjectMetadata.SetRange("App Package ID",Rec."Package ID");
        NAVAppObjectMetadata.SetRange("Object Type",NAVAppObjectMetadata."Object Type"::Table);
        if NAVAppObjectMetadata.FindSet then begin
          repeat
            FilterText += StrSubstNo('%1|',NAVAppObjectMetadata."Object ID");
          until NAVAppObjectMetadata.Next = 0;

          // Remove the last '|' character
          FilterText := DelChr(FilterText,'>','|');

          DataSensitivity.SetFilter("Table No",FilterText);
          DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
          DataSensitivity.DeleteAll;
        end;
    end;

    procedure OpenClassificationWorksheetPage(Notification: Notification)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
        PAGE.Run(PAGE::"Data Classification Worksheet",DataSensitivity);
    end;

    local procedure SetFilterOnField(var "Field": Record "Field")
    begin
        Field.SetRange(Enabled,true);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        Field.SetRange(Class,Field.Class::Normal);
        Field.SetFilter(DataClassification,StrSubstNo('%1|%2|%3',
            Field.DataClassification::CustomerContent,
            Field.DataClassification::EndUserIdentifiableInformation,
            Field.DataClassification::EndUserPseudonymousIdentifiers));
    end;

    procedure RunSync("Field": Record "Field")
    var
        DataSensitivity: Record "Data Sensitivity";
        TempDataSensitivity: Record "Data Sensitivity" temporary;
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        DataSensitivity.SetRange("Company Name",CompanyName);
        if DataSensitivity.IsEmpty then begin
          FillDataSensitivityTable;
          exit;
        end;

        SetFilterOnField(Field);
        if Field.FindSet then begin
          // Read all records from Data Sensitivity into Temp var
          if DataSensitivity.FindSet then
            repeat
              TempDataSensitivity.TransferFields(DataSensitivity,true);
              TempDataSensitivity.Insert;
            until DataSensitivity.Next = 0;

          repeat
            if not TempDataSensitivity.Get(CompanyName,Field.TableNo,Field."No.") then begin
              DataSensitivity.Init;
              DataSensitivity."Company Name" := CompanyName;
              DataSensitivity."Table No" := Field.TableNo;
              DataSensitivity."Field No" := Field."No.";
              DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Unclassified;
              DataSensitivity.Insert;
            end else
              TempDataSensitivity.Delete;
          until Field.Next = 0;
        end;

        if TempDataSensitivity.FindSet then
          repeat
            if TempDataSensitivity."Data Sensitivity" = TempDataSensitivity."Data Sensitivity"::Unclassified then begin
              DataSensitivity.Get(TempDataSensitivity."Company Name",TempDataSensitivity."Table No",TempDataSensitivity."Field No");
              DataSensitivity.Delete;
            end;
          until TempDataSensitivity.Next = 0;

        if FieldsSyncStatus.Get then begin
          FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime;
          FieldsSyncStatus.Modify;
        end else begin
          FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime;
          FieldsSyncStatus.Insert;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOpenExcelSheet(var ExcelBuffer: Record "Excel Buffer";var ShouldOpenFile: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUploadExcelSheet(var ExcelBuffer: Record "Excel Buffer";var ShouldUploadFile: Boolean)
    begin
    end;

    procedure ShowNotifications()
    var
        DataSensitivity: Record "Data Sensitivity";
        Vendor: Record Vendor;
        Customer: Record Customer;
        Employee: Record Employee;
        Contact: Record Contact;
        Resource: Record Resource;
        CompanyInformation: Record "Company Information";
        IdentityManagement: Codeunit "Identity Management";
    begin
        if IdentityManagement.IsInvAppId then
          exit;

        if not DataSensitivity.WritePermission then
          exit;

        if CompanyInformation.Get then;
        if CompanyInformation."Demo Company" then
          exit;

        DataSensitivity.SetRange("Company Name",CompanyName);
        if DataSensitivity.IsEmpty then begin
          if IsEUCompany(CompanyInformation) then begin
            FireDataClassificationNotification(CompanyTok);
            exit;
          end;

          CountryRegion.SetFilter("EU Country/Region Code",'<>%1','');
          if CountryRegion.FindSet then
            repeat
              CountryCodeFilter += StrSubstNo('%1|',CountryRegion.Code);
            until CountryRegion.Next = 0;

          if CountryCodeFilter = '' then
            exit;

          CountryCodeFilter := DelChr(CountryCodeFilter,'>','|');

          Vendor.SetRange("Partner Type",Vendor."Partner Type"::Person);
          Vendor.SetFilter("Country/Region Code",CountryCodeFilter);
          if Vendor.FindFirst then begin
            FireDataClassificationNotification(VendorsTok);
            exit;
          end;

          Customer.SetRange("Partner Type",Customer."Partner Type"::Person);
          Customer.SetFilter("Country/Region Code",CountryCodeFilter);
          if Customer.FindFirst then begin
            FireDataClassificationNotification(CustomersTok);
            exit;
          end;

          Contact.SetRange(Type,Contact.Type::Person);
          Contact.SetFilter("Country/Region Code",CountryCodeFilter);
          if Contact.FindFirst then begin
            FireDataClassificationNotification(ContactsTok);
            exit;
          end;

          Resource.SetRange(Type,Resource.Type::Person);
          Resource.SetFilter("Country/Region Code",CountryCodeFilter);
          if Resource.FindFirst then begin
            FireDataClassificationNotification(ResourcesTok);
            exit;
          end;

          Employee.SetFilter("Country/Region Code",CountryCodeFilter);
          if Employee.FindFirst then begin
            FireDataClassificationNotification(EmployeesTok);
            exit;
          end;
          exit;
        end;

        DataSensitivity.SetRange("Data Sensitivity",DataSensitivity."Data Sensitivity"::Unclassified);
        if DataSensitivity.FindFirst then begin
          FireUnclassifiedFieldsNotification;
          exit;
        end;

        ShowSyncFieldsNotification;
    end;

    procedure DisableNotifications(Notification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        case Notification.Id of
          GetDataClassificationNotificationId:
            MyNotifications.InsertDefault(
              Notification.Id,
              ReviewPrivacySettingsNotificationTxt,
              ReviewPrivacySettingsNotificationDescriptionTxt,
              false);
          GetSyncFieldsNotificationId:
            MyNotifications.InsertDefault(
              Notification.Id,
              SyncFieldsReminderNotificationTxt,
              SyncFieldsReminderNotificationDescriptionTxt,
              false);
          GetUnclassifiedFieldsNotificationId:
            MyNotifications.InsertDefault(
              Notification.Id,
              UnclassifiedFieldsNotificationTxt,
              UnclassifiedFieldsNotificationDescriptionTxt,
              false);
        end;

        MyNotifications.Disable(Notification.Id);
    end;

    procedure ShowSyncFieldsNotification()
    var
        FieldsSyncStatus: Record "Fields Sync Status";
        CompanyInformation: Record "Company Information";
        DaysSinceLastSync: Integer;
    begin
        if not FieldsSyncStatus.WritePermission then
          exit;

        if CompanyInformation.Get then;
        if CompanyInformation."Demo Company" then
          exit;

        if FieldsSyncStatus.Get then begin
          DaysSinceLastSync := Round((CurrentDateTime - FieldsSyncStatus."Last Sync Date Time") / 1000 / 3600 / 24,1);
          if DaysSinceLastSync > 30 then
            FireSyncFieldsNotification(DaysSinceLastSync);
        end;
    end;

    procedure GetDataSensitivityOptionString(): Text
    begin
        exit(DataSensitivityOptionStringTxt);
    end;

    procedure SetSensitivities(var DataSensitivity: Record "Data Sensitivity";Sensitivity: Option)
    var
        Now: DateTime;
    begin
        // MODIFYALL does not result in a bulk query for this table, looping through the records perfoms faster
        // and eliminates issues with the filters of the record
        Now := CurrentDateTime;
        if DataSensitivity.FindSet then
          repeat
            DataSensitivity."Data Sensitivity" := Sensitivity;
            DataSensitivity."Last Modified By" := UserSecurityId;
            DataSensitivity."Last Modified" := Now;
            DataSensitivity.Modify;
          until DataSensitivity.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetLegalDisclaimerTxt(): Text
    begin
        exit(LegalDisclaimerTxt);
    end;

    [Scope('Personalization')]
    procedure SetTableFieldsToNormal(TableNumber: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
        "Field": Record "Field";
    begin
        Field.SetRange(TableNo,TableNumber);
        Field.SetFilter(
          DataClassification,
          StrSubstNo('%1|%2|%3',
            Field.DataClassification::CustomerContent,
            Field.DataClassification::EndUserIdentifiableInformation,
            Field.DataClassification::EndUserPseudonymousIdentifiers));
        if Field.FindSet then
          repeat
            if DataSensitivity.Get(CompanyName,Field.TableNo,Field."No.") then begin
              DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Normal;
              DataSensitivity.Modify;
            end else begin
              DataSensitivity."Company Name" := CompanyName;
              DataSensitivity."Table No" := Field.TableNo;
              DataSensitivity."Field No" := Field."No.";
              DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Normal;
              DataSensitivity.Insert;
            end;
          until Field.Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetFieldToPersonal(TableNo: Integer;FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if DataSensitivity.Get(CompanyName,TableNo,FieldNo) then begin
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Personal;
          DataSensitivity.Modify;
        end else begin
          DataSensitivity."Company Name" := CompanyName;
          DataSensitivity."Table No" := TableNo;
          DataSensitivity."Field No" := FieldNo;
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Personal;
          DataSensitivity.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFieldToSensitive(TableNo: Integer;FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if DataSensitivity.Get(CompanyName,TableNo,FieldNo) then begin
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Sensitive;
          DataSensitivity.Modify;
        end else begin
          DataSensitivity."Company Name" := CompanyName;
          DataSensitivity."Table No" := TableNo;
          DataSensitivity."Field No" := FieldNo;
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Sensitive;
          DataSensitivity.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFieldToCompanyConfidential(TableNo: Integer;FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if DataSensitivity.Get(CompanyName,TableNo,FieldNo) then begin
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::"Company Confidential";
          DataSensitivity.Modify;
        end else begin
          DataSensitivity."Company Name" := CompanyName;
          DataSensitivity."Table No" := TableNo;
          DataSensitivity."Field No" := FieldNo;
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::"Company Confidential";
          DataSensitivity.Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure SetFieldToNormal(TableNo: Integer;FieldNo: Integer)
    var
        DataSensitivity: Record "Data Sensitivity";
    begin
        if DataSensitivity.Get(CompanyName,TableNo,FieldNo) then begin
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Normal;
          DataSensitivity.Modify;
        end else begin
          DataSensitivity."Company Name" := CompanyName;
          DataSensitivity."Table No" := TableNo;
          DataSensitivity."Field No" := FieldNo;
          DataSensitivity."Data Sensitivity" := DataSensitivity."Data Sensitivity"::Normal;
          DataSensitivity.Insert;
        end;
    end;
}

