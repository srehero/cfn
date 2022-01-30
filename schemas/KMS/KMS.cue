package KMS

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Alias: CloudFormation.#Resource & {
	Type: "AWS::KMS::Alias"
}

#Key: CloudFormation.#Resource & {
	Type: "AWS::KMS::Key"
}
