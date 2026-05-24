---
schema: 1
name: security-review
description: Systematic security review — OWASP, injection, auth, secrets, supply chain
version: 0.1.0
---

## When to use this skill

Use when reviewing code for security vulnerabilities, designing authentication
or authorization, handling secrets, or auditing dependencies.

## Review Checklist

### 1. Injection (OWASP A03)

**Check for:**
- SQL: parameterized queries only, never string concatenation
- Command injection: no `shell=True`, no unsanitized user input in commands
- XSS: output encoding, CSP headers, no `dangerouslySetInnerHTML` without sanitization
- Template injection: no user input in template expressions
- Path traversal: canonicalize paths, reject `..`, validate against allowlist

**Pattern:**

```text
User input → Validation → Sanitization → Parameterized API
Never: User input → String interpolation → Execution
```

### 2. Authentication & Authorization (OWASP A01, A07)

**Check for:**
- Authentication bypass: every endpoint has auth middleware unless explicitly public
- Broken access control: authorization checked at the resource level, not just the route
- Session management: secure flags, httpOnly, SameSite, rotation on privilege change
- Password storage: bcrypt/scrypt/argon2 only, never MD5/SHA-1/SHA-256 alone
- MFA: supported for privileged operations
- JWT: verify signature, check expiration, validate issuer and audience

**Questions to ask:**
- Can user A access user B's data by changing an ID in the URL?
- What happens if the auth token is expired but cached?
- Is there a rate limit on login attempts?

### 3. Secrets Management (OWASP A02)

**Never:**
- Hardcoded secrets in source code
- Secrets in environment variables without rotation strategy
- Secrets in logs (mask/redact)
- Secrets in error messages returned to clients
- Secrets committed to git (even if later removed — history persists)

**Always:**
- Use a secrets manager (Vault, AWS Secrets Manager, GCP Secret Manager)
- Rotate secrets on a schedule
- Audit secret access
- Use short-lived tokens over long-lived keys

**Detection:** Search for patterns: `password=`, `secret=`, `api_key=`,
`token=`, base64-encoded strings, high-entropy strings in config files.

### 4. Data Exposure (OWASP A01)

**Check for:**
- API responses returning more fields than the client needs
- Error messages exposing stack traces, SQL queries, or internal paths
- Logs containing PII, tokens, or request bodies
- Debug endpoints enabled in production

**Pattern:** Explicit allowlist of fields in API responses. Never serialize
entire domain objects to the wire.

### 5. Supply Chain (OWASP A06)

**Check for:**
- Dependency versions pinned (lockfile committed)
- Known vulnerabilities (`npm audit`, `cargo audit`, `pip-audit`)
- Typosquatting: verify package names match official sources
- Minimal dependencies: each dependency is justified
- No `postinstall` scripts from untrusted packages

### 6. Cryptography

**Never:**
- Roll your own crypto
- Use ECB mode
- Use MD5 or SHA-1 for security purposes
- Reuse nonces/IVs
- Use random number generators that aren't cryptographically secure

**Always:**
- AES-256-GCM or ChaCha20-Poly1305 for symmetric encryption
- RSA-OAEP or ECDH for asymmetric
- HKDF for key derivation
- Use well-audited libraries (libsodium, ring, Web Crypto API)

## Severity Classification

| Severity | Definition | Action |
|----------|-----------|--------|
| Critical | Exploitable without authentication, data breach likely | Block merge, fix immediately |
| High | Exploitable with low-privilege access | Block merge, fix in this PR |
| Medium | Requires specific conditions to exploit | Fix before release |
| Low | Defense-in-depth improvement | Track as debt |

## Output Format

When performing a security review, report findings as:

```markdown
## Security Findings

### [CRITICAL/HIGH/MEDIUM/LOW] — [Title]
**Location:** `file:line`
**Issue:** [What's wrong]
**Impact:** [What an attacker could do]
**Fix:** [Specific remediation]
```
