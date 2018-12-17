codeunit 8620 "Config. Package - Import"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        PathIsEmptyErr: Label 'You must enter a file path.';
        ErrorsImportingPackageErr: Label '%1 errors occurred when importing %2 package.', Comment='%1 = No. of errors, %2 = Package Code';
        PathIsTooLongErr: Label 'The path cannot be longer than %1 characters.', Comment='%1 = Max no. of characters';

    procedure ImportAndApplyRapidStartPackage(PackageFileLocation: Text)
    var
        TempConfigSetup: Record "Config. Setup" temporary;
    begin
        ImportRapidStartPackage(PackageFileLocation,TempConfigSetup);
        ApplyRapidStartPackage(TempConfigSetup);
    end;

    procedure ImportRapidStartPackage(PackageFileLocation: Text;var TempConfigSetup: Record "Config. Setup" temporary)
    var
        DecompressedFileName: Text;
        FileLocation: Text[250];
    begin
        if PackageFileLocation = '' then
          Error(PathIsEmptyErr);

        if StrLen(PackageFileLocation) > MaxStrLen(TempConfigSetup."Package File Name") then
          Error(PathIsTooLongErr,MaxStrLen(TempConfigSetup."Package File Name"));

        FileLocation :=
          CopyStr(PackageFileLocation,1,MaxStrLen(TempConfigSetup."Package File Name"));

        TempConfigSetup.Init;
        TempConfigSetup.Insert;
        TempConfigSetup."Package File Name" := FileLocation;
        DecompressedFileName := TempConfigSetup.DecompressPackage(false);

        TempConfigSetup.SetHideDialog(true);
        TempConfigSetup.ReadPackageHeader(DecompressedFileName);
        TempConfigSetup.ImportPackage(DecompressedFileName);
    end;

    [Scope('Personalization')]
    procedure ApplyRapidStartPackage(var TempConfigSetup: Record "Config. Setup" temporary)
    var
        ErrorCount: Integer;
    begin
        ErrorCount := TempConfigSetup.ApplyPackages;
        if ErrorCount > 0 then
          Error(ErrorsImportingPackageErr,ErrorCount,TempConfigSetup."Package Code");
        TempConfigSetup.ApplyAnswers;
    end;

    [Scope('Personalization')]
    procedure ImportAndApplyRapidStartPackageStream(var TempBlob: Record TempBlob)
    var
        TempConfigSetup: Record "Config. Setup" temporary;
    begin
        ImportRapidStartPackageStream(TempBlob,TempConfigSetup);
        ApplyRapidStartPackage(TempConfigSetup);
    end;

    [Scope('Personalization')]
    procedure ImportRapidStartPackageStream(var TempBlob: Record TempBlob;var TempConfigSetup: Record "Config. Setup" temporary)
    var
        TempBlobUncompressed: Record TempBlob;
        InStream: InStream;
    begin
        if TempConfigSetup.Get('ImportRS') then
          TempConfigSetup.Delete;
        TempConfigSetup.Init;
        TempConfigSetup."Primary Key" := 'ImportRS';
        TempConfigSetup."Package File Name" := 'ImportRapidStartPackageFromStream';
        TempConfigSetup.Insert;
        // TempBlob contains the compressed .rapidstart file
        // Decompress the file and put into the TempBlobUncompressed blob
        TempConfigSetup.DecompressPackageToBlob(TempBlob,TempBlobUncompressed);

        TempConfigSetup."Package File" := TempBlobUncompressed.Blob;
        TempConfigSetup.CalcFields("Package File");
        TempConfigSetup."Package File".CreateInStream(InStream);

        TempConfigSetup.SetHideDialog(true);
        TempConfigSetup.ReadPackageHeaderFromStream(InStream);
        TempConfigSetup.ImportPackageFromStream(InStream);
    end;
}

