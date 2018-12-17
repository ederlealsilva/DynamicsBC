page 2346 "BC O365 VAT Posting Setup List"
{
    // version NAVW113.00

    Caption = ' ';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "VAT Product Posting Group";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Editable = false;
                    ToolTip = 'Specifies the VAT rate used to calculate VAT on what you buy or sell.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Open)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Open';
                Image = DocumentEdit;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'Open the card for the selected record.';
                Visible = false;

                trigger OnAction()
                begin
                    PAGE.RunModal(PAGE::"O365 VAT Posting Setup Card",Rec);
                    DefaultVATProductPostingGroupCode := O365TemplateManagement.GetDefaultVATProdPostingGroup;
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Code = DefaultVATProductPostingGroupCode then
          Description := StrSubstNo(DefaultVATRateTxt,Description);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        SetCurrentKey(Code);
        exit(Find(Which));
    end;

    trigger OnOpenPage()
    begin
        DefaultVATProductPostingGroupCode := O365TemplateManagement.GetDefaultVATProdPostingGroup;
    end;

    var
        O365TemplateManagement: Codeunit "O365 Template Management";
        DefaultVATProductPostingGroupCode: Code[20];
        DefaultVATRateTxt: Label '%1 (Default)', Comment='%1 = a VAT rate name, such as "Reduced VAT"';
}

