page 597 "XBRL Comment Lines Part"
{
    // version NAVW111.00

    Caption = 'XBRL Comment Lines Part';
    PageType = ListPart;
    SourceTable = "XBRL Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Comment Type";"Comment Type")
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies the type of comment that the line contains. Info: a comment imported from the schema file when you imported the taxonomy. Note: A comment that will be exported with the other financial information. Reference: A comment imported from the reference linkbase when you imported the taxonomy.';
                    Visible = false;
                }
                field(Date;Date)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies a date for the comment. When you run the XBRL Export Instance - Spec. 2 report, it includes comments that dates within the period of the report, as well as comments that do not have a date.';
                    Visible = false;
                }
                field(Comment;Comment)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies the comment. If the comment type is Info, this comment was imported with the taxonomy and cannot be edited. If the comment type is Note, you can enter a maximum of 80 characters for each, both numbers and letters, and it will be exported with the rest of the financial information.';
                }
            }
        }
    }

    actions
    {
    }
}

