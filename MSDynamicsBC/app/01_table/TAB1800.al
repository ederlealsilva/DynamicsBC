table 1800 "Data Migrator Registration"
{
    // version NAVW113.00

    Caption = 'Data Migrator Registration';
    DrillDownPageID = "Data Migrators";
    LookupPageID = "Data Migrators";
    ReplicateData = false;

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
        }
        field(2;Description;Text[250])
        {
            Caption = 'Description';
            NotBlank = true;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure RegisterDataMigrator(DataMigratorNo: Integer;DataMigratorDescription: Text[250]): Boolean
    begin
        Init;
        "No." := DataMigratorNo;
        Description := DataMigratorDescription;
        exit(Insert);
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnRegisterDataMigrator()
    begin
        // Event which makes all data migrators register themselves in this table.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnHasSettings(var HasSettings: Boolean)
    begin
        // Event which tells whether the data migrator has a settings page.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnOpenSettings(var Handled: Boolean)
    begin
        // Event which opens the settings page for the data migrator.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnValidateSettings()
    begin
        // Event which validates the settings.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnGetInstructions(var Instructions: Text;var Handled: Boolean)
    begin
        // Event which makes all registered data migrators publish their instructions.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnHasTemplate(var HasTemplate: Boolean)
    begin
        // Event which tells whether the data migrator has a template available for download.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnDownloadTemplate(var Handled: Boolean)
    begin
        // Event which invokes the download of the template.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnDataImport(var Handled: Boolean)
    begin
        // Event which makes all registered data migrators import data.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnSelectDataToApply(var DataMigrationEntity: Record "Data Migration Entity";var Handled: Boolean)
    begin
        // Event which makes all registered data migrators populate the Data Migration Entities table, which allows the user to choose which imported data should be applied.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnHasAdvancedApply(var HasAdvancedApply: Boolean)
    begin
        // Event which tells whether the data migrator has an advanced apply page.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnOpenAdvancedApply(var DataMigrationEntity: Record "Data Migration Entity";var Handled: Boolean)
    begin
        // Event which opens the advanced apply page for the data migrator.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnApplySelectedData(var DataMigrationEntity: Record "Data Migration Entity";var Handled: Boolean)
    begin
        // Event which makes all registered data migrators apply the data, which is selected in the Data Migration Entities table.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnPostingGroupSetup(var PostingSetup: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnGLPostingSetup(ListOfAccounts: array [11] of Code[20])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnCustomerVendorPostingSetup(ListOfAccounts: array [4] of Code[20])
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnHasErrors(var HasErrors: Boolean)
    begin
        // Event which tells whether the data migrator had import errors
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnShowErrors(var Handled: Boolean)
    begin
        // Event which opens the error handling page for the data migrator.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnShowDuplicateContactsText(var ShowDuplicateContactText: Boolean)
    begin
        // Event which shows or hides message on the last page of the wizard to run Duplicate Contact Tool or not.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnShowPostingOptions(var ShowPostingOptions: Boolean)
    begin
        // Event which shows or hides posting options (post yes/no and date) on the entity seleciton page-
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnShowBalance(var ShowBalance: Boolean)
    begin
        // Event which shows or hides balance columns in the entity selection page.
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnShowThatsItMessage(var Message: Text)
    begin
        // Event which shows specific data migrator text at the last page
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnEnableTogglingDataMigrationOverviewPage(var EnableTogglingOverviewPage: Boolean)
    begin
        // Event which determines if the option to launch the overview page will be shown to the user at the end.
    end;

    [IntegrationEvent(TRUE, false)]
    [Scope('Personalization')]
    procedure OnHideSelected(var HideSelectedCheckBoxes: Boolean)
    begin
        // Event which shows or hides selected checkboxes in the entity selection page.
    end;
}

