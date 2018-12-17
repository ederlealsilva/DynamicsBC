codeunit 48 PostingSetupManagement
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        MyNotifications: Record "My Notifications";
        MissingAccountTxt: Label '%1 is missing in %2.', Comment='%1 = Field caption, %2 = Table caption';
        SetupMissingAccountTxt: Label 'Set up missing account';
        MissingAccountNotificationTxt: Label 'G/L Account is missing in posting group or setup.';
        MissingAccountNotificationDescriptionTxt: Label 'Show a warning when required G/L Account is missing in posting group or setup.';
        NotAllowedToPostAfterCurrentFiscalYearErr: Label 'Cannot post because one or more transactions have dates after the current fiscal year.';

    [Scope('Personalization')]
    procedure CheckCustPostingGroupReceivablesAccount(PostingGroup: Code[20])
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not CustomerPostingGroup.Get(PostingGroup) then
          exit;

        if CustomerPostingGroup."Receivables Account" = '' then
          SendCustPostingGroupNotification(CustomerPostingGroup,CustomerPostingGroup.FieldCaption("Receivables Account"));
    end;

    [Scope('Personalization')]
    procedure CheckVendPostingGroupPayablesAccount(PostingGroup: Code[20])
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not VendorPostingGroup.Get(PostingGroup) then
          exit;

        if VendorPostingGroup."Payables Account" = '' then
          SendVendPostingGroupNotification(VendorPostingGroup,VendorPostingGroup.FieldCaption("Payables Account"));
    end;

    [Scope('Personalization')]
    procedure CheckGenPostingSetupSalesAccount(GenBusGroupCode: Code[20];GenProdGroupCode: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not GenPostingSetup.Get(GenBusGroupCode,GenProdGroupCode) then
          CreateGenPostingSetup(GenBusGroupCode,GenProdGroupCode);

        if GenPostingSetup."Sales Account" = '' then
          SendGenPostingSetupNotification(GenPostingSetup,GenPostingSetup.FieldCaption("Sales Account"));
    end;

    [Scope('Personalization')]
    procedure CheckGenPostingSetupPurchAccount(GenBusGroupCode: Code[20];GenProdGroupCode: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not GenPostingSetup.Get(GenBusGroupCode,GenProdGroupCode) then
          CreateGenPostingSetup(GenBusGroupCode,GenProdGroupCode);

        if GenPostingSetup."Purch. Account" = '' then
          SendGenPostingSetupNotification(GenPostingSetup,GenPostingSetup.FieldCaption("Purch. Account"));
    end;

    [Scope('Personalization')]
    procedure CheckGenPostingSetupCOGSAccount(GenBusGroupCode: Code[20];GenProdGroupCode: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not GenPostingSetup.Get(GenBusGroupCode,GenProdGroupCode) then
          CreateGenPostingSetup(GenBusGroupCode,GenProdGroupCode);

        if GenPostingSetup."COGS Account" = '' then
          SendGenPostingSetupNotification(GenPostingSetup,GenPostingSetup.FieldCaption("COGS Account"));
    end;

    [Scope('Personalization')]
    procedure CheckVATPostingSetupSalesAccount(VATBusGroupCode: Code[20];VATProdGroupCode: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not VATPostingSetup.Get(VATBusGroupCode,VATProdGroupCode) then
          CreateVATPostingSetup(VATBusGroupCode,VATProdGroupCode);

        if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Sales Tax" then
          exit;

        if VATPostingSetup."Sales VAT Account" = '' then
          SendVATPostingSetupNotification(VATPostingSetup,VATPostingSetup.FieldCaption("Sales VAT Account"));
    end;

    [Scope('Personalization')]
    procedure CheckVATPostingSetupPurchAccount(VATBusGroupCode: Code[20];VATProdGroupCode: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not VATPostingSetup.Get(VATBusGroupCode,VATProdGroupCode) then
          CreateVATPostingSetup(VATBusGroupCode,VATProdGroupCode);

        if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Sales Tax" then
          exit;

        if VATPostingSetup."Purchase VAT Account" = '' then
          SendVATPostingSetupNotification(VATPostingSetup,VATPostingSetup.FieldCaption("Purchase VAT Account"));
    end;

    [Scope('Personalization')]
    procedure CheckInvtPostingSetupInventoryAccount(LocationCode: Code[10];PostingGroup: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        if not InventoryPostingSetup.Get(LocationCode,PostingGroup) then
          CreateInvtPostingSetup(LocationCode,PostingGroup);

        if InventoryPostingSetup."Inventory Account" = '' then
          SendInvtPostingSetupNotification(InventoryPostingSetup,InventoryPostingSetup.FieldCaption("Inventory Account"));
    end;

    local procedure FindNextFYStartingDate(var AccountingPeriod: Record "Accounting Period")
    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
    begin
        if AccountingPeriod.IsEmpty then begin
          AccountingPeriodMgt.InitStartYearAccountingPeriod(AccountingPeriod,WorkDate);
          exit;
        end;
        AccountingPeriod.SetRange(Closed,false);
        AccountingPeriod.SetRange("New Fiscal Year",true);
        AccountingPeriod.FindSet;
        // Try to get starting period of next opened fiscal year
        if AccountingPeriod.Next = 0 then begin
          // If not exists then get the day after the last period of opened fiscal year
          AccountingPeriod.SetRange("New Fiscal Year");
          AccountingPeriod.FindLast;
          AccountingPeriod."Starting Date" := CalcDate('<CM+1D>',AccountingPeriod."Starting Date");
        end;
    end;

    procedure GetPostingSetupNotificationID(): Guid
    begin
        exit('7c2a2ca8-bdf7-4428-b520-ed17887ff30c');
    end;

    [Scope('Personalization')]
    procedure ConfirmPostingAfterCurrentFiscalYear(ConfirmQst: Text;PostingDate: Date): Boolean
    var
        AccountingPeriod: Record "Accounting Period";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        if AccountingPeriod.IsEmpty then
          exit(true);
        if GuiAllowed and
           InstructionMgt.IsMyNotificationEnabled(InstructionMgt.GetPostingAfterCurrentFiscalYeartNotificationId)
        then begin
          FindNextFYStartingDate(AccountingPeriod);
          if PostingDate >= AccountingPeriod."Starting Date" then begin
            if Confirm(ConfirmQst,false) then
              exit(true);
            Error(NotAllowedToPostAfterCurrentFiscalYearErr);
          end;
        end;
    end;

    local procedure CreateGenPostingSetup(GenBusGroupCode: Code[20];GenProdGroupCode: Code[20])
    var
        GenPostingSetup: Record "General Posting Setup";
    begin
        GenPostingSetup.Init;
        GenPostingSetup.Validate("Gen. Bus. Posting Group",GenBusGroupCode);
        GenPostingSetup.Validate("Gen. Prod. Posting Group",GenProdGroupCode);
        GenPostingSetup.Insert;
    end;

    local procedure CreateVATPostingSetup(VATBusGroupCode: Code[20];VATProdGroupCode: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.Init;
        VATPostingSetup.Validate("VAT Bus. Posting Group",VATBusGroupCode);
        VATPostingSetup.Validate("VAT Prod. Posting Group",VATProdGroupCode);
        VATPostingSetup.Insert;
    end;

    local procedure CreateInvtPostingSetup(LocationCode: Code[10];PostingGroupCode: Code[20])
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.Init;
        InventoryPostingSetup.Validate("Location Code",LocationCode);
        InventoryPostingSetup.Validate("Invt. Posting Group Code",PostingGroupCode);
        InventoryPostingSetup.Insert;
    end;

    procedure IsPostingSetupNotificationEnabled(): Boolean
    var
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        exit(InstructionMgt.IsMyNotificationEnabled(GetPostingSetupNotificationID));
    end;

    local procedure SendPostingSetupNotification(NotificationMsg: Text;ActionMsg: Text;ActionName: Text;GroupCode1: Code[20];GroupCode2: Code[20])
    var
        SendNotification: Notification;
    begin
        SendNotification.Id := CreateGuid;
        SendNotification.Message(NotificationMsg);
        SendNotification.Scope(NOTIFICATIONSCOPE::LocalScope);
        SendNotification.SetData('GroupCode1',GroupCode1);
        if GroupCode2 <> '' then
          SendNotification.SetData('GroupCode2',GroupCode2);
        SendNotification.AddAction(ActionMsg,CODEUNIT::PostingSetupManagement,ActionName);
        SendNotification.Send;
    end;

    [Scope('Personalization')]
    procedure SendCustPostingGroupNotification(CustomerPostingGroup: Record "Customer Posting Group";FieldCaption: Text)
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        SendPostingSetupNotification(
          StrSubstNo(MissingAccountTxt,FieldCaption,CustomerPostingGroup.TableCaption),
          SetupMissingAccountTxt,'ShowCustomerPostingGroups',CustomerPostingGroup.Code,'');
    end;

    [Scope('Personalization')]
    procedure SendVendPostingGroupNotification(VendorPostingGroup: Record "Vendor Posting Group";FieldCaption: Text)
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        SendPostingSetupNotification(
          StrSubstNo(MissingAccountTxt,FieldCaption,VendorPostingGroup.TableCaption),
          SetupMissingAccountTxt,'ShowVendorPostingGroups',VendorPostingGroup.Code,'');
    end;

    [Scope('Personalization')]
    procedure SendInvtPostingSetupNotification(InvtPostingSetup: Record "Inventory Posting Setup";FieldCaption: Text)
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        SendPostingSetupNotification(
          StrSubstNo(MissingAccountTxt,FieldCaption,InvtPostingSetup.TableCaption),
          SetupMissingAccountTxt,'ShowInventoryPostingSetup',
          InvtPostingSetup."Invt. Posting Group Code",InvtPostingSetup."Location Code");
    end;

    [Scope('Personalization')]
    procedure SendGenPostingSetupNotification(GenPostingSetup: Record "General Posting Setup";FieldCaption: Text)
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        SendPostingSetupNotification(
          StrSubstNo(MissingAccountTxt,FieldCaption,GenPostingSetup.TableCaption),
          SetupMissingAccountTxt,'ShowGenPostingSetup',
          GenPostingSetup."Gen. Bus. Posting Group",GenPostingSetup."Gen. Prod. Posting Group");
    end;

    [Scope('Personalization')]
    procedure SendVATPostingSetupNotification(VATPostingSetup: Record "VAT Posting Setup";FieldCaption: Text)
    begin
        if not IsPostingSetupNotificationEnabled then
          exit;

        SendPostingSetupNotification(
          StrSubstNo(MissingAccountTxt,FieldCaption,VATPostingSetup.TableCaption),
          SetupMissingAccountTxt,'ShowVATPostingSetup',
          VATPostingSetup."VAT Bus. Posting Group",VATPostingSetup."VAT Prod. Posting Group");
    end;

    procedure ShowCustomerPostingGroups(SetupNotification: Notification)
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        CustomerPostingGroups: Page "Customer Posting Groups";
        PostingGroupCode: Code[20];
    begin
        Clear(CustomerPostingGroups);
        PostingGroupCode := SetupNotification.GetData('GroupCode1');
        if PostingGroupCode <> '' then begin
          CustomerPostingGroup.Get(PostingGroupCode);
          CustomerPostingGroups.SetRecord(CustomerPostingGroup);
        end;
        CustomerPostingGroups.SetTableView(CustomerPostingGroup);
        CustomerPostingGroups.RunModal;
    end;

    procedure ShowVendorPostingGroups(SetupNotification: Notification)
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        VendorPostingGroups: Page "Vendor Posting Groups";
        PostingGroupCode: Code[20];
    begin
        Clear(VendorPostingGroups);
        PostingGroupCode := SetupNotification.GetData('GroupCode1');
        if PostingGroupCode <> '' then begin
          VendorPostingGroup.Get(PostingGroupCode);
          VendorPostingGroups.SetRecord(VendorPostingGroup);
        end;
        VendorPostingGroups.SetTableView(VendorPostingGroup);
        VendorPostingGroups.RunModal;
    end;

    procedure ShowInventoryPostingSetup(SetupNotification: Notification)
    var
        InventoryPostingSetupRec: Record "Inventory Posting Setup";
        InventoryPostingSetupPage: Page "Inventory Posting Setup";
        PostingGroupCode: Code[20];
        LocationCode: Code[10];
    begin
        Clear(InventoryPostingSetupPage);
        PostingGroupCode := SetupNotification.GetData('GroupCode1');
        LocationCode := SetupNotification.GetData('GroupCode2');
        if PostingGroupCode <> '' then begin
          InventoryPostingSetupRec.Get(LocationCode,PostingGroupCode);
          InventoryPostingSetupPage.SetRecord(InventoryPostingSetupRec);
        end;
        InventoryPostingSetupPage.SetTableView(InventoryPostingSetupRec);
        InventoryPostingSetupPage.RunModal;
    end;

    procedure ShowGenPostingSetup(SetupNotification: Notification)
    var
        GenPostingSetupRec: Record "General Posting Setup";
        GenPostingSetupPage: Page "General Posting Setup";
        BusPostingGroupCode: Code[20];
        ProdPostingGroupCode: Code[20];
    begin
        Clear(GenPostingSetupPage);
        BusPostingGroupCode := SetupNotification.GetData('GroupCode1');
        ProdPostingGroupCode := SetupNotification.GetData('GroupCode2');
        if ProdPostingGroupCode <> '' then begin
          GenPostingSetupRec.Get(BusPostingGroupCode,ProdPostingGroupCode);
          GenPostingSetupPage.SetRecord(GenPostingSetupRec);
        end;
        GenPostingSetupPage.SetTableView(GenPostingSetupRec);
        GenPostingSetupPage.RunModal;
    end;

    procedure ShowVATPostingSetup(SetupNotification: Notification)
    var
        VATPostingSetupRec: Record "VAT Posting Setup";
        VATPostingSetupPage: Page "VAT Posting Setup";
        BusPostingGroupCode: Code[20];
        ProdPostingGroupCode: Code[20];
    begin
        Clear(VATPostingSetupPage);
        BusPostingGroupCode := SetupNotification.GetData('GroupCode1');
        ProdPostingGroupCode := SetupNotification.GetData('GroupCode2');
        if ProdPostingGroupCode <> '' then begin
          VATPostingSetupRec.Get(BusPostingGroupCode,ProdPostingGroupCode);
          VATPostingSetupPage.SetRecord(VATPostingSetupRec);
        end;
        VATPostingSetupPage.SetTableView(VATPostingSetupRec);
        VATPostingSetupPage.RunModal;
    end;

    [EventSubscriber(ObjectType::Page, 1518, 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    begin
        MyNotifications.InsertDefault(
          GetPostingSetupNotificationID,MissingAccountNotificationTxt,MissingAccountNotificationDescriptionTxt,false);
    end;
}

