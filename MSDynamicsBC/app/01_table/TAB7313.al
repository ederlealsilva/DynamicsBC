table 7313 "Warehouse Register"
{
    // version NAVW113.00

    Caption = 'Warehouse Register';
    LookupPageID = "Warehouse Registers";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
        }
        field(2;"From Entry No.";Integer)
        {
            Caption = 'From Entry No.';
            TableRelation = "Warehouse Entry";
        }
        field(3;"To Entry No.";Integer)
        {
            Caption = 'To Entry No.';
            TableRelation = "Warehouse Entry";
        }
        field(4;"Creation Date";Date)
        {
            Caption = 'Creation Date';
        }
        field(5;"Source Code";Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(6;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;
        }
        field(7;"Journal Batch Name";Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Item Journal Batch".Name;
            //This property is currently not supported
            //TestTableRelation = false;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Source Code")
        {
        }
    }

    fieldgroups
    {
    }
}

