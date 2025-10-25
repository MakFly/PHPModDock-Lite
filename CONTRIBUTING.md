# Contributing to PHPModDock-Lite

Thank you for considering contributing to PHPModDock-Lite!

## How to Contribute

### Reporting Bugs

- Check if the bug has already been reported in Issues
- Include detailed steps to reproduce
- Specify your environment (OS, Docker version, etc.)
- Provide relevant logs

### Suggesting Features

- Open an issue with the tag "enhancement"
- Explain the use case and benefits
- Consider backward compatibility

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Guidelines

### Code Style

- Follow existing patterns in the codebase
- Use descriptive variable and service names
- Comment complex configurations
- Keep Dockerfiles minimal and efficient

### Testing

Before submitting:

- Test with Laravel, Symfony, and PrestaShop projects
- Verify all profiles work correctly
- Check that Makefile commands function properly
- Ensure documentation is updated
- Verify security: localhost-only port bindings, no hardcoded credentials

### Documentation

- Update README.md for new features
- Add examples for complex configurations
- Keep documentation clear and concise

## Project Structure

- `services/` - Service-specific configurations
- `docker-compose.yml` - Main orchestration file
- `Makefile` - User-facing commands
- `.env.example` - Configuration template

## Questions?

Open an issue for questions or join discussions.

Thank you for contributing!
