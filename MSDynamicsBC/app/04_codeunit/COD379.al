codeunit 379 "Transfer Old Ext. Text Lines"
{
    // version NAVW111.00


    trigger OnRun()
    begin
    end;

    var
        LineNoBuffer: Record "Line Number Buffer" temporary;

    local procedure InsertLineNumbers(OldLineNo: Integer;NewLineNo: Integer)
    begin
        LineNoBuffer."Old Line Number" := OldLineNo;
        LineNoBuffer."New Line Number" := NewLineNo;
        LineNoBuffer.Insert;
    end;

    [Scope('Personalization')]
    procedure GetNewLineNumber(OldLineNo: Integer): Integer
    begin
        if LineNoBuffer.Get(OldLineNo) then
          exit(LineNoBuffer."New Line Number");

        exit(0);
    end;

    [Scope('Personalization')]
    procedure ClearLineNumbers()
    begin
        LineNoBuffer.DeleteAll;
    end;

    [Scope('Personalization')]
    procedure TransferExtendedText(OldLineNo: Integer;NewLineNo: Integer;AttachedLineNo: Integer): Integer
    begin
        InsertLineNumbers(OldLineNo,NewLineNo);
        if AttachedLineNo <> 0 then
          exit(GetNewLineNumber(AttachedLineNo));

        exit(0);
    end;
}

