codeunit 5435 "Automation - API Management"
{
    // version NAVW113.00

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 50, 'OnSuppressApprovalForTrial', '', false, false)]
    local procedure OnSuppressApprovalForTrial(var GetSuppressApprovalForTrial: Boolean)
    begin
        GetSuppressApprovalForTrial := true;
    end;
}

