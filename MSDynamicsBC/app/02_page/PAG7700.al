page 7700 Miniform
{
    // version NAVW113.00

    Caption = 'Miniform';
    DataCaptionFields = "Code";
    PageType = ListPlus;
    SourceTable = "Miniform Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies a unique code for a specific miniform.';
                }
                field(Description;Description)
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies your description of the miniform with the code on the header.';
                }
                field("Form Type";"Form Type")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies the form type of the miniform.';
                }
                field("No. of Records in List";"No. of Records in List")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies the number of records that will be sent to the handheld if the miniform on the header is either Selection List or Data List.';
                }
                field("Handling Codeunit";"Handling Codeunit")
                {
                    ApplicationArea = ADCS;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the number of the codeunit containing the code that handles this miniform.';
                }
                field("Next Miniform";"Next Miniform")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies which form will be shown next when a selection is made in a Data List form or when the last field is entered on a Card form.';
                }
                field("Start Miniform";"Start Miniform")
                {
                    ApplicationArea = ADCS;
                    ToolTip = 'Specifies that this field is the first miniform that will be shown to the user when starting up a handheld.';
                }
            }
            part(Control9;"Miniform Subform")
            {
                ApplicationArea = ADCS;
                SubPageLink = "Miniform Code"=FIELD(Code);
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
        area(navigation)
        {
            group("&Mini Form")
            {
                Caption = '&Mini Form';
                Image = MiniForm;
                action("&Functions")
                {
                    ApplicationArea = ADCS;
                    Caption = '&Functions';
                    Image = "Action";
                    RunObject = Page "Miniform Functions";
                    RunPageLink = "Miniform Code"=FIELD(Code);
                    ToolTip = 'Access functions to set up the ADCS interface.';
                }
            }
        }
    }
}

