page 2020 "Image Analysis Setup"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Image Analysis Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    Permissions = TableData "Cortana Intelligence Usage"=rimd;
    ShowFilter = false;
    SourceTable = "Image Analysis Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Api Uri";"Api Uri")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'API URI';
                    ToolTip = 'Specifies the API URI for the Computer Vision account to use with Microsoft Cognitive Services.';

                    trigger OnValidate()
                    begin
                        if ("Api Uri" <> '') and (ApiKey <> '') then
                          SetInfiniteAccess;
                    end;
                }
                field("<Api Key>";ApiKey)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the API key for the Computer Vision account to use with Microsoft Cognitive Services.';

                    trigger OnValidate()
                    begin
                        SetApiKey(ApiKey);

                        if ("Api Uri" <> '') and (ApiKey <> '') then
                          SetInfiniteAccess;
                    end;
                }
                field(LimitType;LimitType)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Limit Type';
                    Editable = false;
                    ToolTip = 'Specifies the unit of time to limit the usage of the Computer Vision service.';
                }
                field(LimitValue;LimitValue)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Limit Value';
                    Editable = false;
                    ToolTip = 'Specifies the number of images that can be analyzed per unit of time.';
                }
                field(NumberOfCalls;NumberOfCalls)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Analyses Performed';
                    Editable = false;
                    ToolTip = 'Specifies the number of images that have been analyzed per unit of time.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SetupAction)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Computer Vision API Documentation';
                Image = LinkWeb;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Set up a Computer Vision account with Microsoft Cognitive Services to do image analysis with Dynamics 365.';

                trigger OnAction()
                begin
                    HyperLink('https://go.microsoft.com/fwlink/?linkid=848400');
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    begin
        GetSingleInstance;
        if GetApiKey <> '' then
          ApiKey := '***';
        if ("Api Uri" <> '') and (ApiKey <> '') then
          CortanaIntelligenceUsage.SetImageAnalysisIsSetup(true)
        else
          CortanaIntelligenceUsage.SetImageAnalysisIsSetup(false);

        CortanaIntelligenceUsage.GetSingleInstance(CortanaIntelligenceUsage.Service::"Computer Vision");
        LimitType := CortanaIntelligenceUsage."Limit Period";
        LimitValue := CortanaIntelligenceUsage."Original Resource Limit";
        NumberOfCalls := CortanaIntelligenceUsage."Total Resource Usage";
    end;

    var
        ApiKey: Text;
        LimitType: Option Year,Month,Day,Hour;
        LimitValue: Integer;
        NumberOfCalls: Integer;

    local procedure SetInfiniteAccess()
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    begin
        CortanaIntelligenceUsage.SetImageAnalysisIsSetup(true);
        CortanaIntelligenceUsage.GetSingleInstance(CortanaIntelligenceUsage.Service::"Computer Vision");
        LimitType := CortanaIntelligenceUsage."Limit Period"::Year;
        CortanaIntelligenceUsage."Limit Period" := CortanaIntelligenceUsage."Limit Period"::Year;

        LimitValue := 999;
        CortanaIntelligenceUsage."Original Resource Limit" := 999;
        CortanaIntelligenceUsage.Modify;
    end;
}

