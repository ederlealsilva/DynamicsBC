page 9813 Devices
{
    // version NAVW113.00

    ApplicationArea = Basic,Suite;
    Caption = 'Devices';
    CardPageID = "Device Card";
    DelayedInsert = true;
    PageType = List;
    SourceTable = Device;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("MAC Address";"MAC Address")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the MAC Address for the device. MAC is an acronym for Media Access Control. A MAC Address is a unique identifier that is assigned to network interfaces for communications.';
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies a name for the device.';
                }
                field("Device Type";"Device Type")
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the device type.';
                }
                field(Enabled;Enabled)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies whether the device is enabled.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control8;Notes)
            {
            }
            systempart(Control9;Links)
            {
            }
        }
    }

    actions
    {
    }
}

