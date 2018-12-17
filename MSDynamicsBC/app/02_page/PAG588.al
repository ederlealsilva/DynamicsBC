page 588 "XBRL Schemas"
{
    // version NAVW111.00

    AutoSplitKey = true;
    Caption = 'XBRL Schemas';
    DataCaptionFields = "XBRL Taxonomy Name";
    PageType = List;
    SourceTable = "XBRL Schema";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Description;Description)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies a description of the XBRL schema.';
                }
                field(targetNamespace;targetNamespace)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies the uniform resource identifier (URI) for the namespace if there is an overall targetNamespace for this taxonomy.';
                    Visible = false;
                }
                field(schemaLocation;schemaLocation)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies the uniform resource identifier (URI) of the schema file.';
                    Visible = false;
                }
                field("XSD.HasValue";XSD.HasValue)
                {
                    ApplicationArea = XBRL;
                    Caption = 'XSD File Imported';
                    Editable = false;
                    ToolTip = 'Specifies if an XBRL schema has been imported.';
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
        area(navigation)
        {
            group("&Schema")
            {
                Caption = '&Schema';
                Image = Template;
                action(Linkbases)
                {
                    ApplicationArea = XBRL;
                    Caption = 'Linkbases';
                    Image = LinkWithExisting;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "XBRL Linkbases";
                    RunPageLink = "XBRL Taxonomy Name"=FIELD("XBRL Taxonomy Name"),
                                  "XBRL Schema Line No."=FIELD("Line No.");
                    ToolTip = 'View a new taxonomy linkbase or a previously imported taxonomy linkbase that you want to update or export. The window contains a line for each schema that you have imported.';
                }
                separator(Separator13)
                {
                }
                action(Import)
                {
                    ApplicationArea = XBRL;
                    Caption = 'Import';
                    Ellipsis = true;
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Import an XBRL taxonomy into your company database by first importing one or more schemas in .sad format. After you have completed the import of both schemas and linkbases and have applied the linkbases to the schema, you can set up the lines and map the general ledger accounts in the chart of accounts to the appropriate taxonomy lines.';

                    trigger OnAction()
                    var
                        XMLExists: Boolean;
                        FileName: Text;
                        i: Integer;
                    begin
                        CalcFields(XSD);
                        XMLExists := XSD.HasValue;
                        FileName := FileMgt.BLOBImport(TempBlob,'*.xsd');
                        if FileName = '' then
                          exit;
                        XSD := TempBlob.Blob;
                        if XMLExists then
                          if not Confirm(Text001,false) then
                            exit;
                        if StrPos(FileName,'\') <> 0 then begin
                          i := StrLen(FileName);
                          while (i > 0) and (FileName[i] <> '\') do
                            i := i - 1;
                        end;
                        if i > 0 then begin
                          schemaLocation := ConvertStr(CopyStr(FileName,i + 1),' ','_');
                          "Folder Name" := CopyStr(FileName,1,i);
                        end else
                          schemaLocation := ConvertStr(FileName,' ','_');
                        CurrPage.SaveRecord;
                        CODEUNIT.Run(CODEUNIT::"XBRL Import Taxonomy Spec. 2",Rec);
                    end;
                }
                action("E&xport")
                {
                    ApplicationArea = XBRL;
                    Caption = 'E&xport';
                    Ellipsis = true;
                    Image = Export;
                    ToolTip = 'Export the XBRL schema to an .xsd file for reuse in another database.';

                    trigger OnAction()
                    begin
                        CalcFields(XSD);
                        if XSD.HasValue then begin
                          TempBlob.Blob := XSD;
                          FileMgt.BLOBExport(TempBlob,'*.xsd',true);
                        end;
                    end;
                }
            }
        }
    }

    var
        Text001: Label 'Do you want to replace the existing definition?';
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
}

