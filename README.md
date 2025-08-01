# Obsekio: the Tool for Systemic Change

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
![check](https://github.com/EventideSystems/tool_for_systemic_change/actions/workflows/check.yml/badge.svg)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://rubystyle.guide)

## About

Obsekio helps users develop a shared understanding of complex problems and identify strategies to address them. It enables the tracking of progress towards desired changes within an organization or the community, and allows visualization of the connections between stakeholders enagaged in effecting those changes.  

Obsekio is a rewrite of [WickedLab's](https://web.archive.org/web/20240329200630/https://www.wickedlab.co/) **Tool for Systemic Change**. It enhances the original Tool, improving its performance and accessiblity.

The source code for Obsekio is written using [Ruby on Rails](https://rubyonrails.org/) and is available under the [AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.en.html) open source license.

A hosted instance of the tool can be found here: https://www.obsek.io/

## Features

### Tracking Changes

Obsekio allows users to model the objectivites of successful initiatives and record efforts made working towards reaching goals within those initiatives. 

Obsekio includes pre-defined data-collection models (_e.g._ the United Nations' [Sustainable Development Goals](https://sdgs.un.org/goals)) that users can customize to their ends - or create new models from scratch.  

![example of data entry](app/assets/images/data_entry.png)

### Measuring Impact

Obsekio provides an at-a-glance overview of related initiatives, comparing progress across projects and identifying gaps in effort.

![grid view of initiatives](app/assets/images/screenshot.png)

### Connecting Stakeholders

Obsekio provides tools for visualising the connections betweens stakeholders engaged across initiatives, identify how much each impacts the ecosystem of parties with an interest in the tracked projects. 

![stakeholder graph](app/assets/images/graph.png)

## Acknowledgments

We're grateful to Wicked Lab for developing the original Tool for Systemic Change and for agreeing to release the code as open source.

We'd also like to thank [AppSignal](https://www.appsignal.com/) for providing monitoring and error tracking services.

And naturally we appreciate our users, without whose support and feedback this project would not exist.    

So, thank you everyone!

## License & Attribution

Copyright © 2023 Wicked Lab
Copyright © 2025 Eventide Systems Pty Ltd

This software is licensed under the GNU Affero General Public License, version 3 ("AGPL-3.0"). See the [LICENSE](LICENSE.md) file for details.  

NB the `db/data_models` directory contains seed data models that are copyright their respective owners.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.

If you modify this program, or any covered work, by linking or combining it with Obsekio, containing parts covered by the terms of the Affero GPL 3 license, the licensors of this program grant you additional permission to convey the resulting work. Corresponding Source for a non-source form of such a combination shall include the source code for the parts of the Tool for Systemic Change that are used as well as that of the covered work.

Attribution Notice:

- If you modify the software, you must place prominent notices in the modified files stating that you changed the files and the date of any change.

- If you distribute the software or any derivative works in source code form, you must retain the original copyright notices, the above license notice, and provide clear attribution to Emily Humphreys and Eventide Systems Pty Ltd.

- If you distribute the software or any derivative works in binary form, you must, at a minimum, reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation and/or other materials provided with the distribution.

For any questions regarding the use of this software, please contact hello@toolforsystemicchange.com or raise a ticket in the project's [issue tracker on Github](https://github.com/EventideSystems/tool_for_systemic_change/issues).

## System Architecture

### System Components

```
                   HEROKU                              AWS LAMBDA                    APPSIGNAL       MAILJET


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
| APPSIGNAL_APP_NAME | Name of application within the AppSignal monitoring service |
| APPSIGNAL_PUSH_API_KEY | Key used to authenticate with the AppSignal monitoring service |
| AWS_ACCESS_KEY_ID | AWS access key for "betweenness" lambda function |
| AWS_SECRET_ACCESS_KEY | AWS secret key |
| CONTACT_MAIL_RECIPIENTS | Comma-separated list of recipients of email sent via contact forms |
| DATABASE_URL | Postgresql database connection string |
| MAILJET_API_KEY | API key used to send email via Mailjet |
| MAILJET_SECRET_KEY | Secret key used to send email via Mailjet |
| MAILJET_DEFAULT_FROM | Nominal 'from' address for outgoing mail |
| RECAPTCHA_SITE_KEY | Key for Google ReCaptcha used on "external" forms (contact, login, etc) |
| RECAPTCHA_SECRET_KEY | Secrete for Google ReCaptcha |
| RUBY_YJIT_ENABLE | Set to '1' to enable JIT compilation |
| SECRET_KEY_BASE | Secret used by Rails for generating cookies and other encryption-related operations |

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
