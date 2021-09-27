page 50102 "MME BlobStorage Blob List"
{
    PageType = List;
    SourceTable = "Blob Storage Blob Lists";
    Caption = 'Blob Storage Blob List';
    ApplicationArea = All;
    UsageCategory = Lists;
    InsertAllowed = false;
    DeleteAllowed = false;
    Editable = false;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Container; Rec.Container)
                {
                    ToolTip = 'Specifies the value of the Container field';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = All;
                }
                field("Blob Type"; Rec."Blob Type")
                {
                    ToolTip = 'Specifies the value of the Blob Type field';
                    ApplicationArea = All;
                }
                field("Content Length"; Rec."Content Length")
                {
                    ToolTip = 'Specifies the value of the Content Length field';
                    ApplicationArea = All;
                }
                field("Content Type"; Rec."Content Type")
                {
                    ToolTip = 'Specifies the value of the Content Type field';
                    ApplicationArea = All;
                }
                field("Creation Time"; Rec."Creation Time")
                {
                    ToolTip = 'Specifies the value of the Creation Time field';
                    ApplicationArea = All;
                }
                field("Last Modified"; Rec."Last Modified")
                {
                    ToolTip = 'Specifies the value of the Last Modified field';
                    ApplicationArea = All;
                }
                field("Lease State"; Rec."Lease State")
                {
                    ToolTip = 'Specifies the value of the Lease State field';
                    ApplicationArea = All;
                }
                field("Lease Status"; Rec."Lease Status")
                {
                    ToolTip = 'Specifies the value of the Lease Status field';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get List of Blobs")
            {
                ApplicationArea = All;
                Caption = 'Get List of Blobs';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Line;
                trigger OnAction()
                begin
                    ReloadBlobs();
                end;
            }
            action("Download File")
            {
                ApplicationArea = All;
                Image = MoveDown;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Download File';

                trigger OnAction()
                begin
                    DownloadFile()
                end;
            }

            action("Upload File")
            {
                ApplicationArea = All;
                Image = MoveUp;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Caption = 'Upload File';

                trigger OnAction()
                begin
                    UploadFile()
                end;
            }
            action("Delete File")
            {
                ApplicationArea = All;
                Image = Delete;
                trigger OnAction()
                var
                    blobServiceApi: Codeunit "Blob Service API";
                begin
                    if blobServiceApi.DeleteBlob(Rec.Container, Rec.Name) then begin
                        blobServiceApi.ListBlobs(Rec.Container);
                    end;
                end;
            }
        }
    }

    local procedure ReloadBlobs()
    var
        blobServiceApi: Codeunit "Blob Service API";
        Container: Record "Blob Storage Containers";
    begin
        Clear(Container);
        if Container.FindSet() then begin
            repeat
                blobServiceApi.ListBlobs(Container.Name);
            until Container.Next() = 0;
        end;
    end;

    local procedure UploadFile()
    var
        fileName: Text;
        stream: InStream;
        blogServiceAPI: Codeunit "Blob Service API";
    begin
        if UploadIntoStream('Upload File', '', '', fileName, stream) then
            if blogServiceAPI.PutBlob(Rec.Container, fileName, stream) then
                ReloadBlobs();
    end;

    local procedure DownloadFile()
    var
        fileName: Text;
        stream: InStream;
        blogServiceAPI: Codeunit "Blob Service API";
    begin
        Rec.TestField(Name);
        fileName := Rec.Name.Replace('/', '_');
        if blogServiceAPI.GetBlob(Rec.Container, Rec.Name, stream) then
            DownloadFromStream(stream, 'Download File', '', '', fileName);
    end;
}
