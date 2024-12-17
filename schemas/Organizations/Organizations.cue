package Organizations

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Account: CloudFormation.#Resource & {
	Type: "AWS::Organizations::Account"
}

#Organization: CloudFormation.#Resource & {
	Type: "AWS::Organizations::Organization"
}

#OrganizationalUnit: CloudFormation.#Resource & {
	Type: "AWS::Organizations::OrganizationalUnit"
}

#Policy: CloudFormation.#Resource & {
	Type: "AWS::Organizations::Policy"
}

#ResourcePolicy: CloudFormation.#Resource & {
	Type: "AWS::Organizations::ResourcePolicy"
}
