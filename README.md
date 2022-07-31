# WickedLab

## System Architecture

### System Components

```
                  HEROKU                              AWS LAMBDA                    SCOUT




┌────────────────────┐     ┌─────────────┐      ┌────────────────────────┐
│ Background Process │◄────┤ Application ├─────►│ Betweenness/Centrality │
│      Worker        │     │   Server    │      │        Service         │
└─────────┬──────────┘     └──────┬──────┘      └────────────────────────┘
          │                       │  ▲
          │                       │  │
          │                       │  │
          │    ┌────────────┐     │  │                                         ┌────────────┐
          └───►│ Relational │◄────┘  └─────────────────────────────────────────┤   System   │
               │  Database  │                                                  │ Monitoring │
               └────────────┘                                                  └────────────┘


```

#### Service Providers

| Provider | Description |
| --------------- | --------------- |
| Heroku | Hosting platform for the application, background process worker and database |
| AWS Lambda | Serverless computing platform, executing smaller tasks (e.g. calculating metrics)  |
| Scout | Monitoring and alerting platform |

#### System Component Details

| Component | Description |
| --------------- | --------------- |
| Application Server | Ruby on Rails application, providing data entry and reporting features. Authorization and access to data is managed in this component |
| Background Process Worker | Manages long-running workloads. NB This is a proposed component and is not currently in use |
| Relational Database | Postgres-base relational database |
| Betweenness/Centrality Service | Python script used to calculate betweenness/centrality metrics between nodes in the Ecosystem Map graphs |
| System Monitoring Service | Collects application and database performance data, reports on application errors |


## System Environment

There are two environments that are used to run the system: `staging` and `production`. The `staging` environment is used for development and testing, and the `production` environment is used for the production environment. The `staging` environment has approximately the same functionality as the `production` environment, but the system is not optimized for production use. It also does not have any monitoring or alerting functionality.

### Deploying to the Application Server

Code is deployed to either environment using the `heroku` CLI. Code is managed within Github, with the `staging` and `master` branches targetting the `staging` and `production` environments respectively.

Convience tasks are provided to simplify the deployment process. Use the follow ing commands to deploy the system to the `staging` environment:


```
bundle exec rails deploy:staging
```

and to deploy the system to the `production` environment:

```
bundle exec rails deploy:production
```

### Deploying to AWS Lamba

_TBD_

## Development

Work is tracked via the [Wicked Lab App Development](https://github.com/ferrisoxide/wicked_software/projects/1) project.
