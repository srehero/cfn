package ECS

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#CapacityProvider: CloudFormation.#Resource & {
	Type: "AWS::ECS::CapacityProvider"
}

#Cluster: CloudFormation.#Resource & {
	Type: "AWS::ECS::Cluster"
}

#ClusterCapacityProviderAssociations: CloudFormation.#Resource & {
	Type: "AWS::ECS::ClusterCapacityProviderAssociations"
}

#PrimaryTaskSet: CloudFormation.#Resource & {
	Type: "AWS::ECS::PrimaryTaskSet"
}

#Service: CloudFormation.#Resource & {
	Type: "AWS::ECS::Service"
}

#TaskDefinition: CloudFormation.#Resource & {
	Type: "AWS::ECS::TaskDefinition"
}

#TaskSet: CloudFormation.#Resource & {
	Type: "AWS::ECS::TaskSet"
}
