page 9243 "Res. Group Capacity Matrix"
{
    // version NAVW113.00

    Caption = 'Res. Group Capacity Matrix';
    Editable = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "Resource Group";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies a short description of the resource group.';
                }
                field(Field1;MATRIX_CellData[1])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[1];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(1);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(1);
                    end;
                }
                field(Field2;MATRIX_CellData[2])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[2];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(2);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(2);
                    end;
                }
                field(Field3;MATRIX_CellData[3])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[3];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(3);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(3);
                    end;
                }
                field(Field4;MATRIX_CellData[4])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[4];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(4);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(4);
                    end;
                }
                field(Field5;MATRIX_CellData[5])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[5];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(5);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(5);
                    end;
                }
                field(Field6;MATRIX_CellData[6])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[6];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(6);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(6);
                    end;
                }
                field(Field7;MATRIX_CellData[7])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[7];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(7);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(7);
                    end;
                }
                field(Field8;MATRIX_CellData[8])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[8];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(8);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(8);
                    end;
                }
                field(Field9;MATRIX_CellData[9])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[9];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(9);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(9);
                    end;
                }
                field(Field10;MATRIX_CellData[10])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[10];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(10);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(10);
                    end;
                }
                field(Field11;MATRIX_CellData[11])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[11];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(11);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(11);
                    end;
                }
                field(Field12;MATRIX_CellData[12])
                {
                    ApplicationArea = Jobs;
                    CaptionClass = '3,' + MATRIX_ColumnCaption[12];

                    trigger OnDrillDown()
                    begin
                        MatrixOnDrillDown(12);
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCapacity(12);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Res. &Group")
            {
                Caption = 'Res. &Group';
                Image = Group;
                action(Statistics)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Res. Gr. Statistics";
                    RunPageLink = "No."=FIELD("No."),
                                  "Date Filter"=FIELD("Date Filter"),
                                  "Unit of Measure Filter"=FIELD("Unit of Measure Filter"),
                                  "Chargeable Filter"=FIELD("Chargeable Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name"=CONST("Resource Group"),
                                  "No."=FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID"=CONST(152),
                                  "No."=FIELD("No.");
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
            }
            group("&Prices")
            {
                Caption = '&Prices';
                Image = Price;
                action(Costs)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Costs';
                    Image = ResourceCosts;
                    RunObject = Page "Resource Costs";
                    RunPageLink = Type=CONST("Group(Resource)"),
                                  Code=FIELD("No.");
                    ToolTip = 'View or change detailed information about costs for the resource.';
                }
                action(Prices)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Prices';
                    Image = Price;
                    RunObject = Page "Resource Prices";
                    RunPageLink = Type=CONST("Group(Resource)"),
                                  Code=FIELD("No.");
                    ToolTip = 'View or edit prices for the resource.';
                }
            }
            group("Plan&ning")
            {
                Caption = 'Plan&ning';
                Image = Planning;
                action(ResGroupAvailability)
                {
                    ApplicationArea = Jobs;
                    Caption = 'Res. Group Availa&bility';
                    Image = Calendar;
                    RunObject = Page "Res. Group Availability";
                    RunPageLink = "No."=FIELD("No."),
                                  "Unit of Measure Filter"=FIELD("Unit of Measure Filter"),
                                  "Chargeable Filter"=FIELD("Chargeable Filter");
                    ToolTip = 'View a summary of resource group capacities, the quantity of resource hours allocated to jobs on order, the quantity allocated to service orders, the capacity assigned to jobs on quote, and the resource group availability.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        MATRIX_CurrentColumnOrdinal: Integer;
        MATRIX_Steps: Integer;
    begin
        MATRIX_CurrentColumnOrdinal := 0;
        if MATRIX_OnFindRecord('=><') then begin
          MATRIX_CurrentColumnOrdinal := 1;
          repeat
            MATRIX_ColumnOrdinal := MATRIX_CurrentColumnOrdinal;
            MATRIX_OnAfterGetRecord(MATRIX_ColumnOrdinal);
            MATRIX_Steps := MATRIX_OnNextRecord(1);
            MATRIX_CurrentColumnOrdinal := MATRIX_CurrentColumnOrdinal + MATRIX_Steps;
          until (MATRIX_CurrentColumnOrdinal - MATRIX_Steps = MATRIX_NoOfMatrixColumns) or (MATRIX_Steps = 0);
          if MATRIX_CurrentColumnOrdinal <> 1 then
            MATRIX_OnNextRecord(1 - MATRIX_CurrentColumnOrdinal);
        end
    end;

    trigger OnOpenPage()
    begin
        MATRIX_NoOfMatrixColumns := ArrayLen(MATRIX_CellData);
    end;

    var
        MatrixRecord: Record Date;
        MatrixRecords: array [32] of Record Date;
        PeriodFormMgt: Codeunit PeriodFormManagement;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        QtyType: Option "Net Change","Balance at Date";
        MATRIX_ColumnOrdinal: Integer;
        MATRIX_NoOfMatrixColumns: Integer;
        MATRIX_CellData: array [32] of Text[1024];
        MATRIX_ColumnCaption: array [32] of Text[1024];

    local procedure SetDateFilter(ColumnID: Integer)
    begin
        if QtyType = QtyType::"Net Change" then
          if MatrixRecords[ColumnID]."Period Start" = MatrixRecords[ColumnID]."Period End" then
            SetRange("Date Filter",MatrixRecords[ColumnID]."Period Start")
          else
            SetRange("Date Filter",MatrixRecords[ColumnID]."Period Start",MatrixRecords[ColumnID]."Period End")
        else
          SetRange("Date Filter",0D,MatrixRecords[ColumnID]."Period End");
    end;

    local procedure MATRIX_OnFindRecord(Which: Text[1024]): Boolean
    begin
        exit(PeriodFormMgt.FindDate(Which,MatrixRecord,PeriodType));
    end;

    local procedure MATRIX_OnNextRecord(Steps: Integer): Integer
    begin
        exit(PeriodFormMgt.NextDate(Steps,MatrixRecord,PeriodType));
    end;

    local procedure MATRIX_OnAfterGetRecord(ColumnID: Integer)
    begin
        SetDateFilter(ColumnID);
        CalcFields(Capacity);
        if Capacity <> 0 then
          MATRIX_CellData[MATRIX_ColumnOrdinal] := Format(Capacity)
        else
          MATRIX_CellData[MATRIX_ColumnOrdinal] := '';
    end;

    local procedure MatrixOnDrillDown(ColumnID: Integer)
    var
        ResCapacityEntries: Record "Res. Capacity Entry";
    begin
        SetDateFilter(ColumnID);
        ResCapacityEntries.SetCurrentKey("Resource Group No.",Date);
        ResCapacityEntries.SetRange("Resource Group No.","No.");
        ResCapacityEntries.SetFilter(Date,GetFilter("Date Filter"));
        PAGE.Run(0,ResCapacityEntries);
    end;

    procedure Load(PeriodType1: Option Day,Week,Month,Quarter,Year,"Accounting Period";QtyType1: Option "Net Change","Balance at Date";MatrixColumns1: array [32] of Text[1024];var MatrixRecords1: array [32] of Record Date)
    var
        i: Integer;
    begin
        PeriodType := PeriodType1;
        QtyType := QtyType1;
        CopyArray(MATRIX_ColumnCaption,MatrixColumns1,1);
        for i := 1 to ArrayLen(MatrixRecords) do
          MatrixRecords[i].Copy(MatrixRecords1[i]);
    end;

    local procedure ValidateCapacity(ColumnID: Integer)
    begin
        SetDateFilter(ColumnID);
        CalcFields(Capacity);
        Evaluate(Capacity,MATRIX_CellData[ColumnID]);
        Validate(Capacity);
    end;
}

