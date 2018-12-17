page 1445 "Headline RC Administrator"
{
    // version NAVW113.00

    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;
    SourceTable = "Headline RC Administrator";

    layout
    {
        area(content)
        {
            group(Control2)
            {
                ShowCaption = false;
                Visible = UserGreetingVisible;
                field(GreetingText;GreetingText)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Greeting headline';
                    Editable = false;
                    Visible = UserGreetingVisible;
                }
            }
            group(Control4)
            {
                ShowCaption = false;
                Visible = DefaultFieldsVisible;
                field(DocumentationText;DocumentationText)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Documentation headline';
                    DrillDown = true;
                    Editable = false;
                    Visible = DefaultFieldsVisible;

                    trigger OnDrillDown()
                    begin
                        HyperLink(DocumentationUrlTxt);
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
        ComputeDefaultFieldsVisibility;
    end;

    trigger OnOpenPage()
    var
        Uninitialized: Boolean;
    begin
        if not Get then
          if WritePermission then begin
            Init;
            Insert;
          end else
            Uninitialized := true;

        if not Uninitialized and WritePermission then begin
          "Workdate for computations" := WorkDate;
          Modify;
          HeadlineManagement.ScheduleTask(CODEUNIT::"Headline RC Administrator");
        end;

        HeadlineManagement.GetUserGreetingText(GreetingText);
        DocumentationText := StrSubstNo(DocumentationTxt,PRODUCTNAME.Short);

        if Uninitialized then
          // table is uninitialized because of permission issues. OnAfterGetRecord won't be called
          ComputeDefaultFieldsVisibility;
        Commit; // not to mess up the other page parts that may do IF CODEUNIT.RUN()
    end;

    var
        HeadlineManagement: Codeunit "Headline Management";
        DefaultFieldsVisible: Boolean;
        DocumentationTxt: Label 'Want to learn more about %1?', Comment='%1 is the NAV short product name.';
        DocumentationUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=867580', Locked=true;
        GreetingText: Text[250];
        DocumentationText: Text[250];
        UserGreetingVisible: Boolean;

    local procedure ComputeDefaultFieldsVisibility()
    var
        ExtensionHeadlinesVisible: Boolean;
    begin
        OnIsAnyExtensionHeadlineVisible(ExtensionHeadlinesVisible);
        DefaultFieldsVisible := not ExtensionHeadlinesVisible;
        UserGreetingVisible := HeadlineManagement.ShouldUserGreetingBeVisible;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAnyExtensionHeadlineVisible(var ExtensionHeadlinesVisible: Boolean)
    begin
    end;
}

