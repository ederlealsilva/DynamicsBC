codeunit 1900 "Template Selection Mgt."
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure SaveCustTemplateSelectionForCurrentUser(TemplateCode: Code[10])
    begin
        SaveTemplateSelectionForCurrentUser(TemplateCode,GetCustomerTemplateSelectionCode);
    end;

    [Scope('Personalization')]
    procedure GetLastCustTemplateSelection(var TemplateCode: Code[10]): Boolean
    begin
        exit(GetLastTemplateSelection(TemplateCode,GetCustomerTemplateSelectionCode));
    end;

    [Scope('Personalization')]
    procedure SaveVendorTemplateSelectionForCurrentUser(TemplateCode: Code[10])
    begin
        SaveTemplateSelectionForCurrentUser(TemplateCode,GetVendorTemplateSelectionCode);
    end;

    [Scope('Personalization')]
    procedure GetLastVendorTemplateSelection(var TemplateCode: Code[10]): Boolean
    begin
        exit(GetLastTemplateSelection(TemplateCode,GetVendorTemplateSelectionCode));
    end;

    [Scope('Personalization')]
    procedure SaveItemTemplateSelectionForCurrentUser(TemplateCode: Code[10])
    begin
        SaveTemplateSelectionForCurrentUser(TemplateCode,GetItemTemplateSelectionCode);
    end;

    [Scope('Personalization')]
    procedure GetLastItemTemplateSelection(var TemplateCode: Code[10]): Boolean
    begin
        exit(GetLastTemplateSelection(TemplateCode,GetItemTemplateSelectionCode));
    end;

    [Scope('Personalization')]
    procedure GetCustomerTemplateSelectionCode(): Code[20]
    begin
        exit('LASTCUSTTEMPSEL');
    end;

    [Scope('Personalization')]
    procedure GetVendorTemplateSelectionCode(): Code[20]
    begin
        exit('LASTVENDTEMPSEL');
    end;

    [Scope('Personalization')]
    procedure GetItemTemplateSelectionCode(): Code[20]
    begin
        exit('LASTITEMTEMPSEL');
    end;

    local procedure SaveTemplateSelectionForCurrentUser(TemplateCode: Code[10];ContextCode: Code[20])
    var
        UserPreference: Record "User Preference";
    begin
        if UserPreference.Get(UserId,ContextCode) then
          UserPreference.Delete;

        UserPreference.Init;
        UserPreference."User ID" := UserId;
        UserPreference."Instruction Code" := ContextCode;
        UserPreference.SetUserSelection(TemplateCode);
        UserPreference.Insert;
    end;

    local procedure GetLastTemplateSelection(var TemplateCode: Code[10];ContextCode: Code[20]): Boolean
    var
        UserPreference: Record "User Preference";
    begin
        if not UserPreference.Get(UserId,ContextCode) then
          exit(false);

        UserPreference.CalcFields("User Selection");
        TemplateCode := CopyStr(UserPreference.GetUserSelectionAsText,1,MaxStrLen(TemplateCode));
        exit(true);
    end;
}

