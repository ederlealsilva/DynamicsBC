page 6704 "Booking Mailbox List"
{
    // version NAVW111.00

    Caption = 'Booking Mailbox List';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Booking Mailbox";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Service Address";SmtpAddress)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the SMTP address of the Bookings mailbox.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name of the Bookings mailbox.';
                }
                field("Display Name";"Display Name")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the full name of the Bookings mailbox.';
                }
            }
        }
    }

    actions
    {
    }

    [Scope('Personalization')]
    procedure SetMailboxes(var TempBookingMailbox: Record "Booking Mailbox" temporary)
    begin
        TempBookingMailbox.Reset;
        if TempBookingMailbox.FindSet then
          repeat
            Init;
            TransferFields(TempBookingMailbox);
            Insert;
          until TempBookingMailbox.Next = 0;
    end;
}

