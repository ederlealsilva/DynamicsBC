table 6710 "Tenant Web Service OData"
{
    // version NAVW113.00

    Caption = 'Tenant Web Service OData';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;TenantWebServiceID;RecordID)
        {
            Caption = 'TenantWebServiceID';
            DataClassification = SystemMetadata;
        }
        field(2;ODataSelectClause;BLOB)
        {
            Caption = 'ODataSelectClause';
        }
        field(3;ODataFilterClause;BLOB)
        {
            Caption = 'ODataFilterClause';
        }
        field(4;ODataV4FilterClause;BLOB)
        {
            Caption = 'ODataV4FilterClause';
        }
    }

    keys
    {
        key(Key1;TenantWebServiceID)
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetOdataSelectClause(ODataText: Text)
    var
        WriteStream: OutStream;
    begin
        Clear(ODataSelectClause);
        ODataSelectClause.CreateOutStream(WriteStream);
        WriteStream.WriteText(ODataText);
    end;

    [Scope('Personalization')]
    procedure GetOdataSelectClause(): Text
    var
        ReadStream: InStream;
        ODataText: Text;
    begin
        CalcFields(ODataSelectClause);
        ODataSelectClause.CreateInStream(ReadStream);
        ReadStream.ReadText(ODataText);
        exit(ODataText);
    end;

    [Scope('Personalization')]
    procedure SetOdataFilterClause(ODataText: Text)
    var
        WriteStream: OutStream;
    begin
        Clear(ODataFilterClause);
        ODataFilterClause.CreateOutStream(WriteStream);
        WriteStream.WriteText(ODataText);
    end;

    [Scope('Personalization')]
    procedure SetOdataV4FilterClause(ODataText: Text)
    var
        WriteStream: OutStream;
    begin
        Clear(ODataV4FilterClause);
        ODataV4FilterClause.CreateOutStream(WriteStream);
        WriteStream.WriteText(ODataText);
    end;

    [Scope('Personalization')]
    procedure GetOdataFilterClause(): Text
    var
        ReadStream: InStream;
        ODataText: Text;
    begin
        CalcFields(ODataFilterClause);
        ODataFilterClause.CreateInStream(ReadStream);
        ReadStream.ReadText(ODataText);
        exit(ODataText);
    end;

    [Scope('Personalization')]
    procedure GetOdataV4FilterClause(): Text
    var
        ReadStream: InStream;
        ODataText: Text;
    begin
        CalcFields(ODataV4FilterClause);
        ODataV4FilterClause.CreateInStream(ReadStream);
        ReadStream.ReadText(ODataText);
        exit(ODataText);
    end;
}

