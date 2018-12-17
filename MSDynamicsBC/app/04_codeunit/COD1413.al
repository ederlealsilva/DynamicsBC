codeunit 1413 "Read Data Exch. from Stream"
{
    // version NAVW113.00

    TableNo = "Data Exch.";

    trigger OnRun()
    var
        TempBlob: Record TempBlob temporary;
        EventHandled: Boolean;
    begin
        // Fire the get stream event
        OnGetDataExchFileContentEvent(Rec,TempBlob,EventHandled);

        if EventHandled then begin
          "File Name" := 'Data Stream';
          "File Content" := TempBlob.Blob;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDataExchFileContentEvent(DataExchIdentifier: Record "Data Exch.";var TempBlobResponse: Record TempBlob temporary;var Handled: Boolean)
    begin
        // Event that will return the data stream from the identified subscriber
    end;
}

