table 5772 "Registered Whse. Activity Hdr."
{
    // version NAVW113.00

    Caption = 'Registered Whse. Activity Hdr.';
    LookupPageID = "Registered Whse. Activity List";
    Permissions = TableData "Registered Whse. Activity Line"=rimd;

    fields
    {
        field(1;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Put-away,Pick,Movement';
            OptionMembers = " ","Put-away",Pick,Movement;
        }
        field(2;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(3;"Location Code";Code[10])
        {
            Caption = 'Location Code';
            NotBlank = true;
            TableRelation = Location;
        }
        field(4;"Assigned User ID";Code[50])
        {
            Caption = 'Assigned User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Warehouse Employee" WHERE ("Location Code"=FIELD("Location Code"));
        }
        field(5;"Assignment Date";Date)
        {
            Caption = 'Assignment Date';
        }
        field(6;"Assignment Time";Time)
        {
            Caption = 'Assignment Time';
        }
        field(7;"Sorting Method";Option)
        {
            Caption = 'Sorting Method';
            OptionCaption = ' ,Item,Document,Shelf or Bin,Due Date,Ship-To,Bin Ranking,Action Type';
            OptionMembers = " ",Item,Document,"Shelf or Bin","Due Date","Ship-To","Bin Ranking","Action Type";
        }
        field(8;"Registering Date";Date)
        {
            Caption = 'Registering Date';
        }
        field(9;"No. Series";Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10;Comment;Boolean)
        {
            CalcFormula = Exist("Warehouse Comment Line" WHERE ("Table Name"=CONST("Rgstrd. Whse. Activity Header"),
                                                                Type=FIELD(Type),
                                                                "No."=FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11;"Whse. Activity No.";Code[20])
        {
            Caption = 'Whse. Activity No.';
        }
        field(12;"No. Printed";Integer)
        {
            Caption = 'No. Printed';
            Editable = false;
        }
    }

    keys
    {
        key(Key1;Type,"No.")
        {
        }
        key(Key2;"No.",Type)
        {
        }
        key(Key3;"Whse. Activity No.")
        {
        }
        key(Key4;"Location Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RgstrdWhseActivLine: Record "Registered Whse. Activity Line";
        WhseCommentLine: Record "Warehouse Comment Line";
    begin
        RgstrdWhseActivLine.SetRange("Activity Type",Type);
        RgstrdWhseActivLine.SetRange("No.","No.");
        RgstrdWhseActivLine.DeleteAll;

        WhseCommentLine.SetRange("Table Name",WhseCommentLine."Table Name"::"Rgstrd. Whse. Activity Header");
        WhseCommentLine.SetRange(Type,Type);
        WhseCommentLine.SetRange("No.","No.");
        WhseCommentLine.DeleteAll;
    end;

    [Scope('Personalization')]
    procedure SetWhseLocationFilter()
    var
        WmsManagement: Codeunit "WMS Management";
    begin
        if UserId <> '' then begin
          FilterGroup := 2;
          SetRange("Location Code",WmsManagement.GetAllowedLocation("Location Code"));
          FilterGroup := 0;
        end;
    end;

    [Scope('Personalization')]
    procedure LookupRegisteredActivityHeader(var CurrentLocationCode: Code[10];var RegisteredWhseActivHeader: Record "Registered Whse. Activity Hdr.")
    begin
        Commit;
        if UserId <> '' then begin
          RegisteredWhseActivHeader.FilterGroup := 2;
          RegisteredWhseActivHeader.SetRange("Location Code");
        end;
        if PAGE.RunModal(0,RegisteredWhseActivHeader) = ACTION::LookupOK then;
        if UserId <> '' then begin
          RegisteredWhseActivHeader.FilterGroup := 2;
          RegisteredWhseActivHeader.SetRange("Location Code",RegisteredWhseActivHeader."Location Code");
          RegisteredWhseActivHeader.FilterGroup := 0;
        end;
        CurrentLocationCode := RegisteredWhseActivHeader."Location Code";
    end;
}

