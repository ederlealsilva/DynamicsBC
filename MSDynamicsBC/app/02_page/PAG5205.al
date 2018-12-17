page 5205 Qualifications
{
    // version NAVW113.00

    ApplicationArea = Advanced;
    Caption = 'Qualifications';
    PageType = List;
    SourceTable = Qualification;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code";Code)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a qualification code.';
                }
                field(Description;Description)
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies a description for the qualification.';
                }
                field("Qualified Employees";"Qualified Employees")
                {
                    ApplicationArea = BasicHR;
                    ToolTip = 'Specifies if the company has employees with this qualification.';
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
        area(navigation)
        {
            group("Q&ualification")
            {
                Caption = 'Q&ualification';
                Image = Certificate;
                action("Q&ualification Overview")
                {
                    ApplicationArea = BasicHR;
                    Caption = 'Q&ualification Overview';
                    Image = QualificationOverview;
                    RunObject = Page "Qualification Overview";
                    ToolTip = 'View qualifications that are registered for the employee.';
                }
            }
        }
    }
}

