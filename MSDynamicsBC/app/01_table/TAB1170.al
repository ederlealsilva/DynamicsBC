table 1170 "User Task"
{
    // version NAVW113.00

    Caption = 'User Task';
    DataCaptionFields = Title;

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            Editable = false;
        }
        field(2;Title;Text[250])
        {
            Caption = 'Subject';
        }
        field(3;"Created By";Guid)
        {
            Caption = 'Created By';
            DataClassification = EndUserPseudonymousIdentifiers;
            Editable = false;
            TableRelation = User."User Security ID" WHERE ("License Type"=CONST("Full User"));
        }
        field(4;"Created DateTime";DateTime)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(5;"Assigned To";Guid)
        {
            Caption = 'Assigned To';
            TableRelation = User."User Security ID" WHERE ("License Type"=CONST("Full User"));
        }
        field(7;"Completed By";Guid)
        {
            Caption = 'Completed By';
            DataClassification = EndUserPseudonymousIdentifiers;
            TableRelation = User."User Security ID" WHERE ("License Type"=CONST("Full User"));

            trigger OnValidate()
            begin
                if not IsNullGuid("Completed By") then begin
                  "Percent Complete" := 100;
                  if "Completed DateTime" = 0DT then
                    "Completed DateTime" := CurrentDateTime;
                  if "Start DateTime" = 0DT then
                    "Start DateTime" := CurrentDateTime;
                end else begin
                  "Completed DateTime" := 0DT;
                  "Percent Complete" := 0;
                end;
            end;
        }
        field(8;"Completed DateTime";DateTime)
        {
            Caption = 'Completed Date';

            trigger OnValidate()
            begin
                if "Completed DateTime" <> 0DT then begin
                  "Percent Complete" := 100;
                  if IsNullGuid("Completed By") then
                    "Completed By" := UserSecurityId;
                  if "Start DateTime" = 0DT then
                    "Start DateTime" := CurrentDateTime;
                end else begin
                  Clear("Completed By");
                  "Percent Complete" := 0;
                end;
            end;
        }
        field(9;"Due DateTime";DateTime)
        {
            Caption = 'Due Date';
        }
        field(10;"Percent Complete";Integer)
        {
            Caption = '% Complete';
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Percent Complete" = 100 then begin
                  "Completed By" := UserSecurityId;
                  "Completed DateTime" := CurrentDateTime;
                end else begin
                  Clear("Completed By");
                  Clear("Completed DateTime");
                end;

                if "Percent Complete" = 0 then
                  "Start DateTime" := 0DT
                else
                  if "Start DateTime" = 0DT then
                    "Start DateTime" := CurrentDateTime;
            end;
        }
        field(11;"Start DateTime";DateTime)
        {
            Caption = 'Start Date';
        }
        field(12;Priority;Option)
        {
            Caption = 'Priority';
            OptionCaption = ',Low,Normal,High';
            OptionMembers = ,Low,Normal,High;
        }
        field(13;Description;BLOB)
        {
            Caption = 'Description';
            SubType = Memo;
        }
        field(14;"Created By User Name";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("Created By"),
                                                         "License Type"=CONST("Full User")));
            Caption = 'User Created By';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15;"Assigned To User Name";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("Assigned To"),
                                                         "License Type"=CONST("Full User")));
            Caption = 'User Assigned To';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16;"Completed By User Name";Code[50])
        {
            CalcFormula = Lookup(User."User Name" WHERE ("User Security ID"=FIELD("Completed By"),
                                                         "License Type"=CONST("Full User")));
            Caption = 'User Completed By';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17;"Object Type";Option)
        {
            Caption = 'Link Task To';
            OptionCaption = ',,,Report,,,,,Page';
            OptionMembers = ,,,"Report",,,,,"Page";
        }
        field(18;"Object ID";Integer)
        {
            Caption = 'Object ID';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=FIELD("Object Type"));
        }
        field(19;"Parent ID";Integer)
        {
            Caption = 'Parent ID';
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        DummyUserTask: Record "User Task";
    begin
        if ("Percent Complete" > 0) and ("Percent Complete" < 100) then
          if not Confirm(ConfirmDeleteQst) then
            Error('');

        if "Parent ID" > 0 then
          if Confirm(ConfirmDeleteAllOccurrencesQst) then begin
            DummyUserTask.CopyFilters(Rec);
            Reset;
            SetRange("Parent ID","Parent ID");
            DeleteAll;
            CopyFilters(DummyUserTask);
          end
    end;

    trigger OnInsert()
    begin
        Validate("Created DateTime",CurrentDateTime);
        "Created By" := UserSecurityId
    end;

    var
        ConfirmDeleteQst: Label 'This task is started but not complete, delete anyway?';
        ConfirmDeleteAllOccurrencesQst: Label 'Delete all occurrences of this task?';

    [Scope('Personalization')]
    procedure CreateRecurrence(RecurringStartDate: Date;Recurrence: DateFormula;Occurrences: Integer)
    var
        UserTaskTemp: Record "User Task";
        "Count": Integer;
        TempDueDate: Date;
    begin
        Validate("Parent ID",ID);
        Validate("Due DateTime",CreateDateTime(RecurringStartDate,000000T));
        Modify(true);

        TempDueDate := RecurringStartDate;
        while Count < Occurrences - 1 do begin
          Clear(UserTaskTemp);
          UserTaskTemp.Validate(Title,Title);
          UserTaskTemp.SetDescription(GetDescription);
          UserTaskTemp."Created By" := UserSecurityId;
          UserTaskTemp.Validate("Created DateTime",CurrentDateTime);
          UserTaskTemp.Validate("Assigned To","Assigned To");
          UserTaskTemp.Validate(Priority,Priority);
          UserTaskTemp.Validate("Object Type","Object Type");
          UserTaskTemp.Validate("Object ID","Object ID");
          UserTaskTemp.Validate("Parent ID",ID);
          TempDueDate := CalcDate(Recurrence,TempDueDate);
          UserTaskTemp.Validate("Due DateTime",CreateDateTime(TempDueDate,000000T));
          UserTaskTemp.Insert(true);
          Count := Count + 1;
        end
    end;

    [Scope('Personalization')]
    procedure SetCompleted()
    begin
        "Percent Complete" := 100;
        "Completed By" := UserSecurityId;
        "Completed DateTime" := CurrentDateTime;

        if "Start DateTime" = 0DT then
          "Start DateTime" := CurrentDateTime;
    end;

    [Scope('Personalization')]
    procedure SetStyle(): Text
    begin
        if "Percent Complete" <> 100 then begin
          if ("Due DateTime" <> 0DT) and ("Due DateTime" <= CurrentDateTime) then
            exit('Unfavorable')
        end;
        exit('');
    end;

    [Scope('Personalization')]
    procedure GetDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        DescriptionFieldRef: FieldRef;
        UserTaskRecRef: RecordRef;
        StreamText: Text;
    begin
        UserTaskRecRef.GetTable(Rec);
        DescriptionFieldRef := UserTaskRecRef.Field(FieldNo(Description));
        StreamText := TypeHelper.ReadTextBlobWithTextEncoding(DescriptionFieldRef,TEXTENCODING::Windows);
        exit(StreamText);
    end;

    [Scope('Personalization')]
    procedure SetDescription(StreamText: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        DescriptionFieldRef: FieldRef;
        UserTaskRecRef: RecordRef;
    begin
        Clear(Description);
        UserTaskRecRef.GetTable(Rec);
        DescriptionFieldRef := UserTaskRecRef.Field(FieldNo(Description));
        if TypeHelper.WriteBlobWithEncoding(DescriptionFieldRef,StreamText,TEXTENCODING::Windows) then begin
          Description := DescriptionFieldRef.Value;
          if Modify(true) then;
        end;
    end;

    [Scope('Personalization')]
    procedure IsCompleted(): Boolean
    begin
        exit("Percent Complete" = 100);
    end;
}

