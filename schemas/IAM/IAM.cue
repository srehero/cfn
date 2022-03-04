package IAM

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#AccessKey: CloudFormation.#Resource & {
	Type: "AWS::ECS::AccessKey"
}

#Group: CloudFormation.#Resource & {
	Type: "AWS::ECS::Group"
}

#InstanceProfile: CloudFormation.#Resource & {
	Type: "AWS::IAM::InstanceProfile"
}

#ManagedPolicy: CloudFormation.#Resource & {
	Type: "AWS::IAM::ManagedPolicy"
}

#OIDCProvider: CloudFormation.#Resource & {
	Type: "AWS::ECS::OIDCProvider"
}

#Policy: CloudFormation.#Resource & {
	Type: "AWS::ECS::Policy"
}

#PolicyDocument: {
	Version: "2012-10-17"
	Statement: [{...}]
}

#Role: CloudFormation.#Resource & {
	Type: "AWS::ECS::Role"
}

#SAMLProvider: CloudFormation.#Resource & {
	Type: "AWS::ECS::SAMLProvider"
}

#ServerCertificate: CloudFormation.#Resource & {
	Type: "AWS::ECS::ServerCertificate"
}

#ServiceLinkedRole: CloudFormation.#Resource & {
	Type: "AWS::ECS::ServiceLinkedRole"
}

#User: CloudFormation.#Resource & {
	Type: "AWS::ECS::User"
}

#UserToGroupAddition: CloudFormation.#Resource & {
	Type: "AWS::ECS::UserToGroupAddition"
}

#VirtualMFADevice: CloudFormation.#Resource & {
	Type: "AWS::ECS::VirtualMFADevice"
}
