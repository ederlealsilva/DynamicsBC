table 843 "Cash Flow Setup"
{
    // version NAVW113.00

    Caption = 'Cash Flow Setup';
    Permissions = TableData "Service Password"=rimd;

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2;"Cash Flow Forecast No. Series";Code[20])
        {
            Caption = 'Cash Flow Forecast No. Series';
            TableRelation = "No. Series";
        }
        field(3;"Receivables CF Account No.";Code[20])
        {
            Caption = 'Receivables CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Receivables CF Account No.");
            end;
        }
        field(4;"Payables CF Account No.";Code[20])
        {
            Caption = 'Payables CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Payables CF Account No.");
            end;
        }
        field(5;"Sales Order CF Account No.";Code[20])
        {
            AccessByPermission = TableData "Sales Shipment Header"=R;
            Caption = 'Sales Order CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Sales Order CF Account No.");
            end;
        }
        field(6;"Purch. Order CF Account No.";Code[20])
        {
            AccessByPermission = TableData "Purch. Rcpt. Header"=R;
            Caption = 'Purch. Order CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Purch. Order CF Account No.");
            end;
        }
        field(8;"FA Budget CF Account No.";Code[20])
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'FA Budget CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("FA Budget CF Account No.");
            end;
        }
        field(9;"FA Disposal CF Account No.";Code[20])
        {
            AccessByPermission = TableData "Fixed Asset"=R;
            Caption = 'FA Disposal CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("FA Disposal CF Account No.");
            end;
        }
        field(10;"Service CF Account No.";Code[20])
        {
            AccessByPermission = TableData "Service Header"=R;
            Caption = 'Service CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Service CF Account No.");
            end;
        }
        field(11;"CF No. on Chart in Role Center";Code[20])
        {
            Caption = 'CF No. on Chart in Role Center';

            trigger OnValidate()
            begin
                if not ConfirmedChartRoleCenterCFNo("CF No. on Chart in Role Center") then
                  "CF No. on Chart in Role Center" := xRec."CF No. on Chart in Role Center";
            end;
        }
        field(12;"Job CF Account No.";Code[20])
        {
            AccessByPermission = TableData "Job Planning Line"=R;
            Caption = 'Job CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Job CF Account No.");
            end;
        }
        field(13;"Automatic Update Frequency";Option)
        {
            Caption = 'Automatic Update Frequency';
            OptionCaption = 'Never,Daily,Weekly';
            OptionMembers = Never,Daily,Weekly;

            trigger OnValidate()
            var
                CashFlowManagement: Codeunit "Cash Flow Management";
            begin
                if "Automatic Update Frequency" = xRec."Automatic Update Frequency" then
                  exit;

                CashFlowManagement.DeleteJobQueueEntries;
                CashFlowManagement.CreateAndStartJobQueueEntry("Automatic Update Frequency");
            end;
        }
        field(14;"Tax CF Account No.";Code[20])
        {
            AccessByPermission = TableData "VAT Entry"=R;
            Caption = 'Tax CF Account No.';
            TableRelation = "Cash Flow Account";

            trigger OnValidate()
            begin
                CheckAccType("Tax CF Account No.");
            end;
        }
        field(19;"Taxable Period";Option)
        {
            Caption = 'Taxable Period';
            InitValue = Quarterly;
            OptionCaption = 'Monthly,Quarterly,Accounting Period,Yearly';
            OptionMembers = Monthly,Quarterly,"Accounting Period",Yearly;
        }
        field(20;"Tax Payment Window";DateFormula)
        {
            Caption = 'Tax Payment Window';
        }
        field(21;"Tax Bal. Account Type";Option)
        {
            Caption = 'Tax Bal. Account Type';
            OptionCaption = ' ,Vendor,G/L Account';
            OptionMembers = " ",Vendor,"G/L Account";

            trigger OnValidate()
            begin
                EmptyTaxBalAccountIfTypeChanged(xRec."Tax Bal. Account Type");
            end;
        }
        field(22;"Tax Bal. Account No.";Code[20])
        {
            Caption = 'Tax Bal. Account No.';
            TableRelation = IF ("Tax Bal. Account Type"=CONST("G/L Account")) "G/L Account"
                            ELSE IF ("Tax Bal. Account Type"=CONST(Vendor)) Vendor;
        }
        field(23;"API Key";Text[250])
        {
            Caption = 'API Key';

            trigger OnValidate()
            begin
                if not IsNullGuid("Service Pass API Key ID") then
                  EnableEncryption;
                SaveUserDefinedAPIKey("API Key");
            end;
        }
        field(24;"API URL";Text[250])
        {
            Caption = 'API URL';
        }
        field(25;"Variance %";Integer)
        {
            Caption = 'Variance %';
            InitValue = 35;
            MaxValue = 100;
            MinValue = 1;
        }
        field(26;"Historical Periods";Integer)
        {
            Caption = 'Historical Periods';
            InitValue = 24;
            MaxValue = 24;
            MinValue = 5;
        }
        field(27;Horizon;Integer)
        {
            Caption = 'Horizon';
            InitValue = 4;
            MaxValue = 24;
            MinValue = 3;
        }
        field(28;"Period Type";Option)
        {
            Caption = 'Period Type';
            InitValue = Month;
            OptionCaption = 'Day,Week,Month,Quarter,Year';
            OptionMembers = Day,Week,Month,Quarter,Year;
        }
        field(29;TimeOut;Integer)
        {
            Caption = 'TimeOut';
            InitValue = 120;
            MinValue = 1;
        }
        field(30;"Service Pass API Key ID";Guid)
        {
            Caption = 'Service Pass API Key ID';
            Description = 'The Key for retrieving the API Key from the Service Password table.';
            TableRelation = "Service Password".Key;
        }
        field(31;"Cortana Intelligence Enabled";Boolean)
        {
            Caption = 'Cortana Intelligence Enabled';
            InitValue = false;
        }
        field(32;"Show Cortana Notification";Boolean)
        {
            Caption = 'Show Cortana Notification';
            InitValue = true;
        }
        field(33;"Time Series Model";Option)
        {
            Caption = 'Time Series Model';
            OptionCaption = 'ARIMA,ETS,STL,ETS+ARIMA,ETS+STL,ALL', Locked=true;
            OptionMembers = ARIMA,ETS,STL,"ETS+ARIMA","ETS+STL",ALL;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Cash Flow Forecast %1 %2 is shown in the chart on the Role Center. Do you want to show this Cash Flow Forecast instead?', Comment='Cash Flow <No.> <Description> is shown in the chart on the Role Center.';
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";

    local procedure CheckAccType("Code": Code[20])
    var
        CFAccount: Record "Cash Flow Account";
    begin
        if Code <> '' then begin
          CFAccount.Get(Code);
          CFAccount.TestField("Account Type",CFAccount."Account Type"::Entry);
        end;
    end;

    [Scope('Personalization')]
    procedure SetChartRoleCenterCFNo(CashFlowNo: Code[20])
    begin
        Get;
        "CF No. on Chart in Role Center" := CashFlowNo;
        Modify;
    end;

    [Scope('Personalization')]
    procedure GetChartRoleCenterCFNo(): Code[20]
    begin
        Get;
        exit("CF No. on Chart in Role Center");
    end;

    local procedure ConfirmedChartRoleCenterCFNo(NewCashFlowNo: Code[20]): Boolean
    var
        CashFlowForecast: Record "Cash Flow Forecast";
    begin
        if NewCashFlowNo = '' then
          exit(true);

        if not (xRec."CF No. on Chart in Role Center" in ['',NewCashFlowNo]) then begin
          CashFlowForecast.Get(xRec."CF No. on Chart in Role Center");
          exit(Confirm(StrSubstNo(Text001,CashFlowForecast."No.",CashFlowForecast.Description),true));
        end;
        exit(true);
    end;

    [Scope('Personalization')]
    procedure GetTaxPaymentDueDate(ReferenceDate: Date): Date
    var
        EndOfTaxPeriod: Date;
    begin
        Get;
        EndOfTaxPeriod := CalculateTaxableDate(ReferenceDate,true);
        exit(CalcDate("Tax Payment Window",EndOfTaxPeriod));
    end;

    [Scope('Personalization')]
    procedure GetTaxPeriodStartEndDates(TaxDueDate: Date;var StartDate: Date;var EndDate: Date)
    begin
        Get;
        EndDate := GetTaxPeriodEndDate(TaxDueDate);
        StartDate := CalculateTaxableDate(EndDate,false);
    end;

    [Scope('Personalization')]
    procedure GetTaxPaymentStartDate(TaxDueDate: Date): Date
    begin
        Get;
        exit(CalcDate('<1D>',GetTaxPeriodEndDate(TaxDueDate)));
    end;

    procedure GetTaxPeriodEndDate(TaxDueDate: Date): Date
    var
        ReverseDateFormula: DateFormula;
    begin
        Get;
        Evaluate(ReverseDateFormula,ReverseDateFormulaAsText);
        exit(CalcDate(ReverseDateFormula,TaxDueDate));
    end;

    [Scope('Personalization')]
    procedure GetCurrentPeriodStartDate(): Date
    begin
        Get;
        exit(CalculateTaxableDate(WorkDate,false));
    end;

    [Scope('Personalization')]
    procedure GetCurrentPeriodEndDate(): Date
    begin
        Get;
        exit(CalculateTaxableDate(WorkDate,true));
    end;

    [Scope('Personalization')]
    procedure UpdateTaxPaymentInfo(NewTaxablePeriod: Option;NewPaymentWindow: DateFormula;NewTaxBalAccountType: Option;NewTaxBalAccountNum: Code[20])
    var
        Modified: Boolean;
    begin
        Get;
        if "Taxable Period" <> NewTaxablePeriod then begin
          "Taxable Period" := NewTaxablePeriod;
          Modified := true;
        end;

        if "Tax Payment Window" <> NewPaymentWindow then begin
          "Tax Payment Window" := NewPaymentWindow;
          Modified := true;
        end;

        if "Tax Bal. Account Type" <> NewTaxBalAccountType then begin
          "Tax Bal. Account Type" := NewTaxBalAccountType;
          Modified := true;
        end;

        if "Tax Bal. Account No." <> NewTaxBalAccountNum then begin
          "Tax Bal. Account No." := NewTaxBalAccountNum;
          Modified := true;
        end;

        if Modified then
          Modify;
    end;

    local procedure CalculateTaxableDate(ReferenceDate: Date;FindLast: Boolean) Result: Date
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        case "Taxable Period" of
          "Taxable Period"::Monthly:
            if FindLast then
              Result := CalcDate('<CM>',ReferenceDate)
            else
              Result := CalcDate('<-CM>',ReferenceDate);
          "Taxable Period"::Quarterly:
            if FindLast then
              Result := CalcDate('<CQ>',ReferenceDate)
            else
              Result := CalcDate('<-CQ>',ReferenceDate);
          "Taxable Period"::"Accounting Period":
            if FindLast then begin
              // The end of the current accounting period is the start of the next acc. period - 1 day
              AccountingPeriod.SetFilter("Starting Date",'>%1',ReferenceDate);
              AccountingPeriod.FindFirst;
              Result := AccountingPeriod."Starting Date" - 1;
            end else begin
              // The end of the current accounting period is the start of the next acc. period - 1 day
              AccountingPeriod.SetFilter("Starting Date",'<=%1',ReferenceDate);
              AccountingPeriod.FindFirst;
              Result := AccountingPeriod."Starting Date";
            end;
          "Taxable Period"::Yearly:
            if FindLast then
              Result := CalcDate('<CY>',ReferenceDate)
            else
              Result := CalcDate('<-CY>',ReferenceDate);
        end;
    end;

    local procedure ReverseDateFormulaAsText() Result: Text
    var
        TempChar: Char;
    begin
        Result := Format("Tax Payment Window");
        if Result = '' then
          exit('');

        if not (CopyStr(Result,1,1) in ['+','-']) then
          Result := '+' + Result;

        TempChar := '#';
        Result := ReplaceCharInString(Result,'+',TempChar);
        Result := ReplaceCharInString(Result,'-','+');
        Result := ReplaceCharInString(Result,TempChar,'-');
    end;

    local procedure ReplaceCharInString(StringToReplace: Text;OldChar: Char;NewChar: Char) Result: Text
    var
        Index: Integer;
        FirstPart: Text;
        LastPart: Text;
    begin
        Index := StrPos(StringToReplace,Format(OldChar));
        Result := StringToReplace;
        while Index > 0 do begin
          if Index > 1 then
            FirstPart := CopyStr(Result,1,Index - 1);
          if Index < StrLen(Result) then
            LastPart := CopyStr(Result,Index + 1);
          Result := FirstPart + Format(NewChar) + LastPart;
          Index := StrPos(Result,Format(OldChar));
        end;
    end;

    [Scope('Personalization')]
    procedure HasValidTaxAccountInfo(): Boolean
    begin
        exit("Tax Bal. Account Type" <> "Tax Bal. Account Type"::" ");
    end;

    [Scope('Personalization')]
    procedure EmptyTaxBalAccountIfTypeChanged(OldTypeValue: Option)
    begin
        if "Tax Bal. Account Type" <> OldTypeValue then
          "Tax Bal. Account No." := '';
    end;

    [Scope('Personalization')]
    procedure SaveUserDefinedAPIKey(APIKeyValue: Text[250])
    var
        ServicePassword: Record "Service Password";
    begin
        if IsNullGuid("Service Pass API Key ID") or not ServicePassword.Get("Service Pass API Key ID") then begin
          ServicePassword.SavePassword(APIKeyValue);
          ServicePassword.Insert(true);
          "Service Pass API Key ID" := ServicePassword.Key;
        end else begin
          ServicePassword.SavePassword(APIKeyValue);
          ServicePassword.Modify;
        end;
    end;

    procedure GetMLCredentials(var APIURL: Text[250];var APIKey: Text[200];var LimitValue: Decimal;var UsingStandardCredentials: Boolean): Boolean
    var
        ServicePassword: Record "Service Password";
        PermissionManager: Codeunit "Permission Manager";
    begin
        // user-defined credentials
        if IsAPIUserDefined then begin
          ServicePassword.Get("Service Pass API Key ID");
          APIKey := CopyStr(ServicePassword.GetPassword,1,200);
          if (APIKey = '') or ("API URL" = '') then
            exit(false);
          APIURL := "API URL";
          UsingStandardCredentials := false;
          exit(true);
        end;

        UsingStandardCredentials := true;
        // if credentials not user-defined retrieve it from Azure Key Vault
        if PermissionManager.SoftwareAsAService then
          exit(RetrieveSaaSMLCredentials(APIURL,APIKey,LimitValue));
    end;

    local procedure RetrieveSaaSMLCredentials(var APIURL: Text[250];var APIKey: Text[200];var LimitValue: Decimal): Boolean
    var
        LimitType: Option;
    begin
        if not AzureKeyVaultManagement.GetMLForecastCredentials(APIURL,APIKey,LimitType,LimitValue) then
          exit(false);
        APIURL := APIURL + '/execute?api-version=2.0&details=true';
        exit(true);
    end;

    local procedure EnableEncryption()
    var
        EncryptionManagement: Codeunit "Encryption Management";
    begin
        if not EncryptionManagement.IsEncryptionEnabled then
          EncryptionManagement.EnableEncryption;
    end;

    [Scope('Personalization')]
    procedure GetUserDefinedAPIKey(): Text[200]
    var
        ServicePassword: Record "Service Password";
    begin
        // user-defined credentials
        if not IsNullGuid("Service Pass API Key ID") then begin
          ServicePassword.Get("Service Pass API Key ID");
          exit(CopyStr(ServicePassword.GetPassword,1,200));
        end;
    end;

    [Scope('Personalization')]
    procedure IsAPIUserDefined(): Boolean
    begin
        exit(not (IsNullGuid("Service Pass API Key ID") or ("API URL" = '')));
    end;
}

