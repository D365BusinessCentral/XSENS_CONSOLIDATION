report 50101 "Import Consolidation LT"
{
    Caption = 'Import Consolidation File';
    ProcessingOnly = true;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") WHERE("Account Type" = CONST(Posting));

            trigger OnAfterGetRecord()
            begin
                "Consol. Debit Acc." := "No.";
                "Consol. Credit Acc." := "No.";
                "Consol. Translation Method" := "Consol. Translation Method"::"Average Rate (Manual)";
                Consolidate.InsertGLAccount("G/L Account");
            end;

            trigger OnPostDataItem()
            var
                TempGLEntry: Record "G/L Entry" temporary;
                TempDimBuf: Record "Dimension Buffer" temporary;
            begin
                if FileFormat = FileFormat::"Version 4.00 or Later (.xml)" then
                    CurrReport.Break();
                Consolidate.SelectAllImportedDimensions;
            end;

            trigger OnPreDataItem()
            begin
                if FileFormat = FileFormat::"Version 4.00 or Later (.xml)" then
                    CurrReport.Break();
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
                    field(FileFormat; FileFormat)
                    {
                        ApplicationArea = Suite;
                        Caption = 'File Format';
                        OptionCaption = 'Version 4.00 or Later (.xml), Version 3.70 or Earlier (.txt)';
                        Editable = false;
                        ToolTip = 'Specifies the format of the file that you want to use for consolidation.';
                    }
                    field(FileNameControl; FileName)
                    {
                        ApplicationArea = Suite;
                        Caption = 'File Name';
                        ToolTip = 'Specifies the name of the file that you want to use for consolidation.';
                        Lookup = true;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            BlobLists: Record "Blob Storage Blob Lists";
                            BlobListsPage: Page "MME BlobStorage Blob List";
                        begin
                            RecCompanyInfo.GET;
                            RecCompanyInfo.TestField("Root Container");
                            Clear(BlobService);
                            BlobService.ListBlobs(RecCompanyInfo."Root Container");
                            Clear(BlobLists);
                            BlobLists.SetRange(Container, RecCompanyInfo."Root Container");
                            Clear(BlobListsPage);
                            BlobListsPage.SetTableView(BlobLists);
                            BlobListsPage.LookupMode(true);
                            Commit();
                            if BlobListsPage.RunModal() IN [Action::OK, Action::LookupOK] then begin
                                BlobListsPage.GetRecord(BlobLists);
                                FileName := BlobLists.Name;
                            end;
                        end;
                    }
                    field(GLDocNo; GLDocNo)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the document number to be used on all new ledger entries created from the consolidation.';
                    }
                }
            }
        }

        actions
        {
        }

#if not CLEAN17
        trigger OnInit()
        var
            ClientTypeMgt: Codeunit "Client Type Management";
        begin
            OnWebClient := ClientTypeMgt.GetCurrentClientType in [CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop];
        end;

        trigger OnOpenPage()
        var
            BlobLists: Record "Blob Storage Blob Lists";
            NoSeriesMgmt: Codeunit NoSeriesManagement;
        begin
            RecCompanyInfo.GET;
            RecCompanyInfo.TestField("Root Container");
            RecCompanyInfo.TestField("Import Consol. No. Series");
            Clear(BlobService);
            BlobService.ListBlobs(RecCompanyInfo."Root Container");
            Clear(BlobLists);
            BlobLists.SetRange(Container, RecCompanyInfo."Root Container");
            BlobLists.FindFirst();
            FileName := BlobLists.Name;
            GLDocNo := NoSeriesMgmt.GetNextNo(RecCompanyInfo."Import Consol. No. Series", WorkDate(), true);
        end;
