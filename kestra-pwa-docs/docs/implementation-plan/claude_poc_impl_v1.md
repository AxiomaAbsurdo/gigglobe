---
id: claude_poc_impl_v1
title: Claude POC Implementation Plan
sidebar_label: Claude POC v1
slug: /implementation-plan/claude_poc_v1
---

# Kestra.io PWA Integration Documentation Plan

## Overview
```markdown
---
id: environment
title: Environment Setup
sidebar_label: Environment Setup
slug: /setup/environment
---

# Environment Setup

Before starting the implementation, ensure you have the necessary tools and services configured.

## Prerequisites

- **Node.js**: Version 16 or higher
- **Docker and Docker Compose**: For running Kestra and databases
- **Git**: For version control
- **Auth0 Account**: For identity management
- **PostgreSQL**: For database storage

## Initial Setup

1. Clone the repository:

```bash
git clone https://github.com/your-organization/kestra-pwa-integration.git
cd kestra-pwa-integration
```

2. Set up environment variables:

Create a `.env` file in the root directory:

```
# Auth0 Configuration
AUTH0_DOMAIN=your-auth0-domain.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_AUDIENCE=your-api-identifier

# Kestra Configuration
KESTRA_URL=http://localhost:8080
KESTRA_API_KEY=your-api-key

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=jobmatch
DB_USER=postgres
DB_PASSWORD=your-password
```

3. Start the development environment:

```bash
docker-compose up -d
```

This command starts:
- Kestra.io server
- PostgreSQL database
- Any other required services

## Verify Installation

1. Check that Kestra is running:
   - Open [http://localhost:8080](http://localhost:8080) in your browser
   - You should see the Kestra UI

2. Check database connection:
   - Connect to PostgreSQL using your preferred client
   - Verify connectivity using the credentials in your `.env` file

3. Verify Auth0 configuration:
   - Log in to your Auth0 dashboard
   - Confirm your application is set up correctly

Once all services are running properly, you're ready to proceed with the configuration of each component.
```

#### docs/setup/kestra.md

```markdown
---
id: kestra
title: Kestra Configuration
sidebar_label: Kestra Setup
slug: /setup/kestra
---

# Kestra Configuration

This guide covers the setup and configuration of Kestra.io for workflow orchestration.

## Installation

The easiest way to run Kestra is using Docker:

```bash
docker run -p 8080:8080 -v $(pwd)/plugins:/app/plugins kestra/kestra:latest server standalone
```

For development, our `docker-compose.yml` already includes Kestra configuration.

## Configuration File

Create a `kestra.yml` configuration file:

```yaml
kestra:
  repository:
    type: postgres
    postgres:
      url: jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
      user: ${DB_USER}
      password: ${DB_PASSWORD}
  
  queue:
    type: postgres
    
  storage:
    type: local
    local:
      base-path: /tmp/kestra-storage

  # Enable webhook triggers
  triggers:
    webhook:
      enabled: true
```

## Required Plugins

Add the following plugins to your Kestra installation:

1. **JDBC Plugin** (PostgreSQL):
   - Download from [Kestra's plugin page](https://kestra.io/plugins/plugin-jdbc)
   - Copy to the `plugins` directory

2. **Notifications Plugin**:
   - Download from [Kestra's plugin page](https://kestra.io/plugins/plugin-notifications)
   - Copy to the `plugins` directory

## Creating Your First Flow

Create a simple test flow to verify your installation:

```yaml
id: hello-world
namespace: poc
description: Simple test flow

tasks:
  - id: hello
    type: io.kestra.core.tasks.log.Log
    message: "Hello from Kestra!"
```

Save this as `hello-world.yml` and upload it via the Kestra UI or API.

## Test Your Installation

Execute the flow manually from the Kestra UI:

1. Navigate to the Flows section
2. Find your `hello-world` flow
3. Click "Execute"
4. Check the execution results

If you see the "Hello from Kestra!" message in the logs, your installation is working correctly.

## Next Steps

Now that you have Kestra running, you can proceed to set up:
- Auth0 integration
- Database schemas
- Flow definitions for your workflows
```

