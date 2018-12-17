page 476 "Copy Tax Setup"
{
    // version NAVW113.00

    Caption = 'Copy Tax Setup';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field("SourceCompany.Name";SourceCompany.Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'From Company';
                    Lookup = true;
                    LookupPageID = Companies;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        SourceCompany.SetFilter(Name,'<>%1',CompanyName);
                        if PAGE.RunModal(PAGE::Companies,SourceCompany) = ACTION::LookupOK then
                          if SourceCompany.Name = CompanyName then begin
                            SourceCompany.Name := '';
                            Error(Text000);
                          end;
                    end;
                }
                field(CopyMode;CopyMode)
                {
                    ApplicationArea = Basic,Suite;
                    OptionCaption = 'Copy All Setup Information,Copy Selected Information:';

                    trigger OnValidate()
                    begin
                        if CopyMode = CopyMode::Custom then
                          CustomCopyModeOnValidate;
                        if CopyMode = CopyMode::All then
                          AllCopyModeOnValidate;
                    end;
                }
                field(TaxGroups;CopyTable[1])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Tax Groups';
                    Enabled = TaxGroupsEnable;

                    trigger OnValidate()
                    begin
                        CopyTable1OnPush;
                    end;
                }
                field(TaxJurisdictions;CopyTable[2])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Tax Jurisdictions';
                    Enabled = TaxJurisdictionsEnable;

                    trigger OnValidate()
                    begin
                        CopyTable2OnPush;
                    end;
                }
                field(TaxAreas;CopyTable[3])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Tax Areas';
                    Enabled = TaxAreasEnable;

                    trigger OnValidate()
                    begin
                        CopyTable3OnPush;
                    end;
                }
                field(TaxDetail;CopyTable[4])
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Tax Detail';
                    Enabled = TaxDetailEnable;

                    trigger OnValidate()
                    begin
                        CopyTable4OnPush;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        TaxDetailEnable := true;
        TaxAreasEnable := true;
        TaxJurisdictionsEnable := true;
        TaxGroupsEnable := true;
    end;

    trigger OnOpenPage()
    begin
        for i := 1 to ArrayLen(CopyTable) do
          CopyTable[i] := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK,ACTION::LookupOK] then
          OKOnPush;
    end;

    var
        Text000: Label 'You must select a company other than the current company.';
        Text001: Label 'You must select a company from which to copy.';
        Text002: Label 'Nothing was selected to copy.\You must select one or more tables to copy.';
        SourceCompany: Record Company;
        CopyTaxSetup: Codeunit "Copy Tax Setup From Company";
        CopyTable: array [4] of Boolean;
        i: Integer;
        CopyMode: Option All,Custom;
        [InDataSet]
        TaxGroupsEnable: Boolean;
        [InDataSet]
        TaxJurisdictionsEnable: Boolean;
        [InDataSet]
        TaxAreasEnable: Boolean;
        [InDataSet]
        TaxDetailEnable: Boolean;

    local procedure CopyTable1OnPush()
    begin
        CopyMode := CopyMode::Custom;
    end;

    local procedure CopyTable2OnPush()
    begin
        CopyMode := CopyMode::Custom;
    end;

    local procedure CopyTable3OnPush()
    begin
        CopyMode := CopyMode::Custom;
    end;

    local procedure CopyTable4OnPush()
    begin
        CopyMode := CopyMode::Custom;
    end;

    local procedure AllCopyModeOnPush()
    begin
        for i := 1 to ArrayLen(CopyTable) do
          CopyTable[i] := true;
    end;

    local procedure CustomCopyModeOnPush()
    begin
        TaxGroupsEnable := true;
        TaxJurisdictionsEnable := true;
        TaxAreasEnable := true;
        TaxDetailEnable := true;
    end;

    local procedure OKOnPush()
    begin
        if SourceCompany.Name = '' then
          Error(Text001);

        if not CopyTable[1] and not CopyTable[2] and not CopyTable[3] and not CopyTable[4] then
          Error(Text002);

        CopyTaxSetup.CopyTaxInfo(SourceCompany,CopyTable);
    end;

    local procedure AllCopyModeOnValidate()
    begin
        AllCopyModeOnPush;
    end;

    local procedure CustomCopyModeOnValidate()
    begin
        CustomCopyModeOnPush;
    end;
}

