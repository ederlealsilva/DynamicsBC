codeunit 1344 "Acct. WebServices Mgt."
{
    // version NAVW111.00

    // Contains helper functions when creating web services specific to the Accounting portal.


    trigger OnRun()
    begin
    end;

    procedure SetCueStyle(TableID: Integer;FieldID: Integer;Amount: Decimal;var FinalStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate)
    var
        CueSetup: Record "Cue Setup";
        LowRangeStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        Threshold1: Decimal;
        MiddleRangeStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
        Threshold2: Decimal;
        HighRangeStyle: Option "None",,,,,,,Favorable,Unfavorable,Ambiguous,Subordinate;
    begin
        // First see if we have a record for the current user
        CueSetup.SetRange("User Name",UserId);
        CueSetup.SetRange("Table ID",TableID);
        CueSetup.SetRange("Field No.",FieldID);
        if CueSetup.FindFirst then begin
          LowRangeStyle := CueSetup."Low Range Style";
          Threshold1 := CueSetup."Threshold 1";
          MiddleRangeStyle := CueSetup."Middle Range Style";
          Threshold2 := CueSetup."Threshold 2";
          HighRangeStyle := CueSetup."High Range Style";
        end else begin
          CueSetup.Reset;
          CueSetup.SetRange("User Name",'');
          CueSetup.SetRange("Table ID",TableID);
          CueSetup.SetRange("Field No.",FieldID);
          if CueSetup.FindFirst then begin
            LowRangeStyle := CueSetup."Low Range Style";
            Threshold1 := CueSetup."Threshold 1";
            MiddleRangeStyle := CueSetup."Middle Range Style";
            Threshold2 := CueSetup."Threshold 2";
            HighRangeStyle := CueSetup."High Range Style";
          end else begin
            LowRangeStyle := CueSetup."Low Range Style"::None;
            Threshold1 := 0;
            MiddleRangeStyle := CueSetup."Middle Range Style"::None;
            Threshold2 := 0;
            HighRangeStyle := CueSetup."High Range Style"::None;
          end;
        end;

        if Amount < Threshold1 then begin
          FinalStyle := LowRangeStyle;
          exit;
        end;
        if Amount > Threshold2 then begin
          FinalStyle := HighRangeStyle;
          exit;
        end;
        FinalStyle := MiddleRangeStyle;
    end;

    procedure FormatAmountString(Amount: Decimal) FormattedAmount: Text
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        FormatString: Text;
        AmountDecimalPlaces: Text[5];
        LocalCurrencySymbol: Text[10];
    begin
        if GeneralLedgerSetup.FindFirst then begin
          AmountDecimalPlaces := GeneralLedgerSetup."Amount Decimal Places";
          LocalCurrencySymbol := GeneralLedgerSetup."Local Currency Symbol";
        end else begin
          AmountDecimalPlaces := '';
          LocalCurrencySymbol := '';
        end;

        if AmountDecimalPlaces <> '' then
          FormatString := LocalCurrencySymbol + '<Precision,' + AmountDecimalPlaces + '><Standard Format,0>';

        FormattedAmount := Format(Amount,0,FormatString);
    end;
}

