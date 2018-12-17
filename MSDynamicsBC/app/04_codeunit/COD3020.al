codeunit 3020 DotNet_NavDesignerALFunctions
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetNavDesignerALFunctions: DotNet NavDesignerALFunctions;

    procedure GenerateDesignerPackageZipStreamByVersion(var OutStream: OutStream;ID: Guid;VersionString: Text)
    begin
        // do not make external
        DotNetNavDesignerALFunctions.GenerateDesignerPackageZipStreamByVersion(OutStream,ID,VersionString)
    end;

    procedure SanitizeDesignerFileName(Filename: Text;ReplacementCharacter: Char): Text
    begin
        // do not make external
        exit(DotNetNavDesignerALFunctions.SanitizeDesignerFileName(Filename,ReplacementCharacter))
    end;

    procedure GetNavDesignerALFunctions(var DotNetNavDesignerALFunctions2: DotNet NavDesignerALFunctions)
    begin
        DotNetNavDesignerALFunctions2 := DotNetNavDesignerALFunctions
    end;

    procedure SetNavDesignerALFunctions(DotNetNavDesignerALFunctions2: DotNet NavDesignerALFunctions)
    begin
        DotNetNavDesignerALFunctions := DotNetNavDesignerALFunctions2
    end;
}

