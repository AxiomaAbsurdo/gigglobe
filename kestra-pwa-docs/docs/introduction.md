---
id: introduction
title: Introduction
sidebar_label: Introduction
slug: /introduction
---

# Orchestrating PWA Job Matching Workflows with Kestra

This documentation covers the integration of Kestra.io with a Progressive Web App (PWA) for orchestrating automated job matching workflows. The system connects traveling workers with temporary jobs through an efficient, event-driven architecture.

## Background

Our application is a **Progressive Web App (PWA)** built using Vite.js with TypeScript, aimed at matching traveling workers with temporary jobs. The application uses **Auth0** for authentication and defines two user roles:

- **Job Seekers**: Traveling workers looking for temporary employment
- **Job Publishers**: Employers posting temporary job opportunities

The app's core features include user registration, profile management, job postings, automated skill/availability matching, and job application management.

## Why Kestra.io?

[Kestra.io](https://kestra.io) is an open-source workflow orchestration platform that allows us to define backend processes (workflows) in a declarative YAML format. It enables us to:

- Trigger workflows in response to events or on schedules
- Automate complex multi-step processes
- Coordinate job matching and notification delivery
- Integrate with databases, APIs, and messaging services

By leveraging Kestra, we keep our frontend code clean and focused on user interaction while the complex business logic runs as automated workflows.

## Implementation Plans

We have developed detailed implementation plans for our proof of concept:

- [Claude POC Implementation Plan](/docs/implementation-plan/claude_poc_v1)
- [GPT POC Implementation Plan](/docs/implementation-plan/gpt_poc_v1)

These plans outline the approach, timeline, and technical details for implementing the integration between our PWA and Kestra.io.

## Documentation Purpose

This documentation serves as a comprehensive guide for implementing and understanding the integration between our PWA and Kestra.io for workflow orchestration. It covers:

1. Setting up the development environment
2. Configuring Kestra.io workflows
3. Integrating Auth0 authentication
4. Implementing frontend-to-backend communication
5. Extending and customizing the platform

Whether you're a developer working on the project or a stakeholder trying to understand the architecture, this documentation provides the necessary insights and technical details.
