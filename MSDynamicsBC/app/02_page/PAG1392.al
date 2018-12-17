page 1392 "Help And Chart Wrapper"
{
    // version NAVW113.00

    Caption = 'Business Assistance';
    DeleteAllowed = false;
    PageType = CardPart;
    SourceTable = "Assisted Setup";
    SourceTableView = SORTING(Order,Visible)
                      WHERE(Visible=CONST(true),
                            Featured=CONST(true));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'How To:';
                Visible = NOT ShowChart;
                field("Item Type";"Item Type")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    ToolTip = 'Specifies the type of resource.';
                    Visible = false;
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    ToolTip = 'Specifies the name of the resource.';
                }
                field(Icon;Icon)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    ToolTip = 'Specifies the icon for the button that opens the resource.';
                }
                field(Status;Status)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    ToolTip = 'Specifies the status of the resource, such as Completed.';
                    Visible = IsSaaS;
                }
            }
            field("Status Text";StatusText)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Status Text';
                Editable = false;
                ShowCaption = false;
                Style = StrongAccent;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the status of the resource, such as Completed.';
                Visible = ShowChart;
            }
            usercontrol(BusinessChart;"Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Visible = ShowChart;

                trigger DataPointClicked(point: DotNet BusinessChartDataPoint)
                begin
                    BusinessChartBuffer.SetDrillDownIndexes(point);
                    ChartManagement.DataPointClicked(BusinessChartBuffer,SelectedChartDefinition);
                end;

                trigger DataPointDoubleClicked(point: DotNet BusinessChartDataPoint)
                begin
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Chart")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Select Chart';
                Image = SelectChart;
                ToolTip = 'Change the chart that is displayed. You can choose from several charts that show data for different performance indicators.';
                Visible = ShowChart;

                trigger OnAction()
                begin
                    ChartManagement.SelectChart(BusinessChartBuffer,SelectedChartDefinition);
                    InitializeSelectedChart;
                end;
            }
            action("Previous Chart")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Previous Chart';
                Image = PreviousSet;
                ToolTip = 'View the previous chart.';
                Visible = ShowChart;

                trigger OnAction()
                begin
                    SelectedChartDefinition.SetRange(Enabled,true);
                    if SelectedChartDefinition.Next(-1) = 0 then
                      if not SelectedChartDefinition.FindLast then
                        exit;
                    InitializeSelectedChart;
                end;
            }
            action("Next Chart")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Next Chart';
                Image = NextSet;
                ToolTip = 'View the next chart.';
                Visible = ShowChart;

                trigger OnAction()
                begin
                    SelectedChartDefinition.SetRange(Enabled,true);
                    if SelectedChartDefinition.Next = 0 then
                      if not SelectedChartDefinition.FindFirst then
                        exit;
                    InitializeSelectedChart;
                end;
            }
            group(PeriodLength)
            {
                Caption = 'Period Length';
                Image = Period;
                Visible = ShowChart;
                action(Day)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Day';
                    Image = DueDate;
                    ToolTip = 'Each stack covers one day.';
                    Visible = ShowChart;

                    trigger OnAction()
                    begin
                        SetPeriodAndUpdateChart(BusinessChartBuffer."Period Length"::Day);
                    end;
                }
                action(Week)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Week';
                    Image = DateRange;
                    ToolTip = 'Each stack except for the last stack covers one week. The last stack contains data from the start of the week until the date that is defined by the Show option.';
                    Visible = ShowChart;

                    trigger OnAction()
                    begin
                        SetPeriodAndUpdateChart(BusinessChartBuffer."Period Length"::Week);
                    end;
                }
                action(Month)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Month';
                    Image = DateRange;
                    ToolTip = 'Each stack except for the last stack covers one month. The last stack contains data from the start of the month until the date that is defined by the Show option.';
                    Visible = ShowChart;

                    trigger OnAction()
                    begin
                        SetPeriodAndUpdateChart(BusinessChartBuffer."Period Length"::Month);
                    end;
                }
                action(Quarter)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Quarter';
                    Image = DateRange;
                    ToolTip = 'Each stack except for the last stack covers one quarter. The last stack contains data from the start of the quarter until the date that is defined by the Show option.';
                    Visible = ShowChart;

                    trigger OnAction()
                    begin
                        SetPeriodAndUpdateChart(BusinessChartBuffer."Period Length"::Quarter);
                    end;
                }
                action(Year)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Year';
                    Image = DateRange;
                    ToolTip = 'Each stack except for the last stack covers one year. The last stack contains data from the start of the year until the date that is defined by the Show option.';
                    Visible = ShowChart;

                    trigger OnAction()
                    begin
                        SetPeriodAndUpdateChart(BusinessChartBuffer."Period Length"::Year);
                    end;
                }
            }
            action(PreviousPeriod)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Previous Period';
                Enabled = PreviousNextActionEnabled;
                Image = PreviousRecord;
                ToolTip = 'Show the information based on the previous period. If you set the View by field to Day, the date filter changes to the day before.';
                Visible = ShowChart;

                trigger OnAction()
                begin
                    ChartManagement.UpdateChart(SelectedChartDefinition,BusinessChartBuffer,Period::Previous);
                    BusinessChartBuffer.Update(CurrPage.BusinessChart);
                end;
            }
            action(NextPeriod)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Next Period';
                Enabled = PreviousNextActionEnabled;
                Image = NextRecord;
                ToolTip = 'Show the information based on the next period. If you set the View by field to Day, the date filter changes to the day before.';
                Visible = ShowChart;

                trigger OnAction()
                begin
                    ChartManagement.UpdateChart(SelectedChartDefinition,BusinessChartBuffer,Period::Next);
                    BusinessChartBuffer.Update(CurrPage.BusinessChart);
                end;
            }
            action(ChartInformation)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Chart Information';
                Image = AboutNav;
                ToolTip = 'View a description of the chart.';
                Visible = ShowChart;

                trigger OnAction()
                var
                    Description: Text;
                begin
                    if StatusText = '' then
                      exit;
                    Description := ChartManagement.ChartDescription(SelectedChartDefinition);
                    if Description = '' then
                      Message(NoDescriptionMsg)
                    else
                      Message(Description);
                end;
            }
            action("Show Setup and Help Resources")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Show Setup and Help Resources';
                ToolTip = 'Get assistance for setup and view help topics, videos, and other resources.';
                Visible = ShowChart AND IsSaaS;

                trigger OnAction()
                begin
                    PersistChartVisibility(false);
                    Message(RefreshPageMsg)
                end;
            }
            action(View)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'View';
                Image = View;
                Promoted = true;
                PromotedCategory = Category4;
                RunPageMode = View;
                ShortCutKey = 'Return';
                ToolTip = 'View the resource.';
                Visible = NOT ShowChart;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
            action("Show Chart")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Show Chart';
                Image = AnalysisView;
                ToolTip = 'View the chart.';
                Visible = NOT ShowChart;

                trigger OnAction()
                begin
                    SetRange(Featured,true);
                    PersistChartVisibility(true);
                    if ClientTypeManagement.GetCurrentClientType in [CLIENTTYPE::Phone,CLIENTTYPE::Tablet] then
                      Message(SignInAgainMsg)
                    else
                      Message(RefreshPageMsg);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        CompanyInformation: Record "Company Information";
        LastUsedChart: Record "Last Used Chart";
        PermissionManager: Codeunit "Permission Manager";
    begin
        CompanyInformation.Get;
        ShowChart := CompanyInformation."Show Chart On RoleCenter";

        IsSaaS := PermissionManager.SoftwareAsAService;
        if ShowChart then begin
          if LastUsedChart.Get(UserId) then
            if SelectedChartDefinition.Get(LastUsedChart."Code Unit ID",LastUsedChart."Chart Name") then;

          InitializeSelectedChart;
        end;

        Initialize;
    end;

    var
        SelectedChartDefinition: Record "Chart Definition";
        BusinessChartBuffer: Record "Business Chart Buffer";
        ChartManagement: Codeunit "Chart Management";
        ClientTypeManagement: Codeunit ClientTypeManagement;
        StatusText: Text;
        Period: Option " ",Next,Previous;
        [InDataSet]
        PreviousNextActionEnabled: Boolean;
        NoDescriptionMsg: Label 'A description was not specified for this chart.';
        IsChartAddInReady: Boolean;
        ShowChart: Boolean;
        RefreshPageMsg: Label 'Refresh the page for the change to take effect.';
        IsSaaS: Boolean;
        SignInAgainMsg: Label 'Sign out and sign in for the change to take effect.';

    local procedure InitializeSelectedChart()
    begin
        ChartManagement.SetDefaultPeriodLength(SelectedChartDefinition,BusinessChartBuffer);
        ChartManagement.UpdateChart(SelectedChartDefinition,BusinessChartBuffer,Period::" ");
        PreviousNextActionEnabled := ChartManagement.UpdateNextPrevious(SelectedChartDefinition);
        ChartManagement.UpdateStatusText(SelectedChartDefinition,BusinessChartBuffer,StatusText);
        UpdateChart;
    end;

    local procedure SetPeriodAndUpdateChart(PeriodLength: Option)
    begin
        ChartManagement.SetPeriodLength(SelectedChartDefinition,BusinessChartBuffer,PeriodLength,false);
        ChartManagement.UpdateChart(SelectedChartDefinition,BusinessChartBuffer,Period::" ");
        ChartManagement.UpdateStatusText(SelectedChartDefinition,BusinessChartBuffer,StatusText);
        UpdateChart;
    end;

    local procedure UpdateChart()
    begin
        if not IsChartAddInReady then
          exit;
        BusinessChartBuffer.Update(CurrPage.BusinessChart);
    end;

    local procedure PersistChartVisibility(VisibilityStatus: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get then begin
          CompanyInformation.Init;
          CompanyInformation.Insert;
        end;

        CompanyInformation.Validate("Show Chart On RoleCenter",VisibilityStatus);
        CompanyInformation.Modify;
    end;
}

