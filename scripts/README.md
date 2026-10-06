# VITAL Credential Issuance Scripts

This directory contains scripts for issuing VITAL vLEI credentials.

## Prerequisites

Before running the scripts, ensure you have the following installed:
- Python 3.13+
- KERI (`keri` package)
- Internet access (to load the credential schema)

## Setup

### 1. Install the VITAL package

From the root directory of this repository:

```bash
pip install -e .
```

### 2. Start the witness demo

In a separate terminal, run:

```bash
kli witness demo
```

## Running the Credential Issuance Script

### 1. Set up environment variables

From the `scripts` directory:

```bash
source env.sh
```

### 2. Run the issuance script

From the root directory of this repository:

```bash
./scripts/issue-vital-credential-hierarchy.sh
```

## Credential Hierarchy

The script issues the following credential chain:

```
GLEIF External
    |
    v
QVI Credential --> QVI
    |
    v
Legal Entity Credential --> Legal Entity
    |
    v
Legal Entity Subunit Credential --> Subunit
    |
    v
LESR Authorization Credential --> QVI
    |
    v
Legal Entity Subunit Role Credential --> Subunit
```

## Schema SAIDs

The script uses the following credential schemas:

| Credential | Schema SAID |
|------------|-------------|
| QualifiedvLEIIssuervLEICredential | `EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao` |
| LegalEntityvLEICredential | `ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY` |
| LegalEntitySubunitvLEICredential | `EP1jGIb7KXotuUZJf1NSu5wQ089epFfv93cpZECj-YBs` |
| LESRAuthorizationvLEICredential | `ECoqb1jxC9f9zwh664stMAy6gpnNduvP_3SCQlLvkPAR` |
| LegalEntitySubunitRolevLEICredential | `EOlh9L5Y6LEcjQ4KEi3JFHf-IiTKXBKtZ-2Y4egyxS5a` |

## Data Files

The script uses the following data files located in `scripts/data/`:

- `qvi-data.json` - QVI credential attributes
- `legal-entity-data.json` - Legal Entity credential attributes
- `subunit-data.json` - Legal Entity Subunit credential attributes
- `lesr-auth-data.json` - LESR Authorization credential attributes
- `lesr-data.json` - Legal Entity Subunit Role credential attributes
- `rules.json` - Standard vLEI rules block
