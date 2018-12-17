page 684 "Date-Time Dialog"
{
    // version NAVW111.00

    Caption = 'Date-Time Dialog';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(Date;Date0)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Date';
                ToolTip = 'Specifies the date.';

                trigger OnValidate()
                begin
                    if Time0 = 0T then
                      Time0 := 000000T;
                end;
            }
            field(Time;Time0)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Time';
            }
        }
    }

    actions
    {
    }

    var
        Date0: Date;
        Time0: Time;

    [Scope('Personalization')]
    procedure SetDateTime(DateTime: DateTime)
    begin
        Date0 := DT2Date(DateTime);
        Time0 := DT2Time(DateTime);
    end;

    [Scope('Personalization')]
    procedure GetDateTime(): DateTime
    begin
        exit(CreateDateTime(Date0,Time0));
    end;
}

