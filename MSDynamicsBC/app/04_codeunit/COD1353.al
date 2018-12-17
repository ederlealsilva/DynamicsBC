codeunit 1353 "Generate Master Data Telemetry"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        OnMasterDataTelemetry;
    end;

    var
        AlCompanyMasterdataCategoryTxt: Label 'AL Company Masterdata', Comment='Locked';
        MasterdataTelemetryMessageTxt: Label 'CompanyGUID: %1, IsEvaluationCompany: %2, IsDemoCompany: %3, Customers: %4, Vendors: %5, Items: %6, G/L Accounts: %7, Contacts: %8', Comment='Locked';

    [EventSubscriber(ObjectType::Codeunit, 1353, 'OnMasterDataTelemetry', '', true, true)]
    local procedure SendTelemetryOnMasterDataTelemetry()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Item: Record Item;
        GLAccount: Record "G/L Account";
        Contact: Record Contact;
        Company: Record Company;
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        TelemetryMsg: Text;
    begin
        if Company.Get(CompanyName) then;
        TelemetryMsg := StrSubstNo(MasterdataTelemetryMessageTxt,
            Company.Id,Company."Evaluation Company",CompanyInformationMgt.IsDemoCompany,
            Customer.Count,Vendor.Count,Item.Count,GLAccount.Count,Contact.Count);
        SendTraceTag('000018V',AlCompanyMasterdataCategoryTxt,VERBOSITY::Normal,TelemetryMsg,DATACLASSIFICATION::SystemMetadata);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnMasterDataTelemetry()
    begin
    end;
}

