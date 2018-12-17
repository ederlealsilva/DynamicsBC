table 2156 "O365 Payment Instr. Transl."
{
    // version NAVW113.00

    Caption = 'O365 Payment Instr. Transl.';

    fields
    {
        field(1;Id;Integer)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(3;"Language Code";Code[10])
        {
            Caption = 'Language Code';
            DataClassification = SystemMetadata;
        }
        field(5;"Transl. Name";Text[20])
        {
            Caption = 'Transl. Name';
        }
        field(6;"Transl. Payment Instructions";Text[250])
        {
            Caption = 'Transl. Payment Instructions';
        }
        field(7;"Transl. Payment Instr. Blob";BLOB)
        {
            Caption = 'Transl. Payment Instr. Blob';
        }
    }

    keys
    {
        key(Key1;Id,"Language Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetTransPaymentInstructions(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        CalcFields("Transl. Payment Instr. Blob");
        if not "Transl. Payment Instr. Blob".HasValue then
          exit("Transl. Payment Instructions");
        CR[1] := 10;
        TempBlob.Blob := "Transl. Payment Instr. Blob";
        exit(TempBlob.ReadAsText(CR,TEXTENCODING::Windows));
    end;

    procedure SetTranslPaymentInstructions(NewParameter: Text)
    var
        TempBlob: Record TempBlob;
    begin
        Clear("Transl. Payment Instr. Blob");
        "Transl. Payment Instructions" := CopyStr(NewParameter,1,MaxStrLen("Transl. Payment Instructions"));
        if StrLen(NewParameter) <= MaxStrLen("Transl. Payment Instructions") then
          exit; // No need to store anything in the blob
        if NewParameter = '' then
          exit;
        TempBlob.WriteAsText(NewParameter,TEXTENCODING::Windows);
        "Transl. Payment Instr. Blob" := TempBlob.Blob;
        Modify;
    end;
}

