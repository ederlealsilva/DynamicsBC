table 426 "IC Outbox Sales Header"
{
    // version NAVW113.00

    Caption = 'IC Outbox Sales Header';

    fields
    {
        field(1;"Document Type";Option)
        {
            Caption = 'Document Type';
            Editable = false;
            OptionCaption = ' ,Order,Invoice,Credit Memo,,Return Order';
            OptionMembers = " ","Order",Invoice,"Credit Memo",,"Return Order";
        }
        field(2;"Sell-to Customer No.";Code[20])
        {
            Caption = 'Sell-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(3;"No.";Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(4;"Bill-to Customer No.";Code[20])
        {
            Caption = 'Bill-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(13;"Ship-to Name";Text[50])
        {
            Caption = 'Ship-to Name';
            Editable = false;
        }
        field(15;"Ship-to Address";Text[50])
        {
            Caption = 'Ship-to Address';
            Editable = false;
        }
        field(16;"Ship-to Address 2";Text[50])
        {
            Caption = 'Ship-to Address 2';
            Editable = false;
        }
        field(17;"Ship-to City";Text[30])
        {
            Caption = 'Ship-to City';
            Editable = false;
        }
        field(20;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(24;"Due Date";Date)
        {
            Caption = 'Due Date';
        }
        field(25;"Payment Discount %";Decimal)
        {
            Caption = 'Payment Discount %';
            Editable = false;
        }
        field(26;"Pmt. Discount Date";Date)
        {
            Caption = 'Pmt. Discount Date';
            Editable = false;
        }
        field(32;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(35;"Prices Including VAT";Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(44;"Order No.";Code[20])
        {
            Caption = 'Order No.';
        }
        field(91;"Ship-to Post Code";Code[20])
        {
            Caption = 'Ship-to Post Code';
            Editable = false;
        }
        field(92;"Ship-to County";Text[30])
        {
            CaptionClass = '5,1,' + "Ship-to Country/Region Code";
            Caption = 'Ship-to County';
        }
        field(93;"Ship-to Country/Region Code";Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(99;"Document Date";Date)
        {
            Caption = 'Document Date';
        }
        field(100;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
        }
        field(125;"IC Partner Code";Code[20])
        {
            Caption = 'IC Partner Code';
            Editable = false;
            TableRelation = "IC Partner";
        }
        field(201;"IC Transaction No.";Integer)
        {
            Caption = 'IC Transaction No.';
            Editable = false;
        }
        field(202;"Transaction Source";Option)
        {
            Caption = 'Transaction Source';
            Editable = false;
            OptionCaption = 'Rejected by Current Company,Created by Current Company';
            OptionMembers = "Rejected by Current Company","Created by Current Company";
        }
        field(5790;"Requested Delivery Date";Date)
        {
            AccessByPermission = TableData "Order Promising Line"=R;
            Caption = 'Requested Delivery Date';
            Editable = false;
        }
        field(5791;"Promised Delivery Date";Date)
        {
            Caption = 'Promised Delivery Date';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;"IC Transaction No.","IC Partner Code","Transaction Source")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ICOutboxSalesLine: Record "IC Outbox Sales Line";
        DimMgt: Codeunit DimensionManagement;
    begin
        ICOutboxSalesLine.SetRange("IC Partner Code","IC Partner Code");
        ICOutboxSalesLine.SetRange("IC Transaction No.","IC Transaction No.");
        ICOutboxSalesLine.SetRange("Transaction Source","Transaction Source");
        if ICOutboxSalesLine.FindFirst then
          ICOutboxSalesLine.DeleteAll(true);
        DimMgt.DeleteICDocDim(
          DATABASE::"IC Outbox Sales Header","IC Transaction No.","IC Partner Code","Transaction Source",0);
    end;
}

