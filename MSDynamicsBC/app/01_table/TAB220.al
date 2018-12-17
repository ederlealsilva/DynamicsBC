table 220 "Business Unit"
{
    // version NAVW111.00

    Caption = 'Business Unit';
    LookupPageID = "Business Unit List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Consolidate;Boolean)
        {
            Caption = 'Consolidate';
            InitValue = true;
        }
        field(3;"Consolidation %";Decimal)
        {
            Caption = 'Consolidation %';
            DecimalPlaces = 1:1;
            InitValue = 100;
            MaxValue = 100;
            MinValue = 0;
        }
        field(4;"Starting Date";Date)
        {
            Caption = 'Starting Date';
        }
        field(5;"Ending Date";Date)
        {
            Caption = 'Ending Date';
        }
        field(6;"Income Currency Factor";Decimal)
        {
            Caption = 'Income Currency Factor';
            DecimalPlaces = 0:15;
            Editable = false;
            InitValue = 1;
            MinValue = 0;
        }
        field(7;"Balance Currency Factor";Decimal)
        {
            Caption = 'Balance Currency Factor';
            DecimalPlaces = 0:15;
            Editable = false;
            InitValue = 1;
            MinValue = 0;
        }
        field(8;"Exch. Rate Losses Acc.";Code[20])
        {
            Caption = 'Exch. Rate Losses Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Exch. Rate Losses Acc.");
            end;
        }
        field(9;"Exch. Rate Gains Acc.";Code[20])
        {
            Caption = 'Exch. Rate Gains Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Exch. Rate Gains Acc.");
            end;
        }
        field(10;"Residual Account";Code[20])
        {
            Caption = 'Residual Account';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Residual Account");
            end;
        }
        field(11;"Last Balance Currency Factor";Decimal)
        {
            Caption = 'Last Balance Currency Factor';
            DecimalPlaces = 0:15;
            Editable = false;
            InitValue = 1;
        }
        field(12;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(13;"Company Name";Text[30])
        {
            Caption = 'Company Name';
            TableRelation = Company.Name;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(14;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;

            trigger OnValidate()
            begin
                "Income Currency Factor" := CurrExchRate.ExchangeRate(WorkDate,"Currency Code");
                "Balance Currency Factor" := CurrExchRate.ExchangeRate(WorkDate,"Currency Code");
            end;
        }
        field(15;"Comp. Exch. Rate Gains Acc.";Code[20])
        {
            Caption = 'Comp. Exch. Rate Gains Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Comp. Exch. Rate Gains Acc.");
            end;
        }
        field(16;"Comp. Exch. Rate Losses Acc.";Code[20])
        {
            Caption = 'Comp. Exch. Rate Losses Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Comp. Exch. Rate Losses Acc.");
            end;
        }
        field(17;"Equity Exch. Rate Gains Acc.";Code[20])
        {
            Caption = 'Equity Exch. Rate Gains Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Equity Exch. Rate Gains Acc.");
            end;
        }
        field(18;"Equity Exch. Rate Losses Acc.";Code[20])
        {
            Caption = 'Equity Exch. Rate Losses Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Equity Exch. Rate Losses Acc.");
            end;
        }
        field(19;"Minority Exch. Rate Gains Acc.";Code[20])
        {
            Caption = 'Minority Exch. Rate Gains Acc.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Minority Exch. Rate Gains Acc.");
            end;
        }
        field(20;"Minority Exch. Rate Losses Acc";Code[20])
        {
            Caption = 'Minority Exch. Rate Losses Acc';
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Minority Exch. Rate Losses Acc");
            end;
        }
        field(21;"Currency Exchange Rate Table";Option)
        {
            AccessByPermission = TableData Currency=R;
            Caption = 'Currency Exchange Rate Table';
            OptionCaption = 'Local,Business Unit';
            OptionMembers = "Local","Business Unit";
        }
        field(22;"Data Source";Option)
        {
            Caption = 'Data Source';
            OptionCaption = 'Local Curr. (LCY),Add. Rep. Curr. (ACY)';
            OptionMembers = "Local Curr. (LCY)","Add. Rep. Curr. (ACY)";
        }
        field(23;"File Format";Option)
        {
            Caption = 'File Format';
            OptionCaption = 'Version 4.00 or Later (.xml),Version 3.70 or Earlier (.txt)';
            OptionMembers = "Version 4.00 or Later (.xml)","Version 3.70 or Earlier (.txt)";
        }
        field(24;"Last Run";Date)
        {
            Caption = 'Last Run';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
        key(Key2;"Company Name")
        {
        }
    }

    fieldgroups
    {
    }

    var
        CurrExchRate: Record "Currency Exchange Rate";

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAcc: Record "G/L Account";
    begin
        if AccNo <> '' then begin
          GLAcc.Get(AccNo);
          GLAcc.CheckGLAcc;
        end;
    end;
}

