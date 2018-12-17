page 387 "Extended Text Lines"
{
    // version NAVW110.0

    AutoSplitKey = true;
    Caption = 'Lines';
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Extended Text Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Text;Text)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the text. You can use both numbers and letters. There are no restrictions as to the number of lines you can use.';
                }
            }
        }
    }

    actions
    {
    }
}

