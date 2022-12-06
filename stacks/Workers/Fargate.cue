package Workers

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
	"github.com/srehero/cfn/schemas/EC2"
	"github.com/srehero/cfn/schemas/ECS"
	"github.com/srehero/cfn/schemas/IAM"
	"github.com/srehero/cfn/schemas/Logs"
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

		Service: {
			ReplicaCount: int
			ServiceName:  string | *App.Name
			Subnets:      Fnable | [...Fnable]
			VpcId:        Fnable
		}

		TaskDefinition: {
			Command:              [...string] | *{Ref: "AWS::NoValue"}
			Cpu:                  string
			EnvironmentFileS3Arn: Fnable
			ExecutionRole: {
				ManagedPolicyArns: [...Fnable] | *[]
			}
			Family: string | *App.Name
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

		Service: ECS.#Service & {
			Properties: {
				Cluster:              #Stack.Cluster.Name
				DesiredCount:         #Stack.Service.ReplicaCount
				EnableECSManagedTags: true
				EnableExecuteCommand: true
				LaunchType:           "FARGATE"
				NetworkConfiguration: AwsvpcConfiguration: {
					AssignPublicIp: "DISABLED"
					SecurityGroups: [{Ref: "ServiceSecurityGroup"}]
					Subnets: #Stack.Service.Subnets
				}
				ServiceName: #Stack.Service.ServiceName
				TaskDefinition: Ref: "TaskDefinition"
			}
		}

		ServiceSecurityGroup: EC2.#SecurityGroup & {
			Properties: {
				GroupDescription: Ref: "AWS::StackName"
				VpcId: #Stack.Service.VpcId
			}
		}

		TaskDefinition: ECS.#TaskDefinition & {
			Properties: {
				Cpu: #Stack.TaskDefinition.Cpu
				ContainerDefinitions: [{
					Command: #Stack.TaskDefinition.Command
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
				Family:      #Stack.TaskDefinition.Family
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
					PolicyName:     "allow-execute-command"
					PolicyDocument: IAM.#PolicyDocument & {
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
				}]
				RoleName: "Fn::Sub": "${AWS::StackName}-TaskRole"
			}
		}
	}

	Outputs: {
		ExecutionRoleArn: {
			Export: Name: "Fn::Sub": "${AWS::StackName}-ExecutionRoleArn"
			Value: "Fn::GetAtt": "ExecutionRole.Arn"
		}

		ServiceSecurityGroupId: {
			Export: Name: "Fn::Sub": "${AWS::StackName}-ServiceSecurityGroupId"
			Value: "Fn::GetAtt": "ServiceSecurityGroup.GroupId"
		}

		TaskRoleArn: {
			Export: Name: "Fn::Sub": "${AWS::StackName}-TaskRoleArn"
			Value: "Fn::GetAtt": "TaskRole.Arn"
		}
	}
}
