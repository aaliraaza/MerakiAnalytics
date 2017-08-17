//-----------------------------------------------------------------------
// <copyright file="XsltInput.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

public class XsltInput
{
    public JToken Content { get; set; }

    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly", Justification = "By design")]
    public IDictionary<string, string> XsltParameters { get; set; }

    public ContentLinkDefinition MapContentLink { get; set; }
}