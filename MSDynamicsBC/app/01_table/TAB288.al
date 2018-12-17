table 288 "Vendor Bank Account"
{
    // version NAVW113.00

    Caption = 'Vendor Bank Account';
    DataCaptionFields = "Vendor No.","Code",Name;
    DrillDownPageID = "Vendor Bank Account List";
    LookupPageID = "Vendor Bank Account List";

    fields
    {
        field(1;"Vendor No.";Code[20])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(2;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(5;"Name 2";Text[50])
        {
            Caption = 'Name 2';
        }
        field(6;Address;Text[50])
        {
            Caption = 'Address';
        }
        field(7;"Address 2";Text[50])
        {
            Caption = 'Address 2';
        }
        field(8;City;Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code"=CONST('')) "Post Code".City
                            ELSE IF ("Country/Region Code"=FILTER(<>'')) "Post Code".City WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City,"Post Code",County,"Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(9;"Post Code";Code[20])
        {
            Caption = 'Post Code';
            TableRelation = IF ("Country/Region Code"=CONST('')) "Post Code"
                            ELSE IF ("Country/Region Code"=FILTER(<>'')) "Post Code" WHERE ("Country/Region Code"=FIELD("Country/Region Code"));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City,"Post Code",County,"Country/Region Code",(CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(10;Contact;Text[50])
        {
            Caption = 'Contact';
        }
        field(11;"Phone No.";Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        field(12;"Telex No.";Text[20])
        {
            Caption = 'Telex No.';
        }
        field(13;"Bank Branch No.";Text[20])
        {
            Caption = 'Bank Branch No.';
        }
        field(14;"Bank Account No.";Text[30])
        {
            Caption = 'Bank Account No.';
        }
        field(15;"Transit No.";Text[20])
        {
            Caption = 'Transit No.';
        }
        field(16;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(17;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(18;County;Text[30])
        {
            CaptionClass = '5,1,' + "Country/Region Code";
            Caption = 'County';
        }
        field(19;"Fax No.";Text[30])
        {
            Caption = 'Fax No.';
        }
        field(20;"Telex Answer Back";Text[20])
        {
            Caption = 'Telex Answer Back';
        }
        field(21;"Language Code";Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language;
        }
        field(22;"E-Mail";Text[80])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("E-Mail");
            end;
        }
        field(23;"Home Page";Text[80])
        {
            Caption = 'Home Page';
            ExtendedDatatype = URL;
        }
        field(24;IBAN;Code[50])
        {
            Caption = 'IBAN';

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
        }
        field(25;"SWIFT Code";Code[20])
        {
            Caption = 'SWIFT Code';
        }
        field(1211;"Bank Clearing Code";Text[50])
        {
            Caption = 'Bank Clearing Code';
        }
        field(1212;"Bank Clearing Standard";Text[50])
        {
            Caption = 'Bank Clearing Standard';
            TableRelation = "Bank Clearing Standard";
        }
    }

    keys
    {
        key(Key1;"Vendor No.","Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;"Code",Name,"Phone No.",Contact)
        {
        }
    }

    trigger OnDelete()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        VendorLedgerEntry.SetRange("Vendor No.","Vendor No.");
        VendorLedgerEntry.SetRange("Recipient Bank Account",Code);
        VendorLedgerEntry.SetRange(Open,true);
        if not VendorLedgerEntry.IsEmpty then
          Error(BankAccDeleteErr);
        if Vendor.Get("Vendor No.") and (Vendor."Preferred Bank Account Code" = Code) then begin
          Vendor."Preferred Bank Account Code" := '';
          Vendor.Modify;
        end;
    end;

    var
        PostCode: Record "Post Code";
        BankAccIdentifierIsEmptyErr: Label 'You must specify either a Bank Account No. or an IBAN.';
        BankAccDeleteErr: Label 'You cannot delete this bank account because it is associated with one or more open ledger entries.';

    [Scope('Personalization')]
    procedure GetBankAccountNoWithCheck() AccountNo: Text
    begin
        AccountNo := GetBankAccountNo;
        if AccountNo = '' then
          Error(BankAccIdentifierIsEmptyErr);
    end;

    [Scope('Personalization')]
    procedure GetBankAccountNo(): Text
    begin
        if IBAN <> '' then
          exit(DelChr(IBAN,'=<>'));

        if "Bank Account No." <> '' then
          exit("Bank Account No.");
    end;
}

