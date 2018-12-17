table 9900 "Web Service Aggregate"
{
    // version NAVW113.00

    Caption = 'Web Service Aggregate';
    DataPerCompany = false;

    fields
    {
        field(3;"Object Type";Option)
        {
            Caption = 'Object Type';
            OptionCaption = ',,,,,Codeunit,,,Page,Query';
            OptionMembers = ,,,,,"Codeunit",,,"Page","Query";
        }
        field(6;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = AllObjWithCaption."Object ID" WHERE ("Object Type"=FIELD("Object Type"));
        }
        field(9;"Service Name";Text[240])
        {
            Caption = 'Service Name';
        }
        field(12;Published;Boolean)
        {
            Caption = 'Published';
        }
        field(15;"All Tenants";Boolean)
        {
            Caption = 'All Tenants';
        }
    }

    keys
    {
        key(Key1;"Object Type","Service Name")
        {
        }
        key(Key2;"Object Type","Object ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        // When deleting an existing web service record...
        // Deleting a tenant record will delete the tenant record.
        // Deleting a system record will delete the system record.
        if xRec."All Tenants" then begin
          if WebService.Get(xRec."Object Type",xRec."Service Name") then
            WebService.Delete;
        end else
          if TenantWebService.Get(xRec."Object Type",xRec."Service Name") then
            TenantWebService.Delete;
    end;

    trigger OnInsert()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        AssertValidRec;

        // Adding a new web service with the same Object Type and Service Name as an existing record
        // (system or tenant record) will result in a duplicate service error the same as today
        // =>  This scenario is covered by the PK on all tables involved.

        // We also want all of published services to have unique names whatever their Object Type is.
        // Otherwise, there is no difference in requesting, for example, page and query with the same Service Names
        // via OData, and metadata can not be generated.
        AssertUniquePublishedServiceName;

        // Adding a new record for an Object (Type and ID) that has an unpublished system record
        // will give the following record/row error (Message:  The web service can't be added
        // because it conflicts with an unpublished system web service for the object.)
        Clear(WebService);
        WebService.SetRange("Object Type","Object Type");
        WebService.SetRange("Object ID","Object ID");
        WebService.SetRange(Published,false);

        if not WebService.IsEmpty then
          Error(WebServiceNotAllowedErr);

        WebService.Reset;

        // If the all tenants checkbox is selected, then create the web service record as a system
        // record, otherwise create as a tenant record
        if "All Tenants" then begin
          Clear(WebService);
          WebService.TransferFields(Rec);
          WebService.Insert;
        end else begin
          Clear(TenantWebService);
          TenantWebService.TransferFields(Rec);
          TenantWebService.Insert;
        end
    end;

    trigger OnModify()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        AssertValidRec;
        AssertUniquePublishedServiceName;

        if "All Tenants" <> xRec."All Tenants" then
          if not "All Tenants" and xRec."All Tenants" then begin
            // Unselecting the all tenants checkbox will remove the system record and add a tenant record if one
            // doesn't already exist.
            if WebService.Get(xRec."Object Type",xRec."Service Name") then
              WebService.Delete;

            if not TenantWebService.Get("Object Type","Service Name") then begin
              Clear(TenantWebService);
              TenantWebService.TransferFields(Rec);
              TenantWebService.Insert;
            end
          end else begin
            // Selecting the all tenants checkbox will add a system record.
            Clear(WebService);
            WebService.TransferFields(Rec);
            WebService.Insert;
          end
        else
          // Changing the Object Type, Object ID, Service Name, and Publish fields of a system record will
          // change the value in the system record.
          if "All Tenants" then
            if WebService.Get("Object Type","Service Name") then begin
              // There is an existing record, so modify it.
              WebService."Object ID" := "Object ID";
              WebService.Published := Published;
              WebService.Modify;
            end else begin
              // There is no existing record, so insert one.
              Clear(WebService);
              WebService.TransferFields(Rec);
              WebService.Insert;
            end
          else begin
            // Changing the Object Type, Object ID, Service Name, and Publish fields of a tenant record will
            // change the value in the tenant record.
            // i.  Changing the web service to have the same Object Type and Service Name as an existing
            // record (system or tenant record) will result in a duplicate error the same as today.
            // =>  This scenario is covered by keys on the Web Service Aggregate table.
            // ii. Changing the web service to have the same Object (Type and ID) as an Unpublished system
            // record will give the following record/row error. (Message:  The web service can't be modified
            // because it conflicts with an unpublished system web service for the object.

            AssertModAllowed;

            if TenantWebService.Get("Object Type","Service Name") then begin
              TenantWebService."Object ID" := "Object ID";
              TenantWebService.Published := Published;
              TenantWebService.Modify
            end else begin
              TenantWebService.TransferFields(Rec);
              TenantWebService.Insert;
            end
          end
    end;

    trigger OnRename()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        AssertUniquePublishedServiceName;

        if "All Tenants" = xRec."All Tenants" then
          if "All Tenants" then begin
            // Changing the Object Type, Object ID, Service Name, and Publish fields of a system record will
            // change the value in the system record.
            if WebService.Get(xRec."Object Type",xRec."Service Name") then
              WebService.Rename("Object Type","Service Name");

            if WebService.Get("Object Type","Service Name") then begin
              WebService."Object ID" := "Object ID";
              WebService.Published := Published;
              WebService.Modify
            end else begin
              WebService.TransferFields(Rec);
              WebService.Insert;
            end
          end else begin
            // Changing the Object Type, Object ID, Service Name, and Publish fields of a tenant record will
            // change the value in the tenant record.
            // i.  Changing the web service to have the same Object Type and Service Name as an existing
            // record (system or tenant record) will result in a duplicate error the same as today.
            // =>  This scenario is covered by keys on the Web Service Aggregate table.
            // ii. Changing the web service to have the same Object (Type and ID) as an Unpublished system
            // record will give the following record/row error. (Message:  The web service can't be modified
            // because it conflicts with an unpublished system web service for the object.

            AssertModAllowed;

            if TenantWebService.Get(xRec."Object Type",xRec."Service Name") then
              TenantWebService.Rename("Object Type","Service Name");

            if TenantWebService.Get("Object Type","Service Name") then begin
              TenantWebService."Object ID" := "Object ID";
              TenantWebService.Published := Published;
              TenantWebService.Modify
            end else begin
              TenantWebService.TransferFields(Rec);
              TenantWebService.Insert;
            end
          end
        else
          if not "All Tenants" and xRec."All Tenants" then begin
            // Unselecting the all tenants checkbox will remove the system record and add a tenant record if one
            // doesn't already exist.
            if WebService.Get(xRec."Object Type",xRec."Service Name") then
              WebService.Delete;

            if not TenantWebService.Get("Object Type","Service Name") then begin
              Clear(TenantWebService);
              TenantWebService.TransferFields(Rec);
              TenantWebService.Insert;
            end
          end else begin
            // Selecting the all tenants checkbox will add a system record.
            Clear(WebService);
            WebService.TransferFields(Rec);
            WebService.Insert;
          end
    end;

    var
        NotApplicableTxt: Label 'Not applicable';
        WebServiceNotAllowedErr: Label 'The web service cannot be added because it conflicts with an unpublished system web service for the object.';
        WebServiceModNotAllowedErr: Label 'The web service cannot be modified because it conflicts with an unpublished system web service for the object.';
        WebServiceAlreadyPublishedErr: Label 'The web service name %1 already exists.  Enter a different service name.', Comment='%1 = Web Service name';

    local procedure AssertModAllowed()
    var
        WebService: Record "Web Service";
    begin
        WebService.SetRange("Object Type","Object Type");
        WebService.SetRange("Object ID","Object ID");
        WebService.SetRange(Published,false);

        if not WebService.IsEmpty then
          Error(WebServiceModNotAllowedErr);
    end;

    local procedure AssertValidRec()
    var
        AllObj: Record AllObj;
    begin
        TestField("Object ID");
        TestField("Service Name");
        if not ("Object Type" in ["Object Type"::Codeunit,"Object Type"::Page,"Object Type"::Query]) then
          FieldError("Object Type");
        if ("Object Type" = "Object Type"::Page) and
           ("Object ID" = PAGE::"Web Services")
        then
          FieldError("Object ID");
        AllObj.Get("Object Type","Object ID");
    end;

    local procedure AssertUniquePublishedServiceName()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        if ((("Service Name" <> xRec."Service Name") or (Published <> xRec.Published)) and
            (Published = true) and ("Object Type" <> "Object Type"::Codeunit))
        then begin
          // check that this service name does not exist in the list of all-tenant services
          // or in per tenant web services table
          WebService.SetRange(Published,true);
          WebService.SetRange("Service Name","Service Name");
          TenantWebService.SetRange(Published,true);
          TenantWebService.SetRange("Service Name","Service Name");
          // Codeunits use SOAP protocol and do not cause any troubles if they have the same name
          WebService.SetRange("Object Type","Object Type"::Page,"Object Type"::Query);
          TenantWebService.SetRange("Object Type","Object Type"::Page,"Object Type"::Query);
          if (not WebService.IsEmpty) or (not TenantWebService.IsEmpty) then
            Error(WebServiceAlreadyPublishedErr,"Service Name");
        end;
    end;

    procedure GetODataUrl(): Text
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        ODataServiceRootUrl: Text;
        ODataUrl: Text;
        ObjectTypeParam: Option ,,,,,,,,"Page","Query";
    begin
        if "All Tenants" then begin
          Clear(WebService);
          WebService.Init;
          WebService.TransferFields(Rec);

          case "Object Type" of
            "Object Type"::Page:
              exit(GetUrl(CLIENTTYPE::OData,CompanyName,OBJECTTYPE::Page,"Object ID",WebService));
            "Object Type"::Query:
              exit(GetUrl(CLIENTTYPE::OData,CompanyName,OBJECTTYPE::Query,"Object ID",WebService));
            else
              exit(NotApplicableTxt);
          end
        end else begin
          Clear(TenantWebService);
          TenantWebService.Init;
          TenantWebService.TransferFields(Rec);

          case "Object Type" of
            "Object Type"::Page:
              begin
                ODataServiceRootUrl := GetUrl(CLIENTTYPE::OData,CompanyName,OBJECTTYPE::Page,"Object ID",TenantWebService);
                ODataUrl := ODataUtility.GenerateODataV3Url(ODataServiceRootUrl,TenantWebService."Service Name",ObjectTypeParam::Page);
                exit(ODataUrl);
              end;
            "Object Type"::Query:
              begin
                ODataServiceRootUrl := GetUrl(CLIENTTYPE::OData,CompanyName,OBJECTTYPE::Query,"Object ID",TenantWebService);
                ODataUrl := ODataUtility.GenerateODataV3Url(ODataServiceRootUrl,TenantWebService."Service Name",ObjectTypeParam::Query);
                exit(ODataUrl);
              end;
            else
              exit(NotApplicableTxt);
          end
        end
    end;

    [Scope('Personalization')]
    procedure GetSOAPUrl(): Text
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        if "All Tenants" then begin
          Clear(WebService);
          WebService.Init;
          WebService.TransferFields(Rec);

          case "Object Type" of
            "Object Type"::Page:
              exit(GetUrl(CLIENTTYPE::SOAP,CompanyName,OBJECTTYPE::Page,"Object ID",WebService));
            "Object Type"::Codeunit:
              exit(GetUrl(CLIENTTYPE::SOAP,CompanyName,OBJECTTYPE::Codeunit,"Object ID",WebService));
            else
              exit(NotApplicableTxt);
          end
        end else begin
          Clear(TenantWebService);
          TenantWebService.Init;
          TenantWebService.TransferFields(Rec);

          case "Object Type" of
            "Object Type"::Page:
              exit(GetUrl(CLIENTTYPE::SOAP,CompanyName,OBJECTTYPE::Page,"Object ID",TenantWebService));
            "Object Type"::Codeunit:
              exit(GetUrl(CLIENTTYPE::SOAP,CompanyName,OBJECTTYPE::Codeunit,"Object ID",TenantWebService));
            else
              exit(NotApplicableTxt);
          end
        end
    end;

    [Scope('Personalization')]
    procedure PopulateTable()
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
    begin
        Reset;
        DeleteAll;

        // The system records will always be displayed...
        if WebService.FindSet then
          repeat
            Init;
            TransferFields(WebService);
            "All Tenants" := true;
            Insert;
          until WebService.Next = 0;

        // The tenant records that don't have the same (Object Type and Service Name)
        // or (Object Type and Object ID) as a system record will be displayed.
        // i.e. any tenant records that have the same values for these will not be
        // displayed
        "All Tenants" := false;

        Clear(TenantWebService);
        if TenantWebService.FindSet then
          repeat
            Clear(WebService);
            if not WebService.Get(TenantWebService."Object Type",TenantWebService."Service Name") then begin
              WebService.SetRange("Object Type",TenantWebService."Object Type");
              WebService.SetRange("Object ID",TenantWebService."Object ID");

              // DCR: Include the tenant record if it has the same Object Type and Object ID
              // of a system record AND the system record is published...
              WebService.SetRange(Published,false);

              if not WebService.FindSet then begin
                Init;
                TransferFields(TenantWebService);
                Insert;
              end
            end
          until TenantWebService.Next = 0;
    end;

    procedure GetODataV4Url(): Text
    var
        WebService: Record "Web Service";
        TenantWebService: Record "Tenant Web Service";
        ODataUtility: Codeunit ODataUtility;
        ODataServiceRootUrl: Text;
        ODataUrl: Text;
        ObjectTypeParam: Option ,,,,,,,,"Page","Query";
    begin
        if "All Tenants" then begin
          Clear(WebService);
          WebService.Init;
          WebService.TransferFields(Rec);

          case "Object Type" of
            "Object Type"::Page:
              exit(GetUrl(CLIENTTYPE::ODataV4,CompanyName,OBJECTTYPE::Page,"Object ID",WebService));
            "Object Type"::Query:
              exit(GetUrl(CLIENTTYPE::ODataV4,CompanyName,OBJECTTYPE::Query,"Object ID",WebService));
            else
              exit(NotApplicableTxt);
          end
        end else begin
          Clear(TenantWebService);
          TenantWebService.Init;
          TenantWebService.TransferFields(Rec);

          case "Object Type" of
            "Object Type"::Page:
              begin
                ODataServiceRootUrl := GetUrl(CLIENTTYPE::ODataV4,CompanyName,OBJECTTYPE::Page,"Object ID",TenantWebService);
                ODataUrl := ODataUtility.GenerateODataV4Url(ODataServiceRootUrl,TenantWebService."Service Name",ObjectTypeParam::Page);
                exit(ODataUrl);
              end;
            "Object Type"::Query:
              begin
                ODataServiceRootUrl := GetUrl(CLIENTTYPE::ODataV4,CompanyName,OBJECTTYPE::Query,"Object ID",TenantWebService);
                ODataUrl := ODataUtility.GenerateODataV4Url(ODataServiceRootUrl,TenantWebService."Service Name",ObjectTypeParam::Query);
                exit(ODataUrl);
              end;
            else
              exit(NotApplicableTxt);
          end
        end
    end;
}

