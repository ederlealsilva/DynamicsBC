table 1625 "Office Contact Associations"
{
    // version NAVW111.00

    Caption = 'Office Contact Associations';

    fields
    {
        field(1;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
        }
        field(2;"Business Relation Code";Code[10])
        {
            Caption = 'Business Relation Code';
            TableRelation = "Business Relation";
        }
        field(3;"Associated Table";Option)
        {
            Caption = 'Associated Table';
            OptionCaption = ' ,Customer,Vendor,Bank Account,Company';
            OptionMembers = " ",Customer,Vendor,"Bank Account",Company;
        }
        field(4;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF ("Associated Table"=CONST(Customer)) Customer
                            ELSE IF ("Associated Table"=CONST(Vendor)) Vendor
                            ELSE IF ("Associated Table"=CONST("Bank Account")) "Bank Account";
        }
        field(5;"Business Relation Description";Text[50])
        {
            Caption = 'Business Relation Description';
            Editable = false;
        }
        field(6;"Contact Name";Text[50])
        {
            Caption = 'Contact Name';
        }
        field(7;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Company,Contact Person';
            OptionMembers = Company,"Contact Person";
        }
    }

    keys
    {
        key(Key1;"Contact No.",Type,"Associated Table")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure GetContactNo() ContactNo: Code[20]
    begin
        if "Associated Table" = "Associated Table"::" " then
          ContactNo := "Contact No."
        else
          ContactNo := "No.";
    end;
}

