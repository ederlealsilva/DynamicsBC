report 6036 "Create Contract Service Orders"
{
    // version NAVW113.00

    ApplicationArea = #Service;
    Caption = 'Create Contract Service Orders';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem("Service Contract Header";"Service Contract Header")
        {
            DataItemTableView = WHERE("Contract Type"=CONST(Contract),"Change Status"=CONST(Locked),Status=CONST(Signed));
            RequestFilterFields = "Contract No.";
            dataitem("Service Contract Line";"Service Contract Line")
            {
                DataItemLink = "Contract Type"=FIELD("Contract Type"),"Contract No."=FIELD("Contract No.");
                DataItemTableView = SORTING("Contract Type","Contract No.","Line No.") ORDER(Ascending) WHERE("Service Period"=FILTER(<>''));

                trigger OnAfterGetRecord()
                begin
                    if "Contract Expiration Date" <> 0D then begin
                      if "Contract Expiration Date" <= "Next Planned Service Date" then
                        CurrReport.Skip;
                    end else
                      if ("Service Contract Header"."Expiration Date" <> 0D) and
                         ("Service Contract Header"."Expiration Date" <= "Next Planned Service Date")
                      then
                        CurrReport.Skip;

                    Cust.Get("Service Contract Header"."Bill-to Customer No.");
                    if Cust.Blocked = Cust.Blocked::All then
                      CurrReport.Skip;

                    ServHeader.SetCurrentKey("Contract No.",Status,"Posting Date");
                    ServHeader.SetRange("Document Type",ServHeader."Document Type"::Order);
                    ServHeader.SetRange("Contract No.","Contract No.");
                    ServHeader.SetRange(Status,ServHeader.Status::Pending);

                    ServOrderExist := ServHeader.FindFirst;
                    if ServOrderExist then begin
                      ServItemLine.SetCurrentKey("Document Type","Document No.","Service Item No.");
                      ServItemLine.SetRange("Document Type",ServHeader."Document Type");
                      ServItemLine.SetRange("Document No.",ServHeader."No.");
                      ServItemLine.SetRange("Contract No.","Contract No.");
                      ServItemLine.SetRange("Contract Line No.","Line No.");
                      if ServItemLine.FindFirst then
                        CurrReport.Skip;
                    end;
                    CreateOrAddToServOrder;
                end;

                trigger OnPreDataItem()
                begin
                    if EndDate = 0D then
                      Error(Text002);
                    if EndDate < StartDate then
                      Error(Text003);

                    if StartDate <> 0D then begin
                      if EndDate - StartDate + 1 > ServMgtSetup."Contract Serv. Ord.  Max. Days" then
                        Error(
                          Text004,
                          ServMgtSetup.TableCaption);
                    end;

                    SetRange("Next Planned Service Date",StartDate,EndDate);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                VerifyServiceContractHeader;
            end;

            trigger OnPreDataItem()
            begin
                if CreateServOrders = CreateServOrders::"Print Only" then begin
                  Clear(ContrServOrdersTest);
                  ContrServOrdersTest.InitVariables(StartDate,EndDate);
                  ContrServOrdersTest.SetTableView("Service Contract Header");
                  ContrServOrdersTest.RunModal;
                  CurrReport.Break;
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate;StartDate)
                    {
                        ApplicationArea = Service;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date for the period that you want to create contract service orders for. The batch job includes contracts with service items that have next planned service dates on or later than this date.';
                    }
                    field(EndingDate;EndDate)
                    {
                        ApplicationArea = Service;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the ending date for the period that you want to create contract service orders for. The batch job includes contracts with service items with next planned service date on or earlier than this date.';

                        trigger OnValidate()
                        begin
                            if EndDate < StartDate then
                              Error(Text003);
                        end;
                    }
                    field(CreateServiceOrders;CreateServOrders)
                    {
                        ApplicationArea = Service;
                        Caption = 'Action';
                        OptionCaption = 'Create Service Order,Print Only';
                        ToolTip = 'Specifies the desired action relating to contract service orders.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        ServMgtSetup.Get;
        if ServMgtSetup."Last Contract Service Date" <> 0D then
          StartDate := ServMgtSetup."Last Contract Service Date" + 1;
    end;

    trigger OnPostReport()
    begin
        if CreateServOrders = CreateServOrders::"Create Service Order" then begin
          ServMgtSetup.Get;
          ServMgtSetup."Last Contract Service Date" := EndDate;
          ServMgtSetup.Modify;

          if not HideDialog then
            if ServOrderCreated > 1 then
              Message(Text000,ServOrderCreated)
            else
              Message(Text001,ServOrderCreated)
        end;
    end;

    var
        Text000: Label '%1 service orders were created.';
        Text001: Label '%1 service order was created.';
        Text002: Label 'You must fill in the ending date field.';
        Text003: Label 'The starting date is after the ending date.';
        Text004: Label 'The date range you have entered is a longer period than is allowed in the %1 table.';
        ServMgtSetup: Record "Service Mgt. Setup";
        ServHeader: Record "Service Header";
        ServItemLine: Record "Service Item Line";
        Cust: Record Customer;
        ServItem: Record "Service Item";
        RepairStatus: Record "Repair Status";
        Salesperson: Record "Salesperson/Purchaser";
        ContrServOrdersTest: Report "Contr. Serv. Orders - Test";
        ServOrderCreated: Integer;
        RecordNo: Integer;
        StartDate: Date;
        EndDate: Date;
        CreateServOrders: Option "Create Service Order","Print Only";
        ServOrderExist: Boolean;
        HideDialog: Boolean;
        Text005: Label 'A service order cannot be created for contract no. %1 because customer no. %2 does not have a %3.';

    local procedure CreateOrAddToServOrder()
    begin
        Clear(ServHeader);
        ServHeader.SetCurrentKey("Contract No.",Status,"Posting Date");
        ServHeader.SetRange("Document Type",ServHeader."Document Type"::Order);
        ServHeader.SetRange("Contract No.","Service Contract Header"."Contract No.");
        ServHeader.SetRange(Status,ServHeader.Status::Pending);
        ServHeader.SetFilter("Order Date",'>=%1',"Service Contract Line"."Next Planned Service Date");
        if not ServHeader.FindFirst then begin
          Clear(ServHeader);
          ServHeader.Init;
          ServHeader."Document Type" := ServHeader."Document Type"::Order;
          ServHeader.Insert(true);
          ServHeader.SetHideValidationDialog(true);
          ServHeader."Contract No." := "Service Contract Header"."Contract No.";
          ServHeader.Validate("Order Date","Service Contract Line"."Next Planned Service Date");
          ServHeader.Validate("Customer No.","Service Contract Header"."Customer No.");
          ServHeader.Validate("Bill-to Customer No.","Service Contract Header"."Bill-to Customer No.");
          ServHeader."Default Response Time (Hours)" := "Service Contract Header"."Response Time (Hours)";
          ServHeader.Validate("Ship-to Code","Service Contract Header"."Ship-to Code");
          ServHeader."Service Order Type" := "Service Contract Header"."Service Order Type";
          ServHeader.Validate("Currency Code","Service Contract Header"."Currency Code");
          SetSalespersonCode("Service Contract Header"."Salesperson Code",ServHeader."Salesperson Code");
          ServHeader."Max. Labor Unit Price" := "Service Contract Header"."Max. Labor Unit Price";
          ServHeader."Your Reference" := "Service Contract Header"."Your Reference";
          ServHeader."Service Zone Code" := "Service Contract Header"."Service Zone Code";
          ServHeader."Shortcut Dimension 1 Code" := "Service Contract Header"."Shortcut Dimension 1 Code";
          ServHeader."Shortcut Dimension 2 Code" := "Service Contract Header"."Shortcut Dimension 2 Code";
          ServHeader.Validate("Service Order Type","Service Contract Header"."Service Order Type");
          ServHeader."Dimension Set ID" := "Service Contract Header"."Dimension Set ID";
          ServHeader.Modify(true);

          ServOrderCreated := ServOrderCreated + 1;
        end;

        RecordNo := 0;
        Clear(ServItemLine);
        ServItemLine.SetRange("Document Type",ServHeader."Document Type");
        ServItemLine.SetRange("Document No.",ServHeader."No.");
        if ServItemLine.FindLast then
          RecordNo := ServItemLine."Line No."
        else
          RecordNo := 0;
        Clear(ServItemLine);
        ServItemLine.SetCurrentKey("Document Type","Document No.","Service Item No.");
        ServItemLine.SetRange("Document Type",ServHeader."Document Type");
        ServItemLine.SetRange("Document No.",ServHeader."No.");
        ServItemLine.SetRange("Contract No.","Service Contract Line"."Contract No.");
        ServItemLine.SetRange("Contract Line No.","Service Contract Line"."Line No.");
        if not ServItemLine.FindFirst then begin
          RecordNo := RecordNo + 10000;
          ServItemLine.Init;
          ServItemLine.SetHideDialogBox(true);
          ServItemLine."Document No." := ServHeader."No.";
          ServItemLine."Document Type" := ServHeader."Document Type";
          RepairStatus.Reset;
          RepairStatus.Initial := true;
          ServItemLine."Repair Status Code" := RepairStatus.ReturnStatusCode(RepairStatus);
          ServItemLine."Line No." := RecordNo;
          if "Service Contract Line"."Service Item No." <> '' then begin
            ServItem.Get("Service Contract Line"."Service Item No.");
            ServItemLine.Validate("Service Item No.",ServItem."No.");
            ServItemLine."Location of Service Item" := ServItem."Location of Service Item";
            ServItemLine.Priority := ServItem.Priority;
          end else
            ServItemLine.Description := "Service Contract Line".Description;
          ServItemLine."Serial No." := "Service Contract Line"."Serial No.";
          ServItemLine."Item No." := "Service Contract Line"."Item No.";
          ServItemLine."Variant Code" := "Service Contract Line"."Variant Code";
          ServItemLine."Contract No." := "Service Contract Line"."Contract No.";
          ServItemLine."Contract Line No." := "Service Contract Line"."Line No.";
          ServItemLine.UpdateResponseTimeHours;
          ServItemLine.Insert(true);
        end;
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    procedure InitializeRequest(StartDateFrom: Date;EndDateFrom: Date;CreateServOrdersFrom: Option)
    begin
        StartDate := StartDateFrom;
        EndDate := EndDateFrom;
        CreateServOrders := CreateServOrdersFrom;
    end;

    local procedure VerifyServiceContractHeader()
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        with "Service Contract Header" do
          if "Ship-to Code" <> '' then
            if not ShipToAddress.Get("Customer No.","Ship-to Code") then begin
              Message(Text005,"Contract No.","Customer No.","Ship-to Code");
              CurrReport.Skip;
            end;
    end;

    local procedure SetSalespersonCode(SalesPersonCodeToCheck: Code[20];var SalesPersonCodeToAssign: Code[20])
    begin
        if SalesPersonCodeToCheck <> '' then
          if Salesperson.Get(SalesPersonCodeToCheck) then
            if Salesperson.VerifySalesPersonPurchaserPrivacyBlocked(Salesperson) then
              SalesPersonCodeToAssign := ''
            else
              SalesPersonCodeToAssign := SalesPersonCodeToCheck;
    end;
}

