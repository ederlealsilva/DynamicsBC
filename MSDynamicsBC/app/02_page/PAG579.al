page 579 "Post Application"
{
    // version NAVW111.00

    Caption = 'Post Application';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DocNo;DocNo)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the document number of the entry to be applied.';
                }
                field(PostingDate;PostingDate)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Posting Date';
                    ToolTip = 'Specifies the posting date of the entry to be applied.';
                }
            }
        }
    }

    actions
    {
    }

    var
        DocNo: Code[20];
        PostingDate: Date;

    [Scope('Personalization')]
    procedure SetValues(NewDocNo: Code[20];NewPostingDate: Date)
    begin
        DocNo := NewDocNo;
        PostingDate := NewPostingDate;
    end;

    [Scope('Personalization')]
    procedure GetValues(var NewDocNo: Code[20];var NewPostingDate: Date)
    begin
        NewDocNo := DocNo;
        NewPostingDate := PostingDate;
    end;
}

