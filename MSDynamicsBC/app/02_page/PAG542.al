page 542 "Default Dimensions-Multiple"
{
    // version NAVW113.00

    Caption = 'Default Dimensions-Multiple';
    DataCaptionExpression = GetCaption;
    PageType = List;
    SourceTable = "Default Dimension";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Dimension Code";"Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the default dimension.';

                    trigger OnValidate()
                    begin
                        if (xRec."Dimension Code" <> '') and (xRec."Dimension Code" <> "Dimension Code") then
                          Error(CannotRenameErr,TableCaption);
                    end;
                }
                field("Dimension Value Code";"Dimension Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the dimension value code to suggest as the default dimension.';
                }
                field("Value Posting";"Value Posting")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies how default dimensions and their values must be used.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        DimensionValueCodeOnFormat(Format("Dimension Value Code"));
        ValuePostingOnFormat(Format("Value Posting"));
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        "Multi Selection Action" := "Multi Selection Action"::Delete;
        Modify;
        exit(false);
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetRange("Dimension Code","Dimension Code");
        if not Find('-') and ("Dimension Code" <> '') then begin
          "Multi Selection Action" := "Multi Selection Action"::Change;
          Insert;
        end;
        SetRange("Dimension Code");
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        "Multi Selection Action" := "Multi Selection Action"::Change;
        Modify;
        exit(false);
    end;

    trigger OnOpenPage()
    begin
        GetDefaultDim;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
          LookupOKOnPush;
    end;

    var
        CannotRenameErr: Label 'You cannot rename a %1.';
        Text001: Label '(Conflict)';
        TempDefaultDim2: Record "Default Dimension" temporary;
        TempDefaultDim3: Record "Default Dimension" temporary;
        TotalRecNo: Integer;

    [Scope('Personalization')]
    procedure SetMultiGLAcc(var GLAcc: Record "G/L Account")
    begin
        TempDefaultDim2.DeleteAll;
        with GLAcc do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"G/L Account","No.");
            until Next = 0;
    end;

    local procedure SetCommonDefaultDim()
    var
        DefaultDim: Record "Default Dimension";
    begin
        SetRange(
          "Multi Selection Action","Multi Selection Action"::Delete);
        if Find('-') then
          repeat
            if TempDefaultDim3.Find('-') then
              repeat
                if DefaultDim.Get(
                     TempDefaultDim3."Table ID",TempDefaultDim3."No.","Dimension Code")
                then
                  DefaultDim.Delete(true);
              until TempDefaultDim3.Next = 0;
          until Next = 0;
        SetRange(
          "Multi Selection Action","Multi Selection Action"::Change);
        if Find('-') then
          repeat
            if TempDefaultDim3.Find('-') then
              repeat
                if DefaultDim.Get(
                     TempDefaultDim3."Table ID",TempDefaultDim3."No.","Dimension Code")
                then begin
                  DefaultDim."Dimension Code" := "Dimension Code";
                  DefaultDim."Dimension Value Code" := "Dimension Value Code";
                  DefaultDim."Value Posting" := "Value Posting";
                  OnBeforeSetCommonDefaultCopyFields(DefaultDim,Rec);
                  DefaultDim.Modify(true);
                end else begin
                  DefaultDim.Init;
                  DefaultDim."Table ID" := TempDefaultDim3."Table ID";
                  DefaultDim."No." := TempDefaultDim3."No.";
                  DefaultDim."Dimension Code" := "Dimension Code";
                  DefaultDim."Dimension Value Code" := "Dimension Value Code";
                  DefaultDim."Value Posting" := "Value Posting";
                  OnBeforeSetCommonDefaultCopyFields(DefaultDim,Rec);
                  DefaultDim.Insert(true);
                end;
              until TempDefaultDim3.Next = 0;
          until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiCust(var Cust: Record Customer)
    begin
        TempDefaultDim2.DeleteAll;
        with Cust do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Customer,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiVendor(var Vend: Record Vendor)
    begin
        TempDefaultDim2.DeleteAll;
        with Vend do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Vendor,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiItem(var Item: Record Item)
    begin
        TempDefaultDim2.DeleteAll;
        with Item do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Item,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiResGr(var ResGr: Record "Resource Group")
    begin
        TempDefaultDim2.DeleteAll;
        with ResGr do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Resource Group","No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiResource(var Res: Record Resource)
    begin
        TempDefaultDim2.DeleteAll;
        with Res do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Resource,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiJob(var Job: Record Job)
    begin
        TempDefaultDim2.DeleteAll;
        with Job do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Job,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiBankAcc(var BankAcc: Record "Bank Account")
    begin
        TempDefaultDim2.DeleteAll;
        with BankAcc do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Bank Account","No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiEmployee(var Employee: Record Employee)
    begin
        TempDefaultDim2.DeleteAll;
        with Employee do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Employee,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiFA(var FA: Record "Fixed Asset")
    begin
        TempDefaultDim2.DeleteAll;
        with FA do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Fixed Asset","No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiInsurance(var Insurance: Record Insurance)
    begin
        TempDefaultDim2.DeleteAll;
        with Insurance do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Insurance,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiRespCenter(var RespCenter: Record "Responsibility Center")
    begin
        TempDefaultDim2.DeleteAll;
        with RespCenter do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Responsibility Center",Code);
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiSalesperson(var SalesPurchPerson: Record "Salesperson/Purchaser")
    begin
        TempDefaultDim2.DeleteAll;
        with SalesPurchPerson do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Salesperson/Purchaser",Code);
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiWorkCenter(var WorkCenter: Record "Work Center")
    begin
        TempDefaultDim2.DeleteAll;
        with WorkCenter do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Work Center","No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiCampaign(var Campaign: Record Campaign)
    begin
        TempDefaultDim2.DeleteAll;
        with Campaign do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::Campaign,"No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiCustTemplate(var CustTemplate: Record "Customer Template")
    begin
        TempDefaultDim2.DeleteAll;
        with CustTemplate do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Customer Template",Code);
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure CopyDefaultDimToDefaultDim(TableID: Integer;No: Code[20])
    var
        DefaultDim: Record "Default Dimension";
    begin
        TotalRecNo := TotalRecNo + 1;
        TempDefaultDim3."Table ID" := TableID;
        TempDefaultDim3."No." := No;
        TempDefaultDim3.Insert;

        DefaultDim.SetRange("Table ID",TableID);
        DefaultDim.SetRange("No.",No);
        if DefaultDim.Find('-') then
          repeat
            TempDefaultDim2 := DefaultDim;
            TempDefaultDim2.Insert;
          until DefaultDim.Next = 0;
    end;

    local procedure GetDefaultDim()
    var
        Dim: Record Dimension;
        RecNo: Integer;
    begin
        Reset;
        DeleteAll;
        if Dim.Find('-') then
          repeat
            RecNo := 0;
            TempDefaultDim2.SetRange("Dimension Code",Dim.Code);
            SetRange("Dimension Code",Dim.Code);
            if TempDefaultDim2.Find('-') then
              repeat
                if FindFirst then begin
                  if "Dimension Value Code" <> TempDefaultDim2."Dimension Value Code" then begin
                    if ("Multi Selection Action" <> 10) and
                       ("Multi Selection Action" <> 21)
                    then begin
                      "Multi Selection Action" :=
                        "Multi Selection Action" + 10;
                      "Dimension Value Code" := '';
                    end;
                  end;
                  if "Value Posting" <> TempDefaultDim2."Value Posting" then begin
                    if ("Multi Selection Action" <> 11) and
                       ("Multi Selection Action" <> 21)
                    then begin
                      "Multi Selection Action" :=
                        "Multi Selection Action" + 11;
                      "Value Posting" := "Value Posting"::" ";
                    end;
                  end;
                  Modify;
                  RecNo := RecNo + 1;
                end else begin
                  Rec := TempDefaultDim2;
                  Insert;
                  RecNo := RecNo + 1;
                end;
              until TempDefaultDim2.Next = 0;

            if Find('-') and (RecNo <> TotalRecNo) then
              if ("Multi Selection Action" <> 10) and
                 ("Multi Selection Action" <> 21)
              then begin
                "Multi Selection Action" :=
                  "Multi Selection Action" + 10;
                "Dimension Value Code" := '';
                Modify;
              end;
          until Dim.Next = 0;

        Reset;
        SetCurrentKey("Dimension Code");
        SetFilter(
          "Multi Selection Action",'<>%1',"Multi Selection Action"::Delete);
    end;

    [Scope('Personalization')]
    procedure SetMultiServiceItem(var ServiceItem: Record "Service Item")
    begin
        TempDefaultDim2.DeleteAll;
        with ServiceItem do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Service Item","No.");
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiServiceItemGroup(var ServiceItemGroup: Record "Service Item Group")
    begin
        TempDefaultDim2.DeleteAll;
        with ServiceItemGroup do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Service Item Group",Code);
            until Next = 0;
    end;

    [Scope('Personalization')]
    procedure SetMultiServiceOrderType(var ServiceOrderType: Record "Service Order Type")
    begin
        TempDefaultDim2.DeleteAll;
        with ServiceOrderType do
          if Find('-') then
            repeat
              CopyDefaultDimToDefaultDim(DATABASE::"Service Order Type",Code);
            until Next = 0;
    end;

    local procedure LookupOKOnPush()
    begin
        SetCommonDefaultDim;
    end;

    local procedure DimensionValueCodeOnFormat(Text: Text[1024])
    begin
        if "Dimension Code" <> '' then
          if ("Multi Selection Action" = 10) or
             ("Multi Selection Action" = 21)
          then
            Text := Text001;
    end;

    local procedure ValuePostingOnFormat(Text: Text[1024])
    begin
        if "Dimension Code" <> '' then
          if ("Multi Selection Action" = 11) or
             ("Multi Selection Action" = 21)
          then
            Text := Text001;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetCommonDefaultCopyFields(var DefaultDimension: Record "Default Dimension";FromDefaultDimension: Record "Default Dimension")
    begin
    end;
}

