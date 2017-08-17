//-----------------------------------------------------------------------
// <copyright file="ContentLinkDefinition.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

#load "ContentHash.csx"

using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class ContentLinkDefinition
{
    [JsonProperty(Required = Required.Always)]
    public Uri Uri { get; set; }

    public string ContentVersion { get; set; }

    public long? ContentSize { get; set; }

    public ContentHash ContentHash { get; set; }

    public JToken Metadata { get; set; }
}