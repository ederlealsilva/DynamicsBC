codeunit 1799 "Import Config. Package File"
{
    // version NAVW111.00

    TableNo = "Configuration Package File";

    trigger OnRun()
    begin
        SetRecFilter;
        CODEUNIT.Run(CODEUNIT::"Import Config. Package Files",Rec);
    end;
}

