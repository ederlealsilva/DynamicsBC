page 2507 "Upload And Deploy Extension"
{
    // version NAVW113.00

    Caption = 'Upload And Deploy Extension';
    PageType = NavigatePage;
    SourceTable = "NAV App";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field("Upload Extension";'')
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Upload Extension';
                Style = StrongAccent;
                StyleExpr = TRUE;
            }
            field(FileName;FileName)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Select .app file';
                Editable = false;

                trigger OnAssistEdit()
                begin
                    UploadIntoStream('Select .APP File','C:\','Extension Files|*.app',FileName,FileStream);
                end;
            }
            field(Control11;'')
            {
                ShowCaption = false;
            }
            field("Deploy Extension";'')
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Deploy Extension';
                Style = StrongAccent;
                StyleExpr = TRUE;
            }
            field(DeployTo;DeployTo)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Deploy to';
            }
            field(Language;LanguageName)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Language';

                trigger OnLookup(var Text: Text): Boolean
                var
                    WinLanguagesTable: Record "Windows Language";
                begin
                    WinLanguagesTable.SetRange("Globally Enabled",true);
                    WinLanguagesTable.SetRange("Localization Exist",true);
                    if PAGE.RunModal(PAGE::"Windows Languages",WinLanguagesTable) = ACTION::LookupOK then begin
                      LanguageID := WinLanguagesTable."Language ID";
                      LanguageName := WinLanguagesTable.Name;
                    end;
                end;

                trigger OnValidate()
                var
                    WinLanguagesTable: Record "Windows Language";
                begin
                    WinLanguagesTable.SetRange(Name,LanguageName);
                    WinLanguagesTable.SetRange("Globally Enabled",true);
                    WinLanguagesTable.SetRange("Localization Exist",true);
                    if WinLanguagesTable.FindFirst then
                      LanguageID := WinLanguagesTable."Language ID"
                    else
                      Error(LanguageNotFoundErr,LanguageName);
                end;
            }
            field(Disclaimer;DisclaimerLbl)
            {
                ApplicationArea = Basic,Suite;
                Editable = false;
                ShowCaption = false;
                Style = None;

                trigger OnDrillDown()
                begin
                    Message(DisclaimerMsg);
                end;
            }
            field(Accepted;Accepted)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Accept';
                ToolTip = 'Specifies that you accept Disclaimer.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Deploy)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Deploy';
                Enabled = Accepted;
                InFooterBar = true;
                Promoted = true;
                RunPageMode = Edit;

                trigger OnAction()
                var
                    NavExtensionOperationMgmt: Codeunit NavExtensionOperationMgmt;
                    DotNet_ALPacDeploymentSchedule: Codeunit DotNet_ALPacDeploymentSchedule;
                begin
                    if FileName = '' then
                      Message(ExtensionNotUploadedMsg)
                    else begin
                      case DeployTo of
                        DeployTo::"Current version":
                          begin
                            DotNet_ALPacDeploymentSchedule.Immediate;
                            NavExtensionOperationMgmt.UploadNavExtension(FileStream,DotNet_ALPacDeploymentSchedule,LanguageID);
                            Message(CurrentOperationProgressMsg);
                          end;
                        DeployTo::"Next minor version":
                          begin
                            DotNet_ALPacDeploymentSchedule.StageForNextMinorUpdate;
                            NavExtensionOperationMgmt.UploadNavExtension(FileStream,DotNet_ALPacDeploymentSchedule,LanguageID);
                            Message(ScheduledOperationMinorProgressMsg);
                          end;
                        DeployTo::"Next major version":
                          begin
                            DotNet_ALPacDeploymentSchedule.StageForNextMajorUpdate;
                            NavExtensionOperationMgmt.UploadNavExtension(FileStream,DotNet_ALPacDeploymentSchedule,LanguageID);
                            Message(ScheduledOperationMajorProgressMsg);
                          end;
                      end;
                      CurrPage.Close;
                    end;
                end;
            }
            action(Cancel)
            {
                ApplicationArea = Basic,Suite;
                Caption = 'Cancel';
                InFooterBar = true;
                RunPageMode = Edit;

                trigger OnAction()
                begin
                    CurrPage.Close;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        WinLanguagesTable: Record "Windows Language";
    begin
        LanguageID := GlobalLanguage;
        WinLanguagesTable.SetRange("Language ID",LanguageID);
        if WinLanguagesTable.FindFirst then
          LanguageName := WinLanguagesTable.Name;
    end;

    var
        FileStream: InStream;
        DeployTo: Option "Current version","Next minor version","Next major version";
        FileName: Text;
        LanguageName: Text;
        LanguageID: Integer;
        LanguageNotFoundErr: Label 'Cannot find the specified language, %1. Choose the lookup button to select a language.', Comment='Error message to notify user that the entered language was not found. This could mean that the language doesn''t exist or that the language is not valid within the filter set for the lookup. %1=Entered value.';
        ExtensionNotUploadedMsg: Label 'Please upload an extension file before clicking "Deploy" button.';
        CurrentOperationProgressMsg: Label 'Extension deployment is in progress. Please check the status page for updates.';
        ScheduledOperationMajorProgressMsg: Label 'Extension deployment has been scheduled for the next major version. Please check the status page for updates.';
        ScheduledOperationMinorProgressMsg: Label 'Extension deployment has been scheduled for the next minor version. Please check the status page for updates.';
        DisclaimerLbl: Label 'Disclaimer';
        DisclaimerMsg: Label 'The creator of this customized extension is responsible for its licensing. The customized extension is subject to the terms and conditions, privacy policy, support and billing offered by the creator, as applicable, and does not create any liability or obligation for Microsoft.';
        Accepted: Boolean;
}

