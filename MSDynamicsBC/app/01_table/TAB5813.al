table 5813 "Inventory Posting Setup"
{
    // version NAVW113.00

    Caption = 'Inventory Posting Setup';

    fields
    {
        field(1;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(2;"Invt. Posting Group Code";Code[20])
        {
            Caption = 'Invt. Posting Group Code';
            NotBlank = true;
            TableRelation = "Inventory Posting Group";
        }
        field(6;"Inventory Account";Code[20])
        {
            Caption = 'Inventory Account';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount(
                  "Inventory Account",GLAccountCategory."Account Category"::Assets,GLAccountCategoryMgt.GetInventory);
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Inventory Account",false,false,GLAccountCategory."Account Category"::Assets,GLAccountCategoryMgt.GetInventory);
            end;
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(40;"Used in Ledger Entries";Integer)
        {
            CalcFormula = Count("Value Entry" WHERE ("Location Code"=FIELD("Location Code"),
                                                     "Inventory Posting Group"=FIELD("Invt. Posting Group Code")));
            Caption = 'Used in Ledger Entries';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteReason = 'Replaced by code';
            ObsoleteState = Removed;
        }
        field(5800;"Inventory Account (Interim)";Code[20])
        {
            Caption = 'Inventory Account (Interim)';
            TableRelation = "G/L Account";

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccount(
                  "Inventory Account",GLAccountCategory."Account Category"::Assets,GLAccountCategoryMgt.GetInventory);
            end;

            trigger OnValidate()
            begin
                GLAccountCategoryMgt.CheckGLAccount(
                  "Inventory Account (Interim)",false,false,GLAccountCategory."Account Category"::Assets,GLAccountCategoryMgt.GetInventory);
            end;
        }
        field(99000750;"WIP Account";Code[20])
        {
            AccessByPermission = TableData "Production Order"=R;
            Caption = 'WIP Account';
            TableRelation = "G/L Account";
        }
        field(99000753;"Material Variance Account";Code[20])
        {
            Caption = 'Material Variance Account';
            TableRelation = "G/L Account";
        }
        field(99000754;"Capacity Variance Account";Code[20])
        {
            Caption = 'Capacity Variance Account';
            TableRelation = "G/L Account";
        }
        field(99000755;"Mfg. Overhead Variance Account";Code[20])
        {
            Caption = 'Mfg. Overhead Variance Account';
            TableRelation = "G/L Account";
        }
        field(99000756;"Cap. Overhead Variance Account";Code[20])
        {
            Caption = 'Cap. Overhead Variance Account';
            TableRelation = "G/L Account";
        }
        field(99000757;"Subcontracted Variance Account";Code[20])
        {
            AccessByPermission = TableData "Production Order"=R;
            Caption = 'Subcontracted Variance Account';
            TableRelation = "G/L Account";
        }
    }

    keys
    {
        key(Key1;"Location Code","Invt. Posting Group Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckSetupUsage;
    end;

    var
        GLAccountCategory: Record "G/L Account Category";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        YouCannotDeleteErr: Label 'You cannot delete %1 %2.', Comment='%1 = Location Code; %2 = Posting Group';
        PostingSetupMgt: Codeunit PostingSetupManagement;

    local procedure CheckSetupUsage()
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Location Code","Location Code");
        ValueEntry.SetRange("Inventory Posting Group","Invt. Posting Group Code");
        if not ValueEntry.IsEmpty then
          Error(YouCannotDeleteErr,"Location Code","Invt. Posting Group Code");
    end;

    [Scope('Personalization')]
    procedure GetCapacityVarianceAccount(): Code[20]
    begin
        if "Capacity Variance Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Capacity Variance Account"));
        TestField("Capacity Variance Account");
        exit("Capacity Variance Account");
    end;

    [Scope('Personalization')]
    procedure GetCapOverheadVarianceAccount(): Code[20]
    begin
        if "Cap. Overhead Variance Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Cap. Overhead Variance Account"));
        TestField("Cap. Overhead Variance Account");
        exit("Cap. Overhead Variance Account");
    end;

    [Scope('Personalization')]
    procedure GetInventoryAccount(): Code[20]
    begin
        if "Inventory Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Inventory Account"));
        TestField("Inventory Account");
        exit("Inventory Account");
    end;

    [Scope('Personalization')]
    procedure GetInventoryAccountInterim(): Code[20]
    begin
        if "Inventory Account (Interim)" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Inventory Account (Interim)"));
        TestField("Inventory Account (Interim)");
        exit("Inventory Account (Interim)");
    end;

    [Scope('Personalization')]
    procedure GetMaterialVarianceAccount(): Code[20]
    begin
        if "Material Variance Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Material Variance Account"));
        TestField("Material Variance Account");
        exit("Material Variance Account");
    end;

    [Scope('Personalization')]
    procedure GetMfgOverheadVarianceAccount(): Code[20]
    begin
        if "Mfg. Overhead Variance Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Mfg. Overhead Variance Account"));
        TestField("Mfg. Overhead Variance Account");
        exit("Mfg. Overhead Variance Account");
    end;

    [Scope('Personalization')]
    procedure GetSubcontractedVarianceAccount(): Code[20]
    begin
        if "Subcontracted Variance Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("Subcontracted Variance Account"));
        TestField("Subcontracted Variance Account");
        exit("Subcontracted Variance Account");
    end;

    [Scope('Personalization')]
    procedure GetWIPAccount(): Code[20]
    begin
        if "WIP Account" = '' then
          PostingSetupMgt.SendInvtPostingSetupNotification(Rec,FieldCaption("WIP Account"));
        TestField("WIP Account");
        exit("WIP Account");
    end;

    procedure SuggestSetupAccounts()
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        if "Inventory Account" = '' then
          SuggestAccount(RecRef,FieldNo("Inventory Account"));
        if "Inventory Account" = '' then
          SuggestAccount(RecRef,FieldNo("Inventory Account (Interim)"));
        if "WIP Account" = '' then
          SuggestAccount(RecRef,FieldNo("WIP Account"));
        if "Material Variance Account" = '' then
          SuggestAccount(RecRef,FieldNo("Material Variance Account"));
        if "Capacity Variance Account" = '' then
          SuggestAccount(RecRef,FieldNo("Capacity Variance Account"));
        if "Mfg. Overhead Variance Account" = '' then
          SuggestAccount(RecRef,FieldNo("Mfg. Overhead Variance Account"));
        if "Cap. Overhead Variance Account" = '' then
          SuggestAccount(RecRef,FieldNo("Cap. Overhead Variance Account"));
        if "Subcontracted Variance Account" = '' then
          SuggestAccount(RecRef,FieldNo("Subcontracted Variance Account"));
        RecRef.Modify;
    end;

    local procedure SuggestAccount(var RecRef: RecordRef;AccountFieldNo: Integer)
    var
        TempAccountUseBuffer: Record "Account Use Buffer" temporary;
        RecFieldRef: FieldRef;
        InvtPostingSetupRecRef: RecordRef;
        InvtPostingSetupFieldRef: FieldRef;
    begin
        InvtPostingSetupRecRef.Open(DATABASE::"Inventory Posting Setup");

        InvtPostingSetupRecRef.Reset;
        InvtPostingSetupFieldRef := InvtPostingSetupRecRef.Field(FieldNo("Invt. Posting Group Code"));
        InvtPostingSetupFieldRef.SetFilter('<>%1',"Invt. Posting Group Code");
        InvtPostingSetupFieldRef := InvtPostingSetupRecRef.Field(FieldNo("Location Code"));
        InvtPostingSetupFieldRef.SetRange("Location Code");
        TempAccountUseBuffer.UpdateBuffer(InvtPostingSetupRecRef,AccountFieldNo);

        InvtPostingSetupRecRef.Close;

        TempAccountUseBuffer.Reset;
        TempAccountUseBuffer.SetCurrentKey("No. of Use");
        if TempAccountUseBuffer.FindLast then begin
          RecFieldRef := RecRef.Field(AccountFieldNo);
          RecFieldRef.Value(TempAccountUseBuffer."Account No.");
        end;
    end;
}

