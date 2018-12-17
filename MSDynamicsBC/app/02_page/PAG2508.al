page 2508 "Extension Deployment Status"
{
    // version NAVW113.00

    Caption = 'Extension Deployment Status';
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NAV App Tenant Operation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;AppName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the App.';
                }
                field(Publisher;Publisher)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Publisher';
                    ToolTip = 'Specifies the name of the App Publisher.';
                }
                field("Operation Type";OperationType)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Operation Type';
                    ToolTip = 'Specifies the deployment type.';
                }
                field(Status;Status)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Status';
                    ToolTip = 'Specifies the deployment status.';
                }
                field(Schedule;Schedule)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Schedule';
                    ToolTip = 'Specifies the deployment Schedule.';
                    Width = 12;
                }
                field(AppVersion;Version)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'App Version';
                    ToolTip = 'Specifies the version of the App.';
                    Width = 6;
                }
                field("Started On";"Started On")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Started Date';
                    ToolTip = 'Specifies the deployment start date.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(View)
            {
                ApplicationArea = Basic,Suite;
                Scope = Repeater;
                ShortCutKey = 'Return';
                Visible = false;

                trigger OnAction()
                begin
                    RunDetails;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
    begin
        if "Operation Type" = 0 then
          OperationType := OperationType::Install
        else
          OperationType := OperationType::Upload;

        AppName := NavExtensionOperationMgmt.GetDeployOperationAppName("Operation ID");
        if AppName = '' then
          AppName := Description;

        Publisher := NavExtensionOperationMgmt.GetDeployOperationAppPublisher("Operation ID");
        Version := NavExtensionOperationMgmt.GetDeployOperationAppVersion("Operation ID");
        Schedule := NavExtensionOperationMgmt.GetDeployOperationSchedule("Operation ID");
        if Status = Status::InProgress then
          NavExtensionOperationMgmt.RefreshStatus("Operation ID");
    end;

    trigger OnOpenPage()
    begin
        SetCurrentKey("Started On");
        Ascending(false);
    end;

    var
        Version: Text;
        Schedule: Text;
        Publisher: Text;
        AppName: Text;
        OperationType: Option Upload,Install;

    local procedure RunDetails()
    var
        ExtnDeploymentStatusDetail: Page "Extn. Deployment Status Detail";
    begin
        ExtnDeploymentStatusDetail.SetRecord(Rec);
        ExtnDeploymentStatusDetail.Run;
        if ExtnDeploymentStatusDetail.Editable = false then
          CurrPage.Update;
        CurrPage.Update;
    end;
}

