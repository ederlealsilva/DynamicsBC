codeunit 5466 "Graph Mgt - In. Services Setup"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        BusinessSetupNameTxt: Label 'Integration Services Setup';
        BusinessSetupDescriptionTxt: Label 'Define the data that you want to expose in integration services';
        BusinessSetupKeywordsTxt: Label 'Integration,Service,Expose,Setup';

    [EventSubscriber(ObjectType::Table, 1875, 'OnRegisterBusinessSetup', '', false, false)]
    local procedure HandleAPISetup(var TempBusinessSetup: Record "Business Setup" temporary)
    begin
        TempBusinessSetup.InsertBusinessSetup(
          TempBusinessSetup,BusinessSetupNameTxt,BusinessSetupDescriptionTxt,BusinessSetupKeywordsTxt,
          TempBusinessSetup.Area::Service,
          PAGE::"Integration Services Setup",'Default');
    end;
}

