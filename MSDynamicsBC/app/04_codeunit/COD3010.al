codeunit 3010 DotNet_Image
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetImage: DotNet Image;

    [Scope('Personalization')]
    procedure FromStream(InStream: InStream)
    begin
        DotNetImage := DotNetImage.FromStream(InStream)
    end;

    [Scope('Personalization')]
    procedure RawFormat(var DotNet_ImageFormat: Codeunit DotNet_ImageFormat)
    begin
        DotNet_ImageFormat.SetImageFormat(DotNetImage.RawFormat)
    end;

    procedure GetImage(var DotNetImage2: DotNet Image)
    begin
        DotNetImage2 := DotNetImage
    end;

    procedure SetImage(DotNetImage2: DotNet Image)
    begin
        DotNetImage := DotNetImage2
    end;
}

