codeunit 5942 "ServContractQuote-Tmpl. Upd."
{
    // version NAVW17.00

    TableNo = "Service Contract Header";

    trigger OnRun()
    begin
        ContractTemplate.Reset;
        if not ContractTemplate.FindFirst then
          exit;

        TestField("Contract No.");

        if PAGE.RunModal(PAGE::"Service Contract Template List",ContractTemplate) = ACTION::LookupOK then begin
          ServContract := Rec;
          ServContract.Description := ContractTemplate.Description;
          ServContract.Validate("Contract Group Code",ContractTemplate."Contract Group Code");
          ServContract.Validate("Service Order Type",ContractTemplate."Service Order Type");
          ServContract.Validate("Service Period",ContractTemplate."Default Service Period");
          ServContract.Validate("Price Update Period",ContractTemplate."Price Update Period");
          ServContract.Validate("Response Time (Hours)",ContractTemplate."Default Response Time (Hours)");
          ServContract.Validate("Max. Labor Unit Price",ContractTemplate."Max. Labor Unit Price");
          ServContract.Validate("Invoice after Service",ContractTemplate."Invoice after Service");
          ServContract.Validate("Invoice Period",ContractTemplate."Invoice Period");
          ServContract.Validate("Price Inv. Increase Code",ContractTemplate."Price Inv. Increase Code");
          ServContract.Validate("Allow Unbalanced Amounts",ContractTemplate."Allow Unbalanced Amounts");
          ServContract.Validate("Contract Lines on Invoice",ContractTemplate."Contract Lines on Invoice");
          ServContract.Validate("Combine Invoices",ContractTemplate."Combine Invoices");
          ServContract.Validate("Automatic Credit Memos",ContractTemplate."Automatic Credit Memos");
          ServContract.Validate(Prepaid,ContractTemplate.Prepaid);
          ServContract.Validate("Serv. Contract Acc. Gr. Code",ContractTemplate."Serv. Contract Acc. Gr. Code");
          ServContract."Template No." := ContractTemplate."No.";

          ServContract.CreateDim(
            DATABASE::"Service Contract Template",ContractTemplate."No.",
            0,'',0,'',0,'',0,'');
          with ServContract do
            CreateDim(
              DATABASE::"Service Contract Template","Template No.",
              DATABASE::Customer,"Bill-to Customer No.",
              DATABASE::"Salesperson/Purchaser","Salesperson Code",
              DATABASE::"Responsibility Center","Responsibility Center",
              DATABASE::"Service Order Type","Service Order Type");

          ContractDisc.Reset;
          ContractDisc.SetRange("Contract Type",ServContract."Contract Type");
          ContractDisc.SetRange("Contract No.",ServContract."Contract No.");
          ContractDisc.DeleteAll;

          TemplateDisc.Reset;
          TemplateDisc.SetRange("Contract Type",TemplateDisc."Contract Type"::Template);
          TemplateDisc.SetRange("Contract No.",ContractTemplate."No.");
          if TemplateDisc.Find('-') then
            repeat
              ContractDisc := TemplateDisc;
              ContractDisc."Contract Type" := ServContract."Contract Type";
              ContractDisc."Contract No." := ServContract."Contract No.";
              ContractDisc.Insert;
            until TemplateDisc.Next = 0;

          Rec := ServContract;
        end;
    end;

    var
        ServContract: Record "Service Contract Header";
        ContractTemplate: Record "Service Contract Template";
        ContractDisc: Record "Contract/Service Discount";
        TemplateDisc: Record "Contract/Service Discount";
}

