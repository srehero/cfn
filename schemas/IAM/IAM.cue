package IAM

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#AccessKey: CloudFormation.#Resource & {
	Type: "AWS::IAM::AccessKey"
}

#Group: CloudFormation.#Resource & {
	Type: "AWS::IAM::Group"
}

#InstanceProfile: CloudFormation.#Resource & {
	Type: "AWS::IAM::InstanceProfile"
}

#ManagedPolicy: CloudFormation.#Resource & {
	Type: "AWS::IAM::ManagedPolicy"
}

#OIDCProvider: CloudFormation.#Resource & {
	Type: "AWS::IAM::OIDCProvider"
}

#Policy: CloudFormation.#Resource & {
	Type: "AWS::IAM::Policy"
}

#PolicyDocument: {
	Version: "2012-10-17"
	Statement: [...{...}]
}

#Role: CloudFormation.#Resource & {
	Type: "AWS::IAM::Role"
}

#SAMLProvider: CloudFormation.#Resource & {
	Type: "AWS::IAM::SAMLProvider"
}

#ServerCertificate: CloudFormation.#Resource & {
	Type: "AWS::IAM::ServerCertificate"
}

#ServiceLinkedRole: CloudFormation.#Resource & {
	Type: "AWS::IAM::ServiceLinkedRole"
}

#User: CloudFormation.#Resource & {
	Type: "AWS::IAM::User"
}

#UserToGroupAddition: CloudFormation.#Resource & {
	Type: "AWS::IAM::UserToGroupAddition"
}

#VirtualMFADevice: CloudFormation.#Resource & {
	Type: "AWS::IAM::VirtualMFADevice"
}