### User Workflows Section 

#### docs/workflows/registration.md

```markdown
---
id: registration
title: User Registration Workflow
sidebar_label: Registration Flow
slug: /workflows/registration
---

# User Registration Workflow

The User Registration workflow is triggered when a new user signs up via Auth0 and handles the creation of user profiles in the application database, along with welcome notifications.

## Workflow Diagram

![Registration Workflow](/img/registration-workflow.png)

## Trigger

This workflow is triggered by an Auth0 post-registration action, which sends user data to a Kestra webhook endpoint.

## YAML Definition

```yaml
id: user-registration
namespace: jobmatch
description: Creates a user profile when a new user registers via Auth0

triggers:
  - id: registration_webhook
    type: io.kestra.core.models.triggers.types.Webhook
    key: "registration-secret-key" # Replace with your secure key

inputs:
  user_id:
    type: STRING
    required: true
  email:
    type: STRING
    required: true
  name:
    type: STRING
    required: true
  role:
    type: STRING
    required: true
    defaults: "job_seeker" # Default role

tasks:
  - id: create_user_profile
    type: io.kestra.plugin.jdbc.postgresql.Query
    url: "{{env.DB_URL}}"
    username: "{{env.DB_USER}}"
    password: "{{env.DB_PASSWORD}}"
    sql: >
      INSERT INTO user_profiles (
        auth0_user_id, 
        email, 
        name, 
        role, 
        created_at
      ) 
      VALUES (
        '{{inputs.user_id}}', 
        '{{inputs.email}}', 
        '{{inputs.name}}', 
        '{{inputs.role}}', 
        NOW()
      )
      RETURNING id;

  - id: send_welcome_email
    type: io.kestra.plugin.notifications.mail.MailSend
    from: "welcome@yourapp.com"
    to: "{{inputs.email}}"
    subject: "Welcome to the Job Matching Platform!"
    content: |
      Hi {{inputs.name}},
      
      Welcome to our Job Matching Platform! Your account has been created successfully.
      
      {% if inputs.role == 'job_seeker' %}
      Start by setting up your profile and availability to find matching jobs.
      {% else %}
      Start by posting your first job to find qualified candidates.
      {% endif %}
      
      Best regards,
      The Team
```

## Integration with Auth0

To connect this workflow with Auth0:

1. Create an Auth0 Post-Registration Action
2. Configure it to send a POST request to your Kestra webhook URL

```javascript
// Auth0 Post-Registration Action
exports.onExecutePostUserRegistration = async (event, api) => {
  const axios = require('axios');
  
  // Get Kestra webhook URL from environment or config
  const kestraWebhookUrl = event.secrets.KESTRA_WEBHOOK_URL;
  
  try {
    await axios.post(kestraWebhookUrl, {
      user_id: event.user.user_id,
      email: event.user.email,
      name: event.user.name || event.user.email.split('@')[0],
      role: event.user.app_metadata.role || 'job_seeker'
    });
    
    console.log('User registration webhook sent to Kestra');
  } catch (error) {
    console.error('Error sending registration webhook:', error);
    // Non-blocking - Auth0 will continue even if this fails
  }
};
```

## Flow Execution

When this workflow executes:

1. The Auth0 action sends user data to the Kestra webhook
2. Kestra creates a profile record in the database
3. A welcome email is sent to the user

## Testing

Test this workflow by:

1. Creating a new user in Auth0
2. Verifying the user profile is created in the database
3. Checking that the welcome email is sent
```

### Kestra Plugins Section

#### docs/plugins/database.md

