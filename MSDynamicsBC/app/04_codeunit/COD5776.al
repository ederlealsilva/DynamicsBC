codeunit 5776 "Warehouse Document-Print"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure PrintPickHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        WhsePick: Report "Picking List";
    begin
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        WhsePick.SetTableView(WhseActivHeader);
        WhsePick.SetBreakbulkFilter(WhseActivHeader."Breakbulk Filter");
        WhsePick.RunModal;
    end;

    [Scope('Personalization')]
    procedure PrintPutAwayHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        WhsePutAway: Report "Put-away List";
    begin
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        WhsePutAway.SetTableView(WhseActivHeader);
        WhsePutAway.SetBreakbulkFilter(WhseActivHeader."Breakbulk Filter");
        WhsePutAway.RunModal;
    end;

    [Scope('Personalization')]
    procedure PrintMovementHeader(WhseActivHeader: Record "Warehouse Activity Header")
    var
        MovementList: Report "Movement List";
    begin
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        MovementList.SetTableView(WhseActivHeader);
        MovementList.SetBreakbulkFilter(WhseActivHeader."Breakbulk Filter");
        MovementList.RunModal;
    end;

    [Scope('Personalization')]
    procedure PrintInvtPickHeader(WhseActivHeader: Record "Warehouse Activity Header";HideDialog: Boolean)
    var
        WhsePick: Report "Picking List";
    begin
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        WhsePick.SetTableView(WhseActivHeader);
        WhsePick.SetInventory(true);
        WhsePick.SetBreakbulkFilter(false);
        WhsePick.UseRequestPage(not HideDialog);
        WhsePick.RunModal;
    end;

    [Scope('Personalization')]
    procedure PrintInvtPutAwayHeader(WhseActivHeader: Record "Warehouse Activity Header";HideDialog: Boolean)
    var
        WhsePutAway: Report "Put-away List";
    begin
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        WhsePutAway.SetTableView(WhseActivHeader);
        WhsePutAway.SetInventory(true);
        WhsePutAway.SetBreakbulkFilter(false);
        WhsePutAway.UseRequestPage(not HideDialog);
        WhsePutAway.RunModal;
    end;

    [Scope('Personalization')]
    procedure PrintInvtMovementHeader(WhseActivHeader: Record "Warehouse Activity Header";HideDialog: Boolean)
    var
        MovementList: Report "Movement List";
    begin
        WhseActivHeader.SetRange("No.",WhseActivHeader."No.");
        MovementList.SetTableView(WhseActivHeader);
        MovementList.SetInventory(true);
        MovementList.SetBreakbulkFilter(false);
        MovementList.UseRequestPage(not HideDialog);
        MovementList.RunModal;
    end;

    [Scope('Personalization')]
    procedure PrintRcptHeader(RcptHeader: Record "Warehouse Receipt Header")
    begin
        RcptHeader.SetRange("No.",RcptHeader."No.");
        REPORT.Run(REPORT::"Whse. - Receipt",true,false,RcptHeader);
    end;

    [Scope('Personalization')]
    procedure PrintPostedRcptHeader(PostedRcptHeader: Record "Posted Whse. Receipt Header")
    begin
        PostedRcptHeader.SetRange("No.",PostedRcptHeader."No.");
        REPORT.Run(REPORT::"Whse. - Posted Receipt",true,false,PostedRcptHeader);
    end;

    [Scope('Personalization')]
    procedure PrintShptHeader(ShptHeader: Record "Warehouse Shipment Header")
    begin
        ShptHeader.SetRange("No.",ShptHeader."No.");
        REPORT.Run(REPORT::"Whse. - Shipment",true,false,ShptHeader);
    end;

    [Scope('Personalization')]
    procedure PrintPostedShptHeader(PostedShptHeader: Record "Posted Whse. Shipment Header")
    begin
        PostedShptHeader.SetRange("No.",PostedShptHeader."No.");
        REPORT.Run(REPORT::"Whse. - Posted Shipment",true,false,PostedShptHeader);
    end;
}

