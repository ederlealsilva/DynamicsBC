page 5748 "Transfer Route Specification"
{
    // version NAVW113.00

    Caption = 'Trans. Route Spec.';
    PageType = Card;
    SourceTable = "Transfer Route";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("In-Transit Code";"In-Transit Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the in-transit code for the transfer order, such as a shipping agent.';
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                }
                field("Shipping Agent Service Code";"Shipping Agent Service Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
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
    }

    trigger OnClosePage()
    begin
        if Get("Transfer-from Code","Transfer-to Code") then begin
          if ("Shipping Agent Code" = '') and
             ("Shipping Agent Service Code" = '') and
             ("In-Transit Code" = '')
          then
            Delete;
        end;
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;
}

