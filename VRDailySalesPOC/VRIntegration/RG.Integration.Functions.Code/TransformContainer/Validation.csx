//-----------------------------------------------------------------------
// <copyright file="Validation.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

using System.Globalization;
using System.Net;

public static class Validation
{
    public static void XslTransformRequest(XsltInput xsltInput)
    {
        if (xsltInput == null || xsltInput.Content == null)
        {
            throw new IntegrationXsltException(
                statusCode: HttpStatusCode.BadRequest,
                message: "The provided xml content to transform is null or empty.");
        }

        if (xsltInput.MapContentLink == null)
        {
            throw new IntegrationXsltException(
                statusCode: HttpStatusCode.BadRequest,
                message: "The provided content link for the map is null or empty.");
        }

        if (xsltInput.MapContentLink.Uri == null)
        {
            throw new IntegrationXsltException(
                statusCode: HttpStatusCode.BadRequest,
                message: "The provided uri in the content link for the map is null or empty.");
        }

        if (!xsltInput.MapContentLink.Uri.IsAbsoluteUri)
        {
            throw new IntegrationXsltException(
                statusCode: HttpStatusCode.BadRequest,
                message: string.Format(CultureInfo.InvariantCulture, "The provided uri '{0}' in the content link for the map is not a valid uri.", xsltInput.MapContentLink.Uri));
        }
    }
}
