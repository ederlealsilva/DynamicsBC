report 357 "Copy Company"
{
    // version NAVW113.00

    Caption = 'Copy Company';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Company;Company)
        {
            DataItemTableView = SORTING(Name);
            dataitem("Experience Tier Setup";"Experience Tier Setup")
            {
                DataItemLink = "Company Name"=FIELD(Name);
                DataItemTableView = SORTING("Company Name");

                trigger OnAfterGetRecord()
                var
                    ExperienceTierSetup: Record "Experience Tier Setup";
                    ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
                begin
                    ExperienceTierSetup := "Experience Tier Setup";
                    ExperienceTierSetup."Company Name" := NewCompanyName;
                    ExperienceTierSetup.Insert;
                    ApplicationAreaMgmt.SetExperienceTierOtherCompany(ExperienceTierSetup,NewCompanyName);
                end;
            }
            dataitem("Report Layout Selection";"Report Layout Selection")
            {
                DataItemLink = "Company Name"=FIELD(Name);
                DataItemTableView = SORTING("Report ID","Company Name");

                trigger OnAfterGetRecord()
                var
                    ReportLayoutSelection: Record "Report Layout Selection";
                begin
                    ReportLayoutSelection := "Report Layout Selection";
                    ReportLayoutSelection."Report ID" := "Report ID";
                    ReportLayoutSelection."Company Name" := NewCompanyName;
                    ReportLayoutSelection.Insert;
                end;
            }
            dataitem("Custom Report Layout";"Custom Report Layout")
            {
                DataItemLink = "Company Name"=FIELD(Name);

                trigger OnAfterGetRecord()
                var
                    CustomReportLayout: Record "Custom Report Layout";
                begin
                    CustomReportLayout := "Custom Report Layout";
                    CustomReportLayout.Code := '';
                    CustomReportLayout."Company Name" := NewCompanyName;
                    CustomReportLayout.Insert(true);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ProgressWindow.Open(StrSubstNo(ProgressMsg,NewCompanyName));

                if BreakReport then
                  CurrReport.Break;
                CopyCompany(Name,NewCompanyName);
                BreakReport := true;
            end;

            trigger OnPostDataItem()
            begin
                ProgressWindow.Close;
                Message(CopySuccessMsg,Name);
            end;
        }
    }

    requestpage
    {
        ShowFilter = false;

        layout
        {
            area(content)
            {
                group(Control2)
                {
                    ShowCaption = false;
                    field("New Company Name";NewCompanyName)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'New Company Name';
                        NotBlank = true;
                        ToolTip = 'Specifies the name of the new company. The name can have a maximum of 30 characters. If the database collation is case-sensitive, you can have one company called COMPANY and another called Company. However, if the database is case-insensitive, you cannot create companies with names that differ only by case.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ProgressWindow: Dialog;
        BreakReport: Boolean;
        NewCompanyName: Text[30];
        ProgressMsg: Label 'Creating new company %1.', Comment='Creating new company Contoso Corporation.';
        CopySuccessMsg: Label 'Company %1 has been copied successfully.', Comment='Company CRONUS International Ltd. has been copied successfully.';

    procedure GetCompanyName(): Text[30]
    begin
        exit(NewCompanyName);
    end;
}

