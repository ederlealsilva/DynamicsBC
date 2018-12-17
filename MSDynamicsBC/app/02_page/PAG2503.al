page 2503 "Extension Installation"
{
    // version NAVW113.00

    Caption = 'Extension Installation';
    PageType = Card;
    SourceTable = "NAV App";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        CurrPage.Close;
    end;

    trigger OnOpenPage()
    var
        MarketplaceExtnDeployment: Page "Marketplace Extn. Deployment";
    begin
        GetDetailsFromFilters;
        ExtensionAppId := ID;
        TelemetryUrl := responseUrl;

        MarketplaceExtnDeployment.SetAppIDAndTelemetryUrl(ExtensionAppId,TelemetryUrl);
        MarketplaceExtnDeployment.Run;
    end;

    var
        ExtensionAppId: Text;
        TelemetryUrl: Text;

    local procedure GetDetailsFromFilters()
    var
        RecRef: RecordRef;
        i: Integer;
    begin
        RecRef.GetTable(Rec);
        for i := 1 to RecRef.FieldCount do
          ParseFilter(RecRef.FieldIndex(i));
        RecRef.SetTable(Rec);
    end;

    local procedure ParseFilter(FieldRef: FieldRef)
    var
        FilterPrefixDotNet_RegEx: Codeunit DotNet_RegEx;
        SingleQuoteDotNet_RegEx: Codeunit DotNet_RegEx;
        EscapedEqualityDotNet_RegEx: Codeunit DotNet_RegEx;
        "Filter": Text;
    begin
        FilterPrefixDotNet_RegEx.Regex('^@\*([^\\]+)\*$');
        SingleQuoteDotNet_RegEx.Regex('^''([^\\]+)''$');
        EscapedEqualityDotNet_RegEx.Regex('~');
        Filter := FieldRef.GetFilter;
        Filter := FilterPrefixDotNet_RegEx.Replace(Filter,'$1');
        Filter := SingleQuoteDotNet_RegEx.Replace(Filter,'$1');
        Filter := EscapedEqualityDotNet_RegEx.Replace(Filter,'=');

        if Filter <> '' then
          FieldRef.Value(Filter);
    end;
}

