codeunit 5445 "Graph Delta Sync"
{
    // version NAVW111.00


    trigger OnRun()
    var
        GraphSyncRunner: Codeunit "Graph Sync. Runner";
    begin
        GraphSyncRunner.RunDeltaSync
    end;
}

