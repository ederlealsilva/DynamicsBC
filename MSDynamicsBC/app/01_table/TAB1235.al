table 1235 "XML Buffer"
{
    // version NAVW113.00

    Caption = 'XML Buffer';
    ReplicateData = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2;Type;Option)
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,Element,Attribute,Processing Instruction';
            OptionMembers = " ",Element,Attribute,"Processing Instruction";
        }
        field(3;Name;Text[250])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(4;Path;Text[250])
        {
            Caption = 'Path';
            DataClassification = SystemMetadata;
        }
        field(5;Value;Text[250])
        {
            Caption = 'Value';
            DataClassification = SystemMetadata;
        }
        field(6;Depth;Integer)
        {
            Caption = 'Depth';
            DataClassification = SystemMetadata;
        }
        field(7;"Parent Entry No.";Integer)
        {
            Caption = 'Parent Entry No.';
            DataClassification = SystemMetadata;
        }
        field(8;"Is Parent";Boolean)
        {
            Caption = 'Is Parent';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Is not used anomore';
            ObsoleteState = Pending;
        }
        field(9;"Data Type";Option)
        {
            Caption = 'Data Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Text,Date,Decimal,DateTime';
            OptionMembers = Text,Date,Decimal,DateTime;
        }
        field(10;"Code";Code[20])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Is not used anymore';
            ObsoleteState = Pending;
        }
        field(11;"Node Name";Text[250])
        {
            Caption = 'Node Name';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Is not used anymore';
            ObsoleteState = Pending;
        }
        field(12;"Has Attributes";Boolean)
        {
            Caption = 'Has Attributes';
            DataClassification = SystemMetadata;
            Editable = false;
            ObsoleteReason = 'Is not used anymore';
            ObsoleteState = Pending;
        }
        field(13;"Node Number";Integer)
        {
            Caption = 'Node Number';
            DataClassification = SystemMetadata;
        }
        field(14;Namespace;Text[250])
        {
            Caption = 'Namespace';
            DataClassification = SystemMetadata;
        }
        field(15;"Import ID";Guid)
        {
            Caption = 'Import ID';
            DataClassification = SystemMetadata;
        }
        field(16;"Value BLOB";BLOB)
        {
            Caption = 'Value BLOB';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Parent Entry No.",Type,"Node Number")
        {
        }
    }

    fieldgroups
    {
    }

    [Scope('Personalization')]
    procedure Load(StreamOrServerFile: Variant)
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.InitializeXMLBufferFrom(Rec,StreamOrServerFile);
    end;

    [Scope('Personalization')]
    procedure ReadFromBlob(TempBlob: Record TempBlob)
    begin
        LoadFromText(TempBlob.ReadAsTextWithCRLFLineSeparator);
    end;

    [Scope('Personalization')]
    procedure LoadFromText(XmlText: Text)
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.InitializeXMLBufferFromText(Rec,XmlText);
    end;

    procedure Upload(): Boolean
    var
        FileManagement: Codeunit "File Management";
        ServerTempFileName: Text;
    begin
        ServerTempFileName := FileManagement.UploadFile('','*.xml');
        if ServerTempFileName = '' then
          exit(false);
        Load(ServerTempFileName);
        FileManagement.DeleteServerFile(ServerTempFileName);
        exit(true);
    end;

    procedure Save(ServerFilePath: Text): Boolean
    var
        XMLBufferReader: Codeunit "XML Buffer Reader";
    begin
        exit(XMLBufferReader.SaveToFile(ServerFilePath,Rec));
    end;

    procedure Download() Success: Boolean
    var
        FileManagement: Codeunit "File Management";
        ServerTempFileName: Text;
    begin
        ServerTempFileName := FileManagement.ServerTempFileName('xml');
        Save(ServerTempFileName);
        Success := FileManagement.DownloadHandler(ServerTempFileName,'','','','temp.xml');
        FileManagement.DeleteServerFile(ServerTempFileName);
    end;

    [Scope('Personalization')]
    procedure CreateRootElement(ElementName: Text[250])
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.InsertElement(Rec,Rec,1,1,ElementName,'');
    end;

    [Scope('Personalization')]
    procedure AddNamespace(NamespacePrefix: Text[244];NamespacePath: Text[250])
    begin
        if NamespacePrefix = '' then
          AddAttribute('xmlns',NamespacePath)
        else
          AddAttribute('xmlns:' + NamespacePrefix,NamespacePath);
    end;

    [Scope('Personalization')]
    procedure AddProcessingInstruction(InstructionName: Text[250];InstructionValue: Text)
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.InsertProcessingInstruction(Rec,Rec,CountProcessingInstructions + 1,Depth + 1,InstructionName,InstructionValue);
        GetParent;
    end;

    [Scope('Personalization')]
    procedure AddAttribute(AttributeName: Text[250];AttributeValue: Text[250])
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.InsertAttribute(Rec,Rec,CountAttributes + 1,Depth + 1,AttributeName,AttributeValue);
        GetParent;
    end;

    [Scope('Personalization')]
    procedure AddGroupElement(ElementNameWithNamespace: Text[250]): Integer
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
    begin
        XMLBufferWriter.InsertElement(Rec,Rec,CountChildElements + 1,Depth + 1,ElementNameWithNamespace,'');
        exit("Entry No.");
    end;

    [Scope('Personalization')]
    procedure AddGroupElementAt(ElementNameWithNamespace: Text[250];EntryNo: Integer): Integer
    var
        XMLBufferWriter: Codeunit "XML Buffer Writer";
        CurrentView: Text;
        ElementNo: Integer;
    begin
        CurrentView := GetView;
        Get(EntryNo);
        ElementNo := "Node Number";
        Reset;
        SetRange("Parent Entry No.","Parent Entry No.");
        SetFilter("Node Number",'>=%1',ElementNo);
        if FindSet(true) then
          repeat
            "Node Number" += 1;
            Modify;
          until Next = 0;
        Get("Parent Entry No.");
        XMLBufferWriter.InsertElement(Rec,Rec,ElementNo,Depth + 1,ElementNameWithNamespace,'');
        SetView(CurrentView);
        exit("Entry No.");
    end;

    [Scope('Personalization')]
    procedure AddElement(ElementNameWithNamespace: Text[250];ElementValue: Text) ElementEntryNo: Integer
    begin
        ElementEntryNo := AddGroupElement(ElementNameWithNamespace);
        SetValueWithoutModifying(ElementValue);
        Modify(true);
        GetParent;
    end;

    [Scope('Personalization')]
    procedure AddLastElement(ElementNameWithNamespace: Text[250];ElementValue: Text) ElementEntryNo: Integer
    begin
        ElementEntryNo := AddElement(ElementNameWithNamespace,ElementValue);
        GetParent;
    end;

    [Scope('Personalization')]
    procedure AddNonEmptyElement(ElementNameWithNamespace: Text[250];ElementValue: Text) ElementEntryNo: Integer
    begin
        if ElementValue = '' then
          exit;
        ElementEntryNo := AddElement(ElementNameWithNamespace,ElementValue);
    end;

    [Scope('Personalization')]
    procedure AddNonEmptyLastElement(ElementNameWithNamespace: Text[250];ElementValue: Text) ElementEntryNo: Integer
    begin
        ElementEntryNo := AddNonEmptyElement(ElementNameWithNamespace,ElementValue);
        GetParent;
    end;

    [Scope('Personalization')]
    procedure CopyImportFrom(var TempXMLBuffer: Record "XML Buffer" temporary)
    var
        XMLBuffer: Record "XML Buffer";
    begin
        if TempXMLBuffer.IsTemporary then
          Copy(TempXMLBuffer,true)
        else begin
          XMLBuffer.SetRange("Import ID",TempXMLBuffer."Import ID");
          if XMLBuffer.FindSet then
            repeat
              Rec := XMLBuffer;
              Insert;
            until XMLBuffer.Next = 0;
          SetView(TempXMLBuffer.GetView);
        end;
    end;

    [Scope('Personalization')]
    procedure CountChildElements() NumElements: Integer
    var
        CurrentView: Text;
    begin
        CurrentView := GetView;
        Reset;
        SetRange("Parent Entry No.","Entry No.");
        SetRange(Type,Type::Element);
        NumElements := Count;
        SetView(CurrentView);
    end;

    [Scope('Personalization')]
    procedure CountAttributes() NumAttributes: Integer
    var
        CurrentView: Text;
    begin
        CurrentView := GetView;
        Reset;
        SetRange("Parent Entry No.","Entry No.");
        SetRange(Type,Type::Attribute);
        NumAttributes := Count;
        SetView(CurrentView);
    end;

    [Scope('Personalization')]
    procedure CountProcessingInstructions() NumElements: Integer
    var
        CurrentView: Text;
    begin
        CurrentView := GetView;
        Reset;
        SetRange("Parent Entry No.","Entry No.");
        SetRange(Type,Type::"Processing Instruction");
        NumElements := Count;
        SetView(CurrentView);
    end;

    [Scope('Personalization')]
    procedure FindProcessingInstructions(var TempXMLBuffer: Record "XML Buffer" temporary): Boolean
    begin
        exit(FindChildNodes(TempXMLBuffer,Type::"Processing Instruction",''));
    end;

    [Scope('Personalization')]
    procedure FindAttributes(var TempResultAttributeXMLBuffer: Record "XML Buffer" temporary): Boolean
    begin
        exit(FindChildNodes(TempResultAttributeXMLBuffer,Type::Attribute,''));
    end;

    [Scope('Personalization')]
    procedure FindChildElements(var TempResultElementXMLBuffer: Record "XML Buffer" temporary): Boolean
    begin
        exit(FindChildNodes(TempResultElementXMLBuffer,Type::Element,''));
    end;

    [Scope('Personalization')]
    procedure FindNodesByXPath(var TempResultElementXMLBuffer: Record "XML Buffer" temporary;XPath: Text): Boolean
    begin
        TempResultElementXMLBuffer.CopyImportFrom(Rec);

        TempResultElementXMLBuffer.SetRange("Import ID","Import ID");
        TempResultElementXMLBuffer.SetRange("Parent Entry No.");
        TempResultElementXMLBuffer.SetFilter(Path,'*' + XPath);
        exit(TempResultElementXMLBuffer.FindSet);
    end;

    [Scope('Personalization')]
    procedure GetAttributeValue(AttributeName: Text): Text[250]
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
    begin
        if FindChildNodes(TempXMLBuffer,Type::Attribute,AttributeName) then
          exit(TempXMLBuffer.Value);
    end;

    [Scope('Personalization')]
    procedure GetElementName(): Text
    begin
        if Namespace = '' then
          exit(Name);
        exit(Namespace + ':' + Name);
    end;

    [Scope('Personalization')]
    procedure GetParent(): Boolean
    begin
        exit(Get("Parent Entry No."))
    end;

    [Scope('Personalization')]
    procedure HasChildNodes() ChildNodesExists: Boolean
    var
        CurrentView: Text;
    begin
        CurrentView := GetView;
        Reset;
        SetRange("Parent Entry No.","Entry No.");
        ChildNodesExists := not IsEmpty;
        SetView(CurrentView);
    end;

    local procedure FindChildNodes(var TempResultXMLBuffer: Record "XML Buffer" temporary;NodeType: Option;NodeName: Text): Boolean
    begin
        TempResultXMLBuffer.CopyImportFrom(Rec);

        TempResultXMLBuffer.SetRange("Parent Entry No.","Entry No.");
        TempResultXMLBuffer.SetRange(Path);
        TempResultXMLBuffer.SetRange(Type,NodeType);
        if NodeName <> '' then
          TempResultXMLBuffer.SetRange(Name,NodeName);
        exit(TempResultXMLBuffer.FindSet);
    end;

    [Scope('Personalization')]
    procedure GetValue(): Text
    var
        TempBlob: Record TempBlob;
        CR: Text[1];
    begin
        CalcFields("Value BLOB");
        if not "Value BLOB".HasValue then
          exit(Value);
        CR[1] := 10;
        TempBlob.Blob := "Value BLOB";
        exit(TempBlob.ReadAsText(CR,TEXTENCODING::Windows));
    end;

    [Scope('Personalization')]
    procedure SetValue(NewValue: Text)
    begin
        SetValueWithoutModifying(NewValue);
        Modify;
    end;

    [Scope('Personalization')]
    procedure SetValueWithoutModifying(NewValue: Text)
    var
        TempBlob: Record TempBlob;
    begin
        Clear("Value BLOB");
        Value := CopyStr(NewValue,1,MaxStrLen(Value));
        if StrLen(NewValue) <= MaxStrLen(Value) then
          exit; // No need to store anything in the blob
        if NewValue = '' then
          exit;
        TempBlob.WriteAsText(NewValue,TEXTENCODING::Windows);
        "Value BLOB" := TempBlob.Blob;
    end;
}

