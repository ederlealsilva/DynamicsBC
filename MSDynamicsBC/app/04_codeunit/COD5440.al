codeunit 5440 "Business Profile Sync. Runner"
{
    // version NAVW111.00


    trigger OnRun()
    var
        GraphSyncRunner: Codeunit "Graph Sync. Runner";
    begin
        GraphSyncRunner.RunFullSyncForEntity(DATABASE::"Company Information");
    end;
}

