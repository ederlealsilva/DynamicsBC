codeunit 1180 "Data Privacy Mgmt"
{
    // version NAVW113.00


    trigger OnRun()
    var
        ActivityLog: Record "Activity Log";
        ActivityLogPage: Page "Activity Log";
    begin
        Clear(ActivityLogPage);
        ActivityLog.FilterGroup(2);
        ActivityLog.SetRange(Context,ActivityContextTxt);
        ActivityLog.FilterGroup(0);
        ActivityLogPage.SetTableView(ActivityLog);
        ActivityLogPage.Run;
    end;

    var
        DataPrivacyEntities: Record "Data Privacy Entities";
        ConfigProgressBar: Codeunit "Config. Progress Bar";
        ActivityContextTxt: Label 'Privacy Activity';
        CreatingFieldDataTxt: Label 'Creating field data...';
        RemovingConfigPackageTxt: Label 'Removing config package...';
        ConfigDeleteStatusTxt: Label 'records.';
        TypeHelper: Codeunit "Type Helper";
        ProgressBarText: Text;

    procedure InitRecords(EntityTypeTableNo: Integer;EntityNo: Code[50];var PackageCode: Code[20];ActionType: Option "Export a data subject's data","Create a data privacy configuration package";GeneratePreview: Boolean;DataSensitivityOption: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified)
    begin
        CreateData(EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
    end;

    procedure CreateData(EntityTypeTableNo: Integer;EntityNo: Code[50];var PackageCode: Code[20];ActionType: Option "Export a data subject's data","Create a data privacy configuration package";GeneratePreview: Boolean;DataSensitivityOption: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified)
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        Resource: Record Resource;
        Employee: Record Employee;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        User: Record User;
        UserSetup: Record "User Setup";
        RecRef: RecordRef;
    begin
        case EntityTypeTableNo of
          DATABASE::Customer:
            if Customer.Get(Format(EntityNo,20)) then begin
              RecRef.GetTable(Customer);
              CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
            end;
          DATABASE::Vendor:
            if Vendor.Get(Format(EntityNo,20)) then begin
              RecRef.GetTable(Vendor);
              CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
            end;
          DATABASE::Contact:
            if Contact.Get(Format(EntityNo,20)) then begin
              RecRef.GetTable(Contact);
              CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
            end;
          DATABASE::Resource:
            if Resource.Get(Format(EntityNo,20)) then begin
              RecRef.GetTable(Resource);
              CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
            end;
          DATABASE::Employee:
            if Employee.Get(Format(EntityNo,20)) then begin
              RecRef.GetTable(Employee);
              CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
            end;
          DATABASE::"Salesperson/Purchaser":
            if SalespersonPurchaser.Get(Format(EntityNo,20)) then begin
              RecRef.GetTable(SalespersonPurchaser);
              CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
            end;
          DATABASE::User:
            begin
              User.SetRange("User Name",EntityNo);
              if User.FindFirst then
                if UserSetup.Get(EntityNo) then begin
                  // Redirect to use the User Setup table
                  EntityTypeTableNo := DATABASE::"User Setup";
                  RecRef.GetTable(UserSetup);
                  CreateRelatedData(RecRef,EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
                end;
            end;
          else
            OnCreateData(EntityTypeTableNo,EntityNo,PackageCode,ActionType,GeneratePreview,DataSensitivityOption);
        end;
    end;

    [Scope('Personalization')]
    procedure CreateRelatedData(var RecRef: RecordRef;EntityTypeTableNo: Integer;EntityNo: Code[50];var PackageCode: Code[20];ActionType: Option "Export a data subject's data","Create a data privacy configuration package";GeneratePreview: Boolean;DataSensitivityOption: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified)
    var
        ConfigPackage: Record "Config. Package";
        TableRelationsMetadata: Record "Table Relations Metadata";
        DataSensitivity: Record "Data Sensitivity";
        DataPrivacyListPage: Page "Data Privacy ListPage";
        LocalRecRef: RecordRef;
        FieldRef: FieldRef;
        LastTableID: Integer;
        ProcessingOrder: Integer;
        PackageName: Text[50];
        EntityKeyField: Integer;
        FieldIndex: Integer;
    begin
        PackageCode := GetPackageCode(EntityTypeTableNo,EntityNo,ActionType);
        PackageName :=
          CopyStr(Format('Privacy Package for ' + Format(RecRef.Caption,10) + ' ' + DelChr(Format(EntityNo,20),'<',' ')),1,50);

        if ConfigPackage.Get(PackageCode) then begin
          if ActionType = ActionType::"Export a data subject's data" then begin
            // Recreate the package if they chose the option to create the config package or are using the "temp" config package,
            // otherwise use the one already created
            if StrPos(PackageCode,'*') = 0 then
              exit;
            DeletePackage(PackageCode);
          end;
          // I could not get PreCAL to like this logic in it's original form, which is why I have this extra IF statement...
          if ActionType = ActionType::"Create a data privacy configuration package" then
            DeletePackage(PackageCode);
        end;

        CreateEntities;
        if EntityTypeTableNo = DATABASE::"User Setup" then
          EntityTypeTableNo := DATABASE::User;

        if DataPrivacyEntities.Get(EntityTypeTableNo) then
          if EntityTypeTableNo = DATABASE::User then begin
            EntityKeyField := 1;
            EntityTypeTableNo := DATABASE::"User Setup";
          end else
            EntityKeyField := DataPrivacyEntities."Key Field No.";

        CreatePackage(ConfigPackage,PackageCode,PackageName);
        CreatePackageTable(PackageCode,EntityTypeTableNo);

        if OpenRecRef(LocalRecRef,EntityTypeTableNo) then begin
          for FieldIndex := 1 to LocalRecRef.FieldCount do
            if GetFieldRef(FieldRef,LocalRecRef,FieldIndex) then
              if IsInPrimaryKey(FieldRef) then begin
                ProcessingOrder += 1;
                CreatePackageField(ConfigPackage.Code,EntityTypeTableNo,FieldRef.Number,ProcessingOrder);
                CreatePackageFilter(ConfigPackage.Code,EntityTypeTableNo,EntityKeyField,Format(EntityNo));
              end;
          LocalRecRef.Close;
        end;

        // This will handle the fields on the master table.
        SetRangeDataSensitivity(DataSensitivity,RecRef.Number,DataSensitivityOption);
        if DataSensitivity.FindSet then begin
          repeat
            CreatePackageTable(PackageCode,DataSensitivity."Table No");

            ProcessingOrder += 1;
            CreatePackageField(PackageCode,DataSensitivity."Table No",DataSensitivity."Field No",ProcessingOrder);
          until DataSensitivity.Next = 0;
        end;

        // Now we handle the conditional and unconditional relations.
        SetRangeTableRelationsMetadata(TableRelationsMetadata,RecRef,EntityKeyField);

        ConfigProgressBar.Init(TableRelationsMetadata.Count,1,CreatingFieldDataTxt);

        if TableRelationsMetadata.FindSet then begin
          CreatePackage(ConfigPackage,PackageCode,PackageName);
          CreateRelatedDataFields(TableRelationsMetadata,ConfigPackage,EntityNo,LastTableID,DataSensitivityOption);
        end;

        // Now to handle the change log entries.
        CreateDataForChangeLogEntries(PackageCode,EntityNo,EntityTypeTableNo);

        ConfigProgressBar.Close;

        if GeneratePreview then
          DataPrivacyListPage.GeneratePreviewData(PackageCode);
    end;

    procedure DeletePackage(PackageCode: Code[20])
    var
        ConfigPackage: Record "Config. Package";
    begin
        ConfigProgressBar.Init(4,1,RemovingConfigPackageTxt);

        ProgressBarText := Format(ConfigPackage.TableCaption) + ' ' + ConfigDeleteStatusTxt;
        ConfigProgressBar.Update(ProgressBarText);
        ConfigPackage.SetRange(Code,PackageCode);
        ConfigPackage.DeleteAll(true);

        ConfigProgressBar.Close;
    end;

    procedure CreateEntities()
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataPrivacyEntities.Reset;
        DataPrivacyEntities.DeleteAll;
        DataClassificationMgt.OnGetPrivacyMasterTables(DataPrivacyEntities);
    end;

    procedure SetPrivacyBlocked(EntityTypeTableNo: Integer;EntityNo: Code[50])
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        Resource: Record Resource;
        Employee: Record Employee;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        case EntityTypeTableNo of
          DATABASE::Customer:
            if Customer.Get(EntityNo) then
              if not Customer."Privacy Blocked" then begin
                Customer.Validate("Privacy Blocked",true);
                if Customer.Modify then;
              end;
          DATABASE::Vendor:
            if Vendor.Get(EntityNo) then
              if not Vendor."Privacy Blocked" then begin
                Vendor.Validate("Privacy Blocked",true);
                if Vendor.Modify then;
              end;
          DATABASE::Contact:
            if Contact.Get(EntityNo) then
              if not Contact."Privacy Blocked" then begin
                Contact.Validate("Privacy Blocked",true);
                if Contact.Modify then;
              end;
          DATABASE::Resource:
            if Resource.Get(EntityNo) then
              if not Resource."Privacy Blocked" then begin
                Resource.Validate("Privacy Blocked",true);
                if Resource.Modify then;
              end;
          DATABASE::Employee:
            if Employee.Get(EntityNo) then
              if not Employee."Privacy Blocked" then begin
                Employee.Validate("Privacy Blocked",true);
                if Employee.Modify then;
              end;
          DATABASE::"Salesperson/Purchaser":
            if SalespersonPurchaser.Get(EntityNo) then
              if not SalespersonPurchaser."Privacy Blocked" then begin
                SalespersonPurchaser.Validate("Privacy Blocked",true);
                if SalespersonPurchaser.Modify then;
              end;
          else
            OnAfterSetPrivacyBlocked(EntityTypeTableNo,EntityNo);
        end;
    end;

    procedure GetPackageCode(EntityTypeTableNo: Integer;EntityNo: Code[50];ActionType: Option "Export a data subject's data","Create a data privacy configuration package"): Code[20]
    var
        ConfigPackage: Record "Config. Package";
        TempEntityNumber: Code[17];
        PackageCodeTemp: Code[20];
        PackageCodeKeep: Code[20];
    begin
        if StrLen(EntityNo) >= 18 then
          TempEntityNumber := CopyStr(EntityNo,(StrLen(EntityNo) mod 17) + 1,(StrLen(EntityNo) - (StrLen(EntityNo) mod 17)))
        else
          TempEntityNumber := CopyStr(EntityNo,1,StrLen(EntityNo));

        case EntityTypeTableNo of
          DATABASE::Customer:
            begin
              PackageCodeKeep := 'CUS' + TempEntityNumber;
              PackageCodeTemp := 'CU*' + TempEntityNumber;
            end;
          DATABASE::Vendor:
            begin
              PackageCodeKeep := 'VEN' + TempEntityNumber;
              PackageCodeTemp := 'VE*' + TempEntityNumber;
            end;
          DATABASE::Contact:
            begin
              PackageCodeKeep := 'CON' + TempEntityNumber;
              PackageCodeTemp := 'CO*' + TempEntityNumber;
            end;
          DATABASE::Resource:
            begin
              PackageCodeKeep := 'RES' + TempEntityNumber;
              PackageCodeTemp := 'RE*' + TempEntityNumber;
            end;
          DATABASE::Employee:
            begin
              PackageCodeKeep := 'EMP' + TempEntityNumber;
              PackageCodeTemp := 'EM*' + TempEntityNumber;
            end;
          DATABASE::"Salesperson/Purchaser":
            begin
              PackageCodeKeep := 'SPC' + TempEntityNumber;
              PackageCodeTemp := 'SP*' + TempEntityNumber;
            end;
          DATABASE::"User Setup":
            begin
              PackageCodeKeep := 'USR' + TempEntityNumber;
              PackageCodeTemp := 'US*' + TempEntityNumber;
            end;
          else
            OnAfterGetPackageCode(EntityTypeTableNo,EntityNo,ActionType,PackageCodeTemp,PackageCodeKeep);
        end;

        if ActionType = ActionType::"Create a data privacy configuration package" then
          exit(PackageCodeKeep);
        if ActionType = ActionType::"Export a data subject's data" then begin
          if ConfigPackage.Get(PackageCodeKeep) then
            exit(PackageCodeKeep);

          exit(PackageCodeTemp);
        end;
    end;

    local procedure CreatePackage(var ConfigPackage: Record "Config. Package";PackageCode: Code[20];PackageName: Text[50])
    var
        LanguageManagement: Codeunit LanguageManagement;
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        ConfigPackage.Init;
        ConfigPackage.Validate(Code,PackageCode);
        ConfigPackage.Validate("Package Name",PackageName);
        ConfigPackage."Language ID" := LanguageManagement.ApplicationLanguage;
        ConfigPackage."Product Version" :=
          CopyStr(ApplicationSystemConstants.ApplicationVersion,1,StrLen(ConfigPackage."Product Version"));
        if not ConfigPackage.Insert(true) then;
    end;

    local procedure CreatePackageTable(PackageCode: Code[20];TableId: Integer)
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackageTable.Init;
        ConfigPackageTable.Validate("Package Code",PackageCode);
        ConfigPackageTable.Validate("Table ID",TableId);
        if not ConfigPackageTable.Insert then;  // Do NOT fire the trigger as it will create the ConfigPackageField
    end;

    local procedure CreatePackageField(ConfigPackageCode: Code[20];TableId: Integer;FieldId: Integer;ProcessingOrder: Integer): Boolean
    var
        ConfigPackageField: Record "Config. Package Field";
        "Field": Record "Field";
    begin
        if IsValidField(TableId,FieldId,Field) then begin
          InitPackageField(ConfigPackageField,Field,ConfigPackageCode,TableId,ProcessingOrder,FieldId);
          exit(ConfigPackageField.Insert(true));
        end;
    end;

    local procedure CreatePackageFilter(ConfigPackageCode: Code[20];TableId: Integer;EntityKeyField: Integer;FieldValue: Text[250]): Boolean
    var
        "Field": Record "Field";
        ConfigPackageFilter: Record "Config. Package Filter";
        ConfigPackage: Record "Config. Package";
    begin
        if ConfigPackage.Get(ConfigPackageCode) then
          if TypeHelper.GetField(TableId,EntityKeyField,Field) then
            if (Field.Class = Field.Class::Normal) and
               ((Field.Type = Field.Type::Integer) or (Field.Type = Field.Type::Text) or
                (Field.Type = Field.Type::Code) or (Field.Type = Field.Type::Option))
            then begin
              InitPackageFilter(ConfigPackageFilter,ConfigPackageCode,TableId,EntityKeyField,FieldValue);
              exit(ConfigPackageFilter.Insert(true));
            end;
    end;

    local procedure IsValidField(TableId: Integer;FieldId: Integer;var "Field": Record "Field"): Boolean
    begin
        if TypeHelper.GetField(TableId,FieldId,Field) then
          if (not ((Field.Type = Field.Type::Media) or
                   (Field.Type = Field.Type::MediaSet) or (Field.Type = Field.Type::BLOB) or (Field.Type = Field.Type::GUID))) and
             (Field.Class = Field.Class::Normal)
          then
            exit(true);
    end;

    local procedure IsInPrimaryKey(FieldRef: FieldRef): Boolean
    var
        RecRef: RecordRef;
        KeyRef: KeyRef;
        FieldIndex: Integer;
    begin
        RecRef := FieldRef.Record;

        KeyRef := RecRef.KeyIndex(1);
        for FieldIndex := 1 to KeyRef.FieldCount do
          if KeyRef.FieldIndex(FieldIndex).Number = FieldRef.Number then
            exit(true);

        exit(false);
    end;

    local procedure SetRangeTableRelationsMetadata(var TableRelationsMetadata: Record "Table Relations Metadata";RecRef: RecordRef;EntityKeyField: Integer)
    begin
        TableRelationsMetadata.Reset;
        TableRelationsMetadata.SetRange("Related Table ID",RecRef.Number);
        TableRelationsMetadata.SetRange("Related Field No.",EntityKeyField);
        TableRelationsMetadata.SetRange("Validate Table Relation",true);
        TableRelationsMetadata.SetRange("Condition Field No.",0);
        TableRelationsMetadata.SetFilter("Table ID",'<>%1',RecRef.Number); // More than one filter causes no records to be returned
    end;

    local procedure SetRangeDataSensitivity(var DataSensitivity: Record "Data Sensitivity";TableID: Integer;DataSensitivityOption: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified)
    begin
        DataSensitivity.Reset;
        DataSensitivity.SetRange("Company Name",CompanyName);
        DataSensitivity.SetRange("Table No",TableID);
        case DataSensitivityOption of
          DataSensitivityOption::Sensitive:
            DataSensitivity.SetFilter("Data Sensitivity",'%1',DataSensitivity."Data Sensitivity"::Sensitive);
          DataSensitivityOption::Personal:
            DataSensitivity.SetFilter("Data Sensitivity",'%1|%2',
              DataSensitivity."Data Sensitivity"::Sensitive,
              DataSensitivity."Data Sensitivity"::Personal);
          DataSensitivityOption::"Company Confidential":
            DataSensitivity.SetFilter("Data Sensitivity",'%1|%2|%3',
              DataSensitivity."Data Sensitivity"::Sensitive,
              DataSensitivity."Data Sensitivity"::Personal,
              DataSensitivity."Data Sensitivity"::"Company Confidential");
          DataSensitivityOption::Normal:
            DataSensitivity.SetFilter("Data Sensitivity",'%1|%2|%3|%4',
              DataSensitivity."Data Sensitivity"::Sensitive,
              DataSensitivity."Data Sensitivity"::Personal,
              DataSensitivity."Data Sensitivity"::"Company Confidential",
              DataSensitivity."Data Sensitivity"::Normal);
          DataSensitivityOption::Unclassified:
            DataSensitivity.SetFilter("Data Sensitivity",'%1',DataSensitivity."Data Sensitivity"::Unclassified);
        end;
    end;

    local procedure CreateRelatedDataFields(var TableRelationsMetadata: Record "Table Relations Metadata";var ConfigPackage: Record "Config. Package";EntityNo: Code[50];var LastTableID: Integer;DataSensitivityOption: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified)
    var
        DataSensitivity: Record "Data Sensitivity";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ProcessingOrder: Integer;
        FilterCreated: Boolean;
        FieldIndex: Integer;
        TableIDProcessed: Integer;
    begin
        repeat
          ConfigProgressBar.Update(TableRelationsMetadata.TableName);

          // Create the fields for the primary key fields first...
          if (TableIDProcessed <> TableRelationsMetadata."Table ID") and OpenRecRef(RecRef,TableRelationsMetadata."Table ID") then begin
            TableIDProcessed := TableRelationsMetadata."Table ID";
            for FieldIndex := 1 to RecRef.FieldCount do
              if GetFieldRef(FieldRef,RecRef,FieldIndex) then
                if IsInPrimaryKey(FieldRef) then begin
                  ProcessingOrder += 1;
                  CreatePackageField(ConfigPackage.Code,TableRelationsMetadata."Table ID",FieldRef.Number,ProcessingOrder);
                end;
            RecRef.Close;
          end;

          FilterCreated := false;

          FilterCreated :=
            CreatePackageFilter(ConfigPackage.Code,TableRelationsMetadata."Table ID",TableRelationsMetadata."Field No.",EntityNo);

          if FilterCreated then begin
            ProcessingOrder += 1;
            CreatePackageField(
              ConfigPackage.Code,TableRelationsMetadata."Table ID",TableRelationsMetadata."Field No.",ProcessingOrder);
          end;

          if FilterCreated then
            if LastTableID <> TableRelationsMetadata."Table ID" then begin
              CreatePackageTable(ConfigPackage.Code,TableRelationsMetadata."Table ID");
              LastTableID := TableRelationsMetadata."Table ID";

              SetRangeDataSensitivity(DataSensitivity,LastTableID,DataSensitivityOption);
              if DataSensitivity.FindSet then begin
                repeat
                  ProcessingOrder += 1;
                  CreatePackageField(ConfigPackage.Code,DataSensitivity."Table No",DataSensitivity."Field No",ProcessingOrder);
                until DataSensitivity.Next = 0;
              end;
            end;

        until TableRelationsMetadata.Next = 0;
    end;

    [TryFunction]
    local procedure OpenRecRef(var RecRef: RecordRef;TableNo: Integer)
    begin
        RecRef.Open(TableNo);
    end;

    [TryFunction]
    local procedure GetFieldRef(var FieldRef: FieldRef;var RecordRef: RecordRef;FieldIndex: Integer)
    begin
        FieldRef := RecordRef.FieldIndex(FieldIndex);
    end;

    local procedure InitPackageField(var ConfigPackageField: Record "Config. Package Field";var "Field": Record "Field";PackageCode: Code[20];TableId: Integer;ProcessingOrder: Integer;FieldId: Integer)
    begin
        ConfigPackageField.Init;
        ConfigPackageField.Validate("Package Code",PackageCode);
        ConfigPackageField.Validate("Table ID",TableId);
        ConfigPackageField.Validate("Field Name",Field.FieldName);
        ConfigPackageField.Validate("Field Caption",Field."Field Caption");
        ConfigPackageField.Validate("Field ID",FieldId);
        ConfigPackageField.Validate("Validate Field",true);
        ConfigPackageField.Validate("Include Field",true);
        ConfigPackageField.Validate("Processing Order",ProcessingOrder);
    end;

    local procedure InitPackageFilter(var ConfigPackageFilter: Record "Config. Package Filter";ConfigPackageCode: Code[20];TableNo: Integer;EntityKeyField: Integer;FieldValue: Text[250])
    var
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
    begin
        ConfigPackageFilter.Init;
        ConfigPackageFilter.Validate("Package Code",ConfigPackageCode);
        ConfigPackageFilter.Validate("Table ID",TableNo);
        ConfigPackageFilter.Validate("Field ID",EntityKeyField);
        case TableNo of
          DATABASE::Contact,
          DATABASE::"Contact Alt. Address",
          DATABASE::"Sales Header",
          DATABASE::"Purchase Header",
          DATABASE::"Sales Shipment Header",
          DATABASE::"Sales Invoice Header",
          DATABASE::"Sales Cr.Memo Header",
          DATABASE::"Purch. Rcpt. Header",
          DATABASE::"Purch. Inv. Header",
          DATABASE::"Purch. Cr. Memo Hdr.",
          DATABASE::"Sales Header Archive",
          DATABASE::"Purchase Header Archive",
          DATABASE::"Sales Invoice Entity Aggregate",
          DATABASE::"Sales Order Entity Buffer",
          DATABASE::"Sales Quote Entity Buffer",
          DATABASE::"Sales Cr. Memo Entity Buffer",
          DATABASE::"Service Header",
          DATABASE::"Service Contract Header",
          DATABASE::"Service Shipment Header",
          DATABASE::"Service Invoice Header",
          DATABASE::"Service Cr.Memo Header",
          DATABASE::"Return Shipment Header",
          DATABASE::"Return Receipt Header",
          DATABASE::"Interaction Log Entry":
            if ContactPerson.Get(Format(FieldValue,20)) then // FieldValue is the EntityNo for this method
              if ContactCompany.Get(ContactPerson."Company No.") then
                FieldValue := FieldValue + ' | ' + ContactCompany."No.";
        end;
        ConfigPackageFilter.Validate("Field Filter",Format(FieldValue));
    end;

    local procedure CreateDataForChangeLogEntries(PackageCode: Code[20];EntityNo: Code[50];EntityTableID: Integer)
    var
        ConfigPackage: Record "Config. Package";
        ChangeLogEntry: Record "Change Log Entry";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageFilter: Record "Config. Package Filter";
    begin
        if ConfigPackage.Get(PackageCode) then begin
          // Create package table for Change Log table (405)
          ConfigPackageTable.Init;
          ConfigPackageTable.Validate("Package Code",PackageCode);
          ConfigPackageTable.Validate("Table ID",DATABASE::"Change Log Entry");
          if not ConfigPackageTable.Insert(true) then;  // Fire the trigger as it will create the ConfigPackageField

          // Create package filter for Table No = Change Log table (405) AND Primary key Field 1 value = Entity No
          ConfigPackageFilter.Init;
          ConfigPackageFilter.Validate("Package Code",PackageCode);
          ConfigPackageFilter.Validate("Table ID",DATABASE::"Change Log Entry");
          ConfigPackageFilter.Validate("Field ID",ChangeLogEntry.FieldNo("Table No.")); // Table No. field.
          ConfigPackageFilter.Validate("Field Filter",Format(EntityTableID)); // Need to pass in table number from entity
          if not ConfigPackageFilter.Insert(true) then;

          ConfigPackageFilter.Init;
          ConfigPackageFilter.Validate("Package Code",PackageCode);
          ConfigPackageFilter.Validate("Table ID",DATABASE::"Change Log Entry");
          ConfigPackageFilter.Validate("Field ID",ChangeLogEntry.FieldNo("Primary Key Field 1 Value")); // Primary Key Field 1 Value field.
          ConfigPackageFilter.Validate("Field Filter",Format(EntityNo));
          if not ConfigPackageFilter.Insert(true) then;
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnCreateData(EntityTypeTableNo: Integer;EntityNo: Code[50];var PackageCode: Code[20];ActionType: Option "Export a data subject's data","Create a data privacy configuration package";GeneratePreview: Boolean;DataSensitivity: Option Sensitive,Personal,"Company Confidential",Normal,Unclassified)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetPrivacyBlocked(EntityTypeTableNo: Integer;EntityNo: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPackageCode(EntityTypeTableNo: Integer;EntityNo: Code[50];ActionType: Option "Export a data subject's data","Create a data privacy configuration package";var PackageCodeTemp: Code[20];var PackageCodeKeep: Code[20])
    begin
    end;
}

