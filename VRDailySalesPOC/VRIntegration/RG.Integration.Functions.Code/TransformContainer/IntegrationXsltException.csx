//-----------------------------------------------------------------------
// <copyright file="IntegrationXsltException.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

using System;
using System.Net;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1032:ImplementStandardExceptionConstructors", Justification = "Not needed.")]
[System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2237:MarkISerializableTypesWithSerializable", Justification = "Not needed.")]
public class IntegrationXsltException : Exception
{
    public IntegrationXsltException()
    {
    }

    public IntegrationXsltException(string message) : base(message, null)
    {
        this.StatusCode = HttpStatusCode.InternalServerError;
    }

    public IntegrationXsltException(HttpStatusCode statusCode, string message)
        : base(message)
    {
        this.StatusCode = statusCode;
    }

    public IntegrationXsltException(HttpStatusCode statusCode, string message, Exception innerException)
        : base(message, innerException)
    {
        this.StatusCode = statusCode;
    }

    public HttpStatusCode StatusCode { get; set; }
}