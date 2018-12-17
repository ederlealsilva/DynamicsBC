codeunit 1011 "Job Jnl.-Check Line"
{
    // version NAVW113.00

    TableNo = "Job Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var
        Text000: Label 'cannot be a closing date.';
        Text001: Label 'is not within your range of allowed posting dates.';
        Text002: Label 'The combination of dimensions used in %1 %2, %3, %4 is blocked. %5';
        Text003: Label 'A dimension used in %1 %2, %3, %4 has caused an error. %5';
        Location: Record Location;
        DimMgt: Codeunit DimensionManagement;
        TimeSheetMgt: Codeunit "Time Sheet Management";
        Text004: Label 'You must post more usage of %1 %2 in %3 %4 before you can post job journal %5 %6 = %7.', Comment='%1=Item;%2=JobJnlline."No.";%3=Job;%4=JobJnlline."Job No.";%5=JobJnlline."Journal Batch Name";%6="Line No";%7=JobJnlline."Line No."';

    [Scope('Personalization')]
    procedure RunCheck(var JobJnlLine: Record "Job Journal Line")
    var
        Job: Record Job;
        UserSetupManagement: Codeunit "User Setup Management";
        TableID: array [10] of Integer;
        No: array [10] of Code[20];
    begin
        OnBeforeRunCheck(JobJnlLine);

        with JobJnlLine do begin
          if EmptyLine then
            exit;
          TestField("Job No.");
          TestField("Job Task No.");
          TestField("No.");
          TestField("Posting Date");
          TestField(Quantity);

          Job.Get("Job No.");
          Job.TestField(Status,Job.Status::Open);

          if NormalDate("Posting Date") <> "Posting Date" then
            FieldError("Posting Date",Text000);

          if ("Document Date" <> 0D) and ("Document Date" <> NormalDate("Document Date")) then
            FieldError("Document Date",Text000);

          if not UserSetupManagement.IsPostingDateValid("Posting Date") then
            FieldError("Posting Date",Text001);

          if "Time Sheet No." <> '' then
            TimeSheetMgt.CheckJobJnlLine(JobJnlLine);

          if not DimMgt.CheckDimIDComb("Dimension Set ID") then
            Error(
              Text002,
              TableCaption,"Journal Template Name","Journal Batch Name","Line No.",
              DimMgt.GetDimCombErr);

          TableID[1] := DATABASE::Job;
          No[1] := "Job No.";
          TableID[2] := DimMgt.TypeToTableID2(Type);
          No[2] := "No.";
          TableID[3] := DATABASE::"Resource Group";
          No[3] := "Resource Group No.";
          if not DimMgt.CheckDimValuePosting(TableID,No,"Dimension Set ID") then begin
            if "Line No." <> 0 then
              Error(
                Text003,
                TableCaption,"Journal Template Name","Journal Batch Name","Line No.",
                DimMgt.GetDimValuePostingErr);
            Error(DimMgt.GetDimValuePostingErr);
          end;

          if Type = Type::Item then begin
            if ("Quantity (Base)" < 0) and ("Entry Type" = "Entry Type"::Usage) then
              CheckItemQuantityJobJnl(JobJnlLine);
            GetLocation("Location Code");
            if Location."Directed Put-away and Pick" then
              TestField("Bin Code",'')
            else
              if Location."Bin Mandatory" then
                TestField("Bin Code");
          end;
          if "Line Type" in ["Line Type"::Billable,"Line Type"::"Both Budget and Billable"] then
            TestField(Chargeable,true);
        end;

        OnAfterRunCheck(JobJnlLine);
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
          Clear(Location)
        else
          if Location.Code <> LocationCode then
            Location.Get(LocationCode);
    end;

    local procedure CheckItemQuantityJobJnl(var JobJnlline: Record "Job Journal Line")
    var
        Item: Record Item;
        Job: Record Job;
    begin
        if JobJnlline.IsNonInventoriableItem then
          exit;

        Job.Get(JobJnlline."Job No.");
        if (Job.GetQuantityAvailable(JobJnlline."No.",JobJnlline."Location Code",JobJnlline."Variant Code",0,2) +
            JobJnlline."Quantity (Base)") < 0
        then
          Error(
            Text004,Item.TableCaption,JobJnlline."No.",Job.TableCaption,
            JobJnlline."Job No.",JobJnlline."Journal Batch Name",
            JobJnlline.FieldCaption("Line No."),JobJnlline."Line No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var JobJnlLine: Record "Job Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunCheck(var JobJnlLine: Record "Job Journal Line")
    begin
    end;
}

