codeunit 8810 "Customer Layout - Statement"
{
    // version NAVW19.00

    // // Wrapper codeunit to call 8800 - allows menus and objects to invoke a CU directly to get the per-customer
    // // layout support for statements.


    trigger OnRun()
    var
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        RecRef.Open(DATABASE::Customer);
        CustomLayoutReporting.SetOutputFileBaseName(StatementFileNameTxt);
        CustomLayoutReporting.ProcessReportForData(ReportSelections.Usage::"C.Statement",RecRef,Customer.FieldName("No."),
          DATABASE::Customer,Customer.FieldName("No."),true);
    end;

    var
        ReportSelections: Record "Report Selections";
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
        StatementFileNameTxt: Label 'Statement', Comment='Shortened form of ''Customer Statement''';
}

