codeunit 849 "Cash Flow Account - Indent"
{
    // version NAVW19.00


    trigger OnRun()
    begin
        if not
           Confirm(
             Text1000 +
             Text1003,true)
        then
          exit;

        Indentation;
    end;

    var
        Text1000: Label 'This function updates the indentation of all the cash flow accounts in the chart of cash flow accounts. All accounts between a Begin-Total and the matching End-Total are indented one level. The Totaling for each End-total is also updated.\\';
        Text1003: Label 'Do you want to indent the chart of accounts?';
        Text1004: Label 'Indenting the Chart of Accounts #1##########';
        Text1005: Label 'End-Total %1 is missing a matching Begin-Total.';
        CFAccount: Record "Cash Flow Account";
        Window: Dialog;
        AccNo: array [10] of Code[20];
        i: Integer;

    local procedure Indentation()
    begin
        Window.Open(Text1004);

        with CFAccount do
          if Find('-') then
            repeat
              Window.Update(1,"No.");

              if "Account Type" = "Account Type"::"End-Total" then begin
                if i < 1 then
                  Error(
                    Text1005,
                    "No.");
                Totaling := AccNo[i] + '..' + "No.";
                i := i - 1;
              end;

              Indentation := i;
              Modify;

              if "Account Type" = "Account Type"::"Begin-Total" then begin
                i := i + 1;
                AccNo[i] := "No.";
              end;
            until Next = 0;

        Window.Close;
    end;
}

