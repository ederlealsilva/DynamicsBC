codeunit 9750 "Web Service Management"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    procedure CreateWebService(ObjectType: Option;ObjectId: Integer;ObjectName: Text;Published: Boolean)
    var
        AllObj: Record AllObj;
        WebService: Record "Web Service";
        WebServiceName: Text;
    begin
        AllObj.Get(ObjectType,ObjectId);
        WebServiceName := GetWebServiceName(ObjectName,AllObj."Object Name");

        // If the web service already exists, modify it accoridingly, otherwise add it
        if WebService.Get(ObjectType,WebServiceName) then begin
          ModifyWebService(WebService,AllObj,WebServiceName,Published);
          WebService.Modify;
        end else begin
          WebService.Init;
          ModifyWebService(WebService,AllObj,WebServiceName,Published);
          WebService.Insert;
        end
    end;

    local procedure ModifyWebService(var WebService: Record "Web Service";AllObj: Record AllObj;WebServiceName: Text;Published: Boolean)
    begin
        WebService."Object Type" := AllObj."Object Type";
        WebService."Object ID" := AllObj."Object ID";
        WebService."Service Name" := CopyStr(WebServiceName,1,MaxStrLen(WebService."Service Name"));
        WebService.Published := Published;
    end;

    [Scope('Personalization')]
    procedure CreateTenantWebService(ObjectType: Option;ObjectId: Integer;ObjectName: Text;Published: Boolean)
    var
        AllObj: Record AllObj;
        TenantWebService: Record "Tenant Web Service";
        WebServiceName: Text;
    begin
        AllObj.Get(ObjectType,ObjectId);
        WebServiceName := GetWebServiceName(ObjectName,AllObj."Object Name");

        // If the web service already exists, modify it accoridingly, otherwise add it
        if TenantWebService.Get(ObjectType,WebServiceName) then begin
          ModifyTenantWebService(TenantWebService,AllObj,WebServiceName,Published);
          TenantWebService.Modify;
        end else begin
          TenantWebService.Init;
          ModifyTenantWebService(TenantWebService,AllObj,WebServiceName,Published);
          TenantWebService.Insert;
        end
    end;

    local procedure ModifyTenantWebService(var TenantWebService: Record "Tenant Web Service";AllObj: Record AllObj;WebServiceName: Text;Published: Boolean)
    begin
        TenantWebService."Object Type" := AllObj."Object Type";
        TenantWebService."Object ID" := AllObj."Object ID";
        TenantWebService."Service Name" := CopyStr(WebServiceName,1,MaxStrLen(TenantWebService."Service Name"));
        TenantWebService.Published := Published;
    end;

    local procedure GetWebServiceName(ServiceName: Text;ObjectName: Text): Text
    begin
        // If a name is not specified, the object's name will be used
        if ServiceName <> '' then
          exit(ServiceName);

        exit(DelChr(ObjectName,'=',' '));
    end;
}

