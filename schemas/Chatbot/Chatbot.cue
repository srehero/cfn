package Chatbot

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#SlackChannelConfiguration: CloudFormation.#Resource & {
	Type: "AWS::Chatbot::SlackChannelConfiguration"
}
