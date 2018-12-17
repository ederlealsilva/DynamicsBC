table 9004 Plan
{
    // version NAVW113.00

    Caption = 'Subscription Plan';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Plan ID";Guid)
        {
            Caption = 'Plan ID';
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;"Role Center ID";Integer)
        {
            Caption = 'Role Center ID';
        }
    }

    keys
    {
        key(Key1;"Plan ID")
        {
        }
        key(Key2;Name)
        {
        }
    }

    fieldgroups
    {
    }

    var
        BasicPlanGUIDTxt: Label '{7e8e26a8-91a4-4590-961d-d12b61c16a43}', Locked=true;
        EssentialPlanGUIDTxt: Label '{920656a2-7dd8-4c83-97b6-a356414dbd36}', Locked=true;
        PremiumPlanGUIDTxt: Label '{8e9002c0-a1d8-4465-b952-817d2948e6e2}', Locked=true;
        ViralSignupPlanGUIDTxt: Label '{3F2AFEED-6FB5-4BF9-998F-F2912133AEAD}', Locked=true;
        DelegatedAdminGUIDTxt: Label '{00000000-0000-0000-0000-000000000007}', Locked=true;
        InternalAdminGUIDTxt: Label '{62e90394-69f5-4237-9190-012177145e10}', Locked=true;

    procedure GetBasicPlanId(): Guid
    begin
        exit(BasicPlanGUIDTxt);
    end;

    procedure GetEssentialPlanId(): Guid
    begin
        exit(EssentialPlanGUIDTxt);
    end;

    procedure GetPremiumPlanId(): Guid
    begin
        exit(PremiumPlanGUIDTxt);
    end;

    procedure GetViralSignupPlanId(): Guid
    begin
        exit(ViralSignupPlanGUIDTxt);
    end;

    procedure GetDelegatedAdminPlanId(): Guid
    begin
        exit(DelegatedAdminGUIDTxt);
    end;

    procedure GetInternalAdminPlanId(): Guid
    begin
        exit(InternalAdminGUIDTxt);
    end;
}

