report 5177 "Delete Purchase Quote Versions"
{
    // version NAVW17.00

    Caption = 'Delete Archived Purchase Quote Versions';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Header Archive";"Purchase Header Archive")
        {
            DataItemTableView = SORTING("Document Type","No.","Doc. No. Occurrence","Version No.") WHERE("Document Type"=CONST(Quote),"Interaction Exist"=CONST(false));
            RequestFilterFields = "No.","Date Archived","Buy-from Vendor No.";

            trigger OnAfterGetRecord()
            var
                PurchHeader: Record "Purchase Header";
            begin
                PurchHeader.SetRange("Document Type",PurchHeader."Document Type"::Quote);
                PurchHeader.SetRange("No.","No.");
                PurchHeader.SetRange("Doc. No. Occurrence","Doc. No. Occurrence");
                if not PurchHeader.FindFirst then
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

