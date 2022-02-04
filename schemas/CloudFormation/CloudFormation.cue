package CloudFormation

#Resource: {
	Type: string
	DependsOn?: string
	Properties: {...}
}

#Template: {
	AWSTemplateFormatVersion: "2010-09-09"
	Description?:             string
	Metadata?: {...}
	Parameters?: {...}
	Rules?: {...}
	Mappings?: {...}
	Conditions?: {...}
	Transform?: string
	Resources: {...}
	Outputs?: {...}
}
