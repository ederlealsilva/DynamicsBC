codeunit 9999 "Upgrade Tag Mgt"
{
    // version NAVW113.00

    // Format of the upgrade tag is:
    // [TFSID]-[Description]-[YYYYMMDD]
    // 
    // Example:
    // 29901-UpdateGLEntriesIntegrationRecordIDs-20161206

    Permissions = TableData "Upgrade Tags"=rimd;

    trigger OnRun()
    begin
    end;

    [Scope('Personalization')]
    procedure HasUpgradeTag(Tag: Code[250]): Boolean
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        exit(UpgradeTags.Get(Tag,CompanyName));
    end;

    [Scope('Personalization')]
    procedure SetUpgradeTag(NewTag: Code[250])
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.Validate(Tag,NewTag);
        UpgradeTags.Validate("Tag Timestamp",CurrentDateTime);
        UpgradeTags.Validate(Company,CompanyName);
        UpgradeTags.Insert(true);
    end;
}

