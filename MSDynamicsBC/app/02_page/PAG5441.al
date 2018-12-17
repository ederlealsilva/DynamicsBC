page 5441 "Automation Extensions Entity"
{
    // version NAVW113.00

    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    Caption = 'extensions', Locked=true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'extension';
    EntitySetName = 'extensions';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = "Package ID";
    PageType = API;
    SourceTable = "NAV App";
    SourceTableView = SORTING(Name)
                      WHERE(Name=FILTER(<>'_Exclude_*'),
                            "Package Type"=FILTER(=0|2));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(packageId;"Package ID")
                {
                    ApplicationArea = All;
                    Caption = 'packageId', Locked=true;
                }
                field(id;ID)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked=true;
                }
                field(displayName;Name)
                {
                    ApplicationArea = All;
                    Caption = 'displayName', Locked=true;
                }
                field(publisher;Publisher)
                {
                    ApplicationArea = All;
                    Caption = 'publisher', Locked=true;
                }
                field(versionMajor;"Version Major")
                {
                    ApplicationArea = All;
                    Caption = 'versionMajor', Locked=true;
                }
                field(versionMinor;"Version Minor")
                {
                    ApplicationArea = All;
                    Caption = 'versionMinor', Locked=true;
                }
                field(scope;Scope)
                {
                    ApplicationArea = All;
                    Caption = 'scope', Locked=true;
                    Editable = false;
                }
                field(isInstalled;Isinstalled)
                {
                    ApplicationArea = All;
                    Caption = 'isInstalled', Locked=true;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
    begin
        Isinstalled := NavExtensionInstallationMgmt.IsInstalled("Package ID");
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        Isinstalled: Boolean;
        IsNotInstalledErr: Label 'The extension %1 is not installed.', Comment='%1=name of app';
        IsInstalledErr: Label 'The extension %1 is already installed.', Comment='%1=name of app';

    [ServiceEnabled]
    [Scope('Personalization')]
    procedure install(var ActionContext: DotNet WebServiceActionContext)
    var
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        ODataActionManagement: Codeunit "OData Action Management";
    begin
        if NavExtensionInstallationMgmt.IsInstalled("Package ID") then
          Error(StrSubstNo(IsInstalledErr,Name));

        NavExtensionInstallationMgmt.InstallNavExtension("Package ID",GlobalLanguage);

        ODataActionManagement.AddKey(FieldNo("Package ID"),"Package ID");
        ODataActionManagement.SetDeleteResponse(ActionContext);
    end;

    [ServiceEnabled]
    [Scope('Personalization')]
    procedure uninstall(var ActionContext: DotNet WebServiceActionContext)
    var
        NavExtensionInstallationMgmt: Codeunit NavExtensionInstallationMgmt;
        ODataActionManagement: Codeunit "OData Action Management";
    begin
        if not NavExtensionInstallationMgmt.IsInstalled("Package ID") then
          Error(StrSubstNo(IsNotInstalledErr,Name));

        NavExtensionInstallationMgmt.UninstallNavExtension("Package ID");

        ODataActionManagement.AddKey(FieldNo("Package ID"),"Package ID");
        ODataActionManagement.SetUpdatedPageResponse(ActionContext,PAGE::"Automation Extensions Entity");
    end;
}

