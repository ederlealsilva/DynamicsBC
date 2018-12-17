table 1810 "Assisted Setup Icons"
{
    // version NAVW113.00

    Caption = 'Assisted Setup Icons';
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1;"No.";Code[50])
        {
            Caption = 'No.';
        }
        field(2;Image;Media)
        {
            Caption = 'Image';
        }
        field(3;"Media Resources Ref";Code[50])
        {
            Caption = 'Media Resources Ref';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetIconFromInstream(MediaResourceRef: Code[50];MediaInstream: InStream)
    var
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
    begin
        if not MediaResourcesMgt.InsertMediaFromInstream(MediaResourceRef,MediaInstream) then
          exit;

        Validate("Media Resources Ref",MediaResourceRef);
        Modify(true);
    end;

    procedure SetIconFromFile(MediaResourceRef: Code[50];FileName: Text)
    var
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
    begin
        if not MediaResourcesMgt.InsertMediaFromFile(MediaResourceRef,FileName) then
          exit;

        Validate("Media Resources Ref",MediaResourceRef);
        Modify(true);
    end;
}

