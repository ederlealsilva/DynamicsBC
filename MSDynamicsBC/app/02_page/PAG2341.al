page 2341 "BC O365 Sales Quote"
{
    // version NAVW113.00

    Caption = 'Estimate';
    DataCaptionExpression = '';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Manage';
    RefreshOnActivate = true;
    SourceTable = "Sales Header";
    SourceTableView = WHERE("Document Type"=CONST(Quote));

    layout
    {
        area(content)
        {
            group("Sell to")
            {
                Caption = 'Sell to';
                field("Sell-to Customer Name";"Sell-to Customer Name")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Customer Name';
                    Importance = Promoted;
                    LookupPageID = "BC O365 Contact Lookup";
                    NotBlank = true;
                    QuickEntry = false;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the customer''s name.';

                    trigger OnValidate()
                    begin
                        O365SalesInvoiceMgmt.ValidateCustomerName(Rec,CustomerName,CustomerEmail);
                        O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);

                        CurrPage.Update(true);
                    end;
                }
                field(CustomerEmail;CustomerEmail)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Email Address';
                    Editable = CurrPageEditable AND (CustomerName <> '');
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the customer''s email address.';

                    trigger OnValidate()
                    begin
                        O365SalesInvoiceMgmt.ValidateCustomerEmail(Rec,CustomerEmail);
                    end;
                }
                field("Quote Accepted";"Quote Accepted")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Customer accepted';
                    Editable = CurrPageEditable AND (CustomerName <> '');
                    ToolTip = 'Specifies whether the customer has accepted the quote or not.';
                }
                group(Control10)
                {
                    ShowCaption = false;
                    field(ViewContactCard;ViewContactDetailsLbl)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Editable = false;
                        Enabled = CustomerName <> '';
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            O365SalesInvoiceMgmt.EditCustomerCardFromSalesHeader(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                }
                group(Control58)
                {
                    ShowCaption = false;
                    field("Sell-to Address";"Sell-to Address")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Address';
                        Editable = CustomerName <> '';
                        ToolTip = 'Specifies the address where the customer is located.';

                        trigger OnValidate()
                        begin
                            O365SalesInvoiceMgmt.ValidateCustomerAddress("Sell-to Address","Sell-to Customer No.");
                            O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                    field("Sell-to Address 2";"Sell-to Address 2")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Address 2';
                        Editable = CustomerName <> '';
                        ToolTip = 'Specifies additional address information.';

                        trigger OnValidate()
                        begin
                            O365SalesInvoiceMgmt.ValidateCustomerAddress2("Sell-to Address 2","Sell-to Customer No.");
                            O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                    field("Sell-to City";"Sell-to City")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'City';
                        Editable = CustomerName <> '';
                        Lookup = false;
                        ToolTip = 'Specifies the address city.';

                        trigger OnValidate()
                        begin
                            O365SalesInvoiceMgmt.ValidateCustomerCity("Sell-to City","Sell-to Customer No.");
                            O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                    field("Sell-to Post Code";"Sell-to Post Code")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Post Code';
                        Editable = CustomerName <> '';
                        Lookup = false;
                        ToolTip = 'Specifies the postal code.';

                        trigger OnValidate()
                        begin
                            O365SalesInvoiceMgmt.ValidateCustomerPostCode("Sell-to Post Code","Sell-to Customer No.");
                            O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                    field("Sell-to County";"Sell-to County")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'County';
                        Editable = CustomerName <> '';
                        Lookup = false;
                        ToolTip = 'Specifies the address county.';

                        trigger OnValidate()
                        begin
                            O365SalesInvoiceMgmt.ValidateCustomerCounty("Sell-to County","Sell-to Customer No.");
                            O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                    field(CountryRegionCode;CountryRegionCode)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Country/Region Code';
                        Editable = CurrPageEditable AND (CustomerName <> '');
                        Lookup = true;
                        LookupPageID = "BC O365 Country/Region List";
                        TableRelation = "Country/Region";
                        ToolTip = 'Specifies the address country/region.';

                        trigger OnValidate()
                        begin
                            CountryRegionCode := O365SalesInvoiceMgmt.FindCountryCodeFromInput(CountryRegionCode);
                            "Sell-to Country/Region Code" := CountryRegionCode;
                            O365SalesInvoiceMgmt.ValidateCustomerCountryRegion("Sell-to Country/Region Code","Sell-to Customer No.");
                            O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);
                        end;
                    }
                }
            }
            group("Estimate Details")
            {
                Caption = 'Estimate Details';
                field(EstimateNoControl;"No.")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Estimate No.';
                    Editable = false;
                    ToolTip = 'Specifies the number of the estimate.';
                }
                field("Quote Valid Until Date";"Quote Valid Until Date")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Valid until';
                    Editable = CustomerName <> '';
                    ToolTip = 'Specifies how long the quote is valid.';
                }
                field("Quote Sent to Customer";"Quote Sent to Customer")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Sent';
                    ToolTip = 'Specifies date and time of when the quote was sent to the customer.';
                }
                field("Quote Accepted Date";"Quote Accepted Date")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Accepted on';
                    ToolTip = 'Specifies when the client accepted the quote.';
                }
                field("Tax Liable";"Tax Liable")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Customer is tax liable';
                    Editable = CustomerName <> '';
                    ToolTip = 'Specifies if the sales invoice contains sales tax.';
                    Visible = NOT IsUsingVAT;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field(TaxAreaDescription;TaxAreaDescription)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Customer tax rate';
                    Editable = false;
                    Enabled = CustomerName <> '';
                    NotBlank = true;
                    QuickEntry = false;
                    ToolTip = 'Specifies the customer''s tax area.';
                    Visible = NOT IsUsingVAT;

                    trigger OnAssistEdit()
                    var
                        TaxArea: Record "Tax Area";
                    begin
                        if PAGE.RunModal(PAGE::"O365 Tax Area List",TaxArea) = ACTION::LookupOK then begin
                          Validate("Tax Area Code",TaxArea.Code);
                          TaxAreaDescription := TaxArea.GetDescriptionInCurrentLanguage;
                          CurrPage.Update;
                        end;
                    end;
                }
                field("VAT Registration No.";"VAT Registration No.")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Editable = (IsUsingVAT AND IsCompanyContact);
                    Visible = IsUsingVAT;
                }
            }
            part(Lines;"BC O365 Sales Inv. Line Subp.")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Line Items';
                Editable = CustomerName <> '';
                Enabled = CustomerName <> '';
                SubPageLink = "Document Type"=FIELD("Document Type"),
                              "Document No."=FIELD("No.");
            }
            group(Totals)
            {
                Caption = 'Totals';
                Visible = NOT InvDiscAmountVisible;
                group(Control32)
                {
                    ShowCaption = false;
                    field(Amount;Amount)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = CurrencyFormat;
                        AutoFormatType = 10;
                        Caption = 'Net Total';
                        DrillDown = false;
                        Lookup = false;
                        ToolTip = 'Specifies the total amount on the sales invoice excluding VAT.';
                    }
                    field(AmountInclVAT;"Amount Including VAT")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = CurrencyFormat;
                        AutoFormatType = 10;
                        Caption = 'Total Including VAT';
                        DrillDown = false;
                        Importance = Promoted;
                        Lookup = false;
                        Style = Strong;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the total amount on the sales invoice including VAT.';
                    }
                    field(DiscountLink;DiscountTxt)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        DrillDown = true;
                        Editable = false;
                        Enabled = CustomerName <> '';
                        Importance = Promoted;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            if PAGE.RunModal(PAGE::"O365 Sales Invoice Discount",Rec) = ACTION::LookupOK then
                              CurrPage.Update;
                        end;
                    }
                }
            }
            group(Control20)
            {
                Caption = 'Totals';
                Visible = InvDiscAmountVisible;
                group(Control19)
                {
                    ShowCaption = false;
                    field(SubTotalAmount;SubTotalAmount)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = CurrencyFormat;
                        AutoFormatType = 10;
                        Caption = 'Subtotal';
                        Editable = false;
                        Importance = Promoted;
                    }
                    field(InvoiceDiscount;-InvoiceDiscountAmount)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = CurrencyFormat;
                        AutoFormatType = 10;
                        CaptionClass = GetInvDiscountCaption;
                        Caption = 'Invoice Discount';
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the invoice discount amount. To edit the invoice discount, click on the amount.';

                        trigger OnDrillDown()
                        begin
                            if PAGE.RunModal(PAGE::"O365 Sales Invoice Discount",Rec) = ACTION::LookupOK then
                              CurrPage.Update;
                        end;
                    }
                    field(Amount2;Amount)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = CurrencyFormat;
                        AutoFormatType = 10;
                        Caption = 'Net Total';
                        DrillDown = false;
                        Lookup = false;
                        ToolTip = 'Specifies the total amount on the sales invoice excluding VAT.';
                    }
                    field(AmountInclVAT2;"Amount Including VAT")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = CurrencyFormat;
                        AutoFormatType = 10;
                        Caption = 'Total Including VAT';
                        DrillDown = false;
                        Importance = Promoted;
                        Lookup = false;
                        Style = Strong;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the total amount on the sales invoice including VAT.';
                    }
                }
            }
            group("Note and attachments")
            {
                Caption = 'Note and attachments';
                group(Control36)
                {
                    ShowCaption = false;
                    field(WorkDescription;WorkDescription)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Note for customer';
                        Editable = CurrPageEditable AND (CustomerName <> '');
                        MultiLine = true;
                        ToolTip = 'Specifies the products or service being offered';

                        trigger OnValidate()
                        begin
                            SetWorkDescription(WorkDescription);
                        end;
                    }
                    field(NoOfAttachmentsValueTxt;NoOfAttachmentsValueTxt)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        DrillDown = true;
                        Editable = false;
                        Enabled = CustomerName <> '';
                        Importance = Promoted;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            O365SalesInvoiceMgmt.UpdateNoOfAttachmentsLabel(O365SalesAttachmentMgt.EditAttachments(Rec),NoOfAttachmentsValueTxt);
                            CurrPage.Update(false);
                        end;
                    }
                }
            }
        }
        area(factboxes)
        {
            part(CustomerStatisticsFactBox;"BC O365 Cust. Stats FactBox")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Customer statistics';
                SubPageLink = "No."=FIELD("Sell-to Customer No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ViewPdf)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Preview';
                Enabled = "Sell-to Customer Name" <> '';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Show a preview of the estimate before you send it.';
                Visible = NOT IsCustomerBlocked;

                trigger OnAction()
                var
                    ReportSelections: Record "Report Selections";
                    DocumentPath: Text[250];
                begin
                    SetRecFilter;
                    LockTable;
                    Find;
                    ReportSelections.GetPdfReport(DocumentPath,ReportSelections.Usage::"S.Quote",Rec,"Sell-to Customer No.");
                    Download(DocumentPath,'','','',DocumentPath);
                    Find;
                end;
            }
            action(EmailQuote)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Send';
                Enabled = "Sell-to Customer Name" <> '';
                Gesture = LeftSwipe;
                Image = SendTo;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = NOT IsCustomerBlocked;

                trigger OnAction()
                begin
                    SetRecFilter;

                    if not O365SendResendInvoice.SendSalesInvoiceOrQuoteFromBC(Rec) then
                      exit;

                    Find;
                    CurrPage.Update;
                    ForceExit := true;
                    CurrPage.Close;
                end;
            }
            action(MakeToInvoice)
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Make invoice';
                Enabled = "Sell-to Customer Name" <> '';
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Visible = NOT IsCustomerBlocked;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    if not O365SendResendInvoice.MakeInvoiceFromQuote(SalesHeader,Rec,true) then
                      exit;

                    ForceExit := true;

                    SalesHeader.SetRecFilter;
                    PAGE.Run(PAGE::"BC O365 Sales Invoice",SalesHeader);
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        O365DocumentSendMgt: Codeunit "O365 Document Send Mgt";
    begin
        // Tasks shared with invoices (PAG2310)
        O365SalesInvoiceMgmt.OnAfterGetSalesHeaderRecord(Rec,CurrencyFormat,TaxAreaDescription,NoOfAttachmentsValueTxt,WorkDescription);
        CurrPageEditable := CurrPage.Editable;

        O365SalesInvoiceMgmt.UpdateCustomerFields(Rec,CustomerName,CustomerEmail,IsCompanyContact);
        O365SalesInvoiceMgmt.UpdateAddress(Rec,FullAddress,CountryRegionCode);

        O365SalesInvoiceMgmt.CalcInvoiceDiscountAmount(Rec,SubTotalAmount,DiscountTxt,InvoiceDiscountAmount,InvDiscAmountVisible);

        IsCustomerBlocked := O365SalesInvoiceMgmt.IsCustomerBlocked("Sell-to Customer No.");
        if IsCustomerBlocked then
          O365SalesInvoiceMgmt.SendCustomerHasBeenBlockedNotification("Sell-to Customer Name");

        // Estimate specific tasks
        if ("Sell-to Customer No." = '') and ("Quote Valid Until Date" < WorkDate) then
          "Quote Valid Until Date" := WorkDate + 30;

        O365DocumentSendMgt.ShowSalesHeaderFailedNotification(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
    begin
        ForceExit := true;
        if not Find then begin
          CurrPage.Close;
          exit(false);
        end;

        if CustInvoiceDisc.Get("Invoice Disc. Code","Currency Code",0) then
          CustInvoiceDisc.Delete;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Document Type" := "Document Type"::Quote;
        O365SendResendInvoice.CheckNextNoSeriesIsAvailable("Document Type"::Quote);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(Rec);
        IsNew := true;

        CustomerName := '';
        CustomerEmail := '';
        WorkDescription := '';
        SetDefaultPaymentServices;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        if not IsNew then
          ForceExit := true;

        O365SalesInvoiceMgmt.OnQueryCloseForSalesHeader(Rec,ForceExit,CustomerName);
        IsNew := false;

        exit(Next(Steps));
    end;

    trigger OnOpenPage()
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
    begin
        IsUsingVAT := O365SalesInitialSetup.IsUsingVAT;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not IsNew then
          ForceExit := true;

        exit(O365SalesInvoiceMgmt.OnQueryCloseForSalesHeader(Rec,ForceExit,CustomerName));
    end;

    var
        O365SalesAttachmentMgt: Codeunit "O365 Sales Attachment Mgt";
        O365SendResendInvoice: Codeunit "O365 Send + Resend Invoice";
        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
        CustomerName: Text[50];
        CustomerEmail: Text[80];
        WorkDescription: Text;
        FullAddress: Text;
        CurrPageEditable: Boolean;
        IsUsingVAT: Boolean;
        ForceExit: Boolean;
        InvDiscAmountVisible: Boolean;
        IsCompanyContact: Boolean;
        InvoiceDiscountAmount: Decimal;
        SubTotalAmount: Decimal;
        DiscountTxt: Text;
        NoOfAttachmentsValueTxt: Text;
        CurrencyFormat: Text;
        ViewContactDetailsLbl: Label 'Open contact details';
        TaxAreaDescription: Text[50];
        CountryRegionCode: Code[10];
        IsCustomerBlocked: Boolean;
        IsNew: Boolean;

    procedure SuppressExitPrompt()
    begin
        ForceExit := true;
    end;

    local procedure GetInvDiscountCaption(): Text
    begin
        exit(O365SalesInvoiceMgmt.GetInvoiceDiscountCaption(Round("Invoice Discount Value",0.1)));
    end;
}

