page 538 "Dimension Combinations"
{
    // version NAVW113.00

    ApplicationArea = Dimensions;
    Caption = 'Dimension Combinations';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    SaveValues = true;
    SourceTable = Dimension;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ShowColumnName;ShowColumnName)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Show Column Name';
                    ToolTip = 'Specifies that the names of columns are shown in the matrix window.';

                    trigger OnValidate()
                    begin
                        ShowColumnNameOnPush;
                        ShowColumnNameOnAfterValidate;
                    end;
                }
            }
            part(MatrixForm;"Dimension Combinations Matrix")
            {
                ApplicationArea = Dimensions;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Set")
            {
                ApplicationArea = Dimensions;
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous set of data.';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next;
                begin
                    // SetPoints(Direction::Backward);
                    MATRIX_GenerateColumnCaptions(Step::Previous);
                    UpdateMatrixSubform;
                end;
            }
            action("Previous Column")
            {
                ApplicationArea = Dimensions;
                Caption = 'Previous Column';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous column.';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
                begin
                    // SetPoints(Direction::Backward);
                    MATRIX_GenerateColumnCaptions(Step::PreviousColumn);
                    UpdateMatrixSubform;
                end;
            }
            action("Next Column")
            {
                ApplicationArea = Dimensions;
                Caption = 'Next Column';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the next column.';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
                begin
                    // SetPoints(Direction::Forward);
                    MATRIX_GenerateColumnCaptions(Step::NextColumn);
                    UpdateMatrixSubform;
                end;
            }
            action("Next Set")
            {
                ApplicationArea = Dimensions;
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the next set of data.';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next;
                begin
                    // SetPoints(Direction::Forward);
                    MATRIX_GenerateColumnCaptions(Step::Next);
                    UpdateMatrixSubform;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Name := GetMLName(GlobalLanguage);
    end;

    trigger OnOpenPage()
    begin
        MaximumNoOfCaptions := ArrayLen(MATRIX_CaptionSet);
        MATRIX_GenerateColumnCaptions(MATRIX_SetWanted::Initial);
        UpdateMatrixSubform;
    end;

    var
        MatrixRecords: array [32] of Record Dimension;
        MatrixRecord: Record Dimension;
        MatrixMgm: Codeunit "Matrix Management";
        MATRIX_CaptionSet: array [32] of Text[80];
        MATRIX_ColumnSet: Text[80];
        MATRIX_CaptionFieldNo: Integer;
        ShowColumnName: Boolean;
        MaximumNoOfCaptions: Integer;
        PrimaryKeyFirstCaptionInCurrSe: Text;
        MATRIX_CurrSetLength: Integer;
        MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        NoDimensionsErr: Label 'No dimensions are available in the database.';

    local procedure MATRIX_GenerateColumnCaptions(SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn)
    var
        RecRef: RecordRef;
        CurrentMatrixRecordOrdinal: Integer;
    begin
        RecRef.GetTable(MatrixRecord);

        if RecRef.IsEmpty then
          Error(NoDimensionsErr);

        if ShowColumnName then
          MATRIX_CaptionFieldNo := 2
        else
          MATRIX_CaptionFieldNo := 1;

        MatrixMgm.GenerateMatrixData(RecRef,SetWanted,MaximumNoOfCaptions,MATRIX_CaptionFieldNo,PrimaryKeyFirstCaptionInCurrSe,
          MATRIX_CaptionSet,MATRIX_ColumnSet,MATRIX_CurrSetLength);

        Clear(MatrixRecords);
        MatrixRecord.SetPosition(PrimaryKeyFirstCaptionInCurrSe);
        CurrentMatrixRecordOrdinal := 1;
        repeat
          MatrixRecords[CurrentMatrixRecordOrdinal].Copy(MatrixRecord);
          CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
        until (CurrentMatrixRecordOrdinal = ArrayLen(MatrixRecords)) or (MatrixRecord.Next <> 1);
    end;

    local procedure UpdateMatrixSubform()
    begin
        CurrPage.MatrixForm.PAGE.Load(MATRIX_CaptionSet,MatrixRecords,ShowColumnName);
        CurrPage.Update(false);
    end;

    local procedure ShowColumnNameOnAfterValidate()
    begin
        UpdateMatrixSubform;
    end;

    local procedure ShowColumnNameOnPush()
    begin
        MATRIX_GenerateColumnCaptions(MATRIX_SetWanted::Same);
        UpdateMatrixSubform;
    end;
}

