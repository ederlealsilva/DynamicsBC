page 1316 "Accountant Portal User Tasks"
{
    // version NAVW111.00

    Caption = 'Accountant Portal User Tasks';
    PageType = List;
    SourceTable = "User Task";
    SourceTableView = SORTING(ID)
                      WHERE("Percent Complete"=FILTER(<100));

    layout
    {
        area(content)
        {
            group(Task)
            {
                field(ID;ID)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'ID', Locked=true;
                    ToolTip = 'Specifies the ID that applies.';
                }
                field(Title;Title)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Subject', Locked=true;
                    ToolTip = 'Specifies the title of the task.';
                }
                field("Due DateTime";"Due DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Due Date', Locked=true;
                    ToolTip = 'Specifies when the task must be completed.';
                }
                field("Percent Complete";"Percent Complete")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = '% Complete', Locked=true;
                    ToolTip = 'Specifies the progress of the task.';
                }
                field(Priority;Priority)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Priority', Locked=true;
                    ToolTip = 'Specifies the priority of the task.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Description', Locked=true;
                    ToolTip = 'Specifies a descriptions of the task.';
                }
                field(Created_By_Name;CreatedByName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Created_By_Name', Locked=true;
                    ToolTip = 'Specifies the string value name of the user who created the task.';
                }
                field("Created DateTime";"Created DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Created Date', Locked=true;
                    ToolTip = 'Specifies when the task was created.';
                }
                field("Start DateTime";"Start DateTime")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Start Date', Locked=true;
                    ToolTip = 'Specifies when the task must start.';
                }
                field("Assigned To";"Assigned To")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Assigned To', Locked=true;
                    ToolTip = 'Specifies who the task is assigned to.';
                }
                field(Link;Link)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Link', Locked=true;
                    ToolTip = 'Specifies the string value of web link to this user task.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields("Created By User Name");
        CreatedByName := "Created By User Name";
        Link := GetUrl(CLIENTTYPE::Web,CompanyName,OBJECTTYPE::Page,1171,Rec) + '&Mode=Edit';
    end;

    trigger OnOpenPage()
    begin
        Reset;

        SetRange("Assigned To",UserSecurityId);
        SetFilter("Percent Complete",'< 100');
    end;

    var
        CreatedByName: Code[50];
        Link: Text;
}

