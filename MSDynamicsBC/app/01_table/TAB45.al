table 45 "G/L Register"
{
    // version NAVW113.00

    Caption = 'G/L Register';
    LookupPageID = "G/L Registers";

    fields
    {
        field(1;"No.";Integer)
        {
            Caption = 'No.';
        }
        field(2;"From Entry No.";Integer)
        {
            Caption = 'From Entry No.';
            TableRelation = "G/L Entry";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(3;"To Entry No.";Integer)
        {
            Caption = 'To Entry No.';
            TableRelation = "G/L Entry";
            //This property is currently not supported
            //TestTableRelation = false;
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
        }
        field(8;"From VAT Entry No.";Integer)
        {
            Caption = 'From VAT Entry No.';
            TableRelation = "VAT Entry";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(9;"To VAT Entry No.";Integer)
        {
            Caption = 'To VAT Entry No.';
            TableRelation = "VAT Entry";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(10;Reversed;Boolean)
        {
            Caption = 'Reversed';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Creation Date")
        {
        }
        key(Key3;"Source Code","Journal Batch Name","Creation Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"No.","From Entry No.","To Entry No.","Creation Date","Source Code")
        {
        }
    }
}

