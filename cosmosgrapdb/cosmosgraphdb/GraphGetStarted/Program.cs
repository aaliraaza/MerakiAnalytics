namespace GraphGetStarted
{
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Linq;
    using System.Threading.Tasks;
    using Microsoft.Azure.Documents;
    using Microsoft.Azure.Documents.Client;
    using Microsoft.Azure.Documents.Linq;
    using Microsoft.Azure.Graphs;
    using Microsoft.Azure.Graphs.Elements;
    using Newtonsoft.Json;

    /// <summary>
    /// Sample program that shows how to get started with the Graph (Gremlin) APIs for Azure Cosmos DB.
    /// </summary>
    public class Program
    {
        /// <summary>
        /// Runs some Gremlin commands on the console.
        /// </summary>
        /// <param name="args">command-line arguments</param>
        public static void Main(string[] args)
        {
            string endpoint = ConfigurationManager.AppSettings["Endpoint"];
            string authKey = ConfigurationManager.AppSettings["AuthKey"];

            using (DocumentClient client = new DocumentClient(
                new Uri(endpoint),
                authKey,
                new ConnectionPolicy { ConnectionMode = ConnectionMode.Direct, ConnectionProtocol = Protocol.Tcp }))
            {
                Program p = new Program();
                p.RunAsync(client).Wait();
            }
        }

        /// <summary>
        /// Run the get started application.
        /// </summary>
        /// <param name="client">The DocumentDB client instance</param>
        /// <returns>A Task for asynchronous execuion.</returns>
        public async Task RunAsync(DocumentClient client)
        {
            Database database = await client.CreateDatabaseIfNotExistsAsync(new Database { Id = "Graphtestdb" });

            DocumentCollection graph = await client.CreateDocumentCollectionIfNotExistsAsync(
                UriFactory.CreateDatabaseUri("Graphtestdb"),
                new DocumentCollection { Id = "Friends" },
                new RequestOptions { OfferThroughput = 1000 });

            // Azure Cosmos DB supports the Gremlin API for working with Graphs. Gremlin is a functional programming language composed of steps.
            // Here, we run a series of Gremlin queries to show how you can add vertices, edges, modify properties, perform queries and traversals
            // For additional details, see https://aka.ms/gremlin for the complete list of supported Gremlin operators
            Dictionary<string, string> gremlinQueries = new Dictionary<string, string>
            {
                { "Cleanup",        "g.V().drop()" },
                { "AddVertex 1",    "g.addV('person').property('id', 'thomas').property('firstName', 'Thomas').property('age', 44)" },
                { "AddVertex 2",    "g.addV('person').property('id', 'mary').property('firstName', 'Mary').property('lastName', 'Andersen').property('age', 39)" },
                { "AddVertex 3",    "g.addV('person').property('id', 'ben').property('firstName', 'Ben').property('lastName', 'Miller')" },
                { "AddVertex 4",    "g.addV('person').property('id', 'robin').property('firstName', 'Robin').property('lastName', 'Wakefield')" },
                { "AddEdge 1",      "g.V('thomas').addE('knows').to(g.V('mary'))" },
                { "AddEdge 2",      "g.V('thomas').addE('knows').to(g.V('ben'))" },
                { "AddEdge 3",      "g.V('ben').addE('knows').to(g.V('robin'))" },
                { "UpdateVertex",   "g.V('thomas').property('age', 44)" },
                { "CountVertices",  "g.V().count()" },
                { "Filter Range",   "g.V().hasLabel('person').has('age', gt(40))" },
                { "Project",        "g.V().hasLabel('person').values('firstName')" },
                { "Sort",           "g.V().hasLabel('person').order().by('firstName', decr)" },
                { "Traverse",       "g.V('thomas').outE('knows').inV().hasLabel('person')" },
                { "Traverse 2x",    "g.V('thomas').outE('knows').inV().hasLabel('person').outE('knows').inV().hasLabel('person')" },
                { "Loop",           "g.V('thomas').repeat(out()).until(has('id', 'robin')).path()" },
                { "DropEdge",       "g.V('thomas').outE('knows').where(inV().has('id', 'mary')).drop()" },
                { "CountEdges",     "g.E().count()" },
                { "DropVertex",     "g.V('thomas').drop()" },
            };

            foreach (KeyValuePair<string, string> gremlinQuery in gremlinQueries)
            {
                Console.WriteLine($"Running {gremlinQuery.Key}: {gremlinQuery.Value}");

                // The CreateGremlinQuery method extensions allow you to execute Gremlin queries and iterate
                // results asychronously
                IDocumentQuery<dynamic> query = client.CreateGremlinQuery<dynamic>(graph, gremlinQuery.Value);
                while (query.HasMoreResults)
                {
                    foreach (dynamic result in await query.ExecuteNextAsync())
                    {
                        Console.WriteLine($"\t {JsonConvert.SerializeObject(result)}");
                    }
                }

                Console.WriteLine();
            }

            // Data is returned in GraphSON format, which be deserialized into a strongly-typed vertex, edge or property class
            // The following snippet shows how to do this
            string gremlin = gremlinQueries["AddVertex 1"];
            Console.WriteLine($"Running Add Vertex with deserialization: {gremlin}");

            IDocumentQuery<Vertex> insertVertex = client.CreateGremlinQuery<Vertex>(graph, gremlinQueries["AddVertex 1"]);
            while (insertVertex.HasMoreResults)
            {
                foreach (Vertex vertex in await insertVertex.ExecuteNextAsync<Vertex>())
                {
                    // Since Gremlin is designed for multi-valued properties, the format returns an array. Here we just read
                    // the first value
                    string name = (string)vertex.GetVertexProperties("firstName").First().Value;
                    Console.WriteLine($"\t Id:{vertex.Id}, Name: {name}");
                }
            }

            Console.WriteLine();

            Console.WriteLine("Done. Press any key to exit...");
            Console.ReadLine();
        }
    }
}
