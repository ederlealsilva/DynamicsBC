page 5362 "CRM UnitGroup List"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Unit Groups - Microsoft Dynamics 365 for Sales';
    Editable = false;
    PageType = List;
    SourceTable = "CRM Uomschedule";
    SourceTableView = SORTING(Name);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = Suite;
                    Caption = 'Name';
                    StyleExpr = FirstColumnStyle;
                    ToolTip = 'Specifies the name of the record.';
                }
                field(BaseUoMName;BaseUoMName)
                {
                    ApplicationArea = Suite;
                    Caption = 'Base Unit Name';
                    ToolTip = 'Specifies the base unit of measure of the Dynamics 365 for Sales record.';
                }
                field(StateCode;StateCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Status';
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(StatusCode;StatusCode)
                {
                    ApplicationArea = Suite;
                    Caption = 'Status Reason';
                    ToolTip = 'Specifies information related to the Dynamics 365 for Sales connection. ';
                }
                field(Coupled;Coupled)
                {
                    ApplicationArea = Suite;
                    Caption = 'Coupled';
                    ToolTip = 'Specifies if the Dynamics 365 for Sales record is coupled to Business Central.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        CRMIntegrationRecord: Record "CRM Integration Record";
        RecordID: RecordID;
    begin
        if CRMIntegrationRecord.FindRecordIDFromID(UoMScheduleId,DATABASE::"Unit of Measure",RecordID) then
          if CurrentlyCoupledCRMUomschedule.UoMScheduleId = UoMScheduleId then begin
            Coupled := 'Current';
            FirstColumnStyle := 'Strong';
          end else begin
            Coupled := 'Yes';
            FirstColumnStyle := 'Subordinate';
          end
        else begin
          Coupled := 'No';
          FirstColumnStyle := 'None';
        end;
    end;

    trigger OnInit()
    begin
        CODEUNIT.Run(CODEUNIT::"CRM Integration Management");
    end;

    trigger OnOpenPage()
    var
        LookupCRMTables: Codeunit "Lookup CRM Tables";
    begin
        FilterGroup(4);
        SetView(LookupCRMTables.GetIntegrationTableMappingView(DATABASE::"CRM Uomschedule"));
        FilterGroup(0);
    end;

    var
        CurrentlyCoupledCRMUomschedule: Record "CRM Uomschedule";
        Coupled: Text;
        FirstColumnStyle: Text;

    [Scope('Personalization')]
    procedure SetCurrentlyCoupledCRMUomschedule(CRMUomschedule: Record "CRM Uomschedule")
    begin
        CurrentlyCoupledCRMUomschedule := CRMUomschedule;
    end;
}

