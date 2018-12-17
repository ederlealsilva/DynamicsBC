page 743 "VAT Report Setup"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'VAT Report Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "VAT Report Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Modify Submitted Reports";"Modify Submitted Reports")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies if users can modify VAT reports that have been submitted to the tax authorities. If the field is left blank, users must create a corrective or supplementary VAT report instead.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("EC Sales List No. Series";"No. Series")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number series from which entry or record numbers are assigned to new entries or records.';
                }
                field("VAT Return No. Series";"VAT Return No. Series")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number series that is used for VAT return records.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

