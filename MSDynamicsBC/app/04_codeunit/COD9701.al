codeunit 9701 "Cue Setup"
{
    // version NAVW113.00

    Permissions = TableData "Cue Setup"=r;
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        TempGlobalCueSetup: Record "Cue Setup" temporary;

    [Scope('Personalization')]
    procedure GetCustomizedCueStyle(TableId: Integer;FieldId: Integer;CueValue: Decimal): Text
    var
        CueSetup: Record "Cue Setup";
        Style: Option;
    begin
        Style := GetCustomizedCueStyleOption(TableId,FieldId,CueValue);
        exit(CueSetup.ConvertStyleToStyleText(Style));
    end;

    [Scope('Personalization')]
    procedure OpenCustomizePageForCurrentUser(TableId: Integer)
    var
        TempCueSetupRecord: Record "Cue Setup" temporary;
    begin
        // Set TableNo in filter group 4, which is invisible and unchangeable for the user.
        // The user should only be able to set personal styles/thresholds, and only for the given table.
        TempCueSetupRecord.FilterGroup(4);
        TempCueSetupRecord.SetRange("Table ID",TableId);
        PAGE.RunModal(PAGE::"Cue Setup End User",TempCueSetupRecord);
    end;

    [Scope('Personalization')]
    procedure PopulateTempCueSetupRecords(var TempCueSetupPageSourceRec: Record "Cue Setup" temporary)
    var
        CueSetup: Record "Cue Setup";
        "Field": Record "Field";
    begin
        // Populate temporary records with appropriate records from the real table.
        CueSetup.CopyFilters(TempCueSetupPageSourceRec);
        CueSetup.SetFilter("User Name",'%1|%2',UserId,'');

        // Insert user specific records and company wide records.
        CueSetup.Ascending := false;
        if CueSetup.FindSet then begin
          repeat
            TempCueSetupPageSourceRec.TransferFields(CueSetup);

            if TempCueSetupPageSourceRec."User Name" = '' then
              TempCueSetupPageSourceRec.Personalized := false
            else
              TempCueSetupPageSourceRec.Personalized := true;

            TempCueSetupPageSourceRec."User Name" := UserId;
            if TempCueSetupPageSourceRec.Insert then;
          until CueSetup.Next = 0;
        end;

        // Insert default records
        // Look up in the Fields virtual table
        // Filter on Table No=Table No and Type=Decimal|Integer. This should give us approximately the
        // fields that are "valid" for a cue control.
        Field.SetFilter(TableNo,TempCueSetupPageSourceRec.GetFilter("Table ID"));
        Field.SetFilter(Type,'%1|%2',Field.Type::Decimal,Field.Type::Integer);
        Field.SetFilter(ObsoleteState,'<>%1',Field.ObsoleteState::Removed);
        if Field.FindSet then begin
          repeat
            if not TempCueSetupPageSourceRec.Get(UserId,Field.TableNo,Field."No.") then begin
              TempCueSetupPageSourceRec.Init;
              TempCueSetupPageSourceRec."User Name" := UserId;
              TempCueSetupPageSourceRec."Table ID" := Field.TableNo;
              TempCueSetupPageSourceRec."Field No." := Field."No.";
              TempCueSetupPageSourceRec.Personalized := false;
              TempCueSetupPageSourceRec.Insert;
            end;
          until Field.Next = 0;

          // Clear last filter
          TempCueSetupPageSourceRec.SetRange("Field No.");
          if TempCueSetupPageSourceRec.FindFirst then;
        end;
    end;

    [Scope('Personalization')]
    procedure CopyTempCueSetupRecordsToTable(var TempCueSetupPageSourceRec: Record "Cue Setup" temporary)
    var
        CueSetup: Record "Cue Setup";
    begin
        if TempCueSetupPageSourceRec.FindSet then begin
          repeat
            if TempCueSetupPageSourceRec.Personalized then begin
              CueSetup.TransferFields(TempCueSetupPageSourceRec);
              if CueSetup.Find then begin
                CueSetup.TransferFields(TempCueSetupPageSourceRec);
                // Personalized field contains tempororaty property we never save it in the database.
                CueSetup.Personalized := false;
                CueSetup.Modify
              end else begin
                // Personalized field contains tempororaty property we never save it in the database.
                CueSetup.Personalized := false;
                CueSetup.Insert;
              end;
            end else begin
              CueSetup.TransferFields(TempCueSetupPageSourceRec);
              if CueSetup.Delete then;
            end;
          until TempCueSetupPageSourceRec.Next = 0;
        end;
        ClearCachedValues;
    end;

    [Scope('Personalization')]
    procedure ValidatePersonalizedField(var TempCueSetupPageSourceRec: Record "Cue Setup" temporary)
    var
        CueSetup: Record "Cue Setup";
    begin
        if TempCueSetupPageSourceRec.Personalized = false then
          if CueSetup.Get('',TempCueSetupPageSourceRec."Table ID",TempCueSetupPageSourceRec."Field No.") then begin
            // Revert back to company default if present.
            TempCueSetupPageSourceRec."Low Range Style" := CueSetup."Low Range Style";
            TempCueSetupPageSourceRec."Threshold 1" := CueSetup."Threshold 1";
            TempCueSetupPageSourceRec."Middle Range Style" := CueSetup."Middle Range Style";
            TempCueSetupPageSourceRec."Threshold 2" := CueSetup."Threshold 2";
            TempCueSetupPageSourceRec."High Range Style" := CueSetup."High Range Style";
          end else begin
            // Revert to "no values".
            TempCueSetupPageSourceRec."Low Range Style" := TempCueSetupPageSourceRec."Low Range Style"::None;
            TempCueSetupPageSourceRec."Threshold 1" := 0;
            TempCueSetupPageSourceRec."Middle Range Style" := TempCueSetupPageSourceRec."Middle Range Style"::None;
            TempCueSetupPageSourceRec."Threshold 2" := 0;
            TempCueSetupPageSourceRec."High Range Style" := TempCueSetupPageSourceRec."High Range Style"::None;
          end;
    end;

    local procedure GetCustomizedCueStyleOption(TableId: Integer;FieldNo: Integer;CueValue: Decimal): Integer
    var
        CueSetup: Record "Cue Setup";
    begin
        FindCueSetup(CueSetup,TableId,FieldNo);
        exit(CueSetup.GetStyleForValue(CueValue));
    end;

    local procedure FindCueSetup(var CueSetup: Record "Cue Setup";TableId: Integer;FieldNo: Integer)
    var
        Found: Boolean;
    begin
        if not TempGlobalCueSetup.Get(UserId,TableId,FieldNo) then begin
          Found := CueSetup.Get(UserId,TableId,FieldNo);
          if not Found then
            Found := CueSetup.Get('',TableId,FieldNo);
          if Found then
            TempGlobalCueSetup := CueSetup
          else begin // add default to cache
            TempGlobalCueSetup.Init;
            TempGlobalCueSetup."Table ID" := TableId;
            TempGlobalCueSetup."Field No." := FieldNo;
          end;
          TempGlobalCueSetup."User Name" := UserId;
          TempGlobalCueSetup.Insert;
        end;
        CueSetup := TempGlobalCueSetup;
    end;

    procedure ClearCachedValues()
    begin
        TempGlobalCueSetup.DeleteAll;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2000000004, 'GetCueStyle', '', false, false)]
    local procedure GetCueStyle(TableId: Integer;FieldNo: Integer;CueValue: Decimal;var StyleText: Text)
    begin
        StyleText := GetCustomizedCueStyle(TableId,FieldNo,CueValue)
    end;
}

