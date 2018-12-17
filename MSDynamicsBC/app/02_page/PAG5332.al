page 5332 "SDK Version List"
{
    // version NAVW113.00

    Caption = 'SDK Version List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = TempStack;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("SDK version";StackOrder)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the version of the Microsoft Dynamics 365 (CRM) software development kit that is used for the connection.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationManagement.InitializeProxyVersionList(Rec);
    end;
}

