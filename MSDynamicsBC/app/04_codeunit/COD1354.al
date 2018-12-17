codeunit 1354 "Generate Activity Telemetry"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        OnActivityTelemetry;
    end;

    var
        AlCompanyActivityCategoryTxt: Label 'AL Company Activity', Comment='Locked';
        GLEntryTelemetryMsg: Label 'G/L Entries: %1', Comment='Locked';
        OpenDocsTelemetryMsg: Label 'Open documents (sales+purchase): %1', Comment='Locked';
        PostedDocsTelemetryMsg: Label 'Posted documents (sales+purchase): %1', Comment='Locked';

    [EventSubscriber(ObjectType::Codeunit, 1354, 'OnActivityTelemetry', '', true, true)]
    local procedure SendTelemetryOnActivityTelemetry()
    var
        GLEntry: Record "G/L Entry";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        GLEntriesMsg: Text;
        OpenInvoicesMsg: Text;
        PostedInvoicesMsg: Text;
    begin
        GLEntriesMsg := StrSubstNo(GLEntryTelemetryMsg,GLEntry.Count);
        SendTraceTag('000018W',AlCompanyActivityCategoryTxt,VERBOSITY::Normal,GLEntriesMsg,DATACLASSIFICATION::SystemMetadata);

        OpenInvoicesMsg := StrSubstNo(OpenDocsTelemetryMsg,SalesHeader.Count + PurchaseHeader.Count);
        SendTraceTag('000018X',AlCompanyActivityCategoryTxt,VERBOSITY::Normal,OpenInvoicesMsg,DATACLASSIFICATION::SystemMetadata);

        PostedInvoicesMsg := StrSubstNo(PostedDocsTelemetryMsg,SalesInvoiceHeader.Count + PurchInvHeader.Count);
        SendTraceTag('000018Y',AlCompanyActivityCategoryTxt,VERBOSITY::Normal,PostedInvoicesMsg,DATACLASSIFICATION::SystemMetadata);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActivityTelemetry()
    begin
    end;
}

