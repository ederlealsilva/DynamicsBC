page 2159 "O365 Email Preview"
{
    // version NAVW113.00

    Caption = 'Email Preview';
    PageType = Card;

    layout
    {
        area(content)
        {
            usercontrol(BodyHTMLMessage;"Microsoft.Dynamics.Nav.Client.WebPageViewer")
            {
                ApplicationArea = Basic,Suite,Invoicing;
            }
        }
    }

    actions
    {
    }

    var
        BodyText: Text;

    procedure LoadHTMLFile(FileName: Text)
    var
        HTMLFile: File;
        InStream: InStream;
        TextLine: Text;
        Pos: Integer;
    begin
        HTMLFile.Open(FileName,TEXTENCODING::UTF8);
        HTMLFile.CreateInStream(InStream);
        while not InStream.EOS do begin
          InStream.ReadText(TextLine,1000);
          BodyText := BodyText + TextLine;
        end;

        Pos := StrPos(LowerCase(BodyText),'<html');
        BodyText := CopyStr(BodyText,Pos);
        HTMLFile.Close;
    end;

    procedure GetBodyText(): Text
    begin
        exit(BodyText);
    end;
}

