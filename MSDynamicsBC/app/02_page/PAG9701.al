page 9701 "Cue Setup Administrator"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Cue Setup';
    PageType = List;
    Permissions = TableData "Cue Setup"=rimd;
    SourceTable = "Cue Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User Name";"User Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies which Business Central user the indicator setup for the Cue pertains to. If you leave this field blank, then the indicator setup will pertain to all users.';
                }
                field("Table ID";"Table ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the Business Central table that contains the Cue.';
                }
                field("Table Name";"Table Name")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    QuickEntry = false;
                    ToolTip = 'Specifies the name of the table that contains the field that defines the Cue.';
                }
                field("Field No.";"Field No.")
                {
                    ApplicationArea = Basic,Suite;
                    NotBlank = true;
                    ToolTip = 'Specifies the ID that is assigned the Cue.';
                }
                field("Field Name";"Field Name")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    LookupPageID = "Fields";
                    QuickEntry = false;
                    ToolTip = 'Specifies the name that is assigned to the Cue.';
                }
                field("Low Range Style";"Low Range Style")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = LowRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is less than the value that is specified by the Threshold 1 field.';

                    trigger OnValidate()
                    begin
                        LowRangeStyleExpr := ConvertStyleToStyleText("Low Range Style");
                    end;
                }
                field("Threshold 1";"Threshold 1")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the value in the Cue below which the indicator has the color that is specified by the Low Range Style field.';
                }
                field("Middle Range Style";"Middle Range Style")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = MiddleRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is greater than or equal to the value that is specified by the Threshold 1 field but less than or equal to the value that is specified by the Threshold 2 field.';

                    trigger OnValidate()
                    begin
                        MiddleRangeStyleExpr := ConvertStyleToStyleText("Middle Range Style");
                    end;
                }
                field("Threshold 2";"Threshold 2")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the value in the Cue above which the indicator has the color that is specified by the High Range Style field.';
                }
                field("High Range Style";"High Range Style")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = HighRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value in the Cue is greater than the value of the Threshold 2 field.';

                    trigger OnValidate()
                    begin
                        HighRangeStyleExpr := ConvertStyleToStyleText("High Range Style");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UpdateThresholdStyles;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateThresholdStyles;
    end;

    var
        LowRangeStyleExpr: Text;
        MiddleRangeStyleExpr: Text;
        HighRangeStyleExpr: Text;

    local procedure UpdateThresholdStyles()
    begin
        LowRangeStyleExpr := ConvertStyleToStyleText("Low Range Style");
        MiddleRangeStyleExpr := ConvertStyleToStyleText("Middle Range Style");
        HighRangeStyleExpr := ConvertStyleToStyleText("High Range Style");
    end;
}

