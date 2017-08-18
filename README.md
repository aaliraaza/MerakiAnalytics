# Cisco Meraki Location Analytics
Azure PaaS Implementation using Lambda Architecture of Cisco Meraki In-Store Location Analytics

## **Note:**
> This solution is not production ready as it requires security hardening and relevant scaling based on specific customer environments. 

## Use Case

This solution is a quick demonstration of the art of possible for any smart buildings, retail stores, universities, hospitals equipped with WAPs (Wireless Access Points) using Azure PaaS offering. It enables data ingestion omitted through user mobile devices into Azure Cloud via Meraki Cloud API for analytical purposes i.e. 

- Foot-Fall Analysis
- Staff Optimisation
- Store Layout Optimisation 
- Product Recommendation
- Many other advance use cases

Along the way you will also be exposed to a number of other Azure components, namely Event Hub, Stream Analytics, and Power BI. When everything is successfully deployed and running, the final result will be a PowerBI dashboard showing the following Line chart for real time footfall captured via user mobile devices and further Dashboard visualisations can be added after batch aggregation / analysis.

![dashboard](https://user-images.githubusercontent.com/31105197/29453710-7f8b1642-8402-11e7-9f3f-99b90d96c39c.png)

> **Note:** This solution is pre-configured with the Cisco Meraki settings but can be very easily tailored for other manufacturers. 

## Requirements

- Microsoft <a href="https://azure.microsoft.com/en-us/">Azure</a> subscription with login credentials
- <a href="https://powerbi.microsoft.com/">PowerBI</a> subscription with login credentials
- A local installation of <a href="https://azure.microsoft.com/en-us/documentation/articles/sql-data-warehouse-install-visual-studio/">Visual Studio 2015 with SQL Server Data Tools (SSDT)</a>
- Azure SDK
- Nuget Package installtion of "WindowsAzure.ServiceBus" & "WindowsAzure.Storage" from within Visual Studio 2015 -->Project-->Manage NuGet Packages menu option

# High Level Architecture

![merakidatavisiorevised](https://user-images.githubusercontent.com/31105197/29423338-3d5d95e0-8373-11e7-804c-316d3e005c94.jpg)

## Deploy

Below are the steps to deploy the use case into your Azure subscription.

**Clone or download the code from Github repositry and open the solution file in Visual Studio 2015. It will look like the following:
![solutionimage](https://user-images.githubusercontent.com/31105197/29456731-0c7034e6-840f-11e7-980d-82288bb99380.png)


