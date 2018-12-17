table 5151 "Integration Record"
{
    // version NAVW113.00

    Caption = 'Integration Record';

    fields
    {
        field(1;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(2;"Page ID";Integer)
        {
            Caption = 'Page ID';
        }
        field(3;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;
        }
        field(5150;"Integration ID";Guid)
        {
            Caption = 'Integration ID';
        }
        field(5151;"Deleted On";DateTime)
        {
            Caption = 'Deleted On';
        }
        field(5152;"Modified On";DateTime)
        {
            Caption = 'Modified On';
        }
    }

    keys
    {
        key(Key1;"Integration ID")
        {
        }
        key(Key2;"Record ID")
        {
        }
        key(Key3;"Page ID","Deleted On")
        {
        }
        key(Key4;"Page ID","Modified On")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if IsNullGuid("Integration ID") then
          "Integration ID" := CreateGuid;

        "Modified On" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Modified On" := CurrentDateTime;
    end;

    [Scope('Personalization')]
    procedure FindByIntegrationId(IntegrationId: Guid): Boolean
    begin
        if IsNullGuid(IntegrationId) then
          exit(false);

        Reset;
        SetRange("Integration ID",IntegrationId);
        exit(FindFirst);
    end;

    [Scope('Personalization')]
    procedure FindByRecordId(FindRecordId: RecordID): Boolean
    begin
        if FindRecordId.TableNo = 0 then
          exit(false);

        Reset;
        SetRange("Record ID",FindRecordId);
        exit(FindFirst);
    end;
}

