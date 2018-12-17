codeunit 1352 "Create Telemetry Cal. Events"
{
    // version NAVW111.00

    TableNo = "CodeUnit Metadata";

    trigger OnRun()
    var
        TelemetryManagement: Codeunit "Telemetry Management";
        CalendarEventMangement: Codeunit "Calendar Event Mangement";
    begin
        if not TelemetryManagement.DoesTelemetryCalendarEventExist(Today + 1,Name,ID) then
          CalendarEventMangement.CreateCalendarEventForCodeunit(Today + 1,Name,ID);

        if not TelemetryManagement.DoesTelemetryCalendarEventExist(Today + 2,Name,ID) then
          CalendarEventMangement.CreateCalendarEventForCodeunit(Today + 2,Name,ID);
    end;
}

