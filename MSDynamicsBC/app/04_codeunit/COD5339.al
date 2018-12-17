codeunit 5339 "Integration Synch. Job Runner"
{
    // version NAVW111.00

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
    begin
        IntegrationTableMapping.Get("Record ID to Process");
        RunIntegrationTableSynch(IntegrationTableMapping,GetLastLogEntryNo);
    end;

    [Scope('Personalization')]
    procedure RunIntegrationTableSynch(IntegrationTableMapping: Record "Integration Table Mapping";JobLogEntryNo: Integer)
    begin
        IntegrationTableMapping.SetJobLogEntryNo(JobLogEntryNo);
        CODEUNIT.Run(IntegrationTableMapping."Synch. Codeunit ID",IntegrationTableMapping);
    end;
}

