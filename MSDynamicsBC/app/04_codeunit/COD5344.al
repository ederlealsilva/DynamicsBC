codeunit 5344 "CRM Product Name"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure SHORT(): Text
    begin
        exit('Dynamics 365 for Sales');
    end;

    [Scope('Personalization')]
    procedure FULL(): Text
    begin
        exit('Microsoft Dynamics 365 for Sales');
    end;
}

