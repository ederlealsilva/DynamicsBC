page 2115 "Report Viewer"
{
    // version NAVW113.00

    Caption = 'Report Viewer';

    layout
    {
        area(content)
        {
            usercontrol(PdfViewer;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite,Invoicing;
            }
        }
    }

    actions
    {
    }

    var
        DocumentPath: Text[250];
        NoDocErr: Label 'No document has been specified.';

    procedure SetDocument(RecordVariant: Variant;ReportType: Integer;CustNo: Code[20])
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.GetHtmlReport(DocumentPath,ReportType,RecordVariant,CustNo);
    end;
}

