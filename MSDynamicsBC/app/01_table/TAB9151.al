table 9151 "My Vendor"
{
    // version NAVW113.00

    Caption = 'My Vendor';

    fields
    {
        field(1;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;

            trigger OnValidate()
            begin
                SetVendorFields;
            end;
        }
        field(3;Name;Text[50])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(4;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
            Editable = false;
        }
        field(5;"Balance (LCY)";Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE ("Vendor No."=FIELD("Vendor No.")));
            Caption = 'Balance (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"User ID","Vendor No.")
        {
        }
        key(Key2;Name)
        {
        }
        key(Key3;"Phone No.")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure SetVendorFields()
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get("Vendor No.") then begin
          Name := Vendor.Name;
          "Phone No." := Vendor."Phone No.";
        end;
    end;
}

