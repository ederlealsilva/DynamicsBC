table 1875 "Business Setup"
{
    // version NAVW111.00

    Caption = 'Business Setup';
    DataPerCompany = false;

    fields
    {
        field(1;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(2;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(3;Keywords;Text[250])
        {
            Caption = 'Keywords';
        }
        field(4;"Setup Page ID";Integer)
        {
            Caption = 'Setup Page ID';
        }
        field(5;"Area";Option)
        {
            Caption = 'Area';
            OptionCaption = ',General,Finance,Sales,Jobs,Fixed Assets,Purchasing,Reference Data,HR,Inventory,Service,System,Relationship Mngt,Intercompany';
            OptionMembers = ,General,Finance,Sales,Jobs,"Fixed Assets",Purchasing,"Reference Data",HR,Inventory,Service,System,"Relationship Mngt",Intercompany;
        }
        field(7;Icon;Media)
        {
            Caption = 'Icon';
        }
    }

    keys
    {
        key(Key1;Name)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;Description,Name,Icon)
        {
        }
    }

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnRegisterBusinessSetup(var TempBusinessSetup: Record "Business Setup" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnOpenBusinessSetupPage(var TempBusinessSetup: Record "Business Setup" temporary;var Handled: Boolean)
    begin
    end;

    [Scope('Personalization')]
    procedure InsertBusinessSetup(var TempBusinessSetup: Record "Business Setup" temporary;BusinessSetupName: Text[50];BusinessSetupDescription: Text[250];BusinessSetupKeywords: Text[250];BusinessSetupArea: Option;BusinessSetupRunPage: Integer;BusinessSetupIconFileName: Text[50])
    var
        BusinessSetupIcon: Record "Business Setup Icon";
    begin
        if TempBusinessSetup.Get(BusinessSetupName) then
          exit;

        TempBusinessSetup.Init;
        TempBusinessSetup.Name := BusinessSetupName;
        TempBusinessSetup.Description := BusinessSetupDescription;
        TempBusinessSetup.Keywords := BusinessSetupKeywords;
        TempBusinessSetup."Setup Page ID" := BusinessSetupRunPage;
        TempBusinessSetup.Area := BusinessSetupArea;
        TempBusinessSetup.Insert(true);

        if BusinessSetupIcon.Get(BusinessSetupIconFileName) then
          BusinessSetupIcon.GetIcon(TempBusinessSetup);
    end;

    [Scope('Personalization')]
    procedure InsertExtensionBusinessSetup(var TempBusinessSetup: Record "Business Setup" temporary;BusinessSetupName: Text[50];BusinessSetupDescription: Text[250];BusinessSetupKeywords: Text[250];BusinessSetupArea: Option;BusinessSetupRunPage: Integer;ExtensionName: Text[250])
    begin
        if TempBusinessSetup.Get(BusinessSetupName) then
          exit;

        TempBusinessSetup.Init;
        TempBusinessSetup.Name := BusinessSetupName;
        TempBusinessSetup.Description := BusinessSetupDescription;
        TempBusinessSetup.Keywords := BusinessSetupKeywords;
        TempBusinessSetup."Setup Page ID" := BusinessSetupRunPage;
        TempBusinessSetup.Area := BusinessSetupArea;
        TempBusinessSetup.Insert(true);

        AddExtensionIconToBusinessSetup(TempBusinessSetup,ExtensionName);
    end;

    [Scope('Personalization')]
    procedure SetBusinessSetupIcon(var TempBusinessSetup: Record "Business Setup" temporary;IconInStream: InStream)
    var
        BusinessSetupIcon: Record "Business Setup Icon";
    begin
        if not BusinessSetupIcon.Get(TempBusinessSetup.Name) then begin
          BusinessSetupIcon.Init;
          BusinessSetupIcon."Business Setup Name" := TempBusinessSetup.Name;
          BusinessSetupIcon.Insert(true);
          BusinessSetupIcon.SetIconFromInstream(TempBusinessSetup.Name,IconInStream);
        end;

        BusinessSetupIcon.GetIcon(TempBusinessSetup);
    end;

    local procedure AddExtensionIconToBusinessSetup(var TempBusinessSetup: Record "Business Setup" temporary;ExtensionName: Text)
    var
        BusinessSetupIcon: Record "Business Setup Icon";
        NAVApp: Record "NAV App";
        Media: Record Media;
        IconInStream: InStream;
    begin
        if not BusinessSetupIcon.Get(TempBusinessSetup.Name) then begin
          NAVApp.SetRange(Name,ExtensionName);
          if not NAVApp.FindFirst then
            exit;
          Media.SetRange(ID,NAVApp.Logo.MediaId);
          if not Media.FindFirst then
            exit;
          Media.CalcFields(Content);
          Media.Content.CreateInStream(IconInStream);

          BusinessSetupIcon.Init;
          BusinessSetupIcon."Business Setup Name" := TempBusinessSetup.Name;
          BusinessSetupIcon.Icon.ImportStream(IconInStream,TempBusinessSetup.Name);
          if BusinessSetupIcon.Insert(true) then;
        end;

        TempBusinessSetup.Icon := BusinessSetupIcon.Icon;
        if TempBusinessSetup.Modify(true) then;
    end;
}

