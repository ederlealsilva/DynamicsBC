codeunit 2001 "Azure ML Connector"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        [WithEvents]
        AzureMLRequest: DotNet AzureMLRequest;
        [WithEvents]
        AzureMLParametersBuilder: DotNet AzureMLParametersBuilder;
        [WithEvents]
        AzureMLInputBuilder: DotNet AzureMLInputBuilder;
        HttpMessageHandler: DotNet HttpMessageHandler;
        ProcessingTime: Decimal;
        OutputNameTxt: Label 'Output1', Locked=true;
        InputNameTxt: Label 'input1', Locked=true;
        ParametersNameTxt: Label 'Parameters', Locked=true;
        InputName: Text;
        OutputName: Text;
        ParametersName: Text;

    [Scope('Personalization')]
    procedure Initialize(ApiKey: Text;ApiUri: Text;TimeOutSeconds: Integer)
    begin
        AzureMLRequest := AzureMLRequest.AzureMLRequest(ApiKey,ApiUri,TimeOutSeconds);
        // To set HttpMessageHandler first call SetMessageHandler
        AzureMLRequest.SetHttpMessageHandler(HttpMessageHandler);

        AzureMLInputBuilder := AzureMLInputBuilder.AzureMLInputBuilder;

        AzureMLParametersBuilder := AzureMLParametersBuilder.AzureMLParametersBuilder;

        OutputName := OutputNameTxt;
        InputName := InputNameTxt;
        ParametersName := ParametersNameTxt;

        AzureMLRequest.SetInput(InputName,AzureMLInputBuilder);
        AzureMLRequest.SetParameter(ParametersName,AzureMLParametersBuilder);
    end;

    [Scope('Personalization')]
    procedure IsInitialized(): Boolean
    begin
        exit(not IsNull(AzureMLRequest) and not IsNull(AzureMLInputBuilder) and not IsNull(AzureMLParametersBuilder));
    end;

    procedure SendToAzureML(TrackUsage: Boolean): Boolean
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    begin
        AzureMLRequest.SetUsingStandardCredentials(TrackUsage);

        if not SendRequestToAzureML then
          exit(false);

        if TrackUsage then begin
          // Convert to seconds
          ProcessingTime := ProcessingTime / 1000;
          CortanaIntelligenceUsage.IncrementTotalProcessingTime(CortanaIntelligenceUsage.Service::"Machine Learning",
            ProcessingTime);
        end;
        exit(true);
    end;

    [TryFunction]
    procedure SendRequestToAzureML()
    begin
        AzureMLRequest.SetHttpMessageHandler(HttpMessageHandler);
        ProcessingTime := AzureMLRequest.InvokeRequestResponseService;
    end;

    procedure SetMessageHandler(MessageHandler: DotNet HttpMessageHandler)
    begin
        HttpMessageHandler := MessageHandler;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure SetInputName(Name: Text)
    begin
        InputName := Name;
        AzureMLRequest.SetInput(InputName,AzureMLInputBuilder);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure AddInputColumnName(ColumnName: Text)
    begin
        AzureMLInputBuilder.AddColumnName(ColumnName);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure AddInputRow()
    begin
        AzureMLInputBuilder.AddRow;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure AddInputValue(Value: Text)
    begin
        AzureMLInputBuilder.AddValue(Value);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure AddParameter(Name: Text;Value: Text)
    begin
        AzureMLParametersBuilder.AddParameter(Name,Value);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure SetParameterName(Name: Text)
    begin
        ParametersName := Name;
        AzureMLRequest.SetParameter(ParametersName,AzureMLParametersBuilder);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure SetOutputName(Name: Text)
    begin
        OutputName := Name;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure GetOutput(LineNo: Integer;ColumnNo: Integer;var OutputValue: Text)
    begin
        OutputValue := AzureMLRequest.GetOutputValue(OutputName,LineNo - 1,ColumnNo - 1);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure GetOutputLength(var Length: Integer)
    begin
        Length := AzureMLRequest.GetOutputLength(OutputName);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure GetInput(LineNo: Integer;ColumnNo: Integer;var InputValue: Text)
    begin
        InputValue := AzureMLInputBuilder.GetValue(LineNo - 1,ColumnNo - 1);
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure GetInputLength(var Length: Integer)
    begin
        Length := AzureMLInputBuilder.GetLength;
    end;

    [TryFunction]
    [Scope('Personalization')]
    procedure GetParameter(Name: Text;var ParameterValue: Text)
    begin
        ParameterValue := AzureMLParametersBuilder.GetParameter(Name);
    end;
}

