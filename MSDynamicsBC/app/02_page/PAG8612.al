page 8612 "Config. Question Subform"
{
    // version NAVW113.00

    Caption = 'Lines';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Config. Question";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                    ApplicationArea = Basic,Suite;
                    MinValue = 1;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Field ID";"Field ID")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the ID of the field from the table that the question area manages.';
                }
                field(Question;Question)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a question that is to be answered on the setup questionnaire. On the Actions tab, in the Question group, choose Update Questions to auto populate the question list based on the fields in the table on which the question area is based. You can modify the text to be more meaningful to the person responsible for filling out the questionnaire. For example, you could rewrite the Name? question as What is the name of your company?';
                }
                field("Answer Option";"Answer Option")
                {
                    ApplicationArea = Basic,Suite;
                    Lookup = false;
                    ToolTip = 'Specifies the format that the answer to the question needs to meet. For example, if you have a question about a name that needs to be answered, according to the name field format and data type set up in the database, the answer option can specify Text.';
                }
                field(Answer;Answer)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the answer to the question. The answer to the question should match the format of the answer option and must be a value that the database supports. If it does not, then there will be an error when you apply the answer.';
                }
                field("Field Value";LookupValue)
                {
                    ApplicationArea = Basic,Suite;
                }
                field(Reference;Reference)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a url address. Use this field to provide a url address to a location that Specifies information about the question. For example, you could provide the address of a page that Specifies information about setup considerations that the person answering the questionnaire should consider.';
                }
                field("Field Name";"Field Name")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the field that is supporting the setup questionnaire area. The name comes from the Name property of the field.';
                }
                field("Field Caption";"Field Caption")
                {
                    ApplicationArea = Basic,Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the caption of the field that is supporting the setup questionnaire area. The caption comes from the Caption property of the field.';
                }
                field("Question Origin";"Question Origin")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the origin of the question.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

