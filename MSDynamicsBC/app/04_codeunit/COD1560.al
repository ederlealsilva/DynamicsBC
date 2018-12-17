codeunit 1560 "Workflow Imp. / Exp. Mgt"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        MoreThanOneWorkflowImportErr: Label 'You cannot import more than one workflow.';

    local procedure GetWorkflowCodeListFromXml(TempBlob: Record TempBlob) WorkflowCodes: Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        XmlNodeList: DotNet XmlNodeList;
        XmlNode: DotNet XmlNode;
        InStream: InStream;
    begin
        TempBlob.Blob.CreateInStream(InStream);
        XMLDOMManagement.LoadXMLNodeFromInStream(InStream,XmlNode);

        XMLDOMManagement.FindNodes(XmlNode,'/Root/Workflow',XmlNodeList);

        foreach XmlNode in XmlNodeList do begin
          if WorkflowCodes = '' then
            WorkflowCodes := XMLDOMManagement.GetAttributeValue(XmlNode,'Code')
          else
            WorkflowCodes := WorkflowCodes + ',' + XMLDOMManagement.GetAttributeValue(XmlNode,'Code');
        end;
    end;

    procedure ReplaceWorkflow(var Workflow: Record Workflow;var TempBlob: Record TempBlob)
    var
        FromWorkflow: Record Workflow;
        CopyWorkflow: Report "Copy Workflow";
        NewWorkflowCodes: Text;
        TempWorkflowCode: Text[20];
    begin
        NewWorkflowCodes := GetWorkflowCodeListFromXml(TempBlob);
        if TrySelectStr(2,NewWorkflowCodes,TempWorkflowCode) then
          Error(MoreThanOneWorkflowImportErr);

        FromWorkflow.Init;
        FromWorkflow.Code := CopyStr(Format(CreateGuid),1,MaxStrLen(Workflow.Code));
        FromWorkflow.ImportFromBlob(TempBlob);

        CopyWorkflow.InitCopyWorkflow(FromWorkflow,Workflow);
        CopyWorkflow.UseRequestPage(false);
        CopyWorkflow.Run;

        FromWorkflow.Delete(true);
    end;

    [TryFunction]
    local procedure TrySelectStr(Index: Integer;InputString: Text;var SelectedString: Text[20])
    begin
        SelectedString := SelectStr(Index,InputString);
    end;
}

