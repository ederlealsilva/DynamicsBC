page 410 "SMTP User-Specified Address"
{
    // version NAVW111.00

    Caption = 'Enter Email Address';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Control4)
            {
                ShowCaption = false;
                field(EmailAddressField;EmailAddress)
                {
                    ApplicationArea = Basic,Suite,Invoicing;
                    Caption = 'Email Address';
                    ExtendedDatatype = EMail;
                    ToolTip = 'Specifies the email address.';

                    trigger OnValidate()
                    var
                        SMTPMail: Codeunit "SMTP Mail";
                    begin
                        SMTPMail.CheckValidEmailAddresses(EmailAddress);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        EmailAddress: Text;

    [Scope('Personalization')]
    procedure GetEmailAddress(): Text
    begin
        exit(EmailAddress);
    end;

    [Scope('Personalization')]
    procedure SetEmailAddress(Address: Text)
    begin
        EmailAddress := Address;
    end;
}

