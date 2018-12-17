page 99000921 "Demand Forecast Names"
{
    // version NAVW113.00

    ApplicationArea = Planning;
    Caption = 'Demand Forecasts';
    PageType = List;
    SourceTable = "Production Forecast Name";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the name of the production forecast.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies a brief description of the production forecast.';
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
        area(processing)
        {
            action("Edit Production Forecast")
            {
                ApplicationArea = Planning;
                Caption = 'Edit Production Forecast';
                Image = EditForecast;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Return';
                ToolTip = 'Open the related production forecast.';

                trigger OnAction()
                var
                    DemandForecast: Page "Demand Forecast";
                begin
                    DemandForecast.SetProductionForecastName(Name);
                    DemandForecast.Run;
                end;
            }
        }
    }
}

