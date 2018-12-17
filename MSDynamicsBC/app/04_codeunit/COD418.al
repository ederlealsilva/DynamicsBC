codeunit 418 "User Management"
{
    // version NAVW113.00

    Permissions = TableData "G/L Entry"=rm,
                  TableData "Cust. Ledger Entry"=rm,
                  TableData "Vendor Ledger Entry"=rm,
                  TableData "G/L Register"=rm,
                  TableData "Item Register"=rm,
                  TableData "G/L Budget Entry"=rm,
                  TableData "Sales Shipment Header"=rm,
                  TableData "Sales Invoice Header"=rm,
                  TableData "Sales Cr.Memo Header"=rm,
                  TableData "Purch. Rcpt. Header"=rm,
                  TableData "Purch. Inv. Header"=rm,
                  TableData "Purch. Cr. Memo Hdr."=rm,
                  TableData "Job Ledger Entry"=rm,
                  TableData "Res. Ledger Entry"=rm,
                  TableData "Resource Register"=rm,
                  TableData "Job Register"=rm,
                  TableData "VAT Entry"=rm,
                  TableData "Bank Account Ledger Entry"=rm,
                  TableData "Check Ledger Entry"=rm,
                  TableData "Phys. Inventory Ledger Entry"=rm,
                  TableData "Issued Reminder Header"=rm,
                  TableData "Reminder/Fin. Charge Entry"=rm,
                  TableData "Issued Fin. Charge Memo Header"=rm,
                  TableData "Reservation Entry"=rm,
                  TableData "Item Application Entry"=rm,
                  TableData "Detailed Cust. Ledg. Entry"=rm,
                  TableData "Detailed Vendor Ledg. Entry"=rm,
                  TableData "Change Log Entry"=rm,
                  TableData "Approval Entry"=rm,
                  TableData "Approval Comment Line"=rm,
                  TableData "Posted Approval Entry"=rm,
                  TableData "Posted Approval Comment Line"=rm,
                  TableData "Posted Assembly Header"=rm,
                  TableData "Cost Entry"=rm,
                  TableData "Cost Register"=rm,
                  TableData "Cost Budget Entry"=rm,
                  TableData "Cost Budget Register"=rm,
                  TableData "Interaction Log Entry"=rm,
                  TableData "Campaign Entry"=rm,
                  TableData "FA Ledger Entry"=rm,
                  TableData "FA Register"=rm,
                  TableData "Maintenance Ledger Entry"=rm,
                  TableData "Ins. Coverage Ledger Entry"=rm,
                  TableData "Insurance Register"=rm,
                  TableData "Value Entry"=rm,
                  TableData "Service Ledger Entry"=rm,
                  TableData "Service Register"=rm,
                  TableData "Contract Gain/Loss Entry"=rm,
                  TableData "Filed Service Contract Header"=rm,
                  TableData "Service Shipment Header"=rm,
                  TableData "Service Invoice Header"=rm,
                  TableData "Service Cr.Memo Header"=rm,
                  TableData "Return Shipment Header"=rm,
                  TableData "Return Receipt Header"=rm,
                  TableData "Item Budget Entry"=rm,
                  TableData "Warehouse Entry"=rm,
                  TableData "Warehouse Register"=rm;

    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'The user name %1 does not exist.';
        Text001: Label 'You are renaming an existing user. This will also update all related records. Are you sure that you want to rename the user?';
        Text002: Label 'The account %1 already exists.';
        Text003: Label 'You do not have permissions for this action.';

    [Scope('Personalization')]
    procedure ValidateUserID(UserName: Code[50])
    var
        User: Record User;
    begin
        if UserName <> '' then begin
          User.SetCurrentKey("User Name");
          User.SetRange("User Name",UserName);
          if not User.FindFirst then begin
            User.Reset;
            if not User.IsEmpty then
              Error(Text000,UserName);
          end;
        end;
    end;

    [Scope('Personalization')]
    procedure LookupUserID(var UserName: Code[50])
    var
        SID: Guid;
    begin
        LookupUser(UserName,SID);
    end;

    [Scope('Personalization')]
    procedure LookupUser(var UserName: Code[50];var SID: Guid): Boolean
    var
        User: Record User;
    begin
        User.Reset;
        User.SetCurrentKey("User Name");
        User."User Name" := UserName;
        if User.Find('=><') then;
        if PAGE.RunModal(PAGE::Users,User) = ACTION::LookupOK then begin
          UserName := User."User Name";
          SID := User."User Security ID";
          exit(true);
        end;

        exit(false);
    end;

    procedure ValidateUserName(NewUser: Record User;OldUser: Record User;WindowsUserName: Text)
    var
        User: Record User;
    begin
        if NewUser."User Name" <> OldUser."User Name" then begin
          User.SetRange("User Name",NewUser."User Name");
          User.SetFilter("User Security ID",'<>%1',OldUser."User Security ID");
          if User.FindFirst then
            Error(Text002,NewUser."User Name");

          if NewUser."Windows Security ID" <> '' then
            NewUser.TestField("User Name",WindowsUserName);

          if OldUser."User Name" <> '' then
            if Confirm(Text001,false) then
              RenameUser(OldUser."User Name",NewUser."User Name")
            else
              Error('');
        end;
    end;

    local procedure IsPrimaryKeyField(TableID: Integer;FieldID: Integer;var NumberOfPrimaryKeyFields: Integer): Boolean
    var
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        RecRef: RecordRef;
        KeyRef: KeyRef;
    begin
        RecRef.Open(TableID);
        KeyRef := RecRef.KeyIndex(1);
        NumberOfPrimaryKeyFields := KeyRef.FieldCount;
        exit(ConfigValidateMgt.IsKeyField(TableID,FieldID));
    end;

    local procedure RenameRecord(var RecRef: RecordRef;TableNo: Integer;NumberOfPrimaryKeyFields: Integer;UserName: Code[50];Company: Text[30])
    var
        UserTimeRegister: Record "User Time Register";
        PrinterSelection: Record "Printer Selection";
        SelectedDimension: Record "Selected Dimension";
        OutlookSynchUserSetup: Record "Outlook Synch. User Setup";
        FAJournalSetup: Record "FA Journal Setup";
        AnalysisSelectedDimension: Record "Analysis Selected Dimension";
        WarehouseEmployee: Record "Warehouse Employee";
        MyCustomer: Record "My Customer";
        MyVendor: Record "My Vendor";
        MyItem: Record "My Item";
        MyAccount: Record "My Account";
        CueSetup: Record "Cue Setup";
        ApplicationAreaSetup: Record "Application Area Setup";
        MyJob: Record "My Job";
        MyTimeSheets: Record "My Time Sheets";
    begin
        if NumberOfPrimaryKeyFields = 1 then
          RecRef.Rename(UserName)
        else
          case TableNo of
            DATABASE::"User Time Register":
              begin
                UserTimeRegister.ChangeCompany(Company);
                RecRef.SetTable(UserTimeRegister);
                UserTimeRegister.Rename(UserName,UserTimeRegister.Date);
              end;
            DATABASE::"Printer Selection":
              begin
                RecRef.SetTable(PrinterSelection);
                PrinterSelection.Rename(UserName,PrinterSelection."Report ID");
              end;
            DATABASE::"Selected Dimension":
              begin
                SelectedDimension.ChangeCompany(Company);
                RecRef.SetTable(SelectedDimension);
                SelectedDimension.Rename(UserName,SelectedDimension."Object Type",SelectedDimension."Object ID",
                  SelectedDimension."Analysis View Code",SelectedDimension."Dimension Code");
              end;
            DATABASE::"Outlook Synch. User Setup":
              begin
                OutlookSynchUserSetup.ChangeCompany(Company);
                RecRef.SetTable(OutlookSynchUserSetup);
                OutlookSynchUserSetup.Rename(UserName,OutlookSynchUserSetup."Synch. Entity Code");
              end;
            DATABASE::"FA Journal Setup":
              begin
                FAJournalSetup.ChangeCompany(Company);
                RecRef.SetTable(FAJournalSetup);
                FAJournalSetup.Rename(FAJournalSetup."Depreciation Book Code",UserName);
              end;
            DATABASE::"Analysis Selected Dimension":
              begin
                AnalysisSelectedDimension.ChangeCompany(Company);
                RecRef.SetTable(AnalysisSelectedDimension);
                AnalysisSelectedDimension.Rename(UserName,AnalysisSelectedDimension."Object Type",AnalysisSelectedDimension."Object ID",
                  AnalysisSelectedDimension."Analysis Area",AnalysisSelectedDimension."Analysis View Code",
                  AnalysisSelectedDimension."Dimension Code");
              end;
            DATABASE::"Cue Setup":
              begin
                CueSetup.ChangeCompany(Company);
                RecRef.SetTable(CueSetup);
                CueSetup.Rename(UserName,CueSetup."Table ID",CueSetup."Field No.");
              end;
            DATABASE::"Warehouse Employee":
              begin
                WarehouseEmployee.ChangeCompany(Company);
                RecRef.SetTable(WarehouseEmployee);
                WarehouseEmployee.Rename(UserName,WarehouseEmployee."Location Code");
              end;
            DATABASE::"My Customer":
              begin
                MyCustomer.ChangeCompany(Company);
                RecRef.SetTable(MyCustomer);
                MyCustomer.Rename(UserName,MyCustomer."Customer No.");
              end;
            DATABASE::"My Vendor":
              begin
                MyVendor.ChangeCompany(Company);
                RecRef.SetTable(MyVendor);
                MyVendor.Rename(UserName,MyVendor."Vendor No.");
              end;
            DATABASE::"My Item":
              begin
                MyItem.ChangeCompany(Company);
                RecRef.SetTable(MyItem);
                MyItem.Rename(UserName,MyItem."Item No.");
              end;
            DATABASE::"My Account":
              begin
                MyAccount.ChangeCompany(Company);
                RecRef.SetTable(MyAccount);
                MyAccount.Rename(UserName,MyAccount."Account No.");
              end;
            DATABASE::"Application Area Setup":
              begin
                ApplicationAreaSetup.ChangeCompany(Company);
                RecRef.SetTable(ApplicationAreaSetup);
                ApplicationAreaSetup.Rename('','',UserName);
              end;
            DATABASE::"My Job":
              begin
                MyJob.ChangeCompany(Company);
                RecRef.SetTable(MyJob);
                MyJob.Rename(UserName,MyJob."Job No.");
              end;
            DATABASE::"My Time Sheets":
              begin
                MyTimeSheets.ChangeCompany(Company);
                RecRef.SetTable(MyTimeSheets);
                MyTimeSheets.Rename(UserName,MyTimeSheets."Time Sheet No.");
              end;
          end;
        OnAfterRenameRecord(RecRef,TableNo,NumberOfPrimaryKeyFields,UserName,Company);
    end;

    local procedure RenameUser(OldUserName: Code[50];NewUserName: Code[50])
    var
        User: Record User;
        "Field": Record "Field";
        TableInformation: Record "Table Information";
        Company: Record Company;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        NumberOfPrimaryKeyFields: Integer;
    begin
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        Field.SetRange(RelationTableNo,DATABASE::User);
        Field.SetRange(RelationFieldNo,User.FieldNo("User Name"));
        if Field.FindSet then
          repeat
            Company.FindSet;
            repeat
              RecRef.Open(Field.TableNo,false,Company.Name);
              if RecRef.ReadPermission then begin
                FieldRef := RecRef.Field(Field."No.");
                FieldRef.SetRange(OldUserName);
                if RecRef.FindSet(true) then
                  repeat
                    if IsPrimaryKeyField(Field.TableNo,Field."No.",NumberOfPrimaryKeyFields) then
                      RenameRecord(RecRef,Field.TableNo,NumberOfPrimaryKeyFields,NewUserName,Company.Name)
                    else begin
                      FieldRef2 := RecRef.Field(Field."No.");
                      FieldRef2.Value := NewUserName;
                      RecRef.Modify;
                    end;
                  until RecRef.Next = 0;
              end else begin
                TableInformation.SetFilter("Company Name",'%1|%2','',Company.Name);
                TableInformation.SetRange("Table No.",Field.TableNo);
                TableInformation.FindFirst;
                if TableInformation."No. of Records" > 0 then
                  Error(Text003);
              end;
              RecRef.Close;
            until Company.Next = 0;
          until Field.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 2000000120, 'OnAfterValidateEvent', 'Application ID', false, false)]
    local procedure SetLicenseTypeOnValidateApplicationID(var Rec: Record User;var xRec: Record User;CurrFieldNo: Integer)
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        if PermissionManager.SoftwareAsAService then
          if IsNullGuid(Rec."Application ID") then
            Rec."License Type" := Rec."License Type"::"Full User"
          else
            Rec."License Type" := Rec."License Type"::"External User";
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnAfterRenameRecord(var RecRef: RecordRef;TableNo: Integer;NumberOfPrimaryKeyFields: Integer;UserName: Code[50];Company: Text[30])
    begin
    end;
}

