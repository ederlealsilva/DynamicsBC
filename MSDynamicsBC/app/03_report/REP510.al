report 510 "Change Log - Delete"
{
    // version NAVW113.00

    Caption = 'Change Log - Delete';
    Permissions = TableData "Change Log Entry"=rid;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Change Log Entry";"Change Log Entry")
        {
            DataItemTableView = SORTING("Table No.","Primary Key Field 1 Value");
            RequestFilterFields = "Date and Time","Table No.";

            trigger OnPreDataItem()
            begin
                DeleteAll;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if "Change Log Entry".GetFilter("Date and Time") = '' then
              "Change Log Entry".SetFilter("Date and Time",'..%1',CreateDateTime(CalcDate('<-1Y>',Today),0T));
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            ChangeLogEntry: Record "Change Log Entry";
        begin
            if CloseAction = ACTION::Cancel then
              exit(true);
            if "Change Log Entry".GetFilter("Date and Time") <> '' then begin
              ChangeLogEntry.CopyFilters("Change Log Entry");
              if not ChangeLogEntry.FindLast then
                Error(NothingToDeleteErr);
              if DT2Date(ChangeLogEntry."Date and Time") > CalcDate('<-1Y>',Today) then
                if not Confirm(Text002,false) then
                  exit(false);
            end else
              if not Confirm(Text001,false) then
                exit(false);
            exit(true);
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if not GuiAllowed then
          exit;
        Window.Close;
        Message(DeletedMsg);
    end;

    trigger OnPreReport()
    begin
        if GuiAllowed then
          Window.Open(DialogMsg);
    end;

    var
        Text001: Label 'You have not defined a date filter. Do you want to continue?';
        Text002: Label 'Your date filter allows deletion of entries that are less than one year old. Do you want to continue?';
        NothingToDeleteErr: Label 'There are no entries within the filter.';
        DeletedMsg: Label 'The selected entries were deleted.';
        Window: Dialog;
        DialogMsg: Label 'Entries are being deleted...';
}

