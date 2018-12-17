codeunit 9901 "Data Upgrade In Progress"
{
    // version NAVW113.00

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 9900, 'OnIsUpgradeInProgress', '', false, false)]
    [Normal]
    local procedure OnIsUpgradeInProgressHandler(var UpgradeIsInProgress: Boolean)
    begin
        UpgradeIsInProgress := true;
    end;
}

