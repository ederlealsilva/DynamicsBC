report 9170 "Copy Profile"
{
    // version NAVW111.00

    Caption = 'Copy Profile';
    ProcessingOnly = true;

    dataset
    {
        dataitem("All Profile";"All Profile")
        {
            DataItemTableView = SORTING("Profile ID");

            trigger OnAfterGetRecord()
            var
                ConfPersMgt: Codeunit "Conf./Personalization Mgt.";
            begin
                ConfPersMgt.CopyProfile("All Profile",NewProfileID,NewProfileScope);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NewProfileID;NewProfileID)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'New Profile ID';
                        NotBlank = true;
                        ToolTip = 'Specifies the new ID of the profile after copying.';
                    }
                    field(NewProfileScope;NewProfileScope)
                    {
                        ApplicationArea = Basic,Suite;
                        Caption = 'New Profile Scope';
                        Enabled = NOT IsSaaS;
                        ToolTip = 'Specifies the new scope of the profile after copying.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            PermissionManager: Codeunit "Permission Manager";
        begin
            IsSaaS := PermissionManager.SoftwareAsAService;

            if IsSaaS then
              NewProfileScope := NewProfileScope::Tenant;
        end;
    }

    labels
    {
    }

    var
        NewProfileID: Code[30];
        NewProfileScope: Option System,Tenant;
        [InDataSet]
        IsSaaS: Boolean;

    [Scope('Personalization')]
    procedure GetProfileID(): Code[30]
    begin
        exit(NewProfileID);
    end;
}

