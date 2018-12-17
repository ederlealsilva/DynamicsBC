page 810 "Web Services"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Web Services';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Web Service Aggregate";
    SourceTableTemporary = true;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1102601000)
            {
                ShowCaption = false;
                field("Object Type";"Object Type")
                {
                    ApplicationArea = Basic,Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the ID of the object.';
                    ValuesAllowed = Codeunit,Page,Query;
                }
                field("Object ID";"Object ID")
                {
                    ApplicationArea = Basic,Suite;
                    LookupPageID = Objects;
                    TableRelation = AllObj."Object ID" WHERE ("Object Type"=FIELD("Object Type"));
                    ToolTip = 'Specifies the ID of the object.';
                }
                field(ObjectName;GetObjectCaption)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Object Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the object that will be exposed to the web service.';
                }
                field("Service Name";"Service Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the service.';
                }
                field("All Tenants";"All Tenants")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = IsWebServiceWriteable;
                    Enabled = IsWebServiceWriteable;
                    ToolTip = 'Specifies that the service is available to all tenants.';
                }
                field(Published;Published)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies that the web service is published. A published web service is available on the Business Central Server computer that you were connected to when you published. The web service is available across all Business Central Server instances running on the server computer.';
                }
                field(ODataV4Url;GetODataV4Url)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OData V4 URL';
                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL that is generated for the web service. You can test the web service immediately by choosing the link in the field.';
                }
                field(ODataUrl;GetODataUrl)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'OData URL';
                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL that is generated for the web service. You can test the web service immediately by choosing the link in the field.';
                }
                field(SOAPUrl;GetSOAPUrl)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'SOAP URL';
                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the URL that is generated for the web service. You can test the web service immediately by choosing the link in the field.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("<Reload>")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Reload';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Update the window with the latest information.';

                trigger OnAction()
                begin
                    PopulateTable;
                end;
            }
            action("Create Data Set")
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Create Data Set';
                Image = AddAction;
                RunObject = Page "OData Setup Wizard";
                ToolTip = 'Launches wizard to create data sets that can be used for building reports in Excel, Power BI or any other reporting tool that works with an OData data source.';
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Default the all tenants checkbox to selected if the tenant has write permissions
        // to the application database.  Otherwise default not selected.
        "All Tenants" := IsWebServiceWriteable;
    end;

    trigger OnOpenPage()
    begin
        UpdatePage;
    end;

    var
        IsWebServiceWriteable: Boolean;

    local procedure GetObjectCaption(): Text[80]
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get("Object Type","Object ID") then
          exit(AllObjWithCaption."Object Caption");
        exit('');
    end;

    local procedure UpdatePage()
    var
        WebService: Record "Web Service";
    begin
        // When logged into a tenant with write permissions to the application database,
        // the all tenants checkbox will be enabled.
        // When logged into a tenant without write permissions to the application database,
        // the all tenants checkbox will be disabled.
        if WebService.WritePermission then
          IsWebServiceWriteable := true
        else
          IsWebServiceWriteable := false;

        PopulateTable;
    end;
}

