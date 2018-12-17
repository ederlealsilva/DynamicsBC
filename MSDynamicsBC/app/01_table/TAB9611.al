table 9611 "XML Schema Restriction"
{
    // version NAVW19.00

    Caption = 'XML Schema Restriction';

    fields
    {
        field(1;"XML Schema Code";Code[20])
        {
            Caption = 'XML Schema Code';
            TableRelation = "XML Schema Element"."XML Schema Code";
        }
        field(2;"Element ID";Integer)
        {
            Caption = 'Element ID';
            TableRelation = "XML Schema Element".ID WHERE ("XML Schema Code"=FIELD("XML Schema Code"));
        }
        field(3;ID;Integer)
        {
            Caption = 'ID';
        }
        field(4;Value;Text[250])
        {
            Caption = 'Value';
        }
        field(25;"Simple Data Type";Text[50])
        {
            Caption = 'Simple Data Type';
            Editable = false;
        }
        field(26;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Value,Base';
            OptionMembers = Value,Base;
        }
    }

    keys
    {
        key(Key1;"XML Schema Code","Element ID",ID)
        {
        }
    }

    fieldgroups
    {
    }
}

