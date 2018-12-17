codeunit 99000812 PlanningWkshManagement
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        LastReqLine: Record "Requisition Line";

    [Scope('Personalization')]
    procedure SetName(CurrentWkshBatchName: Code[10];var ReqLine: Record "Requisition Line")
    begin
        ReqLine.FilterGroup(2);
        ReqLine.SetRange("Journal Batch Name",CurrentWkshBatchName);
        ReqLine.FilterGroup(0);
        if ReqLine.Find('-') then;
    end;

    [Scope('Personalization')]
    procedure GetDescriptionAndRcptName(var ReqLine: Record "Requisition Line";var ItemDescription: Text[50];var RoutingDescription: Text[50])
    var
        Item: Record Item;
        RtngHeader: Record "Routing Header";
    begin
        if ReqLine."No." = '' then
          ItemDescription := ''
        else
          if ReqLine."No." <> LastReqLine."No." then begin
            if Item.Get(ReqLine."No.") then
              ItemDescription := Item.Description
            else
              ItemDescription := '';
          end;

        if ReqLine."Routing No." = '' then
          RoutingDescription := ''
        else
          if ReqLine."Routing No." <> LastReqLine."Routing No." then begin
            if RtngHeader.Get(ReqLine."Routing No.") then
              RoutingDescription := RtngHeader.Description
            else
              RoutingDescription := '';
          end;

        LastReqLine := ReqLine;
    end;
}

