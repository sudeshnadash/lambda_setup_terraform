# darwin-analytics-service
The purpose of the ***darwin-analytics-service*** is to manage APIs/Lambda/StepFuctions required to fetch analytics data from redshift and return it to client(browser/mobile app).

## Table of Contents
  - [👀 Overview](#-overview)
  - [🛠️ Tools & Technologies](#️-tools--technologies)
  - [🏃 Get up and running](#-get-up-and-running)
  - [🏔️ Project layout](#️-project-layout)
  - [Testing](#-testing)
  - [👩‍💻 API](#-api)
  - [Dependency Management](#-dependency--management)
  - [🏛️ ADR](#️-adr)
  - [🚢 Deployment](#-deployment)
  - [💁‍♀️ Contributing](#️-contributing)
  - [👩‍⚖️ License](#️-license)





## 👀 Overview
To see the actual documentation follow this link: [Documentation](docs/index.md)
![Components & Flows](./docs/draw.io/analytics-service.svg "Overview")
## 🛠️ Tools & Technologies

Here are links to the tools and technologies we use in the project.
EXAMPLE
- [Python](https://www.python.org/)
- [Terraform](https://www.terraform.io/)
- [Step Function](https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html)
- [Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)
- [Amazon Redshift](https://docs.aws.amazon.com/redshift/latest/mgmt/welcome.html)

## 🏃 Get up and running (WIP)

[describe how to get up and running for new developer]


### 🏔️ Project layout
> `/src/api`

API specific componenets: lambda function, data model etc

> `/src/services`

Services/Step function specific componenets: lambda handlers, integrations etc

> `/custom_layer`

To package libraries and other dependencies as **lambda layer** that you can use with your Lambda functions

> `/terraform`

Source code to provision and manage infrastructure

> `/pipeline`

Scripts/code to manage CICD pipeline

> `/test`

Test specific components : Unit tests

> `/docs`

Project specific documents : Architecture Diagram, Sequence diagram(UML) etc


## Testing (WIP)

### Unit testing
### Component testing
### Integration testing
### Security testing 
[describe team consideration]
[More information is found here](https://skfdc.visualstudio.com/Darwin/_wiki/wikis/Darwin.wiki/17985/Security-Testing)

## 👩‍💻 API

`Swagger` file for [API Specification](./swagger/analytics-api.yaml)


## 🚢 Deployment

Deployments happen.. descibe You find futher information here [https://dev.azure.com/skfdc/Darwin/_wiki/wikis/Darwin.wiki/17459/Branching-Strategy-and-Release-flow](https://dev.azure.com/skfdc/Darwin/_wiki/wikis/Darwin.wiki/17459/Branching-Strategy-and-Release-flow)

To use CLI AWS access is required:

[AWS Accounts are available here](https://skfdc.visualstudio.com/Darwin/_wiki/wikis/Darwin.wiki/17271/AWS-Organization-and-Accounts)

Service is deployed on AWS account: 

|| sandbox | test | staging | prod |  |
|--|--|--|--|--|--|
|Name| aws.darwin.idp.app.dev000 |  |  |  |  |
|Account| 544251498666 |  |  |  |  |