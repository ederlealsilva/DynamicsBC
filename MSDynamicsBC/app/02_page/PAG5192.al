page 5192 "Contact Duplicate Details"
{
    // version NAVW111.00

    Caption = 'Contact Duplicate Details';
    Editable = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Contact Dupl. Details Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name";"Field Name")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the name of the field where the duplicate was found.';
                }
                field("Field Value";"Field Value")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the value of the field where the duplicate was found.';
                }
                field("Duplicate Field Value";"Duplicate Field Value")
                {
                    ApplicationArea = RelationshipMgmt;
                    ToolTip = 'Specifies the value of the duplicate that was found.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CreateContactDuplicateDetails(NewContactNo,NewDuplicateContactNo);
    end;

    var
        NewContactNo: Code[20];
        NewDuplicateContactNo: Code[20];

    [Scope('Personalization')]
    procedure SetContactNo(ContactNo: Code[20];DuplicateContactNo: Code[20])
    begin
        NewContactNo := ContactNo;
        NewDuplicateContactNo := DuplicateContactNo;
    end;
}

