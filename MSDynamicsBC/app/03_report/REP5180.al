report 5180 "Delete Sales Order Versions"
{
    // version NAVW17.00

    Caption = 'Delete Archived Sales Order Versions';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Header Archive";"Sales Header Archive")
        {
            DataItemTableView = SORTING("Document Type","No.","Doc. No. Occurrence","Version No.") WHERE("Document Type"=CONST(Order),"Interaction Exist"=CONST(false));
            RequestFilterFields = "No.","Date Archived","Sell-to Customer No.";

            trigger OnAfterGetRecord()
            var
                SalesHeader: Record "Sales Header";
            begin
                SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
                SalesHeader.SetRange("No.","No.");
                SalesHeader.SetRange("Doc. No. Occurrence","Doc. No. Occurrence");
                if not SalesHeader.FindFirst then
                  Delete(true);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Message(Text000);
    end;

    var
        Text000: Label 'Archived versions deleted.';
}

