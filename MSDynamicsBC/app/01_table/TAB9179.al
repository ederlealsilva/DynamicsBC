table 9179 "Application Area Buffer"
{
    // version NAVW113.00

    Caption = 'Application Area Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Field No.";Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2;"Application Area";Text[30])
        {
            Caption = 'Application Area';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3;Selected;Boolean)
        {
            Caption = 'Selected';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        TempApplicationAreaBuffer: Record "Application Area Buffer" temporary;
    begin
        case true of
          (not Selected) and ("Field No." = ApplicationAreaSetup.FieldNo(Basic)):
            ModifyAll(Selected,false);
          Selected and ("Field No." <> ApplicationAreaSetup.FieldNo(Basic)):
            begin
              TempApplicationAreaBuffer.Copy(Rec,true);
              TempApplicationAreaBuffer.Get(ApplicationAreaSetup.FieldNo(Basic));
              TempApplicationAreaBuffer.Selected := true;
              TempApplicationAreaBuffer.Modify;
            end;
        end;
    end;
}

