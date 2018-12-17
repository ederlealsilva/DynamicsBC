page 2511 "Extension Settings"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Extension Settings';
    DataCaptionExpression = AppName;
    PageType = Card;
    SourceTable = "NAV App Setting";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(AppId;AppId)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'App ID';
                    Editable = false;
                    ToolTip = 'Specifies the App ID of the extension.';
                }
                field(AppName;AppName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(AppPublisher;AppPublisher)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Publisher';
                    Editable = false;
                    ToolTip = 'Specifies the publisher of the extension.';
                }
                field(AllowHttpClientRequests;"Allow HttpClient Requests")
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Allow HttpClient Requests';
                    ToolTip = 'Specifies whether the runtime should allow this extension to make HTTP requests through the HttpClient data type when running in a non-production environment.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        NAVApp: Record "NAV App";
    begin
        NAVApp.SetRange(ID,"App ID");

        if NAVApp.FindFirst then begin
          AppName := NAVApp.Name;
          AppPublisher := NAVApp.Publisher;
          AppId := LowerCase(DelChr(Format(NAVApp.ID),'=','{}'));
        end
    end;

    trigger OnOpenPage()
    begin
        if GetFilter("App ID") = '' then
          exit;

        "App ID" := GetRangeMin("App ID");
        if not FindFirst then begin
          Init;
          Insert;
        end;
    end;

    var
        AppName: Text;
        AppPublisher: Text;
        AppId: Text;
}

