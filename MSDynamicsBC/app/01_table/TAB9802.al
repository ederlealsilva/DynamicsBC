table 9802 "Permission Set Link"
{
    // version NAVW113.00

    Caption = 'Permission Set Link';
    DataPerCompany = false;
    Permissions = TableData "Permission Set Link"=rmd;

    fields
    {
        field(1;"Permission Set ID";Code[20])
        {
            Caption = 'Permission Set ID';
            DataClassification = SystemMetadata;
            TableRelation = "Permission Set"."Role ID";
        }
        field(2;"Linked Permission Set ID";Code[20])
        {
            Caption = 'Linked Permission Set ID';
            DataClassification = SystemMetadata;
            TableRelation = "Tenant Permission Set"."Role ID";
        }
        field(3;"Source Hash";Text[250])
        {
            Caption = 'Source Hash';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Permission Set ID","Linked Permission Set ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SourceHashHasChanged(): Boolean
    begin
        MarkWithChangedSource;
        exit(not IsEmpty);
    end;

    [Scope('Personalization')]
    procedure UpdateSourceHashesOnAllLinks()
    var
        PermissionSet: Record "Permission Set";
    begin
        if FindSet then
          repeat
            if PermissionSet.Get("Permission Set ID") then begin
              "Source Hash" := PermissionSet.Hash;
              Modify;
            end else
              Delete;
          until Next = 0;
    end;

    [Scope('Personalization')]
    procedure MarkWithChangedSource()
    var
        PermissionSet: Record "Permission Set";
        SourceChanged: Boolean;
    begin
        if FindSet then
          repeat
            SourceChanged := false;
            if PermissionSet.Get("Permission Set ID") then
              SourceChanged := "Source Hash" <> PermissionSet.Hash
            else
              SourceChanged := true;
            if SourceChanged then
              Mark(true);
          until Next = 0;
        MarkedOnly(true);
    end;

    [Scope('Personalization')]
    procedure GetSourceForLinkedPermissionSet(LinkedPermissionSetId: Code[20]): Code[20]
    begin
        SetRange("Linked Permission Set ID",LinkedPermissionSetId);
        if FindFirst then
          exit("Permission Set ID");
    end;
}

