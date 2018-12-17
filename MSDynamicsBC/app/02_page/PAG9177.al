page 9177 "Allowed Companies"
{
    // version NAVW113.00

    Caption = 'Allowed Companies';
    Editable = false;
    PageType = List;
    SourceTable = Company;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(CompanyDisplayName;CompanyDisplayName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    StyleExpr = NameStyleExpr;
                    ToolTip = 'Specifies the display name that is defined for the company. If a display name is not defined, then the company name is used.';
                }
                field("Evaluation Company";"Evaluation Company")
                {
                    ApplicationArea = All;
                    Caption = 'Evaluation Company';
                    Editable = false;
                    ToolTip = 'Specifies that the company is for trial purposes only, and that a subscription has not been purchased.';
                }
                field(SetupStatus;SetupStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Setup Status';
                    OptionCaption = ' ,Completed,In Progress,Error';
                    ToolTip = 'Specifies the setup status of the company.';

                    trigger OnDrillDown()
                    var
                        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
                    begin
                        AssistedCompanySetupStatus.DrillDownSetupStatus(Name);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create New Company")
            {
                AccessByPermission = TableData Company=I;
                ApplicationArea = Basic,Suite;
                Caption = 'Create New Company';
                Image = Company;
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Get assistance with creating a new company.';
                Visible = SoftwareAsAService;

                trigger OnAction()
                begin
                    // Action invoked through event subscriber to avoid hard coupling to other objects,
                    // as this page is part of the Cloud Manager.
                    Initialize;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CompanyDisplayName := GetCompanyDisplayNameDefaulted(Rec);
    end;

    trigger OnAfterGetRecord()
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        CompanyDisplayName := GetCompanyDisplayNameDefaulted(Rec);
        SetupStatus := AssistedCompanySetupStatus.GetCompanySetupStatus(Name);
        if SetupStatus = SetupStatus::"In Progress" then
          NameStyleExpr := 'Subordinate'
        else
          NameStyleExpr := '';
    end;

    trigger OnInit()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        SoftwareAsAService := PermissionManager.SoftwareAsAService;
    end;

    var
        CompanyDisplayName: Text[250];
        SoftwareAsAService: Boolean;
        SetupStatus: Option " ",Completed,"In Progress",Error;
        NameStyleExpr: Text;

    [Scope('Personalization')]
    procedure Initialize()
    var
        AssistedCompanySetup: Codeunit "Assisted Company Setup";
    begin
        AssistedCompanySetup.GetAllowedCompaniesForCurrnetUser(Rec);
    end;

    [Scope('Personalization')]
    procedure GetCompanyDisplayNameDefaulted(Company: Record Company): Text[250]
    begin
        if Company."Display Name" <> '' then
          exit(Company."Display Name");
        exit(Company.Name)
    end;
}

