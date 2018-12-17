codeunit 741 "VAT Report Release/Reopen"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure Release(var VATReportHeader: Record "VAT Report Header")
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        ErrorMessage: Record "Error Message";
    begin
        VATReportHeader.CheckIfCanBeReleased(VATReportHeader);
        VATReportsConfiguration.SetRange("VAT Report Type",VATReportHeader."VAT Report Config. Code");
        if VATReportsConfiguration.FindFirst and (VATReportsConfiguration."Validate Codeunit ID" <> 0) then
          CODEUNIT.Run(VATReportsConfiguration."Validate Codeunit ID",VATReportHeader)
        else
          CODEUNIT.Run(CODEUNIT::"VAT Report Validate",VATReportHeader);

        ErrorMessage.SetContext(VATReportHeader.RecordId);
        if ErrorMessage.HasErrors(false) then
          exit;

        VATReportHeader.Status := VATReportHeader.Status::Released;
        VATReportHeader.Modify;
    end;

    [Scope('Personalization')]
    procedure Reopen(var VATReportHeader: Record "VAT Report Header")
    begin
        VATReportHeader.CheckIfCanBeReopened(VATReportHeader);

        VATReportHeader.Status := VATReportHeader.Status::Open;
        VATReportHeader.Modify;
    end;

    [Scope('Personalization')]
    procedure Submit(var VATReportHeader: Record "VAT Report Header")
    begin
        VATReportHeader.CheckIfCanBeSubmitted;

        VATReportHeader.Status := VATReportHeader.Status::Submitted;
        VATReportHeader.Modify;
    end;
}

