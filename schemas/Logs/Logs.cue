package Logs

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Destination: CloudFormation.#Resource & {
	Type: "AWS::Logs::Destination"
}

#LogGroup: CloudFormation.#Resource & {
	Type: "AWS::Logs::LogGroup"
}

#LogStream: CloudFormation.#Resource & {
	Type: "AWS::Logs::LogStream"
}

#MetricFilter: CloudFormation.#Resource & {
	Type: "AWS::Logs::MetricFilter"
}

#QueryDefinition: CloudFormation.#Resource & {
	Type: "AWS::Logs::QueryDefinition"
}

#ResourcePolicy: CloudFormation.#Resource & {
	Type: "AWS::Logs::ResourcePolicy"
}

#SubscriptionFilter: CloudFormation.#Resource & {
	Type: "AWS::Logs::SubscriptionFilter"
}
