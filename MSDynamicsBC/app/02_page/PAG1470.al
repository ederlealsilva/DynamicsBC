page 1470 "Product Videos"
{
    // version NAVW113.00

    Caption = 'Product Videos';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Product Video Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control12)
            {
                Caption = 'Category';
                Editable = false;
            }
            field(Category;Category)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Category';
                OptionCaption = 'All,Getting Started,,Finance & Bookkeeping,Sales,Reporting & BI,Inventory Management,Project Management,Workflows,Services & Extensions,Setup';
                ToolTip = 'Specifies categories by which you can filter the listed videos.';
                Visible = false;

                trigger OnValidate()
                begin
                    InitBuffer(Rec,Category);
                    CurrPage.Update(false);
                end;
            }
            repeater("Available Videos")
            {
                Caption = 'Available Videos';
                Editable = false;
                IndentationColumn = Indentation;
                IndentationControls = Title;
                field(Title;Title)
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    StyleExpr = DescriptionStyle;
                    ToolTip = 'Specifies the title of the video.';

                    trigger OnDrillDown()
                    var
                        AssistedSetup: Record "Assisted Setup";
                    begin
                        if Indentation = 0 then begin
                          Message(GroupSelectionMsg);
                          exit;
                        end;
                        AssistedSetup.Get("Assisted Setup ID");
                        AssistedSetup.NavigateVideo;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if Indentation = 0 then
          DescriptionStyle := 'Strong'
        else
          DescriptionStyle := 'Standard';
    end;

    trigger OnInit()
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        AssistedSetup.Initialize;
    end;

    trigger OnOpenPage()
    begin
        Category := Category::All;
        InitBuffer(Rec,Category);
    end;

    var
        Category: Option All,"Getting Started",,"Finance & Bookkeeping",Sales,"Reporting & BI","Inventory Management","Project Management",Workflows,"Services & Extensions",Setup;
        DescriptionStyle: Text[50];
        GroupSelectionMsg: Label 'Select a video below to play.';
}

