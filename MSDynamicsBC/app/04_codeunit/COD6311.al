codeunit 6311 "PBI Start Uploads Task"
{
    // version NAVW113.00

    // // For triggering background sessions for asynchronous deployment of default Power BI reports.
    // // Called by UploadDefaultReportsInBackground method of codeunit 6301.


    trigger OnRun()
    begin
        PowerBIServiceMgt.UploadAllDefaultReports;
    end;

    var
        PowerBIServiceMgt: Codeunit "Power BI Service Mgt.";
}

