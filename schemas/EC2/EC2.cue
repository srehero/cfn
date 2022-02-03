package EC2

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Instance: CloudFormation.#Resource & {
	Type: "AWS::EC2::Instance"
}

#InternetGateway: CloudFormation.#Resource & {
	Type: "AWS::EC2::InternetGateway"
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

#VPCGatewayAttachment: CloudFormation.#Resource & {
	Type: "AWS::EC2::VPCGatewayAttachment"
}
