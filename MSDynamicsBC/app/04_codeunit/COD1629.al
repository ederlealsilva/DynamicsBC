codeunit 1629 "Office Attachment Manager"
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        UrlOrContentString: Text;
        NameString: Text;
        Body: Text;
        "Count": Integer;

    [Scope('Personalization')]
    procedure Add(FileUrlOrContent: Text;FileName: Text;BodyText: Text)
    begin
        if UrlOrContentString <> '' then begin
          UrlOrContentString += '|';
          NameString += '|';
        end;

        UrlOrContentString += FileUrlOrContent;
        NameString += FileName;
        if Body = '' then
          Body := BodyText;
        Count -= 1;
    end;

    [Scope('Personalization')]
    procedure Ready(): Boolean
    begin
        exit(Count < 1);
    end;

    [Scope('Personalization')]
    procedure Done()
    begin
        Count := 0;
        UrlOrContentString := '';
        NameString := '';
        Body := '';
    end;

    [Scope('Personalization')]
    procedure GetFiles(): Text
    begin
        exit(UrlOrContentString);
    end;

    [Scope('Personalization')]
    procedure GetNames(): Text
    begin
        exit(NameString);
    end;

    procedure GetBody(): Text
    var
        MailMgt: Codeunit "Mail Management";
    begin
        exit(MailMgt.ImageBase64ToUrl(Body));
    end;

    [Scope('Personalization')]
    procedure IncrementCount(NewCount: Integer)
    begin
        Count += NewCount;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnSendSalesDocument', '', false, false)]
    local procedure OnSendSalesDocument(ShipAndInvoice: Boolean)
    begin
        if ShipAndInvoice then
          Count := 2;
    end;
}

