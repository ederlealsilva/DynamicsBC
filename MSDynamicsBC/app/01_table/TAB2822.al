table 2822 "Native - Export Invoices"
{
    // version NAVW111.00

    Caption = 'Native - Export Invoices';

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(2;"Start Date";Date)
        {
            Caption = 'Start Date';
        }
        field(3;"End Date";Date)
        {
            Caption = 'End Date';
        }
        field(4;"E-mail";Text[80])
        {
            Caption = 'E-mail';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

