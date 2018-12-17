table 5456 "Graph Business Profile"
{
    // version NAVW113.00

    Caption = 'Graph Business Profile';
    ExternalName = 'BusinessProfile';
    TableType = MicrosoftGraph;

    fields
    {
        field(1;Id;Text[250])
        {
            Caption = 'Id';
            ExternalName = 'id';
            ExternalType = 'Edm.String';
        }
        field(2;Name;Text[250])
        {
            Caption = 'Name';
            ExternalName = 'name';
            ExternalType = 'Edm.String';
        }
        field(3;Description;Text[250])
        {
            Caption = 'Description';
            ExternalName = 'description';
            ExternalType = 'Edm.String';
        }
        field(4;Addresses;BLOB)
        {
            Caption = 'Addresses';
            ExternalName = 'addresses';
            ExternalType = 'Collection(Microsoft.SmallBusiness.C2GraphService.PhysicalAddress)';
            SubType = Json;
        }
        field(5;Currency;Code[10])
        {
            Caption = 'Currency';
            ExternalName = 'currency';
            ExternalType = 'Edm.String';
        }
        field(6;PhoneNumbers;BLOB)
        {
            Caption = 'PhoneNumbers';
            ExternalName = 'phoneNumbers';
            ExternalType = 'Collection(Microsoft.SmallBusiness.C2GraphService.Phone)';
            SubType = Json;
        }
        field(7;"Tax Id";Code[10])
        {
            Caption = 'Tax Id';
            ExternalName = 'taxId';
            ExternalType = 'Edm.String';
        }
        field(8;Industry;Text[30])
        {
            Caption = 'Industry';
            ExternalName = 'industry';
            ExternalType = 'Edm.String';
        }
        field(10;Logo;BLOB)
        {
            Caption = 'Logo';
            ExternalName = '/logo';
            ExternalType = 'Microsoft.Griffin.SmallBusiness.SbGraph.Core.MediaResource';
            SubType = Json;
        }
        field(11;LogoContent;BLOB)
        {
            Caption = 'LogoContent';
            ExternalName = '/logo/$value';
            ExternalType = 'image/png';
            SubType = Bitmap;
        }
        field(13;EmailAddresses;BLOB)
        {
            Caption = 'EmailAddresses';
            ExternalName = 'emailAddresses';
            ExternalType = 'Collection(Microsoft.SmallBusiness.C2GraphService.EmailAddress)';
            SubType = Json;
        }
        field(14;Website;BLOB)
        {
            Caption = 'Website';
            ExternalName = 'website';
            ExternalType = 'Microsoft.Griffin.SmallBusiness.SbGraph.Core.WebSite';
            SubType = Json;
        }
        field(15;IsPrimary;Boolean)
        {
            Caption = 'IsPrimary';
            Description = 'For creating BusinessProfiles, this field must be set to Yes.';
            ExternalName = 'isPrimary';
            ExternalType = 'Edm.Boolean';
            InitValue = true;
        }
        field(16;BrandColor;Code[10])
        {
            Caption = 'BrandColor';
            ExternalName = 'brandColor';
            ExternalType = 'Edm.String';
        }
        field(17;SocialLinks;BLOB)
        {
            Caption = 'SocialLinks';
            ExternalName = 'socialLinks';
            ExternalType = 'Collection(Microsoft.Griffin.SmallBusiness.SbGraph.Core.WebSite)';
            SubType = Json;
        }
        field(19;CountryCode;Code[10])
        {
            Caption = 'CountryCode';
            ExternalName = 'countryCode';
            ExternalType = 'Edm.String';
        }
        field(22;CreatedDate;DateTime)
        {
            Caption = 'CreatedDate';
            ExternalName = 'createdDate';
            ExternalType = 'Edm.DateTimeOffset';
        }
        field(23;LastModifiedDate;DateTime)
        {
            Caption = 'LastModifiedDate';
            ExternalName = 'lastModifiedDate';
            ExternalType = 'Edm.DateTimeOffset';
        }
        field(24;ETag;Text[250])
        {
            Caption = 'ETag';
            ExternalName = '@odata.etag';
            ExternalType = 'Edm.String';
        }
    }

    keys
    {
        key(Key1;Id)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetAddressesString(): Text
    begin
        exit(GetBlobString(FieldNo(Addresses)));
    end;

    procedure SetAddressesString(AddressesString: Text)
    begin
        SetBlobString(FieldNo(Addresses),AddressesString);
    end;

    procedure GetEmailAddressesString(): Text
    begin
        exit(GetBlobString(FieldNo(EmailAddresses)));
    end;

    procedure SetEmailAddressesString(EmailAddressesString: Text)
    begin
        SetBlobString(FieldNo(EmailAddresses),EmailAddressesString);
    end;

    procedure GetLogoString(): Text
    begin
        exit(GetBlobString(FieldNo(Logo)));
    end;

    procedure GetPhoneNumbersString(): Text
    begin
        exit(GetBlobString(FieldNo(PhoneNumbers)));
    end;

    procedure SetPhoneNumbersString(PhoneNumbersString: Text)
    begin
        SetBlobString(FieldNo(PhoneNumbers),PhoneNumbersString);
    end;

    procedure GetSocialLinksString(): Text
    begin
        exit(GetBlobString(FieldNo(SocialLinks)));
    end;

    procedure SetSocialLinksString(SocialLinksString: Text)
    begin
        SetBlobString(FieldNo(SocialLinks),SocialLinksString);
    end;

    procedure GetWebsiteString(): Text
    begin
        exit(GetBlobString(FieldNo(Website)));
    end;

    procedure SetWebsitesString(WebsitesString: Text)
    begin
        SetBlobString(FieldNo(Website),WebsitesString);
    end;

    local procedure GetBlobString(FieldNo: Integer): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetBlobString(Rec,FieldNo));
    end;

    local procedure SetBlobString(FieldNo: Integer;NewContent: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        TypeHelper.SetBlobString(RecordRef,FieldNo,NewContent);
        RecordRef.SetTable(Rec);
    end;
}

