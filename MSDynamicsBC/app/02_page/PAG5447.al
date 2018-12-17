page 5447 "Automation Extension Upload"
{
    // version NAVW113.00

    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    Caption = 'extensionUpload', Locked=true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'extensionUpload';
    EntitySetName = 'extensionUpload';
    ODataKeyFields = "Primary Key";
    PageType = API;
    SourceTable = TempBlob;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(content;Blob)
                {
                    ApplicationArea = All;
                    Caption = 'content', Locked=true;

                    trigger OnValidate()
                    var
                        NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
                        DotNet_ALPacDeploymentSchedule: Codeunit DotNet_ALPacDeploymentSchedule;
                        FileStream: InStream;
                    begin
                        if Blob.HasValue then begin
                          Blob.CreateInStream(FileStream);
                          DotNet_ALPacDeploymentSchedule.Immediate;
                          NavExtensionOperationMgmt.UploadNavExtension(FileStream,DotNet_ALPacDeploymentSchedule,GlobalLanguage);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not loaded then begin
          Insert(true);
          loaded := true;
        end;
        exit(true);
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        loaded: Boolean;
}

