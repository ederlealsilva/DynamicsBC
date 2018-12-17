codeunit 2114 "O365 HTML Templ. Mgt."
{
    // version NAVW113.00

    Permissions = TableData "Payment Reporting Argument"=rimd;

    trigger OnRun()
    begin
    end;

    var
        InvoiceNoTxt: Label 'Invoice No.';
        EstimateNoTxt: Label 'Estimate No.';
        ValidUntilTxt: Label 'Valid until';
        TotalTxt: Label 'Total %1', Comment='%1 = Currency Code';
        YourInvoiceTxt: Label 'Your Invoice';
        YourEstimateTxt: Label 'Your Estimate';
        WantToPayOnlineQst: Label 'Want to pay online?';
        PaymentInvitationTxt: Label 'You can pay this invoice online. It''s quick and easy.';
        CompanyInformation: Record "Company Information";
        CompanyInfoRead: Boolean;
        EmailSentToTxt: Label 'This email was sent to';
        FollowOnSocialTxt: Label 'Follow %1 on Social', Comment='%1 - company name';
        ThankYouForYourBusinessTxt: Label 'Thank you for your business.';
        InvoiceFromTitleTxt: Label 'Invoice from %1', Comment='This is a mail title. %1 - company name';
        EstimateFromTitleTxt: Label 'Estimate from %1', Comment='This is a mail title. %1 - company name';

    [Scope('Personalization')]
    procedure CreateEmailBodyFromReportSelections(ReportSelections: Record "Report Selections";RecordVariant: Variant;MailTo: Text;MailText: Text) OutputFileName: Text[250]
    var
        FileMgt: Codeunit "File Management";
        HTMLText: Text;
    begin
        OutputFileName := CopyStr(FileMgt.ServerTempFileName('html'),1,250);

        HTMLText := CreateHTMLTextFromReportSelections(ReportSelections,RecordVariant,MailTo,MailText);

        SaveHTML(OutputFileName,HTMLText);
    end;

    local procedure CreateHTMLTextFromReportSelections(ReportSelections: Record "Report Selections";RecordVariant: Variant;MailTo: Text;MailText: Text) HTMLText: Text
    begin
        with ReportSelections do begin
          HTMLText := GetTemplateContent("Email Body Layout Code");

          case Usage of
            Usage::"S.Invoice":
              FillSalesInvoiceHTML(RecordVariant,HTMLText,MailTo,MailText);
            Usage::"S.Invoice Draft":
              FillSalesDraftInvoiceHTML(RecordVariant,HTMLText,MailTo,MailText);
            Usage::"S.Quote":
              FillSalesEstimateHTML(RecordVariant,HTMLText,MailTo,MailText);
          end;
        end;
    end;

    local procedure FillSalesDraftInvoiceHTML(SalesHeader: Record "Sales Header";var HTMLText: Text;MailTo: Text;MailText: Text)
    var
        PaymentServicesSectionHTMLText: Text;
        PaymentServiceRowHTMLText: Text;
        SocialNetworksSectionHTMLText: Text;
        SocialNetworkRowSectionHTMLText: Text;
    begin
        SliceSalesCoverLetterTemplate(HTMLText,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText,
          SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText);

        FillCommonParameters(HTMLText,SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText,MailTo,MailText);
        FillParameterValueEncoded(HTMLText,'MailTitle',StrSubstNo(InvoiceFromTitleTxt,CompanyInformation.Name));
        FillParameterValueEncoded(HTMLText,'YourDocument',YourInvoiceTxt);

        FillParameterValueEncoded(HTMLText,'DocumentNoLbl',InvoiceNoTxt);
        FillParameterValueEncoded(HTMLText,'DocumentNo',SalesHeader."No.");
        FillParameterValueEncoded(HTMLText,'DateLbl',SalesHeader.FieldCaption("Due Date"));
        FillParameterValueEncoded(HTMLText,'Date',Format(SalesHeader."Due Date"));
        FillParameterValueEncoded(HTMLText,'TotalAmountLbl',StrSubstNo(TotalTxt,SalesHeader.GetCurrencySymbol));
        SalesHeader.CalcFields("Amount Including VAT");
        FillParameterValueEncoded(HTMLText,'TotalAmount',Format(SalesHeader."Amount Including VAT"));

        FillSalesDraftInvoicePaymentServices(HTMLText,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText,SalesHeader);
    end;

    local procedure FillSalesInvoiceHTML(SalesInvoiceHeader: Record "Sales Invoice Header";var HTMLText: Text;MailTo: Text;MailText: Text)
    var
        PaymentServicesSectionHTMLText: Text;
        PaymentServiceRowHTMLText: Text;
        SocialNetworksSectionHTMLText: Text;
        SocialNetworkRowSectionHTMLText: Text;
    begin
        SliceSalesCoverLetterTemplate(HTMLText,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText,
          SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText);

        FillCommonParameters(HTMLText,SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText,MailTo,MailText);
        FillParameterValueEncoded(HTMLText,'MailTitle',StrSubstNo(InvoiceFromTitleTxt,CompanyInformation.Name));
        FillParameterValueEncoded(HTMLText,'YourDocument',YourInvoiceTxt);
        FillParameterValueEncoded(HTMLText,'DocumentNoLbl',InvoiceNoTxt);
        FillParameterValueEncoded(HTMLText,'DocumentNo',SalesInvoiceHeader."No.");
        FillParameterValueEncoded(HTMLText,'DateLbl',SalesInvoiceHeader.FieldCaption("Due Date"));
        FillParameterValueEncoded(HTMLText,'Date',Format(SalesInvoiceHeader."Due Date"));
        FillParameterValueEncoded(HTMLText,'TotalAmountLbl',StrSubstNo(TotalTxt,SalesInvoiceHeader.GetCurrencySymbol));
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        FillParameterValueEncoded(HTMLText,'TotalAmount',Format(SalesInvoiceHeader."Amount Including VAT"));

        SalesInvoiceHeader.CalcFields(Cancelled);
        if not SalesInvoiceHeader.Cancelled then
          FillSalesInvoicePaymentServices(HTMLText,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText,SalesInvoiceHeader);
    end;

    local procedure FillSalesEstimateHTML(SalesHeader: Record "Sales Header";var HTMLText: Text;MailTo: Text;MailText: Text)
    var
        PaymentServicesSectionHTMLText: Text;
        PaymentServiceRowHTMLText: Text;
        SocialNetworksSectionHTMLText: Text;
        SocialNetworkRowSectionHTMLText: Text;
    begin
        SliceSalesCoverLetterTemplate(HTMLText,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText,
          SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText);

        FillCommonParameters(HTMLText,SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText,MailTo,MailText);
        FillParameterValueEncoded(HTMLText,'MailTitle',StrSubstNo(EstimateFromTitleTxt,CompanyInformation.Name));
        FillParameterValueEncoded(HTMLText,'YourDocument',YourEstimateTxt);

        FillParameterValueEncoded(HTMLText,'DocumentNoLbl',EstimateNoTxt);
        FillParameterValueEncoded(HTMLText,'DocumentNo',SalesHeader."No.");
        FillParameterValueEncoded(HTMLText,'DateLbl',ValidUntilTxt);
        FillParameterValueEncoded(HTMLText,'Date',Format(SalesHeader."Quote Valid Until Date"));
        FillParameterValueEncoded(HTMLText,'TotalAmountLbl',StrSubstNo(TotalTxt,SalesHeader.GetCurrencySymbol));
        SalesHeader.CalcFields("Amount Including VAT");
        FillParameterValueEncoded(HTMLText,'TotalAmount',Format(SalesHeader."Amount Including VAT"));
    end;

    local procedure GetCompanyInfo()
    begin
        if CompanyInfoRead then
          exit;

        CompanyInformation.Get;
        CompanyInfoRead := true;
    end;

    local procedure GetCompanyLogoScaledDimensions(var TempBlob: Record TempBlob;var ScaledWidth: Integer;var ScaledHeight: Integer;ScaleToWidth: Integer;ScaleToHeight: Integer)
    var
        Image: DotNet Image;
        InStream: InStream;
        HorizontalFactor: Decimal;
        VerticalFactor: Decimal;
    begin
        if not TempBlob.Blob.HasValue then
          exit;
        TempBlob.Blob.CreateInStream(InStream);
        Image := Image.FromStream(InStream);

        if Image.Height <> 0 then
          HorizontalFactor := ScaleToHeight / Image.Height;
        if Image.Width <> 0 then
          VerticalFactor := ScaleToWidth / Image.Width;

        if HorizontalFactor < VerticalFactor then
          VerticalFactor := HorizontalFactor
        else
          HorizontalFactor := VerticalFactor;

        ScaledHeight := Round(Image.Height * HorizontalFactor,1);
        ScaledWidth := Round(Image.Width * VerticalFactor,1);
    end;

    local procedure GetCompanyLogoAsTempBlob(var TempBlob: Record TempBlob): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.CalcFields(Picture);
        TempBlob.Init;
        TempBlob.Blob := CompanyInformation.Picture;
        exit(TempBlob.GetHTMLImgSrc);
    end;

    [Scope('Personalization')]
    procedure GetTemplateContent(TemplateCode: Code[20]) TemplateContent: Text
    var
        O365HTMLTemplate: Record "O365 HTML Template";
        MediaResources: Record "Media Resources";
        InStream: InStream;
        Buffer: Text;
    begin
        O365HTMLTemplate.Get(TemplateCode);
        O365HTMLTemplate.TestField("Media Resources Ref");
        MediaResources.Get(O365HTMLTemplate."Media Resources Ref");
        MediaResources.CalcFields(Blob);
        MediaResources.Blob.CreateInStream(InStream,TEXTENCODING::UTF8);
        while not InStream.EOS do begin
          InStream.Read(Buffer);
          TemplateContent += Buffer;
        end;
    end;

    local procedure GetPaymentServiceLogoAsText(PaymentReportingArgument: Record "Payment Reporting Argument"): Text
    var
        TempBlob: Record TempBlob;
        O365PaymentServiceLogo: Record "O365 Payment Service Logo";
        MediaResources: Record "Media Resources";
    begin
        TempBlob.Init;

        if O365PaymentServiceLogo.FindO365Logo(PaymentReportingArgument) then begin
          MediaResources.Get(O365PaymentServiceLogo."Media Resources Ref");
          MediaResources.CalcFields(Blob);
          TempBlob.Blob := MediaResources.Blob;
        end else begin
          PaymentReportingArgument.CalcFields(Logo);
          TempBlob.Blob := PaymentReportingArgument.Logo;
        end;

        ResizePaymentServiceLogoIfNeeded(TempBlob);

        exit(TempBlob.GetHTMLImgSrc);
    end;

    local procedure GetPrimaryColorValue(): Code[10]
    var
        O365BrandColor: Record "O365 Brand Color";
    begin
        GetCompanyInfo;

        if CompanyInformation."Brand Color Value" = '' then
          if O365BrandColor.FindFirst then
            exit(O365BrandColor."Color Value");

        exit(CompanyInformation."Brand Color Value");
    end;

    local procedure GetSocialNetworksHTMLPart(SocialNetworksSectionHTMLText: Text;SocialNetworkRowSectionHTMLText: Text) SocialNetworksHTMLPart: Text
    var
        O365SocialNetwork: Record "O365 Social Network";
    begin
        O365SocialNetwork.SetFilter(URL,'<>%1','');
        O365SocialNetwork.SetFilter("Media Resources Ref",'<>%1','');
        if O365SocialNetwork.FindFirst then begin
          SocialNetworksHTMLPart := SocialNetworksSectionHTMLText;
          GetCompanyInfo;
          FillParameterValueEncoded(
            SocialNetworksHTMLPart,
            'FollowOnSocial',
            StrSubstNo(FollowOnSocialTxt,CompanyInformation.Name));
          FillParameterValue(
            SocialNetworksHTMLPart,
            'CoverLetterSocialRow',
            GetSocialsRowsHTMLPart(O365SocialNetwork,SocialNetworkRowSectionHTMLText));
        end;
    end;

    local procedure GetSocialsRowsHTMLPart(var O365SocialNetwork: Record "O365 Social Network";SocialNetworkRowSectionHTMLText: Text) HTMLText: Text
    var
        MediaResources: Record "Media Resources";
    begin
        repeat
          if MediaResources.Get(O365SocialNetwork."Media Resources Ref") then
            HTMLText += GetSocialsRowHTMLPart(O365SocialNetwork,SocialNetworkRowSectionHTMLText);
        until O365SocialNetwork.Next = 0;
    end;

    local procedure GetSocialsRowHTMLPart(O365SocialNetwork: Record "O365 Social Network";SocialNetworkRowSectionHTMLText: Text) RowHTMLText: Text
    begin
        RowHTMLText := SocialNetworkRowSectionHTMLText;
        FillParameterValueEncoded(RowHTMLText,'SocialURL',O365SocialNetwork.URL);
        FillParameterValueEncoded(RowHTMLText,'SocialAlt',O365SocialNetwork.Name);
        FillParameterValue(RowHTMLText,'SocialLogo',GetSocialNetworkLogoAsTxt(O365SocialNetwork));
    end;

    local procedure GetSocialNetworkLogoAsTxt(O365SocialNetwork: Record "O365 Social Network"): Text
    var
        TempBlob: Record TempBlob;
        MediaResources: Record "Media Resources";
    begin
        if not MediaResources.Get(O365SocialNetwork."Media Resources Ref") then
          exit('');

        MediaResources.CalcFields(Blob);
        TempBlob.Init;
        TempBlob.Blob := MediaResources.Blob;
        exit(TempBlob.GetHTMLImgSrc);
    end;

    local procedure FillCompanyInfoSection(var HTMLText: Text)
    var
        FormatAddr: Codeunit "Format Address";
        CompanyAddr: array [8] of Text[50];
    begin
        GetCompanyInfo;
        FormatAddr.Company(CompanyAddr,CompanyInformation);
        FillParameterValueEncoded(HTMLText,'CompanyName',CompanyInformation.Name);
        FillParameterValueEncoded(HTMLText,'CompanyAddress',MakeFullCompanyAddress(CompanyAddr));
        FillParameterValueEncoded(HTMLText,'CompanyPhoneNo',CompanyInformation."Phone No.");
    end;

    local procedure FillCompanyLogo(var HTMLText: Text)
    var
        TempBlob: Record TempBlob temporary;
        TempBlobResized: Record TempBlob temporary;
        ImageHandlerManagement: Codeunit "Image Handler Management";
        Width: Integer;
        Height: Integer;
        MaxWidth: Integer;
        MaxHeight: Integer;
    begin
        GetCompanyLogoAsTempBlob(TempBlob);

        MaxWidth := 246;
        MaxHeight := 80;

        TempBlobResized.Copy(TempBlob);

        if ImageHandlerManagement.ScaleDownFromBlob(TempBlobResized,MaxWidth,MaxHeight) then
          TempBlob.Copy(TempBlobResized);

        OnResizeCompanyLogo(TempBlob);

        GetCompanyLogoScaledDimensions(TempBlob,Width,Height,MaxWidth,MaxHeight);

        FillParameterValue(HTMLText,'CompanyLogo',TempBlob.GetHTMLImgSrc);
        FillParameterValueEncoded(HTMLText,'CompanyLogoWidth',Format(Width,0,9));
        FillParameterValueEncoded(HTMLText,'CompanyLogoHeight',Format(Height,0,9));
    end;

    [Scope('Personalization')]
    procedure FillCommonParameters(var HTMLText: Text;SocialNetworksSectionHTMLText: Text;SocialNetworkRowSectionHTMLText: Text;MailTo: Text;MailText: Text)
    begin
        FillCompanyLogo(HTMLText);

        FillParameterValueEncoded(HTMLText,'ThankYouForYourBusiness',ThankYouForYourBusinessTxt);
        FillParameterValue(HTMLText,'SocialNetworks',
          GetSocialNetworksHTMLPart(SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText));

        FillCompanyInfoSection(HTMLText);

        FillParameterValueEncoded(HTMLText,'EmailSentToLbl',EmailSentToTxt);
        FillParameterValueEncoded(HTMLText,'MailTo',MailTo);
        FillParameterValueEncoded(HTMLText,'PrimaryColor',GetPrimaryColorValue);

        FillParameterValue(HTMLText,'MailText',EncodeMessage(MailText,false));
    end;

    [Scope('Personalization')]
    procedure FillParameterValueEncoded(var HTMLText: Text;ParamenterName: Text;ParameterValue: Text)
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        FillParameterValue(HTMLText,ParamenterName,TypeHelper.HtmlEncode(ParameterValue));
    end;

    [Scope('Personalization')]
    procedure FillParameterValue(var HTMLText: Text;ParamenterName: Text;ParameterValue: Text)
    begin
        ReplaceHTMLText(HTMLText,MakeParameterNameString(ParamenterName),ParameterValue);
    end;

    local procedure FillSalesDraftInvoicePaymentServices(var HTMLText: Text;PaymentServicesSectionHTMLText: Text;PaymentServiceRowHTMLText: Text;SalesHeader: Record "Sales Header")
    var
        PaymentServiceSetup: Record "Payment Service Setup";
        PaymentReportingArgument: Record "Payment Reporting Argument";
    begin
        PaymentServiceSetup.CreateReportingArgs(PaymentReportingArgument,SalesHeader);
        FillPaymentServicesPart(HTMLText,PaymentReportingArgument,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText);
    end;

    local procedure FillSalesInvoicePaymentServices(var HTMLText: Text;PaymentServicesSectionHTMLText: Text;PaymentServiceRowHTMLText: Text;SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        PaymentServiceSetup: Record "Payment Service Setup";
        PaymentReportingArgument: Record "Payment Reporting Argument";
    begin
        PaymentServiceSetup.CreateReportingArgs(PaymentReportingArgument,SalesInvoiceHeader);
        FillPaymentServicesPart(HTMLText,PaymentReportingArgument,PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText);
    end;

    local procedure FillPaymentServicesPart(var HTMLText: Text;var PaymentReportingArgument: Record "Payment Reporting Argument";PaymentServicesSectionHTMLText: Text;PaymentServiceRowHTMLText: Text)
    var
        PaymentServicesHTMLText: Text;
        PaymentServicesRowsHTMLText: Text;
    begin
        if PaymentReportingArgument.FindSet then begin
          PaymentServicesHTMLText := PaymentServicesSectionHTMLText;

          FillParameterValueEncoded(PaymentServicesHTMLText,'WantToPayOnline',WantToPayOnlineQst);
          FillParameterValueEncoded(PaymentServicesHTMLText,'PaymentInvitation',PaymentInvitationTxt);

          repeat
            PaymentServicesRowsHTMLText += FillPaymentServiceRowPart(PaymentReportingArgument,PaymentServiceRowHTMLText);
          until PaymentReportingArgument.Next = 0;

          FillParameterValue(PaymentServicesHTMLText,'PaymentServicesRows',PaymentServicesRowsHTMLText);
          FillParameterValue(HTMLText,'PaymentSevices',PaymentServicesHTMLText);
        end;
    end;

    local procedure FillPaymentServiceRowPart(PaymentReportingArgument: Record "Payment Reporting Argument";PaymentServiceRowHTMLText: Text) PaymentServiceHTMLText: Text
    var
        PaymentServiceUrl: Text;
    begin
        PaymentServiceHTMLText := PaymentServiceRowHTMLText;
        PaymentServiceUrl := PaymentReportingArgument.GetTargetURL;
        FillParameterValueEncoded(PaymentServiceHTMLText,'PaymentServiceUrl',PaymentServiceUrl);
        FillParameterValueEncoded(PaymentServiceHTMLText,'PaymentServiceAlt',PaymentReportingArgument."URL Caption");
        FillParameterValue(PaymentServiceHTMLText,'PaymentServiceLogo',
          GetPaymentServiceLogoAsText(PaymentReportingArgument));
        FillParameterValueEncoded(PaymentServiceHTMLText,'PrimaryColor',GetPrimaryColorValue);
    end;

    local procedure MakeFullCompanyAddress(CompanyAddr: array [8] of Text[50]) FullCompanyAddress: Text
    var
        i: Integer;
    begin
        FullCompanyAddress := CompanyAddr[2];
        for i := 3 to 8 do begin
          if CompanyAddr[i] <> '' then
            FullCompanyAddress += ', ' + CompanyAddr[i];
        end;
    end;

    local procedure MakeParameterNameString(ParameterName: Text): Text
    begin
        exit(StrSubstNo('<!--%1-->',ParameterName));
    end;

    local procedure ReplaceHTMLText(var HTMLText: Text;OldValue: Text;NewValue: Text)
    var
        Regex: DotNet Regex;
    begin
        Regex := Regex.Regex(OldValue);
        if Regex.IsMatch(HTMLText) then
          HTMLText := Regex.Replace(HTMLText,NewValue);
    end;

    procedure ReplaceBodyFileSendTo(BodyFileName: Text;OldSendTo: Text;NewSendTo: Text)
    var
        InStream: InStream;
        BodyFile: File;
        HTMLText: Text;
        Buffer: Text;
    begin
        BodyFile.Open(BodyFileName,TEXTENCODING::UTF8);
        BodyFile.CreateInStream(InStream);
        while not InStream.EOS do begin
          InStream.Read(Buffer);
          HTMLText += Buffer;
        end;
        BodyFile.Close;

        ReplaceHTMLText(HTMLText,OldSendTo,NewSendTo);
        SaveHTML(BodyFileName,HTMLText);
    end;

    [Scope('Personalization')]
    procedure SaveHTML(OutputFileName: Text;HTMLText: Text)
    var
        OutStream: OutStream;
        OutputFile: File;
    begin
        OutputFile.WriteMode(true);
        OutputFile.Create(OutputFileName,TEXTENCODING::UTF8);
        OutputFile.CreateOutStream(OutStream);
        OutStream.Write(HTMLText,StrLen(HTMLText));
        OutputFile.Close;
    end;

    local procedure SliceSalesCoverLetterTemplate(var HTMLText: Text;var PaymentServicesSectionHTMLText: Text;var PaymentServiceRowHTMLText: Text;var SocialNetworksSectionHTMLText: Text;var SocialNetworkRowSectionHTMLText: Text)
    begin
        SliceSection(HTMLText,PaymentServicesSectionHTMLText,'PaymentSevicesSection','PaymentSevices');
        SliceSection(PaymentServicesSectionHTMLText,PaymentServiceRowHTMLText,'PaymentServiceRowSection','PaymentServicesRows');
        SliceSection(HTMLText,SocialNetworksSectionHTMLText,'SocialNetworksSection','SocialNetworks');
        SliceSection(SocialNetworksSectionHTMLText,SocialNetworkRowSectionHTMLText,'SocialNetworkRowSection','CoverLetterSocialRow');
    end;

    local procedure SliceSection(var HTMLText: Text;var SectionHTMLText: Text;SectionName: Text;SectionHolderName: Text)
    var
        StartPosition: Integer;
        EndPosition: Integer;
        StartSectionParameter: Text;
        EndSectionParameter: Text;
        SectionHolderParameter: Text;
    begin
        StartSectionParameter := MakeParameterNameString(StrSubstNo('%1.Start',SectionName));
        EndSectionParameter := MakeParameterNameString(StrSubstNo('%1.End',SectionName));
        SectionHolderParameter := MakeParameterNameString(SectionHolderName);

        StartPosition := StrPos(HTMLText,StartSectionParameter);
        EndPosition := StrPos(HTMLText,EndSectionParameter);

        SectionHTMLText :=
          CopyStr(
            HTMLText,
            StartPosition + StrLen(StartSectionParameter) + 1,
            EndPosition - StartPosition - StrLen(StartSectionParameter) - 1);

        HTMLText :=
          CopyStr(HTMLText,1,StartPosition - 1) +
          SectionHolderParameter +
          CopyStr(HTMLText,EndPosition + StrLen(EndSectionParameter));
    end;

    local procedure EncodeMessage(Message: Text;CarriageReturn: Boolean): Text
    var
        TypeHelper: Codeunit "Type Helper";
        String: DotNet String;
        NewLineChar: Char;
        CarriageReturnChar: Char;
    begin
        if Message = '' then
          exit('');

        String := TypeHelper.HtmlEncode(Message);

        NewLineChar := 10;
        CarriageReturnChar := 13;
        if CarriageReturn then
          exit(String.Replace(Format(CarriageReturnChar) + Format(NewLineChar),'<br />'));
        exit(String.Replace(Format(NewLineChar),'<br />'));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnResizeCompanyLogo(var TempBlob: Record TempBlob temporary)
    begin
    end;

    local procedure ResizePaymentServiceLogoIfNeeded(var TempBlob: Record TempBlob temporary)
    var
        TempLocalTempBlob: Record TempBlob temporary;
        ImageHandlerManagement: Codeunit "Image Handler Management";
        ImageWidth: Integer;
        ImageHeight: Integer;
        AdvisedImageHeightPixels: Integer;
    begin
        AdvisedImageHeightPixels := 35;

        TempLocalTempBlob.Copy(TempBlob);

        if ImageHandlerManagement.GetImageSizeBlob(TempLocalTempBlob,ImageWidth,ImageHeight) then
          if ImageHeight > AdvisedImageHeightPixels then
            if ImageHandlerManagement.ScaleDownFromBlob(TempLocalTempBlob,ImageWidth,AdvisedImageHeightPixels) then
              TempBlob.Copy(TempLocalTempBlob);
    end;
}

