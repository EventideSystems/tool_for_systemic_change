import networkx as nx
import json

def lambda_handler(event, context):
    links = event['links']
    
    G = nx.Graph(links)
    G.add_edges_from(links)
    data = nx.betweenness_centrality(G)

    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
