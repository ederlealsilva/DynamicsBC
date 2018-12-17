codeunit 2300 "Tenant License State"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        TenantLicenseStatePeriodProvider: DotNet TenantLicenseStatePeriodProvider;

    [Scope('Personalization')]
    procedure GetPeriod(TenantLicenseState: Option): Integer
    begin
        exit(TenantLicenseStatePeriodProvider.ALGetPeriod(TenantLicenseState));
    end;

    [Scope('Personalization')]
    procedure GetCurrentState(var TenantLicenseState: Option)
    var
        PreviousState: Option;
    begin
        GetLicenseState(TenantLicenseState,PreviousState);
    end;

    [Scope('Personalization')]
    procedure GetStartDate(var StartDate: DateTime)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast then
          StartDate := TenantLicenseState."Start Date";
    end;

    [Scope('Personalization')]
    procedure GetEndDate(var EndDate: DateTime)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast then
          EndDate := TenantLicenseState."End Date";
    end;

    [Scope('Personalization')]
    procedure IsEvaluationMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState,PreviousState);
        exit(CurrentState = TenantLicenseState.State::Evaluation);
    end;

    [Scope('Personalization')]
    procedure IsTrialMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState,PreviousState);
        exit(CurrentState = TenantLicenseState.State::Trial);
    end;

    [Scope('Personalization')]
    procedure IsTrialSuspendedMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState,PreviousState);
        exit((CurrentState = TenantLicenseState.State::Suspended) and (PreviousState = TenantLicenseState.State::Trial));
    end;

    [Scope('Personalization')]
    procedure IsPaidMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState,PreviousState);
        exit(CurrentState = TenantLicenseState.State::Paid);
    end;

    [Scope('Personalization')]
    procedure IsPaidWarningMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState,PreviousState);
        exit((CurrentState = TenantLicenseState.State::Warning) and (PreviousState = TenantLicenseState.State::Paid));
    end;

    [Scope('Personalization')]
    procedure IsPaidSuspendedMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState,PreviousState);
        exit((CurrentState = TenantLicenseState.State::Suspended) and (PreviousState = TenantLicenseState.State::Paid));
    end;

    local procedure GetLicenseState(var CurrentState: Option;var PreviousState: Option)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        PreviousState := TenantLicenseState.State::Evaluation;
        if TenantLicenseState.Find('+') then begin
          CurrentState := TenantLicenseState.State;
          if (CurrentState = TenantLicenseState.State::Warning) or (CurrentState = TenantLicenseState.State::Suspended) then begin
            while TenantLicenseState.Next(-1) <> 0 do begin
              PreviousState := TenantLicenseState.State;
              if (PreviousState = TenantLicenseState.State::Trial) or (PreviousState = TenantLicenseState.State::Paid) then
                exit;
            end;
            PreviousState := TenantLicenseState.State::Paid;
          end;
        end else
          CurrentState := TenantLicenseState.State::Evaluation;
    end;
}

