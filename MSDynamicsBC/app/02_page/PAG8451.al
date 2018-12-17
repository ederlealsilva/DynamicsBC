page 8451 "Intrastat Checklist Setup"
{
    // version NAVW113.00

    Caption = 'Intrastat Checklist Setup';
    PageType = List;
    SourceTable = "Intrastat Checklist Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name";"Field Name")
                {
                    ApplicationArea = Basic,Suite;
                    Editable = false;
                    ToolTip = 'Specifies the field that will be verified by the Intrastat journal check.';

                    trigger OnAssistEdit()
                    var
                        ClientTypeManagement: Codeunit ClientTypeManagement;
                    begin
                        if ClientTypeManagement.IsCommonWebClientType then
                          LookupFieldName;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ClientTypeManagement: Codeunit ClientTypeManagement;
                    begin
                        if ClientTypeManagement.IsWindowsClientType then
                          LookupFieldName;
                    end;
                }
            }
        }
    }

    actions
    {
    }
}

