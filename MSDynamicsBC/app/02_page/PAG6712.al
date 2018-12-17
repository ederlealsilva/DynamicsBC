page 6712 "Tenant Web Services Lookup"
{
    // version NAVW110.0

    Caption = 'Tenant Web Services Lookup';
    Editable = false;
    PageType = List;
    SourceTable = "Tenant Web Service";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type";"Object Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the Object Type of the data set.';
                }
                field("Object ID";"Object ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the object ID for the data set.';
                }
                field("Service Name";"Service Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the data set name.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        InitData;
    end;

    local procedure InitData()
    var
        LocalTenantWebService: Record "Tenant Web Service";
        LocalTenantWebServiceColumns: Record "Tenant Web Service Columns";
    begin
        if LocalTenantWebService.Find('-') then
          repeat
            LocalTenantWebServiceColumns.TenantWebServiceID := LocalTenantWebService.RecordId;
            if LocalTenantWebServiceColumns.FindFirst then begin
              Rec := LocalTenantWebService;
              Insert;
            end;
          until LocalTenantWebService.Next = 0;
    end;
}

