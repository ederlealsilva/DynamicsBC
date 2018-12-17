page 5150 "Contact Segment List"
{
    // version NAVW111.00

    Caption = 'Contact Segment List';
    DataCaptionExpression = GetCaption;
    Editable = false;
    PageType = List;
    SourceTable = "Segment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Segment No.";"Segment No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the segment to which this segment line belongs.';
                }
                field(Description;Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the segment line.';
                }
                field(Date;Date)
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the date the segment line was created.';
                }
                field("Contact No.";"Contact No.")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the number of the contact to which this segment line applies.';
                }
                field("Contact Name";"Contact Name")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = 'Contact Name';
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the contact to which the segment line applies. The program automatically fills in this field when you fill in the Contact No. field on the line.';
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
            group("&Segment")
            {
                Caption = '&Segment';
                Image = Segment;
                action("&Card")
                {
                    ApplicationArea = RelationshipMgmt;
                    Caption = '&Card';
                    Image = EditLines;
                    RunObject = Page Segment;
                    RunPageLink = "No."=FIELD("Segment No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about the contact segment.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalcFields("Contact Name");
    end;

    var
        ClientTypeManagement: Codeunit ClientTypeManagement;

    local procedure GetCaption() Result: Text
    var
        Contact: Record Contact;
    begin
        if Contact.Get(GetFilter("Contact Company No.")) then
          Result := StrSubstNo('%1 %2',Contact."No.",Contact.Name);

        if Contact.Get(GetFilter("Contact No.")) then
          Result := StrSubstNo('%1 %2 %3',Result,Contact."No.",Contact.Name);

        if ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Phone then
          Result := StrSubstNo('%1 %2',CurrPage.Caption,Result);
    end;
}

