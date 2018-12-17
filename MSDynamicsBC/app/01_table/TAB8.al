table 8 Language
{
    // version NAVW111.00

    Caption = 'Language';
    LookupPageID = Languages;

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(6;"Windows Language ID";Integer)
        {
            BlankZero = true;
            Caption = 'Windows Language ID';
            TableRelation = "Windows Language";

            trigger OnValidate()
            begin
                CalcFields("Windows Language Name");
            end;
        }
        field(7;"Windows Language Name";Text[80])
        {
            CalcFormula = Lookup("Windows Language".Name WHERE ("Language ID"=FIELD("Windows Language ID")));
            Caption = 'Windows Language Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;Name)
        {
        }
    }

    [Scope('Personalization')]
    procedure GetUserLanguage(): Code[10]
    var
        UserLanguageId: Integer;
        Handled: Boolean;
    begin
        OnGetUserLanguageId(UserLanguageId,Handled);

        if not Handled then
          UserLanguageId := GlobalLanguage;

        exit(GetLanguageCode(UserLanguageId));
    end;

    [Scope('Personalization')]
    procedure GetLanguageID(LanguageCode: Code[10]): Integer
    begin
        Clear(Rec);
        if LanguageCode <> '' then
          if Get(LanguageCode) then
            exit("Windows Language ID");
        "Windows Language ID" := GlobalLanguage;
        exit("Windows Language ID");
    end;

    [Scope('Personalization')]
    procedure GetUserSelectedLanguageId(): Integer
    var
        UserPersonalization: Record "User Personalization";
        BlankGuid: Guid;
        LanguageId: Integer;
    begin
        UserPersonalization.SetRange("User ID",UserId);
        if not UserPersonalization.FindFirst then begin
          UserPersonalization.SetRange("User ID",BlankGuid);
          if not UserPersonalization.FindFirst then;
        end;

        LanguageId := UserPersonalization."Language ID";
        if LanguageId = 0 then
          LanguageId := GlobalLanguage;

        exit(LanguageId);
    end;

    local procedure GetLanguageCode(LanguageId: Integer): Code[10]
    begin
        Clear(Rec);
        SetRange("Windows Language ID",LanguageId);
        if FindFirst then;
        SetRange("Windows Language ID");
        exit(Code);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetUserLanguageId(var UserLanguageId: Integer;var Handled: Boolean)
    begin
    end;
}

