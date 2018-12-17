table 6706 "Booking Service Mapping"
{
    // version NAVW111.00

    Caption = 'Booking Service Mapping';

    fields
    {
        field(1;"Service ID";Text[50])
        {
            Caption = 'Service ID';
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(3;"Booking Mailbox";Text[80])
        {
            Caption = 'Booking Mailbox';
        }
    }

    keys
    {
        key(Key1;"Service ID")
        {
        }
        key(Key2;"Booking Mailbox","Item No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure Map(ItemNo: Code[20];ServiceID: Text[50];Mailbox: Text[80])
    begin
        Init;
        "Item No." := ItemNo;
        "Service ID" := ServiceID;
        "Booking Mailbox" := Mailbox;
        if not Insert(true) then
          Modify(true);
    end;
}

