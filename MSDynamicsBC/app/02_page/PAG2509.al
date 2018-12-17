page 2509 "Extn. Deployment Status Detail"
{
    // version NAVW113.00

    Caption = 'Extn. Deployment Status Detail';
    DataCaptionExpression = Description;
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "NAV App Tenant Operation";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control16)
                {
                    ShowCaption = false;
                    field("App Name";Name)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'App Name';
                        ToolTip = 'Specifies the name of the App.';
                        Visible = NOT HideName;
                    }
                    field("App Publisher";Publisher)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'App Publisher';
                        ToolTip = 'Specifies the name of the App Publisher.';
                        Visible = NOT HideName;
                    }
                    field("App Version";Version)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'App Version';
                        ToolTip = 'Specifies the version of the App.';
                        Visible = NOT HideName;
                    }
                    field(Schedule;Schedule)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Schedule';
                        ToolTip = 'Specifies the deployment Schedule.';
                        Visible = NOT HideName;
                    }
                    field("Started On";"Started On")
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Started Date';
                        ToolTip = 'Specifies the Deployment start date.';
                    }
                }
                group(Control17)
                {
                    ShowCaption = false;
                    field(Status;Status)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Status';
                        ToolTip = 'Specifies the deployment status.';
                    }
                    field(OpDetails;OpDetails)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'Summary';
                        MultiLine = true;
                        ToolTip = 'Specifies the deployment summary details.';
                    }
                    group(Control18)
                    {
                        ShowCaption = false;
                        Visible = (ShowDetails) AND (NOT ShowDetailedMessage);
                        field(Details;DetailedMessageLbl)
                        {
                            ApplicationArea = Basic,Suite;
                            Caption = 'Details';
                            ShowCaption = false;
                            ToolTip = 'Specifies deploy operation details.';
                            Visible = ShowDetails;

                            trigger OnDrillDown()
                            var
                                NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
                            begin
                                DetailedMessageText := NavExtensionOperationMgmt.GetDeploymentDetailedStatusMessage("Operation ID");
                                DetailedMessageText := DetailedMessageText + ' - Job Id : ' + NavExtensionOperationMgmt.GetDeployOperationJobId("Operation ID");
                                ShowDetailedMessage := true;
                            end;
                        }
                    }
                }
            }
            group("Error Details")
            {
                Caption = 'Error Details';
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Rows;
                Visible = ShowDetailedMessage;
                field("Detailed Message box";DetailedMessageText)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Detailed Message box';
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies detailed message box.';
                    Visible = ShowDetailedMessage;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Refresh)
            {
                ApplicationArea = Basic,Suite;
                Enabled = NOT IsFinalStatus;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
                    DetailsStream: InStream;
                begin
                    NavExtensionOperationMgmt.RefreshStatus("Operation ID");
                    NavAppTenantOperationTable.SetRange("Operation ID","Operation ID");
                    if not NavAppTenantOperationTable.FindFirst then
                      CurrPage.Close;

                    Status := NavAppTenantOperationTable.Status;
                    NavAppTenantOperationTable.CalcFields(Details);
                    NavAppTenantOperationTable.Details.CreateInStream(DetailsStream,TEXTENCODING::UTF8);
                    OpDetails.Read(DetailsStream);
                    Modify;
                    CurrPage.Update;
                    ShowDetails := Status <> Status::InProgress;
                end;
            }
            action("Download Details")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Download Details';
                Enabled = ShowDetails;
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Download the operation status details to a file.';

                trigger OnAction()
                var
                    TempBlob: Record TempBlob;
                    NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
                    FileManagement: Codeunit "File Management";
                    NavOutStream: OutStream;
                    FileName: Text;
                begin
                    TempBlob.Blob.CreateOutStream(NavOutStream);
                    NavExtensionOperationMgmt.GetDeploymentDetailedStatusMessageAsStream("Operation ID",NavOutStream);
                    FileName := 'Deploy_Detailed_Message.txt';
                    FileManagement.BLOBExport(TempBlob,FileName,true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
    begin
        NavAppTenantOperationTable.SetRange("Operation ID","Operation ID");
        if not NavAppTenantOperationTable.FindFirst then
          CurrPage.Close;

        IsFinalStatus := NavAppTenantOperationTable.Status in [Status::Completed,Status::Failed];

        if not IsFinalStatus then
          NavExtensionOperationMgmt.RefreshStatus("Operation ID");

        SetOperationRecord;

        ShowDetails := not (Status in [Status::InProgress,Status::Completed]);
        Name := NavExtensionOperationMgmt.GetDeployOperationAppName("Operation ID");
        Publisher := NavExtensionOperationMgmt.GetDeployOperationAppPublisher("Operation ID");
        Version := NavExtensionOperationMgmt.GetDeployOperationAppVersion("Operation ID");
        Schedule := NavExtensionOperationMgmt.GetDeployOperationSchedule("Operation ID");

        if Name = '' then
          HideName := true;
    end;

    var
        NavAppTenantOperationTable: Record "NAV App Tenant Operation";
        OpDetails: BigText;
        DetailedMessageLbl: Label 'View Details';
        ShowDetails: Boolean;
        DetailedMessageText: Text;
        ShowDetailedMessage: Boolean;
        Schedule: Text;
        Version: Text;
        Name: Text;
        Publisher: Text;
        HideName: Boolean;
        IsFinalStatus: Boolean;

    local procedure SetOperationRecord()
    var
        DetailsStream: InStream;
    begin
        "Operation ID" := NavAppTenantOperationTable."Operation ID";
        Description := NavAppTenantOperationTable.Description;
        "Started On" := NavAppTenantOperationTable."Started On";
        Status := NavAppTenantOperationTable.Status;

        NavAppTenantOperationTable.CalcFields(Details);
        NavAppTenantOperationTable.Details.CreateInStream(DetailsStream,TEXTENCODING::UTF8);
        OpDetails.Read(DetailsStream);
        Insert;
    end;
}

