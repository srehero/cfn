package SQS

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Queue: CloudFormation.#Resource & {
	Type: "AWS::SQS::Queue"
}

#QueuePolicy: CloudFormation.#Resource & {
	Type: "AWS::SQS::QueuePolicy"
}
