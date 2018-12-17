codeunit 1634 "Setup Office Host Provider"
{
    // version NAVW110.0


    trigger OnRun()
    begin
        InitSetup;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2, 'OnCompanyInitialize', '', false, false)]
    local procedure InitSetup()
    var
        OfficeAddinSetup: Record "Office Add-in Setup";
    begin
        if not OfficeAddinSetup.IsEmpty then
          exit;

        OfficeAddinSetup.Init;
        OfficeAddinSetup.Insert;
    end;
}

