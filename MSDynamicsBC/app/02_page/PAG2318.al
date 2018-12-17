page 2318 "BC O365 Sales Customer Card"
{
    // version NAVW113.00

    Caption = 'Customer';
    DataCaptionExpression = Name;
    PageType = Card;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Importance = Promoted;
                    ToolTip = 'Specifies the customer''s name.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord;
                    end;
                }
                field("Contact Type";"Contact Type")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    OptionCaption = 'Company contact,Person';
                    ToolTip = 'Specifies if the contact is a company or a person.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
            }
            group("Contact & Address")
            {
                Caption = 'Contact & Address';
                group(ContactDetails)
                {
                    Caption = 'Contact';
                    field("E-Mail";"E-Mail")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Email Address';
                        ExtendedDatatype = EMail;
                        Importance = Promoted;
                        ToolTip = 'Specifies the customer''s email address.';

                        trigger OnValidate()
                        var
                            MailManagement: Codeunit "Mail Management";
                        begin
                            if "E-Mail" <> '' then
                              MailManagement.CheckValidEmailAddress("E-Mail");
                        end;
                    }
                    field("Phone No.";"Phone No.")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Phone Number';
                        Importance = Promoted;
                        ToolTip = 'Specifies the customer''s telephone number.';
                    }
                }
                group(AddressDetails)
                {
                    Caption = 'Address';
                    field(Address;Address)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                    }
                    field("Address 2";"Address 2")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(City;City)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Lookup = false;
                    }
                    field("Post Code";"Post Code")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Lookup = false;
                    }
                    field(County;County)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                    }
                    field(CountryRegionCode;CountryRegionCode)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Country/Region Code';
                        Editable = CurrPageEditable;
                        Lookup = true;
                        LookupPageID = "BC O365 Country/Region List";
                        TableRelation = "Country/Region";
                        ToolTip = 'Specifies the country/region of the address.';

                        trigger OnValidate()
                        begin
                            CountryRegionCode := O365SalesInvoiceMgmt.FindCountryCodeFromInput(CountryRegionCode);
                            "Country/Region Code" := CountryRegionCode;
                        end;
                    }
                    field(ShowMap;ShowMapLbl)
                    {
                        ApplicationArea = Basic,Suite;
                        Editable = false;
                        ShowCaption = false;
                        Style = StrongAccent;
                        StyleExpr = TRUE;
                        ToolTip = 'Specifies the customer''s address on your preferred map website.';

                        trigger OnDrillDown()
                        begin
                            CurrPage.Update(true);
                            DisplayMap;
                        end;
                    }
                    field(LanguageName;LanguageName)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        Caption = 'Preferred Language';
                        Importance = Promoted;
                        QuickEntry = false;
                        ToolTip = 'Specifies the preferred language for the contact.';
                        Visible = false;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupLanguage;
                        end;

                        trigger OnValidate()
                        var
                            LanguageManagement: Codeunit LanguageManagement;
                            NewLanguageCode: Code[10];
                        begin
                            NewLanguageCode :=
                              LanguageManagement.GetLanguageCodeFromLanguageID(
                                LanguageManagement.GetWindowsLanguageIDFromLanguageName(LanguageName));
                            if NewLanguageCode <> '' then
                              "Language Code" := NewLanguageCode;
                            UpdateLanguageCodeOnUnpostedDocuments;
                            CurrPage.Update;
                        end;
                    }
                }
            }
            group("Sales and Payments")
            {
                Caption = 'Sales and Payments';
                Visible = SalesAndPaymentsVisible;
                group(Control16)
                {
                    ShowCaption = false;
                    Visible = NOT TotalsHidden;
                    field("Balance (LCY)";"Balance (LCY)")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = '1';
                        AutoFormatType = 10;
                        Caption = 'Outstanding';
                        DrillDown = false;
                        Importance = Promoted;
                        Lookup = false;
                        ToolTip = 'Specifies the customer''s balance.';
                    }
                    field(OverdueAmount;OverdueAmount)
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = '1';
                        AutoFormatType = 10;
                        Caption = 'Overdue';
                        DrillDown = false;
                        Editable = false;
                        Lookup = false;
                        Style = Unfavorable;
                        StyleExpr = OverdueAmount > 0;
                        ToolTip = 'Specifies payments from the customer that are overdue per today''s date.';
                    }
                    field("Sales (LCY)";"Sales (LCY)")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                        AutoFormatExpression = '1';
                        AutoFormatType = 10;
                        Caption = 'Total Sales (Excl. VAT)';
                        DrillDown = false;
                        Lookup = false;
                        ToolTip = 'Specifies the total net amount of sales to the customer in LCY.';
                    }
                }
                group(Control13)
                {
                    ShowCaption = false;
                    Visible = ("Contact Type" = "Contact Type"::Company) AND IsUsingVAT;
                    field("VAT Registration No.";"VAT Registration No.")
                    {
                        ApplicationArea = Basic,Suite,Invoicing;
                    }
                }
            }
            group("Tax Information")
            {
                Caption = 'Tax';
                Visible = NOT IsUsingVAT;
                field("Tax Liable";"Tax Liable")
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    ToolTip = 'Specifies if the sales invoice contains sales tax.';
                }
                field(TaxAreaDescription;TaxAreaDescription)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Tax Rate';
                    Editable = false;
                    Enabled = CurrPageEditable;
                    Importance = Promoted;
                    NotBlank = true;
                    QuickEntry = false;
                    ToolTip = 'Specifies the customer''s tax area.';

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

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        TaxArea: Record "Tax Area";
                    begin
                        if PAGE.RunModal(PAGE::"O365 Tax Area List",TaxArea) = ACTION::LookupOK then begin
                          Validate("Tax Area Code",TaxArea.Code);
                          TaxAreaDescription := TaxArea.GetDescriptionInCurrentLanguage;
                        end;
                    end;
                }
            }
            group(Status)
            {
                Caption = 'Status';
                Visible = BlockedStatus;
                field(BlockedStatus;BlockedStatus)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Blocked';
                    ToolTip = 'Specifies if you want to block the customer for any further business.';

                    trigger OnValidate()
                    begin
                        if not BlockedStatus then
                          if Confirm(UnblockCustomerQst) then begin
                            Validate(Blocked,Blocked::" ");
                            if not ContBusRel.FindByRelation(ContBusRel."Link to Table"::Customer,"No.") then
                              CustContUpdate.OnInsert(Rec)
                          end else
                            BlockedStatus := true
                        else
                          Validate(Blocked,Blocked::All)
                    end;
                }
            }
            group(Privacy)
            {
                InstructionalText = 'Export customer privacy data in an Excel file and email it to yourself for review before sending it to the customer.';
                field(ExportData;ExportDataLbl)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Editable = false;
                    Importance = Promoted;
                    ShowCaption = false;

                    trigger OnDrillDown()
                    begin
                        SetRecFilter;
                        PAGE.RunModal(PAGE::"O365 Export Customer Data",Rec);
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(Control50;"Customer Picture")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                SubPageLink = "No."=FIELD("No.");
            }
            part(SalesHistSelltoFactBox;"BC O365 Hist. Sell-to FactBox")
            {
                ApplicationArea = Basic,Suite,Invoicing;
                Caption = 'Sales History';
                SubPageLink = "No."=FIELD("No."),
                              "Currency Filter"=FIELD("Currency Filter"),
                              "Date Filter"=FIELD("Date Filter"),
                              "Global Dimension 1 Filter"=FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter"=FIELD("Global Dimension 2 Filter");
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        TaxArea: Record "Tax Area";
        LanguageManagement: Codeunit LanguageManagement;
    begin
        CreateCustomerFromTemplate;

        OverdueAmount := CalcOverdueBalance;

        if TaxArea.Get("Tax Area Code") then
          TaxAreaDescription := TaxArea.GetDescriptionInCurrentLanguage;

        BlockedStatus := IsBlocked;

        // Supergroup is visible only if one of the two subgroups is visible
        SalesAndPaymentsVisible := (not TotalsHidden) or
          (("Contact Type" = "Contact Type"::Company) and IsUsingVAT);

        LanguageName := LanguageManagement.GetWindowsLanguageNameFromLanguageCode("Language Code");
        CountryRegionCode := "Country/Region Code";
        CurrPageEditable := CurrPage.Editable;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        O365SalesManagement.BlockOrDeleteCustomerAndDeleteContact(Rec);
        exit(false);
    end;

    trigger OnInit()
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
    begin
        if O365SalesInitialSetup.Get then
          IsUsingVAT := O365SalesInitialSetup.IsUsingVAT;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Name = '' then
          CustomerCardState := CustomerCardState::Prompt
        else
          CustomerCardState := CustomerCardState::Keep;

        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Name = '' then
          CustomerCardState := CustomerCardState::Prompt
        else
          CustomerCardState := CustomerCardState::Keep;

        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        OnNewRec;
    end;

    trigger OnOpenPage()
    begin
        SetRange("Date Filter",0D,WorkDate);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        exit(CanExitAfterProcessingCustomer);
    end;

    var
        ContBusRel: Record "Contact Business Relation";
        CustContUpdate: Codeunit "CustCont-Update";
        O365SalesManagement: Codeunit "O365 Sales Management";
        O365SalesInvoiceMgmt: Codeunit "O365 Sales Invoice Mgmt";
        CustomerCardState: Option Keep,Delete,Prompt;
        NewMode: Boolean;
        IsUsingVAT: Boolean;
        OverdueAmount: Decimal;
        TaxAreaDescription: Text[50];
        TotalsHidden: Boolean;
        SalesAndPaymentsVisible: Boolean;
        LanguageName: Text;
        ClosePageQst: Label 'You haven''t specified a name. Do you want to save this customer?';
        CountryRegionCode: Code[10];
        BlockedStatus: Boolean;
        UnblockCustomerQst: Label 'Are you sure you want to unblock the customer for further business?';
        ExportDataLbl: Label 'Export customer privacy data';
        ShowMapLbl: Label 'Show on Map';
        CurrPageEditable: Boolean;

    local procedure CanExitAfterProcessingCustomer(): Boolean
    begin
        if "No." = '' then
          exit(true);

        if CustomerCardState = CustomerCardState::Delete then
          exit(DeleteCustomerRelatedData);

        if GuiAllowed and (CustomerCardState = CustomerCardState::Prompt) and not IsBlocked
        then begin
          if Confirm(ClosePageQst,true) then
            exit(true);
          exit(DeleteCustomerRelatedData);
        end;

        exit(true);
    end;

    local procedure DeleteCustomerRelatedData(): Boolean
    begin
        CustContUpdate.DeleteCustomerContacts(Rec);

        // workaround for bug: delete for new empty record returns false
        if Delete(true) then;
        exit(true);
    end;

    local procedure OnNewRec()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        if GuiAllowed and DocumentNoVisibility.CustomerNoSeriesIsDefault then
          NewMode := true;
    end;

    local procedure CreateCustomerFromTemplate()
    var
        MiniCustomerTemplate: Record "Mini Customer Template";
        Customer: Record Customer;
    begin
        if NewMode then begin
          if MiniCustomerTemplate.NewCustomerFromTemplate(Customer) then
            Copy(Customer);

          TotalsHidden := true;

          CustomerCardState := CustomerCardState::Delete;
          NewMode := false;
          CurrPage.Update;
        end;
    end;

    local procedure LookupLanguage()
    var
        Language: Record Language;
        LanguageManagement: Codeunit LanguageManagement;
        LanguageID: Integer;
    begin
        if "Language Code" <> '' then
          if not Language.Get("Language Code") then
            Language."Windows Language ID" := WindowsLanguage;
        LanguageID := Language."Windows Language ID";
        LanguageManagement.LookupApplicationLanguage(LanguageID);
        Language.SetRange("Windows Language ID",LanguageID);
        if Language.FindFirst then
          "Language Code" := Language.Code
        else
          "Language Code" := '';

        UpdateLanguageCodeOnUnpostedDocuments;
        CurrPage.Update;
    end;

    local procedure UpdateLanguageCodeOnUnpostedDocuments()
    var
        SalesHeader: Record "Sales Header";
    begin
        if "Language Code" = xRec."Language Code" then
          exit;
        SalesHeader.SetRange("Bill-to Customer No.","No.");
        SalesHeader.ModifyAll("Language Code","Language Code");
    end;
}