#endif
    }



    trigger OnInitReport()
    begin
        RecCompanyInfo.GET;
    end;

    trigger OnPostReport()
    begin
        if FileFormat = FileFormat::"Version 3.70 or Earlier (.txt)" then
            Consolidate.SetGlobals(
              '', '', BusUnit."Company Name",
              SubsidCurrencyCode, AdditionalCurrencyCode, ParentCurrencyCode,
              0, ConsolidStartDate, ConsolidEndDate);
        Consolidate.UpdateGLEntryDimSetID;
        Consolidate.SetDocNo(GLDocNo);
        Consolidate.Run(BusUnit);

        //Moving from failed to success 
        Clear(BlobService);
        BlobService.PutBlob(RecCompanyInfo."Success Container", FileName, Instream);
        BlobService.DeleteBlob(RecCompanyInfo."Failed Container", FileName);
    end;

    trigger OnPreReport()
    var
        BusUnit2: Record "Business Unit";
        GLSetup: Record "General Ledger Setup";
        FileManagement: Codeunit "File Management";
        ConfirmManagement: Codeunit "Confirm Management";
        InStreamL: InStream;
    begin

        if GLDocNo = '' then
            Error(Text015);

        if FileFormat = FileFormat::"Version 4.00 or Later (.xml)" then begin
            RecCompanyInfo.GET;
            RecCompanyInfo.TestField("Root Container");
            RecCompanyInfo.TestField("Success Container");
            RecCompanyInfo.TestField("Failed Container");
            Clear(BlobService);
            BlobService.GetBlobIntoStream(RecCompanyInfo."Root Container", FileName, Instream);
            BlobService.GetBlobIntoStream(RecCompanyInfo."Root Container", FileName, InstreamL);
            BlobService.PutBlob(RecCompanyInfo."Failed Container", FileName, InstreamL);
            BlobService.DeleteBlob(RecCompanyInfo."Root Container", FileName);
            Consolidate.ImportFromXML(Instream);
            Consolidate.GetGlobals(
              ProductVersion, FormatVersion, BusUnit."Company Name",
              SubsidCurrencyCode, AdditionalCurrencyCode, ParentCurrencyCode,
              CheckSum, ConsolidStartDate, ConsolidEndDate);
            CalculatedCheckSum := Consolidate.CalcCheckSum;
            if CheckSum <> CalculatedCheckSum then
                Error(Text036, CheckSum, CalculatedCheckSum);
            TransferPerDay := true;
        end;

        if (BusUnit."Company Name" = '') or (ConsolidStartDate = 0D) or (ConsolidEndDate = 0D) then
            Error(Text001);

        if not ConfirmManagement.GetResponseOrDefault(
             StrSubstNo(Text023, ConsolidStartDate, ConsolidEndDate), true)
        then
            CurrReport.Quit;

        BusUnit.SetCurrentKey("Company Name");
        BusUnit.SetRange("Company Name", BusUnit."Company Name");
        BusUnit.Find('-');
        if BusUnit.Next <> 0 then
            Error(
              Text005 +
              Text006,
              BusUnit.FieldCaption("Company Name"), BusUnit."Company Name");
        BusUnit.TestField(Consolidate, true);

        BusUnit2."File Format" := FileFormat;
        if BusUnit."File Format" <> FileFormat then
            if not ConfirmManagement.GetResponseOrDefault(
                 StrSubstNo(
                   FileFormatQst, BusUnit.FieldCaption("File Format"), BusUnit2."File Format",
                   BusUnit.TableCaption, BusUnit."File Format"), true)
            then
                CurrReport.Quit;

        if FileFormat = FileFormat::"Version 4.00 or Later (.xml)" then begin
            if SubsidCurrencyCode = '' then
                SubsidCurrencyCode := BusUnit."Currency Code";
            GLSetup.Get();
            if (SubsidCurrencyCode <> BusUnit."Currency Code") and
               (SubsidCurrencyCode <> GLSetup."LCY Code") and
               not ((BusUnit."Currency Code" = '') and (GLSetup."LCY Code" = ''))
            then
                Error(
                  Text002,
                  BusUnit.FieldCaption("Currency Code"), SubsidCurrencyCode,
                  BusUnit.TableCaption, BusUnit."Currency Code");
        end else begin
            SubsidCurrencyCode := BusUnit."Currency Code";
            Window.Open(
              '#1###############################\\' +
              Text024 +
              Text025 +
              Text026);
            Window.Update(1, Text027);
            Window.Update(2, BusUnit.Code);
            Window.Update(3, '');
        end;
    end;

    var
        Text000: Label 'Enter the file name.';
        Text001: Label 'The file to be imported has an unknown format.';
        Text002: Label 'The %1 in the file to be imported (%2) does not match the %1 in the %3 (%4).';
        Text005: Label 'The business unit %1 %2 is not unique.\\';
        Text006: Label 'Delete %1 in the extra records.';
        Text015: Label 'Enter a document number.';
        Text023: Label 'Do you want to consolidate in the period from %1 to %2?';
        Text024: Label 'Business Unit Code   #2##########\';
        Text025: Label 'G/L Account No.      #3##########\';
        Text026: Label 'Date                 #4######';
        Text027: Label 'Reading File...';
        Text031: Label 'Import from File';
        BusUnit: Record "Business Unit";
        Consolidate: Codeunit Consolidate_LT; //Consolidate;
        Window: Dialog;
        GLEntryFile: File;
        FileName: Text;
        FilePath: Text;
        FileFormat: Option "Version 4.00 or Later (.xml)","Version 3.70 or Earlier (.txt)";
        TextLine: Text[250];
        GLDocNo: Code[20];
        ConsolidStartDate: Date;
        ConsolidEndDate: Date;
        TransferPerDay: Boolean;
        CheckSum: Decimal;
        CalculatedCheckSum: Decimal;
        ParentCurrencyCode: Code[10];
        SubsidCurrencyCode: Code[10];
        AdditionalCurrencyCode: Code[10];
        ProductVersion: Code[10];
        FormatVersion: Code[10];
        Text036: Label 'Imported checksum (%1) does not equal the calculated checksum (%2). The file may be corrupt.';
        ServerFileName: Text;
#if not CLEAN17
        [InDataSet]
        OnWebClient: Boolean;
#endif
        FileFormatQst: Label 'The entered %1, %2, does not equal the %1 on this %3, %4.\Do you want to continue?', Comment = '%1 - field caption, %2 - field value, %3 - table captoin, %4 - field value';
        RecCompanyInfo: Record "Company Information";
        BlobService: Codeunit "Blob Service API";
        Instream: InStream;

    procedure InitializeRequest(NewFileFormat: Option; NewFilePath: Text; NewGLDocNo: Code[20])
    begin
        FileFormat := NewFileFormat;
        FilePath := NewFilePath;
        FileName := GetFileName(FilePath);
        GLDocNo := NewGLDocNo;
    end;

    local procedure GetFileName(FilePath: Text): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        exit(FileManagement.GetFileName(FilePath));
    end;
}