```markdown
---
id: database
title: Database Plugins
sidebar_label: Database Plugins
slug: /plugins/database
---

# Database Plugins for Kestra

This page documents how to use Kestra's JDBC plugin to interact with your PostgreSQL database for storing user profiles, job listings, and managing the matching process.

## JDBC PostgreSQL Plugin

Kestra's JDBC plugin allows your workflows to execute SQL queries against your database.

### Installation

1. Download the PostgreSQL JDBC plugin from [Kestra's plugin page](https://kestra.io/plugins/plugin-jdbc)
2. Place it in your Kestra plugins directory
3. Restart Kestra if it's already running

### Usage in Workflows

#### Basic Query

```yaml
- id: execute_query
  type: io.kestra.plugin.jdbc.postgresql.Query
  url: "jdbc:postgresql://localhost:5432/jobmatch"
  username: "postgres"
  password: "your-password"
  sql: "SELECT * FROM users WHERE role = 'job_seeker'"
```

#### Insert Data

```yaml
- id: insert_data
  type: io.kestra.plugin.jdbc.postgresql.Query
  url: "{{env.DB_URL}}"
  username: "{{env.DB_USER}}"
  password: "{{env.DB_PASSWORD}}"
  sql: >
    INSERT INTO jobs (
      title, 
      description, 
      required_skills, 
      start_date, 
      end_date, 
      location, 
      publisher_id
    )
    VALUES (
      '{{inputs.title}}',
      '{{inputs.description}}',
      '{{inputs.skills}}',
      '{{inputs.start_date}}',
      '{{inputs.end_date}}',
      '{{inputs.location}}',
      '{{inputs.publisher_id}}'
    )
    RETURNING id;
```

#### Update Data

```yaml
- id: update_profile
  type: io.kestra.plugin.jdbc.postgresql.Query
  url: "{{env.DB_URL}}"
  username: "{{env.DB_USER}}"
  password: "{{env.DB_PASSWORD}}"
  sql: >
    UPDATE user_profiles
    SET skills = '{{inputs.skills}}', 
        availability = '{{inputs.availability}}'
    WHERE auth0_user_id = '{{inputs.user_id}}'
```

#### Using Results in Subsequent Tasks

The results of a query are available to subsequent tasks:

```yaml
- id: find_matching_candidates
  type: io.kestra.plugin.jdbc.postgresql.Query
  url: "{{env.DB_URL}}"
  username: "{{env.DB_USER}}"
  password: "{{env.DB_PASSWORD}}"
  sql: >
    SELECT up.auth0_user_id, up.email, up.name
    FROM user_profiles up
    JOIN user_skills us ON up.id = us.user_id
    WHERE us.skill = ANY(string_to_array('{{inputs.required_skills}}', ','))
    AND up.availability @> '{{inputs.job_period}}'::tsrange;

- id: notify_candidates
  type: io.kestra.core.tasks.flows.EachSequential
  value: "{{ outputs.find_matching_candidates.rows }}"
  tasks:
    - id: send_notification
      type: io.kestra.plugin.notifications.mail.MailSend
      from: "jobs@yourapp.com"
      to: "{{ taskRunContext.value.email }}"
      subject: "New job matching your skills!"
      content: "Hi {{ taskRunContext.value.name }}, we found a job matching your skills..."
```

## Database Schema

For reference, here's the simplified database schema used in our examples:

```sql
-- User profiles
CREATE TABLE user_profiles (
  id SERIAL PRIMARY KEY,
  auth0_user_id VARCHAR(255) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) NOT NULL,
  skills TEXT[],
  availability TSRANGE[],
  created_at TIMESTAMP DEFAULT NOW()
);

