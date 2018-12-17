xmlport 9170 "Profile Import/Export"
{
    // version NAVW111.00

    Caption = 'Profile Import/Export';
    Encoding = UTF8;
    FormatEvaluate = Xml;

    schema
    {
        textelement(Profiles)
        {
            tableelement(Profile;Profile)
            {
                XmlName = 'Profile';
                fieldattribute(ID;Profile."Profile ID")
                {
                }
                fieldattribute(Description;Profile.Description)
                {
                }
                fieldattribute(RoleCenterID;Profile."Role Center ID")
                {
                }
                fieldattribute(DefaultRoleCenter;Profile."Default Role Center")
                {

                    trigger OnAfterAssignField()
                    var
                        Profile2: Record "Profile";
                    begin
                        if Profile."Default Role Center" then begin
                          Profile2.SetRange("Default Role Center",true);
                          if not Profile2.IsEmpty then
                            Profile."Default Role Center" := false;
                        end;
                    end;
                }
                tableelement("Profile Metadata";"Profile Metadata")
                {
                    LinkFields = "Profile ID"=FIELD("Profile ID");
                    LinkTable = "Profile";
                    MinOccurs = Zero;
                    XmlName = 'ProfileMetadata';
                    fieldattribute(ProfileID;"Profile Metadata"."Profile ID")
                    {
                    }
                    fieldattribute(PageID;"Profile Metadata"."Page ID")
                    {
                    }
                    fieldattribute(PersonalizationID;"Profile Metadata"."Personalization ID")
                    {
                    }
                    textelement(PageMetadata)
                    {
                        TextType = BigText;

                        trigger OnBeforePassVariable()
                        var
                            MetadataInStream: InStream;
                            XDoc: DotNet XDocument;
                        begin
                            Clear(PageMetadata);
                            "Profile Metadata".CalcFields("Page Metadata Delta");

                            if "Profile Metadata"."Page Metadata Delta".HasValue then begin
                              "Profile Metadata"."Page Metadata Delta".CreateInStream(MetadataInStream,TEXTENCODING::UTF8);
                              XDoc := XDoc.Load(MetadataInStream);
                              PageMetadata.AddText(XmlDeltaHeaderTxt + XDoc.ToString);
                            end;
                        end;

                        trigger OnAfterAssignVariable()
                        var
                            MetadataOutStream: OutStream;
                        begin
                            if PageMetadata.Length > 0 then begin
                              "Profile Metadata"."Page Metadata Delta".CreateOutStream(MetadataOutStream,TEXTENCODING::UTF8);
                              PageMetadata.Write(MetadataOutStream);
                            end;
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    var
        XmlDeltaHeaderTxt: Label '<?xml version="1.0"?>', Locked=true;
}

