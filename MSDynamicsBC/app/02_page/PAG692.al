page 692 "Import Style Sheet"
{
    // version NAVW113.00

    Caption = 'Import Style Sheet';
    DataCaptionExpression = AllObjWithCaption."Object Caption";
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(FileName;FileName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Style Sheet';

                    trigger OnAssistEdit()
                    begin
                        LookupStyleSheet;
                    end;

                    trigger OnValidate()
                    var
                        TempBlob: Record TempBlob;
                    begin
                        if not FileMgt.ClientFileExists(FileName) then
                          Error(Text002,FileName);

                        FileMgt.BLOBImport(TempBlob,FileName);
                        StyleSheet."Style Sheet" := TempBlob.Blob;
                    end;
                }
                field(Description;Description)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Name';

                    trigger OnValidate()
                    begin
                        StyleSheet.Name := Description;
                    end;
                }
                field(ApplicationName;ApplicationName)
                {
                    ApplicationArea = Basic,Suite;
                    Caption = 'Send-to Program';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupApplication;
                    end;

                    trigger OnValidate()
                    begin
                        FindApplication;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        SendToProgram: Record "Send-To Program";
        StyleSheet: Record "Style Sheet";
        AllObjWithCaption: Record AllObjWithCaption;
        FileMgt: Codeunit "File Management";
        FileName: Text;
        Description: Text[1024];
        ApplicationName: Text[250];
        ObjType: Integer;
        ObjectID: Integer;
        Text001: Label 'No %1 found.';
        Text002: Label 'The file %1 could not be found.';

    [Scope('Personalization')]
    procedure SetObjectID(NewObjectType: Integer;NewObjectID: Integer;NewApplicationID: Guid)
    begin
        if not SendToProgram.Get(NewApplicationID) then
          SendToProgram.FindFirst;
        ApplicationName := SendToProgram.Name;
        ObjType := NewObjectType;
        ObjectID := NewObjectID;
        if not AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Page,ObjectID) then
          AllObjWithCaption.Init;
        StyleSheet.Init;
        StyleSheet."Style Sheet ID" := CreateGuid;
        StyleSheet."Object ID" := ObjectID;
        StyleSheet."Object Type" := ObjType;
        StyleSheet."Program ID" := SendToProgram."Program ID";
        StyleSheet.Date := Today;
    end;

    procedure GetStyleSheet(var ReturnStyleSheet: Record "Style Sheet")
    begin
        ReturnStyleSheet := StyleSheet;
    end;

    local procedure LookupApplication()
    var
        SendToPrograms: Page "Send-to Programs";
    begin
        SendToPrograms.LookupMode := true;
        SendToPrograms.SetRecord(SendToProgram);
        if SendToPrograms.RunModal = ACTION::LookupOK then begin
          SendToPrograms.GetRecord(SendToProgram);
          StyleSheet."Program ID" := SendToProgram."Program ID";
          ApplicationName := SendToProgram.Name;
        end;
    end;

    local procedure FindApplication()
    begin
        SendToProgram.Reset;
        if ApplicationName = '' then begin
          SendToProgram.FindFirst;
          ApplicationName := SendToProgram.Name;
          exit;
        end;
        SendToProgram.SetRange(Name,ApplicationName);
        if SendToProgram.FindFirst then begin
          ApplicationName := SendToProgram.Name;
          exit;
        end;
        SendToProgram.SetFilter(Name,'@*' + ApplicationName + '*');
        if SendToProgram.FindFirst then begin
          ApplicationName := SendToProgram.Name;
          exit;
        end;
        Error(Text001,SendToProgram.TableCaption);
    end;

    local procedure LookupStyleSheet()
    var
        TempBlob: Record TempBlob;
        PathLength: Integer;
    begin
        FileName := FileMgt.BLOBImport(TempBlob,'*.xsl*');

        if FileName = '' then begin
          Clear(StyleSheet."Style Sheet");
          Clear(Description);
          exit;
        end;
        PathLength := StrLen(FileMgt.GetDirectoryName(FileName));
        // If there is a path in the filename, we should cut away the path.
        if PathLength <> 0 then
          Description := CopyStr(FileName,PathLength + 2)
        else
          Description := CopyStr(FileName,1);
        StyleSheet.Name := Description;
        StyleSheet."Style Sheet" := TempBlob.Blob;
    end;
}

