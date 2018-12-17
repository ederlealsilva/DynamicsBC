table 6508 "Value Entry Relation"
{
    // version NAVW110.0

    Caption = 'Value Entry Relation';

    fields
    {
        field(1;"Value Entry No.";Integer)
        {
            Caption = 'Value Entry No.';
            TableRelation = "Value Entry";
        }
        field(11;"Source RowId";Text[250])
        {
            Caption = 'Source RowId';
        }
    }

    keys
    {
        key(Key1;"Value Entry No.")
        {
        }
        key(Key2;"Source RowId")
        {
        }
    }

    fieldgroups
    {
    }
}

