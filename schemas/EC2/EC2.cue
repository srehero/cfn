package EC2

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#EIP: CloudFormation.#Resource & {
	Type: "AWS::EC2::EIP"
}

#Instance: CloudFormation.#Resource & {
	Type: "AWS::EC2::Instance"
}

#InternetGateway: CloudFormation.#Resource & {
	Type: "AWS::EC2::InternetGateway"
}

#NatGateway: CloudFormation.#Resource & {
	Type: "AWS::EC2::NatGateway"
}

#Route: CloudFormation.#Resource & {
	Type: "AWS::EC2::Route"
}

#RouteTable: CloudFormation.#Resource & {
	Type: "AWS::EC2::RouteTable"
}

#RouteTableAssociation: CloudFormation.#Resource & {
	Type: "AWS::EC2::RouteTableAssociation"
}

#SecurityGroup: CloudFormation.#Resource & {
	Type: "AWS::EC2::SecurityGroup"
}

#SecurityGroupIngress: CloudFormation.#Resource & {
	Type: "AWS::EC2::SecurityGroupIngress"
}

#Subnet: CloudFormation.#Resource & {
	Type: "AWS::EC2::Subnet"
}

#VPC: CloudFormation.#Resource & {
	Type: "AWS::EC2::VPC"
}

#VPCEndpoint: CloudFormation.#Resource & {
	Type: "AWS::EC2::VPCEndpoint"
}

#VPCGatewayAttachment: CloudFormation.#Resource & {
	Type: "AWS::EC2::VPCGatewayAttachment"
}
