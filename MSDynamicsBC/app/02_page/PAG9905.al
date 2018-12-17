page 9905 "Data Encryption Management"
{
    // version NAVW113.00

    AccessByPermission = System "Tools, Restore"=X;
    ApplicationArea = Advanced;
    Caption = 'Data Encryption Management';
    Editable = false;
    PageType = Card;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(EncryptionEnabledState;EncryptionEnabledState)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Encryption Enabled';
                Editable = false;
                ToolTip = 'Specifies if an encryption key exists and is enabled on the Business Central Server.';
            }
            field(EncryptionKeyExistsState;EncryptionKeyExistsState)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Encryption Key Exists';
                ToolTip = 'Specifies if an encryption key exists on the Business Central Server.';
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Enable Encryption")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Enable Encryption';
                Enabled = EnableEncryptionActionEnabled;
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Generate an encryption key on the server to enable encryption.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    EncryptionManagement.EnableEncryption;
                    RefreshEncryptionStatus;
                end;
            }
            action("Import Encryption Key")
            {
                AccessByPermission = System "Tools, Restore"=X;
                ApplicationArea = Basic,Suite;
                Caption = 'Import Encryption Key';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import the encryption key to a server instance from an encryption key file that was exported from another server instance or saved as a copy when the encryption was enabled.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    EncryptionManagement.ImportKey;
                    RefreshEncryptionStatus;
                end;
            }
            action("Change Encryption Key")
            {
                AccessByPermission = System "Tools, Restore"=X;
                ApplicationArea = Basic,Suite;
                Caption = 'Change Encryption Key';
                Enabled = ChangeKeyActionEnabled;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Change to a different encryption key file.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    EncryptionManagement.ChangeKey;
                    RefreshEncryptionStatus;
                end;
            }
            action("Export Encryption Key")
            {
                AccessByPermission = System "Tools, Backup"=X;
                ApplicationArea = Basic,Suite;
                Caption = 'Export Encryption Key';
                Enabled = ExportKeyActionEnabled;
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the encryption key to make a copy of the key or so that it can be imported on another server instance.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    EncryptionManagement.ExportKey;
                end;
            }
            action("Disable Encryption")
            {
                AccessByPermission = System "Tools, Restore"=X;
                ApplicationArea = Basic,Suite;
                Caption = 'Disable Encryption';
                Enabled = DisableEncryptionActionEnabled;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Decrypt encrypted data.';
                Visible = NOT IsSaaS;

                trigger OnAction()
                begin
                    if EncryptionKeyExistsState then
                      EncryptionManagement.DisableEncryption(false)
                    else
                      EncryptionManagement.DeleteEncryptedDataInAllCompanies;
                    RefreshEncryptionStatus;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RefreshEncryptionStatus;
    end;

    trigger OnInit()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        IsSaaS := PermissionManager.SoftwareAsAService;
    end;

    var
        EncryptionManagement: Codeunit "Encryption Management";
        EncryptionEnabledState: Boolean;
        EncryptionKeyExistsState: Boolean;
        EnableEncryptionActionEnabled: Boolean;
        ChangeKeyActionEnabled: Boolean;
        ExportKeyActionEnabled: Boolean;
        DisableEncryptionActionEnabled: Boolean;
        IsSaaS: Boolean;

    local procedure RefreshEncryptionStatus()
    begin
        EncryptionEnabledState := EncryptionEnabled;
        EncryptionKeyExistsState := EncryptionKeyExists;

        EnableEncryptionActionEnabled := not EncryptionEnabledState;
        ExportKeyActionEnabled := EncryptionKeyExistsState;
        DisableEncryptionActionEnabled := EncryptionEnabledState;
        ChangeKeyActionEnabled := EncryptionKeyExistsState;
    end;
}

