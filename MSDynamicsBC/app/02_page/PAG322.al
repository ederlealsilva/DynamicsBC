page 322 "ECSL Report Subform"
{
    // version NAVW111.00

    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "ECSL VAT Report Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Line No.";"Line No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the unique identifier for the line.';
                }
                field("Report No.";"Report No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the unique identifier for the report.';
                }
                field("Country Code";"Country Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies country code of the customer used for the line calculation.';
                }
                field("Customer VAT Reg. No.";"Customer VAT Reg. No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies VAT Registration Number of the customer.';
                }
                field("Total Value Of Supplies";"Total Value Of Supplies")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the total amount of the sold supplies.';
                }
                field("Transaction Indicator";"Transaction Indicator")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the transaction number.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowLines)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Show VAT Entries';
                Image = List;
                Scope = Repeater;
                ShortCutKey = 'Return';
                ToolTip = 'View the related VAT entries.';

                trigger OnAction()
                var
                    VATEntry: Record "VAT Entry";
                    TempVATEntry: Record "VAT Entry" temporary;
                    ECSLVATReportLineRelation: Record "ECSL VAT Report Line Relation";
                    ECSLVATReportLine: Record "ECSL VAT Report Line";
                    VATEntriesPreview: Page "VAT Entries Preview";
                begin
                    CurrPage.SetSelectionFilter(ECSLVATReportLine);
                    if ECSLVATReportLine.FindFirst then;
                    if ECSLVATReportLine."Line No." = 0 then
                      exit;
                    ECSLVATReportLineRelation.SetRange("ECSL Line No.",ECSLVATReportLine."Line No.");
                    ECSLVATReportLineRelation.SetRange("ECSL Report No.",ECSLVATReportLine."Report No.");
                    if not ECSLVATReportLineRelation.FindSet then
                      exit;

                    repeat
                      if VATEntry.Get(ECSLVATReportLineRelation."VAT Entry No.") then begin
                        TempVATEntry.TransferFields(VATEntry,true);
                        TempVATEntry.Insert;
                      end;
                    until ECSLVATReportLineRelation.Next = 0;

                    VATEntriesPreview.Set(TempVATEntry);
                    VATEntriesPreview.Run;
                end;
            }
        }
    }

    [Scope('Personalization')]
    procedure UpdateForm()
    begin
        CurrPage.Update;
    end;
}

