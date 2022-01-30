package RDS

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#DBCluster: CloudFormation.#Resource & {
	Type: "AWS::RDS::DBCluster"
}

#DBInstance: CloudFormation.#Resource & {
	Type: "AWS::RDS::DBInstance"
}

#DBSecurityGroup: CloudFormation.#Resource & {
	Type: "AWS::RDS::DBSecurityGroup"
}

#DBSubnetGroup: CloudFormation.#Resource & {
	Type: "AWS::RDS::DBSubnetGroup"
}
