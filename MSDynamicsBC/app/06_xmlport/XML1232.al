xmlport 1232 "Exp. Bank Data Conv. Serv.-CT"
{
    // version NAVW113.00

    Caption = 'Exp. Bank Data Conv. Serv.-CT';
    DefaultNamespace = 'http://nav02.soap.xml.link.amc.dk/';
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    Permissions = TableData "Data Exch."=r,
                  TableData "Data Exch. Field"=r,
                  TableData "Data Exch. Column Def"=r;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(paymentExportBank)
        {
            tableelement("Company Information";"Company Information")
            {
                MaxOccurs = Once;
                XmlName = 'amcpaymentreq';
                textelement(version)
                {
                    MaxOccurs = Once;
                }
                textelement(banktransjournal)
                {
                    textelement(bankagreementlevel1)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            bankagreementlevel1 := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    textelement(bankagreementlevel2)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            bankagreementlevel2 := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    textelement(edireceiverid)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            currXMLport.Skip;
                        end;
                    }
                    textelement(edireceivertype)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            currXMLport.Skip;
                        end;
                    }
                    textelement(edisenderid)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            currXMLport.Skip;
                        end;
                    }
                    textelement(edisendertype)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            currXMLport.Skip;
                        end;
                    }
                    textelement(erpsystem)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            erpsystem := DynamicsNAVTxt;
                        end;
                    }
                    textelement(journalname)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            journalname := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    textelement(journalnumber)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            journalnumber := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    fieldelement(legalregistrationnumber;"Company Information"."VAT Registration No.")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                    }
                    textelement(messageref)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            messageref := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    textelement(transmissionref1)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            transmissionref1 := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    textelement(transmissionref2)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            currXMLport.Skip;
                        end;
                    }
                    textelement(jnluniqueid)
                    {
                        XmlName = 'uniqueid';

                        trigger OnBeforePassVariable()
                        begin
                            JnlUniqueId := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                        end;
                    }
                    tableelement("Data Exch. Field";"Data Exch. Field")
                    {
                        XmlName = 'banktransus';
                        textelement(bankaccountcurrency)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable()
                            begin
                                bankaccountcurrency := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(countryoforigin)
                        {
                            MaxOccurs = Unbounded;
                            MinOccurs = Once;

                            trigger OnBeforePassVariable()
                            begin
                                countryoforigin := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(messagetoownbank)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable()
                            begin
                                messagetoownbank := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(ownreference)
                        {
                            MinOccurs = Zero;

                            trigger OnBeforePassVariable()
                            begin
                                ownreference := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(transusuniqueid)
                        {
                            XmlName = 'uniqueid';

                            trigger OnBeforePassVariable()
                            begin
                                TransUsUniqueId := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                            end;
                        }
                        textelement(banktransthem)
                        {
                            textelement(customerid)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    customerid := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(reference)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable()
                                begin
                                    reference := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(shortadvice)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable()
                                begin
                                    shortadvice := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(transthemuniqueid)
                            {
                                XmlName = 'uniqueid';

                                trigger OnBeforePassVariable()
                                begin
                                    TransThemUniqueId := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(regulatoryreporting)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(code)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        code := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(regrepdate)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'date';

                                    trigger OnBeforePassVariable()
                                    begin
                                        RegRepDate := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(regreptext)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'text';

                                    trigger OnBeforePassVariable()
                                    begin
                                        RegRepText := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                            textelement(receiversaddress)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(address1)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        address1 := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(address2)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        address2 := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(city)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        city := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(name)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        name := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(countryiso)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        countryiso := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverstate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'state';

                                    trigger OnBeforePassVariable()
                                    begin
                                        ReceiverState := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(zipcode)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        zipcode := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                            textelement(banktransspec)
                            {
                                MinOccurs = Zero;
                                textelement(cardref)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                }
                                textelement(cardtype)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                }
                                textelement(discountused)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                }
                                textelement(invoiceref)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        invoiceref := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(origamount)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        origamount := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(origdate)
                                {
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        origdate := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(otherref)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        currXMLport.Skip;
                                    end;
                                }
                                textelement(transspecuniqueid)
                                {
                                    XmlName = 'uniqueid';

                                    trigger OnBeforePassVariable()
                                    begin
                                        TransSpecUniqueId := Format(CreateGuid);
                                    end;
                                }
                                textelement(transspecamtdetails)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'amountdetails';
                                    textelement(transspecamtvalue)
                                    {
                                        XmlName = 'payamount';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TransSpecAmtValue := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(transspecamtcurrency)
                                    {
                                        XmlName = 'paycurrency';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TransSpecAmtCurrency := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(transspecamtdate)
                                    {
                                        XmlName = 'paydate';

                                        trigger OnBeforePassVariable()
                                        begin
                                            TransSpecAmtDate := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                }
                            }
                            textelement(emailadvice)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(recipient)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        recipient := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(subject)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;

                                    trigger OnBeforePassVariable()
                                    begin
                                        subject := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(emailpaymentmessage)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'paymentmessage';
                                    textelement(emaillinenum)
                                    {
                                        MaxOccurs = Once;
                                        MinOccurs = Zero;
                                        XmlName = 'linenum';

                                        trigger OnBeforePassVariable()
                                        begin
                                            EmailLineNum := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(emailtext)
                                    {
                                        MaxOccurs = Once;
                                        MinOccurs = Zero;
                                        XmlName = 'text';

                                        trigger OnBeforePassVariable()
                                        begin
                                            EmailText := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                }
                            }
                            textelement(paymentmessage)
                            {
                                MinOccurs = Zero;
                                textelement(pmtlinenum)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'linenum';

                                    trigger OnBeforePassVariable()
                                    begin
                                        PmtLineNum := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(pmtmsgtext)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'text';

                                    trigger OnBeforePassVariable()
                                    begin
                                        PmtMsgText := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                            textelement(chequeinfo)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(dispatchbranch)
                                {
                                    MinOccurs = Zero;
                                }
                                textelement(crossed)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                }
                                textelement(dispatch)
                                {
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    currXMLport.Skip;
                                end;
                            }
                            textelement(amountdetails)
                            {
                                MaxOccurs = Once;
                                textelement(amtvalue)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'payamount';

                                    trigger OnBeforePassVariable()
                                    begin
                                        AmtValue := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(amtcurrency)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'paycurrency';

                                    trigger OnBeforePassVariable()
                                    begin
                                        AmtCurrency := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(amtdate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'paydate';

                                    trigger OnBeforePassVariable()
                                    begin
                                        AmtDate := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                            textelement(correspondentbankaccount)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(correspbankaccount)
                                {
                                    XmlName = 'bankaccount';
                                }
                                textelement(correspintregno)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregno';
                                }
                                textelement(correspswiftcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'swiftcode';
                                }
                                textelement(correspintregnotype)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregnotype';
                                }
                                textelement(correspbankaccaddress)
                                {
                                    XmlName = 'bankaccountaddress';
                                    textelement(correspbankaddress1)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address1';
                                    }
                                    textelement(correspbankaddress2)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address2';
                                    }
                                    textelement(correspbankcity)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'city';
                                    }
                                    textelement(correspbankname)
                                    {
                                        XmlName = 'name';
                                    }
                                    textelement(correspbankctry)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'countryiso';
                                    }
                                    textelement(correspbankstate)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'state';
                                    }
                                    textelement(correspbankzipcode)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'zipcode';
                                    }
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    currXMLport.Skip;
                                end;
                            }
                            textelement(receiversbankaccount)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                textelement(receiverbankaccount)
                                {
                                    XmlName = 'bankaccount';

                                    trigger OnBeforePassVariable()
                                    begin
                                        ReceiverBankAccount := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverintregno)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregno';

                                    trigger OnBeforePassVariable()
                                    begin
                                        ReceiverIntRegNo := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverswiftcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'swiftcode';

                                    trigger OnBeforePassVariable()
                                    begin
                                        ReceiverSWIFTCode := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(receiverintregnotype)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'intregnotype';

                                    trigger OnBeforePassVariable()
                                    begin
                                        ReceiverIntRegNoType := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(recbankaccaddress)
                                {
                                    XmlName = 'bankaccountaddress';
                                    textelement(recbankaccaddress1)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address1';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccAddress1 := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccaddress2)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'address2';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccAddress2 := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankacccity)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'city';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccCity := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccname)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'name';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccName := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccctry)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'countryiso';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccCtry := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankaccstate)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'state';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccState := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                    textelement(recbankacczipcode)
                                    {
                                        MinOccurs = Zero;
                                        XmlName = 'zipcode';

                                        trigger OnBeforePassVariable()
                                        begin
                                            RecBankAccZipcode := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                        end;
                                    }
                                }
                            }
                            textelement(paymenttype)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    paymenttype := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(costs)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    costs := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(messagestructure)
                            {
                                MinOccurs = Zero;

                                trigger OnBeforePassVariable()
                                begin
                                    messagestructure := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                        }
                        textelement(bankaccountident)
                        {
                            textelement(senderbankaccount)
                            {
                                XmlName = 'bankaccount';

                                trigger OnBeforePassVariable()
                                begin
                                    SenderBankAccount := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(senderintregno)
                            {
                                MinOccurs = Zero;
                                XmlName = 'intregno';

                                trigger OnBeforePassVariable()
                                begin
                                    SenderIntRegNo := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(senderswiftcode)
                            {
                                MinOccurs = Zero;
                                XmlName = 'swiftcode';

                                trigger OnBeforePassVariable()
                                begin
                                    SenderSWIFTCode := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(senderintregnotype)
                            {
                                MinOccurs = Zero;
                                XmlName = 'intregnotype';

                                trigger OnBeforePassVariable()
                                begin
                                    SenderIntRegNoType := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                end;
                            }
                            textelement(bankaccountaddress)
                            {
                                textelement(bankaccaddress1)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'address1';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccAddress1 := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccaddress2)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'address2';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccAddress2 := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankacccity)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'city';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccCity := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccname)
                                {
                                    XmlName = 'name';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccName := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccctry)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'countryiso';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccCtry := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankaccstate)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'state';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccState := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                                textelement(bankacczipcode)
                                {
                                    MinOccurs = Zero;
                                    XmlName = 'zipcode';

                                    trigger OnBeforePassVariable()
                                    begin
                                        BankAccZipcode := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                                    end;
                                }
                            }
                        }
                        textelement(ownaddress)
                        {
                            fieldelement(address1;"Company Information".Address)
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(address2;"Company Information"."Address 2")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(city;"Company Information".City)
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(name;"Company Information".Name)
                            {
                            }
                            fieldelement(countryiso;"Company Information"."Country/Region Code")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(state;"Company Information".County)
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(zipcode;"Company Information"."Post Code")
                            {
                                MinOccurs = Zero;
                            }
                        }
                        textelement(ownaddressinfo)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                ownaddressinfo := GetValue("Data Exch. Field"."Data Exch. No.","Data Exch. Field"."Line No.");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if "Data Exch. Field"."Line No." <> CurrentLineNo then
                              CurrentLineNo := "Data Exch. Field"."Line No."
                            else
                              currXMLport.Skip;
                        end;
                    }

                    trigger OnBeforePassVariable()
                    begin
                        DataExchField.CopyFilters("Data Exch. Field");
                        if DataExchField.FindFirst then;
                    end;
                }
            }
            textelement(bank)
            {
                MaxOccurs = Once;

                trigger OnBeforePassVariable()
                begin
                    bank := GetValue(DataExchField."Data Exch. No.",DataExchField."Line No.");
                end;
            }
            textelement(language)
            {

                trigger OnBeforePassVariable()
                begin
                    language := GetLanguage;
                end;
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

    trigger OnPreXmlPort()
    begin
        InitializeGlobals;
    end;

    var
        DataExchField: Record "Data Exch. Field";
        DataExch: Record "Data Exch.";
        DataExchFieldDetails: Query "Data Exch. Field Details";
        DynamicsNAVTxt: Label 'Microsoft Dynamics 365 Business Central', Locked=true;
        DataExchEntryNo: Integer;
        CurrentLineNo: Integer;

    local procedure InitializeGlobals()
    begin
        DataExchEntryNo := "Data Exch. Field".GetRangeMin("Data Exch. No.");
        DataExch.Get(DataExchEntryNo);
        CurrentLineNo := 0;
    end;

    local procedure GetValue(DataExchNo: Integer;LineNo: Integer): Text
    begin
        DataExchFieldDetails.SetRange(Data_Exch_No,DataExchNo);
        DataExchFieldDetails.SetRange(Line_No,LineNo);
        DataExchFieldDetails.SetRange(Path,currXMLport.CurrentPath);
        DataExchFieldDetails.Open;
        if DataExchFieldDetails.Read then
          if DataExchFieldDetails.FieldValue <> '' then
            exit(DataExchFieldDetails.FieldValue);

        currXMLport.Skip;
    end;

    local procedure GetLanguage(): Text[3]
    var
        WindowsLanguage: Record "Windows Language";
    begin
        WindowsLanguage.Get(GlobalLanguage);
        exit(WindowsLanguage."Abbreviated Name");
    end;
}

