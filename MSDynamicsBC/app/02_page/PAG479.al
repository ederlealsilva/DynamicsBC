page 479 "Dimension Set Entries"
{
    // version NAVW113.00

    Caption = 'Dimension Set Entries';
    Editable = false;
    PageType = List;
    SourceTable = "Dimension Set Entry";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Dimension Code";"Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension.';
                }
                field("Dimension Name";"Dimension Name")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the descriptive name of the Dimension Code field.';
                    Visible = false;
                }
                field(DimensionValueCode;"Dimension Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension value.';
                }
                field("Dimension Value Name";"Dimension Value Name")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the descriptive name of the Dimension Value Code field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if FormCaption <> '' then
          CurrPage.Caption := FormCaption;
    end;

    trigger OnInit()
    begin
        if FormCaption <> '' then
          CurrPage.Caption := FormCaption;
    end;

    var
        FormCaption: Text[250];

    [Scope('Personalization')]
    procedure SetFormCaption(NewFormCaption: Text[250])
    begin
        FormCaption := CopyStr(NewFormCaption + ' - ' + CurrPage.Caption,1,MaxStrLen(FormCaption));
    end;
}

