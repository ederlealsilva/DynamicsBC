page 5138 "Duplicate Search String Setup"
{
    // version NAVW111.00

    Caption = 'Duplicate Search String Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Duplicate Search String Setup";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Field Name";"Field Name")
                {
                    ApplicationArea = RelationshipMgmt;
                    Editable = false;
                    ToolTip = 'Specifies the field to use to generate the search string.';

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
                field("Part of Field";"Part of Field")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the part of the field to use to generate the search string. There are two options: First and Last.';
                }
                field(Length;Length)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies how many characters the search string will contain. You can enter a number from 2 to 10. The program automatically enters 5 as a default value.';
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
    }
}

