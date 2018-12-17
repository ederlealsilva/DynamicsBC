table 2190 "O365 Sales Graph"
{
    // version NAVW111.00

    Caption = 'O365 Sales Graph';
    TableType = MicrosoftGraph;

    fields
    {
        field(1;Component;Text[60])
        {
            Caption = 'Component';
            ExternalName = 'component';
            ExternalType = 'Edm.String';
        }
        field(2;Type;Text[60])
        {
            Caption = 'Type';
            ExternalName = 'type';
            ExternalType = 'Edm.String';
        }
        field(3;"Schema";Text[60])
        {
            Caption = 'Schema';
            ExternalName = 'schema';
            ExternalType = 'Edm.String';
        }
        field(4;Details;BLOB)
        {
            Caption = 'Details';
            ExternalName = 'details';
            ExternalType = 'Edm.Json';
            SubType = Json;
        }
        field(5;InvoiceId;Text[60])
        {
            Caption = 'InvoiceId';
            ExternalName = 'invoiceId';
            ExternalType = 'Edm.String';
        }
        field(6;EmployeeId;Text[250])
        {
            Caption = 'EmployeeId';
            ExternalName = 'employeeId';
            ExternalType = 'Edm.String';
        }
        field(7;ContactId;Text[250])
        {
            Caption = 'ContactId';
            ExternalName = 'customerId';
            ExternalType = 'Edm.String';
        }
        field(8;ActivityDate;Text[60])
        {
            Caption = 'ActivityDate';
            ExternalName = 'activityDate';
            ExternalType = 'Edm.String';
        }
        field(9;Kind;Text[60])
        {
            Caption = 'Kind';
            ExternalName = 'kind';
            ExternalType = 'Edm.String';
        }
        field(10;EstimateId;Text[60])
        {
            Caption = 'EstimateId';
            ExternalName = 'EstimateId';
            ExternalType = 'Edm.String';
        }
    }

    keys
    {
        key(Key1;Component)
        {
        }
    }

    fieldgroups
    {
    }

    var
        InvalidComponentErr: Label 'Component should be Invoice.';
        InvalidSchemaErr: Label 'An unsupported schema was specified.';
        InvalidTypeErr: Label 'The specified type is not valid for the request.';
        NotInvoicingErr: Label 'The specified tenant is not an Invoicing tenant.';
        SupportedSchemaTxt: Label 'InvoiceV1', Locked=true;
        ComponentTxt: Label 'Invoice', Locked=true;
        RefreshTypeTxt: Label 'Refresh', Locked=true;

    procedure Initialize()
    begin
        Init;
        Component := ComponentTxt;
        Schema := SupportedSchemaTxt;
        ActivityDate := Format(CurrentDateTime,0,9);
    end;

    procedure SetEmployeeIdToCurrentUser()
    var
        AzureADUserManagement: Codeunit "Azure AD User Management";
    begin
        EmployeeId := AzureADUserManagement.GetUserObjectId(UserSecurityId);
    end;

    procedure ParseRefresh()
    var
        O365SalesInitialSetup: Record "O365 Sales Initial Setup";
    begin
        if UpperCase(Component) <> UpperCase(ComponentTxt) then
          Error(InvalidComponentErr);

        if UpperCase(Schema) <> UpperCase(SupportedSchemaTxt) then
          Error(InvalidSchemaErr);

        if UpperCase(Type) <> UpperCase(RefreshTypeTxt) then
          Error(InvalidTypeErr);

        if (not O365SalesInitialSetup.Get) or (not O365SalesInitialSetup."Is initialized") then
          Error(NotInvoicingErr);

        TASKSCHEDULER.CreateTask(CODEUNIT::"O365 Sales Web Service",0,true,CompanyName,CurrentDateTime + 10000); // Add 10s
    end;
}

