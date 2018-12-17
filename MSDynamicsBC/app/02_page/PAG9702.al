page 9702 "Cue Setup End User"
{
    // version NAVW110.0

    Caption = 'Cue Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    Permissions = TableData "Cue Setup"=rimd;
    SourceTable = "Cue Setup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name";"Field Name")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    LookupPageID = "Fields";
                    QuickEntry = false;
                    ToolTip = 'Specifies the name that is assigned to the Cue.';

                    trigger OnValidate()
                    begin
                        Personalized := true;
                    end;
                }
                field("Low Range Style";"Low Range Style")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = LowRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is less than the value that is specified by the Threshold 1 field.';

                    trigger OnValidate()
                    begin
                        LowRangeStyleExpr := ConvertStyleToStyleText("Low Range Style");
                        Personalized := true;
                    end;
                }
                field("Threshold 1";"Threshold 1")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the value in the Cue below which the indicator has the color that is specified by the Low Range Style field.';

                    trigger OnValidate()
                    begin
                        Personalized := true;
                    end;
                }
                field("Middle Range Style";"Middle Range Style")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = MiddleRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value of data in the Cue is greater than or equal to the value that is specified by the Threshold 1 field but less than or equal to the value that is specified by the Threshold 2 field.';

                    trigger OnValidate()
                    begin
                        MiddleRangeStyleExpr := ConvertStyleToStyleText("Middle Range Style");
                        Personalized := true;
                    end;
                }
                field("Threshold 2";"Threshold 2")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the value in the Cue above which the indicator has the color that is specified by the High Range Style field.';

                    trigger OnValidate()
                    begin
                        Personalized := true;
                    end;
                }
                field("High Range Style";"High Range Style")
                {
                    ApplicationArea = Basic,Suite;
                    StyleExpr = HighRangeStyleExpr;
                    ToolTip = 'Specifies the color of the indicator when the value in the Cue is greater than the value of the Threshold 2 field.';

                    trigger OnValidate()
                    begin
                        HighRangeStyleExpr := ConvertStyleToStyleText("High Range Style");
                        Personalized := true;
                    end;
                }
                field(Personalized;Personalized)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether the colored indicator settings for the Cue have been modified to differ from the company default settings. You also use this field to revert to the default settings.';

                    trigger OnValidate()
                    begin
                        CueSetup.ValidatePersonalizedField(Rec);
                        UpdateThresholdStyles;
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

    trigger OnClosePage()
    begin
        CueSetup.CopyTempCueSetupRecordsToTable(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        UpdateThresholdStyles;
    end;

    trigger OnOpenPage()
    begin
        CueSetup.PopulateTempCueSetupRecords(Rec);
    end;

    var
        CueSetup: Codeunit "Cue Setup";
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

