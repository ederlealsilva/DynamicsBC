page 99000753 "Shop Calendar Holidays"
{
    // version NAVW111.00

    Caption = 'Shop Calendar Holidays';
    DataCaptionFields = "Shop Calendar Code";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Shop Calendar Holiday";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Date;Date)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date to set up as a shop calendar holiday.';
                    Visible = false;
                }
                field("Starting Date-Time";"Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the starting time, which are combined in a format called "starting date-time".';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the shop calendar holiday.';
                    Visible = false;
                }
                field("Ending Date-Time";"Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the ending time, which are combined in a format called "ending date-time".';
                    Visible = false;
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of the shop calendar holiday.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description of the shop calendar holiday.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

