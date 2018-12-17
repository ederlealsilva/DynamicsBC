report 26 "Copy Account Schedule"
{
    // version NAVW113.00

    Caption = 'Copy Account Schedule';
    ProcessingOnly = true;

    dataset
    {
        dataitem(SourceAccScheduleName;"Acc. Schedule Name")
        {

            trigger OnAfterGetRecord()
            var
                SourceAccScheduleLine: Record "Acc. Schedule Line";
            begin
                CreateNewAccountScheduleName(InputAccScheduleName,SourceAccScheduleName);

                SourceAccScheduleLine.SetRange("Schedule Name",Name);
                if SourceAccScheduleLine.FindSet then
                  repeat
                    CreateNewAccountScheduleLine(InputAccScheduleName,SourceAccScheduleLine);
                  until SourceAccScheduleLine.Next = 0;
            end;

            trigger OnPreDataItem()
            begin
                AssertTargetAccountScheduleNameNotEmpty(InputAccScheduleName);
                AssertTargetAccountScheduleNameNotExisting(InputAccScheduleName);
                AssertSourceAccountScheduleNameExists(SourceAccScheduleName);
                AssertSourceAccountScheduleNameOnlyOne(SourceAccScheduleName);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NewAccountScheduleName;InputAccScheduleName)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'New Account Schedule Name';
                        NotBlank = true;
                        ToolTip = 'Specifies the name of the new account schedule after copying.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Message(CopySuccessMsg);
    end;

    var
        InputAccScheduleName: Code[10];
        CopySuccessMsg: Label 'The new account schedule has been created successfully.';
        MissingSourceErr: Label 'There is no account schedule to copy from.';
        MultipleSourcesErr: Label 'You can only copy one account schedule at a time.';
        TargetExistsErr: Label 'The new account schedule already exists.';
        TargetNameMissingErr: Label 'You must specify a name for the new account schedule.';

    procedure GetNewAccountScheduleName(): Code[10]
    begin
        exit(InputAccScheduleName);
    end;

    local procedure AssertTargetAccountScheduleNameNotEmpty(TargetAccountScheduleName: Code[10])
    begin
        if TargetAccountScheduleName = '' then
          Error(TargetNameMissingErr);
    end;

    local procedure AssertTargetAccountScheduleNameNotExisting(TargetAccountScheduleName: Code[10])
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        if AccScheduleName.Get(TargetAccountScheduleName) then
          Error(TargetExistsErr);
    end;

    local procedure AssertSourceAccountScheduleNameExists(var FromAccScheduleName: Record "Acc. Schedule Name")
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.CopyFilters(FromAccScheduleName);
        if AccScheduleName.IsEmpty then
          Error(MissingSourceErr);
    end;

    local procedure AssertSourceAccountScheduleNameOnlyOne(var FromAccScheduleName: Record "Acc. Schedule Name")
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        AccScheduleName.CopyFilters(FromAccScheduleName);
        if AccScheduleName.Count > 1 then
          Error(MultipleSourcesErr);
    end;

    local procedure CreateNewAccountScheduleName(NewName: Code[10];FromAccScheduleName: Record "Acc. Schedule Name")
    var
        AccScheduleName: Record "Acc. Schedule Name";
    begin
        if AccScheduleName.Get(NewName) then
          exit;

        AccScheduleName.Init;
        AccScheduleName.TransferFields(FromAccScheduleName);
        AccScheduleName.Name := NewName;
        AccScheduleName.Insert;
    end;

    local procedure CreateNewAccountScheduleLine(NewName: Code[10];FromAccScheduleLine: Record "Acc. Schedule Line")
    var
        AccScheduleLine: Record "Acc. Schedule Line";
    begin
        if AccScheduleLine.Get(NewName,FromAccScheduleLine."Line No.") then
          exit;

        AccScheduleLine.Init;
        AccScheduleLine.TransferFields(FromAccScheduleLine);
        AccScheduleLine."Schedule Name" := NewName;
        AccScheduleLine.Insert;
    end;
}

