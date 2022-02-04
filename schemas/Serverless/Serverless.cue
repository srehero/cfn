package Serverless

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Api: CloudFormation.#Resource & {
	Type: "AWS::Serverless::Api"
}

#Application: CloudFormation.#Resource & {
	Type: "AWS::Serverless::Application"
}

#Function: CloudFormation.#Resource & {
	Type: "AWS::Serverless::Function"
}

#HttpApi: CloudFormation.#Resource & {
	Type: "AWS::Serverless::HttpApi"
}

#LayerVersion: CloudFormation.#Resource & {
	Type: "AWS::Serverless::LayerVersion"
}

#SimpleTable: CloudFormation.#Resource & {
	Type: "AWS::Serverless::SimpleTable"
}

#Template: CloudFormation.#Template & {
	Transform: "AWS::Serverless-2016-10-31"
}
