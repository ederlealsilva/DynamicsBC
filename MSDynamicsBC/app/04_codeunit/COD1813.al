codeunit 1813 "Assisted Setup Management"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        AssistedSetup: Record "Assisted Setup";

    [EventSubscriber(ObjectType::Table, 1808, 'OnRegisterAssistedSetup', '', false, false)]
    local procedure HandleOnRegisterAggregatedSetup(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup" temporary)
    begin
        AssistedSetup.Initialize;

        AssistedSetup.SetRange(Visible,true);
        AssistedSetup.SetFilter("Assisted Setup Page ID",'<>0');

        if AssistedSetup.FindSet then
          repeat
            Clear(TempAggregatedAssistedSetup);
            TempAggregatedAssistedSetup.TransferFields(AssistedSetup,true);
            TempAggregatedAssistedSetup."External Assisted Setup" := false;
            TempAggregatedAssistedSetup."Record ID" := AssistedSetup.RecordId;
            TempAggregatedAssistedSetup.Insert;
          until AssistedSetup.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 1808, 'OnUpdateAssistedSetupStatus', '', false, false)]
    local procedure HandleOnUpdateAssistedSetupStatus(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup" temporary)
    var
        AssistedSetupRecordID: RecordID;
    begin
        AssistedSetup.Reset;
        AssistedSetup.SetRange(Visible,true);
        AssistedSetup.SetFilter("Assisted Setup Page ID",'<>0');

        if AssistedSetup.FindSet then
          repeat
            AssistedSetupRecordID := TempAggregatedAssistedSetup."Record ID";
            if AssistedSetupRecordID.TableNo = DATABASE::"Assisted Setup" then
              if TempAggregatedAssistedSetup.Get(AssistedSetup."Page ID") then begin
                TempAggregatedAssistedSetup.Status := AssistedSetup.Status;
                TempAggregatedAssistedSetup.Modify;
              end;
          until AssistedSetup.Next = 0;
    end;
}

