package CloudWatch

import (
	"github.com/srehero/cfn/schemas/CloudFormation"
)

#Alarm: CloudFormation.#Resource & {
	Type: "AWS::CloudWatch::Alarm"
}

#AnomalyDetector: CloudFormation.#Resource & {
	Type: "AWS::CloudWatch::AnomalyDetector"
}

#CompositeAlarm: CloudFormation.#Resource & {
	Type: "AWS::CloudWatch::CompositeAlarm"
}

#Dashboard: CloudFormation.#Resource & {
	Type: "AWS::CloudWatch::Dashboard"
}

#InsightRule: CloudFormation.#Resource & {
	Type: "AWS::CloudWatch::InsightRule"
}

#MetricStream: CloudFormation.#Resource & {
	Type: "AWS::CloudWatch::MetricStream"
}
