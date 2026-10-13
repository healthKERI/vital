"""Sample FHIR data for the Provider Access server."""

import json
from datetime import datetime, timezone

from vital.app.server.store import store


# FHIR code systems
ATR_GROUP_SYSTEM = "http://hl7.org/fhir/us/davinci-atr/CodeSystem/atr-group-type"
PDEX_GROUP_SYSTEM = "http://hl7.org/fhir/us/davinci-pdex/CodeSystem/pdex-group-type"


def init_sample_data():
    """Initialize the store with sample Group resources."""

    # Sample Groups representing different payer attribution groups
    sample_groups = [
        {
            "resourceType": "Group",
            "id": "group-aetna-001",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/davinci-atr/StructureDefinition/atr-group"]
            },
            "identifier": [
                {
                    "system": "http://example.org/groups",
                    "value": "aetna-primary-care-network"
                }
            ],
            "name": "Aetna Provider Attribution Group",
            "type": "person",
            "actual": True,
            "code": {
                "coding": [{
                    "system": ATR_GROUP_SYSTEM,
                    "code": "attributed-patients",
                    "display": "Attributed Patients"
                }]
            },
            "characteristic": [
                {
                    "code": {
                        "coding": [{
                            "system": PDEX_GROUP_SYSTEM,
                            "code": "primary-care",
                            "display": "Primary Care Attribution"
                        }]
                    },
                    "valueBoolean": True,
                    "exclude": False
                }
            ],
            "quantity": 150,
            "managingEntity": {
                "display": "Aetna Health Plans"
            }
        },
        {
            "resourceType": "Group",
            "id": "group-cvs-002",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/davinci-atr/StructureDefinition/atr-group"]
            },
            "identifier": [
                {
                    "system": "http://example.org/groups",
                    "value": "cvs-specialty-network"
                }
            ],
            "name": "CVS Specialty Care Attribution Group",
            "type": "person",
            "actual": True,
            "code": {
                "coding": [{
                    "system": ATR_GROUP_SYSTEM,
                    "code": "attributed-patients",
                    "display": "Attributed Patients"
                }]
            },
            "characteristic": [
                {
                    "code": {
                        "coding": [{
                            "system": PDEX_GROUP_SYSTEM,
                            "code": "specialty-care",
                            "display": "Specialty Care Attribution"
                        }]
                    },
                    "valueBoolean": True,
                    "exclude": False
                }
            ],
            "quantity": 75,
            "managingEntity": {
                "display": "CVS Health"
            }
        },
        {
            "resourceType": "Group",
            "id": "group-caremark-003",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/davinci-pdex/StructureDefinition/pdex-provider-group"]
            },
            "identifier": [
                {
                    "system": "http://example.org/groups",
                    "value": "caremark-pharmacy-network"
                }
            ],
            "name": "Caremark Pharmacy Benefits Group",
            "type": "person",
            "actual": True,
            "code": {
                "coding": [{
                    "system": ATR_GROUP_SYSTEM,
                    "code": "attributed-patients",
                    "display": "Attributed Patients"
                }]
            },
            "characteristic": [
                {
                    "code": {
                        "coding": [{
                            "system": PDEX_GROUP_SYSTEM,
                            "code": "pharmacy",
                            "display": "Pharmacy Benefits"
                        }]
                    },
                    "valueBoolean": True,
                    "exclude": False
                }
            ],
            "quantity": 200,
            "managingEntity": {
                "display": "CVS Caremark"
            }
        },
        {
            "resourceType": "Group",
            "id": "group-united-004",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/davinci-atr/StructureDefinition/atr-group"]
            },
            "identifier": [
                {
                    "system": "http://example.org/groups",
                    "value": "united-medicare-advantage"
                }
            ],
            "name": "UnitedHealthcare Medicare Advantage Group",
            "type": "person",
            "actual": True,
            "code": {
                "coding": [{
                    "system": ATR_GROUP_SYSTEM,
                    "code": "attributed-patients",
                    "display": "Attributed Patients"
                }]
            },
            "characteristic": [
                {
                    "code": {
                        "coding": [{
                            "system": PDEX_GROUP_SYSTEM,
                            "code": "medicare-advantage",
                            "display": "Medicare Advantage"
                        }]
                    },
                    "valueBoolean": True,
                    "exclude": False
                }
            ],
            "quantity": 320,
            "managingEntity": {
                "display": "UnitedHealthcare"
            }
        }
    ]

    for group in sample_groups:
        store.groups[group["id"]] = group


def generate_sample_patients(group_id: str, count: int = 5) -> list[dict]:
    """Generate sample Patient resources for export."""
    patients = []
    base_names = [
        ("John", "Smith"),
        ("Jane", "Doe"),
        ("Robert", "Johnson"),
        ("Emily", "Williams"),
        ("Michael", "Brown"),
        ("Sarah", "Davis"),
        ("David", "Miller"),
        ("Jennifer", "Wilson"),
    ]

    for i in range(min(count, len(base_names))):
        first, last = base_names[i]
        patient = {
            "resourceType": "Patient",
            "id": f"patient-{group_id}-{i+1:03d}",
            "identifier": [
                {
                    "system": "http://example.org/patients",
                    "value": f"MRN-{group_id}-{i+1:05d}"
                }
            ],
            "name": [{
                "family": last,
                "given": [first],
                "use": "official"
            }],
            "gender": "male" if i % 2 == 0 else "female",
            "birthDate": f"{1950 + (i * 7) % 50}-{(i % 12) + 1:02d}-{(i % 28) + 1:02d}"
        }
        patients.append(patient)

    return patients


def generate_sample_coverage(patient_id: str, group_id: str) -> dict:
    """Generate a sample Coverage resource."""
    return {
        "resourceType": "Coverage",
        "id": f"coverage-{patient_id}",
        "status": "active",
        "beneficiary": {
            "reference": f"Patient/{patient_id}"
        },
        "payor": [{
            "display": "Sample Payer"
        }],
        "class": [{
            "type": {
                "coding": [{
                    "system": "http://terminology.hl7.org/CodeSystem/coverage-class",
                    "code": "group"
                }]
            },
            "value": group_id
        }]
    }


def generate_export_ndjson(group_id: str) -> str:
    """Generate NDJSON content for a bulk export."""
    patients = generate_sample_patients(group_id)
    lines = []

    for patient in patients:
        lines.append(json.dumps(patient))

    return "\n".join(lines)


def generate_export_manifest(
    task_id: str,
    group_id: str,
    request_url: str,
    download_tokens: list[tuple[str, str]],  # (resource_type, token)
) -> dict:
    """Generate a bulk export manifest."""
    now = datetime.now(timezone.utc).isoformat()

    return {
        "transactionTime": now,
        "request": request_url,
        "requiresAccessToken": False,
        "output": [
            {
                "type": resource_type,
                "url": f"/download/{token}"
            }
            for resource_type, token in download_tokens
        ],
        "error": []
    }


def create_bundle(resources: list[dict], bundle_type: str = "searchset") -> dict:
    """Create a FHIR Bundle from a list of resources."""
    return {
        "resourceType": "Bundle",
        "type": bundle_type,
        "total": len(resources),
        "entry": [
            {
                "fullUrl": f"urn:uuid:{res.get('id', 'unknown')}",
                "resource": res
            }
            for res in resources
        ]
    }


def create_operation_outcome(
    severity: str,
    code: str,
    diagnostics: str
) -> dict:
    """Create a FHIR OperationOutcome resource."""
    return {
        "resourceType": "OperationOutcome",
        "issue": [{
            "severity": severity,
            "code": code,
            "diagnostics": diagnostics
        }]
    }
