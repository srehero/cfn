package ECR

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#PublicRepository: CloudFormation.#Resource & {
	Type: "AWS::ECR::PublicRepository"
}

#RegistryPolicy: CloudFormation.#Resource & {
	Type: "AWS::ECR::RegistryPolicy"
}

#ReplicationConfiguration: CloudFormation.#Resource & {
	Type: "AWS::ECR::ReplicationConfiguration"
}

#Repository: CloudFormation.#Resource & {
	Type: "AWS::ECR::Repository"
}
