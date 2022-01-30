package IAM

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#InstanceProfile: CloudFormation.#Resource & {
	Type: "AWS::IAM::InstanceProfile"
}

#ManagedPolicy: CloudFormation.#Resource & {
	Type: "AWS::IAM::ManagedPolicy"
}

#PolicyDocument: {
	Version: "2012-10-17"
	Statement: [{...}]
}

#Role: CloudFormation.#Resource & {
	Type: "AWS::IAM::Role"
}
