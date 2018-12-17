codeunit 9002 "Permission Manager"
{
    // version NAVW113.00

    Permissions = TableData "Encrypted Key/Value"=r,
                  TableData "User Group Plan"=rimd,
                  TableData "User Login"=rimd;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        OfficePortalUserAdministrationUrlTxt: Label 'https://portal.office.com/admin/default.aspx#ActiveUsersPage', Locked=true;
        TestabilityPreview: Boolean;
        TestabilitySoftwareAsAService: Boolean;
        SUPERPermissionSetTxt: Label 'SUPER', Locked=true;
        SUPERPermissionErr: Label 'At least one user must be a member of the ''SUPER'' group in all companies.';
        SECURITYPermissionSetTxt: Label 'SECURITY', Locked=true;
        IncorrectCalculatedHashErr: Label 'Hash calculated for permission set %1 is ''%2''.', Comment='%1 = permission set id, %2 = value of calculated hash';
        IntelligentCloudTok: Label 'INTELLIGENT CLOUD', Locked=true;
        TestabilityIntelligentCloud: Boolean;

    [Scope('Personalization')]
    procedure AddUserToUserGroup(UserSecurityID: Guid;UserGroupCode: Code[20];Company: Text[30])
    var
        UserGroupMember: Record "User Group Member";
    begin
        if not UserGroupMember.Get(UserGroupCode,UserSecurityID,Company) then begin
          UserGroupMember.Init;
          UserGroupMember."Company Name" := Company;
          UserGroupMember."User Security ID" := UserSecurityID;
          UserGroupMember."User Group Code" := UserGroupCode;
          UserGroupMember.Insert(true);
        end;
    end;

    [Scope('Personalization')]
    procedure AddUserToDefaultUserGroups(UserSecurityID: Guid): Boolean
    begin
        exit(AddUserToDefaultUserGroupsForCompany(UserSecurityID,CompanyName));
    end;

    procedure AddUserToDefaultUserGroupsForCompany(UserSecurityID: Guid;Company: Text[30]) UserGroupsAdded: Boolean
    var
        UserPlan: Record "User Plan";
    begin
        // Add the new user to all user groups of the plan

        // No plan is assigned to this user
        UserPlan.SetRange("User Security ID",UserSecurityID);
        if not UserPlan.FindSet then begin
          UserGroupsAdded := false;
          exit;
        end;

        // There is at least a plan assigned (and probably only one)
        repeat
          if AddUserToAllUserGroupsOfThePlanForCompany(UserSecurityID,UserPlan."Plan ID",Company) then
            UserGroupsAdded := true;
        until UserPlan.Next = 0;
    end;

    local procedure AddUserToAllUserGroupsOfThePlanForCompany(UserSecurityID: Guid;PlanID: Guid;Company: Text[30]): Boolean
    var
        UserGroupPlan: Record "User Group Plan";
    begin
        // Get all User Groups in plan
        UserGroupPlan.SetRange("Plan ID",PlanID);
        if not UserGroupPlan.FindSet then
          exit(false); // nothing to add

        // Assign groups to the current user (if not assigned already)
        repeat
          AddUserToUserGroup(UserSecurityID,UserGroupPlan."User Group Code",Company);
        until UserGroupPlan.Next = 0;
        exit(true);
    end;

    local procedure RemoveUserFromAllPermissionSets(UserSecurityID: Guid)
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID",UserSecurityID);
        AccessControl.DeleteAll(true);
    end;

    local procedure RemoveUserFromAllUserGroups(UserSecurityID: Guid)
    var
        UserGroupMember: Record "User Group Member";
    begin
        UserGroupMember.SetRange("User Security ID",UserSecurityID);
        UserGroupMember.DeleteAll(true);
    end;

    [Scope('Personalization')]
    procedure ResetUserToDefaultUserGroups(UserSecurityID: Guid)
    begin
        // Remove the user from all assigned user groups and their related permission sets
        RemoveUserFromAllUserGroups(UserSecurityID);

        // Remove the user from any additional, manually assigned permission sets
        RemoveUserFromAllPermissionSets(UserSecurityID);

        // Add the user to all the user groups (and their permission sets) which are
        // defined in the user's assigned subscription plan
        AddUserToDefaultUserGroups(UserSecurityID);
    end;

    [Scope('Personalization')]
    procedure GetOfficePortalUserAdminUrl(): Text
    begin
        exit(OfficePortalUserAdministrationUrlTxt);
    end;

    procedure SetTestabilityPreview(EnablePreviewForTest: Boolean)
    begin
        TestabilityPreview := EnablePreviewForTest;
    end;

    [Scope('Personalization')]
    procedure IsPreview(): Boolean
    begin
        if TestabilityPreview then
          exit(true);

        // temporary fix until platform implements correct solution
        exit(false);
    end;

    [Scope('Personalization')]
    procedure IsSandboxConfiguration(): Boolean
    var
        TenantManagementHelper: Codeunit "Tenant Management";
        IsSandbox: Boolean;
    begin
        IsSandbox := TenantManagementHelper.IsSandbox;
        exit(IsSandbox);
    end;

    [Scope('Internal')]
    procedure SetTestabilitySoftwareAsAService(EnableSoftwareAsAServiceForTest: Boolean)
    begin
        TestabilitySoftwareAsAService := EnableSoftwareAsAServiceForTest;
    end;

    [Scope('Personalization')]
    procedure SoftwareAsAService(): Boolean
    var
        MembershipEntitlement: Record "Membership Entitlement";
    begin
        if TestabilitySoftwareAsAService then
          exit(true);

        exit(not MembershipEntitlement.IsEmpty);
    end;

    [Scope('Personalization')]
    procedure UpdateUserAccessForSaaS(UserSID: Guid)
    begin
        if not AllowUpdateUserAccessForSaaS(UserSID) then
          exit;

        // Only remove SUPER if other permissions are granted (to avoid user lockout)
        if AddUserToDefaultUserGroups(UserSID) then begin
          AssignDefaultRoleCenterToUser(UserSID);
          RemoveSUPERPermissionSetFromUserIfMoreSupersExist(UserSID);
          StoreUserFirstLogin(UserSID);
        end;

        if IsIntelligentCloud and not IsSuper(UserSID) then
          RemoveExistingPermissionsAndAddIntelligentCloud(UserSID,CompanyName);
    end;

    local procedure AllowUpdateUserAccessForSaaS(UserSID: Guid): Boolean
    var
        User: Record User;
        UserPlan: Record "User Plan";
        Plan: Record Plan;
    begin
        if not SoftwareAsAService then
          exit(false);

        if IsNullGuid(UserSID) then
          exit(false);

        // Don't demote external users (like the sync daemon)
        User.Get(UserSID);
        if User."License Type" = User."License Type"::"External User" then
          exit(false);

        // Don't demote users which don't come from Office365 (have no plans assigned)
        // Note: all users who come from O365, if they don't have a plan, they don't get a license (hence, no SUPER role)
        UserPlan.SetRange("User Security ID",User."User Security ID");
        if not UserPlan.FindFirst then
          exit(false);

        // Don't demote users then have a invalid plan likely comming from 1.5
        if not Plan.Get(UserPlan."Plan ID") then
          exit(false);
        if Plan."Role Center ID" = 0 then
          exit(false);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure AddUserGroupFromExtension(UserGroupCode: Code[20];RoleID: Code[20];AppGuid: Guid)
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        UserGroup: Record "User Group";
    begin
        if not SoftwareAsAService then
          if not UserGroup.Get(UserGroupCode) then
            exit;

        UserGroupPermissionSet.Init;
        UserGroupPermissionSet."User Group Code" := UserGroupCode;
        UserGroupPermissionSet."Role ID" := RoleID;
        UserGroupPermissionSet."App ID" := AppGuid;
        UserGroupPermissionSet.Scope := UserGroupPermissionSet.Scope::Tenant;
        if not UserGroupPermissionSet.Find then
          UserGroupPermissionSet.Insert(true);
    end;

    local procedure DeleteSuperFromUser(UserSID: Guid)
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("Role ID",SUPERPermissionSetTxt);
        AccessControl.SetRange("Company Name",'');
        AccessControl.SetRange("User Security ID",UserSID);
        AccessControl.DeleteAll(true);
    end;

    local procedure IsExternalUser(UserSID: Guid): Boolean
    var
        User: Record User;
    begin
        if User.Get(UserSID) then
          exit(User."License Type" = User."License Type"::"External User");

        exit(false);
    end;

    local procedure IsEnabledUser(UserSID: Guid): Boolean
    var
        User: Record User;
    begin
        if User.Get(UserSID) then
          exit(User.State = User.State::Enabled);

        exit(false);
    end;

    procedure IsSuper(UserSID: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        if User.IsEmpty then
          exit(true);

        AccessControl.SetRange("Role ID",SUPERPermissionSetTxt);
        AccessControl.SetFilter("Company Name",'%1|%2','',CompanyName);
        AccessControl.SetRange("User Security ID",UserSID);
        exit(not AccessControl.IsEmpty);
    end;

    local procedure IsSomeoneElseSuper(UserSID: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        if User.IsEmpty then
          exit(true);

        AccessControl.LockTable;
        AccessControl.SetRange("Role ID",SUPERPermissionSetTxt);
        AccessControl.SetRange("Company Name",'');
        AccessControl.SetFilter("User Security ID",'<>%1',UserSID);

        if not AccessControl.FindSet then // no other user is SUPER
          exit(false);

        repeat
          // Sync Deamon should not count as a super user and he has a external license
          if not IsExternalUser(AccessControl."User Security ID") then
            exit(true);
        until AccessControl.Next = 0;

        exit(false);
    end;

    local procedure IsSomeoneElseEnabledSuper(UserSID: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        if User.IsEmpty then
          exit(true);

        AccessControl.LockTable;
        AccessControl.SetRange("Role ID",SUPERPermissionSetTxt);
        AccessControl.SetRange("Company Name",'');
        AccessControl.SetFilter("User Security ID",'<>%1',UserSID);

        if not AccessControl.FindSet then // no other user is SUPER
          exit(false);

        repeat
          // Sync Deamon should not count as a super user and he has a external license
          if IsEnabledUser(AccessControl."User Security ID") and not IsExternalUser(AccessControl."User Security ID") then
            exit(true);
        until AccessControl.Next = 0;

        exit(false);
    end;

    local procedure RemoveSUPERPermissionSetFromUserIfMoreSupersExist(UserSID: Guid)
    begin
        if IsUserAdmin(UserSID) then
          exit;

        if IsSomeoneElseSuper(UserSID) then
          DeleteSuperFromUser(UserSID);
    end;

    [Scope('Personalization')]
    procedure IsFirstLogin(UserSecurityID: Guid): Boolean
    var
        UserLogin: Record "User Login";
    begin
        // Only update first-time login users
        if UserLogin.Get(UserSecurityID) then
          exit(false); // This user logged in before

        exit(true);
    end;

    local procedure StoreUserFirstLogin(UserSecurityID: Guid)
    var
        UserLogin: Record "User Login";
    begin
        if UserLogin.Get(UserSecurityID) then
          exit; // the user has already been logged in before
        UserLogin.Init;
        UserLogin.Validate("User SID",UserSecurityID);
        UserLogin.Validate("First Login Date",Today);
        UserLogin.Insert;
    end;

    local procedure AssignDefaultRoleCenterToUser(UserSecurityID: Guid)
    var
        UserPlan: Record "User Plan";
        UserPersonalization: Record "User Personalization";
        Plan: Record Plan;
        "Profile": Record "All Profile";
    begin
        UserPlan.SetRange("User Security ID",UserSecurityID);

        if not UserPlan.FindFirst then
          exit; // this user has no plans assigned, so they'll get the app-wide default role center

        Plan.Get(UserPlan."Plan ID");
        Profile.SetRange("Role Center ID",Plan."Role Center ID");

        if not Profile.FindFirst then
          exit; // the plan does not have a role center, so they'll get the app-wide default role center

        // Create the user personalization record
        if not UserPersonalization.Get(UserSecurityID) then begin
          UserPersonalization.Init;
          UserPersonalization.Validate("User SID",UserSecurityID);
          UserPersonalization.Validate("Profile ID",Profile."Profile ID");
          UserPersonalization.Validate("App ID",Profile."App ID");
          UserPersonalization.Validate(Scope,Profile.Scope);
          UserPersonalization.Insert;
          exit;
        end;
    end;

    procedure GetDefaultProfileID(UserSecurityID: Guid;var "Profile": Record "All Profile")
    var
        UserPlan: Record "User Plan";
        Plan: Record Plan;
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        UserPlan.SetRange("User Security ID",UserSecurityID);
        if UserPlan.FindFirst then
          if Plan.Get(UserPlan."Plan ID") then begin
            Profile.SetRange("Role Center ID",Plan."Role Center ID");
            if Profile.FindFirst then
              exit;
          end;

        Profile.Reset;
        Profile.SetRange("Default Role Center",true);
        if Profile.FindFirst then
          exit;

        Profile.Reset;
        Profile.SetRange("Role Center ID",ConfPersonalizationMgt.DefaultRoleCenterID);
        if Profile.FindFirst then
          exit;

        Profile.Reset;
        if Profile.FindFirst then
          exit;
    end;

    procedure CanCurrentUserManagePlansAndGroups(): Boolean
    var
        UserPlan: Record "User Plan";
        UserGroupMember: Record "User Group Member";
        AccessControl: Record "Access Control";
        UserGroupAccessControl: Record "User Group Access Control";
        UserGroupPermissionSet: Record "User Group Permission Set";
    begin
        exit(
          UserPlan.WritePermission and UserGroupMember.WritePermission and
          AccessControl.WritePermission and UserGroupAccessControl.WritePermission and
          UserGroupPermissionSet.WritePermission);
    end;

    [EventSubscriber(ObjectType::Table, 2000000053, 'OnBeforeRenameEvent', '', false, false)]
    local procedure CheckSuperPermissionsOnBeforeRenameAccessControl(var Rec: Record "Access Control";var xRec: Record "Access Control";RunTrigger: Boolean)
    begin
        if not SoftwareAsAService then
          exit;

        if xRec."Role ID" <> SUPERPermissionSetTxt then
          exit;

        if (Rec."Role ID" <> SUPERPermissionSetTxt) and (not IsSomeoneElseSuper(Rec."User Security ID")) then
          Error(SUPERPermissionErr);

        if (Rec."Company Name" <> '') and (not IsSomeoneElseSuper(Rec."User Security ID")) then
          Error(SUPERPermissionErr)
    end;

    [EventSubscriber(ObjectType::Table, 2000000053, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckSuperPermissionsOnBeforeDeleteAccessControl(var Rec: Record "Access Control";RunTrigger: Boolean)
    var
        EmptyGUID: Guid;
    begin
        if not SoftwareAsAService then
          exit;

        if not RunTrigger then
          exit;

        if Rec."Role ID" <> SUPERPermissionSetTxt then
          exit;

        if (Rec."Company Name" <> '') and IsSuper(Rec."User Security ID") then
          exit;

        // If nobody was SUPER in all companies before, the delete is not going to make it worse
        if not IsSomeoneElseSuper(EmptyGUID) then
          exit;

        if not IsSomeoneElseSuper(Rec."User Security ID") then
          Error(SUPERPermissionErr)
    end;

    [EventSubscriber(ObjectType::Table, 2000000120, 'OnBeforeModifyEvent', '', true, true)]
    local procedure CheckSuperPermissionsOnDisableUser(var Rec: Record User;var xRec: Record User;RunTrigger: Boolean)
    begin
        if not IsSuper(Rec."User Security ID") then
          exit;
        if IsSomeoneElseEnabledSuper(Rec."User Security ID") then
          exit;
        if (Rec.State = Rec.State::Disabled) and (xRec.State = xRec.State::Enabled) then
          Error(SUPERPermissionErr);
    end;

    [EventSubscriber(ObjectType::Table, 2000000120, 'OnAfterDeleteEvent', '', true, true)]
    local procedure CheckSuperPermissionsOnDeleteUser(var Rec: Record User;RunTrigger: Boolean)
    begin
        if Rec.IsTemporary then
          exit;
        if not IsSuper(Rec."User Security ID") then
          exit;
        if IsSomeoneElseEnabledSuper(Rec."User Security ID") then
          exit;
        Error(SUPERPermissionErr);
    end;

    procedure CanManageUsersOnTenant(UserSID: Guid): Boolean
    var
        AccessControl: Record "Access Control";
        User: Record User;
    begin
        if User.IsEmpty then
          exit(true);

        if IsSuper(UserSID) then
          exit(true);

        AccessControl.SetRange("Role ID",SECURITYPermissionSetTxt);
        AccessControl.SetFilter("Company Name",'%1|%2','',CompanyName);
        AccessControl.SetRange("User Security ID",UserSID);
        exit(not AccessControl.IsEmpty);
    end;

    local procedure IsUserAdmin(SecurityID: Guid): Boolean
    var
        Plan: Record Plan;
        UserPlan: Record "User Plan";
    begin
        UserPlan.SetRange("User Security ID",SecurityID);
        if UserPlan.FindFirst then
          exit((UserPlan."Plan ID" = Plan.GetInternalAdminPlanId) or (UserPlan."Plan ID" = Plan.GetDelegatedAdminPlanId));
    end;

    [Scope('Personalization')]
    procedure GenerateHashForPermissionSet(PermissionSetId: Code[20]): Text[250]
    var
        Permission: Record Permission;
        EncryptionManagement: Codeunit "Encryption Management";
        InputText: Text;
        ObjectType: Integer;
    begin
        InputText += PermissionSetId;
        Permission.SetRange("Role ID",PermissionSetId);
        if Permission.FindSet then
          repeat
            ObjectType := Permission."Object Type";
            InputText += Format(ObjectType);
            InputText += Format(Permission."Object ID");
            if ObjectType = Permission."Object Type"::"Table Data" then begin
              InputText += GetCharRepresentationOfPermission(Permission."Read Permission");
              InputText += GetCharRepresentationOfPermission(Permission."Insert Permission");
              InputText += GetCharRepresentationOfPermission(Permission."Modify Permission");
              InputText += GetCharRepresentationOfPermission(Permission."Delete Permission");
            end else
              InputText += GetCharRepresentationOfPermission(Permission."Execute Permission");
            InputText += Format(Permission."Security Filter",0,9);
          until Permission.Next = 0;

        exit(CopyStr(EncryptionManagement.GenerateHash(InputText,2),1,250)); // 2 corresponds to SHA256
    end;

    [Scope('Personalization')]
    procedure UpdateHashForPermissionSet(PermissionSetId: Code[20])
    var
        PermissionSet: Record "Permission Set";
    begin
        PermissionSet.Get(PermissionSetId);
        PermissionSet.Hash := GenerateHashForPermissionSet(PermissionSetId);
        if PermissionSet.Hash = '' then
          Error(IncorrectCalculatedHashErr,PermissionSetId,PermissionSet.Hash);
        PermissionSet.Modify;
    end;

    local procedure GetCharRepresentationOfPermission(PermissionOption: Integer): Text[1]
    begin
        exit(StrSubstNo('%1',PermissionOption));
    end;

    [Scope('Personalization')]
    procedure IsFirstPermissionHigherThanSecond(First: Option;Second: Option): Boolean
    var
        Permission: Record Permission;
    begin
        case First of
          Permission."Read Permission"::" ":
            exit(false);
          Permission."Read Permission"::Indirect:
            exit(Second = Permission."Read Permission"::" ");
          Permission."Read Permission"::Yes:
            exit(Second in [Permission."Read Permission"::Indirect,Permission."Read Permission"::" "]);
        end;
    end;

    [Scope('Personalization')]
    procedure ResetUsersToIntelligentCloudUserGroup()
    var
        User: Record User;
        AccessControl: Record "Access Control";
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if not SoftwareAsAService then
          exit;

        if not IntelligentCloud.Get then
          exit;

        if IntelligentCloud.Enabled then begin
          User.SetFilter("License Type",'<>%1',User."License Type"::"External User");
          User.SetFilter("Windows Security ID",'=''''');

          if User.Count = 0 then
            exit;

          repeat
            if not IsSuper(User."User Security ID") and not IsNullGuid(User."User Security ID") then begin
              AccessControl.SetRange("User Security ID",User."User Security ID");
              if AccessControl.FindSet then
                repeat
                  RemoveExistingPermissionsAndAddIntelligentCloud(AccessControl."User Security ID",AccessControl."Company Name");
                until AccessControl.Next = 0;
            end;
          until User.Next = 0;
        end;
    end;

    [Scope('Personalization')]
    procedure IsIntelligentCloud(): Boolean
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if TestabilityIntelligentCloud then
          exit(true);

        if IntelligentCloud.Get then
          exit(IntelligentCloud.Enabled);
    end;

    [Scope('Personalization')]
    procedure GetIntelligentCloudTok(): Text
    begin
        exit(IntelligentCloudTok);
    end;

    local procedure RemoveExistingPermissionsAndAddIntelligentCloud(UserSecurityID: Guid;CompanyName: Text[30])
    var
        AccessControl: Record "Access Control";
        UserGroupMember: Record "User Group Member";
    begin
        // Remove User from all Permission Sets for the company
        AccessControl.SetRange("User Security ID",UserSecurityID);
        AccessControl.SetRange("Company Name",CompanyName);
        AccessControl.SetRange(Scope,AccessControl.Scope::System);
        AccessControl.SetFilter("Role ID",'<>%1',IntelligentCloudTok);
        AccessControl.DeleteAll(true);

        // Remove User from all User Groups for the company
        UserGroupMember.SetRange("User Security ID",UserSecurityID);
        UserGroupMember.SetRange("Company Name",CompanyName);
        UserGroupMember.SetFilter("User Group Code",'<>%1',IntelligentCloudTok);
        if not UserGroupMember.IsEmpty then begin
          UserGroupMember.DeleteAll(true);
          AddUserToUserGroup(UserSecurityID,IntelligentCloudTok,CompanyName)
        end else
          AddPermissionSetToUser(UserSecurityID,IntelligentCloudTok,CompanyName);
    end;

    [Scope('Internal')]
    procedure SetTestabilityIntelligentCloud(EnableIntelligentCloudForTest: Boolean)
    begin
        TestabilityIntelligentCloud := EnableIntelligentCloudForTest;
    end;

    local procedure AddPermissionSetToUser(UserSecurityID: Guid;RoleID: Code[20];Company: Text[30])
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID",UserSecurityID);
        AccessControl.SetRange("Role ID",RoleID);
        AccessControl.SetRange("Company Name",Company);

        if not AccessControl.IsEmpty then
          exit;

        AccessControl.Init;
        AccessControl."Company Name" := Company;
        AccessControl."User Security ID" := UserSecurityID;
        AccessControl."Role ID" := RoleID;
        AccessControl.Insert(true);
    end;
}

