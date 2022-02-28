package CloudFormation

#Resource: {
	CreationPolicy?: {...}
	DeletionPolicy?: string
	DependsOn?:     string | [...string]
	Metadata?: {...}
	Properties: {...}
	Type: string
	UpdatePolicy?: {...}
	UpdateReplacePolicy?: string
}

#Template: {
	AWSTemplateFormatVersion: "2010-09-09"
	Conditions?: {...}
	Description?: string
	Mappings?: {...}
	Metadata?: {...}
	Outputs?: {...}
	Parameters?: {...}
	Resources: {...}
	Rules?: {...}
	Transform?: string
}
