page 5640 "FA Reclass. Journal Batches"
{
    // version NAVW111.00

    Caption = 'FA Reclass. Journal Batches';
    DataCaptionExpression = DataCaption;
    Editable = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "FA Reclass. Journal Batch";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the name of the journal batch you are creating.';
                }
                field(Description;Description)
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the journal batch that you are creating.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Journal")
            {
                ApplicationArea = FixedAssets;
                Caption = 'Edit Journal';
                Image = OpenJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';
                ToolTip = 'Open a journal based on the journal batch.';

                trigger OnAction()
                begin
                    FAReclassJnlMgt.TemplateSelectionFromBatch(Rec);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        SetRange("Journal Template Name");
    end;

    trigger OnOpenPage()
    begin
        FAReclassJnlMgt.OpenJnlBatch(Rec);
    end;

    var
        FAReclassJnlMgt: Codeunit FAReclassJnlManagement;

    local procedure DataCaption(): Text[250]
    var
        ReclassJnlTempl: Record "FA Reclass. Journal Template";
    begin
        if not CurrPage.LookupMode then
          if GetFilter("Journal Template Name") <> '' then
            if GetRangeMin("Journal Template Name") = GetRangeMax("Journal Template Name") then
              if ReclassJnlTempl.Get(GetRangeMin("Journal Template Name")) then
                exit(ReclassJnlTempl.Name + ' ' + ReclassJnlTempl.Description);
    end;
}

