codeunit 1650 "Office Add-in Web Service"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    procedure DeployManifests(Username: Text[80];Password: Text[30]): Boolean
    var
        AddinDeploymentHelper: Codeunit "Add-in Deployment Helper";
    begin
        SetCredentialsAndDeploy(AddinDeploymentHelper,Username,Password);
        exit(true);
    end;

    procedure DeployManifestsWithExchangeEndpoint(Username: Text[80];Password: Text[30];Endpoint: Text[250]): Boolean
    var
        AddinDeploymentHelper: Codeunit "Add-in Deployment Helper";
    begin
        AddinDeploymentHelper.SetManifestDeploymentCustomEndpoint(Endpoint);
        SetCredentialsAndDeploy(AddinDeploymentHelper,Username,Password);
        exit(true);
    end;

    local procedure SetCredentialsAndDeploy(AddinDeploymentHelper: Codeunit "Add-in Deployment Helper";Username: Text[80];Password: Text[30])
    var
        OfficeAddIn: Record "Office Add-in";
    begin
        AddinDeploymentHelper.SetManifestDeploymentCredentials(Username,Password);
        if OfficeAddIn.Find('-') then
          repeat
            AddinDeploymentHelper.DeployManifest(OfficeAddIn);
          until OfficeAddIn.Next = 0;
    end;
}

