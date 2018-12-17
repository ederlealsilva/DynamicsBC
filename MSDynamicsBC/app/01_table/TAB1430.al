table 1430 "Role Center Notifications"
{
    // version NAVW113.00

    Caption = 'Role Center Notifications';
    DataPerCompany = false;

    fields
    {
        field(1;"User SID";Guid)
        {
            Caption = 'User SID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(2;"First Session ID";Integer)
        {
            Caption = 'First Session ID';
        }
        field(3;"Last Session ID";Integer)
        {
            Caption = 'Last Session ID';
        }
        field(4;"Evaluation Notification State";Option)
        {
            Caption = 'Evaluation Notification State';
            OptionCaption = 'Disabled,Enabled,Clicked';
            OptionMembers = Disabled,Enabled,Clicked;
        }
        field(5;"Buy Notification State";Option)
        {
            Caption = 'Buy Notification State';
            OptionCaption = 'Disabled,Enabled,Clicked';
            OptionMembers = Disabled,Enabled,Clicked;
        }
    }

    keys
    {
        key(Key1;"User SID")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure Initialize()
    begin
        if not Get(UserSecurityId) then begin
          Init;
          "User SID" := UserSecurityId;
          "First Session ID" := SessionId;
          "Last Session ID" := SessionId;
          "Evaluation Notification State" := "Evaluation Notification State"::Enabled;
          "Buy Notification State" := "Buy Notification State"::Disabled;
          Insert;
        end else
          if SessionId <> "Last Session ID" then begin
            "Last Session ID" := SessionId;
            "Evaluation Notification State" := "Evaluation Notification State"::Enabled;
            "Buy Notification State" := "Buy Notification State"::Enabled;
            Modify;
          end;
    end;

    [Scope('Personalization')]
    procedure IsFirstLogon(): Boolean
    begin
        Initialize;
        exit(SessionId = "First Session ID");
    end;

    [Scope('Personalization')]
    procedure GetEvaluationNotificationState(): Integer
    begin
        if Get(UserSecurityId) then
          exit("Evaluation Notification State");
        exit("Evaluation Notification State"::Disabled);
    end;

    [Scope('Personalization')]
    procedure SetEvaluationNotificationState(NewState: Option)
    begin
        if Get(UserSecurityId) then begin
          "Evaluation Notification State" := NewState;
          Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure GetBuyNotificationState(): Integer
    begin
        if Get(UserSecurityId) then
          exit("Buy Notification State");
        exit("Buy Notification State"::Disabled);
    end;

    [Scope('Personalization')]
    procedure SetBuyNotificationState(NewState: Option)
    begin
        if Get(UserSecurityId) then begin
          "Buy Notification State" := NewState;
          Modify;
        end;
    end;
}

