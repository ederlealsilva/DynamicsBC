table 1433 "Net Promoter Score"
{
    // version NAVW113.00

    Caption = 'Net Promoter Score';
    DataPerCompany = false;

    fields
    {
        field(1;"User SID";Guid)
        {
            Caption = 'User SID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(4;"Last Request Time";DateTime)
        {
            Caption = 'Last Request Time';
        }
        field(5;"Send Request";Boolean)
        {
            Caption = 'Send Request';
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
    procedure UpdateRequestSendingStatus()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        if not NetPromoterScoreMgt.IsNpsSupported then
          exit;

        if not Get(UserSecurityId) then begin
          Init;
          "User SID" := UserSecurityId;
          "Last Request Time" := CurrentDateTime;
          "Send Request" := true;
          Insert;
        end else begin
          "Last Request Time" := CurrentDateTime;
          "Send Request" := true;
          Modify;
        end;
    end;

    [Scope('Personalization')]
    procedure DisableRequestSending()
    var
        NetPromoterScoreMgt: Codeunit "Net Promoter Score Mgt.";
    begin
        if not NetPromoterScoreMgt.IsNpsSupported then
          exit;

        if not Get(UserSecurityId) then
          exit;

        "Send Request" := false;
        Modify;
    end;

    [Scope('Personalization')]
    procedure ShouldSendRequest(): Boolean
    begin
        if not Get(UserSecurityId) then
          exit(true);

        exit("Send Request");
    end;
}

