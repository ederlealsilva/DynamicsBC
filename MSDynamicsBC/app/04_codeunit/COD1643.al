codeunit 1643 "Hyperlink Manifest"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasePayablesSetup: Record "Purchases & Payables Setup";
        AddInManifestManagement: Codeunit "Add-in Manifest Management";
        OfficeHostType: DotNet OfficeHostType;
        AddinNameTxt: Label 'Document View';
        AddinDescriptionTxt: Label 'Provides a link directly to business documents in %1.', Comment='%1 - Application Name';
        ManifestVersionTxt: Label '2.0.0.0', Locked=true;
        AppIdTxt: Label 'cf6f2e6a-5f76-4a17-b966-2ed9d0b3e88a', Locked=true;
        PurchaseOrderAcronymTxt: Label 'PO', Comment='US acronym for Purchase Order';

    procedure SetHyperlinkAddinTriggers(var ManifestText: Text)
    var
        RegExText: Text;
    begin
        // First add the number series rules
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPostedSalesInvoice),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForSalesInvoice),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPostedSalesCrMemo),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPostedPurchInvoice),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPostedPurchCrMemo),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPurchaseInvoice),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPurchaseOrder),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForSalesCrMemo),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForSalesOrder),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForSalesQuote),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPurchaseQuote),RegExText);
        RegExText := AddPrefixesToRegex(GetNoSeriesPrefixes(GetNoSeriesForPurchaseCrMemo),RegExText);

        // Wrap the prefixes in parenthesis to group them and fill out the rest of the RegEx:
        if RegExText <> '' then begin
          RegExText := StrSubstNo('(%1)([0-9]+)',RegExText);
          AddInManifestManagement.AddRegExRuleNode(ManifestText,'No.Series',RegExText);
        end;

        // Now add the text-based rules
        RegExText := 'invoice|order|quote|credit memo';
        RegExText += '|' + GetNameForSalesInvoice;
        RegExText += '|' + GetNameForPurchaseInvoice;
        RegExText += '|' + GetNameForPurchaseOrder;
        RegExText += '|' + GetAcronymForPurchaseOrder;
        RegExText += '|' + GetNameForSalesCrMemo;
        RegExText += '|' + GetNameForSalesOrder;
        RegExText += '|' + GetNameForSalesQuote;
        RegExText += '|' + GetNameForPurchaseQuote;
        RegExText += '|' + GetNameForPurchaseCrMemo;

        RegExText :=
          StrSubstNo('(%1):? ?#?(%2)',RegExText,GetNumberSeriesRegex);
        AddInManifestManagement.AddRegExRuleNode(ManifestText,'DocumentTypes',RegExText);
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPurchaseCrMemo(): Code[20]
    begin
        PurchasePayablesSetup.Get;
        exit(PurchasePayablesSetup."Credit Memo Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPurchaseQuote(): Code[20]
    begin
        PurchasePayablesSetup.Get;
        exit(PurchasePayablesSetup."Quote Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPurchaseInvoice(): Code[20]
    begin
        PurchasePayablesSetup.Get;
        exit(PurchasePayablesSetup."Invoice Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPurchaseOrder(): Code[20]
    begin
        PurchasePayablesSetup.Get;
        exit(PurchasePayablesSetup."Order Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForSalesCrMemo(): Code[20]
    begin
        SalesReceivablesSetup.Get;
        exit(SalesReceivablesSetup."Credit Memo Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForSalesInvoice(): Code[20]
    begin
        SalesReceivablesSetup.Get;
        exit(SalesReceivablesSetup."Invoice Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForSalesOrder(): Code[20]
    begin
        SalesReceivablesSetup.Get;
        exit(SalesReceivablesSetup."Order Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForSalesQuote(): Code[20]
    begin
        SalesReceivablesSetup.Get;
        exit(SalesReceivablesSetup."Quote Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPostedSalesInvoice(): Code[20]
    begin
        SalesReceivablesSetup.Get;
        exit(SalesReceivablesSetup."Posted Invoice Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPostedSalesCrMemo(): Code[20]
    begin
        SalesReceivablesSetup.Get;
        exit(SalesReceivablesSetup."Posted Credit Memo Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPostedPurchInvoice(): Code[20]
    begin
        PurchasePayablesSetup.Get;
        exit(PurchasePayablesSetup."Posted Invoice Nos.");
    end;

    [Scope('Personalization')]
    procedure GetNoSeriesForPostedPurchCrMemo(): Code[20]
    begin
        PurchasePayablesSetup.Get;
        exit(PurchasePayablesSetup."Posted Credit Memo Nos.");
    end;

    procedure GetPrefixForNoSeriesLine(var NoSeriesLine: Record "No. Series Line"): Code[20]
    var
        NumericRegEx: DotNet Regex;
        RegExMatches: DotNet MatchCollection;
        SeriesStartNo: Code[20];
        MatchText: Text;
        LowerMatchBound: Integer;
    begin
        SeriesStartNo := NoSeriesLine."Starting No.";

        // Ensure that we have a non-numeric 'prefix' before the numbers and that we capture the last number group.
        // This ensures that we can generate a specific RegEx and not match all number sequences.

        NumericRegEx := NumericRegEx.Regex('[\p{Lu}\p{Lt}\p{Lo}\p{Lm}\p{Pc}' + RegExEscape('\_/#*+|-') + ']([0-9]+)$');
        RegExMatches := NumericRegEx.Matches(SeriesStartNo);

        // If we don't have a match, then the code is unusable for a RegEx as a number series
        if RegExMatches.Count = 0 then
          exit('');

        MatchText := RegExMatches.Item(RegExMatches.Count - 1).Groups.Item(1).Value; // Get the number group from the match.
        LowerMatchBound := RegExMatches.Item(RegExMatches.Count - 1).Groups.Item(1).Index + 1 ; // Get the index of the group, adjust indexing for NAV.

        // Remove the number match - leaving only the prefix
        SeriesStartNo := DelStr(SeriesStartNo,LowerMatchBound,StrLen(MatchText));

        exit(SeriesStartNo);
    end;

    procedure GetNoSeriesPrefixes(NoSeriesCode: Code[20]): Text
    var
        NoSeriesLine: Record "No. Series Line";
        NewPrefix: Text;
        Prefixes: Text;
    begin
        // For the given series code - get the prefix for each line
        NoSeriesLine.SetRange("Series Code",NoSeriesCode);
        if NoSeriesLine.Find('-') then
          repeat
            NewPrefix := GetPrefixForNoSeriesLine(NoSeriesLine);
            if NewPrefix <> '' then
              if Prefixes = '' then
                Prefixes := RegExEscape(NewPrefix)
              else
                Prefixes := StrSubstNo('%1|%2',Prefixes,RegExEscape(NewPrefix));
          until NoSeriesLine.Next = 0;

        exit(Prefixes);
    end;

    local procedure AddPrefixesToRegex(Prefixes: Text;RegExText: Text): Text
    begin
        // Handles some logic around concatenating the prefixes together in a regex string
        if Prefixes <> '' then
          if RegExText = '' then
            RegExText := Prefixes
          else
            RegExText := StrSubstNo('%1|%2',RegExText,Prefixes);
        exit(RegExText);
    end;

    [Scope('Personalization')]
    procedure GetNameForPurchaseCrMemo(): Text
    var
        PurchaseCreditMemo: Page "Purchase Credit Memo";
    begin
        exit(PurchaseCreditMemo.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForPurchaseInvoice(): Text
    var
        PurchaseInvoice: Page "Purchase Invoice";
    begin
        exit(PurchaseInvoice.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForPurchaseOrder(): Text
    var
        PurchaseOrder: Page "Purchase Order";
    begin
        exit(PurchaseOrder.Caption);
    end;

    [Scope('Personalization')]
    procedure GetAcronymForPurchaseOrder(): Text
    begin
        exit(PurchaseOrderAcronymTxt);
    end;

    [Scope('Personalization')]
    procedure GetNameForPurchaseQuote(): Text
    var
        PurchaseQuote: Page "Purchase Quote";
    begin
        exit(PurchaseQuote.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForSalesCrMemo(): Text
    var
        SalesCreditMemo: Page "Sales Credit Memo";
    begin
        exit(SalesCreditMemo.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForSalesInvoice(): Text
    var
        SalesInvoice: Page "Sales Invoice";
    begin
        exit(SalesInvoice.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForSalesOrder(): Text
    var
        SalesOrder: Page "Sales Order";
    begin
        exit(SalesOrder.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForSalesQuote(): Text
    var
        SalesQuote: Page "Sales Quote";
    begin
        exit(SalesQuote.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForPostedSalesInvoice(): Text
    var
        PostedSalesInvoices: Page "Posted Sales Invoices";
    begin
        exit(PostedSalesInvoices.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForPostedSalesCrMemo(): Text
    var
        PostedSalesCreditMemos: Page "Posted Sales Credit Memos";
    begin
        exit(PostedSalesCreditMemos.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForPostedPurchInvoice(): Text
    var
        PostedPurchaseInvoices: Page "Posted Purchase Invoices";
    begin
        exit(PostedPurchaseInvoices.Caption);
    end;

    [Scope('Personalization')]
    procedure GetNameForPostedPurchCrMemo(): Text
    var
        PostedPurchaseCreditMemos: Page "Posted Purchase Credit Memos";
    begin
        exit(PostedPurchaseCreditMemos.Caption);
    end;

    local procedure RegExEscape(RegExText: Text): Text
    var
        RegEx: DotNet Regex;
    begin
        // Function to escape some special characters in a regular expression character class:
        exit(RegEx.Escape(RegExText));
    end;

    [Scope('Personalization')]
    procedure GetNumberSeriesRegex(): Text
    begin
        exit(StrSubstNo('[\w%1]*[0-9]+',RegExEscape('_/#*+\|-')));
    end;

    [EventSubscriber(ObjectType::Codeunit, 1652, 'CreateDefaultAddins', '', false, false)]
    local procedure OnCreateAddin(var OfficeAddin: Record "Office Add-in")
    begin
        if OfficeAddin.Get(AppIdTxt) then
          OfficeAddin.Delete;

        with AddInManifestManagement do
          CreateAddin(OfficeAddin,DefaultManifestText,AddinNameTxt,StrSubstNo(AddinDescriptionTxt,PRODUCTNAME.Full),
            AppIdTxt,CODEUNIT::"Hyperlink Manifest");
    end;

    [EventSubscriber(ObjectType::Codeunit, 1652, 'OnGenerateManifest', '', false, false)]
    local procedure OnGenerateManifest(var OfficeAddin: Record "Office Add-in";var ManifestText: Text;CodeunitID: Integer)
    var
        AddinURL: Text;
    begin
        if not CanHandle(CodeunitID) then
          exit;

        ManifestText := OfficeAddin.GetDefaultManifestText;
        AddInManifestManagement.SetCommonManifestItems(ManifestText);
        AddinURL := AddInManifestManagement.ConstructURL(OfficeHostType.OutlookHyperlink,'',ManifestVersionTxt);
        AddInManifestManagement.SetSourceLocationNodes(ManifestText,AddinURL,0);
        AddInManifestManagement.SetSourceLocationNodes(ManifestText,AddinURL,1);

        AddInManifestManagement.RemoveAddInTriggersFromManifest(ManifestText);
        SetHyperlinkAddinTriggers(ManifestText);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1652, 'GetAddin', '', false, false)]
    local procedure OnGetAddin(var OfficeAddin: Record "Office Add-in";CodeunitID: Integer)
    begin
        if CanHandle(CodeunitID) then
          OfficeAddin.Get(AppIdTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1652, 'GetAddinID', '', false, false)]
    local procedure OnGetAddinID(var ID: Text;CodeunitID: Integer)
    begin
        if CanHandle(CodeunitID) then
          ID := AppIdTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1652, 'GetAddinVersion', '', false, false)]
    local procedure OnGetAddinVersion(var Version: Text;CodeunitID: Integer)
    begin
        if CanHandle(CodeunitID) then
          Version := ManifestVersionTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, 1652, 'GetManifestCodeunit', '', false, false)]
    local procedure OnGetCodeunitID(var CodeunitID: Integer;HostType: Text)
    var
        OfficeHostType: DotNet OfficeHostType;
    begin
        with OfficeHostType do
          if HostType in [OutlookHyperlink] then
            CodeunitID := CODEUNIT::"Hyperlink Manifest";
    end;

    local procedure CanHandle(CodeunitID: Integer): Boolean
    begin
        exit(CodeunitID = CODEUNIT::"Hyperlink Manifest");
    end;

    local procedure DefaultManifestText() Value: Text
    begin
        Value :=
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<OfficeApp xsi:type="MailApp" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
          ' xmlns="http://schemas.microsoft.com/office/appforoffice/1.1">' +
          '  <Id>' + AppIdTxt + '</Id>' +
          '  <Version>' + ManifestVersionTxt + '</Version>' +
          '  <ProviderName>Microsoft</ProviderName>' +
          '  <DefaultLocale>en-US</DefaultLocale>' +
          '  <DisplayName DefaultValue="' + AddinNameTxt + '" />' +
          '  <Description DefaultValue="' +
          StrSubstNo(AddinDescriptionTxt,AddInManifestManagement.XMLEncode(PRODUCTNAME.Full)) + '" />' +
          '  <IconUrl DefaultValue="WEBCLIENTLOCATION/Resources/Images/OfficeAddinLogo.png"/>' +
          '  <HighResolutionIconUrl DefaultValue="WEBCLIENTLOCATION/Resources/Images/OfficeAddinLogoHigh.png"/>' +
          '  <AppDomains>' +
          '    <AppDomain>WEBCLIENTLOCATION</AppDomain>' +
          '  </AppDomains>' +
          '  <Hosts>' +
          '    <Host Name="Mailbox" />' +
          '  </Hosts>' +
          '  <Requirements>' +
          '    <Sets>' +
          '      <Set Name="MailBox" MinVersion="1.1" />' +
          '    </Sets>' +
          '  </Requirements>' +
          '  <FormSettings>' +
          '    <Form xsi:type="ItemRead">' +
          '      <DesktopSettings>' +
          '        <SourceLocation DefaultValue="" />' +
          '        <RequestedHeight>300</RequestedHeight>' +
          '      </DesktopSettings>' +
          '      <TabletSettings>' +
          '        <SourceLocation DefaultValue="" />' +
          '        <RequestedHeight>300</RequestedHeight>' +
          '      </TabletSettings>' +
          '      <PhoneSettings>' +
          '        <SourceLocation DefaultValue="" />' +
          '      </PhoneSettings>' +
          '    </Form>' +
          '    <Form xsi:type="ItemEdit">' +
          '      <DesktopSettings>' +
          '        <SourceLocation DefaultValue="" />' +
          '      </DesktopSettings>' +
          '      <TabletSettings>' +
          '        <SourceLocation DefaultValue="" />' +
          '      </TabletSettings>' +
          '      <PhoneSettings>' +
          '        <SourceLocation DefaultValue="" />' +
          '      </PhoneSettings>' +
          '    </Form>' +
          '  </FormSettings>' +
          '  <Permissions>ReadWriteMailbox</Permissions>' +
          '  <Rule xsi:type="RuleCollection" Mode="And">' +
          '    <Rule xsi:type="RuleCollection" Mode="Or">' +
          '      <!-- To add more complex rules, add additional rule elements -->' +
          '      <!-- E.g. To activate when a message contains an address -->' +
          '      <!-- <Rule xsi:type="ItemHasKnownEntity" EntityType="Address" /> -->' +
          '    </Rule>' +
          '    <Rule xsi:type="RuleCollection" Mode="Or">' +
          '      <Rule xsi:type="ItemIs" FormType="Edit" ItemType="Message" />' +
          '      <Rule xsi:type="ItemIs" FormType="Read" ItemType="Message" />' +
          '    </Rule>' +
          '' +
          '  </Rule>' +
          '</OfficeApp>';
    end;
}

