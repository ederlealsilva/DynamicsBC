page 589 "XBRL Linkbases"
{
    // version NAVW111.00

    AutoSplitKey = true;
    Caption = 'XBRL Linkbases';
    DataCaptionFields = "XBRL Taxonomy Name","XBRL Schema Line No.";
    PageType = List;
    SourceTable = "XBRL Linkbase";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Type;Type)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies which information the linkbase contains. Label: Info about the elements of the taxonomy. Presentation: Info about the structure of the elements. Calculation: Info about which elements roll up to which elements. Reference: Info about what data to enter on each line in the taxonomy.';
                }
                field(Description;Description)
                {
                    ApplicationArea = XBRL;
                    ToolTip = 'Specifies a description of the XBRL linkbase schema.';
                }
                field("XML.HasValue";XML.HasValue)
                {
                    ApplicationArea = XBRL;
                    Caption = 'XML File Imported';
                    Editable = false;
                    ToolTip = 'Specifies if an XBRL linkbase has been imported.';
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
            group("&Linkbase")
            {
                Caption = '&Linkbase';
                Image = Links;
                action(Import)
                {
                    ApplicationArea = XBRL;
                    Caption = 'Import';
                    Ellipsis = true;
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Import an XBRL taxonomy into your company database by first importing one or more linkbases in .xml format. After you have completed the import of both schemas and linkbases and have applied the linkbases to the schema, you can set up the lines and map the general ledger accounts in the chart of accounts to the appropriate taxonomy lines.';

                    trigger OnAction()
                    var
                        XBRLImport: Codeunit "XBRL Import Taxonomy Spec. 2";
                        XMLExists: Boolean;
                    begin
                        CalcFields(XML);
                        XMLExists := XML.HasValue;
                        "File Name" := CopyStr(FileMgt.BLOBImport(TempBlob,'*.xml'),1,MaxStrLen("File Name"));
                        if "File Name" = '' then
                          exit;
                        XML := TempBlob.Blob;
                        if XMLExists then
                          if not Confirm(Text001,false) then
                            exit;
                        CurrPage.SaveRecord;
                        Commit;
                        if Confirm(Text002,false) then
                          case Type of
                            Type::Label:
                              XBRLImport.ImportLabels(Rec);
                            Type::Presentation:
                              XBRLImport.ImportPresentation(Rec);
                            Type::Calculation:
                              XBRLImport.ImportCalculation(Rec);
                            Type::Reference:
                              XBRLImport.ImportReference(Rec);
                          end;
                    end;
                }
                action("E&xport")
                {
                    ApplicationArea = XBRL;
                    Caption = 'E&xport';
                    Ellipsis = true;
                    Image = Export;
                    ToolTip = 'Export the XBRL linkbase to an .xml file for reuse in another database.';

                    trigger OnAction()
                    begin
                        CalcFields(XML);
                        if XML.HasValue then begin
                          TempBlob.Blob := XML;
                          FileMgt.BLOBExport(TempBlob,'*.xml',true);
                        end;
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Apply to Taxonomy")
                {
                    ApplicationArea = XBRL;
                    Caption = 'Apply to Taxonomy';
                    Image = ApplyTemplate;
                    ToolTip = 'Apply the linkbase to a schema.';

                    trigger OnAction()
                    var
                        XBRLLinkbase: Record "XBRL Linkbase";
                        XBRLImportTaxonomySpec2: Codeunit "XBRL Import Taxonomy Spec. 2";
                    begin
                        if Confirm(StrSubstNo(Text003,"XBRL Taxonomy Name"),false) then begin
                          XBRLLinkbase := Rec;
                          CurrPage.SetSelectionFilter(XBRLLinkbase);
                          with XBRLLinkbase do
                            if Find('-') then
                              repeat
                                case Type of
                                  Type::Label:
                                    XBRLImportTaxonomySpec2.ImportLabels(XBRLLinkbase);
                                  Type::Calculation:
                                    XBRLImportTaxonomySpec2.ImportCalculation(XBRLLinkbase);
                                  Type::Presentation:
                                    XBRLImportTaxonomySpec2.ImportPresentation(XBRLLinkbase);
                                  Type::Reference:
                                    XBRLImportTaxonomySpec2.ImportReference(XBRLLinkbase);
                                end;
                              until Next = 0;
                        end;
                    end;
                }
            }
        }
    }

    var
        Text001: Label 'Do you want to replace the existing linkbase?';
        Text002: Label 'Do you want to apply the linkbase to the taxonomy now?';
        Text003: Label 'Do you want to apply the selected linkbases to taxonomy %1?';
        TempBlob: Record TempBlob;
        FileMgt: Codeunit "File Management";
}

