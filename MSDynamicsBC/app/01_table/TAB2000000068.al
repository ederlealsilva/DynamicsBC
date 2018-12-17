table 2000000068 "Record Link"
{
    // version NAVW113.00

    Caption = 'Record Link';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"Link ID";Integer)
        {
            AutoIncrement = true;
            Caption = 'Link ID';
        }
        field(2;"Record ID";RecordID)
        {
            Caption = 'Record ID';
        }
        field(3;URL1;Text[250])
        {
            Caption = 'URL1';
        }
        field(4;URL2;Text[250])
        {
            Caption = 'URL2';
        }
        field(5;URL3;Text[250])
        {
            Caption = 'URL3';
        }
        field(6;URL4;Text[250])
        {
            Caption = 'URL4';
        }
        field(7;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(8;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Link,Note';
            OptionMembers = Link,Note;
        }
        field(9;Note;BLOB)
        {
            Caption = 'Note';
            SubType = Memo;
        }
        field(10;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(11;"User ID";Text[132])
        {
            Caption = 'User ID';
        }
        field(12;Company;Text[30])
        {
            Caption = 'Company';
            TableRelation = Company.Name;
        }
        field(13;Notify;Boolean)
        {
            Caption = 'Notify';
        }
        field(14;"To User ID";Text[132])
        {
            Caption = 'To User ID';
        }
    }

    keys
    {
        key(Key1;"Link ID")
        {
        }
        key(Key2;"Record ID")
        {
        }
        key(Key3;Company)
        {
        }
    }

    fieldgroups
    {
    }
}

