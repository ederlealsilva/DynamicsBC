report 5187 "Generate Dupl. Search String"
{
    // version NAVW113.00

    ApplicationArea = #RelationshipMgmt;
    Caption = 'Generate Duplicate Search String';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Contact;Contact)
        {
            DataItemTableView = WHERE(Type=CONST(Company));
            RequestFilterFields = "No.","Company No.","Last Date Modified","External ID";

            trigger OnAfterGetRecord()
            begin
                Window.Update(1);
                DuplMgt.MakeContIndex(Contact);
            end;

            trigger OnPostDataItem()
            begin
                Window.Close;
            end;

            trigger OnPreDataItem()
            begin
                Window.Open(Text000 +
                  Text001,"No.");
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

    var
        Text000: Label 'Processing contacts...\\';
        Text001: Label 'Contact No.     #1##########';
        DuplMgt: Codeunit DuplicateManagement;
        Window: Dialog;
}

