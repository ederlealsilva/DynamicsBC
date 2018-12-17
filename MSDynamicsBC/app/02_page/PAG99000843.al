page 99000843 "Prod. Order BOM Cmt List"
{
    // version NAVW111.00

    AutoSplitKey = true;
    Caption = 'Comment List';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Prod. Order Comp. Cmt Line";

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
                    ToolTip = 'Specifies the date.';
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the actual comment text.';
                }
                field("Code";Code)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a code for the comments.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

