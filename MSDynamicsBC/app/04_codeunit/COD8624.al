codeunit 8624 "Setup Company Name"
{
    // version NAVW111.00

    TableNo = "Company Information";

    trigger OnRun()
    begin
        Validate(Name,CompanyName);
        Validate("Ship-to Name",CompanyName);
        Modify;
    end;

    [EventSubscriber(ObjectType::Table, 8631, 'OnDoesTableHaveCustomRuleInRapidStart', '', false, false)]
    procedure CheckCompanyInformationOnDoesTableHaveCustomRuleInRapidStart(TableID: Integer;var Result: Boolean)
    begin
        if TableID = DATABASE::"Company Information" then
          Result := true;
    end;
}

