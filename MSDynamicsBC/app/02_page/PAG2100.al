page 2100 "O365 Sales Year Summary"
{
    // version NAVW113.00

    Caption = 'Sales per month';
    DataCaptionExpression = Date2DMY(WorkDate,3);
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(MonthyInfo)
            {
                Caption = '';
            }
            usercontrol(Chart;"Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = Basic,Suite,Invoicing;

                trigger DataPointClicked(point: DotNet BusinessChartDataPoint)
                begin
                    ShowMonth(point.XValueString);
                end;

                trigger DataPointDoubleClicked(point: DotNet BusinessChartDataPoint)
                begin
                end;
            }
            repeater(Control4)
            {
                ShowCaption = false;
                Visible = MonthlyDataVisible;
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Month';
                    Editable = false;
                    ToolTip = 'Specifies the month';
                }
                field(Value;Value)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the summarized amount';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        MonthlyDataVisible := false;
    end;

    var
        MonthTxt: Label 'Month';
        AmountTxt: Label 'Amount (%1)', Comment='%1=Currency Symbol (e.g. $)';
        MonthlyDataVisible: Boolean;

    local procedure ShowMonth(Month: Text)
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        TypeHelper: Codeunit "Type Helper";
    begin
        Get(TypeHelper.GetLocalizedMonthToInt(Month));
        TempNameValueBuffer.Copy(Rec);

        PAGE.Run(PAGE::"O365 Sales Month Summary",TempNameValueBuffer);
    end;

    procedure ShowMonthlyDataPart()
    begin
        MonthlyDataVisible := true;
    end;
}

