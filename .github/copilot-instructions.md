# GitHub Copilot Instructions for Tightener Ecosystem

## Agent Skill Framework

This workspace uses a structured skill-based documentation system. **Before working on any task**, consult the skill documentation:

**Primary Reference**: [TightenerDocs/SKILL.md](../TightenerDocs/SKILL.md)

This document organizes all ecosystem knowledge into 9 categorized skill areas and provides:
- Quick navigation to relevant documentation
- Skill dependency mappings
- Task-to-skill reference tables
- Cross-component relationships

## Required Reading Order

1. **Always start with**: [TightenerDocs/SKILL.md](../TightenerDocs/SKILL.md) to identify relevant skills
2. **For coding tasks**: Review [Tightener_CodingConventions.md](../TightenerDocs/Tightener_CodingConventions.md) before writing code
3. **For licensing/distribution**: Reference [Tightener_LicenseTracking.md](../TightenerDocs/Tightener_LicenseTracking.md)
4. **For ecosystem context**: See [Tightener_Overview.md](../TightenerDocs/Tightener_Overview.md)

## Mandatory Coding Standards

When writing C/C++ code in this workspace:
- **Must use** Tightener control flow macros: `BEGIN_FUNCTION`, `END_FUNCTION`, `SANITY_CHECK`, etc.
- **Must follow** naming conventions: `fMemberVariable`, `myFunction()`, `MyClass`, `CONSTANT_VALUE`
- **Must use** Allman brace style for C/C++ (braces on own lines)
- **Must use** 4-space indentation (no tabs)
- **Must implement** "If-Break" pattern instead of deep nesting

When writing JavaScript/ExtendScript:
- **Must use** K&R/1TBS brace style (opening brace on same line)
- **Must follow** camelCase for functions and variables

## Architecture Awareness

The Tightener ecosystem consists of 25+ interconnected projects. Always consider:
- **Cross-platform requirements**: Mac, Windows, Linux
- **Multi-VM build orchestration**: Changes may affect automated builds
- **Licensing integration**: Capability-based system via TightenerRegistry
- **TPKG packaging**: Distribution format for scripts and plugins

## Quick Task Mapping

| What You're Doing | Read First |
|-------------------|------------|
| Fixing C++ plugin bugs | SKILL.md → Skills 1, 2, 8 |
| Creating InDesign scripts | SKILL.md → Skills 1, 2, 6, 9 |
| Modifying build system | SKILL.md → Skills 1, 2, 5 |
| License system changes | SKILL.md → Skills 1, 2, 3 |
| New feature development | SKILL.md → All relevant skills |

## Component-Specific Notes

- **ActivePageItems**: Uses `LicenseData` class for capability integration
- **TightenerDLL**: ExtendScript integration layer
- **PluginInstaller**: Xojo-based, handles TPKG installation
- **CRDT_ES/UXP**: JSDoc-based documentation generation
- **Build System**: SSH-orchestrated Mac/Linux/Windows VMs

---

**Remember**: The skill framework in [TightenerDocs/SKILL.md](../TightenerDocs/SKILL.md) is your roadmap. Follow it to maintain consistency and architectural integrity across the ecosystem.
