codeunit 6305 "Set Power BI User Config"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";

    procedure SetUserConfig(var PowerBIUserConfiguration: Record "Power BI User Configuration";PageID: Text): Boolean
    begin
        // load existing UserConfig entry to get PowerBI FactBox visibility
        // entry by itself is created on the FactBox page
        PowerBIUserConfiguration.Reset;
        PowerBIUserConfiguration.SetFilter("Page ID",PageID);
        PowerBIUserConfiguration.SetFilter("User Security ID",UserSecurityId);
        PowerBIUserConfiguration.SetFilter("Profile ID",ConfPersonalizationMgt.GetCurrentProfileIDNoError);
        if not PowerBIUserConfiguration.IsEmpty then begin
          PowerBIUserConfiguration.FindFirst;
          exit(PowerBIUserConfiguration."Report Visibility");
        end;

        // if entry has not been created yet, set PowerBI FactBox visibility to defalut TRUE value
        exit(true);
    end;

    procedure CreateOrReadUserConfigEntry(var PowerBIUserConfiguration: Record "Power BI User Configuration";var LastOpenedReportID: Guid;Context: Text[50])
    begin
        // create a new Power BI User Configuration table entry or read one if it exist
        PowerBIUserConfiguration.Reset;
        PowerBIUserConfiguration.SetFilter("Page ID",Context);
        PowerBIUserConfiguration.SetFilter("User Security ID",UserSecurityId);
        PowerBIUserConfiguration.SetFilter("Profile ID",ConfPersonalizationMgt.GetCurrentProfileIDNoError);
        if PowerBIUserConfiguration.IsEmpty then begin
          PowerBIUserConfiguration."Page ID" := Context;
          PowerBIUserConfiguration."User Security ID" := UserSecurityId;
          PowerBIUserConfiguration."Profile ID" := ConfPersonalizationMgt.GetCurrentProfileIDNoError;
          PowerBIUserConfiguration."Report Visibility" := true;
          // SelectedReportId field is set to an empty GUID by default
          Clear(LastOpenedReportID);
          PowerBIUserConfiguration.Insert(true);
          Commit;
        end else begin
          PowerBIUserConfiguration.FindFirst;
          LastOpenedReportID := PowerBIUserConfiguration."Selected Report ID";
        end;
    end;
}

