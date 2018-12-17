page 693 "Program Selection"
{
    // version NAVW113.00

    Caption = 'Program Selection';
    DataCaptionExpression = StrSubstNo(Text001,AllObjWithCaption."Object Caption",Name);
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Send-To Program";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the program to send data to from Business Central.';
                }
                field(Executable;Executable)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Executable';
                    Editable = false;
                    ToolTip = 'Specifies the name of the executable file that launches the program.';
                    Visible = false;
                }
                field(StylesheetName;StylesheetName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Style Sheet';
                    ToolTip = 'Specifies the style sheet for the program to send data to from Business Central.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupStylesheet;
                    end;

                    trigger OnValidate()
                    begin
                        ValidateStylesheet;
                        StylesheetNameOnAfterValidate;
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetDefaultStylesheet;
    end;

    trigger OnAfterGetRecord()
    begin
        GetDefaultStylesheet;
    end;

    var
        AllObjWithCaption: Record AllObjWithCaption;
        StylesheetName: Text[250];
        ObjType: Integer;
        ObjectID: Integer;
        StylesheetID: Guid;
        Text001: Label 'Send %1 to %2';

    [Scope('Personalization')]
    procedure SetObjectID(NewObjectType: Integer;NewObjectID: Integer)
    begin
        ObjType := NewObjectType;
        ObjectID := NewObjectID;
        if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,NewObjectID) then
          AllObjWithCaption.Init;
    end;

    [Scope('Personalization')]
    procedure GetSelectedStyleSheetID(): Guid
    begin
        GetDefaultStylesheet;
        exit(StylesheetID);
    end;

    local procedure LookupStylesheet()
    var
        Stylesheet: Record "Style Sheet";
        Stylesheets: Page "Style Sheets";
    begin
        Stylesheet.SetRange("Program ID","Program ID");
        Stylesheet.SetRange("Object Type",ObjType);
        Stylesheet.SetFilter("Object ID",'%1|%2',0,ObjectID);
        if StylesheetName <> '' then begin
          Stylesheet.SetRange(Name,StylesheetName);
          if Stylesheet.FindFirst then
            Stylesheets.SetRecord(Stylesheet);
          Stylesheet.SetRange(Name);
        end;
        Stylesheets.SetParams(ObjectID,Name);
        Stylesheets.LookupMode := true;
        Stylesheets.SetTableView(Stylesheet);
        if Stylesheets.RunModal = ACTION::LookupOK then begin
          Stylesheets.GetRecord(Stylesheet);
          SetDefaultStylesheet(Stylesheet);
        end;
    end;

    local procedure ValidateStylesheet()
    var
        Stylesheet: Record "Style Sheet";
    begin
        Stylesheet.SetRange("Program ID","Program ID");
        Stylesheet.SetRange("Object Type",ObjType);
        Stylesheet.SetFilter("Object ID",'%1|%2',0,ObjectID);
        Stylesheet.SetRange(Name,StylesheetName);
        if not Stylesheet.FindFirst then begin
          Stylesheet.SetFilter(Name,'@*' + StylesheetName + '*');
          Stylesheet.FindFirst
        end;
        SetDefaultStylesheet(Stylesheet);
    end;

    local procedure GetDefaultStylesheet()
    var
        UserDefaultStylesheet: Record "User Default Style Sheet";
        Stylesheet: Record "Style Sheet";
        Found: Boolean;
    begin
        if UserDefaultStylesheet.Get(UpperCase(UserId),ObjType,ObjectID,"Program ID") then
          Found := Stylesheet.Get(UserDefaultStylesheet."Style Sheet ID");

        if not Found then begin
          Stylesheet.SetRange("Object ID",ObjectID);
          Stylesheet.SetRange("Object Type",ObjType);
          Stylesheet.SetRange("Program ID","Program ID");
          Found := Stylesheet.FindFirst;
          if not Found then begin
            Stylesheet.SetRange("Object ID",0);
            Found := Stylesheet.FindFirst;
          end;
        end;
        if Found then begin
          StylesheetID := Stylesheet."Style Sheet ID";
          StylesheetName := Stylesheet.Name;
        end else begin
          Clear(StylesheetID);
          StylesheetName := '';
        end;
    end;

    local procedure SetDefaultStylesheet(var Stylesheet: Record "Style Sheet")
    var
        UserDefaultStylesheet: Record "User Default Style Sheet";
    begin
        StylesheetID := Stylesheet."Style Sheet ID";
        StylesheetName := Stylesheet.Name;

        UserDefaultStylesheet.SetRange("User ID",UpperCase(UserId));
        UserDefaultStylesheet.SetRange("Object Type",Stylesheet."Object Type");
        UserDefaultStylesheet.SetRange("Object ID",ObjectID);
        UserDefaultStylesheet.SetRange("Program ID",Stylesheet."Program ID");
        UserDefaultStylesheet.DeleteAll;

        UserDefaultStylesheet."User ID" := UpperCase(UserId);
        UserDefaultStylesheet."Object Type" := Stylesheet."Object Type";
        UserDefaultStylesheet."Object ID" := ObjectID;
        UserDefaultStylesheet."Program ID" := Stylesheet."Program ID";
        UserDefaultStylesheet."Style Sheet ID" := Stylesheet."Style Sheet ID";
        UserDefaultStylesheet.Insert;
    end;

    local procedure StylesheetNameOnAfterValidate()
    begin
        CurrPage.Update;
    end;
}

