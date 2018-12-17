table 5100 "Communication Method"
{
    // version NAVW111.00

    Caption = 'Communication Method';

    fields
    {
        field(1;"Key";Integer)
        {
            Caption = 'Key';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;Number;Text[30])
        {
            Caption = 'Number';
        }
        field(4;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
            TableRelation = Contact;
        }
        field(5;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(6;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Company,Person';
            OptionMembers = Company,Person;
        }
        field(7;"E-Mail";Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("E-Mail");
            end;
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

