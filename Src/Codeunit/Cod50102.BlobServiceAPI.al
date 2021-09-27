codeunit 50102 "Blob Service API"
{
    procedure ListContainers(): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        Reccontainers: Record "Blob Storage Containers";
        client: HttpClient;
        response: HttpResponseMessage;
        xmlContent: Text;
        xmlDoc: XmlDocument;
        root: XmlElement;
        nodes: XmlNodeList;
        node: XmlNode;
        i: Integer;
    begin
        blobStorageAccount.GET;
        //GET https://<accountname>.blob.core.windows.net/?comp=list&<sastoken>
        if not client.Get(StrSubstNo('%1?comp=list&%2', blobStorageAccount."Account Url", blobStorageAccount."SaS Token"), response) then begin
            Error(response.ReasonPhrase);
            exit(false);
        end;
        if response.HttpStatusCode <> 200 then
            Error(response.ReasonPhrase);

        response.Content().ReadAs(xmlContent);
        XmlDocument.ReadFrom(xmlContent, xmlDoc);
        xmlDoc.GetRoot(root);
        root.WriteTo(xmlContent);
        root.SelectNodes('/*/Containers/Container/Name', nodes);
        for i := 1 to nodes.Count() do begin
            nodes.Get(i, node);
            Clear(Reccontainers);
            Reccontainers.SetRange(Name, node.AsXmlElement().InnerText());
            if not Reccontainers.FindFirst() then begin
                Reccontainers.Init();
                Reccontainers.Name := node.AsXmlElement().InnerText();
                Reccontainers.Insert();
            end;
            if root.SelectSingleNode(StrSubstNo('/*/Containers/Container[%1]/Properties/Last-Modified', i), node) then
                Reccontainers."Last Modified" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Containers/Container[%1]/Properties/LeaseStatus', i), node) then
                Reccontainers."Lease Status" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Containers/Container[%1]/Properties/LeaseState', i), node) then
                Reccontainers."Lease State" := node.AsXmlElement().InnerText();
            Reccontainers.Modify();
        end;
        exit(true);
    end;

    procedure ListBlobs(containerName: Text): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        Recblobs: Record "Blob Storage Blob Lists";
        client: HttpClient;
        response: HttpResponseMessage;
        xmlContent: Text;
        xmlDoc: XmlDocument;
        root: XmlElement;
        nodes: XmlNodeList;
        node: XmlNode;
        i: Integer;
        len: Integer;
    begin
        blobStorageAccount.GET;
        //GET https://<accountname>.blob.core.windows.net/<container>?restype=container&comp=list&<sastoken>
        if not client.Get(StrSubstNo('%1/%2?restype=container&comp=list&%3', blobStorageAccount."Account Url", containerName, blobStorageAccount."SaS Token"), response) then begin
            Error(response.ReasonPhrase);
            exit(false);
        end;
        if response.HttpStatusCode <> 200 then
            Error(response.ReasonPhrase);
        response.Content().ReadAs(xmlContent);
        XmlDocument.ReadFrom(xmlContent, xmlDoc);
        xmlDoc.GetRoot(root);
        root.WriteTo(xmlContent);

        Clear(Recblobs);
        Recblobs.SetRange(Container, containerName);
        if Recblobs.FindSet() then
            Recblobs.DeleteAll(true);
        root.SelectNodes('/*/Blobs/Blob/Name', nodes);
        for i := 1 to nodes.Count() do begin
            nodes.Get(i, node);
            Clear(Recblobs);
            Recblobs.SetRange(Container, containerName);
            Recblobs.SetRange(Name, node.AsXmlElement().InnerText());
            if not Recblobs.FindFirst() then begin
                Recblobs.Init();
                Recblobs.Container := containerName;
                Recblobs.Name := node.AsXmlElement().InnerText();
                Recblobs.Insert();
            end;


            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/Last-Modified', i), node) then
                Recblobs."Last Modified" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/LeaseStatus', i), node) then
                Recblobs."Lease Status" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/LeaseState', i), node) then
                Recblobs."Lease State" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/Creation-Time', i), node) then
                Recblobs."Creation Time" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/BlobType', i), node) then
                Recblobs."Blob Type" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/Content-Type', i), node) then
                Recblobs."Content Type" := node.AsXmlElement().InnerText();
            if root.SelectSingleNode(StrSubstNo('/*/Blobs/Blob[%1]/Properties/Content-Length', i), node) then
                if Evaluate(len, node.AsXmlElement().InnerText()) then
                    Recblobs."Content Length" := len;
            Recblobs.Modify();
        end;
        exit(true);
    end;

    procedure GetBlob(containerName: Text; blobName: Text; var text: Text): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        client: HttpClient;
        response: HttpResponseMessage;
    begin
        blobStorageAccount.GET;
        if not client.Get(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"), response) then begin
            Error(response.ReasonPhrase);
            exit(false);
        end;
        if response.HttpStatusCode <> 200 then
            Error(response.ReasonPhrase);
        exit(response.Content().ReadAs(text));
    end;

    procedure GetBlobIntoStream(containerName: Text; blobName: Text; var Instream: InStream): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        client: HttpClient;
        response: HttpResponseMessage;
    begin
        blobStorageAccount.GET;
        if not client.Get(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"), response) then begin
            Error(response.ReasonPhrase);
            exit(false);
        end;
        if response.HttpStatusCode <> 200 then
            Error(response.ReasonPhrase);
        exit(response.Content().ReadAs(Instream));
    end;

    procedure GetBlob(containerName: Text; blobName: Text; var stream: InStream): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        client: HttpClient;
        response: HttpResponseMessage;
    begin
        blobStorageAccount.GET;
        if not client.Get(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"), response) then begin
            Error(response.ReasonPhrase);
            exit(false);
        end;
        if response.HttpStatusCode <> 200 then
            Error(response.ReasonPhrase);
        exit(response.Content().ReadAs(stream))
    end;

    procedure PutBlob(containerName: Text; blobName: Text; var text: Text): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        memoryStream: Codeunit "MemoryStream Wrapper";
        client: HttpClient;
        response: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        len: Integer;
    begin
        blobStorageAccount.GET;
        // Write the test into HTTP Content and change the needed Header Information 
        content.WriteFrom(text);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/octet-stream');
        headers.Add('Content-Length', StrSubstNo('%1', StrLen(text)));
        headers.Add('x-ms-blob-type', 'BlockBlob');

        //PUT https://<accountname>.blob.core.windows.net/<container>/<blob>?<sastoken>
        exit(client.Put(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"), content, response));
    end;

    procedure PutBlob(containerName: Text; blobName: Text; var stream: InStream): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        memoryStream: Codeunit "MemoryStream Wrapper";
        client: HttpClient;
        response: HttpResponseMessage;
        content: HttpContent;
        headers: HttpHeaders;
        len: Integer;
    begin
        blobStorageAccount.GET;
        client.SetBaseAddress(blobStorageAccount."Account Url");

        // Load the memory stream and get the size
        memoryStream.Create(0);
        memoryStream.ReadFrom(stream);
        len := memoryStream.Length();
        memoryStream.SetPosition(0);
        memoryStream.GetInStream(stream);

        // Write the Stream into HTTP Content and change the needed Header Information 
        content.WriteFrom(stream);
        content.GetHeaders(headers);
        headers.Remove('Content-Type');
        headers.Add('Content-Type', 'application/octet-stream');
        headers.Add('Content-Length', StrSubstNo('%1', len));
        headers.Add('x-ms-blob-type', 'BlockBlob');

        //PUT https://<accountname>.blob.core.windows.net/<container>/<blob>?<sastoken>
        exit(client.Put(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"), content, response));
    end;

    procedure GetBlobUrl(containerName: Text; blobName: Text): Text
    var
        blobStorageAccount: Record "Blob Storage Account";
    begin
        blobStorageAccount.GET;
        exit(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"));
    end;

    procedure DeleteBlob(containerName: Text; blobName: Text): Boolean
    var
        blobStorageAccount: Record "Blob Storage Account";
        client: HttpClient;
        response: HttpResponseMessage;
    begin
        blobStorageAccount.GET;
        if not client.Delete(StrSubstNo('%1/%2/%3?%4', blobStorageAccount."Account Url", containerName, blobName, blobStorageAccount."SaS Token"), response) then
            Error(response.ReasonPhrase)
        else
            exit(true);
    end;

    var
        export: Report "Export Consolidation";
        importFromFile: Report "Import Consolidation from File";
        ImportFromDB: Report "Import Consolidation from DB";
        P: Page 241;
        akc: Report 10040;
}