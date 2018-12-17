codeunit 1882 "Sandbox Deploymt. Cleanup"
{
    // version NAVW113.00


    trigger OnRun()
    begin
        RaiseEventForEveryCompany;
    end;

    var
        nullGUID: Guid;

    [EventSubscriber(ObjectType::Codeunit, 1882, 'OnClearConfiguration', '', false, false)]
    local procedure ClearConfiguration(CompanyToBlock: Text)
    var
        BankDataConvServiceSetup: Record "Bank Data Conv. Service Setup";
        OCRServiceSetup: Record "OCR Service Setup";
        DocExchServiceSetup: Record "Doc. Exch. Service Setup";
        NetPromoterScore: Record "Net Promoter Score";
        FlowServiceConfiguration: Record "Flow Service Configuration";
        CurrExchRateUpdateSetup: Record "Curr. Exch. Rate Update Setup";
        VATRegNoSrvConfig: Record "VAT Reg. No. Srv Config";
        GraphMailSetup: Record "Graph Mail Setup";
        SMTPMailSetup: Record "SMTP Mail Setup";
        MSPayPalStandardAccount: Record "MS- PayPal Standard Account";
        CRMConnectionSetup: Record "CRM Connection Setup";
        ServiceConnection: Record "Service Connection";
        MarketingSetup: Record "Marketing Setup";
        ExchangeSync: Record "Exchange Sync";
    begin
        if CompanyToBlock <> '' then begin
          BankDataConvServiceSetup.ChangeCompany(CompanyToBlock);
          BankDataConvServiceSetup.ModifyAll("Password Key",nullGUID);

          OCRServiceSetup.ChangeCompany(CompanyToBlock);
          OCRServiceSetup.ModifyAll("Password Key",nullGUID);

          DocExchServiceSetup.ChangeCompany(CompanyToBlock);
          DocExchServiceSetup.ModifyAll(Enabled,false);

          CurrExchRateUpdateSetup.ChangeCompany(CompanyToBlock);
          CurrExchRateUpdateSetup.ModifyAll(Enabled,false);

          VATRegNoSrvConfig.ChangeCompany(CompanyToBlock);
          VATRegNoSrvConfig.ModifyAll(Enabled,false);

          GraphMailSetup.ChangeCompany(CompanyToBlock);
          GraphMailSetup.ModifyAll(Enabled,false);

          SMTPMailSetup.ChangeCompany(CompanyToBlock);
          SMTPMailSetup.ModifyAll("SMTP Server",'');

          MSPayPalStandardAccount.ChangeCompany(CompanyToBlock);
          MSPayPalStandardAccount.ModifyAll(Enabled,false);

          CRMConnectionSetup.ChangeCompany(CompanyToBlock);
          CRMConnectionSetup.ModifyAll("Is Enabled",false);

          ServiceConnection.ChangeCompany(CompanyToBlock);
          ServiceConnection.ModifyAll(Status,ServiceConnection.Status::Disabled);

          MarketingSetup.ChangeCompany(CompanyToBlock);
          MarketingSetup.ModifyAll("Exchange Service URL",'');

          ExchangeSync.ChangeCompany(CompanyToBlock);
          ExchangeSync.ModifyAll(Enabled,false);
        end else begin
          NetPromoterScore.ModifyAll("Send Request",false);
          FlowServiceConfiguration.ModifyAll("Flow Service",FlowServiceConfiguration."Flow Service"::"Testing Service (TIP 1)");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnClearConfiguration(CompanyToBlock: Text)
    begin
    end;

    local procedure RaiseEventForEveryCompany()
    var
        Company: Record Company;
    begin
        if Company.FindSet then
          repeat
            OnClearConfiguration(Company.Name);
          until Company.Next = 0;
        OnClearConfiguration('');
    end;
}

