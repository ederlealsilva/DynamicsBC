table 410 "IC G/L Account"
{
    // version NAVW17.00

    Caption = 'IC G/L Account';
    LookupPageID = "IC G/L Account List";

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(3;"Account Type";Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'Posting,Heading,Total,Begin-Total,End-Total';
            OptionMembers = Posting,Heading,Total,"Begin-Total","End-Total";
        }
        field(4;"Income/Balance";Option)
        {
            Caption = 'Income/Balance';
            OptionCaption = 'Income Statement,Balance Sheet';
            OptionMembers = "Income Statement","Balance Sheet";
        }
        field(5;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(6;"Map-to G/L Acc. No.";Code[20])
        {
            Caption = 'Map-to G/L Acc. No.';
            TableRelation = "G/L Account"."No.";
        }
        field(7;Indentation;Integer)
        {
            Caption = 'Indentation';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"No.",Name,"Income/Balance",Blocked,"Map-to G/L Acc. No.")
        {
        }
    }
}

