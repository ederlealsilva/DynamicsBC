page 5142 "Save Segment Criteria"
{
    // version NAVW111.00

    Caption = 'Save Segment Criteria';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    ToolTip = 'Specifies the code for the segment criteria that you want to save.';

                    trigger OnValidate()
                    var
                        SavedSegCriteria: Record "Saved Segment Criteria";
                    begin
                        if Code <> '' then begin
                          SavedSegCriteria.Code := Code;
                          SavedSegCriteria.Insert;
                          SavedSegCriteria.Delete;
                        end;
                    end;
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies a description of the segment.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK,ACTION::LookupOK] then
          OKOnPush;
    end;

    var
        ExitAction: Action;
        "Code": Code[10];
        Description: Text[50];

    [Scope('Personalization')]
    procedure GetValues(var GetFormAction: Action;var GetCode: Code[10];var GetDescription: Text[50])
    begin
        GetFormAction := ExitAction;
        GetCode := Code;
        GetDescription := Description;
    end;

    [Scope('Personalization')]
    procedure SetValues(SetFormAction: Action;SetCode: Code[10];SetDescription: Text[50])
    begin
        ExitAction := SetFormAction;
        Code := SetCode;
        Description := SetDescription;
    end;

    local procedure OKOnPush()
    var
        SavedSegCriteria: Record "Saved Segment Criteria";
    begin
        SavedSegCriteria.Code := Code;
        SavedSegCriteria.TestField(Code);
        ExitAction := ACTION::OK;
        CurrPage.Close;
    end;
}

