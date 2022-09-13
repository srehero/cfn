package Apps

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
	"github.com/srehero/cfn/schemas/EC2"
	"github.com/srehero/cfn/schemas/ECS"
	ELB "github.com/srehero/cfn/schemas/ElasticLoadBalancingV2"
	"github.com/srehero/cfn/schemas/IAM"
	"github.com/srehero/cfn/schemas/Logs"
	"github.com/srehero/cfn/schemas/Route53"
)

let Fn = {[=~"^Fn::|Ref"]: string | [...] | {...}}
let Fnable = string | Fn

#Fargate: CloudFormation.#Template & {
	#Stack: {
		App: {
			Name: string
			Port: int
		}

		Cluster: {
			Name: Fnable
		}

		DNS: {
			Name:           Fnable
			HostedZoneName: Fnable
		}

		LoadBalancer: {
			DNSName:      Fnable
			HostedZoneId: Fnable
			HTTPSListener: {
				Arn:      Fnable
				Priority: int
			}
			SecurityGroupId: Fnable
		}

		Service: {
			ReplicaCount: int
			Subnets:      Fnable | [...Fnable]
			VpcId:        Fnable
		}

		TaskDefinition: {
			Cpu:                  string
			EnvironmentFileS3Arn: Fnable
			ExecutionRole: {
				ManagedPolicyArns: [...Fnable] | *[]
			}
			HealthCheck: {
				Command: string | [...string]
			}
			Image:  Fnable
			Memory: string
			TaskRole: {
				ManagedPolicyArns: [...Fnable] | *[]
			}
		}
	}

	Resources: {
		ExecutionRole: IAM.#Role & {
			Properties: {
				AssumeRolePolicyDocument: IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Principal: Service: "ecs-tasks.amazonaws.com"
						Action: "sts:AssumeRole"
					}]
				}
				ManagedPolicyArns: [
							"arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
				] + #Stack.TaskDefinition.ExecutionRole.ManagedPolicyArns
				RoleName: "Fn::Sub": "${AWS::StackName}-ExecutionRole"
			}
		}

		LogGroup: Logs.#LogGroup & {
			Properties: {
				LogGroupName: Ref: "AWS::StackName"
			}
		}

		RecordSet: Route53.#RecordSet & {
			Properties: {
				AliasTarget: {
					DNSName:      #Stack.LoadBalancer.DNSName
					HostedZoneId: #Stack.LoadBalancer.HostedZoneId
				}
				Name:           #Stack.DNS.Name
				HostedZoneName: #Stack.DNS.HostedZoneName
				Type:           "A"
			}
		}

		HTTPSListenerRule: ELB.#ListenerRule & {
			Properties: {
				Actions: [{
					TargetGroupArn: Ref: "TargetGroup"
					Type: "forward"
				}]
				Conditions: [{
					Field: "host-header"
					Values: [
						#Stack.DNS.Name,
					]
				}]
				ListenerArn: #Stack.LoadBalancer.HTTPSListener.Arn
				Priority:    #Stack.LoadBalancer.HTTPSListener.Priority
			}
		}

		TargetGroup: ELB.#TargetGroup & {
			Properties: {
				HealthCheckIntervalSeconds: 10
				HealthCheckPath:            "/health"
				HealthCheckProtocol:        "HTTP"
				HealthCheckTimeoutSeconds:  5
				HealthyThresholdCount:      3
				UnhealthyThresholdCount:    3
				Port:                       #Stack.App.Port
				Protocol:                   "HTTP"
				ProtocolVersion:            "HTTP1"
				TargetGroupAttributes: [{
					Key:   "deregistration_delay.timeout_seconds"
					Value: "30"
				}]
				TargetType: "ip"
				VpcId:      #Stack.Service.VpcId
			}
		}

		Service: ECS.#Service & {
			DependsOn: "HTTPSListenerRule"
			Properties: {
				Cluster:              #Stack.Cluster.Name
				DesiredCount:         #Stack.Service.ReplicaCount
				EnableECSManagedTags: true
				EnableExecuteCommand: true
				LaunchType:           "FARGATE"
				LoadBalancers: [{
					ContainerName: #Stack.App.Name
					ContainerPort: #Stack.App.Port
					TargetGroupArn: Ref: "TargetGroup"
				}]
				NetworkConfiguration: AwsvpcConfiguration: {
					AssignPublicIp: "DISABLED"
					SecurityGroups: [{Ref: "ServiceSecurityGroup"}]
					Subnets: #Stack.Service.Subnets
				}
				ServiceName: #Stack.App.Name
				TaskDefinition: Ref: "TaskDefinition"
			}
		}

		ServiceSecurityGroup: EC2.#SecurityGroup & {
			Properties: {
				GroupDescription: Ref: "AWS::StackName"
				VpcId: #Stack.Service.VpcId
			}
		}

		LoadBalancerIngress: EC2.#SecurityGroupIngress & {
			Properties: {
				GroupId: "Fn::GetAtt": "ServiceSecurityGroup.GroupId"
				SourceSecurityGroupId: #Stack.LoadBalancer.SecurityGroupId
				FromPort:              #Stack.App.Port
				ToPort:                #Stack.App.Port
				IpProtocol:            "tcp"
			}
		}

		TaskDefinition: ECS.#TaskDefinition & {
			Properties: {
				Cpu: #Stack.TaskDefinition.Cpu
				ContainerDefinitions: [{
					EnvironmentFiles: [{
						Type:  "s3"
						Value: #Stack.TaskDefinition.EnvironmentFileS3Arn
					}]
					HealthCheck: {
						Command:  #Stack.TaskDefinition.HealthCheck.Command
						Interval: 10
						Retries:  3
						Timeout:  5
					}
					Image: #Stack.TaskDefinition.Image
					LogConfiguration: {
						LogDriver: "awslogs"
						Options: {
							"awslogs-region": Ref: "AWS::Region"
							"awslogs-group": Ref:  "LogGroup"
							"awslogs-stream-prefix": "fargate"
						}
					}
					Name: #Stack.App.Name
					PortMappings: [{
						ContainerPort: #Stack.App.Port
					}]
				}]
				ExecutionRoleArn: "Fn::GetAtt": "ExecutionRole.Arn"
				Family:      #Stack.App.Name
				Memory:      #Stack.TaskDefinition.Memory
				NetworkMode: "awsvpc"
				RequiresCompatibilities: ["FARGATE"]
				RuntimePlatform: {
					CpuArchitecture:       "X86_64"
					OperatingSystemFamily: "LINUX"
				}
				TaskRoleArn: "Fn::GetAtt": "TaskRole.Arn"
			}
		}

		TaskRole: IAM.#Role & {
			Properties: {
				AssumeRolePolicyDocument: IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Principal: Service: "ecs-tasks.amazonaws.com"
						Action: "sts:AssumeRole"
					}]
				}
				ManagedPolicyArns: [
							"arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
				] + #Stack.TaskDefinition.TaskRole.ManagedPolicyArns
				Policies: [{
					PolicyName: "allow-execute-command"
					PolicyDocument: {
						{
							"Version": "2012-10-17"
							"Statement": [
								{
									"Effect": "Allow"
									"Action": [
										"ssmmessages:CreateControlChannel",
										"ssmmessages:CreateDataChannel",
										"ssmmessages:OpenControlChannel",
										"ssmmessages:OpenDataChannel",
									]
									"Resource": "*"
								},
							]
						}
					}
				}]
				RoleName: "Fn::Sub": "${AWS::StackName}-TaskRole"
			}
		}
	}

	Outputs: {
		ServiceSecurityGroupId: {
			Export: Name: "Fn::Sub": "${AWS::StackName}-ServiceSecurityGroupId"
			Value: "Fn::GetAtt": "ServiceSecurityGroup.GroupId"
		}
	}
}
