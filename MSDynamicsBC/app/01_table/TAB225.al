table 225 "Post Code"
{
    // version NAVW113.00

    Caption = 'Post Code';
    LookupPageID = "Post Codes";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                PostCode.SetRange("Search City","Search City");
                PostCode.SetRange(Code,Code);
                if not PostCode.IsEmpty then
                  Error(Text000,FieldCaption(Code),Code);
            end;
        }
        field(2;City;Text[30])
        {
            Caption = 'City';
            NotBlank = true;

            trigger OnValidate()
            var
                PostCode: Record "Post Code";
            begin
                TestField(Code);
                "Search City" := City;
                if xRec."Search City" <> "Search City" then begin
                  PostCode.SetRange("Search City","Search City");
                  PostCode.SetRange(Code,Code);
                  if not PostCode.IsEmpty then
                    Error(Text000,FieldCaption(City),City);
                end;
            end;
        }
        field(3;"Search City";Code[30])
        {
            Caption = 'Search City';
        }
        field(4;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(5;County;Text[30])
        {
            Caption = 'County';
        }
    }

    keys
    {
        key(Key1;"Code",City)
        {
        }
        key(Key2;City,"Code")
        {
        }
        key(Key3;"Search City")
        {
        }
        key(Key4;"Country/Region Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Code",City,"Country/Region Code",County)
        {
        }
        fieldgroup(Brick;"Code",City,County,"Country/Region Code")
        {
        }
    }

    var
        Text000: Label '%1 %2 already exists.';

    [Scope('Personalization')]
    procedure ValidateCity(var City: Text[30];var PostCode: Code[20];var County: Text[30];var CountryCode: Code[10];UseDialog: Boolean)
    var
        PostCodeRec: Record "Post Code";
        PostCodeRec2: Record "Post Code";
        SearchCity: Code[30];
    begin
        if not GuiAllowed then
          exit;

        if City <> '' then begin
          SearchCity := City;
          PostCodeRec.SetCurrentKey("Search City");
          if StrPos(SearchCity,'*') = StrLen(SearchCity) then
            PostCodeRec.SetFilter("Search City",SearchCity)
          else
            PostCodeRec.SetRange("Search City",SearchCity);
          if not PostCodeRec.FindFirst then
            exit;

          if CountryCode <> '' then begin
            PostCodeRec.SetRange("Country/Region Code",CountryCode);
            if not PostCodeRec.FindFirst then
              PostCodeRec.SetRange("Country/Region Code");
          end;

          PostCodeRec2.Copy(PostCodeRec);
          if UseDialog and (PostCodeRec2.Next = 1) then
            if PAGE.RunModal(PAGE::"Post Codes",PostCodeRec,PostCodeRec.Code) <> ACTION::LookupOK then
              Error('');
          PostCode := PostCodeRec.Code;
          City := PostCodeRec.City;
          CountryCode := PostCodeRec."Country/Region Code";
          County := PostCodeRec.County;
        end;
    end;

    [Scope('Personalization')]
    procedure ValidatePostCode(var City: Text[30];var PostCode: Code[20];var County: Text[30];var CountryCode: Code[10];UseDialog: Boolean)
    var
        PostCodeRec: Record "Post Code";
        PostCodeRec2: Record "Post Code";
    begin
        if PostCode <> '' then begin
          if StrPos(PostCode,'*') = StrLen(PostCode) then
            PostCodeRec.SetFilter(Code,PostCode)
          else
            PostCodeRec.SetRange(Code,PostCode);
          if not PostCodeRec.FindFirst then
            exit;

          if CountryCode <> '' then begin
            PostCodeRec.SetRange("Country/Region Code",CountryCode);
            if not PostCodeRec.FindFirst then
              PostCodeRec.SetRange("Country/Region Code");
          end;

          PostCodeRec2.Copy(PostCodeRec);
          if UseDialog and (PostCodeRec2.Next = 1) and GuiAllowed then
            if PAGE.RunModal(PAGE::"Post Codes",PostCodeRec,PostCodeRec.Code) <> ACTION::LookupOK then
              exit;
          PostCode := PostCodeRec.Code;
          City := PostCodeRec.City;
          CountryCode := PostCodeRec."Country/Region Code";
          County := PostCodeRec.County;
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateFromSalesHeader(SalesHeader: Record "Sales Header";PostCodeChanged: Boolean)
    begin
        CreatePostCode(SalesHeader."Sell-to Post Code",SalesHeader."Sell-to City",
          SalesHeader."Sell-to Country/Region Code",SalesHeader."Sell-to County",PostCodeChanged);
    end;

    [Scope('Personalization')]
    procedure UpdateFromCustomer(Customer: Record Customer;PostCodeChanged: Boolean)
    begin
        CreatePostCode(Customer."Post Code",Customer.City,
          Customer."Country/Region Code",Customer.County,PostCodeChanged);
    end;

    [Scope('Personalization')]
    procedure UpdateFromCompanyInformation(CompanyInformation: Record "Company Information";PostCodeChanged: Boolean)
    begin
        CreatePostCode(CompanyInformation."Post Code",CompanyInformation.City,
          CompanyInformation."Country/Region Code",CompanyInformation.County,PostCodeChanged);
    end;

    [Scope('Personalization')]
    procedure UpdateFromStandardAddress(StandardAddress: Record "Standard Address";PostCodeChanged: Boolean)
    begin
        CreatePostCode(StandardAddress."Post Code",StandardAddress.City,
          StandardAddress."Country/Region Code",StandardAddress.County,PostCodeChanged);
    end;

    local procedure CreatePostCode(NewPostCode: Code[20];NewCity: Text[30];NewCountryRegion: Code[10];NewCounty: Text[30];PostCodeChanged: Boolean)
    begin
        if NewPostCode = '' then
          exit;

        SetRange(Code,NewPostCode);
        if FindFirst then begin
          if PostCodeChanged then
            exit; // If the post code was updated, then don't insert the city for the old post code into the new post code
          if (NewCity <> '') and (City <> NewCity) then
            Rename(NewPostCode,NewCity);
          if NewCountryRegion <> '' then
            "Country/Region Code" := NewCountryRegion;
          if NewCounty <> '' then
            County := NewCounty;
          Modify;
        end else begin
          Init;

          Code := NewPostCode;
          City := NewCity;
          "Country/Region Code" := NewCountryRegion;
          County := NewCounty;
          Insert;
        end;
    end;

    [Scope('Personalization')]
    procedure ValidateCountryCode(var CityTxt: Text[30];var PostCode: Code[20];var CountyTxt: Text[30];var CountryCode: Code[10])
    var
        PostCodeRec: Record "Post Code";
    begin
        if xRec."Country/Region Code" = CountryCode then
          exit;
        if (CountryCode = '') or (PostCode = '') then
          exit;

        PostCodeRec.SetRange("Country/Region Code",CountryCode);
        PostCodeRec.SetRange(Code,PostCode);
        if PostCodeRec.FindFirst then begin
          PostCode := PostCodeRec.Code;
          CityTxt := PostCodeRec.City;
          CountryCode := PostCodeRec."Country/Region Code";
          CountyTxt := PostCodeRec.County;
        end;
    end;
}

