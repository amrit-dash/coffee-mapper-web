# Security Policy

## Supported Versions

Currently supported versions for security updates:

| Version | Supported          |
| ------- | ------------------ |
| 1.1.x   | :white_check_mark: |
| 1.0.x   | :x:                |

## Reporting a Vulnerability

We take the security of Coffee Mapper Web seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Reporting Process

1. **DO NOT** create a public GitHub issue for the vulnerability.
2. Email your findings to geospatialtech.production@gmail.com
3. Include detailed steps to reproduce the issue
4. Include any proof of concept code if applicable

### What to Include

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Process

1. You will receive acknowledgment of your report within 48 hours
2. We will confirm the issue and determine its severity
3. We will release a fix as soon as possible depending on complexity

## Security Measures

### Data Protection

- All data is encrypted in transit using TLS
- Sensitive data is encrypted at rest
- Regular security audits are performed
- Access logs are maintained and monitored

### Authentication & Authorization

- Role-based access control (RBAC)
- Secure password policies
- Two-factor authentication support
- Regular session management
- JWT token-based authentication

### Infrastructure Security

- Regular security patches and updates
- Firewall protection
- DDoS protection
- Regular backup procedures
- Monitoring and alerting systems

## Best Practices

When contributing to Coffee Mapper Web, please ensure:

1. All API keys and secrets are properly secured
2. Input validation is implemented
3. Output encoding is used where necessary
4. Authentication and authorization checks are in place
5. Proper error handling is implemented
6. Logging does not expose sensitive information
7. Dependencies are regularly updated

## Contact

For any security-related questions, please contact:
- Security Team: geospatialtech.production@gmail.com
- Developer: amrit.dash60@gmail.com 