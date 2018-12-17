table 1470 "Product Video Buffer"
{
    // version NAVW113.00

    Caption = 'Product Video Buffer';
    ReplicateData = false;

    fields
    {
        field(1;ID;Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2;Title;Text[250])
        {
            Caption = 'Title';
            DataClassification = SystemMetadata;
            TableRelation = "Assisted Setup".Name;
        }
        field(3;"Video Url";Text[250])
        {
            Caption = 'Video Url';
            DataClassification = SystemMetadata;
            TableRelation = "Assisted Setup"."Video Url";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(4;"Assisted Setup ID";Integer)
        {
            Caption = 'Assisted Setup ID';
            DataClassification = SystemMetadata;
        }
        field(5;Indentation;Integer)
        {
            Caption = 'Indentation';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;ID)
        {
        }
    }

    fieldgroups
    {
    }

    var
        EntryNo: Integer;

    procedure InitBuffer(var TempProductVideoBuffer: Record "Product Video Buffer" temporary;Category: Option)
    begin
        TempProductVideoBuffer.DeleteAll;

        InitVideoTree(TempProductVideoBuffer,Category);
        TempProductVideoBuffer.SetCurrentKey(ID);
        if TempProductVideoBuffer.FindFirst then;
    end;

    local procedure InitVideoTree(var TempProductVideoBuffer: Record "Product Video Buffer" temporary;Category: Option)
    var
        ProductVideoCategory: Record "Product Video Category";
    begin
        case Category of
          ProductVideoCategory.Category::" ":
            AddAllVideos(TempProductVideoBuffer);
          else
            AddVideosToCategory(TempProductVideoBuffer,Category);
        end;
    end;

    local procedure AddAllVideos(var TempProductVideoBuffer: Record "Product Video Buffer" temporary)
    var
        ProductVideoCategory: Record "Product Video Category";
        TypeHelper: Codeunit "Type Helper";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        Index: Integer;
    begin
        RecRef.Open(DATABASE::"Product Video Category");
        FieldRef := RecRef.Field(ProductVideoCategory.FieldNo(Category));

        for Index := 1 to TypeHelper.GetNumberOfOptions(FieldRef.OptionString) do
          InitVideoTree(TempProductVideoBuffer,Index);
    end;

    local procedure AddVideosToCategory(var TempProductVideoBuffer: Record "Product Video Buffer" temporary;Category: Option)
    var
        ProductVideoswithCategory: Query "Product Videos with Category";
    begin
        ProductVideoswithCategory.SetRange(Category,Category);
        ProductVideoswithCategory.Open;
        if ProductVideoswithCategory.Read then begin
          AddCategory(TempProductVideoBuffer,Format(ProductVideoswithCategory.Category));
          repeat
            if ProductVideoswithCategory.Alternate_Title <> '' then
              AddVideoToCategory(TempProductVideoBuffer,ProductVideoswithCategory.Assisted_Setup_ID,
                ProductVideoswithCategory.Alternate_Title,ProductVideoswithCategory.Video_Url)
            else
              AddVideoToCategory(TempProductVideoBuffer,ProductVideoswithCategory.Assisted_Setup_ID,
                ProductVideoswithCategory.Name,ProductVideoswithCategory.Video_Url);
          until ProductVideoswithCategory.Read = false;
        end;
        ProductVideoswithCategory.Close;
    end;

    local procedure AddCategory(var TempProductVideoBuffer: Record "Product Video Buffer" temporary;CategoryName: Text[250])
    begin
        InsertRec(TempProductVideoBuffer,0,CategoryName,'',0);
    end;

    local procedure AddVideoToCategory(var TempProductVideoBuffer: Record "Product Video Buffer" temporary;Id: Integer;VideoName: Text[250];VideoUrl: Text[250])
    begin
        InsertRec(TempProductVideoBuffer,Id,VideoName,VideoUrl,1);
    end;

    local procedure InsertRec(var TempProductVideoBuffer: Record "Product Video Buffer" temporary;Id: Integer;VideoName: Text[250];VideoUrl: Text[250];Indent: Integer)
    begin
        EntryNo := EntryNo + 1;
        TempProductVideoBuffer.Init;
        TempProductVideoBuffer.ID := EntryNo;
        TempProductVideoBuffer.Title := VideoName;
        TempProductVideoBuffer."Video Url" := VideoUrl;
        TempProductVideoBuffer."Assisted Setup ID" := Id;
        TempProductVideoBuffer.Indentation := Indent;
        TempProductVideoBuffer.Insert;
    end;
}

