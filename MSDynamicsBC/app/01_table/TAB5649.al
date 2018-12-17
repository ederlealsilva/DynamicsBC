table 5649 "FA Posting Group Buffer"
{
    // version NAVW113.00

    Caption = 'FA Posting Group Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"FA Posting Group";Code[20])
        {
            Caption = 'FA Posting Group';
            DataClassification = SystemMetadata;
        }
        field(2;"Posting Type";Option)
        {
            Caption = 'Posting Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Acq,Depr,WD,Appr,C1,C2,DeprExp,Maint,Disp,GL,BV,DispAcq,DispDepr,DispWD,DispAppr,DispC1,DispC2,BalWD,BalAppr,BalC1,BalC2';
            OptionMembers = Acq,Depr,WD,Appr,C1,C2,DeprExp,Maint,Disp,GL,BV,DispAcq,DispDepr,DispWD,DispAppr,DispC1,DispC2,BalWD,BalAppr,BalC1,BalC2;
        }
        field(3;"Account No.";Code[20])
        {
            Caption = 'Account No.';
            DataClassification = SystemMetadata;
        }
        field(4;Amount;Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(5;"Account Name";Text[50])
        {
            Caption = 'Account Name';
            DataClassification = SystemMetadata;
        }
        field(6;"FA FieldCaption";Text[50])
        {
            Caption = 'FA FieldCaption';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"FA Posting Group","Posting Type","Account No.")
        {
        }
        key(Key2;"Account No.")
        {
            SumIndexFields = Amount;
        }
    }

    fieldgroups
    {
    }
}

