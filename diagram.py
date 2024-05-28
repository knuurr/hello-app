from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS
from diagrams.aws.database import RDS
from diagrams.aws.network import ALB, InternetGateway, NATGateway

with Diagram("Deployment", show=False):
    ig = InternetGateway('ig')

    lb = ALB("lb")



    with Cluster("VPC"):
        
        with Cluster("Private subnet"):
            workers = [
              ECS("worker1"),
              ECS("worker2"),
              ECS("worker3")
          ]

    ig >> lb >>  workers

