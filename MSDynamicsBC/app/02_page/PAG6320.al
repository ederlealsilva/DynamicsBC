page 6320 "Upload Power BI Report"
{
    // version NAVW113.00

    // // Test page for manually importing PBIX blobs into database.
    // // TODO: Remove before check-in.

    Caption = 'Upload Power BI Report';
    Editable = true;
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Control10)
            {
                ShowCaption = false;
                field(FileName;FileName)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Caption = 'File';
                    Editable = false;
                    ShowMandatory = true;
                    ToolTip = 'Specifies File Name';

                    trigger OnAssistEdit()
                    var
                        TempFileName: Text;
                    begin
                        // Event handler for the ellipsis button that opens the file selection dialog.
                        TempFileName := FileManagement.BLOBImportWithFilter(TempBlob,FileDialogTxt,'',FileFilterTxt,ExtFilterTxt);

                        if TempFileName = '' then
                          // User clicked Cancel in the file selection dialog.
                          exit;

                        FileName := TempFileName;

                        if ReportName = '' then begin
                          ReportName := CopyStr(FileManagement.GetFileNameWithoutExtension(FileName),1,200);
                          IsFileLoaded := true;
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        if not FileManagement.ClientFileExists(FileName) then
                          Error(FileExistErr,FileName);
                    end;
                }
            }
            field(ReportName;ReportName)
            {
                ApplicationArea = All;
                Caption = 'Report Name';
                Editable = IsFileLoaded;
                ShowMandatory = true;
                ToolTip = 'Specifies Report Name';
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(OK)
            {
                ApplicationArea = Basic,Suite;
                InFooterBar = true;
                Visible = true;

                trigger OnAction()
                begin
                    ClosedOk := true;
                    CurrPage.Close;
                end;
            }
            action("Upload Report")
            {
                ApplicationArea = Basic,Suite;
                InFooterBar = true;
                Visible = true;

                trigger OnAction()
                var
                    PowerBICustomerReports: Record "Power BI Customer Reports";
                begin
                    UploadedReportCount := PowerBICustomerReports.Count;

                    if FileName = '' then
                      Error(FileNameErr);

                    if ReportName = '' then
                      Error(ReportNameErr);

                    PowerBICustomerReports.Reset;
                    PowerBICustomerReports.SetFilter(Id,ReportID);
                    if not PowerBICustomerReports.IsEmpty then
                      Error(BlobIdErr);

                    if UploadedReportCount < MaxReportLimit then begin
                      PowerBICustomerReports.Init;
                      PowerBICustomerReports.Id := ReportID;
                      PowerBICustomerReports.Name := ReportName;
                      PowerBICustomerReports."Blob File" := TempBlob.Blob;
                      PowerBICustomerReports.Version := Version;
                      PowerBICustomerReports.Insert
                    end else
                      Message(TableLimitMsg);

                    FileName := '';
                    ReportName := '';

                    ReportID := CreateGuid;
                    CurrPage.Update;
                end;
            }
            action(Cancel)
            {
                ApplicationArea = Basic,Suite;
                InFooterBar = true;
                Visible = true;

                trigger OnAction()
                begin
                    ClosedOk := false;
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not PermissionManager.IsSuper(UserSecurityId) then
          Error(PermissionErr);

        if not PowerBIServiceMgt.IsUserReadyForPowerBI then
          Error(NotReadyErr);

        ReportID := CreateGuid;
        Version := 1;

        MaxReportLimit := 20;
    end;

    var
        ReportNameErr: Label 'You must enter a report name.';
        FileNameErr: Label 'You must enter a file name.';
        NotReadyErr: Label 'whoops.';
        FileExistErr: Label 'The file %1 does not exist.', Comment='asdf';
        BlobIdErr: Label 'A blob with this ID already exists.';
        TempBlob: Record TempBlob;
        PowerBIServiceMgt: Codeunit "Power BI Service Mgt.";
        PermissionManager: Codeunit "Permission Manager";
        FileManagement: Codeunit "File Management";
        FileDialogTxt: Label 'Select a PBIX report file.';
        FileFilterTxt: Label 'Power BI Files(*.pbix)|*.pbix';
        ExtFilterTxt: Label 'pbix';
        ReportID: Guid;
        Version: Integer;
        FileName: Text;
        ReportName: Text[200];
        ClosedOk: Boolean;
        PermissionErr: Label 'User does not have permissions to operate this page.';
        IsFileLoaded: Boolean;
        MaxReportLimit: Integer;
        UploadedReportCount: Integer;
        TableLimitMsg: Label 'The Customer Report table is full. Remove a report and try again.';

    procedure GetClosedOk(): Boolean
    begin
        // Returns the ClosedOk variable which tells the parent window if the user hit OK to actually upload a report,
        // rather than canceling.
        exit(ClosedOk);
    end;
}

