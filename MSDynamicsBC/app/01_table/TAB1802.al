table 1802 "Assisted Company Setup Status"
{
    // version NAVW113.00

    Caption = 'Assisted Company Setup Status';
    DataPerCompany = false;

    fields
    {
        field(1;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(2;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                OnEnabled("Company Name",Enabled);
            end;
        }
        field(3;"Package Imported";Boolean)
        {
            Caption = 'Package Imported';
        }
        field(4;"Import Failed";Boolean)
        {
            Caption = 'Import Failed';
        }
        field(5;"Company Setup Session ID";Integer)
        {
            Caption = 'Company Setup Session ID';
        }
        field(6;"Task ID";Guid)
        {
            Caption = 'Task ID';
        }
        field(7;"Server Instance ID";Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetCompanySetupStatus(Name: Text[30]) SetupStatus: Integer
    begin
        if Get(Name) then
          OnGetCompanySetupStatus("Company Name",SetupStatus);
    end;

    procedure DrillDownSetupStatus(Name: Text[30])
    begin
        if Get(Name) then
          OnSetupStatusDrillDown("Company Name");
    end;

    [Scope('Personalization')]
    procedure SetEnabled(CompanyName: Text[30];Enable: Boolean;ResetState: Boolean)
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        if not AssistedCompanySetupStatus.Get(CompanyName) then begin
          AssistedCompanySetupStatus.Init;
          AssistedCompanySetupStatus.Validate("Company Name",CompanyName);
          AssistedCompanySetupStatus.Validate(Enabled,Enable);
          AssistedCompanySetupStatus.Insert;
        end else begin
          AssistedCompanySetupStatus.Validate(Enabled,Enable);
          if ResetState then begin
            AssistedCompanySetupStatus."Package Imported" := false;
            AssistedCompanySetupStatus."Import Failed" := false;
          end;
          AssistedCompanySetupStatus.Modify;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEnabled(SetupCompanyName: Text[30];AssistedSetupEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCompanySetupStatus(Name: Text[30];var SetupStatus: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupStatusDrillDown(Name: Text[30])
    begin
    end;
}

