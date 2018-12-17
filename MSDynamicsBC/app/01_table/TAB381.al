table 381 "VAT Registration No. Format"
{
    // version NAVW113.00

    Caption = 'VAT Registration No. Format';

    fields
    {
        field(1;"Country/Region Code";Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(3;Format;Text[20])
        {
            Caption = 'Format';
        }
    }

    keys
    {
        key(Key1;"Country/Region Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text000: Label 'The entered VAT Registration number is not in agreement with the format specified for Country/Region Code %1.\';
        Text001: Label 'The following formats are acceptable: %1', Comment='1 - format list';
        Text002: Label 'This VAT registration number has already been entered for the following customers:\ %1';
        Text003: Label 'This VAT registration number has already been entered for the following vendors:\ %1';
        Text004: Label 'This VAT registration number has already been entered for the following contacts:\ %1';
        Text005: Label 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        InvalidVatNumberErr: Label 'Enter a valid VAT number, for example ''GB123456789''.';
        IdentityManagement: Codeunit "Identity Management";

    [Scope('Personalization')]
    procedure Test(VATRegNo: Text[20];CountryCode: Code[10];Number: Code[20];TableID: Option): Boolean
    var
        CompanyInfo: Record "Company Information";
        Check: Boolean;
        Finish: Boolean;
        t: Text;
    begin
        VATRegNo := UpperCase(VATRegNo);
        if VATRegNo = '' then
          exit;
        Check := true;

        if CountryCode = '' then begin
          if not CompanyInfo.Get then
            exit;
          SetRange("Country/Region Code",CompanyInfo."Country/Region Code");
        end else
          SetRange("Country/Region Code",CountryCode);
        SetFilter(Format,'<> %1','');
        if FindSet then
          repeat
            AppendString(t,Finish,Format);
            Check := Compare(VATRegNo,Format);
          until Check or (Next = 0);

        if not Check then begin
          if IdentityManagement.IsInvAppId then
            Error(InvalidVatNumberErr);
          Error(StrSubstNo('%1%2',StrSubstNo(Text000,"Country/Region Code"),StrSubstNo(Text001,t)));
        end;

        case TableID of
          DATABASE::Customer:
            CheckCust(VATRegNo,Number);
          DATABASE::Vendor:
            CheckVendor(VATRegNo,Number);
          DATABASE::Contact:
            CheckContact(VATRegNo,Number);
        end;
        exit(true);
    end;

    local procedure CheckCust(VATRegNo: Text[20];Number: Code[20])
    var
        Cust: Record Customer;
        Check: Boolean;
        Finish: Boolean;
        t: Text;
        CustomerIdentification: Text[50];
    begin
        Check := true;
        t := '';
        Cust.SetCurrentKey("VAT Registration No.");
        Cust.SetRange("VAT Registration No.",VATRegNo);
        Cust.SetFilter("No.",'<>%1',Number);
        if Cust.FindSet then begin
          Check := false;
          Finish := false;
          repeat
            if IdentityManagement.IsInvAppId then
              CustomerIdentification := Cust.Name
            else
              CustomerIdentification := Cust."No.";

            AppendString(t,Finish,CustomerIdentification);
          until (Cust.Next = 0) or Finish;
        end;
        if Check = false then
          Message(StrSubstNo(Text002,t));
    end;

    local procedure CheckVendor(VATRegNo: Text[20];Number: Code[20])
    var
        Vend: Record Vendor;
        Check: Boolean;
        Finish: Boolean;
        t: Text;
    begin
        Check := true;
        t := '';
        Vend.SetCurrentKey("VAT Registration No.");
        Vend.SetRange("VAT Registration No.",VATRegNo);
        Vend.SetFilter("No.",'<>%1',Number);
        if Vend.FindSet then begin
          Check := false;
          Finish := false;
          repeat
            AppendString(t,Finish,Vend."No.");
          until (Vend.Next = 0) or Finish;
        end;
        if Check = false then
          Message(StrSubstNo(Text003,t));
    end;

    local procedure CheckContact(VATRegNo: Text[20];Number: Code[20])
    var
        Cont: Record Contact;
        Check: Boolean;
        Finish: Boolean;
        t: Text;
    begin
        Check := true;
        t := '';
        Cont.SetCurrentKey("VAT Registration No.");
        Cont.SetRange("VAT Registration No.",VATRegNo);
        Cont.SetFilter("No.",'<>%1',Number);
        if Cont.FindSet then begin
          Check := false;
          Finish := false;
          repeat
            AppendString(t,Finish,Cont."No.");
          until (Cont.Next = 0) or Finish;
        end;
        if Check = false then
          Message(StrSubstNo(Text004,t));
    end;

    [Scope('Personalization')]
    procedure Compare(VATRegNo: Text[20];Format: Text[20]): Boolean
    var
        i: Integer;
        Cf: Text[1];
        Ce: Text[1];
        Check: Boolean;
    begin
        Check := true;
        if StrLen(VATRegNo) = StrLen(Format) then
          for i := 1 to StrLen(VATRegNo) do begin
            Cf := CopyStr(Format,i,1);
            Ce := CopyStr(VATRegNo,i,1);
            case Cf of
              '#':
                if not ((Ce >= '0') and (Ce <= '9')) then
                  Check := false;
              '@':
                if StrPos(Text005,UpperCase(Ce)) = 0 then
                  Check := false;
              else
                if not ((Cf = Ce) or (Cf = '?')) then
                  Check := false
            end;
          end
        else
          Check := false;
        exit(Check);
    end;

    local procedure AppendString(var String: Text;var Finish: Boolean;AppendText: Text)
    begin
        case true of
          Finish:
            exit;
          String = '':
            String := AppendText;
          StrLen(String) + StrLen(AppendText) + 5 <= 250:
            String += ', ' + AppendText;
          else begin
            String += '...';
            Finish := true;
          end;
        end;
    end;
}

