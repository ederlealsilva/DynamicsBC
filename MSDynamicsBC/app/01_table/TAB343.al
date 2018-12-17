table 343 "Item Application Entry History"
{
    // version NAVW113.00

    Caption = 'Item Application Entry History';
    DrillDownPageID = "Item Application Entry History";
    LookupPageID = "Item Application Entry History";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(2;"Item Ledger Entry No.";Integer)
        {
            Caption = 'Item Ledger Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(3;"Inbound Item Entry No.";Integer)
        {
            Caption = 'Inbound Item Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(4;"Outbound Item Entry No.";Integer)
        {
            Caption = 'Outbound Item Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(9;"Primary Entry No.";Integer)
        {
            Caption = 'Primary Entry No.';
        }
        field(11;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
        }
        field(21;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(23;"Transferred-from Entry No.";Integer)
        {
            Caption = 'Transferred-from Entry No.';
            TableRelation = "Item Ledger Entry";
        }
        field(25;"Creation Date";DateTime)
        {
            Caption = 'Creation Date';
        }
        field(26;"Created By User";Code[50])
        {
            Caption = 'Created By User';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("Created By User");
            end;
        }
        field(27;"Last Modified Date";DateTime)
        {
            Caption = 'Last Modified Date';
        }
        field(28;"Last Modified By User";Code[50])
        {
            Caption = 'Last Modified By User';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("Last Modified By User");
            end;
        }
        field(29;"Deleted Date";DateTime)
        {
            Caption = 'Deleted Date';
        }
        field(30;"Deleted By User";Code[50])
        {
            Caption = 'Deleted By User';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("Deleted By User");
            end;
        }
        field(5800;"Cost Application";Boolean)
        {
            Caption = 'Cost Application';
        }
        field(5804;"Output Completely Invd. Date";Date)
        {
            Caption = 'Output Completely Invd. Date';
        }
    }

    keys
    {
        key(Key1;"Primary Entry No.")
        {
        }
        key(Key2;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

