codeunit 9010 "Azure AD User Management"
{
    // version NAVW113.00

    Permissions = TableData Plan=rimd,
                  TableData "User Plan"=rimd,
                  TableData "Access Control"=rimd,
                  TableData User=rimd,
                  TableData "User Property"=rimd,
                  TableData "Membership Entitlement"=rimd;

    trigger OnRun()
    begin
        if ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Background then
          exit;

        Run(UserSecurityId);
    end;

    var
        PermissionManager: Codeunit "Permission Manager";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        Graph: DotNet GraphQuery;
        IsInitialized: Boolean;
        UserDoesNotObjectIdSetErr: Label 'The user with the security ID %1 does not have a valid object ID in Azure Active Directory.', Comment='%1 =  The specified User Security ID';
        CouldNotFindGraphUserErr: Label 'An Azure Active Directory user with the object ID %1 was not found.', Comment='%1 = The specified object id';
        IsTest: Boolean;
        MixedSKUsWithoutBasicErr: Label 'You cannot mix plans of type Essential and Premium. Contact your system administrator or Microsoft partner for assistance.\\You will be logged out when you choose the OK button.';
        MixedSKUsWithBasicErr: Label 'You cannot mix plans of type Basic, Essential, and Premium. Contact your system administrator or Microsoft partner for assistance.\\You will be logged out when you choose the OK button.';
        ChangesInPlansDetectedMsg: Label 'Changes in users plans were detected. Choose the Refresh all User Groups action in the Users window.';
        ProgressDlgMsg: Label 'No. of users retrieved: ''#1#################################\Current user name: ''#2#################################\', Comment='%1 Integer number, %2 a user name';
        NoOfUsersRetrievedMsg: Label 'No. of users retrieved: %1.', Comment='%1=integer number';

    procedure Run(ForUserSecurityId: Guid)
    var
        UserProperty: Record "User Property";
        PermissionManager: Codeunit "Permission Manager";
    begin
        // This function exists for testability
        if not PermissionManager.SoftwareAsAService then
          exit;

        if not UserProperty.Get(ForUserSecurityId) then
          exit;

        if not PermissionManager.IsFirstLogin(ForUserSecurityId) then
          exit;

        if GetUserAuthenticationObjectId(ForUserSecurityId) = '' then
          exit;

        RefreshUserPlanAssignments(ForUserSecurityId);
    end;

    procedure RefreshUserPlanAssignments(ForUserSecurityId: Guid)
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not User.Get(ForUserSecurityId) then
          exit;

        if not Initialize then
          exit;

        if not GetGraphUserFromObjectId(ForUserSecurityId,GraphUser) then
          exit;

        UpdateUserFromAzureGraph(User,GraphUser);
        UpdateUserPlansFromAzureGraph(User."User Security ID",GraphUser);
    end;

    procedure GetUserPlans(var TempPlan: Record Plan temporary;ForUserSecurityId: Guid;IncludePlansWithoutEntitlement: Boolean)
    var
        GraphUser: DotNet UserInfo;
    begin
        if not Initialize then
          exit;

        if GetGraphUserFromObjectId(ForUserSecurityId,GraphUser) then
          GetGraphUserPlans(TempPlan,GraphUser,IncludePlansWithoutEntitlement);
    end;

    procedure CreateNewUsersFromAzureAD()
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
        Window: Dialog;
        i: Integer;
    begin
        if not Initialize then
          exit;
        if GuiAllowed then
          Window.Open(ProgressDlgMsg);

        foreach GraphUser in Graph.GetUsers(5000) do begin
          i += 1;
          if GuiAllowed then begin
            Window.Update(1,i);
            Window.Update(2,GraphUser.DisplayName);
          end;
          if GetUserFromAuthenticationObjectId(GraphUser.ObjectId,User) then begin
            UpdateUserFromAzureGraph(User,GraphUser);
            UpdateUserPlansFromAzureGraph(User."User Security ID",GraphUser);
          end else
            CreateNewUserFromGraphUser(GraphUser);
        end;
        if GuiAllowed then begin
          Window.Close;
          Message(NoOfUsersRetrievedMsg,i);
        end;
    end;

    procedure CreateNewUserFromGraphUser(GraphUser: DotNet UserInfo)
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
        NewUserSecurityId: Guid;
    begin
        if IsGraphUserEntitledFromServicePlan(GraphUser) then begin
          EnsureAuthenticationEmailIsNotInUse(GraphUser.UserPrincipalName);
          Commit;
          NewUserSecurityId := UserAccountHelper.CreateUserFromAzureADObjectId(GraphUser.ObjectId);
          if not IsNullGuid(NewUserSecurityId) then
            InitializeAsNewUser(NewUserSecurityId,GraphUser);
        end;
    end;

    local procedure RemoveUnassignedUserPlans(var TempO365Plan: Record Plan temporary;ForUserSecurityId: Guid)
    var
        NavUserPlan: Record "User Plan";
        TempNavUserPlan: Record "User Plan" temporary;
    begin
        // Have any plans been removed from this user in O365, since last time he logged-in to NAV?
        // Get all plans assigned to the user, in NAV
        NavUserPlan.SetRange("User Security ID",ForUserSecurityId);
        if NavUserPlan.FindSet then
          repeat
            TempNavUserPlan.Copy(NavUserPlan,false);
            TempNavUserPlan.Insert;
          until NavUserPlan.Next = 0;

        // Get all plans assigned to the user in Office
        if TempO365Plan.FindSet then
          // And remove them from the list of plans assigned to the user
          repeat
            TempNavUserPlan.SetRange("Plan ID",TempO365Plan."Plan ID");
            if not TempNavUserPlan.IsEmpty then
              TempNavUserPlan.DeleteAll;
          until TempO365Plan.Next = 0;

        // If any plans belong to the user in NAV, but not in Office, de-assign them
        TempNavUserPlan.SetRange("Plan ID");
        if TempNavUserPlan.FindSet then
          repeat
            NavUserPlan.SetRange("Plan ID",TempNavUserPlan."Plan ID");
            if NavUserPlan.FindFirst then begin
              NavUserPlan.LockTable;
              NavUserPlan.Delete;
              RemoveUserGroupsForUserAndPlan(NavUserPlan);
              if not IsTest then
                Commit; // Finalize the transaction. Else any further error can rollback and create elevation of priviledge
            end;
          until TempNavUserPlan.Next = 0;
    end;

    procedure GetCurrentUserTokenClaim(ClaimName: Text): Text
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
    begin
        exit(UserAccountHelper.GetCurrentUserTokenClaim(ClaimName));
    end;

    local procedure AddNewlyAssignedUserPlans(var TempO365Plan: Record Plan temporary;ForUserSecurityId: Guid)
    var
        NavUserPlan: Record "User Plan";
        PermissionManager: Codeunit "Permission Manager";
    begin
        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        // For each plan assigned to the user in Office
        if TempO365Plan.FindSet then
          repeat
            // Does this assignment exist in NAV? If not, add it.
            NavUserPlan.SetRange("Plan ID",TempO365Plan."Plan ID");
            NavUserPlan.SetRange("User Security ID",ForUserSecurityId);
            if NavUserPlan.IsEmpty then begin
              InsertFromTempPlan(TempO365Plan);
              NavUserPlan.LockTable;
              NavUserPlan.Init;
              NavUserPlan."Plan ID" := TempO365Plan."Plan ID";
              NavUserPlan."User Security ID" := ForUserSecurityId;
              NavUserPlan.Insert;
              // The SUPER role is replaced with O365 FULL ACCESS for new users.
              // This happens only for users who are created from O365 (i.e. are added to plans)
              PermissionManager.UpdateUserAccessForSaaS(NavUserPlan."User Security ID");
              if not IsTest then
                Commit; // Finalize the transaction. Else any further error can rollback and create elevation of priviledge
            end;
          until TempO365Plan.Next = 0;
    end;

    local procedure GetGraphUserPlans(var TempPlan: Record Plan temporary;var GraphUser: DotNet UserInfo;IncludePlansWithoutEntitlement: Boolean)
    var
        AssignedPlan: DotNet ServicePlanInfo;
        DirectoryRole: DotNet RoleInfo;
        ServicePlanIdValue: Variant;
        IsSystemRole: Boolean;
        HaveAssignedPlans: Boolean;
    begin
        TempPlan.Reset;
        TempPlan.DeleteAll;

        // Loop through assigned Azzure AD Plans
        foreach AssignedPlan in GraphUser.AssignedPlans do begin
          HaveAssignedPlans := true;
          if AssignedPlan.CapabilityStatus = 'Enabled' then begin
            ServicePlanIdValue := AssignedPlan.ServicePlanId;
            if IncludePlansWithoutEntitlement or IsNavServicePlan(ServicePlanIdValue) then
              AddToTempPlan(ServicePlanIdValue,AssignedPlan.ServicePlanName,TempPlan);
          end;
        end;

        // If there are no Azure AD Plans, loop through Azure AD Roles
        if not HaveAssignedPlans then
          foreach DirectoryRole in Graph.GetUserRoles(GraphUser) do begin
            Evaluate(IsSystemRole,Format(DirectoryRole.IsSystem));
            if IncludePlansWithoutEntitlement or IsSystemRole then
              AddToTempPlan(DirectoryRole.RoleTemplateId,DirectoryRole.DisplayName,TempPlan);
          end;
    end;

    [TryFunction]
    local procedure GetGraphUserFromObjectId(ForUserSecurityID: Guid;var GraphUser: DotNet UserInfo)
    var
        UserObjectID: Text;
    begin
        if ForUserSecurityID = UserSecurityId then begin
          GraphUser := Graph.GetCurrentUser;
          if not IsNull(GraphUser) then
            exit;
        end;

        UserObjectID := GetUserAuthenticationObjectId(ForUserSecurityID);
        if UserObjectID = '' then
          Error(CouldNotFindGraphUserErr,UserObjectID);

        GraphUser := Graph.GetUserByObjectId(UserObjectID);
        if IsNull(GraphUser) then
          Error(CouldNotFindGraphUserErr,UserObjectID);
    end;

    local procedure InsertFromTempPlan(var TempPlan: Record Plan temporary)
    var
        Plan: Record Plan;
    begin
        if not Plan.Get(TempPlan."Plan ID") then begin
          Plan.Init;
          Plan.Copy(TempPlan);
          Plan.Insert;
        end;
    end;

    local procedure IsGraphUserEntitledFromServicePlan(var GraphUser: DotNet UserInfo): Boolean
    var
        AssignedPlan: DotNet ServicePlanInfo;
        ServicePlanIdValue: Variant;
    begin
        foreach AssignedPlan in GraphUser.AssignedPlans do begin
          ServicePlanIdValue := AssignedPlan.ServicePlanId;
          if IsNavServicePlan(ServicePlanIdValue) then
            exit(true);
        end;

        exit(false);
    end;

    local procedure IsNavServicePlan(ServicePlanId: DotNet Guid): Boolean
    var
        Plan: Record Plan;
    begin
        exit(Plan.Get(ServicePlanId.ToString('D')));
    end;

    procedure GetUserObjectId(ForUserSecurityId: Guid): Text[250]
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not User.Get(ForUserSecurityId) then
          exit('');

        if not GetGraphUserFromObjectId(ForUserSecurityId,GraphUser) then
          exit('');

        exit(CopyStr(GraphUser.ObjectId,1,250));
    end;

    local procedure GetUserAuthenticationObjectId(ForUserSecurityId: Guid): Text
    var
        UserProperty: Record "User Property";
    begin
        if not UserProperty.Get(ForUserSecurityId) then
          Error(UserDoesNotObjectIdSetErr,ForUserSecurityId);

        exit(UserProperty."Authentication Object ID");
    end;

    local procedure GetUserFromAuthenticationObjectId(AuthenticationObjectId: Text;var FoundUser: Record User): Boolean
    var
        UserProperty: Record "User Property";
    begin
        UserProperty.SetRange("Authentication Object ID",AuthenticationObjectId);
        if UserProperty.FindFirst then
          exit(FoundUser.Get(UserProperty."User Security ID"));
        exit(false)
    end;

    procedure GetAzureUserPlanRoleCenterId(ForUserSecurityId: Guid): Integer
    var
        TempO365Plan: Record Plan temporary;
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not User.Get(ForUserSecurityId) then
          exit(0);

        if not Initialize then
          exit(0);

        if not GetGraphUserFromObjectId(ForUserSecurityId,GraphUser) then
          exit(0);

        GetGraphUserPlans(TempO365Plan,GraphUser,false);

        TempO365Plan.SetFilter("Role Center ID",'<>0');

        if not TempO365Plan.FindFirst then
          exit(0);

        exit(TempO365Plan."Role Center ID");
    end;

    [TryFunction]
    procedure TryGetAzureUserPlanRoleCenterId(var RoleCenterID: Integer;ForUserSecurityId: Guid)
    begin
        RoleCenterID := GetAzureUserPlanRoleCenterId(ForUserSecurityId);
    end;

    local procedure UpdateUserFromAzureGraph(var User: Record User;var GraphUser: DotNet UserInfo): Boolean
    var
        ModifyUser: Boolean;
        TempString: Text;
    begin
        User.LockTable;
        if not User.Get(User."User Security ID") then
          exit;

        if (UpperCase(Format(GraphUser.AccountEnabled)) = 'TRUE') and (User.State = User.State::Disabled) then begin
          User.State := User.State::Enabled;
          ModifyUser := true;
        end;

        if (UpperCase(Format(GraphUser.AccountEnabled)) = 'FALSE') and (User.State = User.State::Enabled) then begin
          User.State := User.State::Disabled;
          ModifyUser := true;
        end;

        TempString := GraphUser.GivenName;
        if GraphUser.Surname <> '' then
          TempString := TempString + ' ';
        TempString := TempString + GraphUser.Surname;
        TempString := CopyStr(TempString,1,MaxStrLen(User."Full Name"));
        if LowerCase(User."Full Name") <> LowerCase(TempString) then begin
          User."Full Name" := TempString;
          ModifyUser := true;
        end;

        TempString := Format(GraphUser.Mail);
        TempString := CopyStr(TempString,1,MaxStrLen(User."Contact Email"));
        if LowerCase(User."Contact Email") <> LowerCase(TempString) then begin
          User."Contact Email" := TempString;
          ModifyUser := true;
        end;

        TempString := CopyStr(GraphUser.UserPrincipalName,1,MaxStrLen(User."Authentication Email"));
        if LowerCase(User."Authentication Email") <> LowerCase(TempString) then begin
          // Clear current authentication mail
          User."Authentication Email" := '';
          User.Modify;
          ModifyUser := false;

          EnsureAuthenticationEmailIsNotInUse(TempString);
          UpdateAuthenticationEmail(User,GraphUser);
        end;

        if ModifyUser then
          User.Modify;

        SetUserLanguage(GraphUser.PreferredLanguage);

        exit(ModifyUser);
    end;

    local procedure UpdateUserPlansFromAzureGraph(ForUserSecurityId: Guid;var GraphUser: DotNet UserInfo)
    var
        TempO365Plan: Record Plan temporary;
    begin
        GetGraphUserPlans(TempO365Plan,GraphUser,false);

        // Have any plans been removed from this user in O365, since last time he logged-in to NAV?
        RemoveUnassignedUserPlans(TempO365Plan,ForUserSecurityId);

        // Have any plans been added to this user in O365, since last time he logged-in to NAV?
        AddNewlyAssignedUserPlans(TempO365Plan,ForUserSecurityId);
    end;

    procedure UpdateUserPlansFromAzureGraphAllUsers()
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not Initialize then
          exit;

        User.SetFilter("License Type",'<>%1',User."License Type"::"External User");
        User.SetFilter("Windows Security ID",'=''''');

        if not User.FindSet then
          exit;

        repeat
          if GetGraphUserFromObjectId(User."User Security ID",GraphUser) then
            UpdateUserPlansFromAzureGraph(User."User Security ID",GraphUser);
        until User.Next = 0;
    end;

    local procedure AddToTempPlan(ServicePlanId: Guid;ServicePlanName: Text;var TempPlan: Record Plan temporary)
    var
        Plan: Record Plan;
    begin
        with TempPlan do begin
          if Get(ServicePlanId) then
            exit;

          if Plan.Get(ServicePlanId) then;

          Init;
          "Plan ID" := ServicePlanId;
          Name := CopyStr(ServicePlanName,1,MaxStrLen(Name));
          "Role Center ID" := Plan."Role Center ID";
          Insert;
        end;
    end;

    local procedure EnsureAuthenticationEmailIsNotInUse(AuthenticationEmail: Text)
    var
        User: Record User;
        ModifiedUser: Record User;
        GraphUser: DotNet UserInfo;
        UserSecurityId: Guid;
    begin
        // Clear all duplicate authentication email.
        User.SetRange("Authentication Email",CopyStr(AuthenticationEmail,1,MaxStrLen(User."Authentication Email")));
        if not User.FindFirst then
          exit;
        repeat
          UserSecurityId := User."User Security ID";
          // Modifying the user authentication email breaks the connection to AD by clearing the Authentication Object Id
          User."Authentication Email" := '';
          User.Modify;

          // Cascade changes to authentication email, terminates at the first time an authentication email is not found.
          if GetGraphUserFromObjectId(User."User Security ID",GraphUser) then begin
            EnsureAuthenticationEmailIsNotInUse(GraphUser.UserPrincipalName);
            if ModifiedUser.Get(UserSecurityId) then
              UpdateAuthenticationEmail(ModifiedUser,GraphUser);
          end;
        until not User.FindFirst;
    end;

    local procedure UpdateAuthenticationEmail(var User: Record User;var GraphUser: DotNet UserInfo)
    var
        NavUserAuthenticationHelper: DotNet NavUserAccountHelper;
    begin
        User."Authentication Email" := CopyStr(GraphUser.UserPrincipalName,1,MaxStrLen(User."Authentication Email"));
        User.Modify;
        NavUserAuthenticationHelper.SetAuthenticationObjectId(User."User Security ID",GraphUser.ObjectId);
    end;

    local procedure SetUserLanguage(PreferredLanguage: Text)
    var
        Language: Record Language;
        UserPersonalization: Record "User Personalization";
        LanguageManagement: Codeunit LanguageManagement;
        IdentityManagement: Codeunit "Identity Management";
        LanguageCode: Code[10];
        LanguageId: Integer;
    begin
        if not IdentityManagement.IsInvAppId then
          exit;

        LanguageId := LanguageManagement.ApplicationLanguage;

        // We will use default application language if the PreferredLanguage is blank or en-us
        // (i.e. don't spend time trying to lookup the code)
        if not (LowerCase(PreferredLanguage) in ['','en-us']) then
          if TryGetLanguageCode(PreferredLanguage,LanguageCode) then ;

        // If we support the language, get the language id
        // If we don't, we keep the current value (default application language)
        if LanguageCode <> '' then
          if Language.Get(LanguageCode) then
            LanguageId := Language."Windows Language ID";

        if not UserPersonalization.Get(UserSecurityId) then
          exit;

        // Only lock the table if there is a change
        if UserPersonalization."Language ID" = LanguageId then
          exit; // No changes required

        UserPersonalization.LockTable;
        UserPersonalization.Get(UserSecurityId);
        UserPersonalization.Validate("Language ID",LanguageId);
        UserPersonalization.Validate("Locale ID",LanguageId);
        UserPersonalization.Modify(true);
    end;

    [TryFunction]
    local procedure TryGetLanguageCode(CultureName: Text;var CultureCode: Code[10])
    var
        CultureInfo: DotNet CultureInfo;
    begin
        CultureInfo := CultureInfo.CultureInfo(CultureName);
        CultureCode := CultureInfo.ThreeLetterWindowsLanguageName;
    end;

    local procedure InitializeAsNewUser(NewUserSecurityId: Guid;var GraphUser: DotNet UserInfo)
    var
        User: Record User;
    begin
        User.Get(NewUserSecurityId);

        UpdateUserFromAzureGraph(User,GraphUser);
        UpdateUserPlansFromAzureGraph(User."User Security ID",GraphUser);
    end;

    local procedure Initialize(): Boolean
    begin
        if not PermissionManager.SoftwareAsAService then
          exit(false);

        if IsInitialized then
          exit(true);

        if CanHandle then begin
          if not TryCreateGraph(Graph) then
            exit(false)
        end else
          OnInitialize(Graph);

        IsInitialized := not IsNull(Graph);
        exit(IsInitialized);
    end;

    [TryFunction]
    local procedure TryCreateGraph(var GraphQuery: DotNet GraphQuery)
    begin
        GraphQuery := GraphQuery.GraphQuery
    end;

    local procedure CanHandle(): Boolean
    var
        AzureADMgtSetup: Record "Azure AD Mgt. Setup";
    begin
        if AzureADMgtSetup.Get then
          exit(AzureADMgtSetup."Azure AD User Mgt. Codeunit ID" = CODEUNIT::"Azure AD User Management");

        exit(true);
    end;

    local procedure RemoveUserGroupsForUserAndPlan(UserPlan: Record "User Plan")
    var
        UserGroupMember: Record "User Group Member";
        UserGroupPlan: Record "User Group Plan";
    begin
        // Remove related user groups from the user
        UserGroupPlan.SetRange("Plan ID",UserPlan."Plan ID");
        if not UserGroupPlan.FindSet then
          exit; // no user groups to remove from this user

        UserGroupMember.SetRange("User Security ID",UserPlan."User Security ID");
        repeat
          UserGroupMember.SetRange("User Group Code",UserGroupPlan."User Group Code");
          UserGroupMember.DeleteAll(true);
        until UserGroupPlan.Next = 0;
    end;

    [IntegrationEvent(false, TRUE)]
    local procedure OnInitialize(var GraphQuery: DotNet GraphQuery)
    begin
    end;

    procedure GetTenantDetail(var TenantDetail: DotNet TenantInfo): Boolean
    begin
        if not Initialize then
          exit(false);

        TenantDetail := Graph.GetTenantDetail;
        exit(not IsNull(TenantDetail));
    end;

    [Scope('Personalization')]
    procedure SetTestability(EnableTestability: Boolean)
    begin
        IsTest := EnableTestability;
    end;

    procedure CheckMixedPlans()
    var
        Plan: Record Plan;
        UserPlan: Record "User Plan";
        Company: Record Company;
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not PermissionManager.SoftwareAsAService then
          exit;

        if not GuiAllowed then
          exit;

        if Company.Get(CompanyName) then
          if Company."Evaluation Company" then
            exit;

        if Plan.IsEmpty then
          exit;

        if UserPlan.IsEmpty then
          exit;

        if not MixedPlansExist then
          exit;

        if not PermissionManager.CanCurrentUserManagePlansAndGroups then begin
          if PlansExist(Plan.GetBasicPlanId) then
            Error(MixedSKUsWithBasicErr);
          Error(MixedSKUsWithoutBasicErr);
        end;
        Message(ChangesInPlansDetectedMsg);
    end;

    procedure MixedPlansExist(): Boolean
    var
        Plan: Record Plan;
        BasicPlanUserExists: Boolean;
        EssentialPlanUserExists: Boolean;
        PremiumPlanUserExists: Boolean;
    begin
        BasicPlanUserExists := PlansExist(Plan.GetBasicPlanId);
        EssentialPlanUserExists := PlansExist(Plan.GetEssentialPlanId);
        PremiumPlanUserExists := PlansExist(Plan.GetPremiumPlanId);

        if (BasicPlanUserExists and EssentialPlanUserExists) or (BasicPlanUserExists and PremiumPlanUserExists) or
           (EssentialPlanUserExists and PremiumPlanUserExists)
        then
          exit(true)
    end;

    procedure PlansExist(PlanId: Guid): Boolean
    var
        UsersInPlans: Query "Users in Plans";
    begin
        UsersInPlans.SetRange(User_State,UsersInPlans.User_State::Enabled);
        UsersInPlans.SetRange(Plan_ID,PlanId);
        if UsersInPlans.Open then
          exit(UsersInPlans.Read);
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', false, false)]
    local procedure CheckMixedPlansOnAfterCompanyOpen()
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
    begin
        AzureADUserManagement.CheckMixedPlans;
    end;

    [Scope('Personalization')]
    procedure SynchronizeLicensedUserFromDirectory(AuthenticationEmail: Text): Boolean
    var
        User: Record User;
        GraphUser: DotNet UserInfo;
    begin
        if not Initialize then
          exit(false);

        GraphUser := Graph.GetUser(AuthenticationEmail);
        if IsNull(GraphUser) then
          exit(false);

        if GetUserFromAuthenticationObjectId(GraphUser.ObjectId,User) then begin
          UpdateUserFromAzureGraph(User,GraphUser);
          UpdateUserPlansFromAzureGraph(User."User Security ID",GraphUser);
        end else
          CreateNewUserFromGraphUser(GraphUser);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure SynchronizeAllLicensedUsersFromDirectory()
    begin
        CreateNewUsersFromAzureAD
    end;
}

