page 5348 "CRM Product List"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Products - Microsoft Dynamics 365 for Sales';
    Editable = false;
    PageType = List;
    SourceTable = "CRM Product";
    SourceTableView = SORTING(ProductNumber);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(ProductNumber;ProductNumber)
                {
                    ApplicationArea = Suite;
                    Caption = 'Product Number';
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(Name;Name)
                {
                    ApplicationArea = Suite;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the record.';
                }
                field(Price;Price)
                {
                    ApplicationArea = Suite;
                    Caption = 'Price';
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(StandardCost;StandardCost)
                {
                    ApplicationArea = Suite;
                    Caption = 'Standard Cost';
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(CurrentCost;CurrentCost)
                {
                    ApplicationArea = Suite;
                    Caption = 'Current Cost';
                    ToolTip = 'Specifies the item''s unit cost.';
                }
                field(Coupled;Coupled)
                {
                    ApplicationArea = Suite;
                    Caption = 'Coupled';
                    ToolTip = 'Specifies if the Dynamics 365 for Sales record is coupled to Business Central.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(ProductId,DATABASE::Item,RecordID) or
           CRMIntegrationRecord.FindRecordIDFromID(ProductId,DATABASE::Resource,RecordID)
        then
          if CurrentlyCoupledCRMProduct.ProductId = ProductId then begin
            Coupled := 'Current';
            FirstColumnStyle := 'Strong';
          end else begin
            Coupled := 'Yes';
            FirstColumnStyle := 'Subordinate';
          end
        else begin
          Coupled := 'No';
          FirstColumnStyle := 'None';
        end;
    end;

    trigger OnInit()
    begin
        CODEUNIT.Run(CODEUNIT::"CRM Integration Management");
    end;

    trigger OnOpenPage()
    var
        LookupCRMTables: Codeunit "Lookup CRM Tables";
    begin
        FilterGroup(4);
        SetView(LookupCRMTables.GetIntegrationTableMappingView(DATABASE::"CRM Product"));
        FilterGroup(0);
    end;

    var
        CurrentlyCoupledCRMProduct: Record "CRM Product";
        Coupled: Text;
        FirstColumnStyle: Text;

    [Scope('Personalization')]
    procedure SetCurrentlyCoupledCRMProduct(CRMProduct: Record "CRM Product")
    begin
        CurrentlyCoupledCRMProduct := CRMProduct;
    end;
}

