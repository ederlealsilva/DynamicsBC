table 6711 "Tenant Web Service Columns"
{
    // version NAVW113.00

    Caption = 'Tenant Web Service Columns';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Entry ID";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry ID';
        }
        field(2;"Data Item";Integer)
        {
            Caption = 'Data Item';
        }
        field(3;"Field Number";Integer)
        {
            Caption = 'Field Number';
        }
        field(4;"Field Name";Text[250])
        {
            Caption = 'Report Caption';
        }
        field(5;TenantWebServiceID;RecordID)
        {
            Caption = 'TenantWebServiceID';
            DataClassification = SystemMetadata;
        }
        field(6;"Data Item Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Table),
                                                                           "Object ID"=FIELD("Data Item")));
            Caption = 'Table';
            FieldClass = FlowField;
        }
        field(7;Include;Boolean)
        {
            Caption = 'Include';
        }
        field(8;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Data Item"),
                                                              "No."=FIELD("Field Number")));
            Caption = 'Field Caption';
            FieldClass = FlowField;
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

    procedure GetTableName(DataItem: Integer): Text
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        AllObjWithCaption."Object Type" := AllObjWithCaption."Object Type"::Table;
        AllObjWithCaption."Object ID" := DataItem;
        if AllObjWithCaption.FindFirst then
          exit(AllObjWithCaption."Object Caption");
    end;

    procedure CreateFromTemp(var TempTenantWebServiceColumns: Record "Tenant Web Service Columns" temporary;TenantWebServiceRecordId: RecordID)
    begin
        if TempTenantWebServiceColumns.FindSet then begin
          SetRange(TenantWebServiceID,TenantWebServiceRecordId);
          DeleteAll;

          repeat
            Init;
            TransferFields(TempTenantWebServiceColumns,true);
            "Entry ID" := 0;
            TenantWebServiceID := TenantWebServiceRecordId;
            Insert;
          until TempTenantWebServiceColumns.Next = 0;
        end;
    end;
}

