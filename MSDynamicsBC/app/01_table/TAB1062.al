table 1062 "Payment Reporting Argument"
{
    // version NAVW113.00

    Caption = 'Payment Reporting Argument';

    fields
    {
        field(1;"Key";Integer)
        {
            AutoIncrement = true;
            Caption = 'Key';
        }
        field(3;"Document Record ID";RecordID)
        {
            Caption = 'Document Record ID';
            DataClassification = SystemMetadata;
        }
        field(4;"Setup Record ID";RecordID)
        {
            Caption = 'Setup Record ID';
            DataClassification = SystemMetadata;
        }
        field(10;Logo;BLOB)
        {
            Caption = 'Logo';
        }
        field(12;"URL Caption";Text[250])
        {
            Caption = 'URL Caption';
        }
        field(13;"Target URL";BLOB)
        {
            Caption = 'Service URL';
        }
        field(30;"Language Code";Code[10])
        {
            Caption = 'Language Code';
        }
        field(35;"Payment Service ID";Integer)
        {
            Caption = 'Payment Service ID';
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PaymentServiceID: Option ,PayPal,"MS Wallet",WorldPay;

    [Scope('Personalization')]
    procedure GetTargetURL() TargetURL: Text
    var
        InStream: InStream;
    begin
        CalcFields("Target URL");
        if "Target URL".HasValue then begin
          "Target URL".CreateInStream(InStream);
          InStream.Read(TargetURL);
        end;
    end;

    [Scope('Personalization')]
    procedure SetTargetURL(ServiceURL: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        OutStream: OutStream;
    begin
        WebRequestHelper.IsValidUri(ServiceURL);
        WebRequestHelper.IsHttpUrl(ServiceURL);

        "Target URL".CreateOutStream(OutStream);
        OutStream.Write(ServiceURL);
        Modify;
    end;

    [Scope('Personalization')]
    procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode <> '' then
          exit(CurrencyCode);

        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.GetCurrencyCode(CurrencyCode);
        exit(GeneralLedgerSetup."LCY Code");
    end;

    [Scope('Personalization')]
    procedure GetPayPalServiceID(): Integer
    begin
        exit(PaymentServiceID::PayPal);
    end;

    [Scope('Personalization')]
    procedure GetMSWalletServiceID(): Integer
    begin
        exit(PaymentServiceID::"MS Wallet");
    end;

    [Scope('Personalization')]
    procedure GetWorldPayServiceID(): Integer
    begin
        exit(PaymentServiceID::WorldPay);
    end;

    procedure GetPayPalLogoFile(): Text
    begin
        exit('Payment service - PayPal-logo.png');
    end;

    procedure GetMSWalletLogoFile(): Text
    begin
        exit('Payment service - Microsoft-logo.png');
    end;

    procedure GetWorldPayLogoFile(): Text
    begin
        exit('Payment service - WorldPay-logo.png');
    end;
}

