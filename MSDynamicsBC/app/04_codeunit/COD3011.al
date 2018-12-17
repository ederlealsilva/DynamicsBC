codeunit 3011 DotNet_ImageFormatConverter
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        DotNetImageFormatConverter: DotNet ImageFormatConverter;

    [Scope('Personalization')]
    procedure InitImageFormatConverter()
    begin
        DotNetImageFormatConverter := DotNetImageFormatConverter.ImageFormatConverter
    end;

    [Scope('Personalization')]
    procedure ConvertToString(var DotNet_ImageFormat: Codeunit DotNet_ImageFormat): Text
    var
        DotNetImageFormat: DotNet ImageFormat;
    begin
        DotNet_ImageFormat.GetImageFormat(DotNetImageFormat);
        exit(DotNetImageFormatConverter.ConvertToString(DotNetImageFormat))
    end;

    procedure GetImageFormatConverter(var DotNetImageFormatConverter2: DotNet ImageFormatConverter)
    begin
        DotNetImageFormatConverter2 := DotNetImageFormatConverter
    end;

    procedure SetImageFormatConverter(DotNetImageFormatConverter2: DotNet ImageFormatConverter)
    begin
        DotNetImageFormatConverter := DotNetImageFormatConverter2
    end;
}

