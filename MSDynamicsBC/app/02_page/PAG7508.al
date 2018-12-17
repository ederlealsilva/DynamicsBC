page 7508 "Select Item Attribute Value"
{
    // version NAVW111.00

    Caption = 'Select Item Attribute Value';
    DataCaptionExpression = '';
    PageType = StandardDialog;
    SourceTable = "Item Attribute Value";

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(Value;Value)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the value of the option.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        Clear(DummySelectedItemAttributeValue);
        CurrPage.SetSelectionFilter(DummySelectedItemAttributeValue);
    end;

    var
        DummySelectedItemAttributeValue: Record "Item Attribute Value";

    [Scope('Personalization')]
    procedure GetSelectedValue(var ItemAttributeValue: Record "Item Attribute Value")
    begin
        ItemAttributeValue.Copy(DummySelectedItemAttributeValue);
    end;
}

