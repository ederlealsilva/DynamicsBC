codeunit 9170 "Conf./Personalization Mgt."
{
    // version NAVW113.00


    trigger OnRun()
    begin
        InitializeProfiles;
    end;

    var
        DeleteConfigurationChangesQst: Label 'This will delete all configuration changes made for this profile.  Do you want to continue?';
        DeletePersonalizationChangesQst: Label 'This will delete all personalization changes made by this user.  Do you want to continue?';
        NoDeleteProfileErr: Label 'You cannot delete a profile with default Role Center.';
        AccountingManagerProfileTxt: Label 'Accounting Manager';
        AccountingManagerDescriptionTxt: Label 'Accounting Manager';
        APCoordinatorProfileTxt: Label 'AP Coordinator';
        APCoordinatorDescriptionTxt: Label 'Accounts Payable Coordinator';
        ARAdministratorProfileTxt: Label 'AR Administrator';
        ARAdministratorDescriptionTxt: Label 'Accounts Receivable Administrator';
        BookkeeperProfileTxt: Label 'Bookkeeper';
        BookkeeperDescriptionTxt: Label 'Bookkeeper';
        SalesManagerProfileTxt: Label 'Sales Manager';
        SalesManagerDescriptionTxt: Label 'Sales Manager';
        OrderProcessorProfileTxt: Label 'Order Processor';
        SalesOrderProcessorDescriptionTxt: Label 'Sales Order Processor ';
        PurchasingAgentProfileTxt: Label 'Purchasing Agent';
        PurchasingAgentDescriptionTxt: Label 'Purchasing Agent';
        ShippingandReceivingWMSProfileTxt: Label 'Shipping and Receiving - WMS';
        ShippingandReceivingWMSDescriptionTxt: Label 'Shipping and Receiving - Warehouse Management System';
        ShippingandReceivingProfileTxt: Label 'Shipping and Receiving';
        ShippingandReceivingDescriptionTxt: Label 'Shipping and Receiving - Order-by-Order';
        WarehouseWorkerWMSProfileTxt: Label 'Warehouse Worker - WMS';
        WarehouseWorkerWMSDescriptionTxt: Label 'Warehouse Worker - Warehouse Management System';
        ProductionPlannerProfileTxt: Label 'Production Planner';
        ProductionPlannerDescriptionTxt: Label 'Production Planner';
        ShopSupervisorProfileTxt: Label 'Shop Supervisor';
        ShopSupervisorDescriptionTxt: Label 'Shop Supervisor - Manufacturing Comprehensive';
        ShopSupervisorFoundationProfileTxt: Label 'Shop Supervisor - Foundation';
        ShopSupervisorFoundationDescriptionTxt: Label 'Shop Supervisor - Manufacturing Foundation';
        MachineOperatorProfileTxt: Label 'Machine Operator';
        MachineOperatorDescriptionTxt: Label 'Machine Operator - Manufacturing Comprehensive';
        ResourceManagerProfileTxt: Label 'Resource Manager';
        ResourceManagerDescriptionTxt: Label 'Resource Manager';
        ProjectManagerProfileTxt: Label 'Project Manager';
        ProjectManagerDescriptionTxt: Label 'Project Manager';
        DispatcherProfileTxt: Label 'Dispatcher';
        DispatcherDescriptionTxt: Label 'Dispatcher - Customer Service';
        OutboundTechnicianProfileTxt: Label 'Outbound Technician';
        OutboundTechnicianDescriptionTxt: Label 'Outbound Technician - Customer Service';
        ITManagerProfileTxt: Label 'IT Manager';
        ITManagerDescriptionTxt: Label 'IT Manager';
        PresidentProfileTxt: Label 'President';
        PresidentDescriptionTxt: Label 'President ';
        PresidentSBProfileTxt: Label 'President - Small Business';
        PresidentSBDescriptionTxt: Label 'President - Small Business';
        RapidStartServicesProfileTxt: Label 'RapidStart Services';
        RapidStartServicesDescriptionTxt: Label 'RapidStart Services Implementer';
        AccountingServicesTxt: Label 'Accounting Services';
        AccountingServicesDescriptionTxt: Label 'Profile for users that have outsourced their Accounting';
        SecurityAdministratorTxt: Label 'Security Administrator';
        SecurityAdministratorDescriptionTxt: Label 'Administration of users, user groups and permissions';
        AccountantTxt: Label 'Accountant';
        AccountantDescriptionTxt: Label 'Accountant';
        BusinessManagerIDTxt: Label 'Business Manager';
        BusinessManagerDescriptionTxt: Label 'Business Manager';
        CannotDeleteDefaultUserProfileErr: Label 'You cannot delete this profile because it is set up as a default profile for one or more users or user groups.';
        XMLDOMManagement: Codeunit "XML DOM Management";
        RegEx: DotNet Regex;
        CultureInfo: DotNet CultureInfo;
        Convert: DotNet Convert;
        InstalledLanguages: DotNet StringCollection;
        DetectedLanguages: DotNet StringCollection;
        InfoForCompletionMessage: DotNet StringCollection;
        CurrentProfileID: Code[30];
        CurrentProfileDescription: Text[250];
        CurrentPageID: Integer;
        CurrentPersonalizationID: Code[40];
        ProfileResxFileNotFoundTxt: Label '%1  for Profile %2.', Comment='Tells the user that translated UI strings for a profile could not be found in a specific language.';
        ProfileResxFileNotFoundMsg: Label 'Could not find translated resources for the following language(s)\%1\This can happen if Profile ID is translated between languages.', Comment='Tells the user that translated UI strings for a given profile could not be found for one or more languages.';
        AttributesNodeNameTxt: Label 'Attributes', Locked=true;
        NodeNodeNameTxt: Label 'Node', Locked=true;
        NodesNodeNameTxt: Label 'Nodes', Locked=true;
        CaptionMLAttributeNameTxt: Label 'CaptionML', Locked=true;
        idLowerAttributeNameTxt: Label 'id', Locked=true;
        NameAttributeNameLowerTxt: Label 'name', Locked=true;
        ValueAttributeNameTxt: Label 'value', Locked=true;
        RegexAppendCaptionMLTxt: Label '%1=%2', Locked=true;
        ReplaceCaptionMLPatternTxt: Label '%1=.+?(?=;[A-Z]{3}=|$)', Locked=true;
        RemoveCaptionMLPatternTxt: Label '%1=.+?(?<=;)(?=[A-Z]{3}=)|;%1=.+?(?=;[A-Z]{3}=|$)', Locked=true;
        ExtractCaptionMLPatternTxt: Label '[A-Z]{3}(?==)|(?<=[A-Z]{3}=).+?(?=;[A-Z]{3}=|$)', Locked=true;
        LanguagePatternTxt: Label '%1=', Locked=true;
        SelectImportFolderMsg: Label 'Select a folder to import translations from.';
        SelectExportFolderMsg: Label 'Select a folder to export translations to.';
        SelectRemoveLanguageMsg: Label 'Select the language to remove profile translations for.';
        SelectRemoveLanguageTxt: Label '%1 - %2,', Locked=true;
        ProfileIDTxt: Label 'Profile ID', Locked=true;
        ProfileIDCommentTxt: Label 'Profile ID field from table 2000000074', Locked=true;
        ProfileDescriptionTxt: Label 'Profile Description', Locked=true;
        ProfileDescriptionCommentTxt: Label 'Description field from table 2000000074', Locked=true;
        ExportResxFormatTxt: Label '%1;%2;%3', Locked=true;
        ExportResxCommentFormatTxt: Label 'Page: %1 - PersonalizationId: %2 - ControlGuid: %3', Locked=true;
        ZipFileEntryTxt: Label '%1\%2.resx', Locked=true;
        ZipFileFormatNameTxt: Label '%1.zip', Locked=true;
        ZipFileNameTxt: Label 'ProfileResources';
        Mode: Option "None",Import,Export,Remove;
        SelectTranslatedResxFileTxt: Label 'Select a zip file with translated resources.';
        ImportCompleteMsg: Label 'Import completed. Restart the client to apply changes.', Comment='User must restart the client to see the imported translations.';
        ExportCompleteMsg: Label 'Export completed.';
        ExportNoEntriesFoundMsg: Label 'No entries found to export.';
        RemoveCompleteMsg: Label 'Remove completed.';
        CompletionMessageMsg: Label '%1\%2', Locked=true;
        NoImportResourcesFoundMsg: Label 'No resources found to import.', Comment='%1 = User selected folder. ';
        NoImportResourcesFoundForProfileMsg: Label 'No resources found to import for Profile %1.', Comment='%1 = Profile ID';
        NoDefaultProfileErr: Label 'No default profile set.';
        ZipArchiveFileNameTxt: Label 'Profiles.zip';
        ZipArchiveFilterTxt: Label 'Zip File (*.zip)|*.zip', Locked=true;
        ZipArchiveSaveDialogTxt: Label 'Export Profiles';
        ZipArchiveProgressMsg: Label 'Exporting profile: #1######', Comment='Exporting profile: ORDER PROCESSOR';
        O365SalesTxt: Label 'O365 Sales';
        O365SalesDescriptionTxt: Label 'O365 Sales Activities';
        TeamMemberTxt: Label 'Team Member';
        TeamMemberDescriptionTxt: Label 'Team Member';
        TenantProfileCantBeExportedErr: Label 'A Tenant Scope Profile does not support Export operation.';

    [Scope('Personalization')]
    procedure InitializeProfiles()
    var
        "Profile": Record "Profile";
    begin
        Profile.LockTable;
        if not Profile.IsEmpty then
          exit;
        InsertProfile(AccountingManagerProfileTxt,AccountingManagerDescriptionTxt,9001);
        InsertProfile(APCoordinatorProfileTxt,APCoordinatorDescriptionTxt,9002);
        InsertProfile(ARAdministratorProfileTxt,ARAdministratorDescriptionTxt,9003);
        InsertProfile(BookkeeperProfileTxt,BookkeeperDescriptionTxt,9004);
        InsertProfile(SalesManagerProfileTxt,SalesManagerDescriptionTxt,9005);
        InsertDefaultProfile(OrderProcessorProfileTxt,SalesOrderProcessorDescriptionTxt,9006);
        InsertProfile(PurchasingAgentProfileTxt,PurchasingAgentDescriptionTxt,9007);
        InsertProfile(ShippingandReceivingWMSProfileTxt,ShippingandReceivingWMSDescriptionTxt,9000);
        InsertProfile(ShippingandReceivingProfileTxt,ShippingandReceivingDescriptionTxt,9008);
        InsertProfile(WarehouseWorkerWMSProfileTxt,WarehouseWorkerWMSDescriptionTxt,9009);
        InsertProfile(ProductionPlannerProfileTxt,ProductionPlannerDescriptionTxt,9010);
        InsertProfile(ShopSupervisorProfileTxt,ShopSupervisorDescriptionTxt,9012);
        InsertProfile(ShopSupervisorFoundationProfileTxt,ShopSupervisorFoundationDescriptionTxt,9011);
        InsertProfile(MachineOperatorProfileTxt,MachineOperatorDescriptionTxt,9013);
        InsertProfile(ResourceManagerProfileTxt,ResourceManagerDescriptionTxt,9014);
        InsertProfile(ProjectManagerProfileTxt,ProjectManagerDescriptionTxt,9015);
        InsertProfile(DispatcherProfileTxt,DispatcherDescriptionTxt,9016);
        InsertProfile(OutboundTechnicianProfileTxt,OutboundTechnicianDescriptionTxt,9017);
        InsertProfile(ITManagerProfileTxt,ITManagerDescriptionTxt,9018);
        InsertProfile(PresidentProfileTxt,PresidentDescriptionTxt,9019);
        InsertProfile(PresidentSBProfileTxt,PresidentSBDescriptionTxt,9020);
        InsertProfile(RapidStartServicesProfileTxt,RapidStartServicesDescriptionTxt,9021);
        InsertProfile(BusinessManagerIDTxt,BusinessManagerDescriptionTxt,9022);
        InsertProfile(AccountingServicesTxt,AccountingServicesDescriptionTxt,9023);
        InsertProfile(SecurityAdministratorTxt,SecurityAdministratorDescriptionTxt,9024);
        InsertProfile(AccountantTxt,AccountantDescriptionTxt,9027);
        InsertProfile(O365SalesTxt,O365SalesDescriptionTxt,9029);
        InsertProfile(TeamMemberTxt,TeamMemberDescriptionTxt,9028);
        OnInitializeProfiles;
        Commit;
    end;

    [Scope('Personalization')]
    procedure InsertProfileExtended(ProfileID: Code[30];Description: Text[250];RoleCenterID: Integer;Default: Boolean)
    var
        "Profile": Record "All Profile";
        AllObj: Record AllObj;
    begin
        if not AllObj.Get(AllObj."Object Type"::Page,RoleCenterID) then
          exit;

        Profile.Init;
        Profile."Profile ID" := ProfileID;
        Profile.Description := Description;
        Profile."Role Center ID" := RoleCenterID;
        Profile."Default Role Center" := Default;
        Profile.Scope := Profile.Scope::System;
        Profile.Insert;
    end;

    [Scope('Personalization')]
    procedure InsertProfile(ProfileID: Code[30];Description: Text[250];RoleCenterID: Integer)
    begin
        InsertProfileExtended(ProfileID,Description,RoleCenterID,false);
    end;

    [Scope('Personalization')]
    procedure InsertDefaultProfile(ProfileID: Code[30];Description: Text[250];RoleCenterID: Integer)
    begin
        InsertProfileExtended(ProfileID,Description,RoleCenterID,true);
    end;

    [Scope('Personalization')]
    procedure DefaultRoleCenterID(): Integer
    var
        IdentityManagement: Codeunit "Identity Management";
        PermissionManager: Codeunit "Permission Manager";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        RoleCenterID: Integer;
    begin
        if PermissionManager.SoftwareAsAService then
          if AzureADUserManagement.TryGetAzureUserPlanRoleCenterId(RoleCenterID,UserSecurityId) then;

        if RoleCenterID = 0 then
          RoleCenterID := PAGE::"Business Manager Role Center"; // BUSINESS MANAGER

        if IdentityManagement.IsInvAppId then
          RoleCenterID := PAGE::"O365 Sales Activities RC"; // O365 Sales Activities RC

        OnAfterGetDefaultRoleCenter(RoleCenterID);
        exit(RoleCenterID);
    end;

    [Scope('Personalization')]
    procedure GetProfileHavingDefaultRoleCenter(var DefaultProfile: Record "All Profile")
    begin
        DefaultProfile.SetRange("Role Center ID",DefaultRoleCenterID);
        if DefaultProfile.FindFirst then;
    end;

    [Scope('Personalization')]
    procedure GetDefaultProfile(var DefaultProfile: Record "All Profile")
    begin
        DefaultProfile.SetRange("Default Role Center",true);
        if DefaultProfile.FindFirst then;
    end;

    [Scope('Personalization')]
    procedure GetCurrentProfileID(): Code[30]
    var
        CurrentProfileID: Code[30];
    begin
        CurrentProfileID := GetCurrentProfileIDNoError;
        if CurrentProfileID = '' then
          Error(NoDefaultProfileErr);

        exit(CurrentProfileID);
    end;

    [Scope('Personalization')]
    procedure GetCurrentProfileIDNoError(): Code[30]
    var
        UserPersonalization: Record "User Personalization";
        "Profile": Record "All Profile";
    begin
        if UserPersonalization.Get(UserSecurityId) then
          if UserPersonalization."Profile ID" <> '' then
            exit(UserPersonalization."Profile ID");

        Profile.SetRange("Default Role Center",true);
        if Profile.FindFirst then
          exit(Profile."Profile ID");

        exit('');
    end;

    [Scope('Personalization')]
    procedure SetCurrentProfileID(ProfileID: Code[30])
    var
        UserPersonalization: Record "User Personalization";
        PrevProfileID: Code[30];
    begin
        if UserPersonalization.Get(UserSecurityId) then begin
          PrevProfileID := UserPersonalization."Profile ID";
          UserPersonalization."Profile ID" := ProfileID;
          UserPersonalization.Modify(true);
        end else begin
          UserPersonalization.Init;
          UserPersonalization."User SID" := UserSecurityId;
          UserPersonalization."Profile ID" := ProfileID;
          UserPersonalization.Insert(true);
        end;

        OnProfileChanged(PrevProfileID,ProfileID);
    end;

    [Scope('Personalization')]
    procedure GetCurrentProfile(var AllProfile: Record "All Profile")
    begin
        GetCurrentProfileNoError(AllProfile);
        if AllProfile.IsEmpty then
          Error(NoDefaultProfileErr);
    end;

    [Scope('Personalization')]
    procedure GetCurrentProfileNoError(var AllProfile: Record "All Profile"): Boolean
    var
        UserPersonalization: Record "User Personalization";
    begin
        if UserPersonalization.Get(UserSecurityId) then
          if UserPersonalization."Profile ID" <> '' then
            exit(AllProfile.Get(UserPersonalization.Scope,UserPersonalization."App ID",UserPersonalization."Profile ID"));

        AllProfile.SetRange("Default Role Center",true);
        exit(AllProfile.FindFirst);
    end;

    [Scope('Personalization')]
    procedure IsCurrentProfile(Scope: Option;AppID: Guid;ProfileID: Code[30]): Boolean
    var
        AllProfile: Record "All Profile";
    begin
        if not GetCurrentProfileNoError(AllProfile) then
          exit(false);

        exit((AllProfile.Scope = Scope) and (AllProfile."App ID" = AppID) and (AllProfile."Profile ID" = ProfileID));
    end;

    [Scope('Personalization')]
    procedure SetCurrentProfile(AllProfile: Record "All Profile")
    var
        UserPersonalization: Record "User Personalization";
        PrevAllProfile: Record "All Profile";
    begin
        if UserPersonalization.Get(UserSecurityId) then begin
          if PrevAllProfile.Get(UserPersonalization.Scope,UserPersonalization."App ID",UserPersonalization."Profile ID") then;
          UserPersonalization."Profile ID" := AllProfile."Profile ID";
          UserPersonalization.Scope := AllProfile.Scope;
          UserPersonalization."App ID" := AllProfile."App ID";
          UserPersonalization.Modify(true);
        end else begin
          UserPersonalization.Init;
          UserPersonalization."User SID" := UserSecurityId;
          UserPersonalization."Profile ID" := AllProfile."Profile ID";
          UserPersonalization.Scope := AllProfile.Scope;
          UserPersonalization."App ID" := AllProfile."App ID";
          UserPersonalization.Insert(true);
        end;

        OnProfileChanged(PrevAllProfile."Profile ID",AllProfile."Profile ID");
    end;

    [Scope('Personalization')]
    procedure CopyProfile("Profile": Record "All Profile";NewProfileID: Code[30];NewProfileScope: Option System,Tenant)
    var
        NewProfile: Record "All Profile";
        ProfileMetadata: Record "Profile Metadata";
        NewProfileMetadata: Record "Profile Metadata";
    begin
        NewProfile.Init;
        NewProfile.Validate("Profile ID",NewProfileID);
        NewProfile.TestField("Profile ID");
        NewProfile.Validate(Description,Profile.Description);
        NewProfile.Validate("Role Center ID",Profile."Role Center ID");
        NewProfile.Validate(Scope,NewProfileScope);
        NewProfile.Insert;

        if (Profile.Scope = Profile.Scope::System) and (NewProfileScope = Profile.Scope::System) then begin
          ProfileMetadata.SetRange("Profile ID",Profile."Profile ID");
          if ProfileMetadata.FindSet then
            repeat
              ProfileMetadata.CalcFields("Page Metadata Delta");

              NewProfileMetadata.Init;
              NewProfileMetadata.Copy(ProfileMetadata);
              NewProfileMetadata."Profile ID" := NewProfileID;
              NewProfileMetadata.Insert;
            until ProfileMetadata.Next = 0;
        end;

        CopyProfilePageMetadata(Profile,NewProfile);

        OnAfterCopyProfile(Profile,NewProfile);
    end;

    [Scope('Personalization')]
    procedure ClearProfileConfiguration("Profile": Record "All Profile")
    var
        ProfileMetadata: Record "Profile Metadata";
    begin
        if not Confirm(DeleteConfigurationChangesQst) then
          exit;
        if Profile.Scope = Profile.Scope::System then begin
          ProfileMetadata.SetRange("Profile ID",Profile."Profile ID");
          ProfileMetadata.DeleteAll(true);
        end
    end;

    [Scope('Personalization')]
    procedure ClearUserPersonalization(User: Record "User Personalization")
    var
        UserMetadata: Record "User Metadata";
        UserPageMetadata: Record "User Page Metadata";
    begin
        if not Confirm(DeletePersonalizationChangesQst) then
          exit;

        UserMetadata.SetRange("User SID",User."User SID");
        UserMetadata.DeleteAll(true);

        UserPageMetadata.SetRange("User SID",User."User SID");
        UserPageMetadata.DeleteAll(true);
    end;

    procedure ExportProfilesInZipFile(var "Profile": Record "All Profile")
    var
        FileMgt: Codeunit "File Management";
        Window: Dialog;
        FileName: Text;
        ZipArchive: Text;
    begin
        if Profile.FindSet then begin
          ZipArchive := FileMgt.CreateZipArchiveObject;
          Window.Open(ZipArchiveProgressMsg);

          repeat
            Window.Update(1,Profile."Profile ID");
            FileName := FileMgt.ServerTempFileName('xml');

            ExportProfiles(FileName,Profile);

            FileMgt.AddFileToZipArchive(FileName,Profile."Profile ID" + '.xml');
            FileMgt.DeleteServerFile(FileName);
          until Profile.Next = 0;

          Window.Close;
          FileMgt.CloseZipArchive;

          FileMgt.DownloadHandler(ZipArchive,ZipArchiveSaveDialogTxt,'',ZipArchiveFilterTxt,ZipArchiveFileNameTxt);
          FileMgt.DeleteServerFile(ZipArchive);
        end;
    end;

    procedure ExportProfiles(FileName: Text;"Profile": Record "All Profile")
    var
        SystemProfile: Record "Profile";
        FileOutStream: OutStream;
        ProfileFile: File;
    begin
        if Profile.Scope = Profile.Scope::Tenant then
          Error(TenantProfileCantBeExportedErr);

        ProfileFile.Create(FileName);
        ProfileFile.CreateOutStream(FileOutStream);
        SystemProfile.Get(Profile."Profile ID");
        SystemProfile.SetRecFilter;
        XMLPORT.Export(XMLPORT::"Profile Import/Export",FileOutStream,SystemProfile);
        ProfileFile.Close;
    end;

    procedure ImportProfiles(FileName: Text)
    var
        FileInStream: InStream;
        ProfileFile: File;
    begin
        ProfileFile.Open(FileName);
        ProfileFile.CreateInStream(FileInStream);
        XMLPORT.Import(XMLPORT::"Profile Import/Export",FileInStream);
        ProfileFile.Close;
    end;

    [Scope('Personalization')]
    procedure ChangeDefaultRoleCenter("Profile": Record "All Profile")
    var
        SystemProfile: Record "Profile";
        TenantProfile: Record "Tenant Profile";
    begin
        if Profile.Scope = Profile.Scope::System then begin
          SystemProfile.SetRange("Default Role Center",true);
          if SystemProfile.FindSet then
            repeat
              if not (SystemProfile."Profile ID" = Profile."Profile ID") then begin
                SystemProfile."Default Role Center" := false;
                SystemProfile.Modify;
              end;
            until SystemProfile.Next = 0;
        end;

        TenantProfile.SetRange("Default Role Center",true);
        if TenantProfile.FindSet then
          repeat
            if not ((TenantProfile."App ID" = Profile."App ID") and
                    (TenantProfile."Profile ID" = Profile."Profile ID") and
                    (Profile.Scope = Profile.Scope::Tenant))
            then begin
              TenantProfile."Default Role Center" := false;
              TenantProfile.Modify;
            end;
          until TenantProfile.Next = 0;
    end;

    [Scope('Personalization')]
    procedure ValidateDeleteProfile("Profile": Record "All Profile")
    var
        UserPersonalization: Record "User Personalization";
        UserGroup: Record "User Group";
    begin
        if Profile."Default Role Center" then
          Error(NoDeleteProfileErr);

        UserPersonalization.SetRange("Profile ID",Profile."Profile ID");
        UserPersonalization.SetRange("App ID",Profile."App ID");
        UserPersonalization.SetRange(Scope,Profile.Scope);

        if not UserPersonalization.IsEmpty then
          Error(CannotDeleteDefaultUserProfileErr);

        UserGroup.SetRange("Default Profile ID",Profile."Profile ID");
        UserGroup.SetRange("Default Profile App ID",Profile."App ID");
        UserGroup.SetRange("Default Profile Scope",Profile.Scope);

        if not UserGroup.IsEmpty then
          Error(CannotDeleteDefaultUserProfileErr);
    end;

    procedure ImportTranslatedResources(var "Profile": Record "All Profile";ResourcesZipFileOrFolder: Text;ShowCompletionMessage: Boolean)
    var
        BaseProfile: Record "Profile";
        FileManagement: Codeunit "File Management";
        ServerFolder: Text;
    begin
        if Profile.FindSet then begin
          InitializeDotnetVariables;
          ServerFolder := CopyResourcesToServer(ResourcesZipFileOrFolder);
          repeat
            if ReadResourceFiles(Profile."Profile ID",ServerFolder) then begin
              Mode := Mode::Import;
              if BaseProfile.Get(Profile."Profile ID") then
                ProcessConfigurationMetadata(BaseProfile);
            end;
          until Profile.Next = 0;

          FileManagement.ServerRemoveDirectory(ServerFolder,true);

          if ShowCompletionMessage then
            GetCompletionMessage(true);
        end;
    end;

    procedure ImportTranslatedResourcesWithFolderSelection(var "Profile": Record "All Profile")
    var
        FileManagement: Codeunit "File Management";
        ResourceFolder: Text;
    begin
        if FileManagement.CanRunDotNetOnClient then
          ResourceFolder := SelectResourceImportFolder;
        if (ResourceFolder <> '') or FileManagement.IsWebClient then
          ImportTranslatedResources(Profile,ResourceFolder,true);
    end;

    procedure ExportTranslatedResources(var "Profile": Record "All Profile";ResourceFolder: Text)
    var
        SystemProfile: Record "Profile";
        FileManagement: Codeunit "File Management";
        FolderExists: Boolean;
    begin
        if Profile.FindSet then begin
          InitializeDotnetVariables;
          if FileManagement.CanRunDotNetOnClient then
            FolderExists := FileManagement.ClientDirectoryExists(ResourceFolder);
          if FileManagement.IsWebClient or FolderExists then begin
            Mode := Mode::Export;
            repeat
              SystemProfile.Reset;
              SystemProfile.Get(Profile."Profile ID");
              ClearResourcesForProfile(SystemProfile."Profile ID");
              ProcessConfigurationMetadata(SystemProfile);
              ExportResourceFiles(ResourceFolder,SystemProfile."Profile ID")
            until Profile.Next = 0
          end;
        end;
    end;

    procedure ExportTranslatedResourcesWithFolderSelection(var "Profile": Record "All Profile")
    var
        FileManagement: Codeunit "File Management";
        ResourceFolder: Text;
    begin
        if FileManagement.CanRunDotNetOnClient then
          ResourceFolder := SelectResourceExportFolder;
        if (ResourceFolder <> '') or FileManagement.IsWebClient then begin
          ExportTranslatedResources(Profile,ResourceFolder);
          GetCompletionMessage(true);
        end;
    end;

    procedure RemoveTranslatedResources(var "Profile": Record "All Profile";Language: Text[3])
    var
        BaseProfile: Record "Profile";
    begin
        if Profile.FindSet then
          if Language <> '' then begin
            InitializeDotnetVariables;
            AppendDetectedLanguage(Language);
            Mode := Mode::Remove;

            repeat
              if BaseProfile.Get(Profile."Profile ID") then
                ProcessConfigurationMetadata(BaseProfile);
            until Profile.Next = 0
          end;
    end;

    procedure RemoveTranslatedResourcesWithLanguageSelection(var "Profile": Record "All Profile")
    var
        LanguageToRemove: Text[3];
    begin
        LanguageToRemove := SelectLanguageToRemove;
        if LanguageToRemove <> '' then begin
          RemoveTranslatedResources(Profile,LanguageToRemove);
          GetCompletionMessage(true);
        end;
    end;

    local procedure ProcessConfigurationMetadata("Profile": Record "Profile")
    var
        ProfileMetadata: Record "Profile Metadata";
        ProfileConfigurationDOM: DotNet XmlDocument;
    begin
        ProfileMetadata.SetRange("Profile ID",Profile."Profile ID");
        if ProfileMetadata.FindSet(true) then begin
          repeat
            LoadProfileMetadata(ProfileMetadata,ProfileConfigurationDOM);
            CurrentProfileID := ProfileMetadata."Profile ID";
            CurrentProfileDescription := Profile.Description;
            CurrentPageID := ProfileMetadata."Page ID";
            CurrentPersonalizationID := ProfileMetadata."Personalization ID";
            ParseConfiguration(ProfileConfigurationDOM);
            UpdateProfileConfigurationRecord(ProfileMetadata,ProfileConfigurationDOM);
          until ProfileMetadata.Next = 0
        end;
    end;

    [Scope('Personalization')]
    procedure SelectResourceImportFolder() Folder: Text
    var
        FileManagement: Codeunit "File Management";
    begin
        if FileManagement.CanRunDotNetOnClient then
          FileManagement.SelectFolderDialog(SelectImportFolderMsg,Folder);
    end;

    [Scope('Personalization')]
    procedure SelectResourceExportFolder() Folder: Text
    var
        FileManagement: Codeunit "File Management";
    begin
        if FileManagement.CanRunDotNetOnClient then
          FileManagement.SelectFolderDialog(SelectExportFolderMsg,Folder);
    end;

    procedure SelectLanguageToRemove(): Text[3]
    var
        WindowsLanguage: Record "Windows Language";
        Options: Text;
        Selected: Integer;
    begin
        FilterToInstalledLanguages(WindowsLanguage);
        if WindowsLanguage.FindSet then begin
          repeat
            Options += StrSubstNo(SelectRemoveLanguageTxt,WindowsLanguage."Abbreviated Name",WindowsLanguage.Name);
          until WindowsLanguage.Next = 0;

          Selected := StrMenu(Options,0,SelectRemoveLanguageMsg);
          if Selected > 0 then
            exit(CopyStr(SelectStr(Selected,Options),1,3));
        end;

        exit('');
    end;

    procedure FilterToInstalledLanguages(var WindowsLanguage: Record "Windows Language")
    begin
        // Filter is the same used by the Select Language dialog in the Windows client
        WindowsLanguage.SetRange("Globally Enabled",true);
        WindowsLanguage.SetRange("Localization Exist",true);
        WindowsLanguage.SetFilter("Language ID",'<> %1',1034);
        WindowsLanguage.FindSet;
    end;

    local procedure IsLanguageInstalled(LanguageName: Text): Boolean
    var
        WindowsLanguage: Record "Windows Language";
    begin
        if InstalledLanguages.Count = 0 then begin
          FilterToInstalledLanguages(WindowsLanguage);
          if WindowsLanguage.FindSet then begin
            repeat
              InstalledLanguages.Add(CultureInfo.GetCultureInfo(WindowsLanguage."Language ID").Name);
            until WindowsLanguage.Next = 0
          end;
        end;

        exit(InstalledLanguages.Contains(LanguageName));
    end;

    local procedure ReadResourceFiles(ProfileID: Code[30];ServerFolder: Text): Boolean
    var
        ProfileResourceImportExport: Record "Profile Resource Import/Export";
        WindowsLanguage: Record "Windows Language";
        FileManagement: Codeunit "File Management";
        ResxReader: DotNet ResXResourceReader;
        Enumerator: DotNet IDictionaryEnumerator;
        KeySplits: DotNet Array;
        Directory: DotNet Directory;
        DirectoryInfo: DotNet DirectoryInfo;
        Directories: DotNet Array;
        Dir: Text;
        DirName: Text;
        FileName: Text;
        Language: Text[3];
        BaseProfileID: Code[30];
        i: Integer;
        ResourceCount: Integer;
    begin
        ClearResourcesForProfile(ProfileID);

        if (ServerFolder = '') or (not FileManagement.ServerDirectoryExists(ServerFolder)) then
          exit(false);

        Directories := Directory.GetDirectories(ServerFolder);
        for i := 0 to Directories.Length - 1 do begin
          Dir := Directories.GetValue(i);
          DirName := DirectoryInfo.DirectoryInfo(Dir).Name;
          if IsLanguageInstalled(DirName) then begin
            Language := CultureInfo.GetCultureInfo(DirName).ThreeLetterWindowsLanguageName;
            AppendDetectedLanguage(Language);
            FilterToInstalledLanguages(WindowsLanguage);
            BaseProfileID := TranslateProfileID(ProfileID,WindowsLanguage,1033);
            FileName := FileManagement.CombinePath(Dir,BaseProfileID + '.Resx');
            if FileManagement.ServerFileExists(FileName) then begin
              ResxReader := ResxReader.ResXResourceReader(FileName);
              Enumerator := ResxReader.GetEnumerator;
              while Enumerator.MoveNext do begin
                KeySplits := RegEx.Split(Convert.ToString(Enumerator.Key),';');
                if KeySplits.Length = 3 then
                  ProfileResourceImportExport.InsertRec(
                    ProfileID,Convert.ToInt32(KeySplits.GetValue(0)),Convert.ToString(KeySplits.GetValue(1)),
                    Convert.ToString(KeySplits.GetValue(2)),Language,Convert.ToString(Enumerator.Value));
              end;
            end else
              InfoForCompletionMessage.Add(StrSubstNo(ProfileResxFileNotFoundTxt,Language,ProfileID));
          end;
        end;

        ResourceCount := CountResourcesForProfile(ProfileID);
        if ResourceCount = 0 then
          InfoForCompletionMessage.Add(StrSubstNo(NoImportResourcesFoundForProfileMsg,ProfileID));

        exit(ResourceCount > 0);
    end;

    local procedure SetTranslationParameters(var WindowsLanguage: Record "Windows Language";ProfileIDTxt: Text;TempLanguage: Integer;TranslateToLanguageID: Integer) TranslatedProfileID: Code[30]
    begin
        CheckSetLanguage(TranslateToLanguageID);
        TranslatedProfileID := CopyStr(ProfileIDTxt,1,MaxStrLen(TranslatedProfileID));
        WindowsLanguage.Get(TempLanguage); // Other profiles will match same language
    end;

    procedure TranslateProfileID(ProfileID: Code[30];var WindowsLanguage: Record "Windows Language";TranslateToLanguageID: Integer) TranslatedProfileID: Code[30]
    var
        CurrentLanguage: Integer;
        TempLanguage: Integer;
        ProfileIDTxt: Text;
    begin
        CurrentLanguage := GlobalLanguage;

        repeat
          TempLanguage := WindowsLanguage."Language ID";
          if GlobalLanguage <> TempLanguage then
            GlobalLanguage := TempLanguage;
          case ProfileID of
            UpperCase(AccountingManagerProfileTxt):
              ProfileIDTxt := AccountingManagerProfileTxt;
            UpperCase(APCoordinatorProfileTxt):
              ProfileIDTxt := APCoordinatorProfileTxt;
            UpperCase(ARAdministratorProfileTxt):
              ProfileIDTxt := ARAdministratorProfileTxt;
            UpperCase(BookkeeperProfileTxt):
              ProfileIDTxt := BookkeeperProfileTxt;
            UpperCase(SalesManagerProfileTxt):
              ProfileIDTxt := SalesManagerProfileTxt;
            UpperCase(OrderProcessorProfileTxt):
              ProfileIDTxt := OrderProcessorProfileTxt;
            UpperCase(PurchasingAgentProfileTxt):
              ProfileIDTxt := PurchasingAgentProfileTxt;
            UpperCase(ShippingandReceivingWMSProfileTxt):
              ProfileIDTxt := ShippingandReceivingWMSProfileTxt;
            UpperCase(ShippingandReceivingProfileTxt):
              ProfileIDTxt := ShippingandReceivingProfileTxt;
            UpperCase(WarehouseWorkerWMSProfileTxt):
              ProfileIDTxt := WarehouseWorkerWMSProfileTxt;
            UpperCase(ProductionPlannerProfileTxt):
              ProfileIDTxt := ProductionPlannerProfileTxt;
            UpperCase(ShopSupervisorProfileTxt):
              ProfileIDTxt := ShopSupervisorProfileTxt;
            UpperCase(ShopSupervisorFoundationProfileTxt):
              ProfileIDTxt := ShopSupervisorFoundationProfileTxt;
            UpperCase(MachineOperatorProfileTxt):
              ProfileIDTxt := MachineOperatorProfileTxt;
            UpperCase(ResourceManagerProfileTxt):
              ProfileIDTxt := ResourceManagerProfileTxt;
            UpperCase(ProjectManagerProfileTxt):
              ProfileIDTxt := ProjectManagerProfileTxt;
            UpperCase(DispatcherProfileTxt):
              ProfileIDTxt := DispatcherProfileTxt;
            UpperCase(OutboundTechnicianProfileTxt):
              ProfileIDTxt := OutboundTechnicianProfileTxt;
            UpperCase(ITManagerProfileTxt):
              ProfileIDTxt := ITManagerProfileTxt;
            UpperCase(PresidentProfileTxt):
              ProfileIDTxt := PresidentProfileTxt;
            UpperCase(PresidentSBProfileTxt):
              ProfileIDTxt := PresidentSBProfileTxt;
            UpperCase(RapidStartServicesProfileTxt):
              ProfileIDTxt := RapidStartServicesProfileTxt;
            UpperCase(BusinessManagerIDTxt):
              ProfileIDTxt := BusinessManagerIDTxt;
            UpperCase(AccountingServicesTxt):
              ProfileIDTxt := AccountingServicesTxt;
            UpperCase(SecurityAdministratorTxt):
              ProfileIDTxt := SecurityAdministratorTxt;
            UpperCase(TeamMemberTxt):
              ProfileIDTxt := TeamMemberTxt;
          end;
          TranslatedProfileID := SetTranslationParameters(
              WindowsLanguage,ProfileIDTxt,TempLanguage,TranslateToLanguageID);
        until (WindowsLanguage.Next = 0) or (TranslatedProfileID <> '');

        if GlobalLanguage <> CurrentLanguage then
          GlobalLanguage := CurrentLanguage;
        if TranslatedProfileID = '' then
          TranslatedProfileID := ProfileID;
    end;

    local procedure CheckSetLanguage(LanguageID: Integer)
    begin
        if GlobalLanguage <> LanguageID then
          GlobalLanguage := LanguageID;
    end;

    local procedure CopyResourcesToServer(ResourcesZipFileOrFolder: Text) ServerFolder: Text
    var
        FileManagement: Codeunit "File Management";
        ServerFile: Text;
    begin
        if FileManagement.IsWebClient then
          ServerFile := FileManagement.UploadFile(SelectTranslatedResxFileTxt,'*.zip');

        if FileManagement.CanRunDotNetOnClient then begin
          if FileManagement.ClientDirectoryExists(ResourcesZipFileOrFolder) then begin
            ServerFolder := FileManagement.UploadClientDirectorySilent(ResourcesZipFileOrFolder,'*.resx',true);
            if ServerFolder = '' then
              InfoForCompletionMessage.Add(NoImportResourcesFoundMsg);
            exit;
          end;
          if ResourcesZipFileOrFolder = '' then
            ServerFile := FileManagement.UploadFile(SelectTranslatedResxFileTxt,'*.zip');
          if FileManagement.GetExtension(ResourcesZipFileOrFolder) = 'zip' then
            ServerFile := FileManagement.UploadFileToServer(ResourcesZipFileOrFolder);
        end;

        if ServerFile <> '' then begin
          ServerFolder := FileManagement.ServerCreateTempSubDirectory;
          FileManagement.ExtractZipFile(ServerFile,ServerFolder);
          FileManagement.DeleteServerFile(ServerFile);
        end;
    end;

    local procedure ExportResourceFiles(ResourceFolder: Text;ProfileID: Code[30])
    var
        ProfileResourceImportExport: Record "Profile Resource Import/Export";
        WindowsLanguage: Record "Windows Language";
        FileManagement: Codeunit "File Management";
        CurrentDir: Text;
        ZipArchiveName: Text;
        ZipFileEntry: Text;
        ServerFileName: Text;
        i: Integer;
        CurrentLanguage: Text;
        CultureName: Text;
        CanRunDotNetOnClient: Boolean;
    begin
        CanRunDotNetOnClient := FileManagement.CanRunDotNetOnClient;

        if not CanRunDotNetOnClient then
          ZipArchiveName := FileManagement.CreateZipArchiveObject;

        for i := 0 to DetectedLanguages.Count - 1 do begin
          CurrentLanguage := DetectedLanguages.Item(i);
          ProfileResourceImportExport.SetRange("Profile ID",ProfileID);
          ProfileResourceImportExport.SetRange("Abbreviated Language Name",CurrentLanguage);

          if ProfileResourceImportExport.FindFirst then begin
            WindowsLanguage.SetRange("Abbreviated Name",CurrentLanguage);
            WindowsLanguage.FindFirst;
            CultureName := CultureInfo.GetCultureInfo(WindowsLanguage."Language ID").Name;
            CurrentDir := FileManagement.CombinePath(ResourceFolder,CultureName);

            ServerFileName := FileManagement.ServerTempFileName('.Resx');
            AppendToResxFile(ProfileResourceImportExport,ProfileID,ServerFileName);

            if not CanRunDotNetOnClient then begin
              ZipFileEntry := StrSubstNo(ZipFileEntryTxt,CultureName,ProfileID);
              FileManagement.AddFileToZipArchive(ServerFileName,ZipFileEntry);
            end else begin
              FileManagement.CreateClientDirectory(CurrentDir);
              FileManagement.DownloadToFile(ServerFileName,FileManagement.CombinePath(CurrentDir,ProfileID + '.Resx'));
            end;
            FileManagement.DeleteServerFile(ServerFileName);
          end else
            InfoForCompletionMessage.Add(ExportNoEntriesFoundMsg);
        end;

        if not CanRunDotNetOnClient then begin
          FileManagement.CloseZipArchive;
          FileManagement.DownloadHandler(ZipArchiveName,'','','',StrSubstNo(ZipFileFormatNameTxt,ZipFileNameTxt));
        end;
    end;

    local procedure AppendToResxFile(var ProfileResourceImportExport: Record "Profile Resource Import/Export";ProfileID: Code[30];ServerFileName: Text)
    var
        ResxWriter: DotNet ResXResourceWriter;
        ResxDataNode: DotNet ResXDataNode;
        "Key": Text;
        Comment: Text;
    begin
        ResxWriter := ResxWriter.ResXResourceWriter(ServerFileName);
        ResxDataNode := ResxDataNode.ResXDataNode(ProfileIDTxt,ProfileID);
        ResxDataNode.Comment := ProfileIDCommentTxt;
        ResxWriter.AddResource(ResxDataNode);
        ResxDataNode := ResxDataNode.ResXDataNode(ProfileDescriptionTxt,CurrentProfileDescription);
        ResxDataNode.Comment := ProfileDescriptionCommentTxt;
        ResxWriter.AddResource(ResxDataNode);

        repeat
          Key := StrSubstNo(ExportResxFormatTxt,
              ProfileResourceImportExport."Page ID",
              ProfileResourceImportExport."Personalization ID",
              ProfileResourceImportExport."Control GUID");

          Comment := StrSubstNo(ExportResxCommentFormatTxt,
              ProfileResourceImportExport."Page ID",
              ProfileResourceImportExport."Personalization ID",
              ProfileResourceImportExport."Control GUID");

          ResxDataNode := ResxDataNode.ResXDataNode(Key,ProfileResourceImportExport.Value);
          ResxDataNode.Comment := Comment;
          ResxWriter.AddResource(ResxDataNode);
        until ProfileResourceImportExport.Next = 0;

        ResxWriter.Close;
    end;

    local procedure LoadProfileMetadata(ProfileMetadata: Record "Profile Metadata";var ObjectDOM: DotNet XmlDocument)
    var
        InStr: InStream;
    begin
        ProfileMetadata.CalcFields("Page Metadata Delta");
        ProfileMetadata."Page Metadata Delta".CreateInStream(InStr);
        XMLDOMManagement.LoadXMLDocumentFromInStream(InStr,ObjectDOM);
    end;

    local procedure ParseConfiguration(var ProfileConfigurationDOM: DotNet XmlDocument)
    var
        ChangeNodeList: DotNet XmlNodeList;
        ChangeNode: DotNet XmlNode;
        DeltaNode: DotNet XmlNode;
        ChangeType: Text;
        i: Integer;
    begin
        DeltaNode := ProfileConfigurationDOM.DocumentElement;
        ChangeNodeList := DeltaNode.FirstChild.ChildNodes;

        for i := 0 to ChangeNodeList.Count - 1 do begin
          ChangeNode := ChangeNodeList.ItemOf(i);
          ChangeType := ChangeNode.Name;
          case LowerCase(ChangeType) of
            'add':
              ParseAdd(ProfileConfigurationDOM,ChangeNode);
            'update':
              ParseUpdate(ChangeNode);
          end;
        end;
    end;

    local procedure UpdateProfileConfigurationRecord(var ProfileMetadata: Record "Profile Metadata";ProfileConfigurationDOM: DotNet XmlDocument)
    var
        OutStr: OutStream;
    begin
        if not (Mode in [Mode::Import,Mode::Remove]) then
          exit;
        ProfileMetadata."Page Metadata Delta".CreateOutStream(OutStr);
        ProfileConfigurationDOM.Save(OutStr);
        ProfileMetadata.Modify;
    end;

    local procedure ParseAdd(XmlDocument: DotNet XmlDocument;var XmlNode: DotNet XmlNode)
    var
        NodeNode: DotNet XmlNode;
    begin
        XMLDOMManagement.FindNode(XmlNode,NodeNodeNameTxt,NodeNode);
        ParseAddNode(XmlDocument,NodeNode);
    end;

    local procedure ParseAddNode(XmlDocument: DotNet XmlDocument;var XmlNode: DotNet XmlNode)
    var
        NodeNode: DotNet XmlNode;
        NodesNode: DotNet XmlNode;
        ControlGuid: Text;
        i: Integer;
    begin
        ControlGuid := XMLDOMManagement.GetAttributeValue(XmlNode,idLowerAttributeNameTxt);
        ProcessAddNodes(XmlNode,CopyStr(ControlGuid,1,40));

        NodesNode := XmlNode.SelectSingleNode(NodesNodeNameTxt);
        for i := 0 to NodesNode.ChildNodes.Count - 1 do begin
          NodeNode := NodesNode.ChildNodes.ItemOf(i);
          ParseAddNode(XmlDocument,NodeNode);
        end;
    end;

    local procedure ParseUpdate(var XmlNode: DotNet XmlNode)
    var
        CaptionMLAttribute: DotNet XmlAttribute;
        ControlGuid: Text;
        CaptionMLValue: Text;
    begin
        if XMLDOMManagement.GetAttributeValue(XmlNode,NameAttributeNameLowerTxt) <> CaptionMLAttributeNameTxt then
          exit;

        if not XMLDOMManagement.FindAttribute(XmlNode,CaptionMLAttribute,ValueAttributeNameTxt) then
          exit;

        ControlGuid := XMLDOMManagement.GetAttributeValue(XmlNode,idLowerAttributeNameTxt);

        CaptionMLValue := CaptionMLAttribute.Value;
        case Mode of
          Mode::Export:
            begin
              ExtractCaptions(CopyStr(ControlGuid,1,40),CaptionMLValue);
              exit;
            end;
          Mode::Import:
            CaptionMLValue := AppendCaptions(CopyStr(ControlGuid,1,40),CaptionMLValue);
          Mode::Remove:
            CaptionMLValue := RemoveCaptions(CaptionMLValue);
        end;

        CaptionMLAttribute.Value(CaptionMLValue);
    end;

    local procedure ProcessAddNodes(NodeNode: DotNet XmlNode;ControlGuid: Code[40])
    var
        AttributesNode: DotNet XmlNode;
        AttributeNode: DotNet XmlNode;
        CaptionMLAttribute: DotNet XmlAttribute;
        Attribute: Text;
        CaptionMLValue: Text;
        i: Integer;
    begin
        if XMLDOMManagement.FindNode(NodeNode,AttributesNodeNameTxt,AttributesNode) then
          for i := 0 to AttributesNode.ChildNodes.Count - 1 do begin
            AttributeNode := AttributesNode.ChildNodes.ItemOf(i);
            Attribute := XMLDOMManagement.GetAttributeValue(AttributeNode,NameAttributeNameLowerTxt);
            if Attribute = CaptionMLAttributeNameTxt then begin
              if not XMLDOMManagement.FindAttribute(AttributeNode,CaptionMLAttribute,ValueAttributeNameTxt) then
                exit;
              CaptionMLValue := CaptionMLAttribute.Value;
              if CaptionMLValue <> '' then begin
                case Mode of
                  Mode::Export:
                    begin
                      ExtractCaptions(ControlGuid,CaptionMLValue);
                      exit;
                    end;
                  Mode::Import:
                    CaptionMLValue := AppendCaptions(ControlGuid,CaptionMLValue);
                  Mode::Remove:
                    CaptionMLValue := RemoveCaptions(CaptionMLValue);
                end;
                CaptionMLAttribute.Value(CaptionMLValue);
                exit;
              end;
            end;
          end;
    end;

    local procedure AppendCaptions(ControlGuid: Code[40];OriginalCaptionML: Text): Text
    var
        ProfileResourceImportExport: Record "Profile Resource Import/Export";
        Pattern: Text;
        Translation: Text;
        Language: Text;
        Position: Integer;
        i: Integer;
    begin
        for i := 0 to DetectedLanguages.Count - 1 do begin
          Language := DetectedLanguages.Item(i);
          if FindProfileLanguageResourcesImp(ProfileResourceImportExport,ControlGuid,Language) then begin
            Translation := ProfileResourceImportExport.Value;
            Position := StrPos(OriginalCaptionML,StrSubstNo(LanguagePatternTxt,Language));

            if Position > 0 then begin
              Pattern := StrSubstNo(ReplaceCaptionMLPatternTxt,Language);
              OriginalCaptionML := RegEx.Replace(OriginalCaptionML,Pattern,StrSubstNo(RegexAppendCaptionMLTxt,Language,Translation));
            end else
              OriginalCaptionML += StrSubstNo(';%1=%2',Language,Translation);
          end;
        end;

        exit(OriginalCaptionML);
    end;

    local procedure RemoveCaptions(OriginalCaptionML: Text): Text
    var
        Pattern: Text;
        Language: Text;
        Position: Integer;
    begin
        Language := DetectedLanguages.Item(0);

        Position := StrPos(OriginalCaptionML,StrSubstNo(LanguagePatternTxt,Language));
        if Position > 0 then begin
          Pattern := StrSubstNo(RemoveCaptionMLPatternTxt,Language);
          OriginalCaptionML := RegEx.Replace(OriginalCaptionML,Pattern,'');
        end;

        exit(OriginalCaptionML);
    end;

    local procedure ExtractCaptions(ControlGuid: Code[40];OriginalCaptionML: Text)
    var
        ProfileResourceImportExport: Record "Profile Resource Import/Export";
        Matches: DotNet MatchCollection;
        AbbreviatedLanguageName: Text[3];
        Caption: Text[250];
        i: Integer;
    begin
        Matches := RegEx.Matches(OriginalCaptionML,ExtractCaptionMLPatternTxt);

        for i := 0 to Matches.Count - 1 do begin
          AbbreviatedLanguageName := Matches.Item(i).Value;
          AppendDetectedLanguage(AbbreviatedLanguageName);
          i += 1;
          Caption := Matches.Item(i).Value;

          ProfileResourceImportExport.InsertRec(
            CurrentProfileID,CurrentPageID,CurrentPersonalizationID,ControlGuid,AbbreviatedLanguageName,Caption);
        end;
    end;

    local procedure FindProfileLanguageResourcesImp(var ProfileResourceImportExport: Record "Profile Resource Import/Export";ControlGuid: Code[40];language: Text): Boolean
    begin
        ProfileResourceImportExport.SetRange("Abbreviated Language Name",language);
        ProfileResourceImportExport.SetRange("Profile ID",CurrentProfileID);
        ProfileResourceImportExport.SetRange("Page ID",CurrentPageID);
        ProfileResourceImportExport.SetRange("Personalization ID",CurrentPersonalizationID);
        ProfileResourceImportExport.SetRange("Control GUID",ControlGuid);
        exit(ProfileResourceImportExport.FindFirst);
    end;

    local procedure ClearResourcesForProfile(ProfileID: Code[30])
    var
        ProfileResourceImportExport: Record "Profile Resource Import/Export";
    begin
        ProfileResourceImportExport.SetRange("Profile ID",ProfileID);
        ProfileResourceImportExport.DeleteAll;
    end;

    local procedure CountResourcesForProfile(ProfileID: Code[30]): Integer
    var
        ProfileResourceImportExport: Record "Profile Resource Import/Export";
    begin
        ProfileResourceImportExport.SetRange("Profile ID",ProfileID);
        exit(ProfileResourceImportExport.Count);
    end;

    local procedure InitializeDotnetVariables()
    begin
        DetectedLanguages := DetectedLanguages.StringCollection;
        InfoForCompletionMessage := InfoForCompletionMessage.StringCollection;
        InstalledLanguages := InstalledLanguages.StringCollection;
    end;

    local procedure AppendDetectedLanguage(AbbreviatedLanguageName: Text[3])
    begin
        if not DetectedLanguages.Contains(AbbreviatedLanguageName) then
          DetectedLanguages.Add(AbbreviatedLanguageName);
    end;

    procedure GetCompletionMessage(ShowAsMessage: Boolean) CompleteMessage: Text
    var
        AdditionalInfo: Text;
    begin
        AdditionalInfo := GetAdditionalInfo;

        case Mode of
          Mode::Export:
            begin
              if AdditionalInfo <> '' then
                CompleteMessage := AdditionalInfo
              else
                CompleteMessage := ExportCompleteMsg;
            end;
          Mode::Import:
            begin
              if AdditionalInfo <> '' then begin
                AdditionalInfo := StrSubstNo(ProfileResxFileNotFoundMsg,AdditionalInfo);
                CompleteMessage := StrSubstNo(CompletionMessageMsg,ImportCompleteMsg,AdditionalInfo);
              end else
                CompleteMessage := ImportCompleteMsg;
            end;
          Mode::Remove:
            begin
              if AdditionalInfo <> '' then
                CompleteMessage := AdditionalInfo
              else
                CompleteMessage := RemoveCompleteMsg;
            end;
          else
            CompleteMessage := AdditionalInfo;
        end;

        if ShowAsMessage and (CompleteMessage <> '') then
          Message(CompleteMessage);
    end;

    local procedure GetAdditionalInfo() ErrorMessage: Text
    var
        i: Integer;
    begin
        if InfoForCompletionMessage.Count > 0 then begin
          for i := 0 to InfoForCompletionMessage.Count - 1 do
            ErrorMessage += InfoForCompletionMessage.Item(i) + '\';
          ErrorMessage := DelChr(ErrorMessage,'>','\');
        end;
    end;

    [Scope('Personalization')]
    procedure ValidateTimeZone(var TimeZoneText: Text)
    var
        TimeZone: Record "Time Zone";
    begin
        TimeZone.Get(FindTimeZoneNo(TimeZoneText));
        TimeZoneText := TimeZone.ID;
    end;

    [Scope('Personalization')]
    procedure LookupTimeZone(var TimeZoneText: Text): Boolean
    var
        TimeZone: Record "Time Zone";
    begin
        TimeZone."No." := FindTimeZoneNo(TimeZoneText);
        if PAGE.RunModal(PAGE::"Time Zones",TimeZone) = ACTION::LookupOK then begin
          TimeZoneText := TimeZone.ID;
          exit(true);
        end;
    end;

    local procedure FindTimeZoneNo(TimeZoneText: Text): Integer
    var
        TimeZone: Record "Time Zone";
    begin
        TimeZone.SetRange(ID,TimeZoneText);
        if not TimeZone.FindFirst then begin
          TimeZone.SetFilter(ID,'''@*' + TimeZoneText + '*''');
          TimeZone.Find('=<>');
        end;
        exit(TimeZone."No.");
    end;

    procedure CopyProfilePageMetadata(OldProfile: Record "All Profile";NewProfile: Record "All Profile")
    var
        ProfilePageMetadata: Record "Profile Page Metadata";
        NewProfilePageMetadata: Record "Profile Page Metadata";
        TenantProfilePageMetadata: Record "Tenant Profile Page Metadata";
        NewTenantProfilePageMetadata: Record "Tenant Profile Page Metadata";
    begin
        if OldProfile.Scope = OldProfile.Scope::System then begin
          ProfilePageMetadata.SetRange("Profile ID",OldProfile."Profile ID");
          if ProfilePageMetadata.FindSet then
            if NewProfile.Scope = NewProfile.Scope::System then
              repeat
                ProfilePageMetadata.CalcFields("Page Metadata","Page AL");

                NewProfilePageMetadata.Init;
                NewProfilePageMetadata.Copy(ProfilePageMetadata);
                NewProfilePageMetadata."Profile ID" := NewProfile."Profile ID";
                NewProfilePageMetadata.Insert;
              until ProfilePageMetadata.Next = 0
            else
              repeat
                TenantProfilePageMetadata.CalcFields("Page Metadata","Page AL");

                NewTenantProfilePageMetadata.Init;
                NewTenantProfilePageMetadata."Profile ID" := NewProfile."Profile ID";
                NewTenantProfilePageMetadata."Page ID" := ProfilePageMetadata."Page ID";
                NewTenantProfilePageMetadata."Page AL" := ProfilePageMetadata."Page AL";
                NewTenantProfilePageMetadata."Page Metadata" := ProfilePageMetadata."Page Metadata";
                NewTenantProfilePageMetadata.Insert;
              until ProfilePageMetadata.Next = 0;
        end;

        if (OldProfile.Scope = OldProfile.Scope::Tenant) and
           (NewProfile.Scope = NewProfile.Scope::Tenant)
        then begin
          TenantProfilePageMetadata.SetFilter("Profile ID",OldProfile."Profile ID");
          TenantProfilePageMetadata.SetFilter("App ID",OldProfile."App ID");
          if TenantProfilePageMetadata.FindSet then
            repeat
              TenantProfilePageMetadata.CalcFields("Page Metadata","Page AL");

              NewTenantProfilePageMetadata.Init;
              NewTenantProfilePageMetadata.Copy(TenantProfilePageMetadata);
              NewTenantProfilePageMetadata."Profile ID" := NewProfile."Profile ID";
              NewTenantProfilePageMetadata.Insert;
            until TenantProfilePageMetadata.Next = 0;
        end;
    end;

    procedure HideSandboxProfiles(var AllProfile: Record "All Profile")
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if PermissionManager.SoftwareAsAService and
           not PermissionManager.IsSandboxConfiguration
        then begin
          AllProfile.FilterGroup(2);
          AllProfile.SetFilter("Role Center ID",GetBuiltInSaaSProfilesFilter + '|10000..');
          AllProfile.FilterGroup(0);
        end;
    end;

    procedure GetBuiltInSaaSProfilesFilter() RoleCenterFilter: Text
    var
        PageNos: array [12] of Integer;
        i: Integer;
    begin
        PageNos[1] := PAGE::"Order Processor Role Center";
        PageNos[2] := PAGE::"Job Project Manager RC";
        PageNos[3] := PAGE::"Business Manager Role Center";
        PageNos[4] := PAGE::"Security Admin Role Center";
        PageNos[5] := PAGE::"Sales & Relationship Mgr. RC";
        PageNos[6] := PAGE::"Accountant Role Center";
        PageNos[7] := PAGE::"Team Member Role Center";
        PageNos[8] := PAGE::"Service Dispatcher Role Center";
        PageNos[9] := PAGE::"Production Planner Role Center";
        PageNos[10] := PAGE::"Whse. WMS Role Center";
        PageNos[11] := PAGE::"Whse. Basic Role Center";
        PageNos[12] := PAGE::"Whse. Worker WMS Role Center";

        for i := 1 to ArrayLen(PageNos) do
          RoleCenterFilter := RoleCenterFilter + '|' + Format(PageNos[i]);
        RoleCenterFilter := DelStr(RoleCenterFilter,1,1);
        OnGetBuiltInRoleCenterFilter(RoleCenterFilter);
    end;

    [Scope('Personalization')]
    procedure GetSettingsPageID(): Integer
    begin
        exit(PAGE::"My Settings");
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000006, 'GetDefaultRoleCenterID', '', false, false)]
    local procedure GetDefaultRoleCenterID(var ID: Integer)
    begin
        ID := DefaultRoleCenterID;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000006, 'OpenSettings', '', false, false)]
    local procedure OpenSettings()
    var
        SettingsPageID: Integer;
        Handled: Boolean;
    begin
        SettingsPageID := GetSettingsPageID;
        OnBeforeOpenSettings(SettingsPageID,Handled);
        if not Handled then
          PAGE.Run(SettingsPageID);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeProfiles()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProfileChanged(PrevProfileID: Code[30];ProfileID: Code[30])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyProfile(var AllProfile: Record "All Profile";NewAllProfile: Record "All Profile")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDefaultRoleCenter(var DefaultRoleCenterID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRoleCenterOpen()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenSettings(var SettingsPageID: Integer;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetBuiltInRoleCenterFilter(var RoleCenterFilter: Text)
    begin
    end;
}

