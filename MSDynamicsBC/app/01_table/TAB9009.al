table 9009 "Permission Set Buffer"
{
    // version NAVW113.00

    Caption = 'Permission Set Buffer';
    DataPerCompany = false;

    fields
    {
        field(1;Scope;Option)
        {
            Caption = 'Scope';
            DataClassification = SystemMetadata;
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
        }
        field(2;"App ID";Guid)
        {
            Caption = 'App ID';
            DataClassification = SystemMetadata;
        }
        field(3;"Role ID";Code[20])
        {
            Caption = 'Role ID';
            DataClassification = SystemMetadata;
        }
        field(4;Name;Text[30])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(5;"App Name";Text[250])
        {
            Caption = 'App Name';
            DataClassification = SystemMetadata;
        }
        field(6;Type;Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'User-Defined,Extension,System';
            OptionMembers = "User-Defined",Extension,System;
        }
    }

    keys
    {
        key(Key1;Type,"Role ID")
        {
        }
    }

    fieldgroups
    {
    }

    var
        IsTempErr: Label '%1 should only be used as a temperory record.', Comment='%1 table caption';

    procedure SetType()
    begin
        Type := GetType(Scope,"App ID");
    end;

    [Scope('Personalization')]
    procedure GetType(ScopeOpt: Option;AppID: Guid): Integer
    begin
        case true of
          (ScopeOpt = Scope::Tenant) and IsNullGuid(AppID):
            exit(Type::"User-Defined");
          ScopeOpt = Scope::Tenant:
            exit(Type::Extension);
          else
            exit(Type::System);
        end;
    end;

    procedure FillRecordBuffer()
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        if not IsTemporary then
          Error(IsTempErr,TableCaption);

        DeleteAll;
        if AggregatePermissionSet.FindSet then
          repeat
            Init;
            "App ID" := AggregatePermissionSet."App ID";
            "Role ID" := AggregatePermissionSet."Role ID";
            Name := AggregatePermissionSet.Name;
            "App Name" := AggregatePermissionSet."App Name";
            Scope := AggregatePermissionSet.Scope;
            SetType;
            Insert;
          until AggregatePermissionSet.Next = 0;
    end;
}