-- Jobs
CREATE TABLE jobs (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  required_skills TEXT[],
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  location VARCHAR(255),
  publisher_id VARCHAR(255) REFERENCES user_profiles(auth0_user_id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Applications
CREATE TABLE applications (
  id SERIAL PRIMARY KEY,
  job_id INTEGER REFERENCES jobs(id),
  user_id VARCHAR(255) REFERENCES user_profiles(auth0_user_id),
  message TEXT,
  status VARCHAR(50) DEFAULT 'applied',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Candidate pools
CREATE TABLE candidate_pools (
  job_id INTEGER REFERENCES jobs(id),
  user_id VARCHAR(255) REFERENCES user_profiles(auth0_user_id),
  matched_at TIMESTAMP DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'matched',
  PRIMARY KEY (job_id, user_id)
);
```

## Best Practices

1. **Use Environment Variables**: Store database credentials in environment variables
2. **Error Handling**: Add error handling tasks to catch and log database errors
3. **Transactions**: For multiple related operations, consider using transactions
4. **Input Validation**: Validate inputs before executing SQL to prevent errors
5. **Parameterized Queries**: Use parameterized queries to prevent SQL injection
```

### Development Section

#### docs/development/poc-plan.md

```markdown
---
id: poc-plan
title: Proof of Concept Plan
sidebar_label: POC Plan
slug: /development/poc-plan
---

# Two-Week Proof of Concept Plan

This page outlines a realistic 14-day plan for implementing a proof of concept (POC) that demonstrates the core functionality of the job matching platform using Kestra workflows.

## Objectives

The POC aims to demonstrate:

1. User registration and profile management
2. Job posting and automated matching
3. Application submission and notifications
4. Integration between Auth0, Kestra, and the PWA

## Timeline

### Week 1: Setup and Core Workflow Implementation

#### Days 1-2: Environment Setup

- Install and configure Kestra (Docker)
- Set up PostgreSQL database
- Configure Auth0 tenant
- Initialize the Vite PWA project
- Verify Auth0 authentication in the PWA

#### Days 3-4: Basic Kestra Flows

- Create User Registration flow
- Create Job Posting flow
- Test flows with manual triggers
- Configure database connections
- Set up basic email notifications

#### Days 5-7: Expand Workflows and Triggers

- Implement Profile/Availability Update flow
- Create Job Application flow
- Configure webhook triggers for all flows
- Document each flow with comments
- Test individual flows via the Kestra UI

### Week 2: Integration and Refinement

#### Days 8-9: Frontend Integration

- Integrate Auth0 Actions with Kestra webhooks
- Set up PWA API calls to Kestra webhooks
- Implement profile management in the PWA
- Create job posting form in the PWA
- Test end-to-end user registration

#### Days 10-11: Notification Testing

- Configure real email sending
- Test email notifications
- Create application submission form
- Implement candidate pool display in the UI
- Ensure database changes are reflected in the frontend

#### Days 12-13: End-to-End Testing

- Test new user onboarding flow
- Test profile update and matching
- Test job posting to notification
- Test application process
- Fix any issues and edge cases

#### Day 14: Documentation and Finalization

- Complete documentation
- Create demonstration materials
- Outline limitations and next steps
- Prepare handover documentation

## Deliverables

At the end of the two-week POC, we will deliver:

1. Working prototype with:
   - Auth0 integration for authentication
   - Kestra workflows for core business processes
   - PWA frontend for user interactions
   - Database schema and sample data

2. Documentation:
   - Setup instructions
   - Flow definitions (YAML)
   - Integration points
   - Screenshots and demos

3. Next steps document outlining:
   - Improvements for production
   - Additional features
   - Scaling considerations
   - Security enhancements

## Trade-offs and Limitations

For the POC, we make the following simplifications:

- Basic matching logic (exact skill matching)
- Simple notifications (email only)
- Minimal frontend styling
- Limited error handling
- No push notifications or real-time updates

These limitations will be addressed in the full implementation phase after POC validation.
```

### Resources Section

#### docs/resources/yaml-examples.md

```markdown
---
id: yaml-examples
title: YAML Workflow Examples
sidebar_label: YAML Examples
slug: /resources/yaml-examples
---

# YAML Workflow Examples

This page provides complete YAML examples for the key workflows in our job matching platform.

## User Registration Workflow

```yaml
id: user-registration
namespace: jobmatch
description: Creates a user profile when a new user registers via Auth0

triggers:
  - id: registration_webhook
    type: io.kestra.core.models.triggers.types.Webhook
    key: "registration-secret-key"

inputs:
  user_id:
    type: STRING
    required: true
  email:
    type: STRING
    required: true
  name:
    type: STRING
    required: true
  role:
    type: STRING
    required: true
    defaults: "job_seeker"

tasks:
  - id: create_user_profile
    type: io.kestra.plugin.jdbc.postgresql.Query
    url: "{{env.DB_URL}}"
    username: "{{env.DB_USER}}"
    password: "{{env.DB_PASSWORD}}"
    sql: >
      INSERT INTO user_profiles (
        auth0_user_id, 
        email, 
        name, 
        role, 
        created_at
      ) 
      VALUES (
        '{{inputs.user_id}}', 
        '{{inputs.email}}', 
        '{{inputs.name}}', 
        '{{inputs.role}}', 
        NOW()
      )
      RETURNING id;

  - id: send_welcome_email
    type: io.kestra.plugin.notifications.mail.MailSend
    from: "welcome@yourapp.com"
    to: "{{inputs.email}}"
    subject: "Welcome to the Job Matching Platform!"
    content: |
      Hi {{inputs.name}},
      
      Welcome to our Job Matching Platform! Your account has been created successfully.
      
      {% if inputs.role == 'job_seeker' %}
      Start by setting up your profile and availability to find matching jobs.
      {% else %}
      Start by posting your first job to find qualified candidates.
      {% endif %}
      
      Best regards,
      The Team
```

## Profile Update Workflow

```yaml
id: profile-update
namespace: jobmatch
description: Updates a user's profile and checks for matching jobs

triggers:
  - id: profile_update_webhook
    type: io.kestra.core.models.triggers.types.Webhook
    key: "profile-update-secret-key"

inputs:
  user_id:
    type: STRING
    required: true
  skills:
    type: STRING
    required: false
  availability:
    type: STRING
    required: false

tasks:
  - id: update_user_profile
    type: io.kestra.plugin.jdbc.postgresql.Query
    url: "{{env.DB_URL}}"
    username: "{{env.DB_USER}}"
    password: "{{env.DB_PASSWORD}}"
    sql: >
      UPDATE user_profiles
      SET 
        {% if inputs.skills is defined %}
        skills = string_to_array('{{inputs.skills}}', ','),
        {% endif %}
        {% if inputs.availability is defined %}
        availability = '{{inputs.availability}}'::tsrange[],
        {% endif %}
        updated_at = NOW()
      WHERE auth0_user_id = '{{inputs.user_id}}'
      RETURNING id;

  - id: find_matching_jobs
    type: io.kestra.plugin.jdbc.postgresql.Query
    url: "{{env.DB_URL}}"
    username: "{{env.DB_USER}}"
    password: "{{env.DB_PASSWORD}}"
    sql: >
      SELECT j.id, j.title, j.start_date, j.end_date, 
             u.email as publisher_email, u.name as publisher_name
      FROM jobs j
      JOIN user_profiles u ON j.publisher_id = u.auth0_user_id
      WHERE 
        array_overlap(j.required_skills, 
                     (SELECT skills FROM user_profiles WHERE auth0_user_id = '{{inputs.user_id}}'))
        AND tsrange(j.start_date, j.end_date) && ANY(
            (SELECT availability FROM user_profiles WHERE auth0_user_id = '{{inputs.user_id}}'))
        AND j.status = 'open'
      LIMIT 5;

  - id: conditional_notification
    type: io.kestra.core.tasks.flows.Condition
    condition: "{{ outputs.find_matching_jobs.rows | length > 0 }}"
    tasks:
      - id: get_user_email
        type: io.kestra.plugin.jdbc.postgresql.Query
        url: "{{env.DB_URL}}"
        username: "{{env.DB_USER}}"
        password: "{{env.DB_PASSWORD}}"
        sql: >
          SELECT email, name FROM user_profiles WHERE auth0_user_id = '{{inputs.user_id}}'