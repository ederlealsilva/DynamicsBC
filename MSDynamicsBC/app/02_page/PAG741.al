page 741 "VAT Report Subform"
{
    // version NAVW113.00

    Caption = 'Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = ListPart;
    SourceTable = "VAT Report Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Gen. Prod. Posting Group";"Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                }
                field("Posting Date";"Posting Date")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the posting date of the document that resulted in the VAT entry.';
                }
                field("Document No.";"Document No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the document number that resulted in the VAT entry.';
                }
                field("Document Type";"Document Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the type of the document that resulted in the VAT entry.';
                }
                field(Type;Type)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the type of the VAT entry.';
                }
                field(Base;Base)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the amount that the VAT amount in the Amount is calculated from.';
                }
                field(Amount;Amount)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the VAT amount for the report line. This is calculated based on the value of the Base field.';

                    trigger OnAssistEdit()
                    var
                        VATReportLineRelation: Record "VAT Report Line Relation";
                        VATEntry: Record "VAT Entry";
                        FilterText: Text[1024];
                        TableNo: Integer;
                    begin
                        FilterText := VATReportLineRelation.CreateFilterForAmountMapping("VAT Report No.","Line No.",TableNo);
                        case TableNo of
                          DATABASE::"VAT Entry":
                            begin
                              VATEntry.SetFilter("Entry No.",FilterText);
                              PAGE.RunModal(0,VATEntry);
                            end;
                        end;
                    end;
                }
                field("VAT Calculation Type";"VAT Calculation Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies how VAT will be calculated for purchases or sales of items with this particular combination of VAT business posting group and VAT product posting group.';
                }
                field("Bill-to/Pay-to No.";"Bill-to/Pay-to No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the number of the bill-to customer or pay-to vendor that the entry is linked to.';
                }
                field("EU 3-Party Trade";"EU 3-Party Trade")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies if the transaction is related to trade with a third party within the EU.';
                }
                field("Source Code";"Source Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the source code that specifies where the entry was created.';
                }
                field("Reason Code";"Reason Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                }
                field("Country/Region Code";"Country/Region Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Internal Ref. No.";"Internal Ref. No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the internal reference number of the VAT entry.';
                }
                field("Unrealized Amount";"Unrealized Amount")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the unrealized VAT amount for this line if you use unrealized VAT.';
                }
                field("Unrealized Base";"Unrealized Base")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the unrealized base amount if you use unrealized VAT.';
                }
                field("External Document No.";"External Document No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("VAT Bus. Posting Group";"VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group";"VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Registration No.";"VAT Registration No.")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the VAT registration number of the customer or vendor that the VAT entry is linked to.';
                }
            }
        }
    }

    actions
    {
    }
}

