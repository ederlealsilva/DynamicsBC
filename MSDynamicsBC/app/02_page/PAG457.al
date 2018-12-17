page 457 "No. Series Lines"
{
    // version NAVW113.00

    AutoSplitKey = true;
    Caption = 'No. Series Lines';
    DataCaptionFields = "Series Code";
    DelayedInsert = true;
    PageType = List;
    SourceTable = "No. Series Line";
    SourceTableView = SORTING("Series Code","Starting Date","Starting No.");

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Series Code";"Series Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the code for the number series to which this line applies.';
                    Visible = false;
                }
                field("Starting Date";"Starting Date")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the date from which you would like this line to apply.';
                }
                field("Starting No.";"Starting No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the first number in the series.';
                }
                field("Ending No.";"Ending No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the last number in the series.';
                }
                field("Last Date Used";"Last Date Used")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the date when a number was most recently assigned from the number series.';
                }
                field("Last No. Used";"Last No. Used")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the last number that was used from the number series.';
                }
                field("Warning No.";"Warning No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies when you want to receive a warning that the number series is running out.';
                }
                field("Increment-by No.";"Increment-by No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the size of the interval by which you would like to space the numbers in the number series.';
                }
                field(Open;Open)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether the number series line is open. It is open until the last number in the series has been used.';
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if NoSeriesLine.Get("Series Code","Line No.") then begin
          NoSeriesLine.SetRange("Series Code","Series Code");
          if NoSeriesLine.FindLast then;
          "Line No." := NoSeriesLine."Line No." + 10000;
        end;
        exit(true);
    end;

    var
        NoSeriesLine: Record "No. Series Line";
}

