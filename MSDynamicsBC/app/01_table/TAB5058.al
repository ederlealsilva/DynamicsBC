table 5058 "Contact Industry Group"
{
    // version NAVW111.00

    Caption = 'Contact Industry Group';
    DrillDownPageID = "Contact Industry Groups";

    fields
    {
        field(1;"Contact No.";Code[20])
        {
            Caption = 'Contact No.';
            NotBlank = true;
            TableRelation = Contact WHERE (Type=CONST(Company));
        }
        field(2;"Industry Group Code";Code[10])
        {
            Caption = 'Industry Group Code';
            NotBlank = true;
            TableRelation = "Industry Group";
        }
        field(3;"Industry Group Description";Text[50])
        {
            CalcFormula = Lookup("Industry Group".Description WHERE (Code=FIELD("Industry Group Code")));
            Caption = 'Industry Group Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4;"Contact Name";Text[50])
        {
            CalcFormula = Lookup(Contact.Name WHERE ("No."=FIELD("Contact No.")));
            Caption = 'Contact Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Contact No.","Industry Group Code")
        {
        }
        key(Key2;"Industry Group Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Contact: Record Contact;
    begin
        Contact.TouchContact("Contact No.");
    end;

    trigger OnInsert()
    var
        Contact: Record Contact;
    begin
        Contact.TouchContact("Contact No.");
    end;

    trigger OnModify()
    var
        Contact: Record Contact;
    begin
        Contact.TouchContact("Contact No.");
    end;

    trigger OnRename()
    var
        Contact: Record Contact;
    begin
        if xRec."Contact No." = "Contact No." then
          Contact.TouchContact("Contact No.")
        else begin
          Contact.TouchContact("Contact No.");
          Contact.TouchContact(xRec."Contact No.");
        end;
    end;
}

