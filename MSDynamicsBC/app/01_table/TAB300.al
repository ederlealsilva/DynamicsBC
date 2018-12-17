table 300 "Reminder/Fin. Charge Entry"
{
    // version NAVW113.00

    Caption = 'Reminder/Fin. Charge Entry';
    DrillDownPageID = "Reminder/Fin. Charge Entries";
    LookupPageID = "Reminder/Fin. Charge Entries";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
            NotBlank = true;
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Reminder,Finance Charge Memo';
            OptionMembers = Reminder,"Finance Charge Memo";
        }
        field(3;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST(Reminder)) "Issued Reminder Header"
                            ELSE IF (Type=CONST("Finance Charge Memo")) "Issued Fin. Charge Memo Header";
        }
        field(4;"Reminder Level";Integer)
        {
            Caption = 'Reminder Level';
        }
        field(5;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(6;"Document Date";Date)
        {
            Caption = 'Document Date';
        }
        field(7;"Interest Posted";Boolean)
        {
            Caption = 'Interest Posted';
        }
        field(8;"Interest Amount";Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Interest Amount';
        }
        field(9;"Customer Entry No.";Integer)
        {
            Caption = 'Customer Entry No.';
            TableRelation = "Cust. Ledger Entry";
        }
        field(10;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Finance Charge Memo,Reminder,Refund';
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
        }
        field(11;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(12;"Remaining Amount";Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            Caption = 'Remaining Amount';
        }
        field(13;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(14;"User ID";Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                UserMgt.LookupUserID("User ID");
            end;
        }
        field(15;"Due Date";Date)
        {
            Caption = 'Due Date';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Customer No.")
        {
        }
        key(Key3;"Customer Entry No.",Type)
        {
        }
        key(Key4;Type,"No.")
        {
        }
        key(Key5;"Document No.","Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure Navigate()
    var
        NavigateForm: Page Navigate;
    begin
        NavigateForm.SetDoc("Posting Date","No.");
        NavigateForm.Run;
    end;

    local procedure GetCurrencyCode(): Code[10]
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if "Customer Entry No." = CustLedgEntry."Entry No." then
          exit(CustLedgEntry."Currency Code");

        if CustLedgEntry.Get("Customer Entry No.") then
          exit(CustLedgEntry."Currency Code");

        exit('');
    end;
}

