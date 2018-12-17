table 1876 "Business Setup Icon"
{
    // version NAVW113.00

    Caption = 'Business Setup Icon';
    DataPerCompany = false;

    fields
    {
        field(1;"Business Setup Name";Text[50])
        {
            Caption = 'Business Setup Name';
        }
        field(2;Icon;Media)
        {
            Caption = 'Icon';
        }
        field(3;"Media Resources Ref";Code[50])
        {
            Caption = 'Media Resources Ref';
        }
    }

    keys
    {
        key(Key1;"Business Setup Name")
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

    procedure GetIcon(var TempBusinessSetup: Record "Business Setup" temporary)
    var
        MediaResources: Record "Media Resources";
    begin
        if Icon.HasValue then begin
          TempBusinessSetup.Icon := Icon;
          TempBusinessSetup.Modify(true);
        end else
          if MediaResources.Get("Media Resources Ref") then begin
            TempBusinessSetup.Icon := MediaResources."Media Reference";
            TempBusinessSetup.Modify(true);
          end;
    end;
}

