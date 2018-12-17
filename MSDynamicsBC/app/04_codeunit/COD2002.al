codeunit 2002 "Cortana Tracing"
{
    // version NAVW113.00

    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        CortanaCategoryTxt: Label 'AL Cortana', Comment='Locked';
        TraceImageAnalysisSuccessTagsTxt: Label 'Number of Image Analysis calls: %1;Limit: %2;Period type: %3;Execution time: %4 ms;Confidence: %5.', Comment='Locked';
        AnalysisStartTime: DateTime;
        TraceImageAnalysisSuccessTxt: Label 'Number of Image Analysis calls: %1;Limit: %2;Period type: %3;Execution time: %4 ms.', Comment='Locked';

    [EventSubscriber(ObjectType::Codeunit, 2020, 'OnBeforeImageAnalysis', '', false, false)]
    local procedure TraceImageAnalysisStart(var Sender: Codeunit "Image Analysis Management")
    begin
        AnalysisStartTime := CurrentDateTime;
    end;

    [EventSubscriber(ObjectType::Codeunit, 2020, 'OnAfterImageAnalysis', '', false, false)]
    local procedure TraceImageAnalysisEnd(var Sender: Codeunit "Image Analysis Management";ImageAnalysisResult: Codeunit "Image Analysis Result")
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
        LastError: Text;
        IsUsageLimitError: Boolean;
        LimitType: Option Year,Month,Day,Hour;
        LimitValue: Integer;
        Message: Text;
        AnalysisDuration: Integer;
        AnalysisType: Option Tags,Faces,Color;
        NoOfCalls: Integer;
    begin
        if Sender.GetLastError(LastError,IsUsageLimitError) then
          SendTraceTag('000015X',CortanaCategoryTxt,VERBOSITY::Error,LastError,DATACLASSIFICATION::SystemMetadata)
        else begin
          Sender.GetLimitParams(LimitType,LimitValue);

          AnalysisDuration := CurrentDateTime - AnalysisStartTime;
          ImageAnalysisResult.GetLatestAnalysisType(AnalysisType);
          NoOfCalls := CortanaIntelligenceUsage.GetTotalProcessingTime(CortanaIntelligenceUsage.Service::"Computer Vision");
          if AnalysisType = AnalysisType::Tags then
            Message := StrSubstNo(TraceImageAnalysisSuccessTagsTxt,
                NoOfCalls,LimitValue,LimitType,AnalysisDuration,
                ImageAnalysisResult.TagConfidence(1))
          else
            Message := StrSubstNo(TraceImageAnalysisSuccessTxt,
                NoOfCalls,LimitValue,LimitType,AnalysisDuration);

          SendTraceTag('000015Y',CortanaCategoryTxt,VERBOSITY::Normal,Message,DATACLASSIFICATION::SystemMetadata);
        end;
    end;
}

