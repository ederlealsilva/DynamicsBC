table 6712 "Tenant Web Service Filter"
{
    // version NAVW113.00

    Caption = 'Tenant Web Service Filter';
    DataPerCompany = false;

    fields
    {
        field(1;"Entry ID";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry ID';
        }
        field(2;"Filter";BLOB)
        {
            Caption = 'Filter';
        }
        field(3;TenantWebServiceID;RecordID)
        {
            Caption = 'TenantWebServiceID';
            DataClassification = SystemMetadata;
        }
        field(4;"Data Item";Integer)
        {
            Caption = 'Data Item';
        }
    }

    keys
    {
        key(Key1;"Entry ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetFilter(FilterText: Text)
    var
        WriteStream: OutStream;
    begin
        Clear(Filter);
        Filter.CreateOutStream(WriteStream);
        WriteStream.WriteText(FilterText);
    end;

    procedure GetFilter(): Text
    var
        ReadStream: InStream;
        FilterText: Text;
    begin
        CalcFields(Filter);
        Filter.CreateInStream(ReadStream);
        ReadStream.ReadText(FilterText);
        exit(FilterText);
    end;

    procedure CreateFromRecordRef(var RecRef: RecordRef;TenantWebServiceRecordId: RecordID)
    begin
        SetRange(TenantWebServiceID,TenantWebServiceRecordId);
        DeleteAll;

        Init;
        "Entry ID" := 0;
        "Data Item" := RecRef.Number;
        TenantWebServiceID := TenantWebServiceRecordId;
        SetFilter(RecRef.GetView);
        Insert;
    end;
}

