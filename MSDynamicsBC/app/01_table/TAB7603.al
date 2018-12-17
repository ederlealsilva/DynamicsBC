table 7603 "Customized Calendar Entry"
{
    // version NAVW113.00

    Caption = 'Customized Calendar Entry';

    fields
    {
        field(1;"Source Type";Option)
        {
            Caption = 'Source Type';
            Editable = false;
            OptionCaption = 'Company,Customer,Vendor,Location,Shipping Agent,Service';
            OptionMembers = Company,Customer,Vendor,Location,"Shipping Agent",Service;
        }
        field(2;"Source Code";Code[20])
        {
            Caption = 'Source Code';
            Editable = false;
        }
        field(3;"Additional Source Code";Code[20])
        {
            Caption = 'Additional Source Code';
        }
        field(4;"Base Calendar Code";Code[10])
        {
            Caption = 'Base Calendar Code';
            Editable = false;
            TableRelation = "Base Calendar";
        }
        field(5;Date;Date)
        {
            Caption = 'Date';
            Editable = false;
        }
        field(6;Description;Text[30])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                UpdateExceptionEntry;
            end;
        }
        field(7;Nonworking;Boolean)
        {
            Caption = 'Nonworking';
            Editable = true;

            trigger OnValidate()
            begin
                UpdateExceptionEntry;
            end;
        }
    }

    keys
    {
        key(Key1;"Source Type","Source Code","Additional Source Code","Base Calendar Code",Date)
        {
        }
    }

    fieldgroups
    {
    }

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Location: Record Location;
        ServMgtsetup: Record "Service Mgt. Setup";
        ShippingAgentService: Record "Shipping Agent Services";

    local procedure UpdateExceptionEntry()
    var
        CalendarException: Record "Customized Calendar Change";
    begin
        CalendarException.SetRange("Source Type","Source Type");
        CalendarException.SetRange("Source Code","Source Code");
        CalendarException.SetRange("Base Calendar Code","Base Calendar Code");
        CalendarException.SetRange(Date,Date);
        CalendarException.DeleteAll;
        CalendarException.Init;
        CalendarException."Source Type" := "Source Type";
        CalendarException."Source Code" := "Source Code";
        CalendarException."Base Calendar Code" := "Base Calendar Code";
        CalendarException.Validate(Date,Date);
        CalendarException.Nonworking := Nonworking;
        CalendarException.Description := Description;
        CalendarException.Insert;
    end;

    [Scope('Personalization')]
    procedure GetCaption(): Text[250]
    begin
        case "Source Type" of
          "Source Type"::Company:
            exit(CompanyName);
          "Source Type"::Customer:
            if Customer.Get("Source Code") then
              exit("Source Code" + ' ' + Customer.Name);
          "Source Type"::Vendor:
            if Vendor.Get("Source Code") then
              exit("Source Code" + ' ' + Vendor.Name);
          "Source Type"::Location:
            if Location.Get("Source Code") then
              exit("Source Code" + ' ' + Location.Name);
          "Source Type"::"Shipping Agent":
            if ShippingAgentService.Get("Source Code","Additional Source Code") then
              exit("Source Code" + ' ' + "Additional Source Code" + ' ' + ShippingAgentService.Description);
          "Source Type"::Service:
            if ServMgtsetup.Get then
              exit("Source Code" + ' ' + ServMgtsetup.TableCaption);
        end;
    end;
}

