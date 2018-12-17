table 1230 "SEPA Direct Debit Mandate"
{
    // version NAVW111.00

    Caption = 'SEPA Direct Debit Mandate';
    DataCaptionFields = ID,"Customer Bank Account Code";
    DrillDownPageID = "SEPA Direct Debit Mandates";
    LookupPageID = "SEPA Direct Debit Mandates";

    fields
    {
        field(1;ID;Code[35])
        {
            Caption = 'ID';

            trigger OnValidate()
            var
                SalesSetup: Record "Sales & Receivables Setup";
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if ID <> xRec.ID then begin
                  SalesSetup.Get;
                  NoSeriesMgt.TestManual(SalesSetup."Direct Debit Mandate Nos.");
                  "No. Series" := '';
                end;
            end;
        }
        field(2;"Customer No.";Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer;

            trigger OnValidate()
            begin
                if (xRec."Customer No." <> '') and ("Customer No." <> xRec."Customer No.") then begin
                  TestField("Date of Signature",0D);
                  TestField("Debit Counter",0);
                  "Customer Bank Account Code" := '';
                end;
            end;
        }
        field(3;"Customer Bank Account Code";Code[20])
        {
            Caption = 'Customer Bank Account Code';
            NotBlank = true;
            TableRelation = "Customer Bank Account".Code WHERE ("Customer No."=FIELD("Customer No."));
        }
        field(4;"Valid From";Date)
        {
            Caption = 'Valid From';

            trigger OnValidate()
            begin
                ValidateDates;
            end;
        }
        field(5;"Valid To";Date)
        {
            Caption = 'Valid To';

            trigger OnValidate()
            begin
                ValidateDates;
            end;
        }
        field(6;"Date of Signature";Date)
        {
            Caption = 'Date of Signature';
            NotBlank = true;
        }
        field(7;"Type of Payment";Option)
        {
            Caption = 'Type of Payment';
            OptionCaption = 'OneOff,Recurrent';
            OptionMembers = OneOff,Recurrent;

            trigger OnValidate()
            begin
                if ("Type of Payment" = "Type of Payment"::OneOff) and ("Debit Counter" > 1) then
                  Error(MandateChangeErr);
                "Expected Number of Debits" := 1;
            end;
        }
        field(8;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(9;"Expected Number of Debits";Integer)
        {
            Caption = 'Expected Number of Debits';
            InitValue = 1;
            MinValue = 1;

            trigger OnValidate()
            begin
                if "Expected Number of Debits" < "Debit Counter" then
                  Error(InvalidNumberOfDebitsTxt);
                if ("Type of Payment" = "Type of Payment"::OneOff) and ("Expected Number of Debits" > 1) then
                  Error(InvalidOneOffNumOfDebitsErr);

                Closed := "Expected Number of Debits" <= "Debit Counter";
            end;
        }
        field(10;"Debit Counter";Integer)
        {
            Caption = 'Debit Counter';
            Editable = false;

            trigger OnValidate()
            begin
                if "Expected Number of Debits" < "Debit Counter" then begin
                  Message(InvalidNumberOfDebitsTxt);
                  FieldError("Debit Counter");
                end;
            end;
        }
        field(11;"No. Series";Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(12;Closed;Boolean)
        {
            Caption = 'Closed';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
        key(Key2;"Customer No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown;ID,"Customer Bank Account Code","Valid From","Valid To","Type of Payment")
        {
        }
    }

    trigger OnInsert()
    begin
        InsertNoSeries
    end;

    trigger OnModify()
    begin
        if xRec.Blocked then
          TestField(Blocked,false);
    end;

    var
        DateErr: Label 'The Valid To date must be after the Valid From date.';
        InvalidNumberOfDebitsTxt: Label 'The Debit Counter cannot be greater than the Number of Debits.';
        InvalidOneOffNumOfDebitsErr: Label 'The Number of Debits for OneOff Sequence Type cannot be greater than one.';
        MandateChangeErr: Label 'SequenceType cannot be set to OneOff, since the Mandate has already been used.';

    local procedure InsertNoSeries()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NewNo: Code[20];
    begin
        if ID = '' then begin
          SalesSetup.Get;
          SalesSetup.TestField("Direct Debit Mandate Nos.");
          NoSeriesMgt.InitSeries(SalesSetup."Direct Debit Mandate Nos.",xRec."No. Series",0D,NewNo,"No. Series");
          ID := NewNo;
        end;
    end;

    [Scope('Personalization')]
    procedure IsMandateActive(TransactionDate: Date): Boolean
    begin
        if ("Valid To" <> 0D) and ("Valid To" < TransactionDate) or ("Valid From" > TransactionDate) or Blocked or Closed then
          exit(false);
        exit(true)
    end;

    [Scope('Personalization')]
    procedure GetDefaultMandate(CustomerNo: Code[20];DueDate: Date): Code[35]
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        Customer: Record Customer;
    begin
        with SEPADirectDebitMandate do begin
          SetRange("Customer No.",CustomerNo);
          SetFilter("Valid From",'%1|<=%2',0D,DueDate);
          SetFilter("Valid To",'%1|>=%2',0D,DueDate);
          SetRange(Blocked,false);
          SetRange(Closed,false);
          if FindFirst then;
          if Customer.Get(CustomerNo) and (Customer."Preferred Bank Account Code" <> '') then
            SetRange("Customer Bank Account Code",Customer."Preferred Bank Account Code");
          if FindFirst then;
          exit(ID);
        end;
    end;

    [Scope('Personalization')]
    procedure UpdateCounter()
    begin
        TestField(Blocked,false);
        Validate("Debit Counter","Debit Counter" + 1);
        Closed := "Debit Counter" >= "Expected Number of Debits";
        Modify;
    end;

    [Scope('Personalization')]
    procedure GetSequenceType(): Integer
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
    begin
        DirectDebitCollectionEntry.Init;
        if "Type of Payment" = "Type of Payment"::OneOff then
          exit(DirectDebitCollectionEntry."Sequence Type"::"One Off");
        if "Debit Counter" = 0 then
          exit(DirectDebitCollectionEntry."Sequence Type"::First);
        if "Debit Counter" >= "Expected Number of Debits" - 1 then
          exit(DirectDebitCollectionEntry."Sequence Type"::Last);
        exit(DirectDebitCollectionEntry."Sequence Type"::Recurring);
    end;

    [Scope('Personalization')]
    procedure RollBackSequenceType()
    begin
        if "Debit Counter" <= 0 then
          exit;

        "Debit Counter" -= 1;
        Closed := "Debit Counter" >= "Expected Number of Debits";
        Modify;
    end;

    local procedure ValidateDates()
    begin
        if ("Valid To" <> 0D) and ("Valid From" > "Valid To") then
          Error(DateErr);
    end;
}

