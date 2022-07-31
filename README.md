# WickedLab

## System Architecture

### System Components

```
                   HEROKU                              AWS LAMBDA                    SCOUT           MANDRILL 


 ┌────────────────────┐     ┌─────────────┐      ┌────────────────────────┐
 │ Background Process │◄────┤ Application ├─────►│ Betweenness/Centrality │
 │      Worker        │     │   Server    │      │        Service         │
 └─────────┬──────────┘     └───┬──┬──────┘      └────────────────────────┘
           │                    │  │  ▲
           │                    │  │  │
           │                    │  │  │                                         ┌────────────┐
           │    ┌────────────┐  │  │  └─────────────────────────────────────────┤   System   │
           └───►│ Relational │◄─┘  │                                            │ Monitoring │
                │  Database  │     │                                            └────────────┘
                └────────────┘     │
                                   │                                                                ┌─────────┐
                                   └───────────────────────────────────────────────────────────────►┤  Email  │
                                                                                                    │ Service │
                                                                                                    └─────────┘
```

#### Service Providers

| Provider | Description |
| --------------- | --------------- |
| Heroku | Hosting platform for the application, background process worker and database |
| AWS Lambda | Serverless computing platform, executing smaller tasks (e.g. calculating metrics)  |
| Scout | Monitoring and alerting platform |
| Mandrill | Email service provider |

#### System Component Details

| Component | Description |
| --------------- | --------------- |
| Application Server | Ruby on Rails application, providing data entry and reporting features. Authorization and access to data is managed in this component |
| Background Process Worker | Manages long-running workloads. NB This is a proposed component and is not currently in use |
| Relational Database | Postgresql-based relational database system |
| Betweenness/Centrality Service | Python script used to calculate betweenness/centrality metrics between nodes in the Ecosystem Map graphs |
| Email Service | Used to send emails to users, required by the authentication process |
| System Monitoring Service | Collects application and database performance data, reports on application errors |


## System Environment

There are two environments that are used to run the system: `staging` and `production`. The `staging` environment is used for development and testing, and the `production` environment is used by actual end users of the system. The `staging` environment has approximately the same functionality as the `production` environment, but the system is not optimized for production use. It also does not have any monitoring or alerting functionality.

### System Environment Configuration

System configuration items are stored on the Heroku platform within environment variables in the System Configuration section of each of the respective `production` or `staging` system environments. The following environment variables are used:

| Variable | Description |
| --------------- | --------------- |
| DATABASE_URL | Postgresql database connection string |
| MANDRILL_API_KEY | Mandrill API key used to send emails |
| MANDRILL_USERNAME | Mandrill username used to send emails |
| RAILS_ENV | Environment used to determine whether the system is running in the `staging` or `production` environment |
| RAILS_MASTER_KEY | Secret key used to encrypt and decrypt data |
| SCOUT_KEY | Scout key used to authenticate with the Scout monitoring service |
| SCOUT_LOG_LEVEL | Log level used to determine the level of logging used by the Scout monitoring service |

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

## Key Processes

_TBD_

## Development

Work is tracked via the [Wicked Lab App Development](https://github.com/ferrisoxide/wicked_software/projects/1) project.
