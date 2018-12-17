codeunit 447 "Record Link Management"
{
    // version NAVW111.00


    trigger OnRun()
    begin
        if Confirm(Text001,false) then begin
          RemoveOrphanedLink;
          Message(Text004,NoOfRemoved);
        end;
    end;

    var
        Text001: Label 'Do you want to remove links with no record reference?';
        Text002: Label 'Removing Record Links without record reference.\';
        Text003: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004: Label '%1 orphaned links were removed.';
        NoOfRemoved: Integer;

    local procedure RemoveOrphanedLink()
    var
        RecordLink: Record "Record Link";
        RecordRef: RecordRef;
        PrevRecID: RecordID;
        Window: Dialog;
        i: Integer;
        Total: Integer;
        TimeLocked: Time;
        InTransaction: Boolean;
        RecordExists: Boolean;
    begin
        Window.Open(Text002 + Text003);
        TimeLocked := Time;
        with RecordLink do begin
          SetFilter(Company,'%1|%2','',CompanyName);
          SetCurrentKey("Record ID");
          Total := Count;
          if Total = 0 then
            exit;
          if Find('-') then
            repeat
              i := i + 1;
              if (i mod 1000) = 0 then
                Window.Update(1,Round(i / Total * 10000,1));
              if Format("Record ID") <> Format(PrevRecID) then begin  // Direct comparison doesn't work.
                PrevRecID := "Record ID";
                RecordExists := RecordRef.Get("Record ID");
              end;
              if not RecordExists then begin
                Delete;
                NoOfRemoved := NoOfRemoved + 1;
                if not InTransaction then
                  TimeLocked := Time;
                InTransaction := true;
              end;
              if InTransaction and (Time > (TimeLocked + 1000)) then begin
                Commit;
                TimeLocked := Time;
                InTransaction := false;
              end;
            until Next = 0;
        end;
        Window.Close;
    end;

    local procedure ResetNotifyOnLinks(RecVar: Variant)
    var
        RecordLink: Record "Record Link";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVar);
        RecordLink.SetRange("Record ID",RecRef.RecordId);
        RecordLink.SetRange(Notify,true);
        if not RecordLink.IsEmpty then
          RecordLink.ModifyAll(Notify,false);
    end;

    [Scope('Personalization')]
    procedure CopyLinks(FromRecord: Variant;ToRecord: Variant)
    var
        RecRefTo: RecordRef;
    begin
        RecRefTo.GetTable(ToRecord);
        RecRefTo.CopyLinks(FromRecord);
        ResetNotifyOnLinks(RecRefTo);
    end;
}

