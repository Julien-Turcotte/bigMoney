# Contributing to MiniUniswap DEX

Thank you for your interest in contributing to MiniUniswap DEX! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Set up the development environment**:
   ```bash
   ./setup.sh
   ```
4. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Making Changes

1. Make your changes in your feature branch
2. Test your changes thoroughly
3. Update documentation if needed
4. Commit with clear messages

### Testing Your Changes

**Smart Contracts:**
```bash
# Compile contracts
npx hardhat compile

# Run tests (when available)
npx hardhat test

# Deploy locally to test
npx hardhat node  # Terminal 1
npx hardhat run scripts/deploy.js --network localhost  # Terminal 2
```

**Frontend:**
```bash
cd frontend

# Build to check for errors
npm run build

# Run dev server
npm run dev
```

### Commit Messages

Use clear, descriptive commit messages:
- ✅ Good: "Add price impact warning to swap interface"
- ✅ Good: "Fix slippage calculation for large trades"
- ❌ Bad: "Update stuff"
- ❌ Bad: "Fix bug"

Format:
```
<type>: <description>

[optional body]
[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

## Areas for Contribution

### High Priority

1. **Testing**
   - Unit tests for smart contracts
   - Integration tests
   - Frontend component tests
   - E2E tests

2. **Security**
   - Security audits
   - Gas optimization
   - Edge case testing

3. **Documentation**
   - Video tutorials
   - More examples
   - Translations

### Feature Enhancements

1. **Smart Contracts**
   - Factory pattern for multiple pools
   - Router for multi-hop swaps
   - TWAP price oracle
   - Flash swaps
   - Concentrated liquidity

2. **Frontend**
   - Price charts
   - Transaction history
   - Analytics dashboard
   - Portfolio tracking
   - Dark mode
   - Mobile app (React Native)

3. **Developer Experience**
   - Better error messages
   - More helpful logs
   - Development tools
   - CLI utilities

## Code Guidelines

### Solidity

- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use NatSpec comments
- Write gas-efficient code
- Include security considerations

Example:
```solidity
/**
 * @notice Swaps tokens using AMM
 * @param tokenIn Address of input token
 * @param amountIn Amount of input token
 * @param amountOutMin Minimum output amount (slippage protection)
 * @return amountOut Actual output amount
 */
function swap(
    address tokenIn,
    uint256 amountIn,
    uint256 amountOutMin
) external nonReentrant returns (uint256 amountOut) {
    // Implementation
}
```

### JavaScript/React

- Use ES6+ features
- Follow React best practices
- Use functional components and hooks
- Add PropTypes or TypeScript types

Example:
```javascript
/**
 * SwapComponent - Token swapping interface
 * @param {string} account - Connected wallet address
 */
function SwapComponent({ account }) {
  const [amount, setAmount] = useState('');
  
  // Implementation
}
```

### CSS

- Use BEM naming or similar
- Mobile-first responsive design
- Consistent spacing and colors
- Reusable components

## Pull Request Process

1. **Update documentation** if needed
2. **Add tests** for new features
3. **Ensure all tests pass**
4. **Update README.md** with any new instructions
5. **Create Pull Request** with clear description

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe testing performed

## Screenshots
If UI changes, add screenshots

## Checklist
- [ ] Code follows project style
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
- [ ] All tests pass
```

## Code Review

All submissions require review. We'll look for:

- ✅ Code quality and style
- ✅ Test coverage
- ✅ Documentation
- ✅ Security considerations
- ✅ Gas efficiency (for contracts)
- ✅ User experience (for frontend)

## Bug Reports

### Before Submitting

1. Check [Troubleshooting Guide](./docs/TROUBLESHOOTING.md)
2. Search existing issues
3. Verify it's not a configuration issue

### Submitting a Bug Report

Include:
- **Description**: Clear and concise description
- **Steps to Reproduce**: Detailed steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**:
  - OS
  - Node.js version
  - Browser (for frontend issues)
  - Network (local/testnet/mainnet)
- **Screenshots**: If applicable
- **Logs**: Console errors or transaction hashes

Example:
```markdown
**Bug**: Swap fails with "Slippage too high" error

**Steps to Reproduce:**
1. Connect wallet to Sepolia testnet
2. Select Token A → Token B
3. Enter amount: 100
4. Slippage: 0.5%
5. Click Swap

**Expected:** Transaction succeeds
**Actual:** Error: "Slippage too high"

**Environment:**
- OS: macOS 13.0
- Node: v18.17.0
- Browser: Chrome 120
- Network: Sepolia

**Transaction Hash:** 0x123...
```

## Feature Requests

We welcome feature requests! Please:

1. **Check existing issues** first
2. **Describe the feature** clearly
3. **Explain the use case**
4. **Propose implementation** (optional)

## Security Issues

⚠️ **DO NOT** open public issues for security vulnerabilities.

Instead:
1. Email: [maintainer email]
2. Describe the vulnerability
3. Provide steps to reproduce
4. Allow time for fix before disclosure

## Development Setup

### Prerequisites

- Node.js v16+
- Git
- MetaMask browser extension

### Environment Setup

1. Clone and install:
   ```bash
   git clone https://github.com/YOUR_USERNAME/bigMoney.git
   cd bigMoney
   npm install
   cd frontend && npm install && cd ..
   ```

2. Create `.env` file (for testnet):
   ```
   PRIVATE_KEY=your_private_key
   SEPOLIA_RPC_URL=your_rpc_url
   ```

3. Start development:
   ```bash
   npx hardhat node  # Terminal 1
   npx hardhat run scripts/deploy.js --network localhost  # Terminal 2
   cd frontend && npm run dev  # Terminal 3
   ```

## Resources

- [Architecture Docs](./docs/ARCHITECTURE.md)
- [API Reference](./docs/API.md)
- [Frontend Guide](./docs/FRONTEND.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)

## Community

- **GitHub Issues**: Bug reports and feature requests
- **Discussions**: General questions and ideas
- **Pull Requests**: Code contributions

## License

By contributing, you agree that your contributions will be licensed under the ISC License.

## Questions?

Feel free to open a GitHub issue with the "question" label.

---

Thank you for contributing to MiniUniswap DEX! 🦄💰
