table 5973 "Service Contract Account Group"
{
    // version NAVW113.00

    Caption = 'Service Contract Account Group';
    DrillDownPageID = "Serv. Contract Account Groups";
    LookupPageID = "Serv. Contract Account Groups";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;"Non-Prepaid Contract Acc.";Code[20])
        {
            Caption = 'Non-Prepaid Contract Acc.';
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if "Non-Prepaid Contract Acc." <> '' then begin
                  GlAcc.Get("Non-Prepaid Contract Acc.");
                  GlAcc.TestField("Gen. Prod. Posting Group");
                  GlAcc.TestField("VAT Prod. Posting Group");
                end;
            end;
        }
        field(4;"Prepaid Contract Acc.";Code[20])
        {
            Caption = 'Prepaid Contract Acc.';
            TableRelation = "G/L Account"."No.";

            trigger OnValidate()
            begin
                if "Prepaid Contract Acc." <> '' then begin
                  GlAcc.Get("Prepaid Contract Acc.");
                  GlAcc.TestField("Gen. Prod. Posting Group");
                  GlAcc.TestField("VAT Prod. Posting Group");
                end;
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
    }

    var
        GlAcc: Record "G/L Account";
}

