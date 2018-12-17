page 2198 "O365 Unit Of Measure Card"
{
    // version NAVW113.00

    Caption = 'Price per';
    DataCaptionExpression = Description;
    SourceTable = "Unit of Measure";

    layout
    {
        area(content)
        {
            field("Code";Code)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                ToolTip = 'Specifies a code for the unit of measure that is shown on the item and resource cards where it is used.';
                Visible = false;
            }
            field(DescriptionInCurrentLanguage;DescriptionInCurrentLanguage)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Description';
                ToolTip = 'Specifies a description of the unit of measure.';

                trigger OnValidate()
                begin
                    if DescriptionInCurrentLanguage = '' then
                      DescriptionInCurrentLanguage := GetDescriptionInCurrentLanguage;
                end;
            }
        }
    }

    actions
    {
        area(creation)
        {
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DescriptionInCurrentLanguage := GetDescriptionInCurrentLanguage;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not (CloseAction in [ACTION::OK,ACTION::LookupOK]) then
          exit(true);

        if DescriptionInCurrentLanguage = GetDescriptionInCurrentLanguage then
          exit(true);

        // Do not insert a new empty record
        if (Code = '') and (DescriptionInCurrentLanguage = '') then
          exit(true);

        if UnitOfMeasure.Get(UpperCase(DescriptionInCurrentLanguage)) then
          Error(UnitOfMeasureAlredyExistsErr,DescriptionInCurrentLanguage);

        if Code = '' then
          InsertNewUnitOfMeasure
        else
          RenameUnitOfMeasureRemoveTranslations;
    end;

    var
        UnitOfMeasureAlredyExistsErr: Label 'You already have a measure with the name %1.', Comment='%1=The unit of measure description';
        DescriptionInCurrentLanguage: Text[10];

    local procedure RenameUnitOfMeasureRemoveTranslations()
    var
        UnitOfMeasureTranslation: Record "Unit of Measure Translation";
    begin
        if Code <> '' then begin
          UnitOfMeasureTranslation.SetRange(Code,Code);
          UnitOfMeasureTranslation.DeleteAll(true);
        end;

        Validate(Description,DescriptionInCurrentLanguage);
        Modify(true);
        Rename(DescriptionInCurrentLanguage);
    end;

    local procedure InsertNewUnitOfMeasure()
    begin
        Validate(Code,DescriptionInCurrentLanguage);
        Validate(Description,DescriptionInCurrentLanguage);

        Insert(true);
    end;
}

