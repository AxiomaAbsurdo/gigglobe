---
id: architecture
title: System Architecture
sidebar_label: Architecture
slug: /architecture
---

# System Architecture

The job matching platform follows a clear separation of concerns with three main components:

## Architecture Overview

<!-- ![Architecture Diagram](/img/architecture-diagram.png) -->

### Frontend (PWA)
- **Vite.js with TypeScript**: Core framework
- **Vite PWA Plugin**: For Progressive Web App capabilities
- **Auth0 Integration**: For user authentication and role management
- **User Interface**: Forms and views for job seekers and publishers

### Identity Provider
- **Auth0**: Manages user authentication
- **Role Management**: Defines and enforces Job Seeker and Job Publisher roles
- **Auth0 Actions**: Triggers workflows upon auth events (like registration)

### Backend (Kestra.io)
- **Workflow Orchestration**: Defines and executes business processes
- **Event-Driven Design**: Responds to frontend actions via webhooks
- **Database Interaction**: Manages user profiles, jobs, and matching
- **Notification System**: Delivers emails and alerts to users

### Database
- **PostgreSQL**: Stores user profiles, job listings, availability, and matches

## Data Flow

1. **User Action**: A user takes an action in the PWA (e.g., posts a job)
2. **Frontend Request**: The PWA sends an authenticated request to Kestra
3. **Workflow Execution**: Kestra runs the appropriate workflow
4. **Data Processing**: The workflow updates the database and performs business logic
5. **Notification**: Users are informed of relevant events
6. **Frontend Update**: The PWA reflects the latest state

## Responsibility Division

The architecture clearly separates:
- **User Interface Logic**: Handled by the PWA
- **Identity Management**: Managed by Auth0
- **Business Process Logic**: Orchestrated by Kestra
- **Data Persistence**: Maintained in the database

This separation allows each component to focus on its strengths while communicating through well-defined interfaces.
