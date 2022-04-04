package Processing

import (
	"github.com/srehero/cfn/schemas/IAM"
	"github.com/srehero/cfn/schemas/SNS"
	"github.com/srehero/cfn/schemas/SQS"
	"github.com/srehero/cfn/schemas/Serverless"
)

#SimplePipeline: Serverless.#Template & {
	#Stack: {
		Function: {
			CodeUri: string | *"lambda_function/"
			Handler: string | *"handler.handler"
			Policies: [{...}] | *[]
			Runtime: string | *"python3.9"
			Timeout: int | *900
		}
		Queue: {
			MessageRetentionPeriod: int | *1209600 // 14 days
		}
		Pipeline: {
			Name: string
		}
		Topic: {
			ArnExport: string
		}
	}

	Resources: {
		Function: Serverless.#Function & {
			Properties: {
				CodeUri: #Stack.Function.CodeUri
				Handler: #Stack.Function.Handler
				Role: "Fn::GetAtt": "FunctionRole.Arn"
				Runtime: #Stack.Function.Runtime
				Timeout: #Stack.Function.Timeout
				Events: {
					SQSEvent: {
						Type: "SQS"
						Properties: {
							Queue: "Fn::GetAtt": "Queue.Arn"
							BatchSize: 10
							Enabled:   true
						}
					}
				}
			}
		}

		FunctionRole: IAM.#Role & {
			Properties: {
				AssumeRolePolicyDocument: IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Action: "sts:AssumeRole"
						Principal: Service: "lambda.amazonaws.com"
					}]
				}
				ManagedPolicyArns: [
					"arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
				]
				Policies: [{
					PolicyName:     "process-\(#Stack.Pipeline.Name)-queue"
					PolicyDocument: IAM.#PolicyDocument & {
						Statement: [{
							Effect: "Allow"
							Action: [
								"sqs:ReceiveMessage",
								"sqs:DeleteMessage",
								"sqs:GetQueueAttributes",
							]
							Resource: "Fn::GetAtt": "Queue.Arn"
						}]
					}
				}] + #Stack.Function.Policies
			}
		}

		Queue: SQS.#Queue & {
			Properties: {
				MessageRetentionPeriod: #Stack.Queue.MessageRetentionPeriod
				QueueName:              #Stack.Pipeline.Name
				// Visibility timeout should always be at least 6 times the function's timeout
				// https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html
				VisibilityTimeout: #Stack.Function.Timeout * 6
				RedrivePolicy: {
					deadLetterTargetArn: "Fn::GetAtt": "ProcessingFailedQueue.Arn"
					// Retry at least five times to create headroom for throttling and scaling activites
					// https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html
					maxReceiveCount: 5
				}
			}
		}

		QueuePolicy: SQS.#QueuePolicy & {
			Properties: {
				PolicyDocument: IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Principal: Service: "sns.amazonaws.com"
						Action: "sqs:SendMessage"
						Resource: "Fn::GetAtt": "Queue.Arn"
						Condition: ArnEquals: "aws:SourceArn": "Fn::ImportValue": #Stack.Topic.ArnExport
					}]
				}
				Queues: [{Ref: "Queue"}]
			}
		}

		ProcessingFailedQueue: SQS.#Queue & {
			Properties: {
				MessageRetentionPeriod: 1209600 // 14 days
				QueueName:              "\(#Stack.Pipeline.Name)-processing-failed"
			}
		}

		DeliveryFailedQueue: SQS.#Queue & {
			Properties: {
				MessageRetentionPeriod: 1209600 // 14 days
				QueueName:              "\(#Stack.Pipeline.Name)-delivery-failed"
			}
		}

		DeliveryFailedQueuePolicy: SQS.#QueuePolicy & {
			Properties: {
				PolicyDocument: IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Principal: Service: "sns.amazonaws.com"
						Action: "sqs:SendMessage"
						Resource: [{"Fn::GetAtt": "DeliveryFailedQueue.Arn"}]
						Condition: ArnEquals: "aws:SourceArn": "Fn::ImportValue": #Stack.Topic.ArnExport
					}]
				}
				Queues: [{Ref: "DeliveryFailedQueue"}]
			}
		}

		Subscription: SNS.#Subscription & {
			Properties: {
				Endpoint: "Fn::GetAtt": "Queue.Arn"
				Protocol: "sqs"
				RedrivePolicy: deadLetterTargetArn: "Fn::GetAtt": "DeliveryFailedQueue.Arn"
				TopicArn: "Fn::ImportValue": #Stack.Topic.ArnExport
			}
		}

		ManagePipelineManagedPolicy: IAM.#ManagedPolicy & {
			Properties: {
				Description:       "Manage resources in the \(#Stack.Pipeline.Name) pipeline"
				ManagedPolicyName: "manage-\(#Stack.Pipeline.Name)-pipeline"
				PolicyDocument:    IAM.#PolicyDocument & {
					Statement: [{
						Effect: "Allow"
						Action: [
							"sqs:DeleteMessage",
							"sqs:Get*",
							"sqs:List*",
							"sqs:PurgeQueue",
							"sqs:ReceiveMessage",
							"sqs:SendMessage",
						]
						Resource: [
							{"Fn::GetAtt": "Queue.Arn"},
							{"Fn::GetAtt": "ProcessingFailedQueue.Arn"},
							{"Fn::GetAtt": "DeliveryFailedQueue.Arn"},
						]
					}]
				}
			}
		}
	}
}
