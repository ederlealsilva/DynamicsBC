codeunit 2850 "Native API - Language Handler"
{
    // version NAVW113.00

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        ClashWhileSettingTheLanguageTxt: Label 'Clash while setting the language. Something else is trying to change langauge at the same time.', Locked=true;
        LanguageFound: Boolean;
        CachedLanguageID: Integer;

    [EventSubscriber(ObjectType::Table, 8, 'OnGetUserLanguageId', '', false, false)]
    local procedure InvoicingAPIGetUserLanguageHandler(var UserLanguageId: Integer;var Handled: Boolean)
    var
        Language: Record Language;
    begin
        // Breaking handled pattern here - API subscriber must win, log a clash
        if Handled then
          SendTraceTag(
            '00001LJ','NativeInvoicingLanguageHanlder',VERBOSITY::Error,
            ClashWhileSettingTheLanguageTxt,DATACLASSIFICATION::SystemMetadata);

        // Performance optimization - Calling GetUserSelectedLanguageId is creating 1-2 SQL queries each time
        if not LanguageFound then begin
          CachedLanguageID := Language.GetUserSelectedLanguageId;
          LanguageFound := true;
        end;

        UserLanguageId := CachedLanguageID;
        Handled := true;
    end;
}

