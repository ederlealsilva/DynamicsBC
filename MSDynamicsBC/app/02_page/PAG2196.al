page 2196 "O365 Link to Financials"
{
    // version NAVW113.00

    Caption = 'O365 Link to Financials';
    PageType = CardPart;

    layout
    {
        area(content)
        {
            field(StayTunedLbl;'')
            {
                ApplicationArea = Invoicing;
                Caption = 'We''re building the Microsoft Invoicing web experience. Stay tuned!';
                Editable = false;
                Style = StrongAccent;
                StyleExpr = TRUE;
                ToolTip = 'Specifies that we''re building the Microsoft Invoicing web experience.';
                Visible = IsFinApp;
            }
            field(TryOutLbl;'')
            {
                ApplicationArea = Invoicing;
                Caption = 'Try out the Dynamics 365 evaluation company.';
                Editable = false;
                Style = StrongAccent;
                StyleExpr = TRUE;
                ToolTip = 'Specifies to try out the Business Central evaluation company';
                Visible = IsFinApp;
            }
            field(LinkToFinancials;TryD365FinancialsLbl)
            {
                ApplicationArea = Invoicing;
                Editable = false;
                ShowCaption = false;
                Visible = IsFinApp;

                trigger OnDrillDown()
                begin
                    ChangeToEvaluationCompany;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        Initialize;
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        IsFinApp: Boolean;
        TryD365FinancialsLbl: Label 'Click here to change company.';
        SignOutToStartTrialMsg: Label 'We''re glad you''ve chosen to explore Dynamics 365 Business Central!\\To get going, please sign out and sign in again.';
        EvaluationCompanyDoesNotExistsMsg: Label 'We''re unable to start Dynamics 365 Business Central because your evaluation company is not yet set up.';

    local procedure Initialize()
    begin
        IsFinApp := IdentityManagement.IsFinAppId;
    end;

    local procedure ChangeToEvaluationCompany()
    var
        UserPersonalization: Record "User Personalization";
        Company: Record Company;
    begin
        Company.SetRange("Evaluation Company",true);
        if Company.FindFirst then begin
          UserPersonalization.Get(UserSecurityId);
          UserPersonalization.Validate(Company,Company.Name);
          UserPersonalization.Modify(true);
          Message(SignOutToStartTrialMsg)
        end else
          Message(EvaluationCompanyDoesNotExistsMsg);
    end;
}

