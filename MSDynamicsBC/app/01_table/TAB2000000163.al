table 2000000163 "NAV App Object Prerequisites"
{
    // version NAVW19.00

    Caption = 'NAV App Object Prerequisites';
    DataPerCompany = false;

    fields
    {
        field(1;"Package ID";Guid)
        {
            Caption = 'Package ID';
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'TableData,Table,,Report,,Codeunit,XMLport,MenuSuite,Page,Query';
            OptionMembers = TableData,"Table",,"Report",,"Codeunit","XMLport",MenuSuite,"Page","Query";
        }
        field(3;ID;Integer)
        {
            Caption = 'ID';
        }
    }

    keys
    {
        key(Key1;"Package ID",Type,ID)
        {
        }
    }

    fieldgroups
    {
    }
}

