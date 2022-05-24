package Events

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#ApiDestination: CloudFormation.#Resource & {
	Type: "AWS::Events::ApiDestination"
}

#Archive: CloudFormation.#Resource & {
	Type: "AWS::Events::Archive"
}

#Connection: CloudFormation.#Resource & {
	Type: "AWS::Events::Connection"
}

#Endpoint: CloudFormation.#Resource & {
	Type: "AWS::Events::Endpoint"
}

#EventBus: CloudFormation.#Resource & {
	Type: "AWS::Events::EventBus"
}

#EventBusPolicy: CloudFormation.#Resource & {
	Type: "AWS::Events::EventBusPolicy"
}

#Rule: CloudFormation.#Resource & {
	Type: "AWS::Events::Rule"
}
