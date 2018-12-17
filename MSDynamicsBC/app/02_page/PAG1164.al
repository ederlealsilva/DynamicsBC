page 1164 "User Task List Part"
{
    // version NAVW111.00

    Caption = 'User Task List Part';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    SourceTable = "User Task";

    layout
    {
        area(content)
        {
            repeater(Control12)
            {
                ShowCaption = false;
                field(Title;Title)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    var
                        Company: Record Company;
                        HyperLinkUrl: Text[500];
                    begin
                        Company.Get(CompanyName);
                        if Company."Evaluation Company" then
                          HyperLinkUrl := GetUrl(CLIENTTYPE::Web,CompanyName,OBJECTTYPE::Page,1171,Rec) + '&profile=BUSINESS%20MANAGER' + '&mode=Edit'
                        else
                          HyperLinkUrl := GetUrl(CLIENTTYPE::Web,CompanyName,OBJECTTYPE::Page,1171,Rec) + '&mode=Edit';
                        HyperLink(HyperLinkUrl);
                    end;
                }
                field("Due DateTime";"Due DateTime")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                }
                field(Priority;Priority)
                {
                    ApplicationArea = All;
                }
                field("Percent Complete";"Percent Complete")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                }
                field("Assigned To User Name";"Assigned To User Name")
                {
                    ApplicationArea = All;
                }
                field("Created DateTime";"Created DateTime")
                {
                    ApplicationArea = All;
                }
                field("Completed DateTime";"Completed DateTime")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Start DateTime";"Start DateTime")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Created By User Name";"Created By User Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Completed By User Name";"Completed By User Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        StyleTxt := SetStyle;
    end;

    trigger OnOpenPage()
    begin
        SetFilter("Assigned To User Name",UserId);
        SetFilter("Percent Complete",'<>100');
    end;

    var
        StyleTxt: Text;

    procedure SetFilterForPendingTasks()
    begin
        // Sets filter to show all pending tasks assigned to logged in user
        Reset;
        SetFilter("Assigned To User Name",UserId);
        SetFilter("Percent Complete",'<>100');
        CurrPage.Update(false);
    end;

    procedure SetFilterForTasksDueToday()
    begin
        // Sets filter to show all pending tasks assigned to logged in user due today
        Reset;
        SetFilter("Assigned To User Name",UserId);
        SetFilter("Percent Complete",'<>100');
        SetFilter("Due DateTime",'<=%1',CurrentDateTime);
        CurrPage.Update(false);
    end;

    procedure SetFilterForTasksDueThisWeek()
    begin
        // Sets filter to show all pending tasks assigned to logged in user due today
        Reset;
        SetFilter("Assigned To User Name",UserId);
        SetFilter("Percent Complete",'<>100');
        SetFilter("Due DateTime",'<=%1',CreateDateTime(CalcDate('<CW>'),0T));
        CurrPage.Update(false);
    end;
}

