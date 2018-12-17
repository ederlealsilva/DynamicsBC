report 1101 "Resource - List"
{
    // version NAVW113.00

    DefaultLayout = RDLC;
    RDLCLayout = './Resource - List.rdlc';
    ApplicationArea = #Jobs;
    Caption = 'Resource - List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Resource;Resource)
        {
            column(COMPANYNAME;COMPANYPROPERTY.DisplayName)
            {
            }
            column(CurrReport_PAGENO;CurrReport.PageNo)
            {
            }
            column(Resource_TABLECAPTION__________ResFilter;TableCaption + ': ' + ResFilter)
            {
            }
            column(ResFilter;ResFilter)
            {
            }
            column(GetShorDimCodeCaption1;GetShorDimCodeCaption1)
            {
            }
            column(GetShorDimCodeCaption2;GetShorDimCodeCaption2)
            {
            }
            column(Resource__No__;"No.")
            {
            }
            column(Resource_Name;Name)
            {
            }
            column(Resource__Resource_Group_No__;"Resource Group No.")
            {
            }
            column(Resource__Gen__Prod__Posting_Group_;"Gen. Prod. Posting Group")
            {
            }
            column(Resource__Global_Dimension_1_Code_;"Global Dimension 1 Code")
            {
            }
            column(Resource__Global_Dimension_2_Code_;"Global Dimension 2 Code")
            {
            }
            column(Resource___ListCaption;Resource___ListCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption;CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Resource__No__Caption;FieldCaption("No."))
            {
            }
            column(Resource_NameCaption;FieldCaption(Name))
            {
            }
            column(Resource__Resource_Group_No__Caption;FieldCaption("Resource Group No."))
            {
            }
            column(Resource__Gen__Prod__Posting_Group_Caption;FieldCaption("Gen. Prod. Posting Group"))
            {
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GLSetup.Get;

        if Dimension.Get(GLSetup."Shortcut Dimension 1 Code") then
          GetShorDimCodeCaption1 := Dimension."Code Caption"
        else
          GetShorDimCodeCaption1 := Text000;

        if Dimension.Get(GLSetup."Shortcut Dimension 2 Code") then
          GetShorDimCodeCaption2 := Dimension."Code Caption"
        else
          GetShorDimCodeCaption2 := Text001;

        ResFilter := Resource.GetFilters;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Dimension: Record Dimension;
        ResFilter: Text;
        GetShorDimCodeCaption1: Text[80];
        GetShorDimCodeCaption2: Text[80];
        Resource___ListCaptionLbl: Label 'Resource - List';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Text000: Label 'Shortcut Dimension 1 Code', Comment='Shortcut Dimension 1 Code';
        Text001: Label 'Shortcut Dimension 2 Code', Comment='Shortcut Dimension 2 Code';
}

