package SNS

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Subscription: CloudFormation.#Resource & {
	Type: "AWS::SNS::Subscription"
}

#Topic: CloudFormation.#Resource & {
	Type: "AWS::SNS::Topic"
}
