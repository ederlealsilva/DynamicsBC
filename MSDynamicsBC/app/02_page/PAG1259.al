page 1259 "Bank Name - Data Conv. List"
{
    // version NAVW113.00

    Caption = 'Bank Name - Data Conv. List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Page,Setup';
    SourceTable = "Bank Data Conv. Bank";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Bank;Bank)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the bank, and potentially its country/region code, that supports your setup for import/export of bank data using the Bank Data Conversion Service feature.';
                }
                field("Bank Name";"Bank Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the bank that supports your setup for import/export of bank data using the Bank Data Conversion Service feature.';
                }
                field("Country/Region Code";"Country/Region Code")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("Last Update Date";"Last Update Date")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the last time the list of supported banks was updated.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(UpdateBankList)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Update Bank Name List';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Category4;
                ShortCutKey = 'Ctrl+F5';
                ToolTip = 'Update the bank list with any new banks in your country/region.';

                trigger OnAction()
                var
                    ImpBankListExtDataHndl: Codeunit "Imp. Bank List Ext. Data Hndl";
                    FilterNotUsed: Text;
                    ShowErrors: Boolean;
                begin
                    ShowErrors := true;
                    ImpBankListExtDataHndl.GetBankListFromConversionService(ShowErrors,FilterNotUsed,LongTimeout);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        ShortTimeout := 5000;
        LongTimeout := 30000;
    end;

    trigger OnOpenPage()
    var
        ImpBankListExtDataHndl: Codeunit "Imp. Bank List Ext. Data Hndl";
        CountryRegionCode: Text;
        HideErrors: Boolean;
    begin
        CountryRegionCode := IdentifyCountryRegionCode(Rec,GetFilter("Country/Region Code"));

        if IsEmpty then begin
          ImpBankListExtDataHndl.GetBankListFromConversionService(HideErrors,CountryRegionCode,ShortTimeout);
          exit;
        end;

        RefreshBankNamesOlderThanToday(CountryRegionCode,HideErrors,ShortTimeout);
    end;

    var
        LongTimeout: Integer;
        ShortTimeout: Integer;

    local procedure IdentifyCountryRegionCode(var BankDataConvBank: Record "Bank Data Conv. Bank";"Filter": Text): Text
    var
        CompanyInformation: Record "Company Information";
        BlankFilter: Text;
    begin
        BlankFilter := '''''';

        if Filter = BlankFilter then begin
          CompanyInformation.Get;
          BankDataConvBank.SetFilter("Country/Region Code",CompanyInformation."Country/Region Code");
          exit(BankDataConvBank.GetFilter("Country/Region Code"));
        end;

        exit(Filter);
    end;

    local procedure RefreshBankNamesOlderThanToday(CountryRegionCode: Text;ShowErrors: Boolean;Timeout: Integer)
    var
        BankDataConvBank: Record "Bank Data Conv. Bank";
        ImpBankListExtDataHndl: Codeunit "Imp. Bank List Ext. Data Hndl";
    begin
        if CountryRegionCode <> '' then
          BankDataConvBank.SetFilter("Country/Region Code",CountryRegionCode);
        BankDataConvBank.SetFilter("Last Update Date",'<%1',Today);
        if BankDataConvBank.FindFirst then
          ImpBankListExtDataHndl.GetBankListFromConversionService(ShowErrors,CountryRegionCode,Timeout);
    end;
}

