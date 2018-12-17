table 1808 "Aggregated Assisted Setup"
{
    // version NAVW113.00

    Caption = 'Aggregated Assisted Setup';

    fields
    {
        field(1;"Page ID";Integer)
        {
            Caption = 'Page ID';
        }
        field(2;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(3;"Order";Integer)
        {
            Caption = 'Order';
        }
        field(4;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Not Completed,Completed,Not Started,Seen,Watched,Read, ';
            OptionMembers = "Not Completed",Completed,"Not Started",Seen,Watched,Read," ";
        }
        field(5;Visible;Boolean)
        {
            Caption = 'Visible';
        }
        field(8;Icon;Media)
        {
            Caption = 'Icon';
        }
        field(9;"Item Type";Option)
        {
            Caption = 'Item Type';
            InitValue = "Setup and Help";
            OptionCaption = ' ,Group,Setup and Help';
            OptionMembers = " ",Group,"Setup and Help";
        }
        field(12;"Assisted Setup Page ID";Integer)
        {
            Caption = 'Assisted Setup Page ID';
        }
        field(17;"External Assisted Setup";Boolean)
        {
            Caption = 'External Assisted Setup';
        }
        field(18;"Record ID";RecordID)
        {
            Caption = 'Record ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Page ID")
        {
        }
        key(Key2;"External Assisted Setup","Order",Visible)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick;Name,Status,Icon)
        {
        }
    }

    var
        RunSetupAgainQst: Label 'You have already completed the %1 assisted setup guide. Do you want to run it again?', Comment='%1 = Assisted Setup Name';

    [Scope('Personalization')]
    procedure RunAssistedSetup()
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        if "Item Type" <> "Item Type"::"Setup and Help" then
          exit;

        if Status = Status::Completed then
          case "Page ID" of
            PAGE::"Assisted Company Setup Wizard":
              AssistedSetup.HandleOpenCompletedAssistedCompanySetupWizard;
            else
              if not Confirm(RunSetupAgainQst,false,Name) then
                exit;
          end;

        Commit;
        PAGE.RunModal("Assisted Setup Page ID");
        OnUpdateAssistedSetupStatus(Rec);
    end;

    [Scope('Personalization')]
    procedure AddExtensionAssistedSetup(PageID: Integer;AssistantName: Text[250];AssistantVisible: Boolean;AssistedSetupRecordID: RecordID;AssistedSetupStatus: Option;AssistedSetupIconCode: Code[50])
    var
        AssistedSetupIcons: Record "Assisted Setup Icons";
    begin
        if not Get(PageID) then begin
          Clear(Rec);
          "Page ID" := PageID;
          Visible := AssistantVisible;
          Insert(true);
        end;

        "Page ID" := PageID;
        Name := AssistantName;
        Order := GetNextSortingOrder;
        "Item Type" := "Item Type"::"Setup and Help";

        "Assisted Setup Page ID" := PageID;
        "External Assisted Setup" := true;
        "Record ID" := AssistedSetupRecordID;
        Status := AssistedSetupStatus;

        if AssistedSetupIcons.Get(AssistedSetupIconCode) then
          Icon := AssistedSetupIcons.Image;

        Modify(true);
    end;

    [Scope('Personalization')]
    procedure InsertAssistedSetupIcon(AssistedSetupIconCode: Code[50];IconInStream: InStream)
    var
        AssistedSetupIcons: Record "Assisted Setup Icons";
    begin
        if not AssistedSetupIcons.Get(AssistedSetupIconCode) then begin
          AssistedSetupIcons.Init;
          AssistedSetupIcons."No." := AssistedSetupIconCode;
          AssistedSetupIcons.Image.ImportStream(IconInStream,AssistedSetupIconCode);
          AssistedSetupIcons.Insert(true);
        end else begin
          AssistedSetupIcons.Image.ImportStream(IconInStream,AssistedSetupIconCode);
          AssistedSetupIcons.Modify(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnRegisterAssistedSetup(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Scope('Personalization')]
    procedure OnUpdateAssistedSetupStatus(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup" temporary)
    begin
    end;

    local procedure GetNextSortingOrder() SortingOrder: Integer
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        SortingOrder := 1;

        AssistedSetup.SetCurrentKey(Order);
        if AssistedSetup.FindLast then
          SortingOrder := AssistedSetup.Order + 1;
    end;

    [Scope('Personalization')]
    procedure SetStatus(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup" temporary;EntryId: Integer;ItemStatus: Option)
    begin
        TempAggregatedAssistedSetup.Get(EntryId);
        TempAggregatedAssistedSetup.Status := ItemStatus;
        TempAggregatedAssistedSetup.Modify;
    end;
}

