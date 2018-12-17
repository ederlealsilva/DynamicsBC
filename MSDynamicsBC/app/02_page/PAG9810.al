page 9810 "Set Password"
{
    // version NAVW110.0

    Caption = 'Set Password';
    DataCaptionExpression = "Full Name";
    PageType = StandardDialog;
    SourceTable = User;

    layout
    {
        area(content)
        {
            field("<SetPassword>";SetPassword)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Password';
                ExtendedDatatype = Masked;

                trigger OnValidate()
                begin
                    if not IdentityManagement.ValidatePasswordStrength(SetPassword) then
                      Error(Text002);
                end;
            }
            field("<ConfirmPassword>";ConfirmPassword)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Confirm Password';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password repeated.';

                trigger OnValidate()
                begin
                    if SetPassword <> ConfirmPassword then
                      Error(Text001);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::OK then begin
          if SetPassword <> ConfirmPassword then
            Error(Text001);
          if IdentityManagement.ValidatePasswordStrength(SetPassword) then begin
            SetUserPassword("User Security ID",SetPassword);
          end else
            Error(Text002);
        end
    end;

    var
        Text001: Label 'The passwords that you entered do not match.';
        Text002: Label 'The password that you entered does not meet the minimum requirements. It must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number.';
        IdentityManagement: Codeunit "Identity Management";
        [InDataSet]
        SetPassword: Text[250];
        [InDataSet]
        ConfirmPassword: Text[250];
}

