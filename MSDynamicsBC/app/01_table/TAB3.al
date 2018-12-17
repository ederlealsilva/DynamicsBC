table 3 "Payment Terms"
{
    // version NAVW113.00

    Caption = 'Payment Terms';
    DataCaptionFields = "Code",Description;
    LookupPageID = "Payment Terms";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;"Due Date Calculation";DateFormula)
        {
            Caption = 'Due Date Calculation';
        }
        field(3;"Discount Date Calculation";DateFormula)
        {
            Caption = 'Discount Date Calculation';
        }
        field(4;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:5;
            MaxValue = 100;
            MinValue = 0;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(6;"Calc. Pmt. Disc. on Cr. Memos";Boolean)
        {
            Caption = 'Calc. Pmt. Disc. on Cr. Memos';
        }
        field(8;"Last Modified Date Time";DateTime)
        {
            Caption = 'Last Modified Date Time';
            Editable = false;
        }
        field(8000;Id;Guid)
        {
            Caption = 'Id';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;"Code",Description,"Due Date Calculation")
        {
        }
        fieldgroup(Brick;"Code",Description,"Due Date Calculation")
        {
        }
    }

    trigger OnDelete()
    var
        PaymentTermsTranslation: Record "Payment Term Translation";
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
    begin
        if IdentityManagement.IsInvAppId then
          if O365SalesInitialSetup.Get and
             (O365SalesInitialSetup."Default Payment Terms Code" = Code)
          then
            Error(CannotRemoveDefaultPaymentTermsErr);

        with PaymentTermsTranslation do begin
          SetRange("Payment Term",Code);
          DeleteAll
        end;
    end;

    trigger OnInsert()
    begin
        SetLastModifiedDateTime;
    end;

    trigger OnModify()
    begin
        SetLastModifiedDateTime;
    end;

    trigger OnRename()
    begin
        SetLastModifiedDateTime;
    end;

    var
        IdentityManagement: Codeunit "Identity Management";
        CannotRemoveDefaultPaymentTermsErr: Label 'You cannot remove the default payment terms.';

    local procedure SetLastModifiedDateTime()
    begin
        "Last Modified Date Time" := CurrentDateTime;
    end;

    [Scope('Personalization')]
    procedure TranslateDescription(var PaymentTerms: Record "Payment Terms";Language: Code[10])
    var
        PaymentTermsTranslation: Record "Payment Term Translation";
    begin
        if PaymentTermsTranslation.Get(PaymentTerms.Code,Language) then
          PaymentTerms.Description := PaymentTermsTranslation.Description;
    end;

    procedure GetDescriptionInCurrentLanguage(): Text[50]
    var
        Language: Record Language;
        PaymentTermTranslation: Record "Payment Term Translation";
    begin
        if PaymentTermTranslation.Get(Code,Language.GetUserLanguage) then
          exit(PaymentTermTranslation.Description);

        exit(Description);
    end;

    [Scope('Personalization')]
    procedure UsePaymentDiscount(): Boolean
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.SetFilter("Discount %",'<>%1',0);

        exit(not PaymentTerms.IsEmpty);
    end;
}

