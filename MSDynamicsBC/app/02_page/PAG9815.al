page 9815 "Std. Password Dialog"
{
    // version NAVW111.00

    Caption = 'Set Password';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(SetPassword;SetPassword)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password for this task. The password must consist of 8 or more characters, at least one uppercase letter, one lowercase letter, and one number.';

                trigger OnValidate()
                begin
                    if ValidatePassword and not IdentityManagement.ValidatePasswordStrength(SetPassword) then
                      Error(PasswordTooSimpleErr);
                end;
            }
            field(ConfirmPassword;ConfirmPassword)
            {
                ApplicationArea = All;
                Caption = 'Confirm Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password repeated.';
                Visible = RequiresPasswordConfirmation;

                trigger OnValidate()
                begin
                    if RequiresPasswordConfirmation and (SetPassword <> ConfirmPassword) then
                      Error(PasswordMismatchErr);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        ValidatePassword := true;
        RequiresPasswordConfirmation := true;
    end;

    trigger OnOpenPage()
    begin
        ValidPassword := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        ValidPassword := false;
        if CloseAction = ACTION::OK then begin
          if RequiresPasswordConfirmation and (SetPassword <> ConfirmPassword) then
            Error(PasswordMismatchErr);
          if EnableBlankPasswordState and (SetPassword = '') then begin
            if not Confirm(ConfirmBlankPasswordQst) then
              Error(PasswordTooSimpleErr);
          end else begin
            if SetPassword = '' then
              Error(PasswordBlankIsNotAllowedErr);
            if ValidatePassword and not IdentityManagement.ValidatePasswordStrength(SetPassword) then
              Error(PasswordTooSimpleErr);
          end;
          ValidPassword := true;
        end
    end;

    var
        PasswordMismatchErr: Label 'The specified passwords are not the same.';
        PasswordTooSimpleErr: Label 'The specified password does not meet the requirements. It must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number.';
        PasswordNotValidatedErr: Label 'The password did not validate correctly, or it was not accepted.';
        PasswordBlankIsNotAllowedErr: Label 'You must enter a password.';
        ConfirmBlankPasswordQst: Label 'Do you want to exit without entering a password?';
        IdentityManagement: Codeunit "Identity Management";
        [InDataSet]
        SetPassword: Text[250];
        [InDataSet]
        ConfirmPassword: Text[250];
        ValidPassword: Boolean;
        EnableBlankPasswordState: Boolean;
        ValidatePassword: Boolean;
        GetPasswordCaptionTxt: Label 'Enter Password';
        RequiresPasswordConfirmation: Boolean;

    [Scope('Personalization')]
    procedure GetPasswordValue(): Text
    begin
        if ValidPassword = true then
          exit(SetPassword);

        Error(PasswordNotValidatedErr);
    end;

    [Scope('Personalization')]
    procedure EnableBlankPassword(enable: Boolean)
    begin
        EnableBlankPasswordState := enable;
    end;

    [Scope('Personalization')]
    procedure EnableGetPasswordMode(NewValidatePassword: Boolean)
    begin
        ValidatePassword := NewValidatePassword;
        CurrPage.Caption := GetPasswordCaptionTxt;
    end;

    [Scope('Personalization')]
    procedure DisablePasswordConfirmation()
    begin
        RequiresPasswordConfirmation := false;
    end;
}

