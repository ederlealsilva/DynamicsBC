page 171 "Standard Sales Code Subform"
{
    // version NAVW113.00

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Standard Sales Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type;Type)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies whether the line is for a general ledger account, item, resource, fixed asset or item charge.';

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate;
                    end;
                }
                field(FilteredTypeField;TypeAsText)
                {
                    ApplicationArea = Suite;
                    Caption = 'Type';
                    Editable = CurrPageIsEditable;
                    LookupPageID = "Option Lookup List";
                    TableRelation = "Option Lookup Buffer"."Option Caption" WHERE ("Lookup Type"=CONST(Sales));
                    ToolTip = 'Specifies whether the line is for a general ledger account, item, fixed asset or item charge.';
                    Visible = IsFoundation;

                    trigger OnValidate()
                    begin
                        TempOptionLookupBuffer.SetCurrentType(Type);
                        if TempOptionLookupBuffer.AutoCompleteOption(TypeAsText,TempOptionLookupBuffer."Lookup Type"::Sales) then
                          Validate(Type,TempOptionLookupBuffer.ID);
                        TempOptionLookupBuffer.ValidateOption(TypeAsText);
                        UpdateTypeText;
                        TypeOnAfterValidate;
                    end;
                }
                field("No.";"No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of a general ledger account, item, resource, additional cost, or fixed asset, depending on the contents of the Type field.';

                    trigger OnValidate()
                    begin
                        if not ApplicationAreaMgmtFacade.IsFoundationEnabled then
                          exit;

                        if "No." = xRec."No." then
                          exit;

                        UpdateTypeText;
                    end;
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description;Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a description of the entry, which is based on the contents of the Type and No. fields.';

                    trigger OnValidate()
                    begin
                        if Description = xRec.Description then
                          exit;

                        if "No." = '' then
                          Type := Type::" ";
                        UpdateTypeText;
                    end;
                }
                field(Quantity;Quantity)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of units of the item on the line.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                    Visible = false;
                }
                field("Amount Excl. VAT";"Amount Excl. VAT")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the net amount for the standard sales line. This field only applies to lines of type G/L Account and Charge (Item).';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]";ShortcutDimCode[3])
                {
                    ApplicationArea = Suite;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(3),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3,ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]";ShortcutDimCode[4])
                {
                    ApplicationArea = Suite;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(4),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4,ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]";ShortcutDimCode[5])
                {
                    ApplicationArea = Suite;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(5),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5,ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]";ShortcutDimCode[6])
                {
                    ApplicationArea = Suite;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(6),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6,ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]";ShortcutDimCode[7])
                {
                    ApplicationArea = Suite;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(7),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7,ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]";ShortcutDimCode[8])
                {
                    ApplicationArea = Suite;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(8),
                                                                  "Dimension Value Type"=CONST(Standard),
                                                                  Blocked=CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8,ShortcutDimCode[8]);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension=R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Scope = Repeater;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPageIsEditable := CurrPage.Editable;
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
        UpdateTypeText;
    end;

    trigger OnInit()
    begin
        TempOptionLookupBuffer.FillBuffer(TempOptionLookupBuffer."Lookup Type"::Sales);
        IsFoundation := ApplicationAreaMgmtFacade.IsFoundationEnabled;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if ApplicationAreaMgmtFacade.IsAdvancedEnabled then
          Type := xRec.Type;

        if ApplicationAreaMgmtFacade.IsFoundationEnabled then
          Type := Type::Item;
        UpdateTypeText;

        Clear(ShortcutDimCode);
    end;

    var
        TempOptionLookupBuffer: Record "Option Lookup Buffer" temporary;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        ShortcutDimCode: array [8] of Code[20];
        TypeAsText: Text[30];
        IsFoundation: Boolean;
        CurrPageIsEditable: Boolean;

    local procedure TypeOnAfterValidate()
    begin
        Clear(ShortcutDimCode);
    end;

    local procedure UpdateTypeText()
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        TypeAsText := TempOptionLookupBuffer.FormatOption(RecRef.Field(FieldNo(Type)));
    end;
}

