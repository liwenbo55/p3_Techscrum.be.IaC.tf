#####################################################################################
# Cloudwatch dashboard -- ECS dashboard (Metrics: CPU and Memory Utilization)
#####################################################################################
resource "aws_cloudwatch_dashboard" "ecs_dashboard"{
    dashboard_name = "${var.project_name}-ECS-Dashboard-${var.environment}"
    dashboard_body = jsonencode({
        "widgets": [
            {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 6,
            "properties": {
                "metrics": [
                    [
                        "AWS/ECS", 
                        "CPUUtilization", 
                        "ClusterName", "${var.ecs_cluster_name}", 
                        "ServiceName","${var.ecs_service_name}",
                        { "label": "CPUUtilization" } 
                    ],
                    [
                        "AWS/ECS", 
                        "MemoryUtilization", 
                        "ClusterName", "${var.ecs_cluster_name}", 
                        "ServiceName","${var.ecs_service_name}",
                        { "label": "MemoryUtilization" } 
                    ]
                ],
                "view": "timeSeries",
                "period": 300,
                "stat": "Average",
                "region":"ap-southeast-2",
                "title": "ECS Services"
            }
            }
        ]
    })
}