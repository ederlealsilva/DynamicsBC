page 1910 "Camera Interaction"
{
    // version NAVW113.00

    Caption = 'Camera Interaction';
    Editable = false;
    LinksAllowed = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(TakingPicture)
            {
                Caption = 'Taking picture...';
                InstructionalText = 'Please take the picture using your camera.';
                Visible = CameraAvailable;
            }
            group(CameraNotSupported)
            {
                Caption = 'Could not connect to camera';
                InstructionalText = 'The camera on the device could not be accessed. Please make sure you are using a Dynamics Tenerife app for Windows, Android or iOS.';
                Visible = NOT CameraAvailable;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        CameraAvailable := CameraProvider.IsAvailable;

        if not CameraAvailable then
          exit;

        CameraOptions := CameraOptions.CameraOptions;
        CameraOptions.Quality := RequestedQuality;
        CameraOptions.AllowEdit := RequestedAllowEdit;
        CameraOptions.EncodingType := RequestedEncodingType;
        CameraOptions.MediaType := RequestedMediaType;
        CameraOptions.SourceType := RequestedSourceType;

        CameraProvider := CameraProvider.Create;
        CameraProvider.RequestPictureAsync(CameraOptions);
    end;

    var
        TempPictureTempBlob: Record TempBlob temporary;
        [RunOnClient]
        [WithEvents]
        CameraProvider: DotNet CameraProvider;
        CameraOptions: DotNet CameraOptions;
        [InDataSet]
        CameraAvailable: Boolean;
        RequestedAllowEdit: Boolean;
        SavedPictureName: Text;
        SavedPictureFilePath: Text;
        RequestedEncodingType: Text;
        RequestedMediaType: Text;
        RequestedSourceType: Text;
        PictureNotAvailableErr: Label 'The picture is not available.';
        RequestedIgnoreError: Boolean;
        RequestedQuality: Integer;

    [Scope('Personalization')]
    procedure AllowEdit(AllowEdit: Boolean)
    begin
        RequestedAllowEdit := AllowEdit;
    end;

    [Scope('Personalization')]
    procedure GetPictureName(): Text
    begin
        exit(SavedPictureName);
    end;

    [Scope('Personalization')]
    procedure GetPicture(Stream: InStream): Boolean
    begin
        if SavedPictureFilePath = '' then begin
          if not RequestedIgnoreError then
            Error(PictureNotAvailableErr);

          exit(false);
        end;

        TempPictureTempBlob.Init;
        TempPictureTempBlob.Blob.Import(SavedPictureFilePath);
        TempPictureTempBlob.Blob.CreateInStream(Stream);
        TempPictureTempBlob.Insert;

        exit(true);
    end;

    [Scope('Personalization')]
    procedure EncodingType(EncodingType: Text)
    begin
        RequestedEncodingType := EncodingType;
    end;

    [Scope('Personalization')]
    procedure MediaType(MediaType: Text)
    begin
        RequestedMediaType := MediaType;
    end;

    [Scope('Personalization')]
    procedure SourceType(SourceType: Text)
    begin
        RequestedSourceType := SourceType;
    end;

    [Scope('Personalization')]
    procedure IgnoreError(IgnoreError: Boolean)
    begin
        RequestedIgnoreError := IgnoreError;
    end;

    [Scope('Personalization')]
    procedure Quality(Quality: Integer)
    begin
        RequestedQuality := Quality;
    end;

    trigger CameraProvider::PictureAvailable(PictureName: Text;PictureFilePath: Text)
    begin
        SavedPictureFilePath := PictureFilePath;
        SavedPictureName := PictureName;

        CurrPage.Close;
    end;
}

