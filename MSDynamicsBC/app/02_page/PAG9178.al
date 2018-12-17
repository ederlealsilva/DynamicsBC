page 9178 "Available Role Centers"
{
    // version NAVW111.00

    Caption = 'Available Role Centers';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = true;
    SourceTable = "All Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the Role Center.';
                }
                field("App Name";"App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the extension that provided the Role Center.';
                }
                field(Scope;Scope)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scope, such as system.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(FindFirstAllowedRec(Which));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(FindNextAllowedRec(Steps));
    end;

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        RoleCenterSubtype := RoleCenterTxt;
        ConfPersonalizationMgt.HideSandboxProfiles(Rec);
    end;

    var
        RoleCenterTxt: Label 'RoleCenter', Locked=true;
        RoleCenterSubtype: Text;

    [Scope('Personalization')]
    procedure FindFirstAllowedRec(Which: Text[1024]): Boolean
    begin
        if Find(Which) then
          if not RoleCenterExist("Role Center ID") then
            exit(false);
        exit(true);
    end;

    [Scope('Personalization')]
    procedure FindNextAllowedRec(Steps: Integer): Integer
    var
        ProfileBrowser: Record "All Profile";
        RealSteps: Integer;
        NextSteps: Integer;
    begin
        RealSteps := 0;
        if Steps <> 0 then begin
          ProfileBrowser := Rec;
          repeat
            NextSteps := Next(Steps / Abs(Steps));
            if RoleCenterExist("Role Center ID") then begin
              RealSteps := RealSteps + NextSteps;
              ProfileBrowser := Rec;
            end;
          until (NextSteps = 0) or (RealSteps = Steps);
          Rec := ProfileBrowser;
          if not Find then ;
        end;
        exit(RealSteps);
    end;

    local procedure RoleCenterExist(PageID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if (PageID = PAGE::"O365 Sales Activities RC") or (PageID = PAGE::"O365 Invoicing RC") then
          exit(false);
        AllObjWithCaption.SetRange("Object Type",AllObjWithCaption."Object Type"::Page);
        AllObjWithCaption.SetRange("Object Subtype",RoleCenterSubtype);
        AllObjWithCaption.SetRange("Object ID",PageID);
        exit(not AllObjWithCaption.IsEmpty);
    end;
}

