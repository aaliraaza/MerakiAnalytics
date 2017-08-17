//-----------------------------------------------------------------------
// <copyright file="ContentEnvelope.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

using System;
using System.Net.Mime;
using System.Text;
using Newtonsoft.Json;

public class ContentEnvelope
{
    [JsonProperty(PropertyName = "$content-encoding", Required = Required.Default)]
    public string ContentEncoding { get; set; }

    [JsonProperty(PropertyName = "$content-type", Required = Required.Always)]
    public string ContentType { get; set; }

    [JsonProperty(PropertyName = "$content", Required = Required.Always)]
    public string Content { get; set; }

    public string DecodeAsString()
    {
        var contentType = new ContentType(this.ContentType);
        var encoding = contentType.CharSet != null ? Encoding.GetEncoding(contentType.CharSet) : Encoding.UTF8;

        return encoding.GetString(Convert.FromBase64String(this.Content));
    }

    public byte[] DecodeAsBytes()
    {
        return Convert.FromBase64String(this.Content);
    }
}