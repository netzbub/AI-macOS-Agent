# Contributing to Self-Hosted AI Toolkit

Thank you for considering contributing to the Self-Hosted AI Toolkit! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please create an issue with the following information:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details (OS, Docker version, etc.)

### Suggesting Enhancements

We welcome suggestions for enhancements! Please create an issue with:

- A clear, descriptive title
- A detailed description of the proposed enhancement
- Any relevant examples or mockups
- Explanation of why this enhancement would be useful

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Update documentation as needed
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/your-feature-name`)
7. Create a new Pull Request

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/self-hosted-ai-toolkit.git
   cd self-hosted-ai-toolkit
   ```

2. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

3. Modify the `.env` file with your settings

4. Run the setup script:
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

## Coding Standards

- Use consistent indentation (2 spaces)
- Use meaningful variable and function names
- Comment your code where necessary
- Follow the existing code style

## Documentation

- Update the README.md if you change functionality
- Update the user guide in docs/user_guide.md
- Add comments to configuration files explaining non-obvious settings

## Testing

Before submitting a pull request, please test your changes:

1. Run the validation script:
   ```bash
   ./scripts/validate-services.sh
   ```

2. Verify all services are accessible through their respective URLs

## Questions?

If you have any questions about contributing, please open an issue with your question.

Thank you for contributing to the Self-Hosted AI Toolkit!
