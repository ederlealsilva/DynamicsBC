page 1260 "Bank Data Conv. Service Setup"
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Bank Data Conv. Service Setup';
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Page,Bank Name,Encryption';
    SourceTable = "Bank Data Conv. Service Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("User Name";"User Name")
                {
                    ApplicationArea = Basic,Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the user name that represents your company''s sign-up for the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files.';
                }
                field(Password;Password)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Password';
                    Editable = CurrPageEditable;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    ToolTip = 'Specifies your company''s password to the service that converts bank data to the format required by your bank. The password that you enter in the Password field must be the same as on the service provider''s sign-on page.';

                    trigger OnValidate()
                    begin
                        SavePassword(Password);
                        Commit;
                        if Password <> '' then
                          CheckEncryption;
                    end;
                }
            }
            group(Servcie)
            {
                Caption = 'Service';
                field("Sign-up URL";"Sign-up URL")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the sign-up page for the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. This is the web page where you enter your company''s user name and password to sign up for the service.';
                }
                field("Service URL";"Service URL")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the address of the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. The service specified in the Service URL field is called when users export or import bank files.';
                }
                field("Support URL";"Support URL")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the web site where the provider of the bank data conversion service publishes status and support information about the service.';
                }
                field("Namespace API Version";"Namespace API Version")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the default namespace for the bank data conversion service.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SetURLsToDefault)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Set URLs to Default';
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Change the Service, Support and Sign-up URLs to their default values. You cannot cancel this action to revert back to the current values.';

                trigger OnAction()
                begin
                    SetURLsToDefault;
                end;
            }
        }
        area(navigation)
        {
            action(BankList)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Bank Name - Data Conversion List';
                Image = ListPage;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = Page "Bank Name - Data Conv. List";
                RunPageMode = View;
                ToolTip = 'View or update the list of banks in your country/region that you can use to import or export bank account data using the Bank Data Conversion Service.';
            }
            action(EncryptionManagement)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Encryption Management';
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                RunObject = Page "Data Encryption Management";
                RunPageMode = View;
                ToolTip = 'Enable or disable data encryption. Data encryption helps make sure that unauthorized users cannot read business data.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPageEditable := CurrPage.Editable;

        if HasPassword then
          Password := 'Password Dots';
    end;

    trigger OnOpenPage()
    begin
        CheckedEncryption := false;
        if not Get then begin
          Init;
          Insert(true);
        end;
    end;

    var
        Password: Text[50];
        CheckedEncryption: Boolean;
        EncryptionIsNotActivatedQst: Label 'Data encryption is not activated. It is recommended that you encrypt data. \Do you want to open the Data Encryption Management window?';
        CurrPageEditable: Boolean;

    local procedure CheckEncryption()
    begin
        if not CheckedEncryption and not EncryptionEnabled then begin
          CheckedEncryption := true;
          if Confirm(EncryptionIsNotActivatedQst) then begin
            PAGE.Run(PAGE::"Data Encryption Management");
            CheckedEncryption := false;
          end;
        end;
    end;
}

