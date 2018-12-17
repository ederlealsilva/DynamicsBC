codeunit 3 "G/L Account-Indent"
{
    // version NAVW111.00


    trigger OnRun()
    begin
        if not
           Confirm(
             Text000 +
             Text001 +
             Text002 +
             Text003,true)
        then
          exit;

        Indent;
    end;

    var
        Text000: Label 'This function updates the indentation of all the G/L accounts in the chart of accounts. ';
        Text001: Label 'All accounts between a Begin-Total and the matching End-Total are indented one level. ';
        Text002: Label 'The Totaling for each End-total is also updated.';
        Text003: Label '\\Do you want to indent the chart of accounts?';
        Text004: Label 'Indenting the Chart of Accounts #1##########';
        Text005: Label 'End-Total %1 is missing a matching Begin-Total.';
        GLAcc: Record "G/L Account";
        Window: Dialog;
        AccNo: array [10] of Code[20];
        i: Integer;

    [Scope('Personalization')]
    procedure Indent()
    begin
        Window.Open(Text004);

        with GLAcc do
          if Find('-') then
            repeat
              Window.Update(1,"No.");

              if "Account Type" = "Account Type"::"End-Total" then begin
                if i < 1 then
                  Error(
                    Text005,
                    "No.");
                if Totaling = '' then
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

    [Scope('Personalization')]
    procedure RunICAccountIndent()
    begin
        if not
           Confirm(
             Text000 +
             Text001 +
             Text003,true)
        then
          exit;

        IndentICAccount;
    end;

    local procedure IndentICAccount()
    var
        ICGLAcc: Record "IC G/L Account";
    begin
        Window.Open(Text004);
        with ICGLAcc do
          if Find('-') then
            repeat
              Window.Update(1,"No.");

              if "Account Type" = "Account Type"::"End-Total" then begin
                if i < 1 then
                  Error(
                    Text005,
                    "No.");
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

