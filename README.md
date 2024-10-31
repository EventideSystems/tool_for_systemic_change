# Tool for Systemic Change

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
![check](https://github.com/EventideSystems/tool_for_systemic_change/actions/workflows/check.yml/badge.svg)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://rubystyle.guide)

## Background

Originally developed by WickedLab, the Tool for Systemic Change is a web-based application that supports the development of a shared understanding of complex problems and the development of strategies to address them. It is based on the Transition Card model developed by Dr Sharon Zivkovic, and is used by a number of organisations in Australia and internationally.

The tool has been extended to support the management of problems in relation to the United Nations Sustainable Development Goals (SDGs), and to support the development of strategies to address them.

The source code tool has been released under an open source license, and is now maintained by Eventide Systems Pty Ltd. The various configurations used to define the diagnostic models used by the tool remain the intellectual property of their owners. These models are _not_ covered by the open source license. Please see **Additional License Information** below.

## License & Attribution

This software is licensed under the GNU Affero General Public License, version 3 ("AGPL-3.0"). See the [LICENSE](LICENSE.md) file for details.

Copyright © 2023 Emily Humphreys. Portions copyright Eventide Systems Pty Ltd. All rights reserved.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

If you modify this program, or any covered work, by linking or combining it with the Tool for Systemic Change, containing parts covered by the terms of the Affero GPL 3 license, the licensors of this program grant you additional permission to convey the resulting work. Corresponding Source for a non-source form of such a combination shall include the source code for the parts of the Tool for Systemic Change that are used as well as that of the covered work.

Attribution Notice:

- If you modify the software, you must place prominent notices in the modified files stating that you changed the files and the date of any change.

- If you distribute the software or any derivative works in source code form, you must retain the original copyright notices, the above license notice, and provide clear attribution to Emily Humphreys and Eventide Systems Pty Ltd.

- If you distribute the software or any derivative works in binary form, you must, at a minimum, reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation and/or other materials provided with the distribution.

For any questions regarding the use of this software, please contact hello@toolforsystemicchange.com

### Additional License Information

The configuration of the Transition Card model - the original diagnostic model used by the tool - remains the intellectual property of Dr Sharon Zivkovic and may not be used without her permission.

SDG logos, and the Sustainable Development Goals model, are the property of the United Nations and may not be used commercially without permission from the United Nations.

## System Architecture

### System Components

```
                   HEROKU                              AWS LAMBDA                    APPSIGNAL       MANDRILL


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
| [AppSignal](https://www.appsignal.com/) | Monitoring and alerting platform |
| Mailjet | Email service provider |

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
| APPSIGNAL_APP_NAME | Name of application within the AppSignal monitoring service |
| APPSIGNAL_PUSH_API_KEY | Key used to authenticate with the AppSignal monitoring service |

### Deploying to the Application Server

Code is deployed to either environment using the `heroku` CLI. Code is managed within Github, with the `staging` and `master` branches targeting the `staging` and `production` environments respectively.

Convenience tasks are provided to simplify the deployment process. Use the following commands to deploy the system to the `staging` environment:

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

Work is tracked via the [Tool for Systemic Change](https://github.com/orgs/EventideSystems/projects/1) project.
