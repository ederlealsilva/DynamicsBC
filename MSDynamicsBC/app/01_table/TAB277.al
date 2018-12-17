table 277 "Bank Account Posting Group"
{
    // version NAVW111.00

    Caption = 'Bank Account Posting Group';
    DrillDownPageID = "Bank Account Posting Groups";
    LookupPageID = "Bank Account Posting Groups";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"G/L Bank Account No.";Code[20])
        {
            Caption = 'G/L Bank Account No.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("G/L Bank Account No.");
            end;
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
        fieldgroup(DropDown;"Code","G/L Bank Account No.")
        {
        }
        fieldgroup(Brick;"Code")
        {
        }
    }

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
          GLAcc.Get(AccNo);
          GLAcc.CheckGLAcc;
        end;
    end;

    [Scope('Personalization')]
    procedure GetGLBankAccountNo(): Code[20]
    begin
        TestField("G/L Bank Account No.");
        exit("G/L Bank Account No.");
    end;
}

