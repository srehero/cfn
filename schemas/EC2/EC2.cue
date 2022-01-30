package EC2

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Instance: CloudFormation.#Resource & {
	Type: "AWS::EC2::Instance"
}

#SecurityGroup: CloudFormation.#Resource & {
	Type: "AWS::EC2::SecurityGroup"
}

#SecurityGroupIngress: CloudFormation.#Resource & {
	Type: "AWS::EC2::SecurityGroupIngress"
}
