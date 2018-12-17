table 849 "Cash Flow Manual Revenue"
{
    // version NAVW113.00

    Caption = 'Cash Flow Manual Revenue';
    DrillDownPageID = "Cash Flow Manual Revenues";
    LookupPageID = "Cash Flow Manual Revenues";

    fields
    {
        field(2;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3;"Cash Flow Account No.";Code[20])
        {
            Caption = 'Cash Flow Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            var
                CFAccount: Record "Cash Flow Account";
            begin
                if "Cash Flow Account No." <> '' then begin
                  CFAccount.Get("Cash Flow Account No.");
                  CFAccount.TestField("Account Type",CFAccount."Account Type"::Entry);
                  if "Cash Flow Account No." <> xRec."Cash Flow Account No." then
                    Description := CFAccount.Name;
                end;
            end;
        }
        field(4;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(5;"Starting Date";Date)
        {
            Caption = 'Starting Date';
        }
        field(6;"Ending Date";Date)
        {
            Caption = 'Ending Date';
        }
        field(7;"Recurring Frequency";DateFormula)
        {
            Caption = 'Recurring Frequency';
        }
        field(8;Amount;Decimal)
        {
            Caption = 'Amount';
        }
        field(9;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Global Dimension 1 Code");
                Modify;
            end;
        }
        field(10;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Global Dimension 2 Code");
                Modify;
            end;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Starting Date")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DimMgt.DeleteDefaultDim(DATABASE::"Cash Flow Manual Revenue",Code);
    end;

    trigger OnInsert()
    begin
        DimMgt.UpdateDefaultDim(
          DATABASE::"Cash Flow Manual Revenue",Code,
          "Global Dimension 1 Code","Global Dimension 2 Code");
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        RevTxt: Label 'REV', Comment='Abbreviation of Revenue, used as prefix for code (e.g. REV000001)';

    [Scope('Personalization')]
    procedure ValidateShortcutDimCode(FieldNo: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNo,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"Cash Flow Manual Expense",Code,FieldNo,ShortcutDimCode);
    end;

    procedure InitNewRecord()
    var
        CashFlowManualRevenue: Record "Cash Flow Manual Revenue";
        CashFlowAccount: Record "Cash Flow Account";
        CashFlowCode: Code[10];
    begin
        CashFlowManualRevenue.SetFilter(Code,'%1',RevTxt + '0*');
        if not CashFlowManualRevenue.FindLast then
          CashFlowCode := PadStr(RevTxt,MaxStrLen(CashFlowManualRevenue.Code),'0')
        else
          CashFlowCode := CashFlowManualRevenue.Code;
        CashFlowCode := IncStr(CashFlowCode);

        CashFlowAccount.SetRange("Source Type",CashFlowAccount."Source Type"::"Cash Flow Manual Revenue");
        if not CashFlowAccount.FindFirst then
          exit;

        Code := CashFlowCode;
        "Cash Flow Account No." := CashFlowAccount."No.";
        "Starting Date" := WorkDate;
        "Ending Date" := 0D;
    end;
}

