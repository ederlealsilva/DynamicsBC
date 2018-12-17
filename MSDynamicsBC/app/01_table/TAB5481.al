table 5481 "Account Entity Setup"
{
    // version NAVW111.00

    Caption = 'Account Entity Setup';
    ObsoleteReason = 'Became obsolete after refactoring of the NAV APIs.';
    ObsoleteState = Pending;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Show Balance";Boolean)
        {
            Caption = 'Show Balance';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SafeGet()
    begin
        if not Get then
          Insert;
    end;
}

