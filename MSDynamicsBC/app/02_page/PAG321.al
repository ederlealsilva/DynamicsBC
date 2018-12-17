page 321 "ECSL Report"
{
    // version NAVW113.00

    Caption = 'EC Sales List Report';
    DataCaptionExpression = '';
    Description = 'EC Sales List Report';
    LinksAllowed = false;
    PageType = Document;
    ShowFilter = false;
    SourceTable = "VAT Report Header";
    SourceTableView = WHERE("VAT Report Config. Code"=FILTER("EC Sales List"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Enabled = IsEditable;
                field("No.";"No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                          CurrPage.Update;
                    end;
                }
                field("VAT Report Version";"VAT Report Version")
                {
                    ApplicationArea = Basic,Suite;
                    Enabled = IsEditable;
                    NotBlank = true;
                    ToolTip = 'Specifies version of the report.';
                }
                field(Status;Status)
                {
                    ApplicationArea = Basic,Suite;
                    DrillDown = false;
                    Enabled = false;
                    ToolTip = 'Specifies whether the report is in progress, is completed, or contains errors.';

                    trigger OnValidate()
                    begin
                        InitPageControllers;
                    end;
                }
                group(Control3)
                {
                    ShowCaption = false;
                    field("Period Year";"Period Year")
                    {
                        ApplicationArea = Basic,Suite;
                        LookupPageID = "Date Lookup";
                        NotBlank = true;
                        ToolTip = 'Specifies the year of the reporting period.';

                        trigger OnValidate()
                        var
                            ECSLVATReportLine: Record "ECSL VAT Report Line";
                        begin
                            ECSLVATReportLine.ClearLines(Rec);
                        end;
                    }
                    field("Period Type";"Period Type")
                    {
                        ApplicationArea = Basic,Suite;
                        NotBlank = true;
                        OptionCaption = ',,Month,Quarter';
                        ToolTip = 'Specifies the length of the reporting period.';

                        trigger OnValidate()
                        var
                            ECSLVATReportLine: Record "ECSL VAT Report Line";
                        begin
                            ECSLVATReportLine.ClearLines(Rec);
                        end;
                    }
                    field("Period No.";"Period No.")
                    {
                        ApplicationArea = Basic,Suite;
                        NotBlank = true;
                        ToolTip = 'Specifies the specific reporting period to use.';

                        trigger OnValidate()
                        var
                            ECSLVATReportLine: Record "ECSL VAT Report Line";
                        begin
                            ECSLVATReportLine.ClearLines(Rec);
                        end;
                    }
                }
                field("Start Date";"Start Date")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the first date of the reporting period.';

                    trigger OnValidate()
                    begin
                        ClearPeriod;
                    end;
                }
                field("End Date";"End Date")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the last date of the reporting period.';

                    trigger OnValidate()
                    begin
                        ClearPeriod;
                    end;
                }
            }
            part(ECSLReportLines;"ECSL Report Subform")
            {
                ApplicationArea = Basic,Suite;
                SubPageLink = "Report No."=FIELD("No.");
            }
            part(ErrorMessagesPart;"Error Messages Part")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Messages';
                Visible = ErrorsExist;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(SuggestLines)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Suggest Lines';
                    Enabled = SuggestLinesControllerStatus;
                    Image = SuggestLines;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Create EC Sales List entries based on information gathered from sales-related documents.';

                    trigger OnAction()
                    var
                        ECSLVATReportLine: Record "ECSL VAT Report Line";
                    begin
                        VATReportMediator.GetLines(Rec);
                        UpdateSubForm;
                        CheckForErrors;
                        ECSLVATReportLine.SetRange("Report No.","No.");
                        if ECSLVATReportLine.Count = 0 then
                          Message(NoLineGeneratedMsg);
                    end;
                }
                action(Release)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Release';
                    Enabled = ReleaseControllerStatus;
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Verify that the report includes all of the required information, and prepare it for submission.';

                    trigger OnAction()
                    begin
                        VATReportMediator.Release(Rec);
                        if not CheckForErrors then
                          Message(ReportReleasedMsg);
                    end;
                }
                action(Submit)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Submit';
                    Enabled = SubmitControllerStatus;
                    Image = SendElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Submits the EC Sales List report to the tax authority''s reporting service.';

                    trigger OnAction()
                    begin
                        VATReportMediator.Export(Rec);
                        if not CheckForErrors then
                          Message(ReportSubmittedMsg);
                    end;
                }
                action("Mark as Submitted")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Mark as Su&bmitted';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Indicate that the tax authority has approved and returned the report.';
                    Visible = false;

                    trigger OnAction()
                    begin
                        VATReportMediator.Submit(Rec);
                        Message(MarkAsSubmittedMsg);
                    end;
                }
                action("Cancel Submission")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Cancel Submission';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Cancels previously submitted report.';
                    Visible = false;

                    trigger OnAction()
                    begin
                        VATReportMediator.Reopen(Rec);
                        Message(CancelReportSentMsg);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Reopen';
                    Enabled = ReopenControllerStatus;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'Open the report again to make changes.';

                    trigger OnAction()
                    begin
                        VATReportMediator.Reopen(Rec);
                    end;
                }
            }
            action(Print)
            {
                ApplicationArea = Basic,Suite;
                Caption = '&Print';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Prepare the report for printing by specifying the information it will include.';
                Visible = false;

                trigger OnAction()
                begin
                    VATReportMediator.Print(Rec);
                end;
            }
            action("Report Setup")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Report Setup';
                Image = Setup;
                RunObject = Page "VAT Report Setup";
                ToolTip = 'Specifies the setup that will be used for the VAT reports submission.';
                Visible = false;
            }
            action("Log Entries")
            {
                ApplicationArea = Basic,Suite;
                Caption = '&Log Entries';
                Image = Log;
                ToolTip = 'View the log entries for this report.';

                trigger OnAction()
                var
                    VATReportLog: Page "VAT Report Log";
                begin
                    VATReportLog.SetReport(Rec);
                    VATReportLog.RunModal;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        InitPageControllers;
        CheckForErrors;
    end;

    trigger OnClosePage()
    begin
        DeleteErrors;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        InitPageControllers;
    end;

    trigger OnOpenPage()
    begin
        if "No." <> '' then
          InitPageControllers;
        IsEditable := Status = Status::Open;
        DeleteErrors;
    end;

    var
        DummyCompanyInformation: Record "Company Information";
        VATReportMediator: Codeunit "VAT Report Mediator";
        ReportSubmittedMsg: Label 'The report has been successfully submitted.';
        CancelReportSentMsg: Label 'The cancel request has been sent.';
        MarkAsSubmittedMsg: Label 'The report has been marked as submitted.';
        SuggestLinesControllerStatus: Boolean;
        SubmitControllerStatus: Boolean;
        ReleaseControllerStatus: Boolean;
        ReopenControllerStatus: Boolean;
        IsEditable: Boolean;
        ReportReleasedMsg: Label 'The report has been marked as released.';
        NoLineGeneratedMsg: Label 'Ther are no VAT entries in the specified period.';
        ErrorsExist: Boolean;

    local procedure UpdateSubForm()
    begin
        CurrPage.ECSLReportLines.PAGE.UpdateForm;
    end;

    local procedure ClearPeriod()
    begin
        "Period No." := 0;
        "Period Type" := "Period Type"::" ";
    end;

    local procedure InitPageControllers()
    begin
        SuggestLinesControllerStatus := Status = Status::Open;
        ReleaseControllerStatus := Status = Status::Open;
        SubmitControllerStatus := Status = Status::Released;
        ReopenControllerStatus := Status = Status::Released;
    end;

    local procedure CheckForErrors(): Boolean
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        ErrorMessage.SetRange("Context Record ID",DummyCompanyInformation.RecordId);
        ErrorMessage.CopyToTemp(TempErrorMessage);
        ErrorMessage.SetRange("Context Record ID",RecordId);
        ErrorMessage.CopyToTemp(TempErrorMessage);

        CurrPage.ErrorMessagesPart.PAGE.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesPart.PAGE.Update;
        CurrPage.ErrorMessagesPart.PAGE.DisableActions;
        ErrorsExist := not TempErrorMessage.IsEmpty;

        exit(ErrorsExist);
    end;

    local procedure DeleteErrors()
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID",DummyCompanyInformation.RecordId);
        if ErrorMessage.FindFirst then
          ErrorMessage.DeleteAll(true);
        Commit;
    end;
}

