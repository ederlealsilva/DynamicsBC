table 1506 "Workflow Table Relation Value"
{
    // version NAVW113.00

    Caption = 'Workflow Table Relation Value';
    Permissions = TableData "Workflow Step Instance"=r;
    ReplicateData = false;

    fields
    {
        field(1;"Workflow Step Instance ID";Guid)
        {
            Caption = 'Workflow Step Instance ID';
            TableRelation = "Workflow Step Instance".ID;
        }
        field(2;"Workflow Code";Code[20])
        {
            Caption = 'Workflow Code';
            TableRelation = "Workflow Step Instance"."Workflow Code" WHERE (ID=FIELD("Workflow Step Instance ID"));
        }
        field(3;"Workflow Step ID";Integer)
        {
            Caption = 'Workflow Step ID';
            TableRelation = "Workflow Step Instance"."Workflow Step ID" WHERE (ID=FIELD("Workflow Step Instance ID"),
                                                                               "Workflow Code"=FIELD("Workflow Code"));
        }
        field(4;"Table ID";Integer)
        {
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(5;"Field ID";Integer)
        {
            Caption = 'Field ID';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Table ID"));
        }
        field(6;"Related Table ID";Integer)
        {
            Caption = 'Related Table ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(7;"Related Field ID";Integer)
        {
            Caption = 'Related Field ID';
            TableRelation = Field."No." WHERE (TableNo=FIELD("Related Table ID"));
        }
        field(8;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(9;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Workflow Step Instance ID","Workflow Code","Workflow Step ID","Table ID","Field ID","Related Table ID","Related Field ID")
        {
        }
        key(Key2;"Record ID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure CreateNew(NextStepId: Integer;WorkflowStepInstance: Record "Workflow Step Instance";WorkflowTableRelation: Record "Workflow - Table Relation";RecRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        Init;
        Validate("Workflow Step Instance ID",WorkflowStepInstance.ID);
        Validate("Workflow Code",WorkflowStepInstance."Workflow Code");
        Validate("Workflow Step ID",NextStepId);
        "Table ID" := WorkflowTableRelation."Table ID";
        "Field ID" := WorkflowTableRelation."Field ID";
        "Related Table ID" := WorkflowTableRelation."Related Table ID";
        "Related Field ID" := WorkflowTableRelation."Related Field ID";
        FieldRef := RecRef.Field(WorkflowTableRelation."Field ID");
        Value := FieldRef.Value;
        "Record ID" := RecRef.RecordId;
        Insert;
    end;

    [Scope('Personalization')]
    procedure UpdateRelationValue(RecRef: RecordRef)
    var
        FieldRef: FieldRef;
    begin
        FieldRef := RecRef.Field("Field ID");
        Value := FieldRef.Value;
        "Record ID" := RecRef.RecordId;
        Modify;
    end;
}

