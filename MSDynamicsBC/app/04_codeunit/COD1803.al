codeunit 1803 "Encrypted Key/Value Management"
{
    // version NAVW113.00

    Permissions = TableData "Encrypted Key/Value"=rimd;

    trigger OnRun()
    begin
    end;

    var
        EncryptedKeyValueTxt: Label 'Encrypted Key/Value';
        NamespaceKeyTemplateTxt: Label '%1_%2', Locked=true;
        ServiceKeyExistsErr: Label 'Configuration key %1 already exists.', Comment='%1 = key name that has been provided (e.g. ServiceName_Username)';
        ServiceKeyNotExistsErr: Label 'Configuration key %1 does not exist.', Comment='%1 = key name that has been provided (e.g. ServiceName_Username)';
        ServiceKeyTooLongErr: Label 'The specified key name is too long.';
        InvalidKeyErr: Label 'The specified key name is not valid.';
        InsertEventTxt: Label 'Insert key.';
        UpdateEventTxt: Label 'Update key.';
        DeleteEventTxt: Label 'Delete key.';
        CleanupEventTxt: Label 'Cleanup.';
        SuccessTxt: Label 'Success.';
        RequestInitTxt: Label 'Request initiated.';
        NoPermissionTxt: Label 'The user does not have permission.';
        NoEncryptionTxt: Label 'Encryption has not been enabled.';
        DevBetaEnabledTxt: Label 'Developer Mode Enabled.';
        DevBetaDisabledTxt: Label 'Developer Mode Disabled.';

    [Scope('Personalization')]
    procedure Insert(Namespace: Code[50];"Key": Code[50];Value: Text): Boolean
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
        FullKey: Code[50];
    begin
        FullKey := GenerateFullKey(Namespace,Key);

        // If key is DEV_BETA we should set development mode and exit
        if ProcessSettingDevelopmentMode(FullKey,Value) then
          exit(true);

        if not HasCapability(InsertEventTxt) then
          exit(false);

        if EncryptedKeyValue.Get(FullKey) then begin
          LogActivity(InsertEventTxt,StrSubstNo(ServiceKeyExistsErr,FullKey),false);
          exit(false);
        end;

        EncryptedKeyValue.Init;
        EncryptedKeyValue.Validate(Key,FullKey);
        EncryptedKeyValue.InsertValue(Value);
        EncryptedKeyValue.Insert(true);

        LogActivity(InsertEventTxt,FullKey,true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure Update(Namespace: Code[50];"Key": Code[50];Value: Text): Boolean
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
        FullKey: Code[50];
    begin
        if not HasCapability(UpdateEventTxt) then
          exit(false);

        FullKey := GenerateFullKey(Namespace,Key);

        if not EncryptedKeyValue.Get(FullKey) then begin
          LogActivity(UpdateEventTxt,StrSubstNo(ServiceKeyNotExistsErr,FullKey),false);
          exit(false);
        end;

        EncryptedKeyValue.InsertValue(Value);
        EncryptedKeyValue.Modify(true);

        LogActivity(UpdateEventTxt,FullKey,true);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure Remove(Namespace: Code[50];"Key": Code[50]): Boolean
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
        FullKey: Code[50];
    begin
        if not HasCapability(DeleteEventTxt) then
          exit(false);

        FullKey := GenerateFullKey(Namespace,Key);

        if EncryptedKeyValue.Get(FullKey) then begin
          EncryptedKeyValue.Delete(true);
          LogActivity(DeleteEventTxt,FullKey,true);
        end else
          LogActivity(DeleteEventTxt,StrSubstNo(ServiceKeyNotExistsErr,FullKey),true);

        exit(true);
    end;

    [Scope('Personalization')]
    procedure Cleanup(): Boolean
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
        ErrorOccured: Boolean;
    begin
        if not HasCapability(CleanupEventTxt) then
          exit(false);

        LogActivity(CleanupEventTxt,RequestInitTxt,true);
        Commit;

        ErrorOccured := false;
        OnCleanUpEvent(ErrorOccured);

        if not ErrorOccured then
          EncryptedKeyValue.DeleteAll;

        LogActivity(CleanupEventTxt,SuccessTxt,not ErrorOccured);
        exit(not ErrorOccured);
    end;

    local procedure ProcessSettingDevelopmentMode("Key": Code[50];Value: Text): Boolean
    var
        CompanyInformation: Record "Company Information";
        EnableDeveloperMode: Boolean;
    begin
        if Key <> CompanyInformation.GetDevBetaModeTxt then
          exit(false);

        if not Evaluate(EnableDeveloperMode,Value,9) then
          exit(false);

        CompanyInformation.Get;

        if (not EnableDeveloperMode) and (CompanyInformation."Custom System Indicator Text" <> CompanyInformation.GetDevBetaModeTxt) then
          exit(false);

        if EnableDeveloperMode then begin
          CompanyInformation.Validate("Custom System Indicator Text",CompanyInformation.GetDevBetaModeTxt);
          LogActivity(InsertEventTxt,DevBetaEnabledTxt,true);
        end else begin
          Clear(CompanyInformation."Custom System Indicator Text");
          LogActivity(InsertEventTxt,DevBetaDisabledTxt,true);
        end;

        CompanyInformation.Modify(true);
        exit(true);
    end;

    local procedure GenerateFullKey(Namespace: Code[50];"Key": Code[50]): Code[50]
    var
        Result: Code[50];
    begin
        if (Namespace = '') or (Key = '') then
          Error(InvalidKeyErr);

        if StrLen(StrSubstNo(NamespaceKeyTemplateTxt,Namespace,Key)) > MaxStrLen(Result) then
          Error(ServiceKeyTooLongErr);

        Result := CopyStr(StrSubstNo(NamespaceKeyTemplateTxt,Namespace,Key),1,MaxStrLen(Result));
        exit(Result);
    end;

    local procedure LogActivity(ActivityDescription: Text;ActivityMessage: Text;Success: Boolean)
    var
        ActivityLog: Record "Activity Log";
        EncryptedKeyValue: Record "Encrypted Key/Value";
        Status: Integer;
    begin
        if Success then
          Status := ActivityLog.Status::Success
        else
          Status := ActivityLog.Status::Failed;

        ActivityLog.LogActivity(EncryptedKeyValue.RecordId,Status,EncryptedKeyValueTxt,
          ActivityDescription,ActivityMessage);
    end;

    local procedure HasCapability(EventType: Text): Boolean
    var
        EncryptedKeyValue: Record "Encrypted Key/Value";
        EncryptionManagement: Codeunit "Encryption Management";
        HasPermission: Boolean;
        HasEncryption: Boolean;
    begin
        HasPermission := EncryptedKeyValue.WritePermission and EncryptedKeyValue.ReadPermission;
        HasEncryption := EncryptionManagement.IsEncryptionEnabled and EncryptionManagement.IsEncryptionPossible;

        if not HasPermission then begin
          LogActivity(EventType,NoPermissionTxt,false);
          exit(false);
        end;

        if not HasEncryption then begin
          LogActivity(EventType,NoEncryptionTxt,false);
          exit(false);
        end;

        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCleanUpEvent(var ErrorOccured: Boolean)
    begin
        // The subscriber of this event should perform any clean up that is dependant on the Encrypted Key/Value table.
        // If an error occurs it should set ErrorOccured to true.
    end;
}

