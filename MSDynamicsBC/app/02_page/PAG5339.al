page 5339 "Integration Synch. Error List"
{
    // version NAVW113.00

    ApplicationArea = Suite;
    Caption = 'Integration Synchronization Errors';
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Integration Synch. Job Errors";
    SourceTableView = SORTING("Date/Time","Integration Synch. Job ID")
                      ORDER(Descending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Date/Time";"Date/Time")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date and time that the error in the integration synchronization job occurred.';
                }
                field(Message;Message)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the error that occurred in the integration synchronization job.';
                    Width = 100;
                }
                field("Exception Detail";"Exception Detail")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the exception that occurred in the integration synchronization job.';
                }
                field(Source;OpenSourcePageTxt)
                {
                    ApplicationArea = Suite;
                    Caption = 'Source';
                    ToolTip = 'Specifies the record that supplied the data to destination record in integration synchronization job that failed.';

                    trigger OnDrillDown()
                    var
                        CRMSynchHelper: Codeunit "CRM Synch. Helper";
                    begin
                        CRMSynchHelper.ShowPage("Source Record ID");
                    end;
                }
                field(Destination;OpenDestinationPageTxt)
                {
                    ApplicationArea = Suite;
                    Caption = 'Destination';
                    ToolTip = 'Specifies the record that received the data from the source record in integration synchronization job that failed.';

                    trigger OnDrillDown()
                    var
                        CRMSynchHelper: Codeunit "CRM Synch. Helper";
                    begin
                        CRMSynchHelper.ShowPage("Destination Record ID");
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Delete7days)
            {
                ApplicationArea = Suite;
                Caption = 'Delete Entries Older Than 7 Days';
                Enabled = HasRecords;
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete error log information for job queue entries that are older than seven days.';

                trigger OnAction()
                begin
                    DeleteEntries(7);
                end;
            }
            action(Delete0days)
            {
                ApplicationArea = Suite;
                Caption = 'Delete All Entries';
                Enabled = HasRecords;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete all error log information for job queue entries.';

                trigger OnAction()
                begin
                    DeleteEntries(0);
                end;
            }
            group(ActionGroupCRM)
            {
                Caption = 'Dynamics 365 for Sales';
                action(CRMSynchronizeNow)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Enabled = HasRecords;
                    Image = Refresh;
                    ToolTip = 'Send or get updated data to or from Dynamics 365 for Sales.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        LocalRecordID: RecordID;
                    begin
                        if IsEmpty then
                          exit;

                        GetRecordID(LocalRecordID);
                        CRMIntegrationManagement.UpdateOneNow(LocalRecordID);
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment='Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Dynamics 365 record and a Dynamics 365 for Sales record.';
                    action(ManageCRMCoupling)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Enabled = HasRecords;
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 for Sales entity.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                            LocalRecordID: RecordID;
                        begin
                            if IsEmpty then
                              exit;

                            GetRecordID(LocalRecordID);
                            CRMIntegrationManagement.DefineCoupling(LocalRecordID);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = HasRecords;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 for Sales entity.';

                        trigger OnAction()
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            LocalRecordID: RecordID;
                        begin
                            if IsEmpty then
                              exit;

                            GetRecordID(LocalRecordID);
                            CRMCouplingManagement.RemoveCoupling(LocalRecordID);
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        RecID: RecordID;
    begin
        RecID := "Source Record ID";
        OpenSourcePageTxt := GetPageLink(RecID);

        RecID := "Destination Record ID";
        OpenDestinationPageTxt := GetPageLink(RecID);

        HasRecords := not IsEmpty;
    end;

    var
        InvalidOrMissingSourceErr: Label 'The source record was not found.';
        InvalidOrMissingDestinationErr: Label 'The destination record was not found.';
        OpenSourcePageTxt: Text;
        OpenDestinationPageTxt: Text;
        OpenPageTok: Label 'View';
        HasRecords: Boolean;

    local procedure GetRecordID(var LocalRecordID: RecordID)
    var
        TableMetadata: Record "Table Metadata";
    begin
        LocalRecordID := "Source Record ID";
        if LocalRecordID.TableNo = 0 then
          Error(InvalidOrMissingSourceErr);

        if not TableMetadata.Get(LocalRecordID.TableNo) then
          Error(InvalidOrMissingSourceErr);

        if TableMetadata.TableType <> TableMetadata.TableType::CRM then
          exit;

        LocalRecordID := "Destination Record ID";
        if LocalRecordID.TableNo = 0 then
          Error(InvalidOrMissingDestinationErr);
    end;

    local procedure GetPageLink(var RecID: RecordID): Text
    var
        TableMetadata: Record "Table Metadata";
        ReferenceRecordRef: RecordRef;
    begin
        TableMetadata.SetRange(ID,RecID.TableNo);
        if TableMetadata.FindFirst then
          if TableMetadata.TableType = TableMetadata.TableType::MicrosoftGraph then
            exit('');

        if not ReferenceRecordRef.Get(RecID) then
          exit('');

        exit(OpenPageTok);
    end;
}

