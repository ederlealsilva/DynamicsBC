table 5460 "Graph Business Setting"
{
    // version NAVW113.00

    Caption = 'Graph Business Setting';
    ExternalName = 'BusinessSetting';
    TableType = MicrosoftGraph;

    fields
    {
        field(1;Id;Text[250])
        {
            Caption = 'Id';
            ExternalName = 'id';
            ExternalType = 'Edm.String';
        }
        field(2;Scope;Text[250])
        {
            Caption = 'Name';
            ExternalName = 'scope';
            ExternalType = 'Edm.String';
        }
        field(3;Name;Text[250])
        {
            Caption = 'Name';
            ExternalName = 'name';
            ExternalType = 'Edm.String';
        }
        field(4;Data;BLOB)
        {
            Caption = 'Data';
            ExternalName = 'data';
            ExternalType = 'Microsoft.Griffin.SmallBusiness.SbGraph.Core.SettingsData';
            SubType = Json;
        }
        field(5;SecondaryKey;Text[250])
        {
            Caption = 'SecondaryKey';
            ExternalName = 'secondaryKey';
            ExternalType = 'Edm.String';
        }
        field(6;CreatedDate;DateTime)
        {
            Caption = 'CreatedDate';
            ExternalName = 'createdDate';
            ExternalType = 'Edm.DateTimeOffset';
        }
        field(7;LastModifiedDate;DateTime)
        {
            Caption = 'LastModifiedDate';
            ExternalName = 'lastModifiedDate';
            ExternalType = 'Edm.DateTimeOffset';
        }
        field(8;ETag;Text[250])
        {
            Caption = 'ETag';
            ExternalName = '@odata.etag';
            ExternalType = 'Edm.String';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetDataString(): Text
    begin
        exit(GetBlobString(FieldNo(Data)));
    end;

    local procedure GetBlobString(FieldNo: Integer): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetBlobString(Rec,FieldNo));
    end;
}

