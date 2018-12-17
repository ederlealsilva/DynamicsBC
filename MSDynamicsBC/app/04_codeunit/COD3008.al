codeunit 3008 DotNet_Convert
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetConvert: DotNet Convert;

    [Scope('Personalization')]
    procedure ToBase64String(var DotNet_Array: Codeunit DotNet_Array): Text
    var
        DotNetArray: DotNet Array;
    begin
        DotNet_Array.GetArray(DotNetArray);
        exit(DotNetConvert.ToBase64String(DotNetArray))
    end;

    [Scope('Personalization')]
    procedure FromBase64String(Base64String: Text;var DotNet_Array: Codeunit DotNet_Array)
    begin
        DotNet_Array.SetArray(DotNetConvert.FromBase64String(Base64String))
    end;

    procedure GetConvert(var DotNetConvert2: DotNet Convert)
    begin
        DotNetConvert2 := DotNetConvert
    end;

    procedure SetConvert(DotNetConvert2: DotNet Convert)
    begin
        DotNetConvert := DotNetConvert2
    end;
}

